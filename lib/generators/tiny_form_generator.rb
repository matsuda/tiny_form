class TinyFormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  check_class_collision :suffix => "Form"

  def create_validator_files
    template 'form.rb', File.join('app/forms', class_path, "#{file_name}_form.rb")
  end

  hook_for :test_framework, :as => :model do |test_framework|
    invoke test_framework, [class_name], :fixture => false
  end
end
