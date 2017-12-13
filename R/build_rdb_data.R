#' @importFrom magrittr "%>%"
NULL

build_rdb_data = function(data_model_dir) {
	# @prerequisite: run build_datamodel_sdb to have ../../data_models/view/datamodel_sdb.yuml
  build_datamodel_sdb.sh = system.file("bash/build_datamodel_sdb.sh", package = "yumltordbschema")
  system2(build_datamodel_sdb.sh, data_model_dir)

	build_yuml_data_model(data_model_dir)
	yden = update_new_entities(data_model_dir)
  ydfl = update_new_fields(yden, data_model_dir)
  return(list(data_entity = yden, data_field = ydfl))
}

build_yuml_data_model = function(data_model_dir) {
	lines = r_datamodel_sdb(data_model_dir) %>% rutils::grepv("\\|")
	ydm = lines %>%
		stringr::str_replace_all( "^[ \\[]*", "" ) %>%
		stringr::str_replace_all( "[ \\]]*$", "" ) %>%
		stringr::str_replace_all( "\\|\\s*", "\\|" ) %>%
		stringr::str_replace_all( ";\\s*", ";" ) %>%
		dplyr::data_frame( ln = . ) %>%
		tidyr::separate( ln, c("entity_name", "columns"), "\\|" ) %>%
		tidyr::unnest( columns = strsplit( columns, ";") ) %>%
		tidyr::separate( columns, c("data_field_name", "type", "pk_fk"), " " ) %>%
    dplyr::mutate( pk_fk = ifelse( is.na(pk_fk), "NOT_KEY", pk_fk)) %>%
    dplyr::mutate( type = ifelse( is.na(type), "TEXT", type))
  verify_no_reserved_words_used(ydm)
  write_yuml_data_model(ydm, data_model_dir = data_model_dir)
}

update_new_entities = function(data_model_dir) {
	ydm = read_yuml_data_model(data_model_dir)
	yden = ydm %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::select( entity_name ) %>%
    dplyr::mutate( data_entity_aid = row_number() ) %>%
		dplyr::select( data_entity_aid, dplyr::everything() )
	path = sprintf("%s/view/yuml_data_entity.tsv", data_model_dir)
	rio::export( yden, path)
  return(yden)
}

update_new_fields = function(yden, data_model_dir) {
  # dfl
  # den
	ydm = read_yuml_data_model()
	ydfl = ydm %>%
		dplyr::inner_join( yden, by = "entity_name" ) %>%
    dplyr::select(-entity_name) %>%
    dplyr::mutate( data_field_aid = row_number() ) %>%
		dplyr::select( data_field_aid, dplyr::everything() )
	path = sprintf("%s/view/yuml_data_field.tsv", data_model_dir)
	rio::export( ydfl, path)
  return(ydfl)
}

study_na = function() {
  df = ydm[1:2, ]
  df %>%
    dplyr::mutate( type = ifelse( rutils::is_na(type), "TEXT", type))

}

#args = commandArgs(T)
#print(args)
#if( rutils::is.blank(args) ) {
#	print( "no args" )
#} else {
#  data_model_dir = Sys.getenv("DATA_MODEL_DIR")
#  build_rdb_data(data_model_dir)
#}


