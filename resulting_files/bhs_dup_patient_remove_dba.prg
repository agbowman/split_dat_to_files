CREATE PROGRAM bhs_dup_patient_remove:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a CMRN: " = "",
  "Select Match to Remove:" = 0
  WITH outdev, s_a_cmrn, f_match_id
 FREE RECORD m_info
 RECORD m_info(
   1 matches[*]
     2 s_a_name = vc
     2 s_a_dob = vc
     2 s_a_corp_nbr = vc
     2 s_b_name = vc
     2 s_b_dob = vc
     2 s_b_corp_nbr = vc
     2 n_remove_ind = i2
 ) WITH protect
 DECLARE ms_a_cmrn = vc WITH protect, constant(trim( $S_A_CMRN))
 DECLARE mf_match_id = f8 WITH protect, constant(cnvtreal( $F_MATCH_ID))
 DECLARE ms_log_msg = vc WITH protect, noconstant(" ")
 IF (mf_match_id <= 0.00)
  SET ms_log_msg = "Invalid match id - exiting"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_person_match b
  PLAN (b
   WHERE ((((b.a_corporate_nbr IN (ms_a_cmrn)) OR (b.b_corporate_nbr IN (ms_a_cmrn))) ) OR (b
   .bhs_person_match_id=mf_match_id)) )
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   CALL echo(build2("match_id: ",mf_match_id," table id: ",b.bhs_person_match_id)), pn_cnt = (pn_cnt
   + 1)
   IF (pn_cnt > size(m_info->matches,5))
    stat = alterlist(m_info->matches,(pn_cnt+ 10))
   ENDIF
   m_info->matches[pn_cnt].s_a_name = trim(b.a_name_full_formatted), m_info->matches[pn_cnt].s_a_dob
    = trim(format(b.a_birth_dt_tm,"dd-mmm-yyyy;;d")), m_info->matches[pn_cnt].s_a_corp_nbr = trim(b
    .a_corporate_nbr),
   m_info->matches[pn_cnt].s_b_name = trim(b.b_name_full_formatted), m_info->matches[pn_cnt].s_b_dob
    = trim(format(b.b_birth_dt_tm,"dd-mmm-yyyy;;d")), m_info->matches[pn_cnt].s_b_corp_nbr = trim(b
    .b_corporate_nbr)
   IF (b.bhs_person_match_id=mf_match_id)
    m_info->matches[pn_cnt].n_remove_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(m_info->matches,pn_cnt)
  WITH nocounter
 ;end select
 UPDATE  FROM bhs_person_match b
  SET b.active_ind = 0
  WHERE b.bhs_person_match_id=mf_match_id
  WITH nocounter
 ;end update
 IF (curqual <= 0)
  SET ms_log_msg = "Inactivate failed - exit"
 ELSE
  SET ms_log_msg = "Success - Match inactivated"
 ENDIF
 COMMIT
#exit_script
 CALL echo(ms_log_msg)
 SELECT INTO value( $OUTDEV)
  HEAD REPORT
   col 0, row 0, ms_log_msg,
   pn_cnt = 0, pl_idx = 0, pl_num = 0
  DETAIL
   IF (ms_log_msg="Success*")
    pl_idx = locateval(pl_num,1,size(m_info->matches,5),1,m_info->matches[pl_num].n_remove_ind), col
    0, row + 2,
    "Match row inactivated:", row + 1, col 0,
    "Patient A", col 25, "DOB A",
    col 40, "Corp Nbr A", col 60,
    "Patient B", col 85, "DOB B",
    col 100, "Corp Nbr A", row + 1,
    col 0, m_info->matches[pl_idx].s_a_name, col 25,
    m_info->matches[pl_idx].s_a_dob, col 40, m_info->matches[pl_idx].s_a_corp_nbr,
    col 60, m_info->matches[pl_idx].s_b_name, col 85,
    m_info->matches[pl_idx].s_b_dob, col 100, m_info->matches[pl_idx].s_b_corp_nbr
   ENDIF
   IF (size(m_info->matches,5) > 1)
    col 0, row + 2, "Existing Matches including patients A or B:",
    row + 1, col 0, "Patient A",
    col 25, "DOB A", col 40,
    "Corp Nbr A", col 60, "Patient B",
    col 85, "DOB B", col 100,
    "Corp Nbr A"
    FOR (pn_cnt = 1 TO size(m_info->matches,5))
      IF ((m_info->matches[pn_cnt].n_remove_ind=0))
       row + 1, col 0, m_info->matches[pn_cnt].s_a_name,
       col 25, m_info->matches[pn_cnt].s_a_dob, col 40,
       m_info->matches[pn_cnt].s_a_corp_nbr, col 60, m_info->matches[pn_cnt].s_b_name,
       col 85, m_info->matches[pn_cnt].s_b_dob, col 100,
       m_info->matches[pn_cnt].s_b_corp_nbr
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
