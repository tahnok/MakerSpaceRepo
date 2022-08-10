FactoryBot.define do
  factory :exam do
    association :user, :regular_user
    association :training_session
    category { "Basic Training" }
    status { Exam::STATUS[:not_started] }
    expired_at { DateTime.tomorrow.end_of_day }

    factory :exam_with_exam_questions do
      transient { exam_questions_count { 4 } }
      after(:create) do |exam, evaluator|
        create_list(
          :exam_question,
          evaluator.exam_questions_count,
          :with_question_and_answers,
          exam: exam
        )
      end
    end

    factory :exam_with_exam_questions_and_exam_responses do
      transient { exam_questions_count { 6 } }
      after(:create) do |exam, evaluator|
        create_list(
          :exam_question_with_exam_response,
          evaluator.exam_questions_count,
          exam: exam
        )
      end
    end

    factory :exam_with_exam_questions_and_exam_responses_wrong do
      transient { exam_questions_count { 6 } }
      after(:create) do |exam, evaluator|
        create_list(
          :exam_question_with_exam_response_wrong,
          evaluator.exam_questions_count,
          exam: exam
        )
      end
    end
  end
end
