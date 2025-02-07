# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PlanPresenter do
  describe '#initialize(plan:)' do
    before do
      plan = build(:plan)
      @data_contact = build(:contributor, data_curation: true)
      @pi = build(:contributor, investigation: true)
      plan.contributors = [@data_contact, @pi]
      @presenter = described_class.new(plan: plan)
    end

    it 'sets contributors to empty array if no plan was specified' do
      presenter = described_class.new(plan: nil)
      expect(presenter.data_contact).to be_nil
      expect(presenter.contributors).to eql([])
    end

    it 'sets contributors to empty array if plan has no contributors' do
      plan = build(:plan)
      plan.contributors = []
      presenter = described_class.new(plan: plan)
      expect(presenter.data_contact).to be_nil
      expect(presenter.contributors).to eql([])
    end

    it 'sets data_contact to the owner' do
      # Plan.owner stupidly requires that the record be persisted, so need to create here
      plan = create(:plan, :creator)
      presenter = described_class.new(plan: plan)
      expect(presenter.data_contact).to eql(plan.owner)
    end

    it 'sets data_contact to the data_curation contributor if there is no owner' do
      expect(@presenter.data_contact).to eql(@data_contact)
    end

    it 'sets other contributors (including the data_contact)' do
      expect(@presenter.contributors.length).to be(2)
      expect(@presenter.contributors.include?(@data_contact)).to be(true)
      expect(@presenter.contributors.include?(@pi)).to be(true)
    end
  end
end
