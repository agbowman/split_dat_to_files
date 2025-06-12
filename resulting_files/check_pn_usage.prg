CREATE PROGRAM check_pn_usage
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 30
 ENDIF
 SELECT INTO  $OUTDEV
  s.display, p.name_full_formatted, story_count = count(sst.scd_story_id)
  FROM scr_pattern s,
   scd_story_pattern ss,
   scd_story sst,
   prsnl p
  PLAN (s
   WHERE s.display="Gyn*"
    AND s.pattern_type_cd=9449.00)
   JOIN (ss
   WHERE s.scr_pattern_id=ss.scr_pattern_id)
   JOIN (sst
   WHERE ss.scd_story_id=sst.scd_story_id
    AND sst.active_status_dt_tm >= cnvtdatetime("01-JUL-2007"))
   JOIN (p
   WHERE sst.author_id=p.person_id)
  GROUP BY s.display, p.name_full_formatted
  ORDER BY p.name_full_formatted
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
