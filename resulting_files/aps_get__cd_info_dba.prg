CREATE PROGRAM aps_get__cd_info:dba
#script
 SET cdinfo->fail = 1
 SET cdinfo->code = 0
 SET cdinfo->display = ""
 SET cdinfo->description = ""
 SET cdinfo->meaning = ""
 SET cdinfo->display_key = ""
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE (cv.code_value= $1)
  DETAIL
   cdinfo->code = cv.code_value, cdinfo->display = cv.display, cdinfo->description = cv.description,
   cdinfo->meaning = cv.cdf_meaning, cdinfo->display_key = cv.display_key
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET cdinfo->fail = 0
 ENDIF
END GO
