# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :bigint(8)        default(0)
#  date       :date             not null
#  details    :text(65535)
#  filtered   :boolean          default(FALSE)
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

# Object that represents a generic usage statistic
class Stat < ApplicationRecord
  extend OrgDateRangeable

  belongs_to :org, optional: true

  validates :type, uniqueness: { scope: %i[date org_id filtered] }

  class << self
    def to_csv(stats, sep = ',')
      data = stats.map do |stat|
        { date: stat.date, count: stat.count }
      end
      Csvable.from_array_of_hashes(data, sep)
    end
  end

  def to_json(methods: nil)
    super(only: %i[count date], methods: methods)
  end
end
