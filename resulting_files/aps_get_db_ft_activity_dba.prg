CREATE PROGRAM aps_get_db_ft_activity:dba
 RECORD reply(
   1 ft_type_cd = f8
   1 patient_notification_ind = i2
   1 short_desc = c25
   1 description = vc
   1 active_ind = i2
   1 patient_notif_template_id = f8
   1 patient_first_overdue_ind = i2
   1 patient_first_template_id = f8
   1 patient_final_overdue_ind = i2
   1 patient_final_template_id = f8
   1 doctor_notification_ind = i2
   1 doctor_notif_template_id = f8
   1 doctor_first_overdue_ind = i2
   1 doctor_first_template_id = f8
   1 doctor_final_overdue_ind = i2
   1 doctor_final_template_id = f8
   1 updt_cnt = i4
   1 term_proc_cnt = i2
   1 term_proc_qual[1]
     2 catalog_cd = f8
     2 auto_term_ind = i2
     2 auto_term_reason_cd = f8
     2 look_back_days = i4
     2 mnemonic = vc
     2 updt_cnt = i4
   1 tracking_rep_cnt = i2
   1 tracking_rep_qual[1]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ftt.followup_tracking_type_cd, join_path = decode(fttp.seq,"A",ftrp.seq,"B"," "), oc
  .primary_mnemonic,
  ftrp.updt_cnt
  FROM ap_ft_type ftt,
   (dummyt d1  WITH seq = 1),
   ap_ft_term_proc fttp,
   order_catalog oc,
   (dummyt d2  WITH seq = 1),
   ap_ft_report_proc ftrp
  PLAN (ftt
   WHERE (ftt.followup_tracking_type_cd=request->tracking_type_cd))
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (fttp
   WHERE fttp.followup_tracking_type_cd=ftt.followup_tracking_type_cd)
   JOIN (oc
   WHERE oc.catalog_cd=fttp.catalog_cd
    AND 1=oc.active_ind)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (ftrp
   WHERE ftrp.followup_tracking_type_cd=ftt.followup_tracking_type_cd)
   ))
  ORDER BY ftt.followup_tracking_type_cd
  HEAD ftt.followup_tracking_type_cd
   reply->ft_type_cd = ftt.followup_tracking_type_cd, reply->patient_notification_ind = ftt
   .patient_notification_ind, reply->short_desc = ftt.short_desc,
   reply->description = ftt.description, reply->active_ind = ftt.active_ind, reply->
   patient_notif_template_id = ftt.patient_notif_template_id,
   reply->patient_first_overdue_ind = ftt.patient_first_overdue_ind, reply->patient_first_template_id
    = ftt.patient_first_template_id, reply->patient_final_overdue_ind = ftt.patient_final_overdue_ind,
   reply->patient_final_template_id = ftt.patient_final_template_id, reply->doctor_notification_ind
    = ftt.doctor_notification_ind, reply->doctor_notif_template_id = ftt.doctor_notif_template_id,
   reply->doctor_first_overdue_ind = ftt.doctor_first_overdue_ind, reply->doctor_first_template_id =
   ftt.doctor_first_template_id, reply->doctor_final_overdue_ind = ftt.doctor_final_overdue_ind,
   reply->doctor_final_template_id = ftt.doctor_final_template_id, reply->updt_cnt = ftt.updt_cnt
  DETAIL
   CASE (join_path)
    OF "A":
     reply->term_proc_cnt = (reply->term_proc_cnt+ 1),
     IF ((reply->term_proc_cnt > 1))
      stat = alter(reply->term_proc_qual,reply->term_proc_cnt)
     ENDIF
     ,reply->term_proc_qual[reply->term_proc_cnt].catalog_cd = fttp.catalog_cd,reply->term_proc_qual[
     reply->term_proc_cnt].auto_term_ind = fttp.auto_termination_ind,reply->term_proc_qual[reply->
     term_proc_cnt].auto_term_reason_cd = fttp.auto_termination_reason_cd,
     reply->term_proc_qual[reply->term_proc_cnt].look_back_days = fttp.look_back_days,reply->
     term_proc_qual[reply->term_proc_cnt].mnemonic = oc.primary_mnemonic,reply->term_proc_qual[reply
     ->term_proc_cnt].updt_cnt = fttp.updt_cnt
    OF "B":
     reply->tracking_rep_cnt = (reply->tracking_rep_cnt+ 1),
     IF ((reply->tracking_rep_cnt > 1))
      stat = alter(reply->tracking_rep_qual,reply->tracking_rep_cnt)
     ENDIF
     ,reply->tracking_rep_qual[reply->tracking_rep_cnt].task_assay_cd = ftrp.task_assay_cd,reply->
     tracking_rep_qual[reply->tracking_rep_cnt].updt_cnt = ftrp.updt_cnt
   ENDCASE
  WITH outerjoin = d1, dontcare = fttp, outerjoin = d2,
   dontcare = ftrp
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "APS_GET_DB_REPORTS_ACITIVITY"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
