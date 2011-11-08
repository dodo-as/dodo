# -*- coding: utf-8 -*-
class Log < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  
  validates :table_name, :old_value, :new_value, :user_id, :company_id, :presence=> true

  # Convert the specified model isntance to JSON. If the object has a log_include property,
  # include the foreign keys returned by that property
  def self.my_json obj
    inc = obj.log_include if obj.respond_to?(:log_include) else []
    return obj.to_json :include => inc
  end

  # This static method returns a function suitable fo use as an around_filter
  # which will log actions.
  # 'field' is the name of a property whose value should be logged on change.
  def self.log field
    return Proc.new {|controller, action|
      
      user = controller.me
      company = user.current_company
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

  # Return a list of hashes. every hash has three items, :field, which is a field name,
  # :before, which is the old value, and :after is the new value. This list includes only
  # the changed fields.
  def changes
    return Log.diff self.old_value, self.new_value
  end

  # Parse a JSON string and flatten dicts and lists into a single hash
  def self.handle_json text

    def self.my_flatten_internal source, destination, prefix
      source.each { |key, value|
        if key != "updated_at"
          if value.class == Hash
            my_flatten_internal value, destination, prefix + key + " "
          else 
            if value.class == Array
              valhash = Hash[value.map {|it| ["element" + it["id"].to_s, it] }]
              my_flatten_internal valhash, destination, prefix + key + " "
            else
              destination[prefix+key] = value
            end
          end
        end
      }
      return destination
    end
    
    def self.my_flatten source
      return my_flatten_internal source, {}, ""
    end

    data = ActiveSupport::JSON.decode text
    if data
      return my_flatten data.values.first
    end
    return {}
  end

  # Helper method for the changes method. 
  # Refactored out of changes so that it can be used by AdminLog.changes as well.
  def self.diff old_value, new_value
    
    before = Log.handle_json old_value
    after = Log.handle_json new_value
    
    def self.my_filter k1, k2
      if !k1 && !k2
        return false
      end

      return k1 != k2
    end

    fields = before.keys | after.keys
    fields = fields.select {|key| my_filter(before[key], after[key])}
    return fields.map {|key| { :field => key, :before => before[key], :after => after[key] } }
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
