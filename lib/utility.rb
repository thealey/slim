module Utility
  class << self
    def floatstringlbs(f)
      return "%.2f" % f.to_s + "/week" if f 
    end
  end
end
