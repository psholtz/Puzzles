#!./lua5.1

dofile '../../oo/classlib.lua'

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

class.C(B)
function C:__init(s,s1,s2)
 	self.B:__init(s,s1)
	self.s2 = s2
end

--
-- Test methods
--
print "---------"
print "A methods"
print "---------"
a = A("s")
a:ps()
print(a:is_a(A))
print(a.is_a(B))
print("")

print "---------"
print "B methods"
print "---------"
b = B("one","two")
b:ps()
print(b:is_a(A))
print(b:is_a(B))
print("")

print "----------"
print "C1 methods"
print "----------"
c1 = C("one")
c1:ps()
c1:ps1()
print("")

print "----------"
print "C2 methods"
print "----------"
c2 = C("one","two")
c2:ps()
c2:ps1()

