# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ping do
    user nil
    post nil
    source "MyString"
    target "MyString"
  end
end
