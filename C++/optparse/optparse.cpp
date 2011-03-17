#include <ctype.h>
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

		// (3) add the remaining args to the _args array
		for ( int i=1; i < argc; ++i ) {
			_args.push_back(argv[i]);
		}
	}
}

OptParser::~OptParser()
{

}

/***************************************************************
 * Call this method before adding attributes to the OptParser.
 ***************************************************************/
void
OptParser::prepare_to_start_attributes()
{
	append_to_usage("");
}


/***************************************************************
 * Add an integer attribute to the parser.
 * 
 * @Parameter: keyShort - short version of the attribute.
 * @Parameter: keyLong - long version of the attribute.
 * @Parameter: desc - description of the attribute.
 * @Parameter: defaultValue - default value for the attribute.
 * 
 * For example, suppose we want to add an attribute called 
 * "width" to the parser. We might invoke this method as follows:
 * 
 *  add_integer_attribute("w","width","(optional)",10);
 * 
 * This would create an attribute such as:
 * 
 *  -w, --width=[value]	(optional)
 * 
 * and which has a default value of 10.
 ******************************************************************/
void 
OptParser::add_integer_attribute(string keyShort, string keyLong, string desc, int defaultValue)
{
	_attrInt.insert( pair<string,int>(keyShort,defaultValue) );
	_mapLongToShort.insert( pair<string,string>(keyLong,keyShort) );
	_desc.insert( pair<string,string>(keyShort,desc) );
	append_to_usage("\t-" + keyShort + ", --" + keyLong + "=[value] \t" + desc);
}

/*********************************************************************
 * Add a string attribute to the parser.
 * 
 * @Parameter: keyShort - short version of the attribute.
 * @Parameter: keyLong - long version of the attribute.
 * @Parameter: desc - description of the attribute.
 * @Parameter: defaultValue - default value for the attribute.
 *
 * See above for example of how to use, using integer attributes.
 *********************************************************************/
void 
OptParser::add_string_attribute(string keyShort, string keyLong, string desc, string defaultValue)
{
	_attrString.insert( pair<string,string>(keyShort,defaultValue) );
	_mapLongToShort.insert( pair<string,string>(keyLong,keyShort) );
	_desc.insert( pair<string,string>(keyShort,desc) );
	append_to_usage("\t-" + keyShort + ", --" + keyLong + "=[value] \t" + desc);
}

/***************************************************************
 * Call this method after adding attributes to the OptParser.
 ***************************************************************/
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
	for ( int i=0; i < _args.size(); ++i ) {
		string t = _args[i];
		cout << t << endl;

		//
		// (1a) Test for "short" key - test for the "string" key
		//
		for ( map<string,string>::iterator it = _attrString.begin(); it != _attrString.end(); ++it ) {
			if ( t.substr(0,2) == ("-" + (*it).first) ) {
				if ( t.substr(2).size() > 0 ) {
					_attrString[(*it).first] = t.substr(2);
					continue;		
				} else {
					//
					// if the string is length zero, it's not a value argument  
					//
					return false;
				}
			}
		}

		//
		// (1b) Test for "short" key -- test for the "integer" key
 		//
		for ( map<string,int>::iterator it = _attrInt.begin(); it != _attrInt.end(); ++it ) {
			if ( t.substr(0,2) == ("-" + (*it).first) ) {
				if ( t.substr(2).size() > 0 ) {
					//
					// check to make sure we are dealing with digits;
					// if not, return a false
					//
					string s = t.substr(2);	
					for ( int j=0; j < s.size(); ++j )  
						if (!isdigit(s[j])) 
							return false;

					_attrInt[(*it).first] = atoi(s.c_str());	
					continue;
				} else {
					// 
					// if the string is length zero, it's not a value argument
					//
					return false;
				}
			}
		}
	
		display_attr_string();
		display_attr_integer();

		//	
		// (2) If test for "short" key fails, test for "long" key

		// If both tests fail, return false 
		return false;
	}
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

/***********************************************************
 * Dump the contents of the _attrString member to console.
 ***********************************************************/
void
OptParser::display_attr_string()
{
	for ( map<string,string>::iterator it = _attrString.begin(); it != _attrString.end(); it++ ) {
		cout << (*it).first << " => " << (*it).second << endl;
	}
}


/***********************************************************
 * Dump the contents of the _attrInt member to console.
 ***********************************************************/
void
OptParser::display_attr_integer()
{
	for ( map<string,int>::iterator it = _attrInt.begin(); it != _attrInt.end(); it++ ) {
		cout << (*it).first << " => " << (*it).second << endl;
	}
}

/***********************************************************
 * Dump the contents of the _args member to console.
 ***********************************************************/
void
OptParser::display_args() 
{
	for ( int i=0; i < _args.size(); ++i ) 
		cout << i << " => " << _args[i] << endl;
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
	b.add_integer_attribute("w","width","(optional)",10);
	b.add_integer_attribute("h","height","(optional)",10);
	b.add_string_attribute("s","string","(optional)","xx");
	b.prepare_to_end_attributes();

	b.usage();

	if ( b.parse() ) {	
		cout << "parse good" << endl;
	} else {
		cout << "parse bad" << endl;
	}

	return 0;
}
