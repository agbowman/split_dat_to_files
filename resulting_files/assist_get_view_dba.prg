CREATE PROGRAM assist_get_view:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 view_qual = i4
    1 views[10]
      2 view_name = c100
      2 table_name = c30
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "CODE_VALUE_EXTENSION"
 SET kount = 0
 IF ((request->table_name="ALL"))
  SELECT DISTINCT INTO "nl:"
   e1.field_value, e3.field_value
   FROM code_value_extension e1,
    code_value_extension e2,
    code_value_extension e3
   WHERE e1.code_set=344
    AND e1.field_name="VIEW_NAME"
    AND e2.code_value=e1.code_value
    AND e2.field_name="OWNER_NAME"
    AND (e2.field_value=request->owner)
    AND e3.code_value=e1.code_value
    AND e3.field_name="TABLE_NAME"
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->views,(kount+ 10))
    ENDIF
    reply->views[kount].view_name = e1.field_value, reply->views[kount].table_name = e3.field_value
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   e1.field_value
   FROM code_value_extension e1,
    code_value_extension e2,
    code_value_extension e3
   WHERE e1.code_set=344
    AND e1.field_name="VIEW_NAME"
    AND e2.code_value=e1.code_value
    AND e2.field_name="OWNER_NAME"
    AND (e2.field_value=request->owner)
    AND e3.code_value=e1.code_value
    AND e3.field_name="TABLE_NAME"
    AND (e3.field_value=request->table_name)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->views,(kount+ 10))
    ENDIF
    reply->views[kount].view_name = e1.field_value, reply->views[kount].table_name = ""
   WITH nocounter
  ;end select
 ENDIF
 SET reply->view_qual = kount
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 SET stat = alter(reply->views,reply->view_qual)
 GO TO end_program
#end_program
END GO
