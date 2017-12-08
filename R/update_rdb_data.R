#!/usr/local/bin/Rscript
# <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/update_rdb_data.R>
# ss = function() { source("update_rdb_data.R") }

#source("utils_tekuis_rdb.R")
#source("data_verify.R")
#source("enums_verify.R")
#source("utils_verify.R")

#' @importFrom magrittr "%>%"
NULL

update_rdb_data = function() {
	update_rdb_data_step_1()
	update_rdb_data_step_2()
	update_rdb_data_step_3()
	update_rdb_data_step_4()
}

update_rdb_data_step_1 = function(data_model_dir) {
	# @prerequisite: run build_datamodel_sdb to have ../../data_models/view/datamodel_sdb.yuml
  build_datamodel_sdb.sh = system.file("bash/build_datamodel_sdb.sh", package = "yumltordbschema")
  system2(build_datamodel_sdb.sh, data_model_dir)
	verify_enum()
	verify_data()

	build_data_dictionary_01(data_model_dir)
	update_new_entities()
	# > data/view/dd2.tsv
  # put them into data_entity.tsv
  # give id to each new entity
}
update_rdb_data_step_2 = function() {
	verify_rdb_data_after_sync_step_1()
	# Note: First call update_rdb_data_step_1() else wrong data is produced
	update_new_fields()
	# > data/temp/dd9.tsv
}
update_rdb_data_step_3 = function() {
	verify_rdb_data_after_sync_step_2()
}
update_rdb_data_step_4 = function() {
	dfl = update_enum_name_in_DataField() %>%
		findout_fk_data_entity()
	# > data/updates/DataField_updated.tsv
}
update_rdb_data_step_5 = function() {
	# @deprecated
	dependency_ordering_of_db_tables()
}
update_rdb_data_step_6 = function() {
	# @deprecated
	export_delete_sql_script()
}
main = function() {
}

build_data_dictionary_01 = function(data_model_dir) {
	lines = r_datamodel_sdb.yuml(data_model_dir) %>% rutils::grepv("\\|")
	df = lines %>%
		stringr::str_replace_all( "^[ \\[]*", "" ) %>%
		stringr::str_replace_all( "[ \\]]*$", "" ) %>%
		stringr::str_replace_all( "\\|\\s*", "\\|" ) %>%
		stringr::str_replace_all( ";\\s*", ";" ) %>%
		dplyr::data_frame( ln = . ) %>%
		tidyr::separate( ln, c("entity_name", "columns"), "\\|" ) %>%
		tidyr::unnest( columns = strsplit( columns, ";") ) %>%
		tidyr::separate( columns, c("data_field_name", "type", "pk_fk"), " " )
  readr::write_csv(df, sprintf("%s/view/dd_01.csv", data_model_dir))
}

update_new_entities = function() { 
	dd = read_data_dictionary_01(data_model_dir)
	de = r_data_entity()
	assertthat::assert_that( rutils::all_nonna(de$data_entity_id) )
	dd2 = dd %>%
		dplyr::anti_join( de, by = "entity_name" ) %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::select( entity_name )
	path = sprintf("%s/view/dd2.tsv", data_model_dir)
	rio::export( dd2, path)
}

update_new_entities_step_2 = function() { # id=g_10016
	# update_new_entities = function() { <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/prepare_rdb_data_operations.R#r=g_10016>
	dd = read_data_dictionary_01()
	de = r_data_entity()
	assertthat::assert_that( rutils::all_nonna(de$data_entity_id) )
	dd3 = dd %>%
		inner_join( de, by = "entity_name" ) %>%
		arrange( entity_name ) %>%
		select( data_entity_id, entity_name )
	assertthat::assert_that( nrow(dd) == nrow(dd3) )
	export( dd3, "data/temp/dd3.tsv" )
}

