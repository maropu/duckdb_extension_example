 - Start a http server for duckdb-wasm:

```
$ docker build --tag duckdb-wasm .
$ docker create -p 8080:8080 --name duckdb-wasm-app duckdb-wasm
$ docker cp ../../assembly/duckdb-wasm/v1.1.1/wasm_eh/sayhello.duckdb_extension.wasm duckdb-wasm-app:/workspace/duckdb-wasm/packages/duckdb-wasm-app/build/release/extension_repository/v1.1.1/wasm_eh
$ docker start duckdb-wasm
```

 - Access http://127.0.0.1:8080/ and the load the extension as follows:

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
