# frozen_string_literal: true

require 'rails_helper'

describe 'api/v1/token.json.jbuilder' do
  before do
    @url = Faker::Internet.url
    @payload = { client_id: 'foo' }
    Rails.application.credentials.secret_key_base = SecureRandom.uuid.to_s
    @token = Api::V1::Auth::Jwt::JsonWebToken.encode(payload: @payload)
    @exp = @payload[:exp]
    @type = Faker::Lorem.word.capitalize

    assign :token, @token
    assign :expiration, @exp
    assign :token_type, @type

    @resp = OpenStruct.new(status: 200)
    @req = Net::HTTPGenericRequest.new('GET', nil, nil, @url)

    render template: 'api/v1/token',
           locals: { response: @resp, request: @req }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe 'authentication responses from controllers' do
    it 'renders the token template' do
      expect(response).to render_template('api/v1/token')
    end

    it ':access_token is the JSON Web Token' do
      expect(@json[:access_token]).to eql(@token)
    end

    it ':token_type is set' do
      expect(@json[:token_type]).to eql(@type)
    end

    it ':expires_in is set' do
      expect(@json[:expires_in]).to eql(@exp)
    end

    it ':created_at is set' do
      expect(@json[:created_at].present?).to be(true)
    end
  end
end
