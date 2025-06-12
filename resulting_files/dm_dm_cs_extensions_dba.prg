CREATE PROGRAM dm_dm_cs_extensions:dba
 RECORD reply(
   1 qual[1]
     2 field_name = c32
     2 field_seq = i4
     2 field_type = i4
     2 field_len = i4
     2 field_prompt = c50
     2 field_in_mask = c50
     2 field_out_mask = c50
     2 validation_condition = vc
     2 validation_code_set = i4
     2 action_field = c50
     2 field_default = c50
     2 field_help = vc
     2 updt_cnt = i4
     2 delete_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dcf.schema_date
  FROM dm_adm_code_set_extension dcf
  WHERE (dcf.code_set=request->code_set)
  DETAIL
   IF ((dcf.schema_date > r1->rdate))
    r1->rdate = dcf.schema_date
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.field_name, c.field_seq, c.field_type,
  c.field_len, c.field_prompt, c.field_in_mask,
  c.field_out_mask, c.validation_condition, c.validation_code_set,
  c.action_field, c.field_default, c.field_help,
  c.updt_cnt, c.delete_ind
  FROM dm_adm_code_set_extension c
  WHERE (c.code_set=request->code_set)
   AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
  DETAIL
   count1 = (count1+ 1), stat = alter(reply->qual,count1), reply->qual[count1].field_name = c
   .field_name,
   reply->qual[count1].field_seq = c.field_seq, reply->qual[count1].field_type = c.field_type, reply
   ->qual[count1].field_len = c.field_len,
   reply->qual[count1].field_prompt = c.field_prompt, reply->qual[count1].field_in_mask = c
   .field_in_mask, reply->qual[count1].field_out_mask = c.field_out_mask,
   reply->qual[count1].validation_condition = c.validation_condition, reply->qual[count1].
   validation_code_set = c.validation_code_set, reply->qual[count1].action_field = c.action_field,
   reply->qual[count1].field_default = c.field_default, reply->qual[count1].field_help = c.field_help,
   reply->qual[count1].updt_cnt = c.updt_cnt,
   reply->qual[count1].delete_ind = c.delete_ind
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
