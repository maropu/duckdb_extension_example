#include "sayhello.hpp"

#include "duckdb/main/extension_util.hpp"

namespace duckdb {

const string SayHelloBindData::DEFAULT_SAYHELLO_TARGET = "DuckDB";

static duckdb::unique_ptr<FunctionData> ExecuteBind(ClientContext &context, TableFunctionBindInput &input,
													vector<LogicalType> &return_types, vector<string> &names) {
	return_types.emplace_back(LogicalType::VARCHAR);
	names.emplace_back("Output");

	auto bind_data = make_uniq<SayHelloBindData>();

	if (!input.inputs.empty()) {
		bind_data->target = StringValue::Get(input.inputs[0]);
	} else {
		Value sayhello_target;
		if (context.TryGetCurrentSetting("sayhello_target", sayhello_target)) {
			bind_data->target = StringValue::Get(sayhello_target);
		}
	}

	return std::move(bind_data);
}

static void ExecuteFunction(ClientContext &context, TableFunctionInput &data_p, DataChunk &output) {
	auto &data = data_p.bind_data->CastNoConst<SayHelloBindData>();
	if (data.finished) {
		return;
	}

	output.SetCardinality(1);
	auto &out_vec = output.data[0];
	auto value = StringVector::AddString(out_vec, "Hello, " + data.target + "!");
	FlatVector::GetData<string_t>(out_vec)[0] = value;

	data.finished = true;
}

void SayHelloFunction::RegisterFunction(DatabaseInstance &db) {
	TableFunctionSet sayhello("sayhello");

	// For sayhello()
	TableFunction sayhello_func({}, ExecuteFunction, ExecuteBind);
	sayhello.AddFunction(sayhello_func);

	// For sayhello(arg1)
	sayhello_func.arguments = {LogicalType::VARCHAR};
	ExtensionUtil::RegisterFunction(db, sayhello_func);
	sayhello.AddFunction(sayhello_func);

	// Register the sayhello function set
	ExtensionUtil::RegisterFunction(db, sayhello);

	auto &config = DBConfig::GetConfig(db);
	config.AddExtensionOption("sayhello_target", "The target name of saying hello",
							  LogicalType::VARCHAR, Value(SayHelloBindData::DEFAULT_SAYHELLO_TARGET));
}

} // namespace duckdb
