CREATE PROGRAM bhs_ppid_audit_byuser:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date(mm/dd/yyyy):" = curdate,
  "Ending date(mm/dd/yyyy):" = curdate,
  "Facility:" = 0,
  "Nurse unit(s):" = 0
  WITH out_dev, start_date, end_date,
  facility, nurse_unit
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 pid = f8
     2 oid = f8
     2 eid = f8
     2 loc = vc
     2 pat = vc
     2 user = vc
     2 event = vc
     2 med = vc
     2 date = vc
     2 ppid_med = i2
     2 ppid_pat = i2
     2 ecode = vc
     2 esev = vc
     2 etext = vc
     2 pos = vc
 )
 FREE RECORD temp2
 RECORD temp2(
   1 cnt = i2
   1 qual[*]
     2 pid = f8
     2 oid = f8
     2 eid = f8
     2 loc = vc
     2 pat = vc
     2 user = vc
     2 event = vc
     2 med = vc
     2 date = vc
     2 ppid_med = i2
     2 ppid_pat = i2
     2 ecode = vc
     2 esev = vc
     2 etext = vc
     2 pos = vc
 )
 SELECT INTO "nl:"
  maa_nurse_unit_disp = uar_get_code_display(mae.nurse_unit_cd), o.person_id, mae.order_id,
  mae.event_id, patient = p.name_full_formatted, event = uar_get_code_display(mae.event_type_cd),
  mae.event_type_cd, med = o.ordered_as_mnemonic, date = format(mae.beg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
  pos_med_scan = mae.positive_med_ident_ind, pos_patient_scan = mae.positive_patient_ident_ind, mame
  .order_id,
  mame.person_id, maa_alert_severity_disp = uar_get_code_display(maa.alert_severity_cd),
  maa_alert_type_disp = uar_get_code_display(maa.alert_type_cd)
  FROM med_admin_event mae,
   orders o,
   person p,
   prsnl pr,
   med_admin_med_error mame,
   med_admin_alert maa
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(cnvtdate( $START_DATE),0) AND cnvtdatetime(cnvtdate(
      $END_DATE),235959)
    AND ((mae.event_type_cd+ 0) > 0)
    AND ((mae.nurse_unit_cd+ 0)= $NURSE_UNIT)
    AND mae.positive_med_ident_ind=0)
   JOIN (o
   WHERE o.order_id=mae.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pr
   WHERE pr.person_id=mae.prsnl_id)
   JOIN (mame
   WHERE mame.order_id=outerjoin(o.order_id)
    AND mame.action_sequence=outerjoin(o.last_action_sequence))
   JOIN (maa
   WHERE maa.med_admin_alert_id=outerjoin(mame.med_admin_alert_id))
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].date =
   date,
   temp->qual[temp->cnt].ecode = maa_alert_type_disp, temp->qual[temp->cnt].esev =
   maa_alert_severity_disp, temp->qual[temp->cnt].etext = trim(mame.freetext_reason,3),
   temp->qual[temp->cnt].pid = o.person_id, temp->qual[temp->cnt].oid = o.order_id, temp->qual[temp->
   cnt].eid = o.encntr_id,
   temp->qual[temp->cnt].loc = maa_nurse_unit_disp, temp->qual[temp->cnt].pat = patient, temp->qual[
   temp->cnt].event = event,
   temp->qual[temp->cnt].med = med, temp->qual[temp->cnt].ppid_med = mae.positive_med_ident_ind, temp
   ->qual[temp->cnt].ppid_pat = mae.positive_patient_ident_ind,
   temp->qual[temp->cnt].pos = uar_get_code_display(mae.position_cd), temp->qual[temp->cnt].user = pr
   .name_full_formatted
  WITH format, maxrec = 100
 ;end select
 SELECT INTO "nl:"
  FROM med_admin_med_error mame,
   med_admin_alert maa,
   orders o,
   person p,
   prsnl pr
  PLAN (mame
   WHERE mame.admin_dt_tm BETWEEN cnvtdatetime(cnvtdate( $START_DATE),0) AND cnvtdatetime(cnvtdate(
      $END_DATE),235959)
    AND  NOT ( EXISTS (
   (SELECT
    mae.order_id
    FROM med_admin_event mae
    WHERE mae.order_id=mame.order_id))))
   JOIN (maa
   WHERE maa.med_admin_alert_id=mame.med_admin_alert_id
    AND ((maa.nurse_unit_cd+ 0)= $NURSE_UNIT))
   JOIN (o
   WHERE o.order_id=mame.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pr
   WHERE pr.person_id=maa.prsnl_id)
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].date =
   format(mame.admin_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   temp->qual[temp->cnt].ecode = uar_get_code_display(maa.alert_type_cd), temp->qual[temp->cnt].esev
    = uar_get_code_display(maa.alert_severity_cd), temp->qual[temp->cnt].etext = trim(mame
    .freetext_reason,3),
   temp->qual[temp->cnt].pid = o.person_id, temp->qual[temp->cnt].oid = o.order_id, temp->qual[temp->
   cnt].eid = o.encntr_id,
   temp->qual[temp->cnt].loc = uar_get_code_display(maa.nurse_unit_cd), temp->qual[temp->cnt].pat = p
   .name_full_formatted, temp->qual[temp->cnt].event = "Not Administered",
   temp->qual[temp->cnt].med = o.order_mnemonic, temp->qual[temp->cnt].ppid_med = 1, temp->qual[temp
   ->cnt].ppid_pat = 1,
   temp->qual[temp->cnt].pos = uar_get_code_display(maa.position_cd), temp->qual[temp->cnt].user = pr
   .name_full_formatted
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d
   WHERE d.seq > 0)
  ORDER BY temp->qual[d.seq].loc, temp->qual[d.seq].user, temp->qual[d.seq].esev,
   temp->qual[d.seq].ecode, temp->qual[d.seq].date, temp->qual[d.seq].oid,
   0
  DETAIL
   temp2->cnt = (temp2->cnt+ 1), stat = alterlist(temp2->qual,temp2->cnt), temp2->qual[temp2->cnt].
   pid = temp->qual[d.seq].pid,
   temp2->qual[temp2->cnt].oid = temp->qual[d.seq].oid, temp2->qual[temp2->cnt].eid = temp->qual[d
   .seq].eid, temp2->qual[temp2->cnt].loc = temp->qual[d.seq].loc,
   temp2->qual[temp2->cnt].pat = temp->qual[d.seq].pat, temp2->qual[temp2->cnt].user = temp->qual[d
   .seq].user, temp2->qual[temp2->cnt].event = temp->qual[d.seq].event,
   temp2->qual[temp2->cnt].med = temp->qual[d.seq].med, temp2->qual[temp2->cnt].date = temp->qual[d
   .seq].date, temp2->qual[temp2->cnt].ppid_med = temp->qual[d.seq].ppid_med,
   temp2->qual[temp2->cnt].ecode = temp->qual[d.seq].ecode, temp2->qual[temp2->cnt].esev = temp->
   qual[d.seq].esev, temp2->qual[temp2->cnt].ppid_pat = temp->qual[d.seq].ppid_pat,
   temp2->qual[temp2->cnt].etext = temp->qual[d.seq].etext, temp2->qual[temp2->cnt].pos = temp->qual[
   d.seq].pos
  WITH nocounter
 ;end select
 SELECT INTO  $OUT_DEV
  loc = substring(1,20,temp2->qual[d.seq].loc), nurse = substring(1,50,temp2->qual[d.seq].user),
  patient = substring(1,50,temp2->qual[d.seq].pat),
  date = temp2->qual[d.seq].date, event = substring(1,30,temp2->qual[d.seq].event), med = substring(1,
   100,temp2->qual[d.seq].med),
  med_scan = temp2->qual[d.seq].ppid_med
  FROM (dummyt d  WITH seq = value(temp2->cnt))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter, format, separator = " "
 ;end select
END GO
