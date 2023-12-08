class Api::V0::MarketsController < ApplicationController
  before_action :find_market, only: [:show, :nearest_atms]

  def index
    render json: MarketSerializer.new(Market.all)
  end

  def show
    render json: MarketSerializer.new(@market)
  end

  def search
    search = MarketSearch.new(search_params)
    render json: MarketSerializer.new(Market.search(search))
  end

  def nearest_atms
    render json: AtmSerializer.new(AtmFacade.atms_for(@market))
  end

  private
  def search_params
    params.permit(:state, :city, :name).to_hash
  end

  def find_market
    @market = Market.find(params[:id])
  end
end