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

    def sanitize(n=5)
    	s = self.upcase
 	s = s.gsub(/[^A-Z]/,"")
	s = s.pad(n)
    end

    # ================================== 
    # Does not work for "frozen" strings
    # ================================== 
    def sanitize!(n=5)
    	self.upcase!
	self.sgub!(/[^A-Z]/,"")
	self.pad!(n)
    end

    def crack(n=5)
    	s = ""
	((self.length / n) + 1).times { |i| s << self[i*n,n] << " " }
	s.strip!
    end
    
    # ================================== 
    # Does not work for "frozen" strings
    # ================================== 
    def crack!(n=5)
    	self.replace crack(n)
    end
end

# ======================================================================
# Cipher combines a) message with b) keystream to obfuscate information
# 
# - encode: call with (sanitized) string to encrypt
# - decode: call with (sanitized) string to decrypt
#
# ======================================================================
class Cipher
    def initialize(n=5)
        @block_size = n
	@keystream = SolitaireKeyStream.new
    end

    attr_accessor :block_size

    def inspect; "Cipher"; end

    def encode(s)
    	msg_length = s.sanitize!(@block_size).length
	t = combine(s,@keystream.add,msg_length)
	t.crack!(@block_size)
    end

    def decode(s)
    	msg_length = s.sanitize!(@block_size).length
	t = combine(s,@keystream.sub,msg_length)
	t.crack!(@block_size)
    end

    # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    # Performs the "heavy lifting" of this class by mixing in the keystream.
    #
    #  - s: sanitized message (to encrypt, or decrypt)
    #  - m: combination method (either add, or subtract)
    #  
    # "Adding" the streams together yields encryption.
    # "Subtracting" the streams yields decryption. 
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    def combine(s,m,length)
    	# generate the keystream
	stream = @keystream.generate_keystream(length)

	# combine the msg and the keystream
	out = ""; i = 0
	s.bytes.to_a.zip(stream.bytes.to_a) { |x|
	    out << m.call(x[0],x[1]).chr
	}
    end

    protected :combine
end

# ===============================================================
# Class KeyStream defines "abstract" methods that all KeyStreams 
# should implement. 
#
# - generate_keystream: return a keystream of the given length
#
# Ruby is dynamically typed, so the use of "abstract" methods here
# is really just a loose of sorts, more for heuristic purposes,
# than it is a strictly enforced syntactic rule.
# ===============================================================
class KeyStream
    def generate_keystream( length ); end;
end

# ================================================================
# Class SolitaireKeyStream implements the cryptosystem code-named
# "Pontifex" designed by Bruce Schneier for Neal Stephenson's 
# novel Cryptonomicon.
# ================================================================
class SolitaireKeyStream < KeyStream
    def initialize(key=nil)
    	@deck = Deck.new(key)
	@add = lambda {|x,y| x+y > 154 ? x+y-90 : x+y-64 }
	@sub = lambda {|x,y| x-y < 1 ? x-y+90 : x-y+64 }
    end

    attr_accessor :add, :sub

    def inspect; "SolitaireKeyStream"; end
end

class Deck

end

# ==========================================
# If invoked from the command line, go here
# ==========================================
OPTIONS = {
    :encode => nil,
    :decode => nil
}