module Terraforming
  module Resource
    class GithubRepository
      def self.tf(client = nil)
        new(client).tf
      end

      def self.tfstate(client = nil)
        new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client)
      end

      def tfstate
        resources = repositories.inject({}) do |result, repository|
          attributes = {
            'id' => repository['id'].to_s,
            'name' => repository['name'],
            'type' => repository['type']
          }

          result["github_repository.#{resource_name_of(repository)}"] = {
            'type' => 'datadog_repository',
            'primary' => {
              'id' => repository['id'].to_s,
              'attributes' => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      # TODO(dtan4): Use terraform's utility method
      def apply_template(client)
        ERB.new(File.open(template_path).read, nil, '-').result(binding)
      end

      def format_number(number)
        number.to_i == number ? number.to_i : number
      end

      def generate_tfstate(resources)
        JSON.pretty_generate(
          'version' => 1,
          'serial' => 1,
          'modules' => [
            {
              'path' => [
                'root'
              ],
              'outputs' => {},
              'resources' => resources
            }
          ]
        )
      end

      def longest_key_length_of(hash)
        return 0 if hash.empty?

        hash.keys.sort_by(&:length).reverse[0].length
      end

      def repositories
        @client.get_all_repositories[1]
      end

      def resource_name_of(repository)
        repository['name'].gsub(/[^a-zA-Z0-9 ]/, '').tr(' ', '-')
      end

      def template_path
        File.join(
          File.expand_path(File.join(File.dirname(__FILE__), "..")), 'template', 'tf', 'github_repository.erb')
      end
    end
  end
end
