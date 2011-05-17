#!./lua5.1

dofile "../oo/classlib.lua"	-- provides object inheritance services

class.Option()
function Option:__init()
	 print("building option")
end

class.OptionParser()
function OptionParser:__init()
	 print("building parser")
end

parser = OptionParser()
