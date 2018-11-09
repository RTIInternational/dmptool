# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  lock_version :integer          default(0)
#  text         :text
#  created_at   :datetime
#  updated_at   :datetime
#  label_id     :string
#  plan_id      :integer
#  question_id  :integer
#  user_id      :integer
#
# Indexes
#
#  index_answers_on_plan_id      (plan_id)
#  index_answers_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :answer do
    text { Faker::Lorem.paragraph }
    plan
    user
    question
  end
end
