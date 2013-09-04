FactoryGirl.define do

  sequence(:email) { |n| "user_#{n}@example.com" }

  sequence(:url) { |n| "http://example.com/url_#{n}" }

  factory :category do
    sequence(:name) { |n| "Category Name #{n}" }
  end

  factory :dmca do

    title "A title"
    works { build_list(:work, 1) }

    ignore do
      role_names ['principal']
    end

    after :build do |notice, evaluator|
      evaluator.role_names.each do |role_name|
        role = notice.entity_notice_roles.build(name: role_name)
        role.entity = build(:entity)
      end
    end

    trait :with_body do
      body "A body"
    end

    trait :with_tags do
      before(:create) do |notice|
        notice.tag_list = 'a_tag, another_tag'
      end
    end

    trait :with_jurisdictions do
      before(:create) do |notice|
        notice.jurisdiction_list = 'us, ca'
      end
    end

    trait :with_categories do
      before(:create) do |notice|
        notice.categories = build_list(:category, 3)
      end
    end

    trait :with_infringing_urls do # through works
      before(:create) do |notice|
        notice.works.first.infringing_urls = build_list(:infringing_url, 3)
      end
    end

    trait :with_copyrighted_urls do # through works
      before(:create) do |notice|
        notice.works.first.copyrighted_urls = build_list(:copyrighted_url, 3)
      end
    end

    trait :with_facet_data do
      with_tags
      with_jurisdictions
      with_categories
      role_names ['sender', 'recipient']
      date_received Time.now
    end

    trait :redactable do
      body "Some [REDACTED] body"
      body_original "Some sensitive body"
      review_required true
    end

    trait :with_original do
      before(:create) do |notice|
        notice.file_uploads << build(:file_upload, kind: 'original')
      end
    end

    trait :with_document do
      before(:create) do |notice|
        notice.file_uploads << build(:file_upload, kind: 'supporting')
      end
    end

    trait :with_pdf do
      before(:create) do |notice|
        notice.file_uploads << build(
          :file_upload, kind: 'supporting', file_content_type: 'application/pdf'
        )
      end
    end

    trait :with_image do
      before(:create) do |notice|
        notice.file_uploads << build(
          :file_upload, kind: 'supporting', file_content_type: 'image/jpeg'
        )
      end
    end

    factory :trademark, class: 'Trademark'
    factory :defamation, class: 'Defamation'
    factory :court_order, class: 'CourtOrder'
    factory :law_enforcement_request, class: 'LawEnforcementRequest'
    factory :private_information, class: 'PrivateInformation'
    factory :other, class: 'Other'
  end

  factory :file_upload do
    ignore do
      content "Content"
    end

    kind 'original'

    file do
      Tempfile.open('factory_file') do |fh|
        fh.write(content)
        fh.flush

        Rack::Test::UploadedFile.new(fh.path, "text/plain")
      end
    end
  end

  factory :entity_notice_role do
    entity
    association(:notice, factory: :dmca)
    name 'principal'
  end

  factory :entity do
    sequence(:name) { |n| "Entity name #{n}" }
    kind "individual"
    address_line_1 "Address 1"
    address_line_2 "Address 2"
    city "City"
    state "State"
    zip "01222"
    country_code "US"
    phone "555-555-1212"
    email "foo@example.com"
    url "http://www.example.com"

    trait :with_children do
      after(:create) do |instance|
        create(:entity, parent: instance)
        create(:entity, parent: instance)
      end
    end
    trait :with_parent do
      before(:create) do |instance|
        instance.parent = create(:entity)
      end
    end
  end

  factory :user do
    email
    password "secretsauce"
    password_confirmation "secretsauce"

    trait :submitter do
      roles { [Role.submitter] }
    end

    trait :redactor do
      roles { [Role.redactor] }
    end

    trait :publisher do
      roles { [Role.publisher] }
    end

    trait :admin do
      roles { [Role.admin] }
    end

    trait :super_admin do
      roles { [Role.super_admin] }
    end
  end

  factory :relevant_question do
    question "What is the meaning of life?"
    answer "42"
  end

  factory :work do
    description "Something copyrighted"

    trait :with_infringing_urls do
      after(:build) do |work|
        work.infringing_urls = build_list(:infringing_url, 3)
      end
    end

    trait :with_copyrighted_urls do
      after(:build) do |work|
        work.copyrighted_urls = build_list(:copyrighted_url, 3)
      end
    end
  end

  factory :infringing_url do
    url
  end

  factory :copyrighted_url do
    url
  end

  factory :blog_entry do
    title "Blog title"
    author "John Smith"

    trait :published do
      published_at 5.days.ago
    end

    trait :with_abstract do
      abstract "Some summary of the post's content"
    end

    trait :with_content do
      content "Some *markdown* content"
    end
  end

  factory :role do
    name 'test_role'
  end

end
