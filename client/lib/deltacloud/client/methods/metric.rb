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
    module Metric

      # Retrieve list of all metric entities
      #
      # Filter options:
      #
      # - :id -> Filter entities using 'id' attribute
      #
      def metrics(filter_opts={})
        from_collection :metrics,
        connection.get(api_uri('metrics'), filter_opts)
      end

      # Retrieve the single metric entity
      #
      # - metric_id -> Metric entity to retrieve
      #
      def metric(metric_id)
        from_resource :metric,
          connection.get(api_uri("metrics/#{metric_id}"))
      end

      # Create a new metric
      #
      # - create_opts
      #
      # def create_metric(create_opts={})
      #   must_support! :metrics
      #    response = connection.post(api_uri('metrics')) do |request|
      #     request.params = create_opts
      #   end
      #   model(:metric).convert(self, response.body)
      # end

    end
  end
end
