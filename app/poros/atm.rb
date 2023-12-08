class Atm 
  attr_reader :name,
              :address,
              :lat,
              :lon,
              :distance,
              :id
  def initialize(data)
    @name = data[:poi][:name]
    @address = format_address(data[:address])
    @lat = data[:position][:lat]
    @lon = data[:position][:lon]
    @distance = format_dist(data[:dist])
    @id = nil
  end

  def format_address(address)
    "#{address[:streetNumber]} #{address[:streetName]}, #{address[:municipality]}, #{address[:countrySubdivision]} #{address[:postalCode]}"
  end

  def format_dist(distance_in_meters) #converts to miles
    distance_in_meters * 0.000621371
  end
end