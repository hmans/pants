# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

hmans = FactoryGirl.create(:user, domain: 'pants.dev', display_name: 'Hendrik Mans', password: 'moocow')
FactoryGirl.create_list(:post, 10, user: hmans)
