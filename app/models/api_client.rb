# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_applications
#
#  id              :integer          not null, primary key
#  callback_method :integer          default(0)
#  callback_uri    :string(255)
#  confidential    :boolean          default(TRUE)
#  contact_email   :string(255)
#  contact_name    :string(255)
#  description     :string(255)
#  homepage        :string(255)
#  last_access     :datetime
#  logo_name       :string(255)
#  logo_uid        :string(255)
#  name            :string(255)      not null
#  redirect_uri    :text(65535)
#  scopes          :string(255)      default(""), not null
#  secret          :string(255)      default(""), not null
#  trusted         :boolean          default(FALSE), not null
#  uid             :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint(8)
#
# Indexes
#
#  index_oauth_applications_on_name     (name)
#  index_oauth_applications_on_uid      (uid) UNIQUE
#  index_oauth_applications_on_user_id  (user_id)
#

# Object that represents an external system
class ApiClient < ApplicationRecord
  self.table_name = 'oauth_applications'

  include Subscribable
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include ::Doorkeeper::Models::Scopes

  extend Dragonfly::Model::Validations
  extend UniqueRandom

  enum callback_methods: { put: 0, post: 1, patch: 2 }

  LOGO_FORMATS = %w[jpeg png gif jpg bmp svg].freeze

  dragonfly_accessor :logo

  # Access Tokens are created when an ApiClient authenticates themselves and is then used instead
  # of credentials when calling the API.
  has_many :access_tokens, class_name: '::Doorkeeper::AccessToken',
                           foreign_key: :application_id,
                           dependent: :delete_all

  belongs_to :user, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { case_sensitive: false,
                                 message: UNIQUENESS_MESSAGE }

  validates :contact_email, presence: { message: PRESENCE_MESSAGE },
                            email: { allow_nil: false }

  validates_property :format, of: :logo, in: LOGO_FORMATS,
                              message: format(_('must be one of the following formats: %{formats}'),
                                              formats: LOGO_FORMATS.join(', '))

  validates_size_of :logo,
                    maximum: 500.kilobytes,
                    message: _("can't be larger than 500KB")

  # =============
  # = Callbacks =
  # =============

  before_validation :ensure_scopes

  # =================
  # = Compatibility =
  # =================

  # These aliases provide backward compatibility for API V1
  alias_attribute :client_id, :uid
  alias_attribute :client_secret, :secret

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # Ensure the name is always saved as lowercase
  # TODO: do we want to add this as a validation as well?
  def name=(value)
    super(value&.downcase)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Override the to_s method to keep the id and secret hidden
  def to_s
    name
  end

  # Returns the scopes defined in the Doorkeeper config
  def available_scopes
    (default_scopes << Doorkeeper.config.optional_scopes.to_a).flatten.uniq
  end

  # Shortcut to fetch all of the plans the client subscribes to
  def plans
    subscriptions.map(&:plan)
  end

  # Returns the default scopes as defined in the Doorkeeper config
  def default_scopes
    Doorkeeper.config.default_scopes.to_a
  end

  # Shortcut helper for backward compatibility since the ApiClient is now associated with User
  # instead of Org
  def owner
    User.find_by(id: user_id)
  end

  # Shortcut helper for backward compatibility since the ApiClient is now associated with User
  # instead of Org
  def org
    user_id.present? ? User.includes(:org).find_by(id: user_id).org : nil
  end

  private

  # Set the scopes
  def ensure_scopes
    self.scopes = default_scopes.sort.join(' ') if scopes.blank?
  end
end
