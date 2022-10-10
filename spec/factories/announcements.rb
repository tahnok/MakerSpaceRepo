FactoryBot.define do
  factory :announcement do
    association :user, :admin
    description { Faker::Lorem.paragraph }
    active { true }

    trait "volunteer" do
      public_goal { "volunteer" }
    end

    trait "regular_user" do
      public_goal { "regular_user" }
    end

    trait "staff" do
      public_goal { "staff" }
    end

    trait "admin" do
      public_goal { "admin" }
    end

    trait "all" do
      public_goal { "all" }
    end

    trait "all_visitors" do
      public_goal { "all_visitors" }
    end
  end
end
