
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
  " id -> id BIGINT PK
	" silent! g/\s*\[\w*|/ s#\<id\s*;#id BIGINT PK;#
  " entity_id PK -> entity_id BIGINT PK
	silent! g/\s*\[\w*|/ s#_id\s*PK;#_id BIGINT PK;#g
  " entity_id -> entity_id BIGINT FK
	silent! g/\s*\[\w*|/ s#_id\s*;#_id BIGINT FK;#g
  " entity_enum -> entity_enum BIGINT FK
	silent! g/\s*\[\w*|/ s#_enum\s*;#_enum BIGINT FK;#g
  " point_gisid -> point_gisid BIGINT FK
	silent! g/\s*\[\w*|/ s#_gisid\s*;#_gisid BIGINT FK;#g
  " ; field; -> ; field TEXT;
	silent! g/\s*\[\w*|/ s#;\s*\(\w\+\)\(;\)\@=#; \1 TEXT#g
  " VARCHAR -> TEXT
	silent! g/\s*\[\w*|/ s#\<VARCHAR\>#TEXT#g
  " NUMBER -> BIGINT
	silent! g/\s*\[\w*|/ s#\<NUMBER\>#BIGINT#g
  " DOUBLE -> DOUBLE
	silent! g/\s*\[\w*|/ s#\<DOUBLE\>#DOUBLE#g
  " objectid -> objectid BIGINT PK
	silent! g/\s*\[\w*|/ s#\<objectid\>\s*;#objectid BIGINT PK;#g
  " , -> ;
	silent! g/\s*\[\w*|/ s#,#;#g
  " | -> | id BIGINT PK
	" silent! v/\(\<id\>\|_id\>\|\<objectid\>\)/ s#|#| id BIGINT PK;#
endfunction
command! YumlFixFormat call YumlFixFormat()
