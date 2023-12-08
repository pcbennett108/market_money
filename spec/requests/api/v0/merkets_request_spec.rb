require "rails_helper"

RSpec.describe "Markets API", :vcr do
  it "returns a list of all markets" do
    create_list(:market, 5)

    get "/api/v0/markets" 

    expect(response).to be_successful
    expect(response.status).to eq(200)
    markets = JSON.parse(response.body, symbolize_names: true)
  
    expect(markets[:data].count).to eq(5)

    markets[:data].each do |market|
      expect(market).to have_key(:id)
      expect(market[:id]).to be_a(String)

      expect(market).to have_key(:type)
      expect(market[:type]).to eq("market")

      expect(market).to have_key(:attributes)
      expect(market[:attributes]).to be_a(Hash)

      expect(market[:attributes]).to have_key(:name)
      expect(market[:attributes][:name]).to be_a(String)

      expect(market[:attributes]).to have_key(:street)
      expect(market[:attributes][:street]).to be_a(String)

      expect(market[:attributes]).to have_key(:city)
      expect(market[:attributes][:city]).to be_a(String)

      expect(market[:attributes]).to have_key(:county)
      expect(market[:attributes][:county]).to be_a(String)

      expect(market[:attributes]).to have_key(:state)
      expect(market[:attributes][:state]).to be_a(String)

      expect(market[:attributes]).to have_key(:zip)
      expect(market[:attributes][:zip]).to be_a(String)

      expect(market[:attributes]).to have_key(:lat)
      expect(market[:attributes][:lat]).to be_a(String)

      expect(market[:attributes]).to have_key(:lon)
      expect(market[:attributes][:lon]).to be_a(String)

      expect(market[:attributes]).to have_key(:vendor_count)
      expect(market[:attributes][:vendor_count]).to be_an(Integer)
    end
  end

  it "returns one market by id" do
    id = create(:market).id

    get "/api/v0/markets/#{id}"

    expect(response).to be_successful
    expect(response.status).to eq(200)
    nested_response = JSON.parse(response.body, symbolize_names: true)
    market = nested_response[:data]

    expect(market).to have_key(:id)
    expect(market[:id]).to eq("#{id}")

    expect(market).to have_key(:type)
    expect(market[:type]).to eq("market")

    expect(market).to have_key(:attributes)
    expect(market[:attributes]).to be_a(Hash)

    expect(market[:attributes]).to have_key(:name)
    expect(market[:attributes][:name]).to be_a(String)

    expect(market[:attributes]).to have_key(:street)
    expect(market[:attributes][:street]).to be_a(String)

    expect(market[:attributes]).to have_key(:city)
    expect(market[:attributes][:city]).to be_a(String)

    expect(market[:attributes]).to have_key(:county)
    expect(market[:attributes][:county]).to be_a(String)

    expect(market[:attributes]).to have_key(:state)
    expect(market[:attributes][:state]).to be_a(String)

    expect(market[:attributes]).to have_key(:zip)
    expect(market[:attributes][:zip]).to be_a(String)

    expect(market[:attributes]).to have_key(:lat)
    expect(market[:attributes][:lat]).to be_a(String)

    expect(market[:attributes]).to have_key(:lon)
    expect(market[:attributes][:lon]).to be_a(String)

    expect(market[:attributes]).to have_key(:vendor_count)
    expect(market[:attributes][:vendor_count]).to be_an(Integer)
  end

  it "throws an error message if an invalid market id is passed" do
    get "/api/v0/markets/534"

    expect(response.status).to eq(404)
    
    error = JSON.parse(response.body, symbolize_names: true)
    
    expect(error).to have_key(:errors)
    expect(error[:errors]).to be_an(Array)
    expect(error[:errors].count).to eq(1)
    expect(error[:errors].first).to be_a(Hash)
    expect(error[:errors].first).to have_key(:detail)
    expect(error[:errors].first[:detail]).to eq("Couldn't find Market with 'id'=534")
  end

  context "search function" do
    it "returns list of markets by given search terms" do
      markets = create_list(:market, 3, state: "California", city: "Oceanside")
      apple_market = markets[0].update(name: "Apple Nation")
      more_markets = create_list(:market, 2, state: "Oregon")

      get "/api/v0/markets/search", params: {
        state: "california",
        city: "oceanside"
      }

      expect(response).to be_successful
      expect(response.status).to eq(200)

      returned_markets = JSON.parse(response.body, symbolize_names: true)
      expect(returned_markets[:data].count).to eq(3)

      get "/api/v0/markets/search", params: {
        state: "california",
        city: "oceanside",
        name: "apple nation"
      }    

      expect(response).to be_successful
      expect(response.status).to eq(200)

      returned_markets = JSON.parse(response.body, symbolize_names: true)
      expect(returned_markets[:data].count).to eq(1)
    end

    it "might return no markets" do
      get "/api/v0/markets/search", params: {
        state: "california"
      }    

      expect(response).to be_successful
      expect(response.status).to eq(200)

      returned_markets = JSON.parse(response.body, symbolize_names: true)
      expect(returned_markets[:data].count).to eq(0)
    end

    it "only accepts certain combos of params" do
      get "/api/v0/markets/search", params: {
        city: "springfield"
      }    

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      error = JSON.parse(response.body, symbolize_names: true)
      
      expected =  {
        errors: [
              {
                detail: "Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint."
              }
            ]
          }

      expect(error).to eq(expected)
    end
  end

  context "ATM search" do
    it "returns nearest atms to market, ordered by distance" do
      market = create(:market, lat: 35.07, lon: -106.60)
      get "/api/v0/markets/#{market.id}/nearest_atms"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      atms = JSON.parse(response.body, symbolize_names: true)

      expect(atms).to have_key(:data)
      expect(atms[:data]).to be_an(Array)

      atms[:data].each do |atm|
        expect(atm).to have_key(:id)
        expect(atm[:id]).to eq(nil)

        expect(atm[:type]).to eq("atm")
        expect(atm[:attributes]).to be_a(Hash)
        expect(atm[:attributes][:name]).to be_a(String)
        expect(atm[:attributes][:address]).to be_a(String)
        expect(atm[:attributes][:lat]).to be_a(Float)
        expect(atm[:attributes][:lon]).to be_a(Float)
        expect(atm[:attributes][:distance]).to be_a(Float)
      end

      atms[:data].each_cons(2).each do |first, second|
        expect(first[:attributes][:distance] < second[:attributes][:distance]).to be(true)
      end
    end

    it "might return no atms" do
      market = create(:market, lat: 5, lon: -130)
      get "/api/v0/markets/#{market.id}/nearest_atms"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      atms = JSON.parse(response.body, symbolize_names: true)

      expect(atms).to have_key(:data)
      expected = {data: []}
      expect(atms).to eq(expected)
    end

    it "returns an error if market not found" do
      get "/api/v0/markets/534/nearest_atms"

      expect(response.status).to eq(404)
      
      error = JSON.parse(response.body, symbolize_names: true)
      
      expect(error).to have_key(:errors)
      expect(error[:errors]).to be_an(Array)
      expect(error[:errors].count).to eq(1)
      expect(error[:errors].first).to be_a(Hash)
      expect(error[:errors].first).to have_key(:detail)
      expect(error[:errors].first[:detail]).to eq("Couldn't find Market with 'id'=534")
    end
  end

end