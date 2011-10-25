class LedgerValidator < ActiveModel::Validator  
  def validate(record)  
     @country = record.address.country
    if record.id_number.blank?
        record.errors.add "Personal number", "can't be blank"
     else
         if @country == 'Norge'
            if record.id_number.length != 11
                record.errors.add "Personal number", ' for Norway must be 11 digits long'
            end
            if record.date_of_birth.blank? and record.id_number.length == 11
                @per_number = record.id_number
                @b = '19' + @per_number[4..5] + '-' + @per_number[2..3] + '-' + @per_number[0..1]
                record.date_of_birth = @b
            else
                record.errors.add :date_of_birth, "is mandatory"
            end
        else @country == 'Sweden'
            if record.id_number.length != 10
                record.errors.add "Personal number", ' for Sweden must be 10 digits long'
            end        
        end
    end
    if record.ledger_bank_number.blank? and record.foreign_bank_number.blank?
        record.errors.add "Bank number.", "You must enter one bank account number"
    elsif (!record.ledger_bank_number.blank? and !record.foreign_bank_number.blank?)
        puts "AAaaaaAAaaAAAaaAAAaaAAaaAAAaaAAAaa", (!record.ledger_bank_number.blank? and !record.foreign_bank_number.blank?), "MMMMMMMMMMMMmmmmmmMMmmmMmmmmmmMMmmmMMmmmmmmmmm"
        
        
        record.errors.add "Bank number:", "You must enter only one bank account number"
    end
     
  end  
end  
