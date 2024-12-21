```shell
$ docker build --tag duckdb-build-wasm ../.. -f ./Dockerfile
$ docker create --name temp duckdb-build-wasm
$ docker cp temp:/workspace/sayhello.duckdb_extension.wasm .
$ docker rm temp
```
