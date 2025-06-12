CREATE PROGRAM bhs_rpt_scan_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg_time" = sysdate,
  "end_time" = sysdate
  WITH outdev, beg_time, end_time
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 pid = f8
     2 uname = vc
     2 eid = f8
     2 edate = dq8
     2 tnf[*]
       3 oid = f8
       3 barcode = vc
       3 nucode = f8
       3 patname = vc
       3 finnbr = vc
       3 mrn = vc
       3 alert = vc
       3 ordname = vc
     2 pnf[*]
       3 oid = f8
       3 barcode = vc
       3 nucode = f8
       3 patname = vc
       3 finnbr = vc
       3 mrn = vc
       3 alert = vc
       3 ordname = vc
     2 mnf[*]
       3 oid = f8
       3 barcode = vc
       3 nucode = f8
       3 patname = vc
       3 finnbr = vc
       3 mrn = vc
       3 alert = vc
       3 ordname = vc
 )
 SELECT DISTINCT INTO  $1
  user = pr.name_full_formatted, date = format(m.event_dt_tm,"mm/dd/yyyy hh:mm;;d"),
  m_alert_type_disp = uar_get_code_display(m.alert_type_cd),
  m.bar_code_ident, patient = p.name_full_formatted, account = ea.alias,
  m_nurse_unit_disp = uar_get_code_display(m.nurse_unit_cd)
  FROM med_admin_ident_error m,
   med_admin_alert ma,
   med_admin_med_error mame,
   prsnl pr,
   person p,
   encntr_alias ea
  PLAN (m
   WHERE m.event_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),235959))
   JOIN (pr
   WHERE pr.person_id=m.prsnl_id)
   JOIN (ma
   WHERE ma.prsnl_id=outerjoin(m.prsnl_id)
    AND ma.event_dt_tm=outerjoin(m.event_dt_tm))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(ma.med_admin_alert_id))
   JOIN (p
   WHERE p.person_id=outerjoin(mame.person_id))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(mame.encounter_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.encntr_alias_type_cd=outerjoin(1077))
  ORDER BY m.prsnl_id, m.bar_code_ident, date,
   0
  WITH nocounter, format
 ;end select
END GO
