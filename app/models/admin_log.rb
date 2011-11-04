class AdminLog < ActiveRecord::Base
  belongs_to :admin

  validates :table_name, :old_value, :new_value, :admin_id, :presence=> true

  def self.log field
    return Proc.new {|controller, action|

      
      user = controller.me

      if !user
        puts "UNKNOWN ADMIN USER! HALP!!!!!!"
        crash
      end

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

      puts "TRALALALALALA", user, before, after
      
      if before != after
        puts "WEEE SAVELISAVE SAVE SAVE SAVE"
        l = AdminLog.new({:admin => user, :old_value => before, :new_value => after, :table_name => table})
        l.save
        puts l.errors
      end
    }
  end

  def changes
    return Log.diff self.old_value, self.new_value
  end

end
