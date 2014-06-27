# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  arnold = FactoryGirl.create(:user, hosted: true, domain: 'arnold.pants.dev', display_name: 'Arnold', password: 'secret')
  ben = FactoryGirl.create(:user, hosted: true, domain: 'ben.pants.dev', display_name: 'Ben', password: 'secret')

  FactoryGirl.create_list(:post, 10, user: arnold)
  FactoryGirl.create_list(:post, 10, user: ben)
end
