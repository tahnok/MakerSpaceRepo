include ActionDispatch::TestProcess

FactoryBot.define do
  factory :repository do
    title { Faker::Lorem.unique.word }
    description { Faker::Lorem.paragraph }
    share_type { "public" }
    user_username { "Bob" }
    youtube_link { "" }

    trait :private do
      password do
        "$2a$12$fJ1zqqOdQVXHt6GZVFWyQu2o4ZUU3KxzLkl1JJSDT0KbhfnoGUvg2"
      end # Password : abc
      share_type { "private" }
    end

    trait :with_repo_files do
      after(:create) do |repo|
        RepoFile.create(
          repository_id: repo.id,
          file:
            Rack::Test::UploadedFile.new(
              Rails.root.join("spec/support/assets", "RepoFile1.pdf"),
              "application/pdf"
            )
        )
        Photo.create(
          repository_id: repo.id,
          image:
            Rack::Test::UploadedFile.new(
              Rails.root.join("spec/support/assets", "avatar.png"),
              "image/png"
            )
        )
      end
    end

    trait :create_equipement_and_categories do
      after(:create) do |repo|
        Category.create(name: "Laser", repository_id: repo.id)
        Category.create(name: "3D printing", repository_id: repo.id)
        Equipment.create(name: "Laser Cutter", repository_id: repo.id)
        Equipment.create(name: "3D Printer", repository_id: repo.id)
      end
    end

    trait :with_equipement_and_categories do
      categories { ["Laser", "3D Printing"] }
      equipments { ["Laser Cutter", "3D Printer"] }
    end

    trait :broken_link do
      youtube_link { "https://google.ca" }
    end

    trait :broken do
      title { "$$$" }
    end

    trait :working_link do
      youtube_link { "https://www.youtube.com/watch?v=AbcdeFGHIJLK" }
    end

    factory :repository_with_users do
      transient { users_count { 5 } }

      after(:create) do |user, evaluator|
        create_list(:repository, evaluator.user_count, users: [user])
      end
    end
  end
end
