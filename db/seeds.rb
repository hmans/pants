# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  andy = FactoryGirl.create(:user, hosted: true, domain: 'andy.pants.dev', display_name: 'Andy', password: 'secret', admin: true)
  ben = FactoryGirl.create(:user, hosted: true, domain: 'ben.pants.dev', display_name: 'Ben', password: 'secret')

  FactoryGirl.create_list(:post, 40, user: andy)
  FactoryGirl.create_list(:post, 20, user: ben)

  andy.add_friend(ben)
end
