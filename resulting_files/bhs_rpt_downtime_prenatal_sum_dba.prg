CREATE PROGRAM bhs_rpt_downtime_prenatal_sum:dba
 DECLARE ms_printer_name = vc WITH protect, constant(trim( $1,3))
 DECLARE ms_nurs_unit = vc WITH protect, constant(cnvtupper(trim( $2,3)))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD m_nunit
 RECORD m_nunit(
   1 l_cnt = i4
   1 qual[*]
     2 f_unit_cv = f8
 ) WITH protect
 FREE RECORD m_pat
 RECORD m_pat(
   1 l_cnt = i4
   1 s_rpt_date = vc
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_filename = vc
     2 s_pat_fname = vc
     2 s_pat_lname = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key=ms_nurs_unit
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND cv.data_status_cd=25)
  HEAD REPORT
   m_nunit->l_cnt = 0
  DETAIL
   m_nunit->l_cnt = (m_nunit->l_cnt+ 1), stat = alterlist(m_nunit->qual,m_nunit->l_cnt), m_nunit->
   qual[m_nunit->l_cnt].f_unit_cv = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE expand(ml_idx1,1,m_nunit->l_cnt,e.loc_nurse_unit_cd,m_nunit->qual[ml_idx1].f_unit_cv)
    AND e.reg_dt_tm IS NOT null
    AND e.disch_dt_tm = null
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   m_pat->l_cnt = 0, m_pat->s_rpt_date = format(curdate,"DD-MMM-YYYY;;q")
  DETAIL
   m_pat->l_cnt = (m_pat->l_cnt+ 1), stat = alterlist(m_pat->qual,m_pat->l_cnt), m_pat->qual[m_pat->
   l_cnt].f_encntr_id = e.encntr_id,
   m_pat->qual[m_pat->l_cnt].f_person_id = e.person_id, m_pat->qual[m_pat->l_cnt].s_pat_fname = trim(
    p.name_first_key,3), m_pat->qual[m_pat->l_cnt].s_pat_lname = trim(p.name_last_key,3),
   m_pat->qual[m_pat->l_cnt].s_filename = build(trim(substring(1,5,trim(cnvtlower(cnvtalphanum(p
         .name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p
         .name_first_key,2)),4)),3),".ps")
  WITH nocounter
 ;end select
 CALL echorecord(m_nunit)
 CALL echorecord(m_pat)
 IF ((m_pat->l_cnt > 0))
  FOR (ml_idx1 = 1 TO m_pat->l_cnt)
    CALL echo(m_pat->qual[ml_idx1].s_filename)
    EXECUTE bhs_rpt_prenatal_summary "bhs_mat_ops.txt", cnvtstring(m_pat->qual[ml_idx1].f_person_id,
     20), m_pat->s_rpt_date,
    value(m_pat->qual[ml_idx1].s_filename)
    IF (findfile(m_pat->qual[ml_idx1].s_filename)=1)
     CALL echo("PS File found")
     SET spool value(m_pat->qual[ml_idx1].s_filename) value(ms_printer_name)
     SET stat = remove(value(m_pat->qual[ml_idx1].s_filename))
     EXECUTE bhs_sys_pause 10
    ELSE
     CALL echo("PS File Not found")
    ENDIF
  ENDFOR
 ENDIF
#exit_script
END GO