findout_fk_data_entity = function(dfl) {
	den = r_data_entity() %>%
		select( data_entity_id, entity_name )
		
	fkd = r_data_field(with_invalid=T) %>%
		select( 1:2, pk_fk, in__fk_data_entity_name ) %>%
		filter( pk_fk == "FK" ) %>%
		filter( greplm( data_field_name, "_id$") ) %>%
		mutate( fk_data_entity_name = str_sub(data_field_name, end = -4) ) %>%
		mutate( fk_data_entity_name = ifelse( greplm(fk_data_entity_name, "enum$"), "EnumValue", fk_data_entity_name )) %>%
		mutate( fk_data_entity_name = ifelse( !greplm(fk_data_entity_name, "enum$"), tocamel(fk_data_entity_name, upper = T), fk_data_entity_name )) %>%
		mutate( fk_data_entity_name = ifelse( is_na(in__fk_data_entity_name), fk_data_entity_name, in__fk_data_entity_name)) 

	fkd2 = fkd %>%
		left_join( den, by = c( "fk_data_entity_name" = "entity_name") ) %>%
		rename( fk_data_entity_id = data_entity_id ) %>%
		select( data_field_id, fk_data_entity_id, fk_data_entity_name)

	#dfl = r_data_field(with_invalid=T) %>%
	dfl2 = dfl %>%
		select( -fk_data_entity_id, -fk_data_entity_name, -table_name, -fk_table_name ) %>%
		left_join(fkd2)

	# add fk_table_name and table_name
	den_table_name_fk = r_data_entity() %>%
		select( entity_name, table_name ) %>%
		rename( fk_table_name = table_name )
	den_table_name = r_data_entity() %>%
		select( data_entity_id, table_name ) 
	dfl3 = dfl2 %>%
		left_join( den_table_name_fk, by = c( "fk_data_entity_name" = "entity_name" ) ) %>%
		left_join( den_table_name, by = "data_entity_id" )
	export(dfl3, "data/updates/DataField_updated.tsv")
	file.copy( "../rdb_data.xlsx", "data/temp/backup_rdb_data.xlsx" )

	assert_all_have_attribute( dfl3, "fk_data_entity_id" )

	return(dfl3)
}

update_enum_name_in_DataField = function() {
	dfl = r_data_field(with_invalid=T) %>%
		select( -enum_name )
	enm = r_enum() %>%
		select( enum_category_id, enum_name )

	dfl_enm = dfl %>%
		left_join( enm, by = "enum_category_id" ) %>%
		arrange( entity_name, data_field_name ) %>%
		select( data_field_id:data_entity_id, enum_name, enum_category_id, everything() )

	export( dfl_enm, "data/temp/dfl_enm.tsv" )
	return(dfl_enm)
}

update_new_fields = function() { #  id=g_10017
	# update_new_fields = function() { <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/prepare_rdb_data_operations.R#r=g_10017>
	dfl = r_data_field(with_invalid=T) %>%
		select( -type, -entity_name, -pk_fk, -table_name ) 
	dd = read_data_dictionary_01()
	den = r_data_entity() %>%
		select( data_entity_id, entity_name, table_name )
	assertthat::assert_that( rutils::all_nonna(dfl$data_field_id) )
	dd3 = dd %>%
		inner_join( den, by = "entity_name" ) 
	assertthat::assert_that( rutils::all_nonna(dd3$data_field_id) )
	dd4 = dd3 %>%
		full_join( dfl, by = c("data_entity_id", "data_field_name") ) %>%
		mutate( state = NA )
	n1 = is.na(dd4$entity_name) 
	n2 = is.na(dd4$data_field_id) 
	n3 = !n1 & !n2
	assertthat::assert_that( none(n1 & n2) )
	assertthat::assert_that( (sum(n1) + sum(n2) + sum(n3)) == nrow(dd4) )
	dd5 = dd4 %>% 
		mutate( state = ifelse( n1, "deleted", dd4$state ) ) %>%
		mutate( invalid = ifelse( n1, 1, dd4$invalid ) ) 
	dd6 = dd5 %>%
		mutate( state = ifelse( n2, "added", dd5$state ) ) %>%
		mutate( invalid = ifelse( n2, 0, dd5$invalid ) ) 
	dd7 = dd6 %>%
		mutate( state = ifelse( !n1 & !n2, "existing", dd6$state ) ) 
	assertthat::assert_that( rutils::all_nonna(dd7$state) )

	# add entity_name to deleted records too
	den = r_data_entity(with_invalid=T) %>%
		select( data_entity_id, entity_name )
	dd8 = dd7 %>%
		select( -entity_name ) %>%
		left_join( den, by = "data_entity_id" ) %>%
		select( data_field_id, data_field_name, entity_name, data_entity_id, enum_name, enum_category_id,  invalid, everything() ) %>%
		distinct( entity_name, data_field_name, .keep_all = T) %>%
		arrange( entity_name, data_field_name )
	# @todo: assert_that
	writeLines( dd8$entity_name, "data/temp/errors.txt" )
	assertthat::assert_that( rutils::all_nonna(dd8$entity_name) )
	dd8[is.na(dd8$entity_name),]

	export( dd4, "data/temp/dd4.tsv" )
	export( dd8, "data/temp/dd8.tsv" )

	dd9 = dd8 %>%
		mutate( adapted_name = data_field_name ) %>%
		mutate( adapted_name = ifelse( greplm( data_field_name, "enum_id$" ), str_replace( data_field_name, "enum_id$", "enum" ), adapted_name ) ) %>%
		mutate( adapted_name = ifelse( greplm( data_field_name, "_(\\w)$" ), str_replace( data_field_name, "_(\\w)$", "\\1" ), adapted_name ) ) %>%
		arrange( entity_name, adapted_name )
	export( dd9, "data/temp/dd9.tsv" )

	print( "max data_field_id" )
	print( dd9$data_field_id %>% max )
	file.copy( "../rdb_data.xlsx", "data/temp/backup_rdb_data.xlsx", overwrite = T)
}

