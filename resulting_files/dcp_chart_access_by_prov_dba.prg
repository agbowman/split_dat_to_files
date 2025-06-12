CREATE PROGRAM dcp_chart_access_by_prov:dba
 DECLARE chart_cd = f8 WITH noconstant(0.0)
 DECLARE mrn_cd = f8 WITH noconstant(0.0)
 DECLARE page_num = i2 WITH noconstant(1)
 SET chart_cd = uar_get_code_by("MEANING",104,"CHARTACCESS")
 SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
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
  ORDER BY pl.name_full_formatted, p.name_full_formatted, ppa.ppa_first_dt_tm,
   pa.beg_effective_dt_tm DESC
  HEAD PAGE
   col 0, "Chart Accesses For ", target_date"mm/dd/yyyy;;q",
   col 100, "Page ", page_num,
   page_num = (page_num+ 1), row + 1, col 4,
   "Personnel", col 40, "Patient",
   col 76, "Medical Record #", col 103,
   "Time", row + 1, col 2,
   "--------------------", col 38, "---------------------",
   col 74, "---------------------", col 100,
   "------------", row + 1
  HEAD pl.name_full_formatted
   row + 1
  DETAIL
   person_name = substring(1,40,p.name_full_formatted), dr_name = substring(1,40,pl
    .name_full_formatted), med_rec_num = substring(1,15,cnvtalias(pa.alias,pa.alias_pool_cd)),
   col 4, dr_name, col 40,
   person_name, col 76, med_rec_num,
   col 102, ppa.ppa_first_dt_tm"hh:mm:ss;;m", row + 1
  WITH nocounter
 ;end select
 SET spool "OUTPUT_FILE.DAT" value(request->printer_name)
END GO
