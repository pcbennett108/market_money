class Api::V0::MarketVendorsController < ApplicationController

  def index
    market = Market.find(params[:market_id])
    render json: VendorSerializer.new(market.vendors)
  end
  
end