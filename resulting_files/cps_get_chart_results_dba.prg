CREATE PROGRAM cps_get_chart_results:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 event_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 event_id = f8
     2 parent_event_id = f8
     2 event_cd = f8
     2 event_disp = vc
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 result_status_cd = f8
     2 result_val = vc
     2 result_units_cd = f8
     2 performed_dt_tm = dq8
     2 performed_tz = i4
     2 performed_prsnl_id = f8
     2 reference_nbr = vc
     2 entry_mode_cd = f8
     2 source_cd = f8
     2 event_set_cd = f8
     2 valid_from_dt_tm = dq8
 )
 DECLARE event_set_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE cnvtupper(v.event_set_name)=cnvtupper(trim(request->event_set_name))
  DETAIL
   event_set_cd = v.event_set_cd
  WITH nocounter
 ;end select
 IF (event_set_cd <= 0.0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "v500_event_set_code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "event set cd is <= 0.0"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event c,
   v500_event_set_explode v
  PLAN (v
   WHERE v.event_set_cd=event_set_cd)
   JOIN (c
   WHERE (c.person_id=request->person_id)
    AND c.event_cd=v.event_cd
    AND c.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
    AND c.publish_flag=1
    AND c.view_level=1)
  HEAD REPORT
   index = 0, stat = alterlist(reply->event_list,50)
  DETAIL
   index = (index+ 1)
   IF (mod(index,50)=1)
    stat = alterlist(reply->event_list,(index+ 49))
   ENDIF
   reply->event_list[index].person_id = c.person_id, reply->event_list[index].encntr_id = c.encntr_id,
   reply->event_list[index].event_id = c.event_id,
   reply->event_list[index].parent_event_id = c.parent_event_id, reply->event_list[index].event_cd =
   c.event_cd, reply->event_list[index].event_end_dt_tm = c.event_end_dt_tm,
   reply->event_list[index].event_end_tz = c.event_end_tz, reply->event_list[index].result_status_cd
    = c.result_status_cd, reply->event_list[index].result_val = c.result_val,
   reply->event_list[index].result_units_cd = c.result_units_cd, reply->event_list[index].
   performed_dt_tm = c.performed_dt_tm, reply->event_list[index].performed_tz = c.performed_tz,
   reply->event_list[index].performed_prsnl_id = c.performed_prsnl_id, reply->event_list[index].
   reference_nbr = c.reference_nbr, reply->event_list[index].entry_mode_cd = c.entry_mode_cd,
   reply->event_list[index].source_cd = c.source_cd, reply->event_list[index].event_set_cd = v
   .event_set_cd, reply->event_list[index].valid_from_dt_tm = c.valid_from_dt_tm
  FOOT REPORT
   stat = alterlist(reply->event_list,index)
  WITH nocounter
 ;end select
 IF (curqual < 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "clinical_event"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed to retrieve results"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
