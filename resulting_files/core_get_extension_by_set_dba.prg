CREATE PROGRAM core_get_extension_by_set:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 ext_list[*]
     2 field_default = vc
     2 field_help = vc
     2 field_in_mask = vc
     2 field_len = i4
     2 field_name = c32
     2 field_out_mask = vc
     2 field_prompt = vc
     2 field_seq = i4
     2 field_type = i4
     2 validation_code_set = i4
     2 validation_condition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cse.code_set, cse.field_default, cse.field_help,
  cse.field_in_mask, cse.field_len, cse.field_name,
  cse.field_out_mask, cse.field_prompt, cse.field_seq,
  cse.field_type, cse.validation_code_set, cse.validation_condition
  FROM code_set_extension cse
  PLAN (cse
   WHERE (cse.code_set=request->code_set))
  ORDER BY cse.field_name
  HEAD REPORT
   ext_cnt = 0
  DETAIL
   ext_cnt = (ext_cnt+ 1)
   IF (mod(ext_cnt,10)=1)
    stat = alterlist(reply->ext_list,(ext_cnt+ 9))
   ENDIF
   reply->ext_list[ext_cnt].field_default = cse.field_default, reply->ext_list[ext_cnt].field_help =
   cse.field_help, reply->ext_list[ext_cnt].field_in_mask = cse.field_in_mask,
   reply->ext_list[ext_cnt].field_len = cse.field_len, reply->ext_list[ext_cnt].field_name = cse
   .field_name, reply->ext_list[ext_cnt].field_out_mask = cse.field_out_mask,
   reply->ext_list[ext_cnt].field_prompt = cse.field_prompt, reply->ext_list[ext_cnt].field_seq = cse
   .field_seq, reply->ext_list[ext_cnt].field_type = cse.field_type,
   reply->ext_list[ext_cnt].validation_code_set = cse.validation_code_set, reply->ext_list[ext_cnt].
   validation_condition = cse.validation_condition
  FOOT REPORT
   stat = alterlist(reply->ext_list,ext_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 MM/DD/YY JF8275"
END GO
