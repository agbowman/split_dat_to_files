CREATE PROGRAM bsc_get_code_value_by_ext
 SET modify = predeclare
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
 DECLARE ext_cnt = i4 WITH noconstant(0)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE get_all_ind = i2 WITH noconstant(0)
 IF (validate(request->get_all_values)=1)
  IF ((request->get_all_values=1))
   SET get_all_ind = 1
  ENDIF
 ENDIF
 IF (get_all_ind=1)
  SELECT INTO "nl:"
   cve.code_set, cve.field_name, cve.field_type,
   cve.field_value, cve.code_value
   FROM code_value_extension cve,
    code_set_extension cse
   PLAN (cve
    WHERE (cve.code_set=request->code_set)
     AND (cve.field_name=request->field_name)
     AND cve.field_value != " ")
    JOIN (cse
    WHERE cse.code_set=cve.code_set
     AND cse.field_name=cve.field_name)
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
    .code_value
   FOOT REPORT
    stat = alterlist(reply->qual,ext_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF ((request->code_set=71))
    PLAN (cve
     WHERE (cve.code_set=request->code_set)
      AND (cve.field_name=request->field_name)
      AND ((cve.field_value="1") OR (cve.field_value="3")) )
     JOIN (cse
     WHERE cse.code_set=cve.code_set
      AND cse.field_name=cve.field_name)
   ELSE
    PLAN (cve
     WHERE (cve.code_set=request->code_set)
      AND (cve.field_name=request->field_name)
      AND cve.field_value="1")
     JOIN (cse
     WHERE cse.code_set=cve.code_set
      AND cse.field_name=cve.field_name)
   ENDIF
   INTO "nl:"
   FROM code_value_extension cve,
    code_set_extension cse
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
    .code_value
   FOOT REPORT
    stat = alterlist(reply->qual,ext_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ZERO QUALIFIED"
 ENDIF
 SET last_mod = "002 12/17/2018"
 SET modify = nopredeclare
END GO
