CREATE PROGRAM djh_dcp_chart_access_by_prov2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE page_num = i2 WITH noconstant(1)
 DECLARE chart_cd = f8 WITH constant(uar_get_code_by("MEANING",104,"CHARTACCESS"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 IF (curtime < 1200)
  SET target_date = (curdate - 1)
 ELSE
  SET target_date = (curdate - 1)
 ENDIF
 SELECT INTO  $OUTDEV
  p.name_full_formatted, pl.name_full_formatted, ppa.ppa_type_cd,
  pa.alias, ppa.ppa_first_dt_tm
  FROM person_prsnl_activity ppa,
   person p,
   prsnl pl,
   person_alias pa
  PLAN (ppa
   WHERE ppa.ppa_type_cd=chart_cd
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime(target_date,0000) AND cnvtdatetime(target_date,2400)
   )
   JOIN (p
   WHERE p.person_id=ppa.person_id)
   JOIN (pl
   WHERE pl.person_id=ppa.prsnl_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY pl.name_full_formatted, p.name_full_formatted, ppa.ppa_first_dt_tm
  HEAD PAGE
   col 0, "CHART ACCESSES FOR ", target_date"MM/DD/YYYY;;Q",
   col 100, "PAGE ", page_num,
   page_num = (page_num+ 1), row + 1, col 4,
   "PERSONNEL", col 40, "PATIENT",
   col 76, "MEDICAL RECORD #", col 103,
   "TIME", row + 1, col 2,
   "--------------------", col 38, "---------------------",
   col 74, "---------------------", col 100,
   "------------", row + 1
  HEAD pl.name_full_formatted
   row + 1
  DETAIL
   person_name = substring(1,40,p.name_full_formatted), dr_name = substring(1,40,pl
    .name_full_formatted), med_rec_num = substring(1,15,pa.alias),
   col 4, dr_name, col 40,
   person_name, col 76, med_rec_num,
   col 102, ppa.ppa_first_dt_tm"HH:MM:SS;;M", row + 1
  WITH nocounter, maxcol = 150, formfeed = none,
   maxrec = 100
 ;end select
END GO
