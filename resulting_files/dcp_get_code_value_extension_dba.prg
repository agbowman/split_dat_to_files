CREATE PROGRAM dcp_get_code_value_extension:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = c32
     2 code_set = i4
     2 field_type = i4
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ext_cnt = 0
 DECLARE ext_cnt = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cve.code_set, cve.field_name, cve.field_type,
  cve.field_value, cve.code_value
  FROM code_value_extension cve,
   code_set_extension cse
  PLAN (cve
   WHERE (cve.code_set=request->code_set))
   JOIN (cse
   WHERE cse.code_set=cve.code_set
    AND cse.field_name=cve.field_name)
  ORDER BY cve.code_set, cve.field_name, cve.code_value
  HEAD REPORT
   ext_cnt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   ext_cnt += 1
   IF (mod(ext_cnt,10)=1
    AND ext_cnt != 1)
    stat = alterlist(reply->qual,(ext_cnt+ 9))
   ENDIF
   reply->qual[ext_cnt].code_set = cve.code_set, reply->qual[ext_cnt].field_name = cve.field_name,
   reply->qual[ext_cnt].field_type = cve.field_type,
   reply->qual[ext_cnt].field_value = cve.field_value, reply->qual[ext_cnt].code_value = cve
   .code_value,
   CALL echo(build("CODE VALUE = ",reply->qual[ext_cnt].code_value))
  FOOT REPORT
   stat = alterlist(reply->qual,ext_cnt)
  WITH nocounter
 ;end select
 IF (error(serrmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "FAILED"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select query failed"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Zero rows found"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
 ENDIF
#exit_script
 CALL echo(build("XXXXXX = ",reply->status_data.subeventstatus[1].operationstatus))
END GO
