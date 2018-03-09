
main_yuml_to_uml = function() {
  data_model_dir = setenv_osx()
  main_yuml_to_uml.sh = system.file("bash/main_yuml_to_uml.sh", package = "yumltordbschema")
  system2(main_yuml_to_uml.sh, data_model_dir)
}
