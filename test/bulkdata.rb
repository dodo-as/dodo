# -*- coding: utf-8 -*-
# Ensure we're in test mode to avoid mail timeout errors
# when creating users.
raise "Set RAILS_ENV=test before loading blueprint" unless Rails.env != 'production'

# Number of users
USER_COUNT = 10
#15000
# Number of companies
COMPANY_COUNT = 5
#10000
# Average number of products for a company
PRODUCT_COUNT = 20
# 50
# Average number of units
UNIT_COUNT = 7
# Average number of cars
CAR_COUNT = 7
# 7
# Average number of projects
PROJECT_COUNT = 7
# 7 
YEARS=(2008..2010)
# Maximum number of journals per period and company
MAX_JOURNAL_COUNT=500
# Number of journal operations per journal entry
JOURNAL_OPERATION_COUNT = 5
# Number of journal with ledger operations per journal entry
JOURNAL_LEDGER_OPERATION_COUNT = 4
# Number of employees per company
EMPLOYEE_COUNT = 5
# Number of employees per company
CUSTOMER_COUNT = 20
# Password used for _all_ users, including admins
PASSWORD= "Secret123"
# Date how many years ago from the current date
YEARS_AGO = 10
# Number of vat chunks 
VAT_CHUNKS_COUNT = 50

def print_time name, &block
  print "#{name}..."
  a = Time.now
  foo = yield block
  b = Time.now
  print " Used #{b-a} seconds.\n"
  return foo
end

# largish data set to test scaling or whatever
require 'machinist/active_record'
require 'sham'
require 'faker'

if not $BULK_APPEND
  require File.expand_path(File.dirname(__FILE__) + "/../db/seed") if Role.all.empty?
  raise "roles not seeded" if Role.all.empty?
end

suffix = Time.now.usec.to_s

Sham.login { Faker::Internet.user_name }
Sham.name(:unique => false) { Faker::Name.name }
Sham.phone(:unique => false) { Faker::PhoneNumber.phone_number }
Sham.email { Faker::Internet.email }
Sham.company_name { Faker::Company.name + suffix }
Sham.street1(:unique => false) { Faker::Address.street_name }
Sham.street2(:unique => false) { Faker::Address.secondary_address }
Sham.postal_code(:unique => false) { Faker::Address.uk_postcode }
Sham.town(:unique => false) { Faker::Address.city }
Sham.country(:unique => false) { Faker::Address.uk_country }
Sham.bs(:unique => false) { Faker::Company.bs.capitalize }
Sham.catch_phrase(:unique => false) { Faker::Company.catch_phrase.capitalize }
Sham.product_name(:unique => false) { Faker::Lorem.words(3).join(" ").capitalize }
Sham.account_name(:unique => false) { Faker::Lorem.words(3).join(" ").capitalize }
Sham.role_name(:unique => true) { Faker::Lorem.words(3).join("_").downcase }
Sham.description(:unique => false) { Faker::Company.catch_phrase }
Sham.car_name(:unique => true) {
  ["Ferrari","Mazda","Ford","Fiat","Toyota","Volvo","Saab","VW","BMW", "Nissan","Lexus","Maserati","Jaguar","Mercedes","Renault","Aston Martin","Bugatti","Alfa Romeo","Seat","Lada"].rand +
  " "+ 
  ["Prius", "Explorer", "Expander", "Canyanaro", "Punto","Sport","190","Skyline","Diabolo","M7","M5","M3","S3"].rand +
  [" S"," E"," XS"," SL"," Touring", "D", "X", ""].rand
}
Sham.web_site(:unique => false) { "www." + Faker::Internet.domain_name }
Sham.personal_number { rand(30).to_s.rjust(2, "0") + rand(12).to_s.rjust(2,"0") + rand(99).to_s.rjust(2,"0") + rand(99999).to_s.rjust(5,"0") }
Sham.bank_account { (10 + rand(89)).to_s.rjust(2, "0") + rand(99).to_s.rjust(2,"0") + rand(99).to_s.rjust(2,"0") + rand(99999).to_s.rjust(5,"0") }
Sham.date(:unique => false) {  Time.at(rand * (Time.now - YEARS_AGO.year.ago) + Time.now.years_ago(YEARS_AGO).to_f) }
Sham.date_of_birth(:unique => false) {  Time.at(rand * (Time.now - 62.year.ago) + Time.now.years_ago(62).to_f).years_ago(18) }
Sham.information(:unique => false) { Faker::Lorem.paragraph(2) }
Sham.sentence(:unique => false) { Faker::Lorem.sentence }
Sham.word(:unique => false) { Faker::Lorem.words.rand } 
Sham.number { rand(1000) }

