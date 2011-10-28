class DateValidator < ActiveModel::Validator
  def validate(record)
    from = record.from
    to = record.to

    if !from.blank? and !to.blank? and from > to
      record.errors.add :to, 'can not be less than From'
    end
  end
end
