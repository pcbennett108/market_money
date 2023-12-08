require "rails_helper"

RSpec.describe "Vendor API requests" do
  context "vendor index endpoint" do
    it "returns all vendors in system" do
      create_list(:market_vendor, 10)
      get "/api/v0/vendors"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      vendors = parsed_response[:data]

      expect(vendors.count).to eq(10)
      vendors.each do |vendor|
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

        expect(vendor[:attributes]).to have_key(:states_sold_in)
        expect(vendor[:attributes][:states_sold_in]).to be_an(Array)
      end
    end

    it "returns all vendors for a given state in order of popularity" do
      market1 = create(:market, state: "Alabama")
      market2 = create(:market, state: "Alaska")
      market3 = create(:market, state: "Arizona")
      market4 = create(:market, state: "Arkansas")
      market5 = create(:market, state: "California")
      market6 = create(:market, state: "Colorado")
      vendor1 = create(:vendor)
      vendor2 = create(:vendor)
      vendor3 = create(:vendor)
      vendor4 = create(:vendor)
      vendor5 = create(:vendor)
      vendor6 = create(:vendor)

      MarketVendor.create(market: market1, vendor: vendor1)
      MarketVendor.create(market: market2, vendor: vendor1)
      MarketVendor.create(market: market3, vendor: vendor1)
      MarketVendor.create(market: market4, vendor: vendor1)
      MarketVendor.create(market: market5, vendor: vendor1)
      MarketVendor.create(market: market6, vendor: vendor1)
      
      MarketVendor.create(market: market1, vendor: vendor5)
      MarketVendor.create(market: market2, vendor: vendor5)
      MarketVendor.create(market: market3, vendor: vendor5)
      MarketVendor.create(market: market4, vendor: vendor5)
      MarketVendor.create(market: market5, vendor: vendor5)
  
      MarketVendor.create(market: market1, vendor: vendor3)
      MarketVendor.create(market: market2, vendor: vendor3)
      MarketVendor.create(market: market3, vendor: vendor3)
  
      MarketVendor.create(market: market1, vendor: vendor4)
      MarketVendor.create(market: market2, vendor: vendor4)
      MarketVendor.create(market: market3, vendor: vendor4)
      MarketVendor.create(market: market4, vendor: vendor4)
  
      MarketVendor.create(market: market1, vendor: vendor2)
  
      MarketVendor.create(market: market2, vendor: vendor6)

      get "/api/v0/vendors", params: {
        state: "Alabama"
      }

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      vendors = parsed_response[:data]

      expect(vendors.count).to eq(5)

      vendor_objects = vendors.map { |vendor| Vendor.find(vendor[:id].to_i) }

      vendor_objects.each_cons(2) do |first, second|
        expect(first.markets.count >= second.markets.count).to eq(true)
      end
    end
  end

  context "show endpoint" do
    it "can return one vendor object + attributes" do
      new_vendor = create(:vendor)
      get "/api/v0/vendors/#{new_vendor.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      vendor = parsed_response[:data]

      expect(vendor).to have_key(:id)
      expect(vendor[:id]).to eq("#{new_vendor.id}")

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

      expect(vendor[:attributes]).to have_key(:states_sold_in)
      expect(vendor[:attributes][:states_sold_in]).to be_an(Array)
    end

    it "returns an error if vendor id is invalid" do
      get "/api/v0/vendors/453"

      expect(response.status).to eq(404)
      
      error = JSON.parse(response.body, symbolize_names: true)
      
      expect(error).to have_key(:errors)
      expect(error[:errors]).to be_an(Array)
      expect(error[:errors].count).to eq(1)
      expect(error[:errors].first).to be_a(Hash)
      expect(error[:errors].first).to have_key(:detail)
      expect(error[:errors].first[:detail]).to eq("Couldn't find Vendor with 'id'=453")
    end
  end

  context "post endpoint" do
    it "can create a new vendor" do
      post "/api/v0/vendors", params: {
        name: "Buzzy Bees",
        description: "Local honey and wax products",
        contact_name: "Berly Couwer",
        contact_phone: "8389928383",
        credit_accepted: false
      }
      
      expect(response).to be_successful
      expect(response.status).to eq(201)
  
      parsed = JSON.parse(response.body, symbolize_names: true)
      vendor = parsed[:data]
  
      vendor_object = Vendor.last
  
      expect(vendor).to have_key(:id)
      expect(vendor[:id]).to eq(vendor_object.id.to_s)
  
      expect(vendor).to have_key(:type)
      expect(vendor[:type]).to eq("vendor")
  
      expect(vendor).to have_key(:attributes)
      expect(vendor[:attributes]).to be_a(Hash)
  
      expect(vendor[:attributes]).to have_key(:name)
      expect(vendor[:attributes][:name]).to eq("Buzzy Bees")
  
      expect(vendor[:attributes]).to have_key(:description)
      expect(vendor[:attributes][:description]).to eq("Local honey and wax products")
  
      expect(vendor[:attributes]).to have_key(:contact_name)
      expect(vendor[:attributes][:contact_name]).to eq("Berly Couwer")
  
      expect(vendor[:attributes]).to have_key(:contact_phone)
      expect(vendor[:attributes][:contact_phone]).to eq("8389928383")
  
      expect(vendor[:attributes]).to have_key(:credit_accepted)
      expect(vendor[:attributes][:credit_accepted]).to eq(false) 

      expect(vendor[:attributes]).to have_key(:states_sold_in)
      expect(vendor[:attributes][:states_sold_in]).to be_an(Array)
    end

    it "raises an error for a missing name or description" do
      post "/api/v0/vendors", params: {
        contact_name: "Berly Couwer",
        contact_phone: "8389928383",
        credit_accepted: true
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      error = JSON.parse(response.body, symbolize_names: true)

      expected_error =  {
        errors: [
          {
            detail: "Validation failed: Name can't be blank, Description can't be blank"
          }
        ]
      }

      expect(error).to eq(expected_error)
    end

    it "raises an error for a missing contact_name or phone" do
      post "/api/v0/vendors", params: {
        name: "Buzzy Bees",
        description: "Local honey and wax products",
        credit_accepted: true
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      error = JSON.parse(response.body, symbolize_names: true)

      expected_error =  {
        errors: [
          {
            detail: "Validation failed: Contact name can't be blank, Contact phone can't be blank"
          }
        ]
      }

      expect(error).to eq(expected_error)
    end

    it "raises an error for a missing credit accepted" do
      post "/api/v0/vendors", params: {
        name: "Buzzy Bees",
        description: "Local honey and wax products",
        contact_name: "Berly Couwer",
        contact_phone: "8389928383"
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      error = JSON.parse(response.body, symbolize_names: true)

      expected_error =  {
        errors: [
          {
            detail: "Validation failed: Credit accepted cannot be left blank"
          }
        ]
      }

      expect(error).to eq(expected_error)
    end

    it "raises an error for invalid data" do
      post "/api/v0/vendors", params: {
        name: "Buzzy Bees",
        description: "Local honey and wax products",
        contact_name: "Berly Couwer",
        contact_phone: "8389928383",
        credit_accepted: "hello world"
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      error = JSON.parse(response.body, symbolize_names: true)

      expected_error =  {
        errors: [
          {
            detail: "Credit accepted must be true or false"
          }
        ]
      }
      expect(error).to eq(expected_error)
    end
  end

  context "patch endpoint" do
    it "can update an existing vendor" do
      vendor = create(:vendor, contact_name: "Elizabeth Swan", credit_accepted: true)
      
      get "/api/v0/vendors/#{vendor.id}"
      current_vendor = JSON.parse(response.body, symbolize_names: true)
      expect(current_vendor[:data][:attributes][:contact_name]).to eq("Elizabeth Swan")
      expect(current_vendor[:data][:attributes][:credit_accepted]).to eq(true)
      

      patch "/api/v0/vendors/#{vendor.id}", params: {
        contact_name: "Kimberly Couwer",
        credit_accepted: false
      }

      expect(response).to be_successful
      expect(response.status).to eq(200)

      updated_vendor = JSON.parse(response.body, symbolize_names: true)
      expect(updated_vendor[:data][:attributes][:contact_name]).to eq("Kimberly Couwer")
      expect(updated_vendor[:data][:attributes][:credit_accepted]).to eq(false)
      expect(current_vendor[:data][:attributes][:name]).to eq(updated_vendor[:data][:attributes][:name])
      expect(current_vendor[:data][:attributes][:contact_phone]).to eq(updated_vendor[:data][:attributes][:contact_phone])
      expect(current_vendor[:data][:attributes][:contact_phone]).to_not eq(nil)
    end

    it "returns error if requested vendor doesn't exist" do
      patch "/api/v0/vendors/453",  params: {
        contact_name: "Kimberly Couwer",
        credit_accepted: false
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      
      error = JSON.parse(response.body, symbolize_names: true)
      
      expect(error).to have_key(:errors)
      expect(error[:errors]).to be_an(Array)
      expect(error[:errors].count).to eq(1)
      expect(error[:errors].first).to be_a(Hash)
      expect(error[:errors].first).to have_key(:detail)
      expect(error[:errors].first[:detail]).to eq("Couldn't find Vendor with 'id'=453")
    end

    it "returns error if update request body removes data" do
      vendor = create(:vendor)

      patch "/api/v0/vendors/#{vendor.id}",  params: {
        contact_name: "",
        credit_accepted: false
      }

      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      
      error = JSON.parse(response.body, symbolize_names: true)
      
      expect(error).to have_key(:errors)
      expect(error[:errors]).to be_an(Array)
      expect(error[:errors].count).to eq(1)
      expect(error[:errors].first).to be_a(Hash)
      expect(error[:errors].first).to have_key(:detail)
      expect(error[:errors].first[:detail]).to eq("Validation failed: Contact name can't be blank")
    end
  end

  context "delete endpoint" do
    it "can delete a vendor, and its associations" do
      market = create(:market)
      market_vendors = create_list(:market_vendor, 4, market: market)
      vendor = Vendor.find(market_vendors[0].vendor_id)

      expect(market.vendors.count).to eq(4)
      expect(market.vendors).to include(vendor)

      delete "/api/v0/vendors/#{vendor.id}"

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to eq("")
      
      expect(Vendor.all).to_not include(vendor)
      expect(market.vendors.count).to eq(3)
      expect(market.vendors).to_not include(vendor)
    end

    it "returns an error code if invalid id is passed" do
      delete "/api/v0/vendors/345"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      expected =  {
          errors: [
            {
              detail: "Couldn't find Vendor with 'id'=345"
            }
          ]
        }

      error = JSON.parse(response.body, symbolize_names: true)
      expect(error).to eq(expected)
    end
  end

  context "multiple_states search endpoint" do
    it "returns all vendors that sell in more than one state" do
      market1 = create(:market, state: "Alabama")
      market2 = create(:market, state: "Alaska")
      market3 = create(:market, state: "Arizona")
      market4 = create(:market, state: "Arkansas")
      market5 = create(:market, state: "California")
      market6 = create(:market, state: "Colorado")
      vendor1 = create(:vendor)
      vendor2 = create(:vendor)
      vendor3 = create(:vendor)
      vendor4 = create(:vendor)
      vendor5 = create(:vendor)
      vendor6 = create(:vendor)

      MarketVendor.create(market: market1, vendor: vendor1)
      MarketVendor.create(market: market2, vendor: vendor1)
      MarketVendor.create(market: market3, vendor: vendor1)
      MarketVendor.create(market: market4, vendor: vendor1)
      MarketVendor.create(market: market5, vendor: vendor1)
      MarketVendor.create(market: market6, vendor: vendor1)
      
      MarketVendor.create(market: market1, vendor: vendor5)
      MarketVendor.create(market: market2, vendor: vendor5)
      MarketVendor.create(market: market3, vendor: vendor5)
      MarketVendor.create(market: market4, vendor: vendor5)
      MarketVendor.create(market: market5, vendor: vendor5)
  
      MarketVendor.create(market: market1, vendor: vendor3)
      MarketVendor.create(market: market2, vendor: vendor3)
      MarketVendor.create(market: market3, vendor: vendor3)
  
      MarketVendor.create(market: market1, vendor: vendor4)
      MarketVendor.create(market: market2, vendor: vendor4)
      MarketVendor.create(market: market3, vendor: vendor4)
      MarketVendor.create(market: market4, vendor: vendor4)
  
      MarketVendor.create(market: market1, vendor: vendor2)
  
      MarketVendor.create(market: market1, vendor: vendor6)
  

      get "/api/v0/vendors/multiple_states"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      vendor_list = parsed_response[:data]
      expect(vendor_list.count).to eq(4)
      ids = vendor_list.map { |vendor| vendor[:id]}
      expect(ids).to include(vendor1.id.to_s, vendor5.id.to_s, vendor4.id.to_s, vendor3.id.to_s)
      expect(ids).to_not include(vendor2.id.to_s, vendor6.id.to_s)

      vendor_list.each_cons(2).each do |first, second|
        expect(first[:attributes][:states_sold_in].count > second[:attributes][:states_sold_in].count).to eq(true)
      end
    end
  end

context "popular states search endpoint" do
    it "can return list of states and count of vendors selling there" do
      ca_market = create(:market, state: "California")
      co_market = create(:market, state: "Colorado")
      pa_market = create(:market, state: "Pennsylvania")
      ny_market = create(:market, state: "New York")
      al_market = create(:market, state: "Alabama")

      create_list(:market_vendor, 10, market: ca_market)
      create_list(:market_vendor, 29, market: co_market)
      create_list(:market_vendor, 15, market: pa_market)
      create_list(:market_vendor, 31, market: ny_market)
      create_list(:market_vendor, 5, market: al_market)

      get "/api/v0/vendors/popular_states"

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      states = parsed_response[:data]
      expect(states.count).to eq(5)

      expect(states[0][:state]).to eq("New York")
      expect(states[0][:number_of_vendors]).to eq(31)

      expect(states[1][:state]).to eq("Colorado")
      expect(states[1][:number_of_vendors]).to eq(29)

      expect(states[2][:state]).to eq("Pennsylvania")
      expect(states[2][:number_of_vendors]).to eq(15)

      expect(states[3][:state]).to eq("California")
      expect(states[3][:number_of_vendors]).to eq(10)

      expect(states[4][:state]).to eq("Alabama")
      expect(states[4][:number_of_vendors]).to eq(5)
    end

    it "can return the top X number of popular states" do
      ca_market = create(:market, state: "California")
      co_market = create(:market, state: "Colorado")
      pa_market = create(:market, state: "Pennsylvania")
      ny_market = create(:market, state: "New York")
      al_market = create(:market, state: "Alabama")

      create_list(:market_vendor, 10, market: ca_market)
      create_list(:market_vendor, 29, market: co_market)
      create_list(:market_vendor, 15, market: pa_market)
      create_list(:market_vendor, 31, market: ny_market)
      create_list(:market_vendor, 5, market: al_market)

      get "/api/v0/vendors/popular_states", params: {
        limit: 3
      }

      expect(response).to be_successful
      expect(response.status).to eq(200)
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      states = parsed_response[:data]
      expect(states.count).to eq(3)

      names = states.map { |state| state[:state] }
      expect(names).to eq(["New York", "Colorado", "Pennsylvania"])
    end
  end
end