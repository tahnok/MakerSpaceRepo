require 'faker'

FactoryBot.define do

  factory :training_session do
    level { "Beginner" }
    association :user, :admin

    trait :normal do
      association :space, :makerspace
      association :training, :test
    end

    trait :'3d_printing' do
      association :space, :makerspace
      association :training, :'3d_printing'
    end

    trait :basic_training do
      association :space, :brunsfield
      association :training, :basic_training
    end

  end

end



