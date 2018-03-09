
main_ddl_to_data = function() {
  data_model_dir = setenv_osx()
  io_write_enum_var(data_model_dir)
  ddl_to_data.sh = system.file("bash/ddl_to_data.sh", package = "yumltordbschema")
  data_model_dir = setenv_osx()
  system2(ddl_to_data.sh, data_model_dir)
}

io_write_enum_var = function(data_model_dir) {
  evl = read_enum_value(data_model_dir)
  evr = read_enum_var(data_model_dir)
  m = get_enum_var_name_to_id(evl, evr)
  for (evn in names(m)) {
    writeLines(as.character(m[[evn]])
               , sprintf("%s/data/view/%s.txt"
                         , data_model_dir, evn))
  }
}

get_enum_var_name_to_id = function(evl, evr) {
  get_enum_value_id_by = function(evn, evl_evr) {
    evl_evr %>%
      dplyr::filter(enum_var_name == evn) %>%
      magrittr::extract2("enum_value_id")
  }
  evl_evr = evl %>%
    dplyr::left_join(evr, by = "enum_var_id") 
  lapply(unique(evl_evr$enum_var_name), get_enum_value_id_by, evl_evr) %>%
    setNames(unique(evl_evr$enum_var_name))
}

io_write_entity_id = function(data_model_dir) {
  # @deprecated
  entity_names = c("enum_var", "enum_value")
  data_entities = lapply(entity_names, r_entity, data_model_dir) %>%
    setNames(entity_names)
  m = get_entity_name_to_id(data_entities)
  for (en in entity_names) {
    writeLines(as.character(m[[en]])
               , sprintf("%s/data/view/%s.txt"
                         , data_model_dir, sprintf("%s_id", en)))
  }
}

get_entity_name_to_id = function(data_entities) {
  by_name_by_id = function(entity_name, data_entities) {
    id_var = sprintf("%s_id", entity_name)
    data_entities[[entity_name]][[id_var]]
  }
  lapply(names(data_entities), by_name_by_id, data_entities) %>%
    setNames(names(data_entities))
  # rutils::lnapply(data_entities, by_name_by_id) 
}

rdb_to_id_entity = function(data_model_dir, entity_names) {
  for (entity_name in entity_names) {
    id_var = sprintf("%s_id", entity_name)
    id_data = data_entities[[entity_name]][[id_var]]
    writeLines(as.character(id_data), sprintf("%s/data/view/id_%s.txt", data_model_dir, entity_name))
  }
}
