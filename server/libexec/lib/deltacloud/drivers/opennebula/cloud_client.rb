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

require 'net/https'

begin
    require 'curb'
    CURL_LOADED=true
rescue LoadError
    CURL_LOADED=false
end

begin
    require 'net/http/post/multipart'
rescue LoadError
end

###############################################################################
# The CloudClient module contains general functionality to implement a 
# Cloud Client
###############################################################################
module CloudClient
    # #########################################################################
    # Default location for the authentication file
    # #########################################################################
    DEFAULT_AUTH_FILE = ENV["HOME"]+"/.one/one_auth"
    
    # #########################################################################
    # Gets authorization credentials from ONE_AUTH or default
    # auth file.
    #
    # Raises an error if authorization is not found
    # #########################################################################
    def self.get_one_auth
        if ENV["ONE_AUTH"] and !ENV["ONE_AUTH"].empty? and 
           File.file?(ENV["ONE_AUTH"])
            one_auth=File.read(ENV["ONE_AUTH"]).strip.split(':')
        elsif File.file?(DEFAULT_AUTH_FILE)
            one_auth=File.read(DEFAULT_AUTH_FILE).strip.split(':')
        else
            raise "No authorization data present"
        end
        
        raise "Authorization data malformed" if one_auth.length < 2
        
        one_auth
    end
        
    # #########################################################################
    # Starts an http connection and calls the block provided. SSL flag
    # is set if needed.
    # #########################################################################
    def self.http_start(url, &block)
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme=='https'
            http.use_ssl = true
            http.verify_mode=OpenSSL::SSL::VERIFY_NONE
        end
        
        begin
            http.start do |connection|
                block.call(connection)
            end
        rescue Errno::ECONNREFUSED => e
            str =  "Error connecting to server (#{e.to_s})."
            str << "Server: #{url.host}:#{url.port}"
        
            return CloudClient::Error.new(str)
        end
    end

    # #########################################################################
    # The Error Class represents a generic error in the Cloud Client
    # library. It contains a readable representation of the error.
    # #########################################################################
    class Error
        attr_reader :message
        
        # +message+ a description of the error
        def initialize(message=nil)
            @message=message
        end

        def to_s()
            @message
        end
    end

    # ######################################################################### 
    # Returns true if the object returned by a method of the OpenNebula
    # library is an Error
    # #########################################################################
    def self.is_error?(value)
        value.class==CloudClient::Error
    end
end
        
# Command line help functions
module CloudCLI
    # Returns the command name
    def cmd_name
        File.basename($0)
    end
end
