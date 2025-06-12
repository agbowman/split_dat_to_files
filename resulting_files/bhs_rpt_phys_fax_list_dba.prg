CREATE PROGRAM bhs_rpt_phys_fax_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 SELECT INTO value( $OUTDEV)
  FROM bhs_physician_fax_list b
  PLAN (b
   WHERE b.active_ind=1)
  ORDER BY b.name
  HEAD REPORT
   pn_cnt = 0, col 0, row 0,
   "ID:", col 15, row 0,
   "Name:", col 60, row 0,
   "Fax Number:", ms_tmp_str = fillstring(80,"-"), row + 1,
   col 0, ms_tmp_str
  DETAIL
   pn_cnt = (pn_cnt+ 1), ms_tmp_str = trim(cnvtstring(b.person_id)), row + 1,
   col 0, ms_tmp_str, ms_tmp_str = trim(b.name),
   col 15, ms_tmp_str, ms_tmp_str = trim(b.fax),
   col 60, ms_tmp_str
  FOOT REPORT
   row + 1, ms_tmp_str = fillstring(80,"-"), col 0,
   ms_tmp_str, row + 1, ms_tmp_str = build2(pn_cnt," records.  End of report."),
   col 0, ms_tmp_str
  WITH nocounter
 ;end select
END GO
