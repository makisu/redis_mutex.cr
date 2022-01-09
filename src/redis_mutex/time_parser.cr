class RedisMutex::TimeParser
  def self.parse(value)
    if value.nil?
      Time.unix(0)
    else
      Time.unix(value.to_i)
    end
  end
end
