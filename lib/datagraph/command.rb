module Datagraph
  ##
  # Base class for CLI commands.
  class Command
    autoload :Register, 'datagraph/command/register'
    autoload :List,     'datagraph/command/list'
    autoload :Create,   'datagraph/command/create'
    autoload :Rename,   'datagraph/command/rename'
    autoload :Drop,     'datagraph/command/drop'
    autoload :Clear,    'datagraph/command/clear'
    autoload :Count,    'datagraph/command/count'
    autoload :Query,    'datagraph/command/query'
    autoload :Import,   'datagraph/command/import'
    autoload :Export,   'datagraph/command/export'
    autoload :Open,     'datagraph/command/open'
    autoload :URL,      'datagraph/command/url'

    include Datagraph::Client

    def basename
      RDF::CLI.basename
    end

    def validate_repository_specs(resource_specs)
      resources = validate_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          RDF::CLI.abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

    def validate_resource_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        case resource
          when Account
            RDF::CLI.abort "unknown account `#{resource}'" unless resource.exists?
          when Repository
            RDF::CLI.abort "unknown account `#{resource.account}'" unless resource.account.exists?
            RDF::CLI.abort "unknown repository `#{resource}'" unless resource.exists?
        end
      end
      resources
    end

    def parse_repository_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          RDF::CLI.abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

    def parse_resource_specs(resource_specs)
      resources = []
      resource_specs.each do |resource_spec|
        unless resource = Resource.new(resource_spec)
          RDF::CLI.abort "invalid resource spec `#{resource_spec}'"
        end
        resources << resource
      end
      resources
    end
  end # Command
end # Datagraph