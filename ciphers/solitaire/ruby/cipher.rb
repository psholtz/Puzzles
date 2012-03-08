#!/usr/bin/ruby

require 'optparse'

# =======================================================
# String Class Extension: add methods directly to String 
#
# - pad: pad with "X" till size of multiple of n
# - sanitize: capitalize, remove nonalpha, then pad 
# - crack: break into a blocks of size n
# =======================================================
class String
  def pad(n=5)
    self + "X" * ( ( n - self.length % n ) % n )
  end

  # ================================== 
  # Does not work for "frozen" strings
  # ================================== 
  def pad!(n=5)
    self.replace pad(n)
  end
end