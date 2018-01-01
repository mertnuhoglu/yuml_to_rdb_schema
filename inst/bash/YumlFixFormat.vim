
function! YumlFixFormat()
	" fix cardinalities
	silent! %s#]\s*\(\S*.*\S\)\s*\[#] \1 [#
	silent! g/[[^\]]*\]/ %s/-\+/-/g
	silent! %s#\*-#n-#
	silent! %s#-\*#-n#

	" fix pipe symbols
	silent! %s#|\s*]#]#
	" spacing between elements
	silent! %s#;\s*#; #g
	" spacing between class name and its attributes
	silent! %s#|\(\w\+\)#| \1#

	" put ; at the end of attributes
	silent! g/\s*\[\w*|/ s/\(\w\+\)\s*]/\1; ]/

	" fix attributes
  " id -> id INT PK
	" silent! g/\s*\[\w*|/ s#\<id\s*;#id INT PK;#
  " entity_id PK -> entity_id INT PK
	silent! g/\s*\[\w*|/ s#_id\s*PK;#_id INT PK;#g
  " entity_id -> entity_id INT FK
	silent! g/\s*\[\w*|/ s#_id\s*@NN\=;#_id INT FK @NN;#g
  " entity_enum -> entity_enum INT FK
	silent! g/\s*\[\w*|/ s#_enum\([^;]*\)#_enum INT FK\1#g
  " point_gisid -> point_gisid INT FK
	silent! g/\s*\[\w*|/ s#_gisid\s*;#_gisid INT FK;#g
  " ; field; -> ; field TEXT;
	silent! g/\s*\[\w*|/ s#;\s*\(\w\+\)\(;\)\@=#; \1 TEXT#g
  " VARCHAR -> TEXT
	silent! g/\s*\[\w*|/ s#\<VARCHAR\>#TEXT#g
  " NUMBER -> INT
	silent! g/\s*\[\w*|/ s#\<NUMBER\>#BIGINT#g
  " DOUBLE -> DOUBLE
	silent! g/\s*\[\w*|/ s#\<DOUBLE\>#DOUBLE#g
  " objectid -> objectid INT PK
	silent! g/\s*\[\w*|/ s#\<objectid\>\s*;#objectid INT PK;#g
  " , -> ;
	silent! g/\s*\[\w*|/ s#,#;#g
  " | -> | id INT PK
	" silent! v/\(\<id\>\|_id\>\|\<objectid\>\)/ s#|#| id INT PK;#
endfunction
command! YumlFixFormat call YumlFixFormat()
