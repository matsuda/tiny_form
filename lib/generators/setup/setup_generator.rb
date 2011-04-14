module TinyForm
  class SetupGenerator < ::Rails::Generators::Base
    COMMENTED_AUTOLOAD_PATH_REGEXP = /\n *#+ *config\.autoload_paths.*/
    UNCOMMENTED_AUTOLOAD_PATH_REGEXP = /\n *[^#]*config\.autoload_paths \+= %W\([^)]*/

    desc "This generator add tiny_forms' path to 'config.autoload_paths.'"
    def main
      generate_configuration
    end

    private
    def generate_configuration
      return if Rails::Application.config.autoload_paths.any?{ |load_path| load_path =~ /app\/forms$/ }
      log 'updating application.rb...'
      add_forms_path File.read(Rails.root.join('config/application.rb'))
    end

    def add_forms_path(config_contents)
      forms_path = '#{config.root}/app/forms'
      new_line = "\n    config.autoload_paths += %W(#{forms_path})"

      if config_contents =~ COMMENTED_AUTOLOAD_PATH_REGEXP
        log %q|enable config.autoload_paths and add form's path|
        insert_into_file 'config/application.rb', new_line, :after => COMMENTED_AUTOLOAD_PATH_REGEXP
      elsif config_contents =~ UNCOMMENTED_AUTOLOAD_PATH_REGEXP
        log %q|add form's path|
        gsub_file 'config/application.rb', UNCOMMENTED_AUTOLOAD_PATH_REGEXP do |match|
          match << " #{forms_path}"
        end
      end
    end
  end
end
