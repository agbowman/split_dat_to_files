CREATE PROGRAM bhs_ma_rpt_surg_nonfin_open:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Surgical Area:" = 0
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
  surg_area = trim(substring(1,100,uar_get_code_display(sc.surg_area_cd)),3), case_start_date =
  format(sc.surg_start_dt_tm,"MM/DD/YYYY;;q"), patient = trim(substring(1,150,p.name_full_formatted),
   3),
  docyment_type = trim(substring(1,100,uar_get_code_display(pd.doc_type_cd)),3), or_case_number =
  trim(substring(1,100,sc.surg_case_nbr_formatted),3), primary_surgeon = trim(substring(1,150,pr2
    .name_full_formatted),3),
  primary_procedure = trim(substring(1,250,oc.primary_mnemonic),3), personnel = trim(substring(1,150,
    pr1.name_full_formatted),3)
  FROM surgical_case sc,
   perioperative_document pd,
   prsnl pr1,
   prsnl pr2,
   surg_case_procedure scp,
   order_catalog oc,
   person p,
   encounter e
  PLAN (sc
   WHERE (sc.surg_area_cd= $F_SURG_AREA_CD)
    AND (sc.sched_surg_area_cd= $F_SURG_AREA_CD)
    AND ((sc.surg_start_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)) OR (sc
   .surg_start_dt_tm = null))
    AND sc.sched_start_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt))
   JOIN (pd
   WHERE pd.surg_case_id=sc.surg_case_id
    AND pd.rec_ver_dt_tm = null
    AND pd.doc_term_reason_cd IN (0, null)
    AND pd.doc_type_cd > 0)
   JOIN (pr1
   WHERE pr1.person_id=pd.updt_id)
   JOIN (pr2
   WHERE pr2.person_id=sc.surgeon_prsnl_id)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id
    AND scp.active_ind=1
    AND scp.primary_proc_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=scp.sched_surg_proc_cd)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id
    AND e.encntr_id > 0.0)
  ORDER BY surg_area, cnvtdatetime(sc.surg_start_dt_tm), sc.person_id,
   sc.surg_case_id, pd.doc_type_cd
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
