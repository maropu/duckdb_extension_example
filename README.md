[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build and test](https://github.com/maropu/duckdb_extension_example/actions/workflows/build_and_tests.yml/badge.svg)](https://github.com/maropu/duckdb_extension_example/actions/workflows/build_and_tests.yml)

This repository shows you how to implement a simple table function for saying hello in DuckDB.
If you look for a general DuckDB extension template, please see [duckdb/extension-template](https://github.com/duckdb/extension-template).

# Minimum Required Components

```bash
.
|-- CMakeLists.txt                  // Root CMake build file
|-- Makefile                        // Build script to wrap cmake
|-- duckdb                          // DuckDB source files
|-- extension_config.cmake          // Extension configure file included by DuckDB's build system
|-- makefiles
|   `-- duckdb_extension.Makefile   // common build configuration to compile extention, copied from `duckdb/extension-ci-tools`
|-- src
|   |-- CMakeLists.txt              // CMake build file to list source files
|   |-- include
|   |   `-- sayhello.hpp            // Header file for this extension
|   |-- sayhello.cpp                // Table function implementation
|   `-- sayhello_extension.cpp      // Entrypoint where DuckDB loads this extension
|-- test
|   `-- sql
|       `-- sayhello.test           // Test code
`-- vcpkg.json                      // Dependency definition file
```

# How to run this example

```shell
$ git submodule init
$ git submodule update
$ DUCKDB_GIT_VERSION=v1.1.3 make set_duckdb_version
$ make
mkdir -p build/release && \
	cmake  -DEXTENSION_STATIC_BUILD=1 -DDUCKDB_EXTENSION_NAMES="sayhello" -DDUCKDB_EXTENSION_SAYHELLO_PATH="/Users/maropu/Repositories/duckdb/duckdb_extension_example/" -DDUCKDB_EXTENSION_SAYHELLO_SHOULD_LINK=0 -DDUCKDB_EXTENSION_SAYHELLO_LOAD_TESTS=1 -DDUCKDB_EXTENSION_SAYHELLO_TEST_PATH="/Users/maropu/Repositories/duckdb/duckdb_extension_example/test/sql" -DDUCKDB_EXTENSION_SAYHELLO_EXT_VERSION="1.0.0" -DOSX_BUILD_ARCH=  -DDUCKDB_EXPLICIT_PLATFORM='' -DCMAKE_BUILD_TYPE=Release -S ./duckdb/ -B build/release && \
	cmake --build build/release --config Release
-- git hash 19864453f7, version v1.1.3, extension folder v1.1.3
-- Extensions will be deployed to: /Users/maropu/Repositories/duckdb/duckdb_extension_example/build/release/repository
-- Load extension 'sayhello' from '/Users/maropu/Repositories/duckdb/duckdb_extension_example/'
-- Load extension 'parquet' from '/Users/maropu/Repositories/duckdb/duckdb_extension_example/duckdb/extensions' @ v1.1.3
-- Extensions linked into DuckDB: [parquet]
-- Extensions built but not linked: [sayhello]
-- Tests loaded for extensions: [sayhello]
-- Configuring done
-- Generating done
-- Build files have been written to: /Users/maropu/Repositories/duckdb/duckdb_extension_example/build/release
[  0%] Building CXX object third_party/hyperloglog/CMakeFiles/duckdb_hyperloglog.dir/hyperloglog.cpp.o
[  0%] Building CXX object third_party/hyperloglog/CMakeFiles/duckdb_hyperloglog.dir/sds.cpp.o
...
[ 99%] Building CXX object third_party/imdb/CMakeFiles/imdb.dir/imdb.cpp.o
[100%] Linking CXX static library libimdb.a
[100%] Built target imdb

$ make test
...
[1/1] (100%): test/sql/sayhello.test
===============================================================================
All tests passed (4 assertions in 1 test case)

$ duckdb -unsigned
v1.1.3 19864453f7
Enter ".help" for usage hints.
D LOAD './build/release/extension/sayhello/sayhello.duckdb_extension';
D SELECT * FROM sayhello();
┌────────────────┐
│     Output     │
│    varchar     │
├────────────────┤
│ Hello, DuckDB! │
└────────────────┘
```

# How to compile as WebAssembly code

```shell
// Compile as WebAssembly code
$ cd dockerfiles/build-wasm
$ docker build --tag duckdb-build-wasm ../.. -f ./Dockerfile
$ docker create --name t duckdb-build-wasm
$ docker cp t:/workspace/sayhello.duckdb_extension.wasm .
$ docker rm t

// Start a http server for duckdb-wasm
cd ../duckdb-wasm
$ docker build --tag duckdb-wasm .
$ docker create -p 8080:8080 --name duckdb-wasm-app duckdb-wasm
$ docker cp ../build-wasm/sayhello.duckdb_extension.wasm duckdb-wasm-app:/workspace/duckdb-wasm/packages/duckdb-wasm-app/build/release/extension_repository/v1.1.1/wasm_eh
$ docker start duckdb-wasm-app
```

 - Access http://127.0.0.1:8080/ and then load the extension as follows:

```sql
DuckDB Web Shell
Database: v1.1.1
Package:  @duckdb/duckdb-wasm@1.11.0

Connected to a local transient in-memory database.
Enter .help for usage hints.

duckdb> SET custom_extension_repository='http://127.0.0.1:8080/extension_repository';
duckdb> LOAD sayhello;
duckdb> SELECT * FROM sayhello();
┌────────────────┐
│ Output         │
╞════════════════╡
│ Hello, DuckDB! │
└────────────────┘
```

# How to compile extensions for multiple platforms

[The DuckDB document](https://duckdb.org/docs/extensions/working_with_extensions.html#platforms) says that extention binaries need to be built for each platform.
To do so, you can use [duckdb/extension-ci-tools](https://github.com/duckdb/extension-ci-tools) to compile your extension for multiple platforms
and please see an actual CI job to compiile this extension in [maropu/extension-ci-tools](https://github.com/maropu/extension-ci-tools/actions/workflows/duckdb_extension_example.yml).

# Any Question?

If you have any question, please feel free to leave it on [Issues](https://github.com/maropu/duckdb_extension_example/issues)
or Twitter ([@maropu](http://twitter.com/#!/maropu)).
