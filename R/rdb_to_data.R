insert_sql_template = function( entity, columns ) {
	template = "INSERT INTO %s (%s) VALUES (%s);"
	column_names = columns %>% paste(collapse=",")
	data_placeholders = rep( "'%s'", length(columns ) ) %>% paste(collapse=",") 
	result = sprintf( template, entity, column_names, data_placeholders )
	return(result)
}

insert_sql = function( data, template ) {
	arg = c( list(template), as.list(data) )
	do.call( 'sprintf', arg ) %>%
		stringr::str_replace_all( "'NA'", "null" )
}

sql_insert = function(df, entity) {
	template_df = dplyr::data_frame( entity = entity, insert_template = insert_sql_template(entity, names(df) ))
	insert_sql( df, template_df$insert_template )
}

delete_sql = function( df, template ) {
	arg = c( list(template), as.list(df) )
	do.call( 'sprintf', arg ) 
}

delete_sql_template = function( entity, id_column) {
	template = "DELETE FROM %s WHERE %s = %%s;"
	sprintf( template, entity, id_column)
}

sql_delete = function(df, entity) {
	template = dplyr::data_frame( entity= entity, delete_template = delete_sql_template(entity, names(df) ))
	delete_sql( df, template$delete_template )
}

update_sql = function( data, template ) {
	arg = c( list(template), as.list(data) )
	do.call( 'sprintf', arg ) %>%
		stringr::str_replace_all( "'\\bNA\\b'", "null" ) 
}

update_sql_template = function( entity, columns ) {
	template = "    UPDATE %s SET %s WHERE %s = %%s;"
	columns_to_set = head(columns, -1)
	set_column_clause = sprintf("%s = '%%s'", columns_to_set) %>% 
		paste(collapse=", ")
  id_column = tail(columns, 1)
	sprintf( template, entity, set_column_clause, id_column )
}

sql_update = function(df, entity) {
	template = dplyr::data_frame( entity= entity, update_template = update_sql_template(entity, names(df) ))
	update_sql( df, template$update_template )
}

build_sql = function(df, entity, id_column, den) {
  df_id_at_end = df %>%
		dplyr::select( -dplyr::one_of(id_column), dplyr::everything(), id_column )
  df_no_fk = dplyr::select( df, -dplyr::ends_with("_id"), id_column) %>%
    dplyr::select( id_column, dplyr::everything() )
  if ( any("invalid" %in% names(df)) ) {
    df_invalid = df %>%
      dplyr::filter( invalid == 1 ) %>%
      dplyr::select(id_column)
  } else {
    df_invalid = df %>%
      dplyr::select(id_column)
  }
  list(
       sql_insert = sql_insert( df, entity )
       , sql_update = sql_update( df_id_at_end, entity )
       , sql_insert_no_fk = sql_insert( df_no_fk, entity )
       , sql_delete = sql_delete( df_invalid, entity )
       )
}

rdb_to_data = function(entity, data_entities, dfl, den) {
  dflf = dfl %>%
    dplyr::left_join(den, by = "data_entity_id") %>%
    dplyr::filter(entity_name == entity) 
  columns = dflf$data_field_name
  id_column = dflf %>%
    dplyr::filter(pk_fk == "PK") %>%
    magrittr::extract2("data_field_name")
	df = data_entities[[entity]] %>%
    dplyr::select_(.dots = columns)
	build_sql(df, entity, id_column, den)
}

main_build_data_sql = function() {
  data_model_dir = setenv_osx()
  entities = c("enum_var", "enum_value")
  data_entities = lapply(entities, r_entity, data_model_dir) %>%
    setNames(entities)
  dfl = read_data_field(data_model_dir)
  den = read_data_entity(data_model_dir)
  ent_m_cmdtype_m_cmds = lapply( entities, rdb_to_data, data_entities, dfl, den) %>%
    setNames(entities)

  for (entity in names(ent_m_cmdtype_m_cmds)) {
    cmdtype_m_cmds = ent_m_cmdtype_m_cmds[[entity]]
    for (cmdtype in names(cmdtype_m_cmds)) {
       writeLines( cmdtype_m_cmds[[cmdtype]], rutils::sprintf_path("%s/data/sql/%s/%s_%s.sql", data_model_dir, cmdtype, cmdtype, entity) )
    }
  }

}

