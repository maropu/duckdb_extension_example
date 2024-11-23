#define DUCKDB_BUILD_LOADABLE_EXTENSION
#include "sayhello.hpp"

using namespace duckdb;

extern "C" {

DUCKDB_EXTENSION_API void sayhello_init(DatabaseInstance &db) {
	SayHelloFunction::RegisterFunction(db);
}

DUCKDB_EXTENSION_API const char *sayhello_version() {
	return SAYHELLO_EXTENSION_VERSION;
}

}
