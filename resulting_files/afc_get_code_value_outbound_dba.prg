CREATE PROGRAM afc_get_code_value_outbound:dba
 RECORD reply(
   1 code_value = f8
   1 code_display = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 IF ((request->code_set=220))
  SELECT INTO "nl:"
   FROM code_value_outbound cvo
   WHERE (cvo.code_set=request->code_set)
    AND (cvo.alias=request->alias)
    AND cvo.alias_type_meaning IN ("NURSEUNIT", "AMBULATORY")
   DETAIL
    reply->code_value = cvo.code_value, reply->code_display = uar_get_code_display(cvo.code_value)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value_outbound cvo
   WHERE (cvo.code_set=request->code_set)
    AND (cvo.alias=request->alias)
   DETAIL
    reply->code_value = cvo.code_value, reply->code_display = uar_get_code_display(cvo.code_value)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_OUTBOUND"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
