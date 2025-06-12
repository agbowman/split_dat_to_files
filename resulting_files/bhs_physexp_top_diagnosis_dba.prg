CREATE PROGRAM bhs_physexp_top_diagnosis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Provider status:" = 0,
  "Select position(s):" = 0,
  "Select users:" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  l_provider_ind, f_position_cd, f_prsnl_id
 FREE RECORD m_prvs
 RECORD m_prvs(
   1 l_pcnt = i4
   1 plist[*]
     2 f_person_id = f8
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_dxcnt = i4
   1 identifier[*]
     2 c_source_identifier = c50
     2 l_nbr_of_identifiers = i4
     2 n_rank = i2
     2 l_scnt = i4
     2 string[*]
       3 f_nomenclature_id = f8
       3 l_nbrstrings = i4
   1 s_error_message = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_output_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_error_message = vc WITH protect, noconstant(" ")
 DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_scnt = i4 WITH protect, noconstant(0)
 DECLARE ml_dxcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_rank_cnt = i4 WITH protect, noconstant(0)
 DECLARE mc_prvs_dtype = c1 WITH protect, noconstant(" ")
 SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
 SET ms_end_dt_tm = concat( $S_END_DT," 00:00:00")
 SET ms_output_filename =  $OUTDEV
 SET mc_prvs_dtype = substring(1,1,reflect(parameter(6,0)))
 IF (mc_prvs_dtype IN ("F", "L"))
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE (pr.person_id= $F_PRSNL_ID))
   ORDER BY pr.name_full_formatted
   HEAD REPORT
    ml_pcnt = 0
   DETAIL
    ml_pcnt += 1, m_prvs->l_pcnt = ml_pcnt, stat = alterlist(m_prvs->plist,ml_pcnt),
    m_prvs->plist[ml_pcnt].f_person_id = pr.person_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE (pr.position_cd= $F_POSITION_CD)
     AND pr.active_ind=1
     AND (pr.physician_ind= $L_PROVIDER_IND))
   ORDER BY pr.name_full_formatted
   HEAD REPORT
    ml_pcnt = 0
   DETAIL
    ml_pcnt += 1, m_prvs->l_pcnt = ml_pcnt, stat = alterlist(m_prvs->plist,ml_pcnt),
    m_prvs->plist[ml_pcnt].f_person_id = pr.person_id
   WITH nocounter
  ;end select
 ENDIF
 IF (ml_pcnt=0)
  GO TO exit_script
 ENDIF
 SET m_rec->l_dxcnt = 0
 SELECT INTO "nl:"
  FROM diagnosis d,
   prsnl pr,
   nomenclature n
  PLAN (d
   WHERE d.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND d.updt_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND d.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=d.diag_prsnl_id
    AND expand(ml_num,1,m_prvs->l_pcnt,pr.person_id,m_prvs->plist[ml_num].f_person_id)
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.active_ind=1)
  ORDER BY n.source_identifier, n.nomenclature_id
  HEAD REPORT
   ml_dxcnt = 0, stat = alterlist(m_rec->identifier,100), ml_scnt = 0
  HEAD n.source_identifier
   ml_dxcnt += 1
   IF (mod(ml_dxcnt,100)=1)
    stat = alterlist(m_rec->identifier,(ml_dxcnt+ 99))
   ENDIF
   CALL echo(build2("n.source_identifier: ",n.source_identifier)), m_rec->identifier[ml_dxcnt].
   c_source_identifier = n.source_identifier, m_rec->identifier[ml_dxcnt].l_nbr_of_identifiers = 0,
   ml_scnt = 0, stat = alterlist(m_rec->identifier[ml_dxcnt].string,10)
  HEAD n.nomenclature_id
   ml_scnt += 1
   IF (mod(ml_scnt,10)=1)
    stat = alterlist(m_rec->identifier[ml_dxcnt].string,(ml_scnt+ 9))
   ENDIF
   m_rec->identifier[ml_dxcnt].string[ml_scnt].l_nbrstrings = 0, m_rec->identifier[ml_dxcnt].string[
   ml_scnt].f_nomenclature_id = n.nomenclature_id
  DETAIL
   m_rec->identifier[ml_dxcnt].string[ml_scnt].l_nbrstrings += 1
  FOOT  n.nomenclature_id
   m_rec->identifier[ml_dxcnt].l_nbr_of_identifiers += m_rec->identifier[ml_dxcnt].string[ml_scnt].
   l_nbrstrings
  FOOT  n.source_identifier
   stat = alterlist(m_rec->identifier[ml_dxcnt].string,ml_scnt), m_rec->identifier[ml_dxcnt].l_scnt
    = ml_scnt
  FOOT REPORT
   stat = alterlist(m_rec->identifier,ml_dxcnt), m_rec->l_dxcnt = ml_dxcnt
  WITH nullreport, nocounter
 ;end select
 IF ((m_rec->l_dxcnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1seq = d1.seq, ml_nbr_of_identifiers = m_rec->identifier[d1.seq].l_nbr_of_identifiers
  FROM (dummyt d1  WITH seq = m_rec->l_dxcnt)
  PLAN (d1)
  ORDER BY ml_nbr_of_identifiers DESC, d1seq
  HEAD REPORT
   ml_previous_nbr_of_identifiers = ml_nbr_of_identifiers, ml_rank_cnt = 0
  HEAD d1seq
   IF (ml_rank_cnt < 100)
    ml_rank_cnt += 1, m_rec->identifier[d1.seq].n_rank = ml_rank_cnt
   ELSEIF (ml_nbr_of_identifiers=ml_previous_nbr_of_identifiers
    AND ml_rank_cnt=100)
    m_rec->identifier[d1.seq].n_rank = ml_rank_cnt, ml_previous_nbr_of_identifiers =
    ml_nbr_of_identifiers
   ELSE
    ml_rank_cnt += 1
   ENDIF
  WITH nullreport, nocounter
 ;end select
 SELECT INTO value(ms_output_filename)
  source_identifier = m_rec->identifier[d1.seq].c_source_identifier, nbr_of_identifiers = m_rec->
  identifier[d1.seq].l_nbr_of_identifiers, source_string = trim(n.source_string),
  nbr_of_strings = m_rec->identifier[d1.seq].string[d2.seq].l_nbrstrings
  FROM (dummyt d1  WITH seq = m_rec->l_dxcnt),
   (dummyt d2  WITH seq = 1),
   nomenclature n
  PLAN (d1
   WHERE maxrec(d2,m_rec->identifier[d1.seq].l_scnt)
    AND (m_rec->identifier[d1.seq].n_rank > 0))
   JOIN (d2)
   JOIN (n
   WHERE (n.nomenclature_id=m_rec->identifier[d1.seq].string[d2.seq].f_nomenclature_id))
  ORDER BY nbr_of_identifiers DESC, source_identifier, nbr_of_strings DESC,
   source_string
  WITH separator = " ", format, nocounter
 ;end select
 SUBROUTINE write_error_message(error_msg,run_file)
   SELECT INTO value(run_file)
    errmsg = error_msg, specialty = specialty_input
    FROM dummyt d
    WITH format, separator = " ", nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF ((m_rec->l_dxcnt=0))
  SELECT INTO value(ms_output_filename)
   message = "No diagnoses found for selected positions/providers."
   FROM dummyt
   WITH format, separator = " ", nocounter
  ;end select
 ENDIF
 IF (validate(request->batch_selection)=1)
  IF (validate(reply,0))
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
