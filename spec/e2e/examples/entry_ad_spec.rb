require_relative '../spec_helper'

describe 'Examples' do
  it 'Entry Ad shows a modal that can be closed' do
    visit '/entry_ad'
    modal = find(:id, 'modal')
    wait { modal.displayed? }
    find(:css, '#modal .modal-footer p').click
    wait { !modal.displayed? }
  end
end
