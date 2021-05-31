# frozen_string_literal: true

RSpec.describe 'Create new CDR export', js: true do
  subject do
    click_submit 'Create Cdr export'
  end

  include_context :login_as_admin

  let!(:account) do
    create(:account, name: 'rspec')
  end

  context 'with all filled attributes' do
    before do
      visit new_cdr_export_path

      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
      fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_flash_message('Cdr export was successfully created.', type: :notice)

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s,
          'src_prefix_in_contains' => '',
          'src_prefix_routing_contains' => '',
          'src_prefix_out_contains' => '',
          'dst_prefix_in_contains' => '',
          'dst_prefix_routing_contains' => '',
          'dst_prefix_out_contains' => '',
          'src_country_id_eq' => '',
          'dst_country_id_eq' => '',
          'routing_tag_ids_include' => '',
          'routing_tag_ids_exclude' => ''
        )
      )
    end
  end

  context 'with inherited fields' do
    before do
      create :cdr_export, :completed, fields: %w[id success customer_id]
      visit new_cdr_export_path

      fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id customer_id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s,
          'src_prefix_in_contains' => '',
          'src_prefix_routing_contains' => '',
          'src_prefix_out_contains' => '',
          'dst_prefix_in_contains' => '',
          'dst_prefix_routing_contains' => '',
          'dst_prefix_out_contains' => '',
          'src_country_id_eq' => '',
          'dst_country_id_eq' => '',
          'routing_tag_ids_include' => '',
          'routing_tag_ids_exclude' => ''
        )
      )
    end
  end

  context 'with all filled filters' do
    let!(:countries) { create_list(:country, 2, :uniq_name) }

    before do
      visit new_cdr_export_path

      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
      fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
      fill_in 'Src prefix in contains', with: 'src_prefix_in_test'
      fill_in 'Src prefix routing contains', with: 'src_prefix_routing_test'
      fill_in 'Src prefix out contains', with: 'src_prefix_out_test'
      fill_in 'Dst prefix in contains', with: 'dst_prefix_in_test'
      fill_in 'Dst prefix routing contains', with: 'dst_prefix_routing_test'
      fill_in 'Dst prefix out contains', with: 'dst_prefix_out_test'
      fill_in_chosen 'Src country id eq', with: countries.first.name
      fill_in_chosen 'Dst country id eq', with: countries.last.name
      fill_in 'Routing tag ids include', with: 2
      fill_in 'Routing tag ids exclude', with: 25
      fill_in_chosen 'Routing tag ids empty', with: 'Any'
    end

    it 'should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: nil,
        fields: %w[id success],
        status: 'Pending',
        filters: CdrExport::FiltersModel.new(
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'customer_acc_id_eq' => account.id.to_s,
          'src_prefix_in_contains' => 'src_prefix_in_test',
          'src_prefix_routing_contains' => 'src_prefix_routing_test',
          'src_prefix_out_contains' => 'src_prefix_out_test',
          'dst_prefix_in_contains' => 'dst_prefix_in_test',
          'dst_prefix_routing_contains' => 'dst_prefix_routing_test',
          'dst_prefix_out_contains' => 'dst_prefix_out_test',
          'src_country_id_eq' => countries.first.id,
          'dst_country_id_eq' => countries.last.id,
          'routing_tag_ids_include' => 2,
          'routing_tag_ids_exclude' => 25,
          'routing_tag_ids_empty' => nil
        )
      )
    end
  end

  context 'with incorrect filters' do
    before do
      visit new_cdr_export_path

      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
    end

    it 'should rise semantic error' do
      subject
      expect(page).to have_semantic_error('Filters can\'t be blank and requires time_start_lteq & time_start_gteq')
    end
  end
end
