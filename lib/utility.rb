module Utility
  class << self
    def floatstringlbs(f)
      return "%.2f" % f.to_s + "/week" if f 
    end
    def floatformat
      "%.2f"
    end
    def floatformat_no_decimals
      "%.0f"
    end
  end
end
