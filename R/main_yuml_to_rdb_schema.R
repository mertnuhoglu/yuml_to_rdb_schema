
test_setup = function() {
  library(devtools)
  devtools::load_all()
  data_model_dir = setenv_osx()
  library(magrittr)
  #library(assertthat)
  #library(dplyr)
  #library(purrr)
  #library(readr)
  #library(rio)
  #library(stringr)
  #library(tidyr)
}

test_build_data_sql = function() {
  main_build_data_sql()
}
test_update_rdb_data_step_1 = function() {
  data_model_dir = setenv_osx()
  rdt = yuml_to_rdb(data_model_dir)
  ddl = rdb_to_ddl(
                  data_entity = rdt$data_entity
                  , data_field = rdt$data_field
                  )
  den2 = rdt$data_entity %>%
    dplyr::left_join(ddl, by = "data_entity_id") %>%
    dplyr::arrange(entity_name)
  rio::export(den2, sprintf("%s/data/view/data_entity_with_ddl.tsv", data_model_dir))
  ddl_lines = den2$sql_create_table %>%
    # split into new lines from '(' but not after 'REFERENCES'
    stringr::str_replace_all("(?<!REFERENCES \\w{1,64} )([(])", "\\1\\\n  ") %>%
    # split into new lines from ')' but not after 'REFERENCES'
    stringr::str_replace_all("(?<!REFERENCES \\w{1,64} \\(\\w{1,64})([)])", "\\\n  \\1 ") %>%
    # split into new lines from ',' 
    stringr::str_replace_all("([,])", "\\\n  \\1 ") 
  writeLines(ddl_lines, sprintf("%s/data/view/create_table_ddl.sql", data_model_dir))
}

test_sh = function() {
  build_datamodel_sdb.sh = system.file("bash/build_datamodel_sdb.sh", package = "yumltordbschema")
  data_model_dir = setenv_osx()
  system2(build_datamodel_sdb.sh, data_model_dir)
  #print("xlp")
  #system(sprintf("%s %s", build_datamodel_sdb.sh, data_model_dir), intern = T)
}

main_yuml_to_rdb_schema = function() {
  setenv_osx()
  data_model_dir = Sys.getenv("DATA_MODEL_DIR")
  update_rdb_data_step_1(data_model_dir)

}

data_model_dir = function() {
	env_data_model_dir()
  Sys.getenv("DATA_MODEL_DIR")
}

env_data_model_dir = function() {
  data_model_dir = Sys.getenv("DATA_MODEL_DIR")
  if (data_model_dir == "") {
    v1 = sprintf("%s/%s", getwd(), ".")
    Sys.setenv(DATA_MODEL_DIR = v1)
  }
  return(data_model_dir)
}

setenv_osx = function() {
  library(yumltordbschema)
  Sys.setenv(DATA_MODEL_DIR = "/Users/mertnuhoglu/projects/itr/itr_documentation/data_model/")
	env_data_model_dir()
}

setenv_docker = function() {
  library(vrpdata)
  Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
  Sys.setenv(DATA_MODEL_DIR = "/srv/app/data/jtn")
	env_data_model_dir()
}

