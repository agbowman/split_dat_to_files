CREATE PROGRAM bhs_rpt_absorbed_charges:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = curdate,
  "End Date" = "CURDATE"
  WITH outdev, begindate, enddate
 SELECT INTO  $OUTDEV
  c.charge_item_id, c.service_dt_tm, c.updt_dt_tm,
  name = substring(1,50,p.name_full_formatted), cdm = substring(1,10,cm.field6), cm.active_ind,
  c.charge_description
  FROM charge c,
   prsnl p,
   charge_mod cm
  PLAN (c
   WHERE c.process_flg=7
    AND c.service_dt_tm BETWEEN cnvtdatetime( $BEGINDATE) AND cnvtdatetime( $ENDDATE))
   JOIN (p
   WHERE c.updt_id=p.person_id)
   JOIN (cm
   WHERE cm.active_ind=1
    AND c.charge_item_id=cm.charge_item_id)
  ORDER BY c.service_dt_tm
  WITH nocounter, format, format(date,";;;q"),
   separator = " "
 ;end select
END GO
