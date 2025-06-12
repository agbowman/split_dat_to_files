CREATE PROGRAM cls_cs1024rpt2
 SELECT INTO  $1
  code = cv.code_value, desc = substring(1,40,cv.description), codeset = cv.code_set,
  active = uar_get_code_meaning(cv.active_ind), alias = decode(cva.seq,substring(1,40,cva.alias)," ")
  FROM code_value cv,
   code_value_alias cva
  WHERE cv.code_set=1024
  ORDER BY desc
 ;end select
END GO
