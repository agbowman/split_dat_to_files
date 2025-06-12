CREATE PROGRAM dcp_retrieve_deprctd_subcomps:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE"
  WITH outdev
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE page_nbr = i4 WITH noconstant(0)
 SELECT INTO  $1
  vp.view_comp_prefs_id, vp.prsnl_id, position_display = uar_get_code_display(vp.position_cd),
  vp.application_number, vp.comp_name, vp.view_name,
  vp.view_seq
  FROM view_comp_prefs vp
  WHERE vp.view_name IN ("HOMEVIEW", "CHARTSUMM", "CHARTSUMMARY", "ACE")
   AND vp.comp_name IN ("PATHWAYS", "ISTRIP", "EASYSCRIPT", "MEDPROFILE", "ENCSUMMARY",
  "ENCNTRSUMM", "LVFLOWSHEET", "INBOX", "HOME", "GRAPHVIEW",
  "CURPATHWAY", "NEWPATHWAY", "GROWTHCHART", "ENCOUNTER", "PROBLIST",
  "PROCEDURES")
  ORDER BY vp.view_name, vp.comp_name, vp.application_number,
   position_display, vp.prsnl_id
  HEAD REPORT
   cnt = 0
  HEAD PAGE
   page_nbr = (page_nbr+ 1), col 0, "Page: ",
   col 6, page_nbr, row + 1,
   col 0, "VIEW_COMP_PREFS_ID", col 22,
   "APP_NUMBER", col 34, "POSITION",
   col 74, "PRSNL_ID", col 89,
   "COMP_TYPE", col 104, "VIEW_NAME",
   col 119, "VIEW_SEQ", row + 2
  DETAIL
   cnt = (cnt+ 1), col 0, vp.view_comp_prefs_id,
   col 22, vp.application_number, col 34,
   position_display, col 74, vp.prsnl_id,
   col 89, vp.comp_name, col 104,
   vp.view_name, col 119, vp.view_seq,
   row + 1
  FOOT REPORT
   row + 1, col 0, "Total Views containing deprecated components: ",
   col 58, cnt
  WITH nocounter
 ;end select
END GO
