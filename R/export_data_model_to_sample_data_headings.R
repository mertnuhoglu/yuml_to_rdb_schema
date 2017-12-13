entity_as_df = function( entity, rdb_data_field ) {
	columns = filter( rdb_data_field, entity_name == entity)$data_field_name
	pk_field = columns %>% rutils::greplm( "^id$" )
	fk_fields = columns %>% rutils::greplm( "_id$" )
	others = !(pk_field | fk_fields)
	attr = setNames( replicate(length(columns), NA, simplify = F), c(columns[pk_field], columns[fk_fields], columns[others]) )
	as_data_frame(attr)
}

export_data_model_to_sample_data_headings = function(dir) { 
	dfl = r_data_field() %>%
		dplyr::select( data_field_id:data_entity_id )

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
	excel_gis = lapply( entities_gis, entity_as_df, dfl ) %>%
		setNames( entities_gis )
	excel_base = lapply( entities_base, entity_as_df, dfl ) %>%
		setNames( entities_base )
	excel_bps01 = lapply( entities_bps01, entity_as_df, dfl ) %>%
		setNames( entities_bps01 )
	write.xlsx( excel_gis, "excel_gis.xlsx" )
	write.xlsx( excel_base, "excel_base.xlsx" )
	write.xlsx( excel_bps01, "excel_bps01.xlsx" )
}

study_export_data_model_to_excel = function() {
	den = r_data_entity()
	dfl = r_data_field() %>%
		dplyr::select( data_field_id:data_entity_id )
	 
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
		pk_field = columns %>% rutils::greplm( "^id$" )
		fk_fields = columns %>% rutils::greplm( "_id$" )
		others = !(pk_field | fk_fields)
		attr = setNames( replicate(length(columns), NA, simplify = F), c(columns[pk_field], columns[fk_fields], columns[others]) )
		dplyr::as_data_frame(attr)
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
	write.xlsx( excel_bps01, rutils::path_file(dir = "sample_data_headings", filename = "excel_bps01"))
}