verify_rdb_data_after_sync_step_1 = function(data_model_dir) { 
	dd = read_data_dictionary_01(data_model_dir)
	de = r_data_entity(data_model_dir)
	assertthat::assert_that( rutils::all_nonna(de$data_entity_id) )
	de = dd %>%
		dplyr::inner_join( de, by = "entity_name" ) %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::arrange( entity_name ) %>%
		dplyr::select( data_entity_id, entity_name )
  rutils::assert_equal_set(dd, de, "entity_name", dir = data_model_dir)

	dd2 = dd %>%
		dplyr::anti_join( de, by = "entity_name" ) %>%
		dplyr::distinct( entity_name, .keep_all = T) %>%
		dplyr::select( entity_name )
  rutils::assert_empty(dd2, dir = data_model_dir)
} 

verify_rdb_data_after_sync_step_2 = function() { 
	dfl = r_data_field(with_invalid=T) 
	dd = read_data_dictionary_01()

	export( filter(dfl, is.na(data_field_id)), "data/temp/na_data_field.tsv" )	
	dup_data_field = duplicated_rows( dfl, "data_field_id" )
	export( dup_data_field, "data/temp/dup_data_field.tsv" )	

	length_data_field_name = lapply( dfl$data_field_name, nchar ) %>% unlist
	df_length_data_field_name = dfl %>%
		select( data_field_id, data_field_name ) %>%
		mutate( data_field_name = str_replace( data_field_name, "enum_id$", "enum" )) %>%
		mutate( length_data_field_name = lapply( data_field_name, nchar ) %>% unlist )
	export( df_length_data_field_name, "../view/df_length_data_field_name.tsv" )
	export( df_length_data_field_name, "../view/df_length_data_field_name.xlsx" )

	too_long_data_field_names = df_length_data_field_name %>%
		filter( length_data_field_name > 29 )
	export( too_long_data_field_names, "data/temp/too_long_data_field_names.tsv" )
	export( too_long_data_field_names, "data/temp/too_long_data_field_names.xlsx" )

	assertthat::assert_that( rutils::all_nonna(dfl$data_field_id) )
	assert_rows_are_unique(dfl, "data_field_id")
	assertthat::assert_that( is_empty(too_long_data_field_names) )

}

study_df_ids_wrong = function() {
	dd4 %>%
		filter( data_field_id == 200 )
	df %>%
		filter( data_field_id == 200 )
	path = '../rdb_data.xlsx'
	df1 = read_excel(path, 'DataField')
	is.na(dfl) %>% all
	!applyr(is.na(dfl), all) %>% all
	df = df1
	if(!is_any_column_exists) return(remove_all_na_rows(df))
	df2 = df %>%
		remove_all_na_columns 
	df3 = df2 %>% 
		remove_blank_column_headings 
	df4 = df3 %>%
		remove_all_na_rows 
	df5 = df4 %>%
		remove_all_newlines_inside_cells 
	df6 = df5 %>%
		make_numeric
	df16 = df1 %>%
		make_numeric
	df46 = df4 %>%
		make_numeric
	a1 = df5[1,1:2]
	a2 = a1 %>%
		remove_all_newlines_inside_cells %>%
		make_numeric
	a3 = a1 %>%
		make_numeric
	{ # make_numeric
		df = a1
		cols = names(df)
		cols_to_select = str_ends_with(cols, '_id') | cols == 'id'
		cols = cols[cols_to_select] 
		for (i in seq_along(cols)) {
			df[[ cols[i] ]] = df[[ cols[i] ]] %>% as.numeric
		}
		df[[ cols[i] ]] 
	}
	{ # make_numeric with df4
		b1 = df4[1, 1:2]
		df = b1
		cols = names(df)
		cols_to_select = str_ends_with(cols, '_id') | cols == 'id'
		cols = cols[cols_to_select] 
		for (i in seq_along(cols)) {
			df[[ cols[i] ]] = df[[ cols[i] ]] %>% as.numeric
		}
		df[[ cols[i] ]] 
	}
}

