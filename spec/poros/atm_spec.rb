require "rails_helper" 

RSpec.describe Atm do
  it "has name, address, lat, lon, and distance", :vcr do
    json_response = File.read('spec/fixtures/atm_sample.json')

    parsed = JSON.parse(json_response, symbolize_names: true)
    atm = Atm.new(parsed)

    expect(atm.name).to eq("ATM at Msquared")
    expect(atm.address).to eq("31 East Santa Clara Street, San Jose, CA 95113")
    expect(atm.lat).to eq(37.336651)
    expect(atm.lon).to eq(-121.890117)
    expect(atm.distance).to eq(0.02495715494886)
  end
end