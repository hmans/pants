# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :timeline_entry do
    user nil
    post nil
    created_at "2014-06-27 19:48:42"
  end
end
