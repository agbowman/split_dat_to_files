CREATE PROGRAM bhs_ops_surg_nonfin_open:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
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
 FREE RECORD m_loc
 RECORD m_loc(
   1 l_cnt = i4
   1 qual[*]
     2 f_loc_cd = f8
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_surg_area = vc
     2 s_surg_start_dt = vc
     2 s_patient = vc
     2 s_doc_type = vc
     2 s_surg_case = vc
     2 s_prim_surgeon = vc
     2 s_prim_proc = vc
     2 s_prsnl = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=221
   AND cv.cdf_meaning="SURGAREA"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND cv.display_key IN ("BFMCENDOSCOPYMINORPROCEDURES", "BFMCLABORANDDELIVERY",
  "BFMCSURGICALSERVICES", "BMCENDOSCOPYCENTER", "BMCINPTOR",
  "BMCLABORANDDELIVERY", "BNHENDOSCOPYCENTER", "BNHSURGICALSERVICES", "BWHENDOSCOPYSPECIALPROCEDURES",
  "BWHSURGICALSERVICES",
  "CHESTNUTSURGERYCENTER", "PEDIATRICPROCEDUREUNIT")
  ORDER BY cv.display
  DETAIL
   m_loc->l_cnt += 1, stat = alterlist(m_loc->qual,m_loc->l_cnt), m_loc->qual[m_loc->l_cnt].f_loc_cd
    = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   perioperative_document pd,
   prsnl pr1,
   prsnl pr2,
   surg_case_procedure scp,
   order_catalog oc,
   person p,
   encounter e
  PLAN (sc
   WHERE expand(ml_idx1,1,m_loc->l_cnt,sc.surg_area_cd,m_loc->qual[ml_idx1].f_loc_cd)
    AND expand(ml_idx1,1,m_loc->l_cnt,sc.sched_surg_area_cd,m_loc->qual[ml_idx1].f_loc_cd)
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
  ORDER BY uar_get_code_display(sc.surg_area_cd), sc.surg_start_dt_tm, sc.person_id,
   sc.surg_case_id, pd.doc_type_cd
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   s_surg_area = trim(uar_get_code_display(sc.surg_area_cd),3),
   m_rec->qual[m_rec->l_cnt].s_surg_start_dt = trim(format(sc.surg_start_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_patient = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_doc_type = trim(uar_get_code_display(pd.doc_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_surg_case = trim(sc.surg_case_nbr_formatted,3), m_rec->qual[m_rec->
   l_cnt].s_prim_surgeon = trim(pr2.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_prim_proc =
   trim(oc.primary_mnemonic,3),
   m_rec->qual[m_rec->l_cnt].s_prsnl = trim(pr1.name_full_formatted,3)
  WITH nocounter
 ;end select
 SET frec->file_name = concat("/cerner/d_p627/bhscust/surginet/extract/daily/","unfinalized.csv")
 IF ((m_rec->l_cnt > 0))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"',"SURG_AREA",'","',"CASE_START_DATE",'","',
   "PATIENT",'","',"DOCUMENT_TYPE",'","',"OR_CASE_NUMBER",
   '","',"PRIMARY_SURGEON",'","',"PRIMARY_PROCEDURE",'","',
   "PERSONNEL",'"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_surg_area,3),'","',trim(m_rec->qual[
     ml_idx1].s_surg_start_dt,3),'","',
    trim(m_rec->qual[ml_idx1].s_patient,3),'","',trim(m_rec->qual[ml_idx1].s_doc_type,3),'","',trim(
     m_rec->qual[ml_idx1].s_surg_case,3),
    '","',trim(m_rec->qual[ml_idx1].s_prim_surgeon,3),'","',trim(m_rec->qual[ml_idx1].s_prim_proc,3),
    '","',
    trim(m_rec->qual[ml_idx1].s_prsnl,3),'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
#exit_script
END GO
