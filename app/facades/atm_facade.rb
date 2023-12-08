class AtmFacade 
  def self.atms_for(market)
    parsed = JSON.parse(TomtomService.new.atm_search(market).body, symbolize_names: true)
    atms = parsed[:results].map do |atm|
      Atm.new(atm)
    end
    atms.sort_by { |atm| atm.distance }
  end
end