User.blueprint do
  email { Sham.email }
  password { PASSWORD }
  password_confirmation { password }
  active {  if rand(10)>2
                true 
            else
                false
            end
  }
end

Admin.blueprint do
  email { Sham.email }
  password { PASSWORD }
  password_confirmation { password }
end

Address.blueprint do
  street1
  street2 if rand(10) > 5
  postal_code
  town
  country
end

Company.blueprint do
  name { Sham.company_name }
  organization_number { (850 + rand(100)).to_s + rand(100).to_s+ (rand(800) + 100).to_s  } 
  visiting_address { Address.make }
  billing_address { Address.make if rand(10) < 3 }
  delivery_address { Address.make if rand(10) < 3 }
  next_invoice_number { 0 }
  bill_comment_top { rand(10) < 5 }
  bill_line_comment_top { rand(10) < 5 }
  show_turnover { rand(10) < 5 }
  telephone_number { Sham.phone }
  fax { Sham.phone if rand(10) < 7 }
  mobile_number { Sham.phone }
  email { Sham.email }
  web_site { Sham.web_site }
  bank_account { Sham.bank_account }
  interest_rate { rand * 20 }
  late_fee { rand * 150 }
  share_value { rand * 1000}
  share_count { 1000+ rand(500)}
  incorporation_date { Sham.date }
  # result_account_balance_id
  # result_account_result_id
  information { Sham.information }
  payment_terms { Sham.sentence }
  deliver_terms { Sham.sentence }
  sector { Sham.word }
end

Unit.blueprint do
  name { Sham.company_name + " (unit)" }
  address { Address.make }
  comments { Sham.information }
  from  { Sham.date }
  to { from.months_since(1 + rand(35)) }
end

Car.blueprint do
  name { Sham.car_name}
  comments { Sham.information }
  company_id { Company.all.rand.id }
  from  { Sham.date }
  to { from.months_since(1 + rand(35)) }
end

Project.blueprint do
  name { Sham.bs + " (project)" }
  address { Address.make }
  comments { Sham.catch_phrase }
  company_id { Company.all.rand.id }
  from  { Sham.date }
  to { from.months_since(1 + rand(35)) }
end

Product.blueprint do
  price { BigDecimal.new( sprintf("%.2f", 10000 * rand) ) }
  name { Sham.product_name }
end

Account.blueprint do
  name { Sham.account_name }
  dodo_name { name }
  number { rand(10000) }
  debit_text { "debit" }
  credit_text { "credit" }
  comments { (rand(10) > 6) ? Sham.bs : "" }
  has_ledger { false }
end

Period.blueprint do
  status { Period::STATUSE_NAMES["Open"] }
end

Journal.blueprint do
end

JournalOperation.blueprint do
end

Role.blueprint do
  name { Sham.role_name }
end

PaycheckLineTemplate.blueprint do
  line_type { PaycheckLineTemplate::TYPES.keys.rand }
  description { Sham.product_name }
  salary_code { "#{rand(1000)}-#{'abc'.chars.to_a.rand}" }
  count { rand(200) }
  rate { rand(1200) }
  amount { rand(5000) }
  payroll_tax { rand(10) > 3 }
  vacation_basis { rand(10) > 3 }
end

