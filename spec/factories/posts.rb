# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    body { Faker::Lorem.paragraphs.join("\n\n") }
    created_at { rand(300).hours.ago }
  end
end
