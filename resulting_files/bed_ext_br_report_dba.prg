CREATE PROGRAM bed_ext_br_report:dba
 SELECT INTO "CER_INSTALL:report_tbl.csv"
  FROM br_report b
  ORDER BY b.report_name, b.sequence
  HEAD REPORT
   "report_name,program_name,step_cat,rpt_sequence,report_type_flag"
  DETAIL
   report_name = concat('"',trim(b.report_name),'"'), program_name = concat('"',trim(b.program_name),
    '"'), step_cat = concat('"',trim(b.step_cat_mean),'"'),
   row + 1, line = concat(trim(report_name),",",trim(program_name),",",trim(step_cat),
    ",",trim(cnvtstring(b.sequence)),",",trim(cnvtstring(b.report_type_flag))), line
  WITH maxcol = 500, maxrow = 1, noformfeed,
   format = variable, nocounter
 ;end select
END GO
