CREATE PROGRAM bhs_ops_surg_term:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Term Date Start:" = "CURDATE",
  "Term Date End:" = "CURDATE"
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
     2 s_doc_type = vc
     2 s_surg_case = vc
     2 s_surg_sched_start_dt = vc
     2 s_surg_start_dt = vc
     2 s_doc_term_dt = vc
     2 s_doc_term_reason = vc
     2 s_doc_term_by = vc
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
  FROM perioperative_document pd,
   surgical_case sc,
   prsnl pr
  PLAN (pd
   WHERE pd.doc_term_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND expand(ml_idx1,1,m_loc->l_cnt,pd.surg_area_cd,m_loc->qual[ml_idx1].f_loc_cd)
    AND pd.surg_case_id > 0)
   JOIN (sc
   WHERE sc.surg_case_id=pd.surg_case_id)
   JOIN (pr
   WHERE pr.person_id=pd.doc_term_by_id)
  ORDER BY uar_get_code_display(pd.surg_area_cd), pd.doc_term_dt_tm, sc.surg_case_nbr_formatted,
   uar_get_code_display(pd.doc_type_cd)
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   s_surg_area = trim(uar_get_code_display(pd.surg_area_cd),3),
   m_rec->qual[m_rec->l_cnt].s_doc_type = trim(uar_get_code_display(pd.doc_type_cd),3), m_rec->qual[
   m_rec->l_cnt].s_surg_case = trim(sc.surg_case_nbr_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_surg_sched_start_dt = trim(format(sc.sched_start_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_surg_start_dt = trim(format(sc.surg_start_dt_tm,"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_doc_term_dt = trim(format(pd.doc_term_dt_tm,"MM/DD/YYYY;;q"),3), m_rec
   ->qual[m_rec->l_cnt].s_doc_term_reason = trim(uar_get_code_display(pd.doc_term_reason_cd),3),
   m_rec->qual[m_rec->l_cnt].s_doc_term_by = trim(pr.name_full_formatted,3)
  WITH nocounter
 ;end select
 SET frec->file_name = concat("/cerner/d_p627/bhscust/surginet/extract/daily/","terminated.csv")
 IF ((m_rec->l_cnt > 0))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"',"SURG_AREA_DISP",'","',"DOC_TYPE_DISP",'","',
   "SURG_CASE_NBR_FORMATTED",'","',"SCHED_START_DT_TM",'","',"SURG_START_DT_TM",
   '","',"DOC_TERM_DT_TM",'","',"DOC_TERM_REASON_DISP",'","',
   "TERMINATED_BY",'"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_surg_area,3),'","',trim(m_rec->qual[
     ml_idx1].s_doc_type,3),'","',
    trim(m_rec->qual[ml_idx1].s_surg_case,3),'","',trim(m_rec->qual[ml_idx1].s_surg_sched_start_dt,3),
    '","',trim(m_rec->qual[ml_idx1].s_surg_start_dt,3),
    '","',trim(m_rec->qual[ml_idx1].s_doc_term_dt,3),'","',trim(m_rec->qual[ml_idx1].
     s_doc_term_reason,3),'","',
    trim(m_rec->qual[ml_idx1].s_doc_term_by,3),'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
#exit_script
END GO
