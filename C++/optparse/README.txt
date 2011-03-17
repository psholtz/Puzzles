This class represents my hack-ish attempt to emulate the optparse library available on platforms like Ruby or Python.

An example of how to use the class would be as follows:

Suppose we have two integer attributes, and one string attribute, to be supplied on the command line.

+++++++++++++++++++++++++++++++++
#include <iostream>
#include "optparse.h"

using namespace std;

int 
main(int argc, char* argv[])
{
	// configure the attributes needed from command line
	OptParser o(argc,argv);
	o.prepare_to_start_attributes();
	o.add_integer_attribute("w","width","(optional)",10);
	o.add_integer_attribute("h","height","(optional)",10);
	o.add_string_attribute("s","string","(optional)","default");
	o.prepare_to_end_attributes();

	if ( o.parse() ) {
		// if the parse went OK, the command line args 
		// can be accessed by appropriate APIs
		cout << "parse good" << endl;
		cout << "width: " << b.get_integer_attribute("w") << ", height: " << b.get_integer_attribute("h") << ", string: " << b.get_string_attribute("s") << endl;
	} else {
		// otherwise, dump the usage info to console
		o.usage();
	}

	return 0;
}
+++++++++++++++++++++++++++++++++
