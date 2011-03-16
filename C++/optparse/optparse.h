#include <string>
#include <vector>

class OptParser
{
public:
	OptParser(int argc, char* argv[]);
	~OptParser();

	static std::vector<std::string> split(const std::string &s, char delim);

protected:
	std::string _scriptName;

private:
	static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);
};
