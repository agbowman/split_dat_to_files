CREATE PROGRAM dcp_retrieve_deprctd_views:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE"
  WITH outdev
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE page_nbr = i4 WITH noconstant(0)
 SELECT INTO  $1
  vp.view_prefs_id, vp.prsnl_id, position_display = uar_get_code_display(vp.position_cd),
  vp.application_number, vp.frame_type, vp.view_name,
  vp.view_seq
  FROM view_prefs vp
  WHERE vp.view_name IN ("PATHWAYS", "ISTRIP", "EASYSCRIPT", "MEDPROFILE", "ENCSUMMARY",
  "ENCNTRSUMM", "LVFLOWSHEET", "INBOX", "GRAPHVIEW", "CURPATHWAY",
  "NEWPATHWAY", "GROWTHCHART", "ENCOUNTER", "PROBLIST", "PROCEDURES")
  ORDER BY vp.view_name, vp.frame_type, vp.application_number,
   position_display, vp.prsnl_id
  HEAD REPORT
   cnt = 0
  HEAD PAGE
   page_nbr = (page_nbr+ 1), col 0, "Page: ",
   col 6, page_nbr, row + 1,
   col 0, "VIEW_PREFS_ID", col 15,
   "APP_NUMBER", col 27, "POSITION",
   col 67, "PRSNL_ID", col 82,
   "FRAME_TYPE", col 97, "VIEW_NAME",
   col 112, "VIEW_SEQ", row + 2
  DETAIL
   cnt = (cnt+ 1), col 0, vp.view_prefs_id,
   col 15, vp.application_number, col 27,
   position_display, col 67, vp.prsnl_id,
   col 82, vp.frame_type, col 97,
   vp.view_name, col 112, vp.view_seq,
   row + 1
  FOOT REPORT
   row + 1, col 0, "Total Deprecated Views: ",
   col 24, cnt
  WITH nocounter
 ;end select
END GO
