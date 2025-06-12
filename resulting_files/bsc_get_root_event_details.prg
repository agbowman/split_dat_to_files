CREATE PROGRAM bsc_get_root_event_details
 RECORD reply(
   1 event_list[*]
     2 event_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 template_order_id = f8
     2 event_cd = f8
     2 event_class_cd = f8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 update_date = dq8
     2 result_status_cd = f8
     2 normalcy_cd = f8
     2 performed_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_tz = i4
     2 event_tag = vc
     2 order_action_seq = i4
     2 contributor_system_cd = f8
     2 note_importance_bit_map = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE not_done_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE unauth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE root_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE success = i2 WITH protect, noconstant(0)
 DECLARE iterator = i4 WITH protect, noconstant(0)
 DECLARE locate_iterator = i4 WITH protect, noconstant(0)
 DECLARE continue_lookup = i2 WITH protect, noconstant(0)
 DECLARE event_idx = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(40)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 DECLARE event_cnt = i4 WITH protect, constant(size(request->event_list,5))
 IF (event_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET success = alterlist(reply->event_list,event_cnt)
 FOR (i = 1 TO event_cnt)
   SET reply->event_list[i].event_id = request->event_list[i].event_id
 ENDFOR
 SET continue_lookup = 1
 SET ntotal = (ceil((cnvtreal(event_cnt)/ nsize)) * nsize)
 SET success = alterlist(reply->event_list,ntotal)
 WHILE (continue_lookup)
  SET continue_lookup = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    clinical_event ce
   PLAN (d1
    WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
    JOIN (ce
    WHERE expand(iterator,start,(start+ (nsize - 1)),ce.event_id,reply->event_list[iterator].event_id
     ))
   HEAD ce.event_id
    event_idx = locateval(locate_iterator,1,event_cnt,ce.event_id,reply->event_list[locate_iterator].
     event_id)
    IF (event_idx > 0)
     IF ((reply->event_list[event_idx].event_id != ce.parent_event_id))
      reply->event_list[event_idx].event_id = ce.parent_event_id, continue_lookup = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event ce,
   orders o
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (ce
   WHERE expand(iterator,start,(start+ (nsize - 1)),ce.event_id,reply->event_list[iterator].event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND ce.event_reltn_cd=root_cd
    AND ce.result_status_cd IN (altered_cd, auth_cd, inerror_cd, modified_cd, not_done_cd,
   unauth_cd))
   JOIN (o
   WHERE o.order_id=ce.order_id)
  HEAD REPORT
   event_idx = 0
  HEAD ce.event_id
   event_idx = (event_idx+ 1), reply->event_list[event_idx].event_id = ce.event_id, reply->
   event_list[event_idx].person_id = ce.person_id,
   reply->event_list[event_idx].encntr_id = ce.encntr_id, reply->event_list[event_idx].order_id = o
   .order_id, reply->event_list[event_idx].template_order_id = o.template_order_id,
   reply->event_list[event_idx].event_cd = ce.event_cd, reply->event_list[event_idx].event_class_cd
    = ce.event_class_cd, reply->event_list[event_idx].event_end_dt_tm = ce.event_end_dt_tm,
   reply->event_list[event_idx].event_end_tz = ce.event_end_tz, reply->event_list[event_idx].
   update_date = ce.updt_dt_tm, reply->event_list[event_idx].result_status_cd = ce.record_status_cd,
   reply->event_list[event_idx].normalcy_cd = ce.normalcy_cd, reply->event_list[event_idx].
   performed_prsnl_id = ce.performed_prsnl_id, reply->event_list[event_idx].performed_dt_tm = ce
   .performed_dt_tm,
   reply->event_list[event_idx].performed_tz = ce.performed_tz, reply->event_list[event_idx].
   event_tag = ce.event_tag, reply->event_list[event_idx].order_action_seq = ce.order_action_sequence,
   reply->event_list[event_idx].contributor_system_cd = ce.contributor_system_cd, reply->event_list[
   event_idx].note_importance_bit_map = ce.note_importance_bit_map
  WITH nocounter
 ;end select
 SET success = alterlist(reply->event_list,event_idx)
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ELSEIF (size(reply->event_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 GO TO exit_script
#exit_script
 SET last_mod = "001"
 SET mod_date = "04/27/2009"
 SET modify = nopredeclare
END GO