Ledger.blueprint do
  name {Sham.name}
  address { Address.make }
  telephone_number {Sham.phone}  
  mobile_number {Sham.phone}  
  email {Sham.email}  
  comment {"Bulk insertion script"}
  placement_top {false}
  debit_text {"debit"}
  credit_text {"credit"}
end

VatChunk.blueprint do
   number { Sham.number }
   start_date { Sham.date }
   stop_date { start_date.months_since( 3 + rand(21)) }
   company { Company.all.rand }
   account { company.accounts.rand }
end

bob = nil
admin = nil
companies = []
users = nil
roles=nil




# **********  Now create some data ***************

ActiveRecord::Base.transaction do

  if not $BULK_APPEND
  
    print_time "Creating users" do
      
      USER_COUNT.times {|i| user = User.make }
      
      bob = User.make(:email => "bob@bobsdomain.com")
      
      admin = Admin.make(:email => "admin@adminsdomain.com")
    end 
  else
    bob = User.where(:email => "bob@bobsdomain.com").first
    admin = User.where(:email => "admin@adminsdomain.com").first
  end    

  print_time "Creating companies" do
    COMPANY_COUNT.times {|i| companies << Company.make }
  end

  users = User.all
  roles = Role.all
  puts "Users: ", users
  print_time "Attaching users to companies" do
    # attach users to companies
    (COMPANY_COUNT * 5).times do
      c = companies.rand
      u = users.rand
      r = roles.rand
      c.assignments.create(:user => u, :role => r)
    end
    
    # make sure bob is assigned to a few companies
    companies.shuffle[0..[COMPANY_COUNT, 5].min].each do |c|
      c.assignments.create(:user => bob, :role => Role.find_by_name("accountant"))
    end
  end
  
  print_time "Creating journal types" do
    jt =[
         ["K", "Kassa"], ["B", "Bank"],
         ["U", "Kjøp"], ["L", "Lønn"],
         ["S", "Salg"], ["A", "Auto"], 
         ["O", "Ukeomsetning"]
        ]
    jt.each {
      |val|

      jt = JournalType.new
      jt.abbreviation = val[0]
      jt.name = val[1]

      jt.save
    }
  end

  print_time "Creating units" do
    # create a bunch of units/projects and attach them to companies
    (companies.size * UNIT_COUNT).times do
      Unit.make(:company => companies.rand)
    end
  end
  print_time "Creating projects" do
    (companies.size * PROJECT_COUNT).times do
      Project.make(:company => companies.rand)
    end
  end

  print_time "Creating cars" do
    (companies.size * CAR_COUNT).times do
      Car.make(:company => companies.rand)
    end
  end

  print_time "Creating company accounts" do
    # create some accounts
    companies.each do |c|
      print '.'
      # Vat accounts from empatix @ lodo.no
      
      # **** Outgoing vat; sales ***
      a2700 = Account.make(:company => c, :name => "Utg mva kode 10", :number => 2700)
      va2700 = VatAccount.create!(:company => c, :overridable => true, :target_account => a2700)
      VatAccountPeriod.create!(:vat_account => va2700, :percentage => 0, :valid_from => "1990-01-01")
      
      
      a2701 = Account.make(:company => c, :name => "Utg mva kode 11", :number => 2701)
      va2701 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2701)
      VatAccountPeriod.create!(:vat_account => va2701, :percentage => 24, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2701, :percentage => 25, :valid_from => "2005-01-01")
      
      
      a2702 = Account.make(:company => c, :name => "Utg mva kode 12", :number => 2702)
      va2702 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2702)
      VatAccountPeriod.create!(:vat_account => va2702, :percentage => 12, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2702, :percentage => 11, :valid_from => "2005-01-01")
      VatAccountPeriod.create!(:vat_account => va2702, :percentage => 13, :valid_from => "2006-01-01")
      VatAccountPeriod.create!(:vat_account => va2702, :percentage => 14, :valid_from => "2007-01-01")
      
      
      a2703 = Account.make(:company => c, :name => "Utg mva kode 13", :number => 2703)
      va2703 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2703)
      VatAccountPeriod.create!(:vat_account => va2703, :percentage => 6, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2703, :percentage => 7, :valid_from => "2005-01-01")
      VatAccountPeriod.create!(:vat_account => va2703, :percentage => 8, :valid_from => "2006-01-01")
      
      # *** Incoming vat; expenses ***
      a2710 = Account.make(:company => c, :name => "Ing mva kode 40", :number => 2710)
      va2710 = VatAccount.create!(:company => c, :overridable => true, :target_account => a2710)
      VatAccountPeriod.create!(:vat_account => va2710, :percentage => 0, :valid_from => "1990-01-01")
      
      
      a2711 = Account.make(:company => c, :name => "Ing mva kode 41", :number => 2711)
      va2711 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2711)
      VatAccountPeriod.create!(:vat_account => va2711, :percentage => 24, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2711, :percentage => 25, :valid_from => "2005-01-01")
      
      
      a2712 = Account.make(:company => c, :name => "Ing mva kode 42", :number => 2712)
      va2712 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2712)
      VatAccountPeriod.create!(:vat_account => va2712, :percentage => 12, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2712, :percentage => 11, :valid_from => "2005-01-01")
      VatAccountPeriod.create!(:vat_account => va2712, :percentage => 13, :valid_from => "2006-01-01")
      VatAccountPeriod.create!(:vat_account => va2712, :percentage => 14, :valid_from => "2007-01-01")
      
      
      a2713 = Account.make(:company => c, :name => "Ing mva kode 43", :number => 2713)
      va2713 = VatAccount.create!(:company => c, :overridable => false, :target_account => a2713)
      VatAccountPeriod.create!(:vat_account => va2713, :percentage => 6, :valid_from => "1990-01-01")
      VatAccountPeriod.create!(:vat_account => va2713, :percentage => 7, :valid_from => "2005-01-01")
      VatAccountPeriod.create!(:vat_account => va2713, :percentage => 8, :valid_from => "2006-01-01")
      
      
      # Other accounts
      Account.make(:company => c, :name => "Sales", :number => 3000, :vat_account => va2701)
      Account.make(:company => c, :name => "Cash", :number => 1900)
      Account.make(:company => c, :name => "Bank", :number => 1920)
      Account.make(:company => c, :name => "Materials", :number => 4000, :vat_account => va2711)
      Account.make(:company => c, :name => "Salaries", :number => 5000)
      Account.make(:company => c, :name => "Arbeidsgiveravgift", :number => 5400)
      Account.make(:company => c, :name => "NAV-refusjon, sykepenger", :number => 5800)
      Account.make(:company => c, :name => "Office supplies", :number => 6800, :vat_account => va2711)
      Account.make(:company => c, :name => "Phone expenses", :number => 6900, :vat_account => va2711)
      
      Account.make(:company => c, :name => "Accounts payable", :number => 2400, :has_ledger => true)
      
      Account.make(:company => c, :name => "Employees", :number => 2930, :has_ledger => true)

      Account.make(:company => c, :name => "Customer bills", :number => 1500, :has_ledger => true)
      
      # create some random filler accounts
      (rand(200) + 40).times do
        begin
          Account.make(:company => c)
        rescue
        end
      end
    end
  end

  companies = Company.all
  print_time "Creating employees" do
    companies.each do |c|
      (1..13).each do |m|
        PaycheckPeriod.new( { :company_id => c.id,
                              :start_month => m,
                              :start_day => 1,
                              :stop_month => m,
                              :stop_day => 31,
                              # Make december plus one wrap around to january
                              :pay_month => (m-1)%12+1, 
                              :pay_day => 10 }).save!
      end
      print '.'
      emp_account = Account.where(:company_id => c.id, :number => 2930).first

      emp_pay_temp = []
      (0..5).each do |i| 
        emp_pay_temp << PaycheckLineTemplate.make(:company => c, :employee => nil, :account => c.accounts.rand)
      end

      EMPLOYEE_COUNT.times do |i| 
        emp = Ledger.make( :account_id => emp_account.id, :number => i+1, :account_type_id => 0, :credit_days => rand(30),
                            :procenttrekk => rand(45), :date_of_birth => Sham.date_of_birth,
                            :id_number => Sham.personal_number , :foreign_bank_number => Sham.bank_account)
        
        emp_pay_temp.each do |t| 
          PaycheckLineTemplate.make(
                                    :company => c, 
                                    :employee => emp, 
                                    :account => t.account, 
                                    :line_type => t.line_type,
                                    :description => t.description,
                                    :salary_code => t.salary_code,
                                    :count => t.count,
                                    :rate => t.rate,
                                    :amount => t.amount,
                                    :payroll_tax => t.payroll_tax,
                                    :vacation_basis => t.vacation_basis
                                    )
        end
      end       
    end
  end





  companies = Company.all
  print_time "Creating customer information" do
    companies.each do |c|
      cust_account = Account.where(:company_id => c.id, :number => 1500).first
      CUSTOMER_COUNT.times do |i| 
        c = Ledger.make( :account_id => cust_account.id, :number => i+1, :account_type_id => 0, :credit_days => rand(30),
                            :procenttrekk => rand(45), :date_of_birth => Sham.date_of_birth,
                            :id_number => Sham.personal_number , :foreign_bank_number => Sham.bank_account)
      end       
    end
  end




  companies = Company.all
  print_time "Creating supplier information" do
    companies.each do |c|
      cust_account = Account.where(:company_id => c.id, :number => 2400).first
      CUSTOMER_COUNT.times do |i|
        c = Ledger.make( :account_id => cust_account.id, :number => i+1, :account_type_id => 0, :credit_days => rand(30),
                            :procenttrekk => rand(45), :date_of_birth => Sham.date_of_birth,
                            :id_number => Sham.personal_number , :foreign_bank_number => Sham.bank_account)
      end
    end
  end





  print_time "Creating products" do
    (companies.size * PRODUCT_COUNT).times do |i|
      Product.make(:account => companies.rand.accounts.rand)
    end
  end
  
  # create random journal entries for the given period
  def create_journal_entries(company, period)
    #    puts "creating journal entries for #{company.name}, period: #{period.year}-#{period.nr}"
    # create journal entries
    date = Date.civil(period.year, period.nr, 1)
    sql = "insert into journals (company_id, period_id, journal_date) select #{company.id}, #{period.id}, ('#{date}'::date + interval '28 days' * random())::date from generate_series (1, #{rand(MAX_JOURNAL_COUNT)})"
    ActiveRecord::Base.connection.execute sql
    
  end
  
  def create_journal_operations(company)
    # create 4 journal_operations for every empty journal entry
    #    sql = "insert into journal_operations (journal_id, account_id, amount) select id as journal_id, #{sample_array_sql(company.accounts)}, (random() * 200 - 100)::numeric(16,2) as amount from (select j.id from journals j where j.company_id = #{company.id} and not exists (select 1 from journal_operations jo where jo.journal_id = j.id)) as aa, (select 1 from generate_series(1, (1 + random() * 5)::integer)) as bb"
    sql = "
