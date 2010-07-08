
require 'deltacloud/base_driver'

class Ec2Driver < DeltaCloud::BaseDriver

  # 
  # Flavors
  # 
  FLAVORS = [ 
    { 
      :id=>'m1-small',
      :memory=>1.7,
      :storage=>160,
      :architecture=>'i386',
    },
    {
      :id=>'m1-large', 
      :memory=>7.5,
      :storage=>850,
      :architecture=>'x86_64',
    },
    { 
      :id=>'m1-xlarge', 
      :memory=>15,
      :storage=>1690,
      :architecture=>'x86_64',
    },
    { 
      :id=>'c1-medium', 
      :memory=>1.7,
      :storage=>350,
      :architecture=>'x86_64',
    },
    { 
      :id=>'c1-xlarge', 
      :memory=>7,
      :storage=>1690,
      :architecture=>'x86_64',
    },
  ]

  def flavors(credentials, ids=nil)
    return FLAVORS if ( ids.nil? )
    FLAVORS.select{|f| ids.include?(f[:id])}
  end

  # 
  # Images
  # 

  def images(credentials, ids_or_owner=nil )
    ec2 = new_client( credentials )
    images = []
    safely do
      if ( ids_or_owner.is_a?( Array ) ) 
        ec2.describe_images(ids_or_owner).each do |ec2_image|
          if ( ec2_image[:aws_id] =~ /^ami-/ ) 
            images << convert_image( ec2_image )
          end
        end
      else
        ec2.describe_images_by_owner( ids_or_owner ).each do |ec2_image|
          if ( ec2_image[:aws_id] =~ /^ami-/ ) 
            images << convert_image( ec2_image )
          end
        end
      end
    end
    images.sort_by{|e| [e[:owner_id],e[:description]]}
  end

  # 
  # Instances
  # 

  def instances(credentials, ids=nil)
    ec2 = new_client(credentials)
    instances = []
    safely do
      ec2.describe_instances(ids).each do |ec2_instance|
        instances << convert_instance( ec2_instance )
      end
    end
    instances
  end

  def create_instance(credentials, image_id, flavor_id)
    ec2 = new_client( credentials )
    ec2_instances = ec2.run_instances( 
                          image_id, 
                          1,1,
                          [],
                          nil,
                          '',
                          'public',
                          flavor_id.gsub( /-/, '.' ) )
    convert_instance( ec2_instances.first )
  end

  def reboot_instance(credentials, id)
    ec2 = new_client(credentials)
    ec2.reboot_instances( id )
  end

  def delete_instance(credentials, id)
    ec2 = new_client(credentials)
    ec2.terminate_instances( id )
  end

  # 
  # Storage Volumes
  # 

  def volumes(credentials, ids=nil)
    ec2 = new_client( credentials ) 
    volumes = []
    ec2.describe_volumes(ids).each do |ec2_volume|
      volumes << convert_volume( ec2_volume )
    end
    volumes
  end

  # 
  # Storage Snapshots
  # 

  def snapshots(credentials, ids=nil)
    ec2 = new_client( credentials ) 
    snapshots = []
    ec2.describe_snapshots(ids).each do |ec2_snapshot|
      snapshots << convert_snapshot( ec2_snapshot )
    end
    snapshots
  end

  private

  def new_client(credentials)
    if ( credentials[:name].nil? || credentials[:password].nil? || credentials[:name] == '' || credentials[:password] == '' ) 
      raise DeltaCloud::AuthException.new
    end
    RightAws::Ec2.new(credentials[:name], credentials[:password], :cache=>false )
  end

  def convert_image(ec2_image)
    {
      :id=>ec2_image[:aws_id], 
      :description=>ec2_image[:aws_location],
      :owner_id=>ec2_image[:aws_owner],
      :architecture=>ec2_image[:aws_architecture],
    } 
  end
 
  def convert_instance(ec2_instance)
    {
      :id=>ec2_instance[:aws_instance_id], 
      :state=>ec2_instance[:aws_state].upcase,
      :image_id=>ec2_instance[:aws_image_id],
      :owner_id=>ec2_instance[:aws_owner],
      :public_address=>( ec2_instance[:dns_name] == '' ? nil : ec2_instance[:dns_name] ),
      :private_address=>( ec2_instance[:private_dns_name] == '' ? nil : ec2_instance[:private_dns_name] ),
      :flavor_id=>ec2_instance[:aws_instance_type].gsub( /\./, '-'),
    } 
  end

  def convert_volume(ec2_volume)
    {
      :id=>ec2_volume[:aws_id],
      :created=>ec2_volume[:aws_created_at],
      :state=>ec2_volume[:aws_status].upcase,
      :capacity=>ec2_volume[:aws_size],
      :instance_id=>ec2_volume[:aws_instance_id],
      :device=>ec2_volume[:aws_device],
    }
  end

  def convert_snapshot(ec2_snapshot)
    { 
      :id=>ec2_snapshot[:aws_id],
      :state=>ec2_snapshot[:aws_status].upcase,
      :volume_id=>ec2_snapshot[:aws_volume_id],
      :created=>ec2_snapshot[:aws_started_at],
    }
  end

  def safely(&block) 
    begin
      block.call
    rescue RightAws::AwsError => e
      if ( e.include?( /SignatureDoesNotMatch/ ) )
        raise DeltaCloud::AuthException.new
      elsif ( e.include?( /InvalidClientTokenId/ ) )
        raise DeltaCloud::AuthException.new
      else
        e.errors.each do |error|
          puts "ERROR #{error.inspect}"
        end
      end
    end
  end


end
