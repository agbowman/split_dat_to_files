CREATE PROGRAM bhs_rpt_fn_eshld
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "from_date" = "SYSDATE",
  "to_date" = "SYSDATE"
  WITH outdev, from_date, to_date
 SET eshld = "SYSTEMUSEESHLD"
 SET bmc_cd = uar_get_code_by("DISPLAYKEY",16370,"BMCEDHOFTRACKINGGROUP")
 SET f_date =  $FROM_DATE
 SET t_date =  $TO_DATE
 SET fin_cd = uar_get_code_by("displaykey",319,"FINNBR")
 SELECT DISTINCT INTO  $OUTDEV
  last_name = substring(1,100,p.name_last_key), first_name = p.name_first_key, account = substring(1,
   20,ea.alias),
  registration_dt_tm = format(tc.checkin_dt_tm,"@SHORTDATETIME"), visit_reason = trim(e
   .reason_for_visit)
  FROM track_event te,
   tracking_event tie,
   tracking_item ti,
   person p,
   encntr_alias ea,
   encounter e,
   tracking_checkin tc
  PLAN (te
   WHERE te.display_key=eshld
    AND te.tracking_group_cd=bmc_cd)
   JOIN (tie
   WHERE tie.track_event_id=te.track_event_id
    AND ((tie.requested_dt_tm+ 0) BETWEEN cnvtdatetime( $FROM_DATE) AND cnvtdatetime( $TO_DATE))
    AND ((tie.active_ind+ 0)=1))
   JOIN (ti
   WHERE ti.tracking_id=tie.tracking_id
    AND te.active_ind=1)
   JOIN (p
   WHERE p.person_id=ti.person_id)
   JOIN (e
   WHERE e.encntr_id=ti.encntr_id)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=fin_cd))
   JOIN (tc
   WHERE tc.tracking_id=ti.tracking_id)
  ORDER BY p.name_last_key
  WITH time = 60, separator = " ", nocounter,
   format, landscape
 ;end select
END GO
