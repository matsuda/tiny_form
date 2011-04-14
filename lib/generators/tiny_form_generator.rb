class TinyFormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  check_class_collision :suffix => "Form"

  desc "This generator generate a skeleton file for custom to app/forms directory."
  def create_validator_files
    template 'form.rb', File.join('app/forms', class_path, "#{file_name}_form.rb")
  end
end
