#include <string>
#include <vector>

class OptParser
{
public:
	OptParser(int argc, char* argv[]);
	~OptParser();

	void prepare_to_start_attributes();
	void prepare_to_end_attributes();

	void usage();

	static std::vector<std::string> split(const std::string &s, char delim);

protected:
	void append_to_usage(std::string s);

	std::string _scriptName;
	std::vector<std::string> _usage;

private:
	static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);
};
