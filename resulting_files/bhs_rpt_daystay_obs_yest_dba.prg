CREATE PROGRAM bhs_rpt_daystay_obs_yest:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE m_start_dt_tm = vc WITH protect, constant(format(cnvtlookbehind("1,D",sysdate),
   "DD-MMM-YYYY 00:00:00;;q"))
 DECLARE m_end_dt_tm = vc WITH protect, constant(format(cnvtlookbehind("1,D",sysdate),
   "DD-MMM-YYYY 23:59:59;;q"))
 DECLARE mc_disp = vc
 DECLARE mc_date = vc
 SELECT INTO  $OUTDEV
  FROM encounter e,
   encntr_alias ea
  PLAN (e
   WHERE e.encntr_type_cd IN (679668.00, 309312.00)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(m_start_dt_tm) AND cnvtdatetime(m_end_dt_tm))
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(1079))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate)) )
  HEAD REPORT
   mc_date = format(sysdate,"DD-MMM-YYYY;;q"), col 0, "DAYSTAY /  OBS patients registered: ",
   col + 1, mc_date, row + 1,
   col 0, "MRN,LOCATION,ENCNTR_TYPE", row + 1
  DETAIL
   mc_disp = build(ea.alias,",",uar_get_code_display(e.loc_facility_cd),",",uar_get_code_display(e
     .encntr_type_cd)), col 0, mc_disp,
   row + 1
  WITH nocounter, format = variable, maxcol = 2000,
   formfeed = none
 ;end select
END GO
