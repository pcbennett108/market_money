require "rails_helper"

RSpec.describe AtmFacade do
  it "converts atm hashes from service into poros, ordered by distance", :vcr do
    market = create(:market, lat: 35.234, lon: -106.435)

    atms = AtmFacade.atms_for(market)
    expect(atms).to be_an(Array)
    expect(atms).to all be_an(Atm)
    atms.each_cons(2).each do |first, second|
      expect(first.distance < second.distance).to be(true)
    end
  end
end