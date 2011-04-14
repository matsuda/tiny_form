class <%= class_name %>Form < TinyForm::Base
  # 
  # Define accessor for form attributes.
  # To use date, datetime class type, use a type option.
  # You can currently use :date, :datetime, :time as a type option.
  # 
  # define_attribute  :name, :email
  # define_attribute  :from_updated_at, :to_updated_at, :type => :datetime
  # 
  # def scope_search
  #   scope = scoped
  #   scope = scope.where(:name => self.name) if self.name.present?
  #   scope = scope.where(:email => self.email) if self.email.present?
  #   if self.from_updated_at.present? && self.to_updated_at.present?
  #     scope = scope.where(:updated_at => self.from_updated_at..self.to_updated_at)
  #   end
  #   scope
  # end
end
