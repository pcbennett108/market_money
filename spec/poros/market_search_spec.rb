require "rails_helper"

RSpec.describe MarketSearch do
  it "initializes with state, city, and name" do
    search = MarketSearch.new({"state" => "California", "city" => "San Francisco", "name" => "Orange Fair"})

    expect(search.state).to eq("California")
    expect(search.city).to eq("San Francisco")
    expect(search.name).to eq("Orange Fair")
  end

  describe "validations" do
    it "is always valid when state is passed in" do
      expect { MarketSearch.new({"state" => "California"}) }.to_not raise_error
      expect { MarketSearch.new({"state" => "California", "city" => "San Francisco"}) }.to_not raise_error
      expect { MarketSearch.new({"state" => "California", "city" => "San Francisco", "name" => "Orange Fair"}) }.to_not raise_error
      expect { MarketSearch.new({"state" => "California", "name" => "Orange Fair"}) }.to_not raise_error
    end

    it "is not valid if city is passed without a state" do
      expect { MarketSearch.new({"city" => "San Francisco", "name" => "Orange Fair"}) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { MarketSearch.new({"city" => "San Francisco"}) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "is valid even if only name is passed" do
      expect { MarketSearch.new({"name" => "Orange Fair"}) }.to_not raise_error
    end
  end

  it "can render queries" do
    search1 = MarketSearch.new({"state" => "California", "city" => "San Francisco", "name" => "Orange Fair"})
    search2 = MarketSearch.new({"state" => "California", "name" => "Orange Fair"})
    
    expect(search1.render_queries).to eq(["state ILIKE ? AND city ILIKE ? AND name ILIKE ?", "%California%", "%San Francisco%", "%Orange Fair%"])
    expect(search2.render_queries).to eq(["state ILIKE ? AND city ILIKE ? AND name ILIKE ?", "%California%", "%%", "%Orange Fair%"])

    market = create(:market, state: "California", city: "San Francisco", name: "Orange Fair")

    expect(Market.where(search1.render_queries)).to include(market)
    expect(Market.where(search2.render_queries)).to include(market)
  end
end