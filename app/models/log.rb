# -*- coding: utf-8 -*-
class Log < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  
  validates :table_name, :old_value, :new_value, :user_id, :company_id, :presence=> true

  def self.my_json obj
    inc = obj.log_include if obj.respond_to?(:log_include) else []
    return obj.to_json :include => inc
  end
  
  def self.log field
    return Proc.new {|controller, action|
      
      user = controller.me
      company = user.current_company
#      puts "AFSDDDDDDD", controller, field
      obj = controller.send(field)

      before = "null"
      after = "null"
      if obj && obj.id != nil

        before = Log.my_json(obj)
      end
      #controller, field
      action.call
      
      if !obj
        obj = controller.send(field)
      end

      if obj
        after = Log.my_json(obj)
      end

      table = obj.class.name
      
      if before != after
        Log.new({:company => company, :user => user, :old_value => before, :new_value => after, :table_name => table}).save
      end
    }
  end

  def changes

    def my_flatten_internal source, destination, prefix
      source.each { |key, value|
        if key != "updated_at"
          if value.class == Hash
            my_flatten_internal value, destination, prefix + key + " "
          else
            destination[prefix+key] = value
          end
        end
      }
      return destination
    end

    def my_flatten source
      return my_flatten_internal source, {}, ""
    end

    before = ActiveSupport::JSON.decode(self.old_value)
    after = ActiveSupport::JSON.decode(self.new_value)

    if before
        before = my_flatten before.values.first
    else
      before = {}
    end
    
    if after
        after = my_flatten after.values.first
    else
      after = {}
    end
    
    def my_filter k1, k2
      if !k1 && !k2
        return false
      end

      return k1 != k2
    end

    fields = before.keys | after.keys
    fields = fields.select {|key| my_filter(before[key], after[key])}
    return fields.map {|key| { :field => key, :before => before[key], :after => after[key] } }
  end
  
end
