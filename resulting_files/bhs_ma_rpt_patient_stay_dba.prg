CREATE PROGRAM bhs_ma_rpt_patient_stay:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Dt" = "CURDATE",
  "End Dt" = "CURDATE"
  WITH outdev, s_start_dt, s_end_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
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
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   encounter e
  PLAN (elh
   WHERE elh.active_ind=1
    AND elh.beg_effective_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND elh.loc_nurse_unit_cd=511342047.00)
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm > cnvtdatetime(mf_start_dt))) )
  ORDER BY elh.encntr_id
  HEAD elh.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = elh.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   encounter e
  PLAN (elh
   WHERE elh.active_ind=1
    AND elh.end_effective_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND elh.loc_nurse_unit_cd=511342047.00
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm > cnvtdatetime(mf_start_dt))) )
  ORDER BY elh.encntr_id
  HEAD elh.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = elh.encntr_id
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   encounter e
  PLAN (elh
   WHERE elh.active_ind=1
    AND cnvtdatetime(mf_start_dt) BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND elh.loc_nurse_unit_cd=511342047.00
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm > cnvtdatetime(mf_start_dt))) )
  ORDER BY elh.encntr_id
  HEAD elh.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = elh.encntr_id
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   encounter e
  PLAN (elh
   WHERE elh.active_ind=1
    AND cnvtdatetime(mf_stop_dt) BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND elh.loc_nurse_unit_cd=511342047.00
    AND  NOT (expand(ml_idx1,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm > cnvtdatetime(mf_start_dt))) )
  ORDER BY elh.encntr_id
  HEAD elh.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = elh.encntr_id
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   CALL echo(m_rec->qual[ml_idx1].f_encntr_id)
 ENDFOR
 CALL echorecord(m_rec)
END GO
