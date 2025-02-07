# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationService do
  describe '#application_name' do
    it 'returns the application name defined in the dmproadmap.rb initializer' do
      original_name = Rails.configuration.x.application.name
      Rails.configuration.x.application.name = 'Foo'
      expect(described_class.application_name).to eql('Foo')
      Rails.configuration.x.application.name = original_name
    end

    it 'returns the Rails application name if no dmproadmap.rb initializer entry' do
      original_name = Rails.configuration.x.application.name
      Rails.configuration.x.application.delete(:name)
      expected = Rails.application.class.name.split('::').first
      expect(described_class.application_name).to eql(expected)
      Rails.configuration.x.application.name = original_name
    end
  end
end
