CREATE PROGRAM dm_starter_cs_extension:dba
 FREE RECORD dmreq
 RECORD dmreq(
   1 qual[*]
     2 field_name = c32
     2 code_set = f8
     2 field_seq = i4
     2 field_type = i2
     2 field_len = i4
     2 field_prompt = c50
     2 field_default = c50
     2 field_help = c100
     2 field_in_mask = c50
     2 field_out_mask = c50
     2 validation_condition = c100
     2 validation_code_set = i4
     2 action_field = c50
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_applctx = i4
     2 updt_task = f8
   1 cnt = i4
 )
 SET dmreq->cnt = 0
 SET stat = alterlist(dmreq->qual,10)
 SELECT INTO "nl:"
  dcv.code_set, dcv.field_name, dcv.field_seq,
  dcv.field_type, dcv.field_len, dcv.field_prompt,
  dcv.field_default, dcv.field_help, dcv.field_in_mask,
  dcv.field_out_mask, dcv.validation_condition, dcv.validation_code_set,
  dcv.action_field, dcv.updt_id, dcv.updt_cnt,
  dcv.updt_task, dcv.updt_dt_tm, dcv.updt_applctx
  FROM dm_adm_code_set_extension dcv
  WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   AND (dcv.code_set=list->qual[cnt].code_set)
   AND dcv.delete_ind=0
  DETAIL
   dmreq->cnt = (dmreq->cnt+ 1), stat = alterlist(dmreq->qual,(dmreq->cnt+ 1)), dmreq->qual[dmreq->
   cnt].code_set = dcv.code_set,
   dmreq->qual[dmreq->cnt].field_name = dcv.field_name, dmreq->qual[dmreq->cnt].field_default = dcv
   .field_default, dmreq->qual[dmreq->cnt].field_prompt = dcv.field_prompt,
   dmreq->qual[dmreq->cnt].field_help = dcv.field_help, dmreq->qual[dmreq->cnt].field_seq = dcv
   .field_seq, dmreq->qual[dmreq->cnt].field_type = dcv.field_type,
   dmreq->qual[dmreq->cnt].field_len = dcv.field_len, dmreq->qual[dmreq->cnt].field_in_mask = dcv
   .field_in_mask, dmreq->qual[dmreq->cnt].field_out_mask = dcv.field_out_mask,
   dmreq->qual[dmreq->cnt].validation_condition = dcv.validation_condition, dmreq->qual[dmreq->cnt].
   validation_code_set = dcv.validation_code_set, dmreq->qual[dmreq->cnt].updt_dt_tm = dcv.updt_dt_tm,
   dmreq->qual[dmreq->cnt].updt_id = dcv.updt_id, dmreq->qual[dmreq->cnt].updt_cnt = dcv.updt_cnt,
   dmreq->qual[dmreq->cnt].updt_task = dcv.updt_task,
   dmreq->qual[dmreq->cnt].updt_applctx = dcv.updt_applctx
  WITH nocounter
 ;end select
 SET knt = 0
 FOR (knt = 1 TO dmreq->cnt)
   FREE SET dmrequest
   RECORD dmrequest(
     1 field_name = c32
     1 code_set = f8
     1 field_seq = i4
     1 field_type = i2
     1 field_len = i4
     1 field_prompt = c50
     1 field_default = c50
     1 field_help = c100
     1 field_in_mask = c50
     1 field_out_mask = c50
     1 validation_condition = c100
     1 validation_code_set = i4
     1 action_field = c50
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_cnt = i4
     1 updt_applctx = i4
     1 updt_task = f8
   )
   SET dmrequest->code_set = dmreq->qual[knt].code_set
   SET dmrequest->field_name = dmreq->qual[knt].field_name
   SET dmrequest->field_default = dmreq->qual[knt].field_default
   SET dmrequest->field_prompt = dmreq->qual[knt].field_prompt
   SET dmrequest->field_help = dmreq->qual[knt].field_help
   SET dmrequest->field_seq = dmreq->qual[knt].field_seq
   SET dmrequest->field_type = dmreq->qual[knt].field_type
   SET dmrequest->field_len = dmreq->qual[knt].field_len
   SET dmrequest->field_in_mask = dmreq->qual[knt].field_in_mask
   SET dmrequest->field_out_mask = dmreq->qual[knt].field_out_mask
   SET dmrequest->validation_condition = dmreq->qual[knt].validation_condition
   SET dmrequest->validation_code_set = dmreq->qual[knt].validation_code_set
   SET dmrequest->updt_dt_tm = dmreq->qual[knt].updt_dt_tm
   SET dmrequest->updt_id = dmreq->qual[knt].updt_id
   SET dmrequest->updt_cnt = dmreq->qual[knt].updt_cnt
   SET dmrequest->updt_task = dmreq->qual[knt].updt_task
   SET dmrequest->updt_applctx = dmreq->qual[knt].updt_applctx
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_set_extension
 ENDFOR
 DELETE  FROM code_set_extension cse
  WHERE (cse.code_set=list->qual[cnt].code_set)
   AND (cse.field_name=
  (SELECT
   c.field_name
   FROM dm_adm_code_set_extension c
   WHERE (c.code_set=list->qual[cnt].code_set)
    AND c.schema_date=cnvtdatetime(r1->rdate)
    AND c.delete_ind=1))
  WITH nocounter
 ;end delete
 COMMIT
END GO
