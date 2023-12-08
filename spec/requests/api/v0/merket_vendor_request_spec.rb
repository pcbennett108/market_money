require "rails_helper"

RSpec.describe "Market Vendor Requests" do
  it "returns a list of vendors belonging to a given market" do
    market1 = create(:market)
    market2 = create(:market)

    market_1_vendors = create_list(:market_vendor, 7, market: market1)
    market_2_vendors = create_list(:market_vendor, 8, market: market2)

    get "/api/v0/markets/#{market1.id}/vendors"

    expect(response).to be_successful
    expect(response.status).to eq(200)
    vendors1 = JSON.parse(response.body, symbolize_names: true)

    get "/api/v0/markets/#{market2.id}/vendors"

    expect(response).to be_successful
    expect(response.status).to eq(200)
    vendors2 = JSON.parse(response.body, symbolize_names: true)

    expect(vendors1).to have_key(:data)
    expect(vendors1[:data].count).to eq(7)
    expect(vendors2[:data].count).to eq(8)

    vendors1[:data].each do |vendor|
      expect(vendor).to have_key(:id)
      expect(vendor[:id]).to be_a(String)

      expect(vendor).to have_key(:type)
      expect(vendor[:type]).to eq("vendor")

      expect(vendor).to have_key(:attributes)
      expect(vendor[:attributes]).to be_a(Hash)

      expect(vendor[:attributes]).to have_key(:name)
      expect(vendor[:attributes][:name]).to be_a(String)

      expect(vendor[:attributes]).to have_key(:description)
      expect(vendor[:attributes][:description]).to be_a(String)

      expect(vendor[:attributes]).to have_key(:contact_name)
      expect(vendor[:attributes][:contact_name]).to be_a(String)

      expect(vendor[:attributes]).to have_key(:contact_phone)
      expect(vendor[:attributes][:contact_phone]).to be_a(String)

      expect(vendor[:attributes]).to have_key(:credit_accepted)
      expect(vendor[:attributes][:credit_accepted]).to eq(true).or eq(false)
    end
  end

  it "throws an error if market id is invalid" do
    get "/api/v0/markets/534/vendors"

    expect(response.status).to eq(404)
    
    error = JSON.parse(response.body, symbolize_names: true)
    
    expect(error).to have_key(:errors)
    expect(error[:errors]).to be_an(Array)
    expect(error[:errors].count).to eq(1)
    expect(error[:errors].first).to be_a(Hash)
    expect(error[:errors].first).to have_key(:detail)
    expect(error[:errors].first[:detail]).to eq("Couldn't find Market with 'id'=534")
  end

  context "create endpoint" do
    it "creates a new association between a market and vendor" do
      market = create(:market)
      vendor = create(:vendor)
      expect(MarketVendor.all.count).to eq(0)

      get "/api/v0/markets/#{market.id}/vendors"
      vendor_list = JSON.parse(response.body, symbolize_names: true)
      expect(vendor_list[:data].count).to eq(0)
      expect(market.vendor_count).to eq(0)

      post "/api/v0/market_vendors", params: {
        vendor_id: vendor.id,
        market_id: market.id
      }

      expect(response).to be_successful
      expect(response.status).to eq(201)
      message = JSON.parse(response.body, symbolize_names: true)

      expect(message).to eq({message: "Successfully added vendor to market"})
      expect(MarketVendor.all.count).to eq(1)
      expect(market.vendors).to include(vendor)

      get "/api/v0/markets/#{market.id}/vendors"
      vendor_list = JSON.parse(response.body, symbolize_names: true)
      expect(vendor_list[:data].count).to eq(1)
    end

    it "throws an error if market id is invalid" do
      vendor = create(:vendor)

      post "/api/v0/market_vendors", params: {
        vendor_id: vendor.id,
        market_id: 36454
      }

      expect(response.status).to eq(404)
      error = JSON.parse(response.body, symbolize_names: true)
      expected =  {
            errors: [
              {
                detail: "Validation failed: Market must exist"
              }
            ]
          }

      expect(error).to eq(expected)
    end

    it "throws an error if vendor id is invalid" do
      market = create(:market)

      post "/api/v0/market_vendors", params: {
        vendor_id: 546546,
        market_id: market.id
      }

      expect(response.status).to eq(404)
      error = JSON.parse(response.body, symbolize_names: true)
      expected =  {
            errors: [
              {
                detail: "Validation failed: Vendor must exist"
              }
            ]
          }

      expect(error).to eq(expected)
    end

    it "throws an error if market id is not included" do
      vendor = create(:vendor)

      post "/api/v0/market_vendors", params: {
        vendor_id: vendor.id
      }

      expect(response.status).to eq(400)
      error = JSON.parse(response.body, symbolize_names: true)
      expected =  {
            errors: [
              {
                detail: "Validation failed: Need both a market and a vendor id"
              }
            ]
          }

      expect(error).to eq(expected)
    end

    it "throws an error if vendor id is not included" do
      market = create(:market)

      post "/api/v0/market_vendors", params: {
        market_id: market.id
      }

      expect(response.status).to eq(400)
      error = JSON.parse(response.body, symbolize_names: true)
      expected =  {
            errors: [
              {
                detail: "Validation failed: Need both a market and a vendor id"
              }
            ]
          }

      expect(error).to eq(expected)
    end

    it "informs user if market_vendor association already exists" do
      market = create(:market)
      vendor = create(:vendor)
      market_vendor = MarketVendor.create!(market: market, vendor: vendor)

      post "/api/v0/market_vendors", params: {
        vendor_id: vendor.id,
        market_id: market.id
      }

      expect(response.status).to eq(422)
      message = JSON.parse(response.body, symbolize_names: true)

      expect(message).to eq({errors: [{detail: "Validation failed: Market vendor association between market with 'id'=#{market.id} and vendor with 'id'=#{vendor.id} already exists"}]})
    end
  end

  context "delete endpoint" do
    it "can delete a market_vendor association" do
      market_vendor = create(:market_vendor)
      market = Market.find(market_vendor.market_id)
      vendor = Vendor.find(market_vendor.vendor_id)

      get "/api/v0/markets/#{market.id}/vendors"
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:data].count).to eq(1)
      expect(data[:data].first[:id]).to eq("#{vendor.id}")

      delete "/api/v0/market_vendors", params: {
        market_id: market.id,
        vendor_id: vendor.id
      }

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to eq("")

      get "/api/v0/markets/#{market.id}/vendors"
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:data].count).to eq(0)
      expect(Market.all).to include(market)
      expect(Vendor.all).to include(vendor)
      expect(MarketVendor.all).to_not include(market_vendor)
    end


    it "returns an error if either id is invalid" do
      vendor = create(:vendor)

      delete "/api/v0/market_vendors", params: {
        market_id: 543,
        vendor_id: vendor.id
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      expected = {
        errors: [
              {detail: "No association exists between market with 'id'=543 AND vendor with 'id'=#{vendor.id}"}
            ]
          }

      error = JSON.parse(response.body, symbolize_names: true)
      expect(error).to eq(expected)
    end
  end
end