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

#' rdb/data_entity.tsv file is written manually
#' its source is: data/view/yuml_data_entity.tsv
#' @export
r_data_entity = function(data_model_dir = env_data_model_dir(), ...) {
  path = sprintf("%s/rdb/data_entity.tsv", data_model_dir)
  if (file.exists(path))
    readr::read_tsv(path)
  else
    data.frame(
      data_entity_id = integer(),
      entity_name = character(),
      entity_type = character(),
      invalid = integer()
    )
}

r_data_field = function(data_model_dir = env_data_model_dir(), ...) {
  path = sprintf("%s/rdb/data_field.tsv", data_model_dir)
  if (file.exists(path))
    rutils::import2(path, ...)
  else
    data.frame(
      data_field_id = integer(),
      data_field_name = character(),
      entity_name = character(),
      data_entity_id = integer(),
      enum_name = character(),
      enum_category_id = integer(),
      type = character(),
      pk_fk = character(),
      state = character(),
      description = character(),
      invalid = integer()
    )
}
