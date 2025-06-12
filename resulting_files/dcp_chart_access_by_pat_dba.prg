CREATE PROGRAM dcp_chart_access_by_pat:dba
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET chart_cd = 0.0
 SET page_num = 1
 SET code_set = 104
 SET cdf_meaning = "CHARTACCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET chart_cd = code_value
 SET mrn_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=4
    AND c.cdf_meaning="MRN")
  DETAIL
   mrn_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curtime < 1200)
  SET target_date = (curdate - 1)
 ELSE
  SET target_date = curdate
 ENDIF
 SELECT INTO value(output_file)
  p.name_full_formatted, pl.name_full_formatted, ppa.ppa_type_cd,
  pa.alias, ppa.ppa_first_dt_tm
  FROM person_prsnl_activity ppa,
   person p,
   prsnl pl,
   person_alias pa,
   dummyt d1,
   dummyt d2
  PLAN (ppa
   WHERE ppa.ppa_type_cd=chart_cd
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime(target_date,0000) AND cnvtdatetime(target_date,2400)
   )
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=ppa.person_id)
   JOIN (pl
   WHERE pl.person_id=ppa.prsnl_id)
   JOIN (d2)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.name_full_formatted, ppa.ppa_first_dt_tm
  HEAD PAGE
   col 0, "CHART ACCESSES FOR ", target_date"MM/DD/YYYY;;Q",
   col 100, "PAGE ", page_num,
   page_num = (page_num+ 1), row + 1, col 4,
   "PATIENT", col 40, "MEDICAL RECORD #",
   col 67, "PERSONNEL", col 103,
   "TIME", row + 1, col 2,
   "--------------------", col 38, "--------------------",
   col 65, "---------------------", col 100,
   "------------", row + 1
  HEAD p.name_full_formatted
   row + 1
  DETAIL
   person_name = substring(1,40,p.name_full_formatted), dr_name = substring(1,40,pl
    .name_full_formatted), med_rec_num = substring(1,15,pa.alias),
   col 4, person_name, col 40,
   med_rec_num, col 67, dr_name,
   col 102, ppa.ppa_first_dt_tm"HH:MM:SS;;M", row + 1
  WITH nocounter
 ;end select
 SET spool "OUTPUT_FILE.DAT" value(request->printer_name)
END GO
