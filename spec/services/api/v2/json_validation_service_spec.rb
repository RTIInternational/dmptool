# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::JsonValidationService do
  describe 'plan_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.plan_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:title] is not present' do
      json = { contact: { mbox: Faker::Internet.email } }
      expect(described_class.plan_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:contact][:mbox] is not present' do
      json = { title: Faker::Lorem.sentence }
      expect(described_class.plan_valid?(json: json)).to be(false)
    end

    it 'returns `true` when json[:title] and json[:contact][:mbox] are present' do
      json = { title: Faker::Lorem.sentence, contact: { mbox: Faker::Internet.email } }
      expect(described_class.plan_valid?(json: json)).to be(true)
    end
  end

  describe 'identifier_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.identifier_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:type] is not present' do
      json = { identifier: SecureRandom.uuid }
      expect(described_class.identifier_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:identifier] is not present' do
      json = { type: Faker::Lorem.word }
      expect(described_class.identifier_valid?(json: json)).to be(false)
    end

    it 'returns `true` when valid' do
      json = { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
      expect(described_class.identifier_valid?(json: json)).to be(true)
    end
  end

  describe 'org_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.org_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:name], [:affiliation_id] and [:funder_id] are not present' do
      json = { abbreviation: Faker::Lorem.word.upcase }
      expect(described_class.org_valid?(json: json)).to be(false)
    end

    it 'returns `true` when :name is present' do
      json = { name: Faker::Company.unique.name }
      expect(described_class.org_valid?(json: json)).to be(true)
    end

    it 'returns `true` when :affiliation_id is present' do
      json = { affiliation_id: SecureRandom.uuid }
      expect(described_class.org_valid?(json: json)).to be(true)
    end

    it 'returns `true` when :funder_id is present' do
      json = { funder_id: SecureRandom.uuid }
      expect(described_class.org_valid?(json: json)).to be(true)
    end

    it 'returns `true` when :name and :affiliation_id are present' do
      json = { name: Faker::Company.unique.name, affiliation_id: SecureRandom.uuid }
      expect(described_class.org_valid?(json: json)).to be(true)
    end

    it 'returns `true` when :name and :funder_id are present' do
      json = { name: Faker::Company.unique.name, funder_id: SecureRandom.uuid }
      expect(described_class.org_valid?(json: json)).to be(true)
    end
  end

  describe 'contributor_valid?(json:, is_contact: false)' do
    it 'returns `false` when json is not present' do
      expect(described_class.contributor_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:name] or json[:mbox] is not present' do
      json = { contributor_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid } }
      expect(described_class.contributor_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:role] is not present and :is_contact is false' do
      json = { name: Faker::Music::PearlJam.musician, mbox: Faker::Internet.email }
      expect(described_class.contributor_valid?(json: json)).to be(false)
    end

    it 'returns `true` when valid and :is_contact is false' do
      json = { name: Faker::Music::PearlJam.musician, role: Faker::Lorem.word }
      expect(described_class.contributor_valid?(json: json)).to be(true)
      json = { mbox: Faker::Internet.email, role: Faker::Lorem.word }
      expect(described_class.contributor_valid?(json: json)).to be(true)
    end

    it 'returns `true` when valid and :is_contact is true' do
      json = { name: Faker::Music::PearlJam.musician }
      expect(described_class.contributor_valid?(json: json, is_contact: true)).to be(true)
      json = { mbox: Faker::Internet.email }
      expect(described_class.contributor_valid?(json: json, is_contact: true)).to be(true)
    end
  end

  describe 'funding_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.funding_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:name] or json[:funder_id] or json[:grant_id] are not present' do
      json = { status: Faker::Lorem.word }
      expect(described_class.funding_valid?(json: json)).to be(false)
    end

    it 'returns `true` when json[:name] is present' do
      json = { name: Faker::Company.name }
      expect(described_class.funding_valid?(json: json)).to be(true)
    end

    it 'returns `true` when json[:funder_id][:identifier] is present' do
      json = { funder_id: { identifier: SecureRandom.uuid } }
      expect(described_class.funding_valid?(json: json)).to be(true)
    end

    it 'returns `true` when json[:grant_id][:identifier] is present' do
      json = { grant_id: { identifier: SecureRandom.uuid } }
      expect(described_class.funding_valid?(json: json)).to be(true)
    end
  end

  describe 'dataset_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.dataset_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:title] or json[:dataset_id] are not present' do
      json = { desription: Faker::Lorem.paragraph }
      expect(described_class.dataset_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:title] or json[:dataset_id][:identifier] are not present' do
      json = { dataset_id: { type: 'url' } }
      expect(described_class.dataset_valid?(json: json)).to be(false)
    end

    it 'returns `true` when json[:title] is present' do
      json = { title: Faker::Lorem.sentence }
      expect(described_class.dataset_valid?(json: json)).to be(true)
    end

    it 'returns `true` when json[:dataset_id] is present' do
      json = { dataset_id: { identifier: SecureRandom.uuid } }
      expect(described_class.dataset_valid?(json: json)).to be(true)
    end
  end

  describe ':related_identifier_valid?(json:)' do
    it 'returns `false` when json is not present' do
      expect(described_class.related_identifier_valid?(json: nil)).to be(false)
    end

    it 'returns `false` when json[:descriptor] is not present' do
      json = { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
      expect(described_class.related_identifier_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:type] is not present' do
      json = { descriptor: Faker::Lorem.word, identifier: SecureRandom.uuid }
      expect(described_class.related_identifier_valid?(json: json)).to be(false)
    end

    it 'returns `false` when json[:identifier] is not present' do
      json = { type: Faker::Lorem.word, descriptor: Faker::Lorem.word }
      expect(described_class.related_identifier_valid?(json: json)).to be(false)
    end

    it 'returns `true` when :descriptor, :type and :identifier are present' do
      json = { descriptor: Faker::Lorem.word, type: Faker::Lorem.word,
               identifier: SecureRandom.uuid }
      expect(described_class.related_identifier_valid?(json: json)).to be(true)
    end
  end

  describe 'validation_errors(json:)' do
    before do
      @json = {
        title: Faker::Lorem.sentence,
        contact: { mbox: Faker::Internet.email },
        contributor: [{ mbox: Faker::Internet.email }],
        project: [
          {
            funding: [
              { name: Faker::Company.name },
              { name: Faker::Company.name }
            ]
          }
        ],
        dmp_id: { type: 'URL', identifier: Faker::Internet.url }
      }
    end

    it "returns an 'Invalid JSON' error if :json is not present" do
      expect(described_class.validation_errors(json: nil)).to eql([_('invalid JSON')])
    end

    it 'returns an empty array if everything is valid' do
      expect(described_class.validation_errors(json: @json)).to eql([])
    end

    it 'calls the contributor_validation_errors' do
      described_class.expects(:contributor_validation_errors).at_least(2)
      described_class.validation_errors(json: @json)
    end

    it 'calls the funding_validation_errors' do
      described_class.expects(:funding_validation_errors).at_least(1)
      described_class.validation_errors(json: @json)
    end

    it 'returns the BAD_PLAN_MSG if the plan is not valid' do
      described_class.stubs(:plan_valid?).returns(false)
      results = described_class.validation_errors(json: @json)
      expect(results.include?(described_class::BAD_PLAN_MSG)).to be(true)
    end

    it 'returns the BAD_ID_MSG if the dmp_id is not valid' do
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns all of the error messages' do
      c_errs = [described_class::BAD_ORG_MSG, described_class::BAD_CONTRIB_MSG]
      f_errs = [described_class::BAD_FUNDING_MSG]
      described_class.stubs(:contributor_validation_errors).returns(c_errs)
      described_class.stubs(:funding_validation_errors).returns(f_errs)
      described_class.stubs(:identifier_valid?).returns(false)
      described_class.stubs(:plan_valid?).returns(false)
      results = described_class.validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
      expect(results.include?(described_class::BAD_ORG_MSG)).to be(true)
      expect(results.include?(described_class::BAD_CONTRIB_MSG)).to be(true)
      expect(results.include?(described_class::BAD_FUNDING_MSG)).to be(true)
      expect(results.include?(described_class::BAD_PLAN_MSG)).to be(true)
    end
  end

  describe ':contributor_validation_errors(json:)' do
    before do
      @json = {
        name: Faker::Movies::StarWars.character,
        mbox: Faker::Internet.email,
        affiliation: {
          name: Faker::Company.name,
          affiliation_id: { type: 'URL', identifier: SecureRandom.uuid }
        },
        contributor_id: { type: 'URL', identifier: Faker::Internet.url },
        role: [Contributor.new.all_roles.sample.to_s]
      }
    end

    it 'returns an empty array if :json is not present' do
      expect(described_class.contributor_validation_errors(json: nil)).to eql([])
    end

    it 'returns an empty array if everything is valid' do
      expect(described_class.contributor_validation_errors(json: nil)).to eql([])
    end

    it 'calls the org_validation_errors' do
      described_class.expects(:org_validation_errors).at_least(1)
      described_class.contributor_validation_errors(json: @json)
    end

    it 'returns the BAD_CONTRIB_MSG if the contributor is not valid' do
      described_class.stubs(:contributor_valid?).returns(false)
      results = described_class.contributor_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_CONTRIB_MSG)).to be(true)
    end

    it 'returns the BAD_ID_MSG if the contact_id is not valid' do
      @json.delete(:contributor_id)
      @json[:contact_id] = { type: 'URL', identifier: Faker::Internet.url }
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.contributor_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns the BAD_ID_MSG if the contributor_id is not valid' do
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.contributor_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns all of the error messages' do
      described_class.expects(:org_validation_errors).at_least(1)
      described_class.stubs(:contributor_valid?).returns(false)
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.contributor_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
      expect(results.include?(described_class::BAD_CONTRIB_MSG)).to be(true)
    end
  end

  describe ':funding_validation_errors(json:)' do
    before do
      @json = {
        name: Faker::Company.name,
        funder_id: { type: 'URL', identifier: Faker::Internet.url },
        grant_id: { type: 'URL', identifier: Faker::Internet.url }
      }
    end

    it 'returns an empty array if :json is not present' do
      expect(described_class.funding_validation_errors(json: nil)).to eql([])
    end

    it 'returns an empty array if everything is valid' do
      expect(described_class.funding_validation_errors(json: nil)).to eql([])
    end

    it 'calls the org_validation_errors' do
      described_class.expects(:org_validation_errors).at_least(1)
      described_class.funding_validation_errors(json: @json)
    end

    it 'returns the BAD_ID_MSG if the funder_id is not valid' do
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.funding_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns the BAD_ID_MSG if the grant_id is not valid' do
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.funding_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns all of the error messages' do
      described_class.expects(:org_validation_errors).at_least(1)
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.funding_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end
  end

  describe ':org_validation_errors(json:)' do
    before do
      @json = {
        name: Faker::Company.name,
        affiliation_id: { type: 'URL', identifier: Faker::Internet.url }
      }
    end

    it 'returns an empty array if :json is not present' do
      expect(described_class.org_validation_errors(json: nil)).to eql([])
    end

    it 'returns an empty array if everything is valid' do
      expect(described_class.org_validation_errors(json: nil)).to eql([])
    end

    it 'returns the BAD_ORG_MSG if the org is not valid' do
      described_class.stubs(:org_valid?).returns(false)
      results = described_class.org_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ORG_MSG)).to be(true)
    end

    it 'returns the BAD_ID_MSG if the identifier is not valid' do
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.org_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end

    it 'returns all of the error messages' do
      described_class.stubs(:org_valid?).returns(false)
      described_class.stubs(:identifier_valid?).returns(false)
      results = described_class.org_validation_errors(json: @json)
      expect(results.include?(described_class::BAD_ORG_MSG)).to be(true)
      expect(results.include?(described_class::BAD_ID_MSG)).to be(true)
    end
  end

  describe ':related_identifiers_errors(json:)' do
    before do
      @json = [{
        descriptor: RelatedIdentifier.relation_types.keys.sample,
        type: RelatedIdentifier.identifier_types.keys.sample,
        identifier: SecureRandom.uuid
      }]
    end

    it 'returns an empty array if :json is not present' do
      expect(described_class.related_identifiers_errors(json: nil)).to eql([])
    end

    it 'returns an empty array if everything is valid' do
      expect(described_class.related_identifiers_errors(json: @json)).to eql([])
    end

    it 'returns the BAD_RELATED_IDENTIFIER_MSG if the related_identifier is not valid' do
      described_class.stubs(:related_identifier_valid?).returns(false)
      results = described_class.related_identifiers_errors(json: @json)
      expect(results.include?(described_class::BAD_RELATED_IDENTIFIER_MSG)).to be(true)
    end
  end
end
