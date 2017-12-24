#' @importFrom magrittr "%>%"
NULL

#' @export
build_rdb_data = function(data_model_dir) {
	# @prerequisite: run build_datamodel_sdb to have ../../data_models/data/view/datamodel_sdb.yuml
  build_datamodel_sdb.sh = system.file("bash/build_datamodel_sdb.sh", package = "yumltordbschema")
  system2(build_datamodel_sdb.sh, data_model_dir)

	build_yuml_data_model(data_model_dir)
	yden = update_new_entities(data_model_dir)
  ydfl = update_new_fields(yden, data_model_dir)
  return(list(data_entity = yden, data_field = ydfl))
}

#' @export
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
    dplyr::mutate( type = ifelse( is.na(type), "TEXT", type)) %>%
    dplyr::mutate( entity_name = tolower(entity_name) ) %>%
    dplyr::mutate( data_field_name = tolower(data_field_name) ) 
  verify_no_reserved_words_used(ydm)
  write_yuml_data_model(ydm, data_model_dir = data_model_dir)
}

#' @export
update_new_entities = function(data_model_dir) {
	ydm = read_yuml_data_model(data_model_dir)
	yden = ydm %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::select( entity_name ) %>%
    dplyr::mutate( data_entity_id = row_number() ) %>%
		dplyr::select( data_entity_id, dplyr::everything() )
	path = sprintf("%s/data/view/yuml_data_entity.tsv", data_model_dir)
	rio::export( yden, path)
  return(yden)
}

#' @export
update_new_fields = function(yden, data_model_dir) {
  # dfl
  # den
	ydm = read_yuml_data_model()
	ydfl = ydm %>%
		dplyr::inner_join( yden, by = "entity_name" ) %>%
    dplyr::select(-entity_name) %>%
    dplyr::mutate( data_field_id = row_number() ) %>%
		dplyr::select( data_field_id, dplyr::everything() )
  ydfl_fk_id = ydfl %>%
		dplyr::select( data_field_id, data_field_name, pk_fk ) %>%
		dplyr::filter( pk_fk == "FK" ) %>%
		dplyr::filter( rutils::greplm( data_field_name, "_id$") ) %>%
		dplyr::mutate( fk_data_entity_name = stringr::str_sub(data_field_name, end = -4)) %>%
		dplyr::select( data_field_id, fk_data_entity_name ) 
  ydfl_fk_enum = ydfl %>%
		dplyr::select( data_field_id, data_field_name, pk_fk ) %>%
		dplyr::filter( pk_fk == "FK" ) %>%
		dplyr::mutate( enum_var_name = data_field_name) %>%
		dplyr::filter( rutils::greplm( data_field_name, "_enum$") ) %>%
		dplyr::mutate( fk_data_entity_name = "enum_value") %>%
		dplyr::select( data_field_id, fk_data_entity_name, enum_var_name ) 
  yden_id = yden %>%
    dplyr::select( data_entity_id, entity_name )
  ydfl_fk = dplyr::bind_rows(ydfl_fk_id, ydfl_fk_enum) %>%
    dplyr::left_join( yden_id, by = c("fk_data_entity_name" = "entity_name") ) %>%
    dplyr::select(-fk_data_entity_name) %>%
    dplyr::select(data_field_id, fk_data_entity_id = data_entity_id, dplyr::everything()) 
  ydfl2 = ydfl %>%
    dplyr::left_join( ydfl_fk, by = "data_field_id" )
    
	path = sprintf("%s/data/view/yuml_data_field.tsv", data_model_dir)
	rio::export( ydfl2, path)
  return(ydfl2)
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


