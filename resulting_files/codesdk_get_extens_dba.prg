CREATE PROGRAM codesdk_get_extens:dba
 RECORD reply(
   1 extensions[*]
     2 code_value = f8
     2 code_set = i4
     2 field_name = vc
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cap = i4 WITH public, noconstant(0)
 IF ((request->by_code.code_value > 0.0))
  SELECT INTO "nl:"
   FROM code_value_extension c
   WHERE (c.code_value=request->by_code.code_value)
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap = (cap * 2)
     ENDIF
     stat = alterlist(reply->extensions,cap)
    ENDIF
    cnt = (cnt+ 1), reply->extensions[cnt].code_value = c.code_value, reply->extensions[cnt].code_set
     = c.code_set,
    reply->extensions[cnt].field_name = c.field_name, reply->extensions[cnt].field_value = c
    .field_value
   FOOT REPORT
    stat = alterlist(reply->extensions,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->by_codeset.code_set > 0.0))
  SELECT INTO "nl:"
   FROM code_value_extension c
   WHERE (c.code_set=request->by_codeset.code_set)
    AND (c.field_name=request->by_codeset.field_name)
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap = (cap * 2)
     ENDIF
     stat = alterlist(reply->extensions,cap)
    ENDIF
    cnt = (cnt+ 1), reply->extensions[cnt].code_value = c.code_value, reply->extensions[cnt].code_set
     = c.code_set,
    reply->extensions[cnt].field_name = c.field_name, reply->extensions[cnt].field_value = c
    .field_value
   FOOT REPORT
    stat = alterlist(reply->extensions,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
