#include <iostream>
#include <sstream>
#include "optparse.h"

using namespace std;

vector<string>
OptParser::split(const string &s, char delim)
{
	vector<string> elems;
	return split(s,delim,elems);
}

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
	vector<string> a = OptParser::split("this:that",':');
	cout << a.size() << endl;
	cout << a[0] << endl;
	cout << a[1] << endl;
	return 0;
}
