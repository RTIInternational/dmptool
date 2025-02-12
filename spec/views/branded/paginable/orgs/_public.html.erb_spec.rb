# frozen_string_literal: true

require 'rails_helper'

describe 'paginable/orgs/_public.html.erb' do
  include Helpers::IdentifierHelper

  it 'renders our version of the page' do
    3.times do
      org = create(:org)
      create_shibboleth_entity_id(org: org)
    end
    shib = Org.last
    non_shib = create(:org, managed: true, identifiers: [], funder: false)

    controller.prepend_view_path 'app/views/branded'
    assign :paginable_path_params, { sort_field: 'orgs.name', sort_direction: :asc }
    assign :paginable_options, {}
    assign :args, { controller: 'paginable/orgs', action: 'public' }
    # Paginable is expecting `scope` to be a local not an instance variable
    render partial: 'paginable/orgs/public', locals: { scope: Org.participating }
    expect(rendered.include?('Institutional Signin Enabled')).to be(true)
    expect(rendered.include?(CGI.escapeHTML(shib.name))).to be(true)
    expect(rendered.include?(CGI.escapeHTML(non_shib.name))).to be(true)
    expect(rendered.scan('fa-check').length).to be(3)
  end
end