convert_dm_to_list = function() {
	den = r_data_entity()
	dfl = r_data_field() %>%
		select( data_field_id:data_entity_id )
	 
}

entity_as_df = function( entity, rdb_data_field ) {
	columns = filter( rdb_data_field, entity_name == entity)$data_field_name
	pk_field = columns %>% greplm( "^id$" )
	fk_fields = columns %>% greplm( "_id$" )
	others = !(pk_field | fk_fields)
	attr = setNames( replicate(length(columns), NA, simplify = F), c(columns[pk_field], columns[fk_fields], columns[others]) )
	as_data_frame(attr)
}

export_data_model_to_excel = function() { 
	# id=g_10026
	# export_data_model_to_excel = function() { <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/update_rdb_data.R#r=g_10026>
	dfl = r_data_field() %>%
		select( data_field_id:data_entity_id )

	entities_predefined = c( 
		"EnumCategory",
		"EnumValue",
		"Party",
		"Organization",
		"User",
		"Title",
		"Composite_Party"
	)
	entities_gis = c(
		"Polygon",
		"Polyline",
		"Point"
	)
	entities_base = c(
		"Territory",
		"Land",
		"Kontur",
		"Comment"
	)
	entities_bps07 = c(
		"Plan",
		"PlanDetail",
		"Applicant",
		"Document",
		"PenaltyOrder",
		"Order",
		"Payment",
		"AdditionalPenalty"
  )
	entities_bps06 = c(
		"Plan",
		"PlanDetail",
		"Applicant",
		"Document",
		"CategoryUpdateOrder",
		"Order",
		"MapObject",
		"TerritoryMapping",
		"BoundaryMeeting",
		"BoundaryMismatch",
		"MeetingParticipant",
		"BoundaryObjection", 
		"RuleViolation"
  )
	entities_bps05 = c(
		"Plan",
		"PlanDetail",
		"Applicant",
		"Document",
		"RecultivationOrder",
		"Order",
		"TerritoryMapping"
  )
	entities_bps03 = c(
		"Plan",
		"PlanDetail",
		"Abris",
		"MapObject",
		"MerzNisani",
		"TerritoryMapping",
		"BoundaryMeeting",
		"BoundaryMismatch",
		"MeetingParticipant",
		"BoundaryObjection", 
		"RuleViolation"
  )
	entities_bps01 = c(
		"Plan",
		"PlanDetail",
		"AraziTetkikati",
		"KesimNoktasi",
		"SampleList",
		"Sample",
		"Sample_Test",
		"TestResult"
	)
	entities_bps02 = c(
		"Plan",
		"PlanDetail",
		"AraziTetkikati",
		"SampleList",
		"Formasiya",
		"Dayanacaq",
		"Sample",
		"Sample_Test",
		"TestResult"
	)
	excel_gis = lapply( entities_gis, entity_as_df, dfl ) %>%
		setNames( entities_gis )
	excel_base = lapply( entities_base, entity_as_df, dfl ) %>%
		setNames( entities_base )
	excel_bps01 = lapply( entities_bps01, entity_as_df, dfl ) %>%
		setNames( entities_bps01 )
	excel_bps02 = lapply( entities_bps02, entity_as_df, dfl ) %>%
		setNames( entities_bps02 )
	excel_bps03 = lapply( entities_bps03, entity_as_df, dfl ) %>%
		setNames( entities_bps03 )
	excel_bps05 = lapply( entities_bps05, entity_as_df, dfl ) %>%
		setNames( entities_bps05 )
	excel_bps06 = lapply( entities_bps06, entity_as_df, dfl ) %>%
		setNames( entities_bps06 )
	excel_bps07 = lapply( entities_bps07, entity_as_df, dfl ) %>%
		setNames( entities_bps07 )
	write.xlsx( excel_gis, "excel_gis.xlsx" )
	write.xlsx( excel_base, "excel_base.xlsx" )
	write.xlsx( excel_bps01, "excel_bps01.xlsx" )
	write.xlsx( excel_bps02, "excel_bps02.xlsx" )
	write.xlsx( excel_bps03, "excel_bps03.xlsx" )
	write.xlsx( excel_bps05, "excel_bps05.xlsx" )
	write.xlsx( excel_bps06, "excel_bps06.xlsx" )
	write.xlsx( excel_bps07, "excel_bps07.xlsx" )
}

