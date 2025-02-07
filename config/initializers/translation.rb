# frozen_string_literal: true

# New with Rails 6+, we need to define the list of locales outside the context of
# the Database since thiss runs during startup. Trying to access the DB causes
# issues with autoloading; 'DEPRECATION WARNING: Initialization autoloaded the constants ... Language'
#
# Note that the entries here must have a corresponding directory in config/locale, a
# YAML file in config/locales and should also have an entry in the DB's languages table
# SUPPORTED_LOCALES = %w[de en-CA en-GB en-US es fi fr-CA fr-FR pt-BR sv-FI tr-TR].freeze
SUPPORTED_LOCALES = %w[en-US es pt-BR].freeze
# You can define a subset of the locales for your instance's version of Translation.io if applicable
# CLIENT_LOCALES = %w[de en-CA en-GB en-US es fi fr-CA fr-FR pt-BR sv-FI tr-TR].freeze
CLIENT_LOCALES = %w[en-US es pt-BR].freeze
# DEFAULT_LOCALE = 'en-GB'
DEFAULT_LOCALE = 'en-US'
# Here we define the translation domains for the Roadmap application, `app` will
# contain translations from the open-source repository and ignore the contents
# of the `app/views/branded` directory.  The `client` domain will
#
# When running the application, the `app` domain should be specified in your environment.
# the `app` domain will be searched first, falling back to `client`
#
# When generating the translations, the rake:tasks will need to be run with each
# domain specified in order to generate both sets of translation keys.
if !ENV['DOMAIN'] || ENV.fetch('DOMAIN', nil) == 'app'
  TranslationIO.configure do |config|
    config.api_key              = Rails.configuration.x.dmproadmap.translation_io_key_app
    config.source_locale        = 'en'
    config.target_locales       = SUPPORTED_LOCALES
    config.text_domain          = 'app'
    config.bound_text_domains   = %w[app client]
    config.ignored_source_paths = Dir.glob('**/*').select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .select do |path|
                                       path.include?('branded/') ||
                                         path.include?('dmptool/') ||
                                         path.include?('node_modules/')
                                     end
    config.locales_path         = Rails.root.join('config', 'locale')
  end
elsif ENV.fetch('DOMAIN', nil) == 'client'
  # Control ignored source paths
  # Note, all prefixes of the directory you want to translate must be defined here!
  #
  # To sync translations with the Translation IO server run:
  #  > rails translation:sync_and_purge DOMAIN=client
  TranslationIO.configure do |config|
    config.api_key              = Rails.configuration.x.dmproadmap.translation_io_key_client
    config.source_locale        = 'en'
    config.target_locales       = CLIENT_LOCALES
    config.text_domain          = 'client'
    config.bound_text_domains = ['client']
    config.ignored_source_paths = Dir.glob('**/*').select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .reject do |path|
                                       path == 'app/' || path == 'app/views/' ||
                                         path.include?('branded/') || path.include?('dmptool/')
                                     end
    config.disable_yaml         = true
    config.locales_path         = Rails.root.join('config', 'locale')
  end
end

# Setup languages
def default_locale
  DEFAULT_LOCALE
end

def available_locales
  SUPPORTED_LOCALES.sort
end

I18n.available_locales = SUPPORTED_LOCALES

I18n.default_locale = DEFAULT_LOCALE
