CREATE PROGRAM bhs_dup_patient_add:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Person A CMRN:" = "",
  "Select Person A :" = "",
  "Enter Person B CMRN:" = "",
  "Select Patient B :" = ""
  WITH outdev, s_a_cmrn1, s_a_cmrn,
  s_b_cmrn1, s_b_cmrn
 FREE RECORD m_info
 RECORD m_info(
   1 f_a_person_id = f8
   1 s_a_dob = vc
   1 s_a_corp_nbr = vc
   1 s_a_name_first_key = vc
   1 s_a_name_last_key = vc
   1 s_a_name_full = vc
   1 f_a_sex_cd = f8
   1 s_a_mrn = vc
   1 s_a_fin = vc
   1 f_b_person_id = f8
   1 s_b_dob = vc
   1 s_b_corp_nbr = vc
   1 s_b_name_first_key = vc
   1 s_b_name_last_key = vc
   1 s_b_name_full = vc
   1 f_b_sex_cd = f8
   1 s_b_mrn = vc
   1 s_b_fin = vc
   1 matches[*]
     2 s_a_name = vc
     2 s_a_dob = vc
     2 s_a_corp_nbr = vc
     2 s_b_name = vc
     2 s_b_dob = vc
     2 s_b_corp_nbr = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",373,"PENDING"))
 DECLARE ms_a_cmrn = vc WITH protect, noconstant(" ")
 DECLARE ms_b_cmrn = vc WITH protect, noconstant(" ")
 DECLARE ms_a_mrn = vc WITH protect, noconstant(" ")
 DECLARE ms_b_mrn = vc WITH protect, noconstant(" ")
 DECLARE ms_log_msg = vc WITH protect, noconstant(" ")
 DECLARE mn_exact_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_activate_row = i2 WITH protect, noconstant(0)
 DECLARE mf_new_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_match_stat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ml_beg_pos = i4 WITH protect, noconstant(0)
 SET ml_beg_pos = findstring("|", $S_A_CMRN)
 SET ms_a_cmrn = substring(1,(ml_beg_pos - 1), $S_A_CMRN)
 SET ms_a_mrn = substring((ml_beg_pos+ 1),(textlen( $S_A_CMRN) - ml_beg_pos), $S_A_CMRN)
 SET ml_beg_pos = findstring("|", $S_B_CMRN)
 SET ms_b_cmrn = substring(1,(ml_beg_pos - 1), $S_B_CMRN)
 SET ms_b_mrn = substring((ml_beg_pos+ 1),(textlen( $S_B_CMRN) - ml_beg_pos), $S_B_CMRN)
 CALL echo(concat( $S_A_CMRN," ",ms_a_cmrn," ",ms_a_mrn))
 CALL echo(concat( $S_B_CMRN," ",ms_b_cmrn," ",ms_b_mrn))
 IF (ms_a_cmrn=ms_b_cmrn)
  SET ms_log_msg = concat("CMRNs of Patient A and Patient B are a match - exiting; A:",ms_a_cmrn,
   " B:",ms_b_cmrn)
  GO TO exit_script
 ENDIF
 CALL echo("checking for existing row on bhs_person_match")
 SELECT INTO "nl:"
  FROM bhs_person_match b
  PLAN (b
   WHERE ((b.a_corporate_nbr IN (ms_a_cmrn, ms_b_cmrn)) OR (b.b_corporate_nbr IN (ms_a_cmrn,
   ms_b_cmrn))) )
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->matches,5))
    stat = alterlist(m_info->matches,(pn_cnt+ 10))
   ENDIF
   IF (((b.a_corporate_nbr=ms_a_cmrn
    AND b.b_corporate_nbr=ms_b_cmrn) OR (b.a_corporate_nbr=ms_b_cmrn
    AND b.b_corporate_nbr=ms_a_cmrn)) )
    IF (b.active_ind=0)
     CALL echo("inactive row exists"), mf_activate_row = b.bhs_person_match_id
    ELSE
     CALL echo("exact match"),
     CALL echo(build(b.active_ind,"; ",b.a_corporate_nbr,"; ",b.b_corporate_nbr)),
     CALL echo(build(ms_a_cmrn,"; ",ms_b_cmrn)),
     mn_exact_ind = 1, ms_log_msg = "These patients already flagged as duplicates"
    ENDIF
   ELSEIF (b.a_corporate_nbr IN (ms_a_cmrn, ms_b_cmrn))
    CALL echo("found a"), ms_log_msg =
    "Patient A already flagged as duplicate of a different patient", mf_match_stat_cd = mf_pending_cd
   ELSEIF (b.b_corporate_nbr IN (ms_a_cmrn, ms_b_cmrn))
    CALL echo("found b"), ms_log_msg =
    "Patient B already flagged as duplicate of a different patient", mf_match_stat_cd = mf_pending_cd
   ENDIF
   m_info->matches[pn_cnt].s_a_name = trim(b.a_name_full_formatted), m_info->matches[pn_cnt].s_a_dob
    = trim(format(b.a_birth_dt_tm,"dd-mmm-yyyy;;d")), m_info->matches[pn_cnt].s_a_corp_nbr = trim(b
    .a_corporate_nbr),
   m_info->matches[pn_cnt].s_b_name = trim(b.b_name_full_formatted), m_info->matches[pn_cnt].s_b_dob
    = trim(format(b.b_birth_dt_tm,"dd-mmm-yyyy;;d")), m_info->matches[pn_cnt].s_b_corp_nbr = trim(b
    .b_corporate_nbr),
   CALL echo(ms_log_msg)
  FOOT REPORT
   stat = alterlist(m_info->matches,pn_cnt)
  WITH nocounter
 ;end select
 IF (mn_exact_ind=1)
  CALL echo("found exact match - exit")
  GO TO exit_script
 ENDIF
 IF (mf_activate_row > 0.0)
  CALL echo("reactivate row")
  UPDATE  FROM bhs_person_match b
   SET b.active_ind = 1
   WHERE b.bhs_person_match_id=mf_activate_row
   WITH nocounter
  ;end update
  IF (curqual <= 0)
   SET ms_log_msg = "Inactive match row exists for these patients.  Unable to activate row"
  ELSE
   SET ms_log_msg = "Success - Inactive match row exists for these patients.  Reactivated row."
   COMMIT
  ENDIF
 ELSE
  CALL echo("get additional patient info")
  SELECT INTO "nl:"
   p.person_id, ea1.alias, ea2.alias
   FROM person p,
    person_alias pa,
    encounter e,
    encntr_alias ea1,
    encntr_alias ea2
   PLAN (pa
    WHERE pa.alias IN (ms_a_cmrn, ms_b_cmrn)
     AND pa.active_ind=1
     AND pa.person_alias_type_cd=mf_cmrn_cd)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND p.active_ind=1)
    JOIN (e
    WHERE e.person_id=outerjoin(p.person_id)
     AND e.active_ind=outerjoin(1))
    JOIN (ea1
    WHERE ea1.encntr_id=outerjoin(e.encntr_id)
     AND ea1.active_ind=outerjoin(1)
     AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
    JOIN (ea2
    WHERE ea2.encntr_id=outerjoin(e.encntr_id)
     AND ea2.active_ind=outerjoin(1)
     AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
   HEAD REPORT
    pn_cnt = 0
   HEAD pa.alias
    pn_cnt = (pn_cnt+ 1)
    IF (pa.alias=ms_a_cmrn)
     CALL echo("person a"), m_info->f_a_person_id = p.person_id, m_info->s_a_dob = trim(format(p
       .birth_dt_tm,"dd-mmm-yyyy;;d")),
     m_info->s_a_corp_nbr = trim(pa.alias), m_info->s_a_name_first_key = trim(p.name_first_key),
     m_info->s_a_name_last_key = trim(p.name_last_key),
     m_info->s_a_name_full = trim(p.name_full_formatted), m_info->f_a_sex_cd = p.sex_cd, m_info->
     s_a_fin = trim(ea1.alias)
     IF (ms_a_mrn > " ")
      m_info->s_a_mrn = ms_a_mrn
     ELSE
      m_info->s_a_mrn = trim(ea2.alias)
     ENDIF
    ELSEIF (pa.alias=ms_b_cmrn)
     CALL echo("person b"), m_info->f_b_person_id = p.person_id, m_info->s_b_dob = trim(format(p
       .birth_dt_tm,"dd-mmm-yyyy;;d")),
     m_info->s_b_corp_nbr = trim(pa.alias), m_info->s_b_name_first_key = trim(p.name_first_key),
     m_info->s_b_name_last_key = trim(p.name_last_key),
     m_info->s_b_name_full = trim(p.name_full_formatted), m_info->f_b_sex_cd = p.sex_cd, m_info->
     s_b_fin = trim(ea1.alias)
     IF (ms_b_mrn > " ")
      m_info->s_b_mrn = ms_b_mrn
     ELSE
      m_info->s_b_mrn = trim(ea2.alias)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((m_info->f_a_sex_cd != m_info->f_b_sex_cd)
   AND (m_info->f_a_sex_cd > 0)
   AND (m_info->f_b_sex_cd > 0))
   SET ms_log_msg = "Patient A and Patient B are opposite sex - no match inserted"
   GO TO exit_script
  ENDIF
  IF ((m_info->f_b_person_id <= 0))
   SET ms_log_msg = "No info found for Patient B"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   pf_max_id = max(b.bhs_person_match_id)
   FROM bhs_person_match b
   DETAIL
    mf_new_id = (pf_max_id+ 1),
    CALL echo(build2("old id: ",pf_max_id," new id: ",mf_new_id))
   WITH nocounter
  ;end select
  CALL echo("inserting patient info to bhs_person_match")
  IF (mf_match_stat_cd > 0)
   CALL echo("PENDING")
  ENDIF
  INSERT  FROM bhs_person_match b
   SET b.active_ind = 1, b.beg_effective_dt_tm = sysdate, b.bhs_person_match_id = mf_new_id,
    b.end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59"), b.match_dt_tm = sysdate, b
    .match_status_cd = mf_match_stat_cd,
    b.updt_dt_tm = sysdate, b.updt_id = 0, b.a_active_status_cd = mf_active_cd,
    b.a_birth_dt_tm = cnvtdatetime(m_info->s_a_dob), b.a_corporate_nbr = m_info->s_a_corp_nbr, b
    .a_fin = m_info->s_a_fin,
    b.a_mrn = m_info->s_a_mrn, b.a_name_first_key = m_info->s_a_name_first_key, b
    .a_name_full_formatted = m_info->s_a_name_full,
    b.a_name_last_key = m_info->s_a_name_last_key, b.a_person_id = m_info->f_a_person_id, b.a_sex_cd
     = m_info->f_a_sex_cd,
    b.b_active_status_cd = mf_active_cd, b.b_birth_dt_tm = cnvtdatetime(m_info->s_b_dob), b
    .b_corporate_nbr = m_info->s_b_corp_nbr,
    b.b_fin = m_info->s_b_fin, b.b_mrn = m_info->s_b_mrn, b.b_name_first_key = m_info->
    s_b_name_first_key,
    b.b_name_full_formatted = m_info->s_b_name_full, b.b_name_last_key = m_info->s_b_name_last_key, b
    .b_person_id = m_info->f_b_person_id,
    b.b_sex_cd = m_info->f_b_sex_cd
   WITH nocounter
  ;end insert
  IF (curqual <= 0)
   SET ms_log_msg = "Unable to insert row"
  ELSE
   SET ms_log_msg = "Success - Match row created"
   COMMIT
  ENDIF
 ENDIF
#exit_script
 SELECT INTO value( $OUTDEV)
  HEAD REPORT
   col 0, row 0, ms_log_msg,
   pn_cnt = 0
  DETAIL
   IF (ms_log_msg="Success*")
    col 0, row + 2, "New match row:",
    row + 1, col 0, "Patient A",
    col 25, "DOB A", col 40,
    "Corp Nbr A", col 60, "Patient B",
    col 85, "DOB B", col 100,
    "Corp Nbr A", row + 1, col 0,
    m_info->s_a_name_full, col 25, m_info->s_a_dob,
    col 40, m_info->s_a_corp_nbr, col 60,
    m_info->s_b_name_full, col 85, m_info->s_b_dob,
    col 100, m_info->s_b_corp_nbr
   ENDIF
   IF (size(m_info->matches,5) > 0)
    col 0, row + 2, "Existing Matches including patients A or B:",
    row + 1, col 0, "Patient A",
    col 25, "DOB A", col 40,
    "Corp Nbr A", col 60, "Patient B",
    col 85, "DOB B", col 100,
    "Corp Nbr A"
    FOR (pn_cnt = 1 TO size(m_info->matches,5))
      row + 1, col 0, m_info->matches[pn_cnt].s_a_name,
      col 25, m_info->matches[pn_cnt].s_a_dob, col 40,
      m_info->matches[pn_cnt].s_a_corp_nbr, col 60, m_info->matches[pn_cnt].s_b_name,
      col 85, m_info->matches[pn_cnt].s_b_dob, col 100,
      m_info->matches[pn_cnt].s_b_corp_nbr
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_info)
 CALL echo(ms_log_msg)
 FREE RECORD m_info
END GO
