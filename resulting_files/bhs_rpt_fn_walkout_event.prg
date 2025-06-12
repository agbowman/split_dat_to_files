CREATE PROGRAM bhs_rpt_fn_walkout_event
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "from_date" = "SYSDATE",
  "to_date" = "SYSDATE"
  WITH outdev, from_date, to_date
 SET lwbsform = "LWBSFORM"
 SET bmc_cd = uar_get_code_by("displaykey",16370,"BMCEDTRACKINGGROUP")
 SET f_date =  $FROM_DATE
 SET t_date =  $TO_DATE
 SELECT DISTINCT INTO  $OUTDEV
  last_name = substring(1,100,p.name_last_key), first_name = p.name_first_key, age = cnvtage(p
   .birth_dt_tm),
  account = substring(1,20,ea.alias), registration_dt_tm = format(e.reg_dt_tm,"@SHORTDATETIME"),
  reason_for_visit = substring(1,50,e.reason_for_visit),
  phone = ph.phone_num_key
  FROM track_event te,
   tracking_event tie,
   tracking_item ti,
   person p,
   phone ph,
   encntr_alias ea,
   encounter e
  PLAN (te
   WHERE te.display_key=lwbsform
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
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.phone_type_cd=outerjoin(170.00))
   JOIN (e
   WHERE e.encntr_id=ti.encntr_id)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=1077))
  ORDER BY p.name_last_key
  WITH time = 30, separator = " ", nocounter,
   format, landscape
 ;end select
END GO
