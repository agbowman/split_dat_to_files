CREATE PROGRAM bhs_ma_rpt_surg_term:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Term Date Start:" = "CURDATE",
  "Term Date End:" = "CURDATE",
  "Surgical Area" = 0
  WITH outdev, s_start_dt, s_stop_dt,
  f_surg_area_cd
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 SELECT INTO  $OUTDEV
  surg_area_disp = uar_get_code_display(pd.surg_area_cd), doc_type_disp = uar_get_code_display(pd
   .doc_type_cd), sc.surg_case_nbr_formatted,
  sc.sched_start_dt_tm, sc.surg_start_dt_tm, pd.doc_term_dt_tm,
  doc_term_reason_disp = uar_get_code_display(pd.doc_term_reason_cd), terminated_by = pr
  .name_full_formatted
  FROM perioperative_document pd,
   surgical_case sc,
   prsnl pr
  PLAN (pd
   WHERE pd.doc_term_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND (pd.surg_area_cd= $F_SURG_AREA_CD)
    AND pd.surg_case_id > 0)
   JOIN (sc
   WHERE sc.surg_case_id=pd.surg_case_id)
   JOIN (pr
   WHERE pr.person_id=pd.doc_term_by_id)
  ORDER BY surg_area_disp, pd.doc_term_dt_tm, sc.surg_case_nbr_formatted,
   doc_type_disp
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
