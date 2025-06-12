CREATE PROGRAM dcp_get_dl_history:dba
 SET modify = predeclare
 RECORD reply(
   1 dynamic_label_instances[*]
     2 ce_dynamic_label_id = f8
     2 create_dt_tm = dq8
     2 label_name = vc
     2 label_prsnl_id = f8
     2 label_seq_nbr = i4
     2 label_status_cd = f8
     2 label_status_disp = c40
     2 label_status_desc = vc
     2 label_status_mean = c12
     2 label_template_id = f8
     2 long_text_id = f8
     2 long_text = vc
     2 person_id = f8
     2 prev_dynamic_label_id = f8
     2 result_set_id = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE label_counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM ce_dynamic_label dl,
   long_text lt
  PLAN (dl
   WHERE (dl.prev_dynamic_label_id=request->dynamic_label_id))
   JOIN (lt
   WHERE lt.long_text_id=dl.long_text_id)
  ORDER BY cnvtdatetime(dl.valid_until_dt_tm) DESC
  HEAD REPORT
   label_counter = 0
  DETAIL
   label_counter = (label_counter+ 1)
   IF (mod(label_counter,10)=1)
    stat = alterlist(reply->dynamic_label_instances,(label_counter+ 9))
   ENDIF
   reply->dynamic_label_instances[label_counter].ce_dynamic_label_id = dl.ce_dynamic_label_id, reply
   ->dynamic_label_instances[label_counter].create_dt_tm = dl.create_dt_tm, reply->
   dynamic_label_instances[label_counter].label_name = dl.label_name,
   reply->dynamic_label_instances[label_counter].label_prsnl_id = dl.label_prsnl_id, reply->
   dynamic_label_instances[label_counter].label_seq_nbr = dl.label_seq_nbr, reply->
   dynamic_label_instances[label_counter].label_status_cd = dl.label_status_cd,
   reply->dynamic_label_instances[label_counter].label_template_id = dl.label_template_id, reply->
   dynamic_label_instances[label_counter].long_text_id = dl.long_text_id, reply->
   dynamic_label_instances[label_counter].long_text = lt.long_text,
   reply->dynamic_label_instances[label_counter].person_id = dl.person_id, reply->
   dynamic_label_instances[label_counter].prev_dynamic_label_id = dl.prev_dynamic_label_id, reply->
   dynamic_label_instances[label_counter].result_set_id = dl.result_set_id,
   reply->dynamic_label_instances[label_counter].valid_from_dt_tm = dl.valid_from_dt_tm, reply->
   dynamic_label_instances[label_counter].valid_until_dt_tm = dl.valid_until_dt_tm
  FOOT REPORT
   stat = alterlist(reply->dynamic_label_instances,label_counter)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
