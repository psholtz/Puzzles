#!./lua5.1

dofile 'classlib.lua'

--[[
	Sample code that demonstrates how to
	use the (hacked-on) OO features of Lua.
]]

-- 
-- Class definitions
--
class.A()
function A:__init(s) self.s = s end
function A:ps() print(self.s) end

class.B(A)
function B:__init(s,sl)
	self.A:__init(s)
	self.sl = sl
end
function B:ps1() print(self.sl) end

--
-- Test methods
--
print "---------"
print "A methods"
print "---------"
a = A("s")
a:ps()			-- should print "s"
print(a:is_a(A))	-- should print true 
print(a.is_a(B))	-- should print false
print("")

print "---------"
print "B methods"
print "---------"
b = B("one","two")
b:ps()			-- should print "one"
b:ps1()			-- should print "two"
print(b:is_a(A))	-- should print true
print(b:is_a(B))	-- should print true
print("")

