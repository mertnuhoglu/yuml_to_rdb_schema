
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

main_manual_rdb_to_data = function() {
  main_rdb_to_data_step01()
  # manual steps:
  # process ddl.sql -> ddl_m.sql
  # ~/projects/itr/itr_documentation/data_model/data/view/ddl_m.sql
  # %s/\<BIGINT\>/INT/g
  # tabloların referans sıralamasını düzelt
  # tüm enum'ların df ifadelerini oluştur
  # -- df place_enum: word=./data/view/place_enum.txt
  # predefined verileri çıkart: enum_var, enum_value
  # -- df: nogen
  main_rdb_to_data_step02()
}

main_rdb_to_data_step01 = function() {
  main_yuml_to_uml()
  main_yuml_to_rdb__yuml_to_ddl()
  #> ~/projects/itr/itr_documentation/data_model/data/view/ddl.sql
  main_rdb_to_data()
  #> ~/projects/itr/itr_documentation/data_model/data/sql/sql_insert/sql_insert_enum_var.sql
}

main_rdb_to_data_step02 = function() {
  #< ~/projects/itr/itr_documentation/data_model/data/view/ddl_m.sql
  main_ddl_to_data()
  #> ~/projects/itr/itr_documentation/data_model/data/view/data.sql
}

main_yuml_to_rdb__yuml_to_ddl = function() {
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
  writeLines(ddl_lines, sprintf("%s/data/view/ddl.sql", data_model_dir))
}

test_sh = function() {
  cat_yuml.sh = system.file("bash/cat_yuml.sh", package = "yumltordbschema")
  data_model_dir = setenv_osx()
  system2(cat_yuml.sh, data_model_dir)
  #print("xlp")
  #system(sprintf("%s %s", cat_yuml.sh, data_model_dir), intern = T)
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

