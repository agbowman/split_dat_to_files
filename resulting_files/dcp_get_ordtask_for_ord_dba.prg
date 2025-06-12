CREATE PROGRAM dcp_get_ordtask_for_ord:dba
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 template_order_id = f8
     2 template_order_flag = i2
     2 order_status_cd = f8
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 synonym_id = f8
     2 order_mnemonic = c100
     2 catalog_cd = f8
     2 clinical_display_line = vc
     2 oe_format_id = f8
     2 last_updt_cnt = i4
     2 ref_text_mask = i4
     2 cki = vc
     2 ingredient_ind = i2
     2 comment_type_mask = i4
     2 stop_type_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 cs_flag = i2
     2 freq_type_flag = i2
     2 rx_mask = i4
     2 dcp_clin_cat_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 dept_status_cd = f8
     2 need_doctor_cosign_ind = i2
     2 need_nurse_review_ind = i2
     2 suspend_ind = i2
     2 resume_ind = i2
     2 orderable_type_flag = i2
   1 task_list[*]
     2 task_id = f8
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
     2 order_id = f8
     2 event_cd = f8
     2 catalog_cd = f8
     2 event_id = f8
     2 task_dt_tm = dq8
     2 task_status_cd = f8
     2 task_status_disp = c40
     2 task_status_mean = c12
     2 allpositionchart_ind = i2
     2 ability_ind = i2
     2 task_activity_cd = f8
     2 task_activity_disp = c40
     2 task_activity_mean = c12
     2 updt_cnt = i4
     2 med_order_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET task_cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET pending_cd = 0.0
 SET overdue_cd = 0.0
 SET inprocess_cd = 0.0
 SET reqordcnt = 0
 SET ordcnt = 0
 SET taskcnt = 0
 SET ordcnt = 0
 SET code_set = 79
 SET cdf_meaning = "PENDING"
 EXECUTE cpm_get_cd_for_cdf
 SET pending_cd = code_value
 SET code_set = 79
 SET cdf_meaning = "OVERDUE"
 EXECUTE cpm_get_cd_for_cdf
 SET overdue_cd = code_value
 SET code_set = 79
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 SET reqordcnt = size(request->order_list,5)
 IF (reqordcnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO reqordcnt)
   SET parentordflag = 0
   IF ((request->order_list[x].template_order_flag=1))
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.template_order_id=request->order_list[x].order_id)
    ;end select
    IF (curqual=0)
     SET parentordflag = 0
    ELSE
     SET parentordflag = 1
    ENDIF
   ENDIF
   SELECT
    IF (parentordflag=1)
     PLAN (o
      WHERE (o.template_order_id=request->order_list[x].order_id))
      JOIN (ta
      WHERE ta.order_id=o.order_id
       AND ta.active_ind=1)
      JOIN (ot
      WHERE ot.reference_task_id=ta.reference_task_id)
    ELSE
     PLAN (o
      WHERE (o.order_id=request->order_list[x].order_id))
      JOIN (ta
      WHERE ta.order_id=o.order_id
       AND ta.active_ind=1)
      JOIN (ot
      WHERE ot.reference_task_id=ta.reference_task_id)
    ENDIF
    INTO "nl:"
    o.order_id, o.template_order_id, ta.order_id,
    ta.active_ind, ta.reference_task_id, ot.reference_task_id
    FROM orders o,
     task_activity ta,
     order_task ot
    ORDER BY o.order_id
    HEAD o.order_id
     ordcnt = (ordcnt+ 1)
     IF (ordcnt > size(reply->order_list,5))
      stat = alterlist(reply->order_list,(ordcnt+ 5))
     ENDIF
     reply->order_list[ordcnt].order_id = o.order_id, reply->order_list[ordcnt].constant_ind = o
     .constant_ind, reply->order_list[ordcnt].prn_ind = o.prn_ind,
     reply->order_list[ordcnt].order_comment_ind = o.order_comment_ind, reply->order_list[ordcnt].
     template_order_id = o.template_order_id, reply->order_list[ordcnt].template_order_flag = o
     .template_order_flag,
     reply->order_list[ordcnt].order_status_cd = o.order_status_cd, reply->order_list[ordcnt].
     current_start_dt_tm = o.current_start_dt_tm, reply->order_list[ordcnt].current_start_tz = o
     .current_start_tz,
     reply->order_list[ordcnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->order_list[
     ordcnt].projected_stop_tz = o.projected_stop_tz, reply->order_list[ordcnt].synonym_id = o
     .synonym_id,
     reply->order_list[ordcnt].order_mnemonic = o.order_mnemonic, reply->order_list[ordcnt].
     catalog_cd = o.catalog_cd, reply->order_list[ordcnt].clinical_display_line = o
     .clinical_display_line,
     reply->order_list[ordcnt].oe_format_id = o.oe_format_id, reply->order_list[ordcnt].last_updt_cnt
      = o.updt_cnt, reply->order_list[ordcnt].ref_text_mask = o.ref_text_mask,
     reply->order_list[ordcnt].cki = o.cki, reply->order_list[ordcnt].ingredient_ind = o
     .ingredient_ind, reply->order_list[ordcnt].comment_type_mask = o.comment_type_mask,
     reply->order_list[ordcnt].stop_type_cd = o.stop_type_cd, reply->order_list[ordcnt].person_id = o
     .person_id, reply->order_list[ordcnt].encntr_id = o.encntr_id,
     reply->order_list[ordcnt].cs_flag = o.cs_flag, reply->order_list[ordcnt].freq_type_flag = o
     .freq_type_flag, reply->order_list[ordcnt].rx_mask = o.rx_mask,
     reply->order_list[ordcnt].dcp_clin_cat_cd = o.dcp_clin_cat_cd, reply->order_list[ordcnt].
     catalog_type_cd = o.catalog_type_cd, reply->order_list[ordcnt].activity_type_cd = o
     .activity_type_cd,
     reply->order_list[ordcnt].dept_status_cd = o.dept_status_cd, reply->order_list[ordcnt].
     need_doctor_cosign_ind = o.need_doctor_cosign_ind, reply->order_list[ordcnt].
     need_nurse_review_ind = o.need_nurse_review_ind,
     reply->order_list[ordcnt].suspend_ind = o.suspend_ind, reply->order_list[ordcnt].resume_ind = o
     .resume_ind, reply->order_list[ordcnt].orderable_type_flag = o.orderable_type_flag
    DETAIL
     taskcnt = (taskcnt+ 1)
     IF (taskcnt > size(reply->task_list,5))
      stat = alterlist(reply->task_list,(taskcnt+ 5))
     ENDIF
     reply->task_list[taskcnt].task_id = ta.task_id, reply->task_list[taskcnt].reference_task_id = ta
     .reference_task_id, reply->task_list[taskcnt].task_description = ot.task_description,
     reply->task_list[taskcnt].dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->task_list[taskcnt].
     order_id = ta.order_id, reply->task_list[taskcnt].event_cd = ot.event_cd,
     reply->task_list[taskcnt].catalog_cd = ta.catalog_cd, reply->task_list[taskcnt].event_id = ta
     .event_id, reply->task_list[taskcnt].task_dt_tm = cnvtdatetime(ta.task_dt_tm),
     reply->task_list[taskcnt].task_status_cd = ta.task_status_cd, reply->task_list[taskcnt].
     allpositionchart_ind = ot.allpositionchart_ind, reply->task_list[taskcnt].task_activity_cd = ot
     .task_activity_cd,
     reply->task_list[taskcnt].updt_cnt = ta.updt_cnt, reply->task_list[taskcnt].med_order_type_cd =
     ta.med_order_type_cd
     IF (ot.allpositionchart_ind=1)
      reply->task_list[taskcnt].ability_ind = 1
     ELSE
      reply->task_list[taskcnt].ability_ind = 0
     ENDIF
     stat = alterlist(reply->task_list,taskcnt)
    FOOT  o.order_id
     stat = alterlist(reply->order_list,ordcnt)
   ;end select
 ENDFOR
 CALL echo(build("OrdCnt ",ordcnt))
 CALL echo(build("TaskCnt ",taskcnt))
 SET nbr_to_check = size(reply->task_list,5)
 SELECT INTO "nl:"
  otpx.reference_task_id, otpx.position_cd
  FROM (dummyt d1  WITH seq = value(nbr_to_check)),
   order_task_position_xref otpx
  PLAN (d1)
   JOIN (otpx
   WHERE (otpx.reference_task_id=reply->task_list[d1.seq].reference_task_id)
    AND (otpx.position_cd=request->position_cd))
  DETAIL
   reply->task_list[d1.seq].ability_ind = 1
  WITH nocounter
 ;end select
 IF (ordcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo("exiting script")
END GO
