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
      
      expect { MarketVendor.create!(market: markets[0], vendor: vendors[0]) }.to raise_error("Validation failed: Market vendor association between market with 'id'=#{markets[0].id} and vendor with 'id'=#{vendors[0].id} already exists")
      expect { MarketVendor.create!(market: markets[1], vendor: vendors[0]) }.not_to raise_error
      expect { MarketVendor.create!(market: markets[0], vendor: vendors[1]) }.not_to raise_error
      expect { MarketVendor.create!(market: markets[1], vendor: vendors[1]) }.to raise_error("Validation failed: Market vendor association between market with 'id'=#{markets[1].id} and vendor with 'id'=#{vendors[1].id} already exists")
    end
  end
end