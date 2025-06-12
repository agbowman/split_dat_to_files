CREATE PROGRAM ce_get_dynamic_label:dba
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SELECT INTO "nl:"
  cdl.prev_dynamic_label_id, cdl.label_template_id, cdl.label_name,
  cdl.label_prsnl_id, cdl.person_id, cdl.result_set_id,
  cdl.label_status_cd, cdl.valid_from_dt_tm, cdl.label_seq_nbr,
  cdl.create_dt_tm
  FROM ce_dynamic_label cdl
  WHERE (cdl.ce_dynamic_label_id=request->ce_dynamic_label_id)
  DETAIL
   reply->prev_dynamic_label_id = cdl.prev_dynamic_label_id, reply->label_template_id = cdl
   .label_template_id, reply->label_name = cdl.label_name,
   reply->label_prsnl_id = cdl.label_prsnl_id, reply->person_id = cdl.person_id, reply->result_set_id
    = cdl.result_set_id,
   reply->label_status_cd = cdl.label_status_cd, reply->valid_from_dt_tm = cdl.valid_from_dt_tm,
   reply->label_seq_nbr = cdl.label_seq_nbr,
   reply->create_dt_tm = cdl.create_dt_tm
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
