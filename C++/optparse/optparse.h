#include <string>
#include <vector>

class OptParser
{
public:
	static std::vector<std::string> split(const std::string &s, char delim);
	static std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);
};
