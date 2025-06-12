CREATE PROGRAM dcp_get_task_info:dba
 RECORD reply(
   1 task_id = f8
   1 nurse_unit_disp = vc
   1 room_disp = vc
   1 bed_disp = vc
   1 reference_task_id = f8
   1 task_status_reason_disp = vc
   1 task_status_reason_cd = f8
   1 task_dt_tm = dq8
   1 task_reason_not_done = vc
   1 task_reason_not_done_msg = vc
   1 note_format_cd = f8
   1 event_note_id = f8
   1 order_id = f8
   1 catalog_type_cd = f8
   1 encntr_id = f8
   1 event_id = f8
   1 task_class_cd = f8
   1 task_class_disp = vc
   1 task_class_mean = vc
   1 task_status_cd = f8
   1 task_status_disp = vc
   1 task_status_mean = vc
   1 task_activity_cd = f8
   1 task_activity_disp = vc
   1 task_activity_mean = vc
   1 med_order_type_cd = f8
   1 task_description = vc
   1 task_type_cd = f8
   1 task_type_disp = vc
   1 task_type_mean = vc
   1 task_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_value = 0.0
 SET code_set = 14024
 SET cdf_meaning = "DCP_NOTDONE"
 EXECUTE cpm_get_cd_for_cdf
 SET notdone = code_value
 CALL echo(build("___________",notdone))
 SET tmp_event_id = 0.0
 SELECT INTO "nl:"
  FROM task_activity ta,
   order_task ot
  PLAN (ta
   WHERE (ta.task_id=request->task_id))
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
  DETAIL
   reply->task_id = ta.task_id, reply->task_dt_tm = ta.task_dt_tm, reply->task_tz = validate(ta
    .task_tz,0),
   reply->reference_task_id = ta.reference_task_id, reply->task_status_reason_cd = ta
   .task_status_reason_cd
   IF (ta.task_status_reason_cd != 0)
    reply->task_status_reason_disp = uar_get_code_description(ta.task_status_reason_cd)
   ELSE
    reply->task_status_reason_disp = ""
   ENDIF
   IF (ta.location_cd != 0)
    reply->nurse_unit_disp = uar_get_code_description(ta.location_cd)
   ELSE
    reply->nurse_unit_disp = ""
   ENDIF
   IF (ta.loc_room_cd != 0)
    reply->room_disp = uar_get_code_description(ta.loc_room_cd)
   ELSE
    reply->room_disp = ""
   ENDIF
   IF (ta.loc_bed_cd != 0)
    reply->bed_disp = uar_get_code_description(ta.loc_bed_cd)
   ELSE
    reply->bed_disp = ""
   ENDIF
   tmp_event_id = ta.event_id, reply->order_id = ta.order_id, reply->catalog_type_cd = ta
   .catalog_type_cd,
   reply->encntr_id = ta.encntr_id, reply->task_class_cd = ta.task_class_cd, reply->task_status_cd =
   ta.task_status_cd,
   reply->task_activity_cd = ta.task_activity_cd, reply->med_order_type_cd = ta.med_order_type_cd,
   reply->event_id = ta.event_id,
   reply->task_description = ot.task_description, reply->task_type_cd = ot.task_type_cd
  WITH nocounter
 ;end select
 IF ((reply->task_status_reason_cd=notdone)
  AND tmp_event_id > 0)
  SELECT INTO "nl:"
   temp_var = decode(cc.seq,"CC",cs.seq,"CS",en.seq,
    "EN","ZZ")
   FROM clinical_event ce,
    ce_coded_result cc,
    ce_string_result cs,
    ce_event_note en,
    (dummyt d  WITH seq = 1)
   PLAN (ce
    WHERE ce.parent_event_id=tmp_event_id
     AND ce.view_level=1)
    JOIN (d)
    JOIN (((cc
    WHERE ce.event_id=cc.event_id)
    ) ORJOIN ((((cs
    WHERE cs.event_id=ce.event_id)
    ) ORJOIN ((en
    WHERE en.event_id=ce.event_id)
    )) ))
   DETAIL
    IF (temp_var="CC")
     reply->task_reason_not_done = uar_get_code_description(cc.result_cd)
    ELSEIF (temp_var="CS")
     reply->task_reason_not_done = cs.string_result_text
    ELSEIF (temp_var="EN")
     reply->event_note_id = en.event_note_id, reply->note_format_cd = en.note_format_cd
    ENDIF
   WITH outerjoin = d, nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
