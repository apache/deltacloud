module CIMI
  module RabbitHelper

    def generate_delete_operation(opts={})
      collection_name = @collection_name.to_s.singularize.camelize
      operation :destroy, :with_capability => opts[:with_capability] do
        description "Delete specified Credential entity"
        control do
          CIMI::Service.const_get(collection_name).delete!(params[:id], self)
          no_content_with_status(200)
        end
      end
    end

    def generate_create_operation(opts={})
      collection_name = @collection_name.to_s.singularize.camelize
      operation :create, :with_capability => opts[:with_capability] do
        description "Create new #{collection_name} entity"
        control do
          ent = CIMI::Service.const_get("#{collection_name}Create").parse(self).create
          headers_for_create ent
          respond_to do |format|
            format.json { ent.to_json }
            format.xml { ent.to_xml }
          end
        end
      end
    end

    def generate_index_operation(opts={})
      collection_name = @collection_name.to_s.singularize.camelize
      operation :index, :with_capability => opts[:with_capability] do
        description "List all entities in #{collection_name} collection"
        control do
          ent = CIMI::Service.const_get(collection_name).list(self)
          respond_to do |format|
            format.xml { ent.to_xml }
            format.json { ent.to_json }
          end
        end
      end
    end

    def generate_show_operation(opts={})
      collection_name = @collection_name.to_s.singularize.camelize
      operation :show, :with_capability => opts[:with_capability] do
        description "Show details about #{collection_name} entity"
        control do
          ent = CIMI::Service.const_get(collection_name).find(params[:id], self)
          respond_to do |format|
            format.xml { ent.to_xml }
            format.json { ent.to_json }
          end
        end
      end
    end

    def generate_remove_from_system_operation(opts={})
      collection_name = "System#{@collection_name.to_s.singularize.camelize}"
      operation :destroy, :with_capability => opts[:with_capability] do
        description "Remove specified #{collection_name} entity from System"
        control do
          CIMI::Service.const_get(collection_name).delete!(params[:id], self, params[:ent_id])
          no_content_with_status(200)
        end
      end
    end

    def generate_add_to_system_operation(opts={})
      collection_name = "System#{@collection_name.to_s.singularize.camelize}"
      operation :create, :with_capability => opts[:with_capability] do
        description "Add specified #{collection_name} entity to System"
        control do
          ent = CIMI::Service.const_get("#{collection_name}Create").parse(params[:id], self).create
          headers_for_create ent
          respond_to do |format|
            format.json { ent.to_json }
            format.xml { ent.to_xml }
          end
        end
      end
    end

    def generate_system_subcollection_index_operation(opts={})
      collection_name = "System#{@collection_name.to_s.singularize.camelize}"
      operation :index, :with_capability => opts[:with_capability] do
        description "List all entities in System's #{collection_name} collection"
        control do
          ent = CIMI::Service.const_get(collection_name).collection_for_system(params[:id], self)
          respond_to do |format|
            format.xml { ent.to_xml }
            format.json { ent.to_json }
          end
        end
      end
    end

    def generate_system_subcollection_show_operation(opts={})
      collection_name = "System#{@collection_name.to_s.singularize.camelize}"
      operation :show, :with_capability => opts[:with_capability] do
        description "Show details of System's #{collection_name} entity"
        control do
          ent = CIMI::Service.const_get(collection_name).find(params[:id], self, params[:ent_id])
          respond_to do |format|
            format.xml { ent.to_xml }
            format.json { ent.to_json }
          end
        end
      end
    end

  end
end
