require_relative '../spec_helper'

describe 'Examples' do
  it 'Locale & Time Zone: picks the language from the URL' do
    visit '/locale?lang=es'
    expect(find(:id, 'greeting').text).to eq '¡Hola!'
    find(:link_text, 'de').click
    expect(find(:id, 'greeting').text).to eq 'Hallo!'
    expect(find(:id, 'server-language').text).to eq 'de'
  end

  it 'Locale & Time Zone: formats with the browser locale and time zone' do
    visit '/locale'
    language, zone = @driver.execute_script('return [navigator.language, Intl.DateTimeFormat().resolvedOptions().timeZone]')
    expect(find(:id, 'browser-language').text).to eq language
    expect(find(:id, 'browser-timezone').text).to eq zone
    expect(find(:id, 'formatted-number').text).to match(/1.?234.?567/)
    expect(find(:id, 'formatted-date').text).to include '2026'
  end
end
