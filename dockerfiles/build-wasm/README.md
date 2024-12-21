```shell
$ docker build --tag duckdb-build-wasm ../.. -f ./Dockerfile
$ docker create --name t duckdb-build-wasm
$ docker cp t:/workspace/sayhello.duckdb_extension.wasm .
$ docker rm t
```
