class StateSerializer 
  def self.serialize(states)
    data = []
    states.each do |state|
      data << {state: state.state, number_of_vendors: state.number_of_vendors}
    end
    { data: data }
  end
end