insert into journal_operations 
(journal_id, account_id, amount, company_id) 
select 
    id as journal_id, 
    0 as account_id,
    (random() * 200 - 100)::numeric(16,2) as amount,
    #{company.id}
    from (
        select j.id from journals j 
        where j.company_id = #{company.id} 
            and not exists (
                select 1 from journal_operations jo 
                where jo.journal_id = j.id)) as aa, (
    select 1 
    from generate_series(1, #{JOURNAL_OPERATION_COUNT-1})) as bb"
    ActiveRecord::Base.connection.execute sql

    sql2 = "
update journal_operations j 
set account_id =(select id from accounts where company_id=#{company.id} and accounts.id != j.id order by random() limit 1)
where company_id = #{company.id};
"      
    ActiveRecord::Base.connection.execute sql2





  end


  def create_journal_ledger_operations(company)
    sql = "
update journal_operations jo
    set 
        ledger_id = (select id from ledgers where account_id = jo.account_id order by random() limit 1), 
        amount = case when random()>0.5 then 1000 else -1000 end
    where account_id in (select id from accounts where has_ledger = true) and company_id = #{company.id}

"
    ActiveRecord::Base.connection.execute sql

    sql2 = "
update journals j
set 
    kid = id % 20
where id in (select journal_id from journal_operations where ledger_id is not null and company_id = #{company.id})
   and company_id = #{company.id}
   and (id % 3) = 0 
"
    ActiveRecord::Base.connection.execute sql2

    sql3 = "
update journals j
set 
    bill_number = id % 20
where id in (select journal_id from journal_operations where ledger_id is not null and company_id = #{company.id})
   and company_id = #{company.id}
   and (id % 3) = 1 
"
    ActiveRecord::Base.connection.execute sql3

  end
  
  def close_journal_operations(company)
    # find and close open journal entries
    sql = "
insert into journal_operations 
(journal_id, account_id, amount, company_id) 
select 
    journal_id, 
    (select id from accounts where company_id=#{company.id} and has_ledger=false order by random() limit 1) as account_id,
    -amount,
    #{company.id}
    from (
        select journal_id, sum(amount) as amount 
        from journals j 
        inner join journal_operations jo 
            on (j.id = jo.journal_id) 
        where j.company_id = #{company.id} group by journal_id having sum(amount) <> 0) as qq"
    ActiveRecord::Base.connection.execute sql
  end





  def create_period(company, year, nr)
    p = Period.make(:company => company, :year => year, :nr => nr)
    create_journal_entries(company, p)
    # TODO: close period as appropriate
    #puts "p.journal count: #{p.journals.count} -- operations: #{p.journal_operations.count}"
  end

end

# create periods and fill these with tx data
companies.each_with_index do |c,idx|
  if idx%40 == 0
    print_time "Vacuuming the house" do
      ActiveRecord::Base.connection.execute "vacuum analyze"    
    end
  end
  print_time "Creating periods, journals and journal operations for company #{idx+1} of #{COMPANY_COUNT}" do
    ActiveRecord::Base.transaction do
      YEARS.each do |year|
        (1..12).each do |month|
          create_period(c, year, month)
        end
      end
      create_journal_operations(c)
      create_journal_ledger_operations(c)
      close_journal_operations(c)
    end
  end # ActiveRecord::Base.transaction do
end

print_time "Creating paychecks" do
  companies.each do |c|
    emp_account = Account.where(:company_id => c.id, :number => 2930).first

    c.employees.each do |emp|
      sql = "
insert into paychecks
(period_id, employee_id, created_at, updated_at, paycheck_period_id)
select p.id, #{emp.id}, now(), now(), pp.id 
from periods p 
join paycheck_periods pp
on p.company_id = pp.company_id and p.nr = pp.start_month
where p.company_id = #{c.id};
"
      ActiveRecord::Base.connection.execute sql
      
      sql = "
insert into paycheck_lines
(line_type, description, paycheck_id, account_id, count, rate, amount, payroll_tax, vacation_basis, salary_code, created_at, updated_at, paycheck_line_template_id)
select plt.line_type, plt.description, p.id, plt.account_id, plt.count, plt.rate, plt.amount, plt.payroll_tax, plt.vacation_basis, plt.salary_code, now(), now(), plt.id
from paychecks p, paycheck_line_templates plt
where p.employee_id = #{emp.id}
    and plt.employee_id = #{emp.id}
"
      ActiveRecord::Base.connection.execute sql
      
    end       
  end
end

print_time "Setting companies for users" do
    User.all.each do |u|
        u.current_company = u.companies.first if u.companies.count > 0
        u.save
    end
end

print_time "Creating vat chunks" do
    VAT_CHUNKS_COUNT.times do 
        VatChunk.make
    end
end

# Check if user bob@bobsdomain.com is active
# and if not make him active
# Also this should be 
bob = User.where(:email => "bob@bobsdomain.com").first
if !bob.active
    bob.active = true
    bob.save
end
