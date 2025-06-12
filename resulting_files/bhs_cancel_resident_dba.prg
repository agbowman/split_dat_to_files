CREATE PROGRAM bhs_cancel_resident:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  FROM encntr_prsnl_reltn epr
  WHERE epr.encntr_id=36188344.00
   AND epr.active_ind=1
   AND epr.encntr_prsnl_r_cd=1052201
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD REPORT
   c = 1
  HEAD epr.encntr_id
   col 1, "relation to keep:", epr.prsnl_person_id,
   row + 1
  WITH nocounter
 ;end select
END GO
