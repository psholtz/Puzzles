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
	def pad( n=5 )
		self + "X" * ( ( n - self.length % n ) % n )
	end

	# ===================================
	# Does not work for "frozen" strings
	# ===================================
	def pad!( n=5 )
		self.replace pad(n)
	end

	def sanitize(n=5)
		s = self.upcase
		s = s.gsub(/[^A-Z]/,"")
		s = s.pad(n)
	end

	# ===================================
	# Does not work for "frozen" strings
	# ===================================
	def sanitize!( n=5 )
		self.upcase!
		self.gsub!(/[^A-Z]/,"")
		self.pad!(n)
	end

	def crack( n=5 )
		s = ""
		((self.length / n) + 1).times { |i| s << self[i*n,n] << " " }
		s.strip!
	end

	# ===================================
	# Does not work for "frozen" strings
	# ===================================
	def crack!( n=5 )
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
		out
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

	# ++++++++++++++++++++++++++++
	# Abstract method definition. 
	# ++++++++++++++++++++++++++++
	def generate_keystream( length )
		@deck = Deck.new
		result = []
		while result.length != length
			@deck.move_A
			@deck.move_B
			@deck.triple_cut
			@deck.count_cut
			letter = @deck.output_letter
			result << letter unless letter.nil?
		end
		result.join
	end
end

# =========================================================
# Class Deck implements a standard 52-card deck of cards.
#
# There are two Jokers, designated by "A" and "B".
# =========================================================
class Deck
	# ++++++++++++++++++++++++++++++++++++
	# Initialize with a key, the "secret"
	# ++++++++++++++++++++++++++++++++++++
	def initialize(key=(1..52).to_a << "A" << "B")
		@deck = key
	end

	def inspect; "Deck"; end

	# +++++++++++++++++++++++++++++
	#  M O V E   C A R D   A P I s
	# +++++++++++++++++++++++++++++
	def move_A
		move_down( @deck.index("A") )
	end

	def move_B
		2.times { move_down( @deck.index("B") ) }
	end

	def move_down(index)
		if index == @deck.length-1
			@deck[1..1] = @deck[index], @deck[1]
			@deck.pop
		else
			@deck[index], @deck[index+1] = @deck[index+1], @deck[index]
		end
	end

	# +++++++++++++++++++++++++++++++++++
	#  C A R D   C U T T I N G   A P I s
	# +++++++++++++++++++++++++++++++++++
	def triple_cut
		a = @deck.index( "A" )
		b = @deck.index( "B" )
		a,b = b,a if a>b
		@deck.replace( [@deck[(b+1)..-1],
				@deck[a..b],
				@deck[0..(a-1)]].flatten )
	end

	def count_cut
		a = @deck.last
		a = 53 if a.instance_of? String

		temp = @deck[0..(a-1)]
		@deck[0..(a-1)] = []
		@deck[-1..-1] = [temp, @deck.last].flatten
	end

	# +++++++++++++++++++++ 
	#  O U T P U T   A P I 
	# +++++++++++++++++++++
	def output_letter
		a = @deck.first
		a = 53 if a.instance_of? String
		output = @deck[a]
		if output.instance_of? String
			nil
		else
			output -= 26 if output > 26
			(output + 64).chr
		end
	end

	# +++++++++++++++++++
	#  T E S T   A P I s 
	# +++++++++++++++++++
	def card_at(index)
		@deck[index]
	end

	def deck_size
		@deck.length
	end
end

# ==========================================
# If invoked from the command line, go here
# ==========================================
OPTIONS = {
	:encode	=> nil,
	:decode => nil 
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator  ""	
		o.on("-e", "--encode=[value]", String, "Encrypt a plaintext message by using this flag" ) { |OPTIONS[:encode]| }
		o.on("-d", "--decode=[value]", String, "Decrypt an encoded message by using this flag" ) { |OPTIONS[:decode]| }
		o.separator ""
		o.parse!

		# run the actual script
		if OPTIONS[:encode] != ""  and OPTIONS[:encode] != nil
			puts Cipher.new.encode(OPTIONS[:encode])
		elsif OPTIONS[:decode] != "" and OPTIONS[:decode] != nil
			puts Cipher.new.decode(OPTIONS[:decode])
		else 
			puts o
		end
	end
end
