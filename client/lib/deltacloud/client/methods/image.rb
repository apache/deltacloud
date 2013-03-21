# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

module Deltacloud::Client
  module Methods
    module Image

      # Retrieve list of all images
      #
      # - filter_opts:
      #   - :id -> Filter images using their 'id'
      #   - :state -> Filter images  by their 'state'
      #   - :architecture -> Filter images  by their 'architecture'
      #
      def images(filter_opts={})
        from_collection :images,
          connection.get(api_uri('images'), filter_opts)
      end

      # Retrieve the given image
      #
      # - image_id -> Image to retrieve
      #
      def image(image_id)
        from_resource :image,
          connection.get(api_uri("images/#{image_id}"))
      end

      # Create a new image from instance
      #
      # - instance_id -> The stopped instance used for creation
      # - create_opts
      #   - :name     -> Name of the new image
      #   - :description -> Description of the new image
      #
      def create_image(instance_id, create_opts={})
        create_resource :image, { :instance_id => instance_id }.merge(create_opts)
      end

      # Destroy given image
      # NOTE: This operation might not be supported for all drivers.
      #
      def destroy_image(image_id)
        destroy_resource :image, image_id
      end

    end
  end
end
