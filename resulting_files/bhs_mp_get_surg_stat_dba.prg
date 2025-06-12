CREATE PROGRAM bhs_mp_get_surg_stat:dba
 PROMPT
  "Surgical Case Number" = ""
  WITH s_surg_case_nbr
 DECLARE ms_case_num = vc WITH protect, constant(trim(cnvtupper( $S_SURG_CASE_NBR),3))
 DECLARE ms_surg_status = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM surgical_case sc,
   encounter e,
   person p,
   tracking_item ti,
   tracking_event te,
   track_event tke
  PLAN (sc
   WHERE sc.surg_case_nbr_formatted=ms_case_num)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (ti
   WHERE ti.parent_entity_id=sc.surg_case_id
    AND ti.parent_entity_name="SURGICAL_CASE"
    AND ti.active_ind=1)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id
    AND te.active_ind=1)
   JOIN (tke
   WHERE tke.track_event_id=te.track_event_id
    AND tke.active_ind=1)
  ORDER BY te.requested_dt_tm DESC
  HEAD REPORT
   ms_tmp = concat('{"surg_status":"',trim(tke.description,3),'",','"surg_status_dt_tm":"',trim(
     format(te.requested_dt_tm,"mm/dd/yy hh:mm;;d"),3),
    '",','"request_status":"S",','"patient_name_first":"',trim(p.name_first_key,3),'",',
    '"msg":""')
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_tmp =
  '{"surg_status":"no match found", "request_status":"S","patient_name_first":"","msg":""}'
  GO TO exit_script
 ENDIF
 SELECT
  tke.track_event_id, tke.description, te.requested_dt_tm
  FROM surgical_case sc,
   tracking_item ti,
   tracking_event te,
   track_event tke
  PLAN (sc
   WHERE sc.surg_case_nbr_formatted=ms_case_num)
   JOIN (ti
   WHERE ti.parent_entity_id=sc.surg_case_id
    AND ti.parent_entity_name="SURGICAL_CASE"
    AND ti.active_ind=1)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id
    AND te.active_ind=1)
   JOIN (tke
   WHERE tke.track_event_id=te.track_event_id
    AND tke.active_ind=1)
  ORDER BY te.requested_dt_tm, tke.description
  HEAD REPORT
   ms_tmp = concat(ms_tmp,',"status":['), pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > 1)
    ms_tmp = concat(ms_tmp,",")
   ENDIF
   ms_tmp = concat(ms_tmp,'{"status_desc":"',trim(tke.description,3),'",',' "status_dt_tm":"',
    trim(format(te.requested_dt_tm,"mm/dd/yy hh:mm;;d"),3),'"}')
  FOOT REPORT
   ms_tmp = concat(ms_tmp,"]}")
  WITH uar_code(d), format(date,"mm/dd/yy hh:mm:ss;;d")
 ;end select
 CALL echo(ms_tmp)
#exit_script
 SET _memory_reply_string = ms_tmp
 CALL echo(_memory_reply_string)
END GO
