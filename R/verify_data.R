verify_data = function() {
	dfl = r_data_field() %>%
		filter( not_na(enum_category_id) )
	enm = r_enum() 
	den = r_data_entity()

	assert_inclusion( dfl, enm, "enum_category_id" )
	assert_all_have_attribute( den, "table_name" )

	verify_data_delete_sql()
}

verify_no_reserved_words_used = function(ydm, data_model_dir = env_data_model_dir()) {
  path = system.file("extdata", "sql_keywords.csv", package = "yumltordbschema")
  kw = rio::import(path)
  ydm$entity_name = toupper(ydm$entity_name)
  ydm$data_field_name = toupper(ydm$data_field_name)
  rutils::assert_no_intersection(ydm, kw, "entity_name", "keyword", dir = data_model_dir)
  rutils::assert_no_intersection(ydm, kw, "data_field_name", "keyword", dir = data_model_dir)
}
