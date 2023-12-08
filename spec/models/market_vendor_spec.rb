require "rails_helper"

RSpec.describe MarketVendor do
  describe "relationships" do
    it { should belong_to :market }
    it { should belong_to :vendor }
  end

  describe "validations" do
    it "should validate uniqueness" do
      markets = create_list(:market, 2)
      vendors = create_list(:vendor, 2)
      MarketVendor.create!(market: markets[0], vendor: vendors[0])
      MarketVendor.create!(market: markets[1], vendor: vendors[1])
      
    end
  end
end