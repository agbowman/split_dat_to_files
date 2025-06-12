CREATE PROGRAM bhs_rpt_pss_powernote_count:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, bdate, edate
 SELECT INTO  $OUTDEV
  p.name_full_formatted, sp.display, note_count = count(s.scd_story_id)
  FROM scd_story s,
   prsnl p,
   scd_story_pattern ss,
   scr_pattern sp
  PLAN (p
   WHERE p.username IN ("PN53040", "PN53364", "PN54378", "PN55428", "PN53307",
   "PN53501", "PN55483", "EN04633"))
   JOIN (s
   WHERE p.person_id=s.author_id
    AND s.active_status_dt_tm BETWEEN cnvtdatetime(cnvtdate( $BDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),2359)
    AND s.story_completion_status_cd=10396)
   JOIN (ss
   WHERE s.scd_story_id=ss.scd_story_id
    AND ss.pattern_type_cd=9449.00)
   JOIN (sp
   WHERE ss.scr_pattern_id=sp.scr_pattern_id)
  GROUP BY p.name_full_formatted, sp.display
  WITH nocounter, separator = " ", format
 ;end select
END GO
