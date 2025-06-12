CREATE PROGRAM cls_cs2052rpt
 SELECT INTO  $1
  code = cv.code_value, desc = substring(1,40,cv.description), codeset = cv.code_set,
  active = uar_get_code_meaning(cv.active_ind)
  FROM code_value cv
  WHERE cv.code_set=2052
  ORDER BY desc
 ;end select
END GO
