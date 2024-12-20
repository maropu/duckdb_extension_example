FROM  ubuntu:24.04

WORKDIR /workspace

# Install necessary basic packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    python3 \
    ccache \
    git \
    wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.0/cmake-3.30.0.tar.gz && \
  tar -xzf cmake-3.30.0.tar.gz && \
  cd cmake-3.30.0 && \
  ./bootstrap && \
  make && \
  make install

# Install emscripten
RUN git clone https://github.com/emscripten-core/emsdk.git && \
  cd emsdk && \
  ./emsdk install 3.1.57 && \
  ./emsdk activate 3.1.57

# Copy extension code into image
COPY Makefile duckdb_extension_example/
COPY CMakeLists.txt duckdb_extension_example/
COPY duckconfigure duckdb_extension_example/
COPY src duckdb_extension_example/src

# Compile extension
RUN cd duckdb_extension_example && \
  sed -i 's/DUCKDB_VERSION = 1.1.3/DUCKDB_VERSION = 1.1.1/g' Makefile && \
  make duckdb && \
  PATH=$PATH:/workspace/emsdk/upstream/emscripten make wasm_eh

# Copy assembly into the top
RUN cp duckdb_extension_example/build/wasm_eh/extension/sayhello/sayhello.duckdb_extension.wasm .
