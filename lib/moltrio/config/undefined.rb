module Moltrio
  module Config
    # Object to represent 'undefined' values, a-la javascript.
    # Primarily useful for optional arguments for which 'nil' is a valid value.
    Undefined = Object.new.freeze
  end
end
