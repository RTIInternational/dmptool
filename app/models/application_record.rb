# frozen_string_literal: true

# Base ActiveRecord object
class ApplicationRecord < ActiveRecord::Base
  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  self.abstract_class = true

  class << self
    # Indicates whether the underlying DB is MySQL
    def mysql_db?
      connection.adapter_name == 'Mysql2'
    end

    def postgres_db?
      connection.adapter_name == 'PostgreSQL'
    end

    # Domains for common email platforms that do not belong to a specific institution
    # Used by the `from_email_domain` method on Org and RegistryOrg
    def ignored_email_domains
      %w[aol.com duck.com gmail.com example.com example.org hotmail.com icloud.com
         outlook.com pm.me qq.com yahoo.com]
    end

    # Attempts to extract the domain from the string
    # Used by the `from_email_domain` method on Org and RegistryOrg
    def domain_for(url:)
      URI.parse(url).host.gsub('www', '')
    rescue URI::InvalidURIError
      url
    end

    # Generates the appropriate where clause for a JSON field based on the DB type
    def safe_json_where_clause(column:, hash_key:)
      return "(#{column}->>'#{hash_key}' LIKE ?)" unless mysql_db?

      "(#{column}->>'$.#{hash_key}' LIKE ?)"
    end

    def safe_json_lower_where_clause(table:, attribute:)
      return '' unless table.present? && attribute.present?
      return "LOWER(#{attribute}::text) LIKE LOWER(?)" unless mysql_db?

      "LOWER(#{table}.#{attribute}) LIKE LOWER(?)"
    end

    # Generates the appropriate where clause for a regular expression based on the DB type
    def safe_regexp_where_clause(column:)
      return "#{column} ~* ?" unless mysql_db?

      "#{column} REGEXP ?"
    end
  end

  def sanitize_fields(*attrs)
    attrs.each do |attr|
      send("#{attr}=", ActionController::Base.helpers.sanitize(send(attr)))
    end
  end
end
