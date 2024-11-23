//===----------------------------------------------------------------------===//
//                         DuckDB
//
// sayhello.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb.hpp"

namespace duckdb {

#define SAYHELLO_EXTENSION_VERSION "1.0.0"

struct SayHelloBindData : public TableFunctionData {
	explicit SayHelloBindData() {
	}

	static const string DEFAULT_SAYHELLO_TARGET;

	string target = DEFAULT_SAYHELLO_TARGET;
	bool finished = false;
};

struct SayHelloFunction {
	static void RegisterFunction(DatabaseInstance &db);
};

} // namespace duckdb
