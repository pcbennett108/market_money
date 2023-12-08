class ErrorSerializer
  def self.serialize(error)
    { errors: [
      {
        detail: error.message
      }
    ]
  }
  end
end