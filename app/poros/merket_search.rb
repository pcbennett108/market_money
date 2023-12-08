class MarketSearch
  attr_reader :state, :city, :name

  def initialize(search_terms)
    @state = search_terms["state"]
    @city = search_terms["city"]
    @name = search_terms["name"]
    validate
  end

  def validate
    if @city && @state.nil?
      raise ActiveRecord::RecordInvalid.new(), "Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint."
    end
  end

  def render_queries
    ["state ILIKE ? AND city ILIKE ? AND name ILIKE ?", "%#{@state}%", "%#{@city}%", "%#{@name}%"]
  end
end