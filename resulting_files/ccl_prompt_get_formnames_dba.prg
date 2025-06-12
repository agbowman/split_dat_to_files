CREATE PROGRAM ccl_prompt_get_formnames:dba
 PROMPT
  "group number" = 0,
  "program name" = "*",
  "sort by" = 0
  WITH grpno, prgname, srtby
 EXECUTE ccl_prompt_api_dataset "dataset"
 SET prgpat = cnvtupper( $PRGNAME)
 IF (( $SRTBY=0))
  SELECT INTO "nl:"
   cpd.group_no, cpd.program_name, cpd.updt_dt_tm,
   cpd.updt_cnt, p.username
   FROM ccl_prompt_definitions cpd,
    prsnl p
   PLAN (cpd
    WHERE (cpd.group_no= $GRPNO)
     AND cpd.program_name=patstring(prgpat)
     AND cpd.position=0)
    JOIN (p
    WHERE cpd.updt_id=outerjoin(p.person_id))
   ORDER BY cpd.group_no, cpd.program_name
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = setfieldtitleno(1,"Group"), stat = setfieldtitleno(2,"Form Name"), stat = setfieldtitleno(
     3,"Updated"),
    stat = setfieldtitleno(4,"Update Count"), stat = setfieldtitleno(5,"Username"), stat =
    closedataset(0)
   WITH reporthelp, check, memsort
  ;end select
 ELSEIF (( $SRTBY=1))
  SELECT INTO "nl:"
   p.username, cpd.group_no, cpd.program_name,
   cpd.updt_dt_tm, cpd.updt_cnt
   FROM ccl_prompt_definitions cpd,
    prsnl p
   PLAN (cpd
    WHERE (cpd.group_no= $GRPNO)
     AND cpd.position=0)
    JOIN (p
    WHERE cpd.updt_id=outerjoin(p.person_id)
     AND p.username=patstring(prgpat))
   ORDER BY p.username, cpd.group_no, cpd.program_name
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = setfieldtitleno(1,"Username"), stat = setfieldtitleno(2,"Group"), stat = setfieldtitleno(3,
     "Form Name"),
    stat = setfieldtitleno(4,"Updated"), stat = setfieldtitleno(5,"Update Count"), stat =
    closedataset(0)
   WITH reporthelp, check, memsort
  ;end select
 ELSEIF (( $SRTBY=2))
  SELECT INTO "nl:"
   cpd.updt_dt_tm, cpd.updt_cnt, cpd.group_no,
   cpd.program_name, p.username
   FROM ccl_prompt_definitions cpd,
    prsnl p
   PLAN (cpd
    WHERE (cpd.group_no= $GRPNO)
     AND cpd.program_name=patstring(prgpat)
     AND cpd.position=0)
    JOIN (p
    WHERE cpd.updt_id=outerjoin(p.person_id))
   ORDER BY p.username, cpd.group_no, cpd.program_name
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = setfieldtitleno(1,"Updated"), stat = setfieldtitleno(2,"Update Count"), stat =
    setfieldtitleno(3,"Group"),
    stat = setfieldtitleno(4,"Form Name"), stat = setfieldtitleno(5,"Username"), stat = closedataset(
     0)
   WITH reporthelp, check, memsort
  ;end select
 ENDIF
END GO
