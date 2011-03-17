#include <map>
#include <string>
#include <vector>

class OptParser
{
public:
	OptParser(int argc, char* argv[]);
	~OptParser();

	//
	// Attribute management.
	//
	void prepare_to_start_attributes();
	void add_integer_attribute(std::string keyShort, std::string keyLong, std::string desc, int defaultValue);
	void add_string_attribute(std::string keyShort, std::string keyLong, std::string desc, std::string defaultValue);
	void prepare_to_end_attributes();

	//
	// "Main" methods of this class.
	//
	bool parse();
	void usage();

	//
	// Obtain information supplied on command line.
	//
	int get_integer_attribute(std::string key);
	std::string get_string_attribute(std::string key);

	static std::vector<std::string> split(const std::string &s, char delim);

protected:
	void append_to_usage(std::string s);

	//
	// These methods are used mainly for testing
	//
	void display_attr_string();
	void display_attr_integer();
	void display_args();

	//
	// Hold the state of the object
	//
	std::string _scriptName;
	std::vector<std::string> _usage;
	std::map<std::string,int> _attrInt;
	std::map<std::string,std::string> _attrString;
	std::map<std::string,std::string> _mapLongToShort;
	std::vector<std::string> _args;
	std::map<std::string,std::string> _desc;

private:
	static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);
};
