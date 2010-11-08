module UserStamp
  def self.append_features(base)
    base.before_create do |model|
#      model.created_by ||= User.backend_user.id if 
      model.created_by == current_user.id if
      model.respond_to?(:created_by)
    end
    base.before_save do |model|
#      model.updated_by =  User.backend_user.id if 
      model.updated_by == current_user.id if
      model.respond_to?(:updated_by)
    end
  end

end
