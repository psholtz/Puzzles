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
	void add_integer_attribute();
	void add_string_attribute();
	void prepare_to_end_attributes();

	//
	// "Main" methods of this class.
	//
	void parse();
	void usage();

	static std::vector<std::string> split(const std::string &s, char delim);

protected:
	void append_to_usage(std::string s);

	std::string _scriptName;
	std::vector<std::string> _usage;

private:
	static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);
};
