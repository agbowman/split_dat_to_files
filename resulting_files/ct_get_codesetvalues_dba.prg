CREATE PROGRAM ct_get_codesetvalues:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 type[*]
      2 default_list_type_cd = f8
      2 default_list_type_disp = vc
      2 default_list_type_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#get_default_type
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_set=request->codeset)
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->type,cnt), reply->type[cnt].default_list_type_cd = cv
   .code_value,
   reply->type[cnt].default_list_type_disp = cv.display, reply->type[cnt].default_list_type_mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
