class AdminLog < ActiveRecord::Base
  belongs_to :admin

  validates :table_name, :old_value, :new_value, :admin_id, :presence=> true

  # This static method returns a function suitable fo use as an around_filter
  # which will log actions.
  # 'field' is the name of a property whose value should be logged on change.
  def self.log field
    return Proc.new {|controller, action|
      
      user = controller.me
      obj = controller.send(field)

      before = "null"
      after = "null"
      if obj && obj.id != nil
        before = Log.my_json(obj)
      end

      action.call
      
      if !obj
        obj = controller.send(field)
      end

      if obj
        after = Log.my_json(obj)
      end

      table = obj.class.name
      
      if before != after
        l = AdminLog.new({:admin => user, :old_value => before, :new_value => after, :table_name => table})
        l.save
        puts l.errors
      end
    }
  end

  # Return a list of hashes. every hash has three items, :field, which is a field name,
  # :before, which is the old value, and :after is the new value. This list includes only
  # the changed fields.
  def changes
    return Log.diff self.old_value, self.new_value
  end

  # Return a list of hashes. every hash has three items, :field, which is a field name,
  # :before, which is the old value, and :after is the new value
  def data 
    before = Log.handle_json self.old_value
    after = Log.handle_json self.new_value
    fields = before.keys | after.keys
    return fields.map {|key| { :field => key, :before => before[key], :after => after[key] } }
  end


end
