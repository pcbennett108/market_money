class TomtomService
  def atm_search(market)
    Faraday.get("https://api.tomtom.com/search/2/nearbySearch/.json") do |f|
      f.params[:lat] = market.lat
      f.params[:lon] = market.lon
      f.params[:radius] = 10000
      f.params[:categorySet] = 7397
      f.params[:key] = Rails.application.credentials.tomtom[:key]
    end
  end
end