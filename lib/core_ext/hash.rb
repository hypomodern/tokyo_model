
class Hash
  # Return a new hash with all keys converted to strings.
  def stringify_keys
    inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end
  end

  # Return a new hash with all keys converted to symbols.
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
  
  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  # n.b. this is modified to union array values in the hashes.
  def deep_merge(other_hash)
    self.merge(other_hash) do |key, oldval, newval|
      if oldval.class.to_s == 'Array' && newval.class.to_s == 'Array'
        oldval | newval
      else
        oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
        newval = newval.to_hash if newval.respond_to?(:to_hash)
        oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? oldval.deep_merge(newval) : newval
      end
    end
  end

  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  # Modifies the receiver in place.
  def deep_merge!(other_hash)
    replace(deep_merge(other_hash))
  end
end