study_export_data_model_to_excel = function() {
	den = r_data_entity()
	dfl = r_data_field() %>%
		select( data_field_id:data_entity_id )
	 
	# s1: example
	plan_dfl = filter( dfl, entity_name == "Plan" )$data_field_name
	attr = setNames( replicate(length(plan_dfl), NA, simplify = F), plan_dfl )
	df_plan = as_data_frame(attr)

	pd_dfl = filter( dfl, entity_name == "PlanDetail" )$data_field_name
	attr = setNames( replicate(length(pd_dfl), NA, simplify = F), pd_dfl )
	df_pd = as_data_frame(attr)
	l = list("Plan" = df_plan, "PlanDetail" = df_pd)
	write.xlsx(l, "dm.xlsx")

	# s2: generify
	entity_as_df = function( entity, rdb_data_field ) {
		columns = filter( rdb_data_field, entity_name == entity)$data_field_name
		pk_field = columns %>% greplm( "^id$" )
		fk_fields = columns %>% greplm( "_id$" )
		others = !(pk_field | fk_fields)
		attr = setNames( replicate(length(columns), NA, simplify = F), c(columns[pk_field], columns[fk_fields], columns[others]) )
		as_data_frame(attr)
	}
	res = lapply( den$entity_name, entity_as_df, dfl) %>%
		setNames( den$entity_name )
	as.yaml(res) %>%
		writeLines( "../view/view_data_model.otl")

	# s3: filtering and ordering
	entities_bps01 = c(
		"Plan",
		"PlanDetail",
		"AraziTetkikati",
		"KesimNoktasi",
		"SampleList",
		"Sample",
		"Sample_Test",
		"TestResult"
	)
	excel_bps01 = lapply( entities_bps01, entity_as_df, dfl ) %>%
		setNames( entities_bps01 )
	write.xlsx( excel_bps01, "excel_bps01.xlsx" )
}

study_create_dataframe_with_columns_specified_in_list = function() {
	l = list( a = NA, b = NA )
	df = as_data_frame(l)
	l2 = setNames( replicate(2,NA, simplify = F), c('a', 'b'))
	df = as_data_frame(l2)
}

dependency_ordering_of_db_tables = function() {
	deps = r_data_field() %>%
		filter( pk_fk == "FK" ) %>%
		filter( !is.na(fk_data_entity_name) ) %>%
		filter( fk_data_entity_name != "NA" ) %>%
		select( entity_name, fk_data_entity_name ) %>%
		distinct( entity_name, fk_data_entity_name, .keep_all = T)

	g <- graph_from_data_frame(deps)
	ts = topo_sort(g) 
	ordt = data_frame( 
		entity_name = names(ts),
		topological_order_no = 1:length(ts)
	)

	den = r_data_entity(with_invalid=T) %>%
		select(-topological_order_no) %>%
		left_join(ordt, by = "entity_name" )

	export(den, "data/updates/DataEntity_updated.tsv")

	all_entities_have_topological_order_no(den)
}

export_delete_sql_script = function() {
	all_entities_have_topological_order_no()

	den = r_data_entity() %>%
		filter( not_na(table_name) ) %>%
		filter( not_na(topological_order_no) ) %>%
		select( table_name, topological_order_no ) %>%
		mutate( topological_order_no = as.numeric(topological_order_no) ) %>%
		arrange(topological_order_no)
	
	export(den, "data/delete_sql/delete_sql.csv")
	delete_data.sql = sprintf("DELETE FROM %s;", den$table_name)
	writeLines(delete_data.sql, "data/delete_sql/delete_data.sql") 

	all_tables_exist_in_delete_sql()

}

to_camel_case_for_postman = function() {
	udf = r_Update_DataField_in_Window()
	udf2 = udf %>%
		mutate(json_field_name = tocamel(data_field_name))
	export(udf2, "data/updates/Update_DataField_in_Window.tsv")
}

args = commandArgs(T)
print(args)
if( rutils::is.blank(args) ) {
	print( "no args" )
} else {
	if( args == "step_1" ) update_rdb_data_step_1()
	if( args == "step_2" ) update_rdb_data_step_2()
	if( args == "step_3" ) update_rdb_data_step_3()
	if( args == "step_4" ) update_rdb_data_step_4()
	if( args == "step_5" ) update_rdb_data_step_5()
	if( args == "step_6" ) update_rdb_data_step_6()
}


