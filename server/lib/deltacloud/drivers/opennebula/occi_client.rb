#--------------------------------------------------------------------------- #
# Copyright 2002-2009, Distributed Systems Architecture Group, Universidad
# Complutense de Madrid (dsa-research.org)
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#--------------------------------------------------------------------------- #

require 'rubygems'
require 'uri'
require 'rexml/document'

require 'deltacloud/drivers/opennebula/cloud_client'


module OCCIClient

    #####################################################################
    #  Client Library to interface with the OpenNebula OCCI Service
    #####################################################################
    class Client

        ######################################################################
        # Initialize client library
        ######################################################################
        def initialize(endpoint_str=nil, user=nil, pass=nil, debug_flag=true)
            @debug = debug_flag

            # Server location
            if endpoint_str
                @endpoint =  endpoint_str
            elsif ENV["OCCI_URL"]
                @endpoint = ENV["OCCI_URL"]
            else
                @endpoint = "http://localhost:4567"
            end

            # Autentication
            if user && pass
                @occiauth = [user, pass]
            else
                @occiauth = CloudClient::get_one_auth
            end

            if !@occiauth
                raise "No authorization data present"
            end

            @occiauth[1] = Digest::SHA1.hexdigest(@occiauth[1])
        end

        #################################
        # Pool Resource Request Methods #
        #################################

        ######################################################################
        # Post a new VM to the VM Pool
        # :instance_type
        # :xmlfile
        ######################################################################
        def post_vms(xmlfile)
            xml=File.read(xmlfile)

            url = URI.parse(@endpoint+"/compute")

            req = Net::HTTP::Post.new(url.path)
            req.body=xml

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) do |http|
                http.request(req)
            end

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end

        ######################################################################
        # Retieves the pool of Virtual Machines
        ######################################################################
        def get_vms
            url = URI.parse(@endpoint+"/compute")
            req = Net::HTTP::Get.new(url.path)

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) {|http|
                http.request(req)
            }

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end

        ######################################################################
        # Retieves the pool of Images owned by the user
        ######################################################################
        def get_images
            url = URI.parse(@endpoint+"/storage")
            req = Net::HTTP::Get.new(url.path)

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) {|http|
                http.request(req)
            }

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end

        ####################################
        # Entity Resource Request Methods  #
        ####################################

        ######################################################################
        # :id VM identifier
        ######################################################################
        def get_vm(id)
            url = URI.parse(@endpoint+"/compute/" + id.to_s)
            req = Net::HTTP::Get.new(url.path)

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) {|http|
                http.request(req)
            }

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end

        ######################################################################
        # Puts a new Compute representation in order to change its state
        # :xmlfile Compute OCCI xml representation
        ######################################################################
        def put_vm(xmlfile)
            xml=File.read(xmlfile)
            vm_info=REXML::Document.new(xml).root.elements

            url = URI.parse(@endpoint+'/compute/' + vm_info['ID'].text)

            req = Net::HTTP::Put.new(url.path)
            req.body = xml

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) do |http|
                http.request(req)
            end

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end

       #######################################################################
        # Retieves an Image
        # :image_uuid Image identifier
        ######################################################################
        def get_image(image_uuid)
            url = URI.parse(@endpoint+"/storage/"+image_uuid)
            req = Net::HTTP::Get.new(url.path)

            req.basic_auth @occiauth[0], @occiauth[1]

            res = CloudClient::http_start(url) {|http|
                http.request(req)
            }

            if CloudClient::is_error?(res)
                return res
            else
                return res.body
            end
        end
    end
end
