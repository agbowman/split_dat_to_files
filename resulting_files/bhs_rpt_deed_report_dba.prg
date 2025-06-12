CREATE PROGRAM bhs_rpt_deed_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "EMAIL" = "REPORT_VIEW"
  WITH outdev, email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 0
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "edencounter"
 ELSE
  SET email_ind = 0
  SET var_output =  $OUTDEV
 ENDIF
 DECLARE dline = vc
 FREE RECORD pat
 RECORD pat(
   1 pat_cnt = i2
   1 pat_count[*]
     2 tracking_id = f8
     2 encounter_id = f8
     2 person_id = f8
     2 fin = vc
     2 pat_mrn = vc
     2 pat_name = vc
     2 pat_age = vc
     2 gender = vc
     2 first_doc_assign = vc
     2 first_rn_assign = vc
     2 discharge_md = vc
     2 disch_ord_dt = vc
     2 checking_dt_tm = vc
     2 checkoout_dt_tm = vc
     2 acutiy = vc
     2 reason_visit = vc
     2 encntr_type_code = vc
     2 b_cnt = i4
     2 last_location[*]
       3 locator_id = f8
       3 update_dt_tm = vc
       3 unit = vc
       3 bed = vc
     2 ed_dr_name = vc
     2 ed_dr_id = f8
     2 discharge_dt_tm = vc
     2 tracking_cnt = i4
     2 tracking_event[*]
       3 tracking_event_id = f8
       3 request_dt_tm = vc
       3 event_status_cd = f8
       3 complete_dt_tm = vc
       3 tracking_id = f8
       3 track_event_desc = vc
       3 seq = i4
 )
 FREE RECORD pat_display
 RECORD pat_display(
   1 qual[*]
     2 fin = c40
     2 pat_mrn = c40
     2 pat_name = c40
     2 pat_age = c40
     2 gender = c40
     2 first_doc_assign = c40
     2 first_rn_assign = c40
     2 discharge_md = c40
     2 disch_ord_dt = c40
     2 checking_dt_tm = c40
     2 checkoout_dt_tm = c40
     2 triage_dt_tm = c40
     2 assessment_dt = c40
     2 acutiy = c40
     2 reason_visit = c40
     2 encntr_type_code = c40
     2 b_cnt = i4
     2 last_location[*]
     2 locator_id = f8
     2 update_dt_tm = c40
     2 unit = c40
     2 bed = c40
     2 ed_dr_name = c40
     2 ed_dr_id = f8
     2 discharge_dt_tm = c40
     2 tracking_cnt = i4
     2 tracking_event[*]
     2 tracking_event_id = f8
     2 request_dt_tm = c40
     2 event_status_cd = f8
     2 complete_dt_tm = c40
     2 tracking_id = f8
     2 track_event_desc = c40
     2 seq = i4
 )
 SELECT INTO "nl:"
  FROM tracking_checkin tc,
   track_reference tr,
   tracking_item ti,
   person p,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1,
   prsnl pa,
   prsnl pa2,
   orders o,
   order_action oa
  PLAN (tc
   WHERE tc.checkout_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959))
   JOIN (ti
   WHERE tc.tracking_id=ti.tracking_id
    AND ti.active_ind=1)
   JOIN (e
   WHERE ti.encntr_id=e.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (tr
   WHERE tr.tracking_ref_id=tc.acuity_level_id)
   JOIN (pa
   WHERE pa.person_id=tc.primary_doc_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(1077))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(1079))
    AND (ea1.active_ind= Outerjoin(1)) )
   JOIN (o
   WHERE (o.encntr_id= Outerjoin(e.encntr_id))
    AND (o.order_mnemonic= Outerjoin("Discharge Patient (ED Order)")) )
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(o.order_id))
    AND (oa.action_type_cd= Outerjoin(value(uar_get_code_by("displaykey",6003,"ORDER")))) )
   JOIN (pa2
   WHERE (pa2.person_id= Outerjoin(oa.action_personnel_id)) )
  ORDER BY tc.tracking_id
  HEAD REPORT
   p_cnt = 0
  HEAD tc.tracking_id
   p_cnt += 1, pat->pat_cnt = p_cnt, stat = alterlist(pat->pat_count,p_cnt),
   pat->pat_count[p_cnt].encounter_id = e.encntr_id, pat->pat_count[p_cnt].checking_dt_tm = format(tc
    .checkin_dt_tm,"mm/dd/yyyy hh:mm;;q"), pat->pat_count[p_cnt].checkoout_dt_tm = format(tc
    .checkout_dt_tm,"mm/dd/yyyy hh:mm;;q"),
   pat->pat_count[p_cnt].person_id = p.person_id, pat->pat_count[p_cnt].gender = uar_get_code_display
   (p.sex_cd), pat->pat_count[p_cnt].pat_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
      .birth_tz),1)),
   pat->pat_count[p_cnt].pat_name = p.name_full_formatted, pat->pat_count[p_cnt].reason_visit = e
   .reason_for_visit, pat->pat_count[p_cnt].person_id = p.person_id,
   pat->pat_count[p_cnt].acutiy = tr.display, pat->pat_count[p_cnt].encntr_type_code =
   uar_get_code_display(e.encntr_type_cd), pat->pat_count[p_cnt].tracking_id = ti.tracking_id,
   pat->pat_count[p_cnt].fin = ea.alias, pat->pat_count[p_cnt].pat_mrn = ea1.alias, pat->pat_count[
   p_cnt].ed_dr_id = pa.person_id,
   pat->pat_count[p_cnt].ed_dr_name = pa.name_full_formatted, pat->pat_count[p_cnt].discharge_dt_tm
    = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM;;D"), pat->pat_count[p_cnt].disch_ord_dt = format(o
    .orig_order_dt_tm,"MM/DD/YYYY HH:MM;;D"),
   pat->pat_count[p_cnt].discharge_md = pa2.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tid = pat->pat_count[d.seq].tracking_id
  FROM tracking_locator tl,
   (dummyt d  WITH seq = value(pat->pat_cnt))
  PLAN (d)
   JOIN (tl
   WHERE (tl.tracking_id=pat->pat_count[d.seq].tracking_id))
  ORDER BY tid, tl.arrive_dt_tm
  HEAD REPORT
   l_cnt = 0
  HEAD tid
   l_cnt = 0
  DETAIL
   l_cnt += 1, stat = alterlist(pat->pat_count[d.seq].last_location,l_cnt), pat->pat_count[d.seq].
   last_location[l_cnt].unit = uar_get_code_display(tl.loc_nurse_unit_cd),
   pat->pat_count[d.seq].last_location[l_cnt].bed = uar_get_code_display(tl.loc_room_cd), pat->
   pat_count[d.seq].last_location[l_cnt].locator_id = tl.tracking_locator_id, pat->pat_count[d.seq].
   last_location[l_cnt].update_dt_tm = format(tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM tracking_event te,
   (dummyt d1  WITH seq = value(pat->pat_cnt)),
   track_event ter
  PLAN (d1)
   JOIN (te
   WHERE (pat->pat_count[d1.seq].tracking_id=te.tracking_id)
    AND te.event_status_cd=value(uar_get_code_by("displaykey",16369,"COMPLETE")))
   JOIN (ter
   WHERE ter.track_event_id=te.track_event_id
    AND ter.display_key IN ("RNASSIGN", "BEDASSIGN", "ASSESSMENTFORM", "FULLREG", "TRIAGEFORM",
   "SYSTEMUSEESHLD", "ARRIVE", "DOCASSIGN"))
  ORDER BY te.tracking_id, te.complete_dt_tm, te.requested_dt_tm
  HEAD te.tracking_id
   a_cnt = 0
  DETAIL
   a_cnt = (pat->pat_count[d1.seq].tracking_cnt+ 1), pat->pat_count[d1.seq].tracking_cnt = a_cnt,
   stat = alterlist(pat->pat_count[d1.seq].tracking_event,a_cnt),
   pat->pat_count[d1.seq].tracking_event[a_cnt].tracking_event_id = te.tracking_event_id, pat->
   pat_count[d1.seq].tracking_event[a_cnt].event_status_cd = te.event_status_cd, pat->pat_count[d1
   .seq].tracking_event[a_cnt].complete_dt_tm = format(te.complete_dt_tm,";;Q"),
   pat->pat_count[d1.seq].tracking_event[a_cnt].track_event_desc = ter.display_key, pat->pat_count[d1
   .seq].tracking_event[a_cnt].tracking_id = te.track_event_id, pat->pat_count[d1.seq].
   tracking_event[a_cnt].request_dt_tm = format(te.requested_dt_tm,";;Q")
  WITH nocounter
 ;end select
 SET c = 0
 SET c += 1
 SET stat = alterlist(pat_display->qual,c)
 SET pat_display->qual[c].fin = "FIN"
 SET pat_display->qual[c].pat_mrn = "MRN"
 SET pat_display->qual[c].pat_name = "NAME"
 SET pat_display->qual[c].pat_age = "AGE"
 SET pat_display->qual[c].gender = "GENDER"
 SET pat_display->qual[c].first_doc_assign = "DOC ASSIGN"
 SET pat_display->qual[c].first_rn_assign = "RN ASSIGN"
 SET pat_display->qual[c].discharge_md = "DISCH MD"
 SET pat_display->qual[c].disch_ord_dt = "DISCH ORDER DT"
 SET pat_display->qual[c].checking_dt_tm = "CHECKIN DT"
 SET pat_display->qual[c].checkoout_dt_tm = "CHECKOUT DT"
 SET pat_display->qual[c].acutiy = "ACUITY"
 SET pat_display->qual[c].reason_visit = "DX"
 SET pat_display->qual[c].encntr_type_code = "ENCNTR TYPE"
 SET pat_display->qual[c].update_dt_tm = "ARRIVE DT"
 SET pat_display->qual[c].unit = "UNIT"
 SET pat_display->qual[c].bed = "BED"
 SET pat_display->qual[c].ed_dr_name = "ED DOC"
 SET pat_display->qual[c].discharge_dt_tm = "DISCH DT"
 SET pat_display->qual[c].triage_dt_tm = "TRIAGE DT"
 SET pat_display->qual[c].assessment_dt = "ASSESSMENT DT"
 FOR (x = 1 TO size(pat->pat_count,5))
   SET c += 1
   SET stat = alterlist(pat_display->qual,c)
   SET pat_display->qual[c].fin = pat->pat_count[x].fin
   SET pat_display->qual[c].pat_mrn = pat->pat_count[x].pat_mrn
   SET pat_display->qual[c].pat_age = pat->pat_count[x].pat_age
   SET pat_display->qual[c].gender = pat->pat_count[x].gender
   SET pat_display->qual[c].pat_name = pat->pat_count[x].pat_name
   FOR (y = 1 TO size(pat->pat_count[x].tracking_event,5))
     IF ((pat->pat_count[x].tracking_event[y].track_event_desc="DOCASSIGN"))
      SET pat_display->qual[c].first_doc_assign = pat->pat_count[x].tracking_event[y].complete_dt_tm
      SET y = size(pat->pat_count[x].tracking_event,5)
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(pat->pat_count[x].tracking_event,5))
     IF ((pat->pat_count[x].tracking_event[y].track_event_desc="RNASSIGN"))
      SET pat_display->qual[c].first_rn_assign = pat->pat_count[x].tracking_event[y].complete_dt_tm
      SET y = size(pat->pat_count[x].tracking_event,5)
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(pat->pat_count[x].tracking_event,5))
     IF ((pat->pat_count[x].tracking_event[y].track_event_desc="TRIAGEFORM"))
      SET pat_display->qual[c].triage_dt_tm = pat->pat_count[x].tracking_event[y].complete_dt_tm
      SET y = size(pat->pat_count[x].tracking_event,5)
     ENDIF
   ENDFOR
   FOR (y = 1 TO size(pat->pat_count[x].tracking_event,5))
     IF ((pat->pat_count[x].tracking_event[y].track_event_desc="ASSESSMENTFORM"))
      SET pat_display->qual[c].assessment_dt = pat->pat_count[x].tracking_event[y].complete_dt_tm
      SET y = size(pat->pat_count[x].tracking_event,5)
     ENDIF
   ENDFOR
   SET pat_display->qual[c].discharge_md = pat->pat_count[x].discharge_md
   SET pat_display->qual[c].disch_ord_dt = pat->pat_count[x].disch_ord_dt
   SET pat_display->qual[c].checking_dt_tm = pat->pat_count[x].checking_dt_tm
   SET pat_display->qual[c].checkoout_dt_tm = pat->pat_count[x].checkoout_dt_tm
   SET pat_display->qual[c].acutiy = pat->pat_count[x].acutiy
   SET pat_display->qual[c].reason_visit = pat->pat_count[x].reason_visit
   SET pat_display->qual[c].encntr_type_code = pat->pat_count[x].encntr_type_code
   SET pat_display->qual[c].ed_dr_name = pat->pat_count[x].ed_dr_name
   SET pat_display->qual[c].discharge_dt_tm = pat->pat_count[x].discharge_dt_tm
   FOR (y = 1 TO size(pat->pat_count[x].last_location,5))
     SET pat_display->qual[c].locator_id = pat->pat_count[x].last_location[y].locator_id
     SET pat_display->qual[c].update_dt_tm = pat->pat_count[x].last_location[y].update_dt_tm
     SET pat_display->qual[c].unit = pat->pat_count[x].last_location[y].unit
     SET pat_display->qual[c].bed = pat->pat_count[x].last_location[y].bed
     SET c += 1
     SET stat = alterlist(pat_display->qual,c)
   ENDFOR
 ENDFOR
 SET num = 0
 SET start = 1
 SET pos = 0
 SELECT INTO "deeds_rpt.csv"
  pat_display->qual[d.seq].fin, pat_display->qual[d.seq].pat_mrn, pat_display->qual[d.seq].pat_name,
  pat_display->qual[d.seq].pat_age, pat_display->qual[d.seq].gender, pat_display->qual[d.seq].
  first_doc_assign,
  pat_display->qual[d.seq].first_rn_assign, pat_display->qual[d.seq].discharge_md, pat_display->qual[
  d.seq].disch_ord_dt,
  pat_display->qual[d.seq].checking_dt_tm, pat_display->qual[d.seq].checkoout_dt_tm, pat_display->
  qual[d.seq].triage_dt_tm,
  pat_display->qual[d.seq].assessment_dt, pat_display->qual[d.seq].acutiy, pat_display->qual[d.seq].
  reason_visit,
  pat_display->qual[d.seq].encntr_type_code, pat_display->qual[d.seq].ed_dr_name, pat_display->qual[d
  .seq].discharge_dt_tm,
  pat_display->qual[d.seq].update_dt_tm, pat_display->qual[d.seq].unit, pat_display->qual[d.seq].bed
  FROM (dummyt d  WITH seq = value(size(pat_display->qual,5)))
  PLAN (d
   WHERE d.seq > 0)
  WITH format = pcformat
 ;end select
 IF (findfile("deeds_rpt.csv")=1)
  SET filename_in = "deeds_rpt.csv"
  SET filename_out = format(curdate,"MMDDYYYY;;D")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Deeds Rpt ")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_in, $EMAIL,subject_line,1)
 ENDIF
#exit_script
END GO
