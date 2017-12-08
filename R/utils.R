
read_view_data_model_all = function(data_model_dir = check_data_dir()) {
	readLines(sprintf("%s/view/datamodel_sdb.yuml", data_model_dir))
}
r_datamodel_sdb.yuml = read_view_data_model_all

read_data_dictionary_01 = function(data_model_dir = check_data_dir()) {
  rio::import(sprintf("%s/view/dd_01.csv", data_model_dir))
}

r_data_entity = function(data_model_dir = check_data_dir(), ...) {
  print(data_model_dir)
  path = sprintf("%s/rdb/data_entity.tsv", data_model_dir)
  if (file.exists(path))
    rio::import(path)
  else
    data.frame(data_entity_id = integer(), entity_name = character())
}

#' Add together two numbers
#'
#' @param x A number
#' @return The sum of \code{x} and 
#' @examples
#' add(1, 1)
add <- function(x, y) { x + y }
