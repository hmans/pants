# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    domain       { Faker::Internet.domain_name }
    display_name { Faker::Name.name }
    password     { SecureRandom.hex }
    hosted true
  end
end
