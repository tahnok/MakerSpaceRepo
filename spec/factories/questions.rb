FactoryBot.define do
  factory :question do
    association :user, :admin
    description { Faker::Lorem.paragraph }

    trait :with_image do
      images { [FilesTestHelper.png] }
    end

    trait :with_invalid_image do
      images { [FilesTestHelper.stl] }
    end

    factory :question_with_training do
      transient { training_count { 1 } }
      after(:create) do |question, evaluator|
        create_list(:training, evaluator.training_count, question: question)
      end
    end

    factory :question_with_answers do
      transient { answer_count { 5 } }
      after(:create) do |question, evaluator|
        create_list(:answer, evaluator.answer_count, question: question)
      end
    end
  end
end
