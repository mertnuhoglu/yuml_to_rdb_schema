#' @export
r_datamodel_sdb = function(data_model_dir = env_data_model_dir()) {
	readLines(sprintf("%s/data/view/datamodel_sdb.yuml", data_model_dir))
}

read_yuml_data_model = function(data_model_dir = env_data_model_dir()) {
  readr::read_csv(sprintf("%s/data/view/yuml_data_model.csv", data_model_dir))
}

write_yuml_data_model = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/data/view/yuml_data_model.csv", data_model_dir))
}

read_enum_value = function(data_model_dir = env_data_model_dir()) {
  rio::convert(sprintf("%s/../rdb/enum_value.xlsx", data_model_dir), sprintf("%s/../rdb/enum_value.tsv", data_model_dir))
  rio::import(sprintf("%s/../rdb/enum_value.xlsx", data_model_dir))
}

write_enum_value = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/../rdb/enum_value.xlsx", data_model_dir))
  rio::convert(sprintf("%s/../rdb/enum_value.xlsx", data_model_dir), sprintf("%s/../rdb/enum_value.tsv", data_model_dir))
}

read_enum_var = function(data_model_dir = env_data_model_dir()) {
  rio::convert(sprintf("%s/../rdb/enum_var.xlsx", data_model_dir), sprintf("%s/../rdb/enum_var.tsv", data_model_dir))
  rio::import(sprintf("%s/../rdb/enum_var.xlsx", data_model_dir))
}

write_enum_var = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/../rdb/enum_var.xlsx", data_model_dir))
  rio::convert(sprintf("%s/../rdb/enum_var.xlsx", data_model_dir), sprintf("%s/../rdb/enum_var.tsv", data_model_dir))
}

r_entity = function(entity, data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/../rdb/%s.xlsx", data_model_dir, entity))
}

r_data_entity = function(...) {
  read_data_entity(...)
}

read_data_entity = function(data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/data/view/data_entity.tsv", data_model_dir))
}

write_data_entity = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/data/view/data_entity.tsv", data_model_dir))
}

r_data_field = function(...) {
  read_data_field(...)
}

read_data_field = function(data_model_dir = env_data_model_dir()) {
  rio::import(sprintf("%s/data/view/data_field.tsv", data_model_dir))
}

write_data_field = function(df, data_model_dir = env_data_model_dir()) {
  rio::export(df, sprintf("%s/data/view/data_field.tsv", data_model_dir))
}

