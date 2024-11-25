[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build and test](https://github.com/maropu/duckdb_extension_example/actions/workflows/build_and_tests.yml/badge.svg)](https://github.com/maropu/duckdb_extension_example/actions/workflows/build_and_tests.yml)

This repository shows you how to implement a simple table function for saying hello in DuckDB.
If you look for a general DuckDB extension template, please see [duckdb/extension-template](https://github.com/duckdb/extension-template).

# Minimum Required Components

```bash
.
|-- CMakeLists.txt                  // Root CMake build file
|-- Makefile                        // Build script to wrap cmake
|-- src
|   |-- CMakeLists.txt              // CMake build file to list source files
|   |-- include
|   |   `-- sayhello.hpp            // Header file for this extension
|   |-- sayhello.cpp                // Table function implementation
|   `-- sayhello_extension.cpp      // Entrypoint where DuckDB loads this extension
`-- test
    `-- sql
        `-- sayhello.test           // Test code
```

# Running this example

```bash
$ make duckdb
Cloning into 'duckdb'...
...
Note: switching to 'tags/v1.1.3'.
...

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

# Any Question?

If you have any question, please feel free to leave it on [Issues](https://github.com/maropu/duckdb_extension_example/issues)
or Twitter ([@maropu](http://twitter.com/#!/maropu)).
