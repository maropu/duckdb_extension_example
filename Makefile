.PHONY: all clean format debug release pull

all: release

DUCKDB_VERSION = 1.1.3

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJ_DIR := $(dir $(MKFILE_PATH))

DUCKDB_SRCDIR ?= "./duckdb/"

# For non-MinGW windows the path is slightly different
ifeq ($(OS),Windows_NT)
	TEST_PATH="/test/Release/unittest.exe"
else
	TEST_PATH="/test/unittest"
endif

#### OSX config
OSX_BUILD_FLAG=
ifneq (${OSX_BUILD_ARCH}, "")
	OSX_BUILD_FLAG=-DOSX_BUILD_ARCH=${OSX_BUILD_ARCH}
endif

#### Enable Ninja as generator
ifeq ($(GEN),ninja)
	GENERATOR=-G "Ninja" -DFORCE_COLORED_OUTPUT=1
endif

#### Configuration for this extension
EXTENSION_NAME=SAYHELLO
EXTENSION_VERSION=v1.0.0
EXTENSION_FLAGS=\
-DDUCKDB_EXTENSION_NAMES="sayhello" \
-DDUCKDB_EXTENSION_${EXTENSION_NAME}_PATH="$(PROJ_DIR)" \
-DDUCKDB_EXTENSION_${EXTENSION_NAME}_SHOULD_LINK=0 \
-DDUCKDB_EXTENSION_${EXTENSION_NAME}_LOAD_TESTS=1 \
-DDUCKDB_EXTENSION_${EXTENSION_NAME}_TEST_PATH="$(PROJ_DIR)test/sql" \
-DDUCKDB_EXTENSION_${EXTENSION_NAME}_EXT_VERSION="$(EXTENSION_VERSION)"

BUILD_FLAGS=-DEXTENSION_STATIC_BUILD=1 $(EXTENSION_FLAGS) $(OSX_BUILD_FLAG) $(TOOLCHAIN_FLAGS) -DDUCKDB_EXPLICIT_PLATFORM='${DUCKDB_PLATFORM}'

# Main build
debug: duckdb
	mkdir -p  build/debug && \
	cmake $(GENERATOR) $(BUILD_FLAGS) -DCMAKE_BUILD_TYPE=Debug -S $(DUCKDB_SRCDIR) -B build/debug && \
	cmake --build build/debug --config Debug

reldebug: duckdb
	mkdir -p build/reldebug && \
	cmake $(GENERATOR) $(BUILD_FLAGS) -DCMAKE_BUILD_TYPE=RelWithDebInfo -S $(DUCKDB_SRCDIR) -B build/reldebug && \
	cmake --build build/reldebug --config RelWithDebInfo

release: duckdb
	mkdir -p build/release && \
	cmake $(GENERATOR) $(BUILD_FLAGS) -DCMAKE_BUILD_TYPE=Release -S $(DUCKDB_SRCDIR) -B build/release && \
	cmake --build build/release --config Release

# Main tests
test: test_release
test_release: release
	./build/release/$(TEST_PATH) --test-dir "$(PROJ_DIR)" "test/*"
test_debug: debug
	./build/debug/$(TEST_PATH) --test-dir "$(PROJ_DIR)" "test/*"

# WASM config
WASM_COMPILE_TIME_COMMON_FLAGS=-DWASM_LOADABLE_EXTENSIONS=1 -DBUILD_EXTENSIONS_ONLY=1 $(TOOLCHAIN_FLAGS)
WASM_CXX_MVP_FLAGS=
WASM_CXX_EH_FLAGS=$(WASM_CXX_MVP_FLAGS) -fwasm-exceptions -DWEBDB_FAST_EXCEPTIONS=1
WASM_CXX_THREADS_FLAGS=$(WASM_COMPILE_TIME_EH_FLAGS) -DWITH_WASM_THREADS=1 -DWITH_WASM_SIMD=1 -DWITH_WASM_BULK_MEMORY=1 -pthread

# WASM targets
wasm_mvp:
	mkdir -p build/wasm_mvp
	emcmake cmake $(GENERATOR) $(EXTENSION_FLAGS) $(WASM_COMPILE_TIME_COMMON_FLAGS) -Bbuild/wasm_mvp -DCMAKE_CXX_FLAGS="$(WASM_CXX_MVP_FLAGS)" -S $(DUCKDB_SRCDIR) -DDUCKDB_EXPLICIT_PLATFORM=wasm_mvp -DDUCKDB_CUSTOM_PLATFORM=wasm_mvp
	emmake make -j8 -Cbuild/wasm_mvp

wasm_eh:
	mkdir -p build/wasm_eh
	emcmake cmake $(GENERATOR) $(EXTENSION_FLAGS) $(WASM_COMPILE_TIME_COMMON_FLAGS) -Bbuild/wasm_eh -DCMAKE_CXX_FLAGS="$(WASM_CXX_EH_FLAGS)" -S $(DUCKDB_SRCDIR) -DDUCKDB_EXPLICIT_PLATFORM=wasm_eh -DDUCKDB_CUSTOM_PLATFORM=wasm_eh
	emmake make -j8 -Cbuild/wasm_eh

wasm_threads:
	mkdir -p ./build/wasm_threads
	emcmake cmake $(GENERATOR) $(EXTENSION_FLAGS) $(WASM_COMPILE_TIME_COMMON_FLAGS) -Bbuild/wasm_threads -DCMAKE_CXX_FLAGS="$(WASM_CXX_THREADS_FLAGS)" -S $(DUCKDB_SRCDIR) -DDUCKDB_EXPLICIT_PLATFORM=wasm_threads -DDUCKDB_CUSTOM_PLATFORM=wasm_threads
	emmake make -j8 -Cbuild/wasm_threads

#### Misc
format:
	cp duckdb/.clang-format .
	find src/ -iname "*.hpp" -o -iname "*.cpp" | xargs clang-format --sort-includes=0 -style=file -i
	cmake-format -i CMakeLists.txt
	rm .clang-format

duckdb:
	./duckconfigure $(DUCKDB_VERSION)

clean:
	rm -rf build
	[ -d "duckdb" ] && (cd duckdb && make clean)
