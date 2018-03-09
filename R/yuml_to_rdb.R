#' @importFrom magrittr "%>%"
NULL

#' @export
yuml_to_rdb = function(data_model_dir) {
  cat_yuml.sh = system.file("bash/cat_yuml.sh", package = "yumltordbschema")
  system2(cat_yuml.sh, data_model_dir)

	yuml_lines = r_datamodel_sdb(data_model_dir) %>% 
    rutils::grepv("\\|")
	ydm = build_yuml_data_model(yuml_lines)
	den = update_new_entities(ydm)
  dfl = update_new_fields(ydm, den)

  write_yuml_data_model(ydm, data_model_dir = data_model_dir)
  write_data_entity(den, data_model_dir)
  write_data_field(dfl, data_model_dir)
  return(list(data_entity = den, data_field = dfl))
}

#' @export
build_yuml_data_model = function(yuml_lines) {
	ydm = yuml_lines %>%
		stringr::str_replace_all( "^[ \\[]*", "" ) %>%
		stringr::str_replace_all( "[ \\]]*$", "" ) %>%
		stringr::str_replace_all( "\\|\\s*", "\\|" ) %>%
		stringr::str_replace_all( ";\\s*", ";" ) %>%
		dplyr::data_frame( ln = . ) %>%
		tidyr::separate( ln, c("entity_name", "columns"), "\\|" ) %>%
		tidyr::unnest( columns = strsplit( columns, ";") ) %>%
    tidyr::separate( columns, c("data_field_name", "type", "pk_fk", "not_null"), " "  ) %>%
    dplyr::mutate( pk_fk = ifelse( is.na(pk_fk), "NON_KEY", pk_fk)) %>%
    dplyr::mutate( type = ifelse( is.na(type), "TEXT", type)) %>%
    dplyr::mutate( not_null = ifelse( is.na(not_null), FALSE, TRUE)) %>%
    dplyr::mutate( entity_name = tolower(entity_name) ) %>%
    dplyr::mutate( data_field_name = tolower(data_field_name) ) 
  verify_no_reserved_words_used(ydm)
  return(ydm)
}

#' @export
update_new_entities = function(ydm) {
	den = ydm %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::select( entity_name ) %>%
    dplyr::mutate( data_entity_id = row_number() ) %>%
		dplyr::select( data_entity_id, dplyr::everything() )
  return(den)
}

#' @export
update_new_fields = function(ydm, den) {
  # dfl
  # den
  dfl_p1 = ydm %>%
    dplyr::inner_join( den, by = "entity_name" ) %>%
    dplyr::select(-entity_name) %>%
    dplyr::mutate( data_field_id = row_number() ) %>%
    dplyr::select( data_field_id, dplyr::everything() )
  dfl_fk_id = dfl_p1 %>%
    dplyr::select( data_field_id, data_field_name, pk_fk ) %>%
    dplyr::filter( pk_fk == "FK" ) %>%
    dplyr::filter( rutils::greplm( data_field_name, "_id$") ) %>%
    dplyr::mutate( fk_data_entity_name = stringr::str_sub(data_field_name, end = -4)) %>%
    dplyr::select( data_field_id, fk_data_entity_name ) 
  dfl_fk_enum = dfl_p1 %>%
    dplyr::select( data_field_id, data_field_name, pk_fk ) %>%
    dplyr::filter( pk_fk == "FK" ) %>%
    dplyr::mutate( enum_var_name = data_field_name) %>%
    dplyr::filter( rutils::greplm( data_field_name, "_enum$") ) %>%
    dplyr::mutate( fk_data_entity_name = "enum_value") %>%
    dplyr::select( data_field_id, fk_data_entity_name, enum_var_name ) 
  den_id = den %>%
    dplyr::select( data_entity_id, entity_name )
  dfl_fk = dplyr::bind_rows(dfl_fk_id, dfl_fk_enum) %>%
    dplyr::left_join( den_id, by = c("fk_data_entity_name" = "entity_name") ) %>%
    dplyr::select(-fk_data_entity_name) %>%
    dplyr::select(data_field_id, fk_data_entity_id = data_entity_id, dplyr::everything()) 
  dfl = dfl_p1 %>%
    dplyr::left_join( dfl_fk, by = "data_field_id" )
    
  return(dfl)
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
#  yuml_to_rdb(data_model_dir)
#}


