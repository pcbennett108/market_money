require "rails_helper"

RSpec.describe TomtomService do
  it "finds nearby cash despensers", :vcr do
    market = create(:market, lat: 35.234, lon: -106.435)

    response = TomtomService.new.atm_search(market) 

    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
  end
end