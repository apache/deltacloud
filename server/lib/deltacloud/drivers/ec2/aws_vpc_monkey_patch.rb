# This is a copy of code that has been submitted upstream
# https://github.com/appoxy/aws/pull/116
#
# If you make changes here, make sure they go upstream, too

unless Aws::Ec2::method_defined?(:create_vpc)
  class Aws::Ec2
    #-----------------------------------------------------------------
    #      VPC related
    #-----------------------------------------------------------------

    # Create VPC
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-CreateVpc.html
    #
    # ec2.create_vpc("10.0.0.0/16")
    # FIXME: EVen though the EC2 docs describe the parameter instanceTenancy,
    # I could not get it to recognize that
    def create_vpc(cidr_block = "10.0.0.0/16")
      params = { "CidrBlock" => cidr_block }
      link = generate_request("CreateVpc", params)
      request_info(link, QEc2VpcsParser.new("vpc", :logger => @logger))
    rescue Exception
      on_exception
    end


    # Describe  VPC's
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DescribeVpcs.html
    #
    # ec2.describe_vpcs
    # ec2.describe_vpcs(vpcId1, vpcId2, 'Filter.1.Name' => 'state', 'Filter.1.Value' = > 'pending', ...)
    def describe_vpcs(*args)
      if args.last.is_a?(Hash)
        params = args.pop.dup
      else
        params = {}
      end
      1.upto(args.size) { |i| params["VpcId.#{i}"] = args[i-1] }
      link = generate_request("DescribeVpcs", params)
      request_info(link, QEc2VpcsParser.new("item", :logger => @logger))
    rescue Exception
      on_exception
    end

    # Delete VPC
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DeleteVpc.html
    #
    # ec2.delete_vpc(vpc_id)
    def delete_vpc(vpc_id)
      params = { "VpcId" => vpc_id }
      link = generate_request("DeleteVpc", params)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Create subnet in a VPC
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-CreateSubnet.html
    #
    # ec2.create_subnet(vpc_id, cidr_block)
    # ec2.create_subnet(vpc_id, cidr_block, availability_zone))
    def create_subnet(vpc_id, cidr_block, availability_zone = nil)
      params = { "VpcId" => vpc_id, "CidrBlock" => cidr_block }
      params["AvailabilityZone"] = availability_zone if availability_zone
      link = generate_request("CreateSubnet", params)
      request_info(link, QEc2SubnetsParser.new("subnet", :logger => @logger))
    rescue Exception
      on_exception
    end

    # Describe subnets
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DescribeSubnets.html
    #
    # ec2.describe_subnets
    # ecs.describe_subnets(subnetId1, SubnetId2, ...,
    #                      'Filter.1.Name' => 'state',
    #                      'Filter.1.Value.1' => 'pending',
    #                      'Filter.2.Name' => ...)
    def describe_subnets(*args)
      if args.last.is_a?(Hash)
        params = args.pop.dup
      else
        params = {}
      end
      1.upto(args.size) { |i| params["SubnetId.#{i}"] = args[i-1] }
      link = generate_request("DescribeSubnets", params)
      request_info(link, QEc2SubnetsParser.new("item", :logger => @logger))
    rescue Exception
      on_exception
    end

    # Delete Subnet
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DeleteSubnet.html
    #
    # ec2.delete_subnet(subnet_id)
    def delete_subnet(subnet_id)
      params = { "SubnetId" => subnet_id }
      link = generate_request("DeleteSubnet", params)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # The only change in this class compared to upstream is
    # that we parse out subnetId and vpcId
    class QEc2DescribeInstancesParser < Aws::AwsParser #:nodoc:
      def tagstart(name, attributes)
        # DescribeInstances property
        if (name == 'item' && @xmlpath == 'DescribeInstancesResponse/reservationSet') ||
            # RunInstances property
        (name == 'RunInstancesResponse')
          @reservation = {:aws_groups    => [],
                          :instances_set => []}

        elsif (name == 'item') &&
            # DescribeInstances property
        (@xmlpath=='DescribeInstancesResponse/reservationSet/item/instancesSet' ||
            # RunInstances property
        @xmlpath=='RunInstancesResponse/instancesSet')
          # the optional params (sometimes are missing and we dont want them to be nil)
          @instance = {:aws_reason        => '',
                       :dns_name          => '',
                       :private_dns_name  => '',
                       :ami_launch_index  => '',
                       :ssh_key_name      => '',
                       :aws_state         => '',
                       :root_device_type  => '',
                       :root_device_name  => '',
                       :architecture      => '',
                       :subnet_id         => '',
                       :vpc_id            => '',
                       :block_device_mappings => [],
                       :aws_product_codes => [],
                       :tags              => {}}
        end
      end

      def tagend(name)
        case name
          when  'rootDeviceType' then
            @instance[:root_device_type] = @text
          when 'architecture' then
            @instance[:architecture] = @text
          when 'rootDeviceName' then
            @instance[:root_device_name] = @text
          # reservation
          when 'reservationId' then
            @reservation[:aws_reservation_id] = @text
          when 'ownerId' then
            @reservation[:aws_owner] = @text
          when 'groupId' then
            @reservation[:aws_groups] << @text
          # instance
          when 'instanceId' then
            @instance[:aws_instance_id] = @text
          when 'imageId' then
            @instance[:aws_image_id] = @text
          when 'dnsName' then
            @instance[:dns_name] = @text
          when 'privateDnsName' then
            @instance[:private_dns_name] = @text
          when 'reason' then
            @instance[:aws_reason] = @text
          when 'keyName' then
            @instance[:ssh_key_name] = @text
          when 'amiLaunchIndex' then
            @instance[:ami_launch_index] = @text
          when 'code' then
            @instance[:aws_state_code] = @text
          when 'name' then
            @instance[:aws_state] = @text
          when 'productCode' then
            @instance[:aws_product_codes] << @text
          when 'instanceType' then
            @instance[:aws_instance_type] = @text
          when 'launchTime' then
            @instance[:aws_launch_time] = @text
          when 'kernelId' then
            @instance[:aws_kernel_id] = @text
          when 'ramdiskId' then
            @instance[:aws_ramdisk_id] = @text
          when 'platform' then
            @instance[:aws_platform] = @text
          when 'availabilityZone' then
            @instance[:aws_availability_zone] = @text
          when 'privateIpAddress' then
            @instance[:aws_private_ip_address] = @text
          when 'subnetId' then
            @instance[:subnet_id] = @text
          when 'vpcId' then
            @instance[:vpc_id] = @text
          when 'key' then
            @tag_key = @text
          when 'value' then
            @tag_value = @text
          when 'deviceName' then
            @device_name = @text
          when 'volumeId' then
            @volume_id = @text
          when 'state'
            if @xmlpath == 'DescribeInstancesResponse/reservationSet/item/instancesSet/item/monitoring' || # DescribeInstances property
            @xmlpath == 'RunInstancesResponse/instancesSet/item/monitoring' # RunInstances property
              @instance[:monitoring_state] = @text
            end
          when 'item'
            if @xmlpath=='DescribeInstancesResponse/reservationSet/item/instancesSet/item/tagSet' # Tags
              @instance[:tags][@tag_key] = @tag_value
            elsif @xmlpath == 'DescribeInstancesResponse/reservationSet/item/instancesSet/item/blockDeviceMapping' # Block device mappings
              @instance[:block_device_mappings] << { @device_name => @volume_id }
            elsif @xmlpath == 'DescribeInstancesResponse/reservationSet/item/instancesSet' || # DescribeInstances property
            @xmlpath == 'RunInstancesResponse/instancesSet' # RunInstances property
              @reservation[:instances_set] << @instance
            elsif @xmlpath=='DescribeInstancesResponse/reservationSet' # DescribeInstances property
              @result << @reservation
            end
          when 'RunInstancesResponse' then
            @result << @reservation # RunInstances property
        end
      end

      def reset
        @result = []
      end
    end

    #-----------------------------------------------------------------
    #      PARSERS: Vpc
    #-----------------------------------------------------------------

    class QEc2VpcsParser < Aws::AwsParser #:nodoc:
      def initialize(wrapper, opts = {})
        super(opts)
        @wrapper = wrapper
      end

      def tagstart(name, attribute)
        @vpc = {} if name == @wrapper
      end

      def tagend(name)
        case name
        when 'vpcId' then
          @vpc[:vpc_id] = @text
        when 'state' then
          @vpc[:state] = @text
        when 'cidrBlock' then
          @vpc[:cidr_block] = @text
        when 'dhcpOptionsId' then
          @vpc[:dhcp_options_id] = @text
        when @wrapper
          @result << @vpc
        end
      end

      def reset
        @result = []
      end
    end

    class QEc2SubnetsParser < Aws::AwsParser #:nodoc
      def initialize(wrapper, opts = {})
        super(opts)
        @wrapper = wrapper
      end

      def tagstart(name, attribute)
        @subnet = {} if name == @wrapper
      end

      def tagend(name)
        case name
        when 'subnetId' then
          @subnet[:subnet_id] = @text
        when 'state' then
          @subnet[:state] = @text
        when 'vpcId' then
          @subnet[:vpc_id] = @text
        when 'cidrBlock' then
          @subnet[:cidr_block] = @text
        when 'availableIpAddressCount' then
          @subnet[:available_ip_address_count] = @text
        when 'availabilityZone' then
          @subnet[:availability_zone] = @text
        when @wrapper
          @result << @subnet
        end
      end

      def reset
        @result = []
      end
    end
  end
end
