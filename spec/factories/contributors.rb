# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  name       :string(255)
#  phone      :string(255)
#  roles      :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  org_id     :integer
#  plan_id    :integer          not null
#
# Indexes
#
#  index_contributors_on_email    (email)
#  index_contributors_on_org_id   (org_id)
#  index_contributors_on_plan_id  (plan_id)
#  index_contributors_on_roles    (roles)
#

FactoryBot.define do
  factory :contributor do
    org
    name { Faker::Movies::StarWars.unique.character }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number_with_country_code }

    transient do
      roles_count { 1 }
    end

    before(:create) do |contributor, evaluator|
      (0..evaluator.roles_count - 1).each do |idx|
        contributor.send(:"#{contributor.all_roles[idx]}=", true)
      end
    end
  end
end
