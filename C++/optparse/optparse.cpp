#include <iostream>
#include <sstream>
#include "optparse.h"

using namespace std;

/****************************************************
 * Constructor. 
 * 
 * @Parameter: argc - argument passed into main()
 * @Parameter: argv[] - argument passed into main()
 ****************************************************/
OptParser::OptParser(int argc, char *argv[]) 
{
	if ( argc >= 1 ) {
		// (1) obtain the script name
		vector<string> a = OptParser::split(string(argv[0]),'/');
		_scriptName = a[a.size()-1];

		// (2) begin building the usage string
		_usage.push_back("Usage: " + _scriptName + " [options]");
	}
}

OptParser::~OptParser()
{

}

void
OptParser::prepare_to_start_attributes()
{
	append_to_usage("");
}

void 
OptParser::prepare_to_end_attributes()
{
	append_to_usage("");
}

/*********************************************************************
 *  Once the attributes have been configured, and the object
 *  has been initialized with the information form the command
 *  line, parse this information into discrete data structures.
 *
 * @Returns: bool - true indicates successful parse, false otherwise
 *********************************************************************/
bool
OptParser::parse()
{
	return true; 
}

/*************************************
 * Dump usage information to console.
 *************************************/
void
OptParser::usage()
{
	for ( int i=0; i < _usage.size(); ++i ) 
		cout << _usage[i] << endl;
}

/********************************************
 * Add the string to the usage information.
 * 
 * @Paramter: s - string to add to usage.
 ********************************************/
void 
OptParser::append_to_usage(string s)
{
	_usage.push_back(s);	
}

/***************************************************************
 * Designed to provide services similar to string.split() 
 * available on platforms like Ruby or Python.
 *  
 *  vector<string> a = OptParser::split("this:that",':');
 * 
 * will return the vector {"this","that"}.
 *
 * This method does not skip empty tokens, so the following
 * will return four items, one of which is empty:
 * 
 *  vector<string> a = OptParser::split("one:two::three",':');
 *
 * @Parameter: s - string to parse
 * @Parameter: delim - character token to split on
 * @Returns: vector compromised of string parsed on token
 ***************************************************************/
vector<string>
OptParser::split(const string &s, char delim)
{
	vector<string> elems;
	return split(s,delim,elems);
}

/*****************************************************
 * Private helper method to the above split() method.
 *****************************************************/
vector<string> &
OptParser::split(const string &s, char delim, vector<string> &elems)
{
	stringstream ss(s);
	string item;
	while ( getline(ss,item,delim) ) {
		elems.push_back(item);
	}
	return elems;
}
 
int
main(int argc, char* argv[])
{
	OptParser b(argc,argv);
	b.prepare_to_start_attributes();
	b.prepare_to_end_attributes();

	b.usage();

	return 0;
}
