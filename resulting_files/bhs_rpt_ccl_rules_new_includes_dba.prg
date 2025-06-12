CREATE PROGRAM bhs_rpt_ccl_rules_new_includes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Since:" = "CURDATE"
  WITH outdev, s_date
 FREE RECORD m_rec
 RECORD m_rec(
   1 ccl[*]
     2 s_name = vc
     2 s_userid = vc
     2 s_path = vc
     2 s_user = vc
     2 s_date = vc
     2 n_group = i2
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_DATE," 00:00:00"))
 DECLARE ms_output = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO value(ms_output)
  p.name_last, d.user_name, d.object_name,
  d.source_name
  FROM dprotect d,
   prsnl p,
   dummyt d1
  PLAN (d
   WHERE d.object="P"
    AND cnvtdatetime(concat(format(d.datestamp,"dd-mmm-yyyy;;d")," 00:00:00")) > cnvtdatetime(
    ms_beg_dt_tm))
   JOIN (d1)
   JOIN (p
   WHERE p.username=d.user_name)
  ORDER BY p.name_last, d.datestamp DESC
  HEAD REPORT
   pl_cnt = 0, pl_beg_pos = 0, pl_end_pos = 0,
   pl_cont = 0, col 0, "User_Name",
   col 25, "User_ID", col 35,
   "Script", col 70, "Date",
   col 80, "Group", col 87,
   "Path"
  DETAIL
   pl_cont = 0, pl_beg_pos = 0, pl_end_pos = 0,
   ms_tmp = trim(d.source_name), pl_beg_pos = findstring("$",ms_tmp)
   IF (pl_beg_pos=0)
    IF (findstring("bhscust:",ms_tmp)=0)
     pl_cont = 1
    ENDIF
   ELSE
    pl_beg_pos = (pl_beg_pos+ 2)
    IF (findstring("\",ms_tmp,pl_beg_pos) > 0)
     pl_cont = 1
    ENDIF
   ENDIF
   IF (d.group=1)
    pl_cont = 1
   ENDIF
   IF (pl_cont=1)
    pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > size(m_rec->ccl,5))
     stat = alterlist(m_rec->ccl,(pl_cnt+ 25))
    ENDIF
    m_rec->ccl[pl_cnt].n_group = d.group, m_rec->ccl[pl_cnt].s_date = trim(format(d.datestamp,
      "mm/dd/yyyy;;d")), m_rec->ccl[pl_cnt].s_name = trim(d.object_name),
    m_rec->ccl[pl_cnt].s_path = trim(d.source_name), m_rec->ccl[pl_cnt].s_user = trim(d.user_name),
    row + 1
    IF (d.user_name="EN15469")
     ms_tmp = "Kauffman, Bob"
    ELSE
     ms_tmp = trim(p.name_full_formatted)
    ENDIF
    col 0, ms_tmp, col 25,
    d.user_name, col 35, d.object_name,
    ms_tmp = trim(format(d.datestamp,"mm/dd/yyyy;;d")), col 70, ms_tmp,
    ms_tmp = trim(cnvtstring(d.group)), col 80, ms_tmp,
    ms_tmp = trim(d.source_name,3), col 87, ms_tmp
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->ccl,pl_cnt)
  WITH nocounter, outerjoin = d1, maxrow = 1,
   maxcol = 2000, format, separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
