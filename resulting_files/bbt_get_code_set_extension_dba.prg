CREATE PROGRAM bbt_get_code_set_extension:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 field_name = vc
     2 field_seq = i4
     2 field_type = i4
     2 field_len = i4
     2 field_prompt = vc
     2 field_in_mask = vc
     2 field_out_mask = vc
     2 validation_condition = vc
     2 validation_code_set = i4
     2 action_field = vc
     2 field_default = vc
     2 field_help = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ext_cnt = 0
 SET select_ok_ind = 0
 SET count1 = 0
 SELECT INTO "nl:"
  cvs.code_set, cse.field_name, cse.field_seq,
  cse.field_type, cse.field_len, cse.field_prompt,
  cse.field_in_mask, cse.field_out_mask, cse.validation_condition,
  cse.validation_code_set, cse.action_field, cse.field_default,
  cse.field_help
  FROM code_value_set cvs,
   code_set_extension cse
  PLAN (cvs
   WHERE (cvs.code_set=request->code_set))
   JOIN (cse
   WHERE cse.code_set=cvs.code_set)
  ORDER BY cvs.code_set, cse.field_name
  HEAD REPORT
   select_ok_ind = 0, ext_cnt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   ext_cnt = (ext_cnt+ 1)
   IF (mod(ext_cnt,10)=1
    AND ext_cnt != 1)
    stat = alterlist(reply->qual,(ext_cnt+ 9))
   ENDIF
   reply->qual[ext_cnt].code_set = cvs.code_set, reply->qual[ext_cnt].field_name = cse.field_name,
   reply->qual[ext_cnt].field_seq = cse.field_seq,
   reply->qual[ext_cnt].field_type = cse.field_type, reply->qual[ext_cnt].field_len = cse.field_len,
   reply->qual[ext_cnt].field_prompt = cse.field_prompt,
   reply->qual[ext_cnt].field_in_mask = cse.field_in_mask, reply->qual[ext_cnt].field_out_mask = cse
   .field_out_mask, reply->qual[ext_cnt].validation_condition = cse.validation_condition,
   reply->qual[ext_cnt].validation_code_set = cse.validation_code_set, reply->qual[ext_cnt].
   action_field = cse.action_field, reply->qual[ext_cnt].field_default = cse.field_default,
   reply->qual[ext_cnt].field_help = cse.field_help
  FOOT REPORT
   stat = alterlist(reply->qual,ext_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "Select Code_Set_Extension"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_code_set_extension"
 IF (select_ok_ind=1)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Zero rows found"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "FAILED"
 ENDIF
END GO
