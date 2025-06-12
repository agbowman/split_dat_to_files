CREATE PROGRAM bhs_mp_fh_pat_search:dba
 PROMPT
  "Last Name:" = "",
  "First Name:" = "",
  "MRN" = "",
  "DOB" = "CURDATE",
  "Gender" = "",
  "FIN:" = ""
  WITH s_name_last, s_name_first, s_mrn,
  s_dob, s_gender, s_fin
 FREE RECORD m_rec
 RECORD m_rec(
   1 c_status = c1
   1 s_msg = vc
   1 pat[*]
     2 f_person_id = f8
     2 s_person_id = vc
     2 s_name_full = vc
     2 s_dob = vc
     2 s_sex = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_reg_dt_tm = vc
     2 s_home_addr = vc
     2 s_home_phone = vc
     2 s_pcp_name = vc
 ) WITH protect
 DECLARE ms_name_last = vc WITH protect, constant(trim(cnvtupper( $S_NAME_LAST),3))
 DECLARE ms_name_first = vc WITH protect, constant(trim(cnvtupper( $S_NAME_FIRST),3))
 DECLARE ms_mrn = vc WITH protect, constant(trim(cnvtupper( $S_MRN),3))
 DECLARE ms_gender = vc WITH protect, constant(trim(cnvtupper( $S_GENDER),3))
 DECLARE ms_fin = vc WITH protect, constant(trim(cnvtupper( $S_FIN),3))
 DECLARE mf_mrn_pa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_cmrn_pa_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_home_addr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE mf_home_ph_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE ms_dob = vc WITH protect, noconstant(trim(cnvtupper( $S_DOB),3))
 DECLARE ms_parse = vc WITH protect, noconstant(" ")
 DECLARE mf_gender_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_dob_beg = vc WITH protect, noconstant(" ")
 DECLARE ms_dob_end = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 IF (isnumeric(substring(1,4,ms_dob)) > 0)
  CASE (cnvtint(substring(6,2,ms_dob)))
   OF 1:
    SET ms_tmp = "JAN"
   OF 2:
    SET ms_tmp = "FEB"
   OF 3:
    SET ms_tmp = "MAR"
   OF 4:
    SET ms_tmp = "APR"
   OF 5:
    SET ms_tmp = "MAY"
   OF 6:
    SET ms_tmp = "JUN"
   OF 7:
    SET ms_tmp = "JUL"
   OF 8:
    SET ms_tmp = "AUG"
   OF 9:
    SET ms_tmp = "SEP"
   OF 10:
    SET ms_tmp = "OCT"
   OF 11:
    SET ms_tmp = "NOV"
   OF 12:
    SET ms_tmp = "DEC"
  ENDCASE
  SET ms_dob = concat(substring(9,2,ms_dob),"-",ms_tmp,"-",substring(1,4,ms_dob),
   " ",substring(12,8,ms_dob))
  CALL echo(concat("ODBC: ",ms_dob))
 ENDIF
 IF (textlen(ms_name_last)=0
  AND textlen(ms_mrn)=0
  AND textlen(ms_fin)=0)
  SET m_rec->s_msg = "Last Name, MRN and FIN are blank.  Must have one filled out"
  GO TO exit_script
 ENDIF
 SET m_rec->c_status = "F"
 IF (textlen(ms_name_last) > 0)
  SET ms_parse = concat(' p.name_last_key = "',ms_name_last,'*"')
 ENDIF
 IF (textlen(ms_name_first) > 0)
  IF (textlen(ms_parse) > 0)
   SET ms_parse = concat(ms_parse," and")
  ENDIF
  SET ms_parse = concat(ms_parse,' p.name_first_key = "',ms_name_first,'*"')
 ENDIF
 IF (textlen(ms_dob) > 0)
  SET ms_dob_beg = concat(ms_dob," 00:00:00")
  SET ms_dob_end = concat(ms_dob," 23:59:59")
  IF (textlen(ms_parse) > 0)
   SET ms_parse = concat(ms_parse," and")
  ENDIF
  SET ms_parse = concat(ms_parse,' p.birth_dt_tm between cnvtdatetime("',ms_dob_beg,
   '") and cnvtdatetime("',ms_dob_end,
   '")')
 ENDIF
 IF (textlen(ms_gender) > 0)
  SET mf_gender_cd = uar_get_code_by("DISPLAYKEY",57,value(ms_gender))
  CALL echo(build2("mf_gender_cd: ",mf_gender_cd))
  IF (mf_gender_cd > 0.0)
   IF (textlen(ms_parse) > 0)
    SET ms_parse = concat(ms_parse," and")
   ENDIF
   SET ms_parse = concat(ms_parse," p.sex_cd = ",trim(cnvtstring(mf_gender_cd,20),3))
  ENDIF
 ENDIF
 IF (textlen(ms_parse)=0)
  SET ms_parse = " 1=1"
 ENDIF
 CALL echo(ms_parse)
 IF (textlen(ms_mrn) > 0)
  CALL echo("select by MRN")
  SELECT INTO "nl:"
   FROM person_alias pa,
    person p,
    encounter e
   PLAN (pa
    WHERE pa.alias=ms_mrn
     AND pa.person_alias_type_cd IN (mf_mrn_pa_cd, mf_cmrn_pa_cd)
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate)
    JOIN (p
    WHERE p.person_id=pa.person_id
     AND p.active_ind=1
     AND parser(ms_parse))
    JOIN (e
    WHERE e.person_id=p.person_id
     AND e.active_ind=1)
   ORDER BY p.person_id
   HEAD REPORT
    pl_cnt = 0
   HEAD p.person_id
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].f_person_id = p
    .person_id,
    m_rec->pat[pl_cnt].s_person_id = trim(cnvtstring(p.person_id,20),3), m_rec->pat[pl_cnt].
    s_name_full = trim(p.name_full_formatted,3), m_rec->pat[pl_cnt].s_sex = trim(uar_get_code_display
     (p.sex_cd),3),
    m_rec->pat[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"yyyy-mm-dd;;d"),3), m_rec->pat[pl_cnt].
    s_mrn = trim(pa.alias,3)
   WITH nocounter
  ;end select
 ELSEIF (textlen(ms_fin) > 0)
  CALL echo("select by FIN")
  SELECT INTO "nl:"
   FROM encntr_alias ea1,
    encounter e,
    person p,
    encntr_alias ea2
   PLAN (ea1
    WHERE ea1.alias=ms_fin
     AND ea1.encntr_alias_type_cd=mf_fin_cd
     AND ea1.active_ind=1
     AND ea1.end_effective_dt_tm > sysdate)
    JOIN (e
    WHERE e.encntr_id=ea1.encntr_id
     AND e.active_ind=1)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND parser(ms_parse))
    JOIN (ea2
    WHERE ea2.encntr_id=e.encntr_id
     AND ea2.encntr_alias_type_cd=mf_mrn_cd
     AND ea2.active_ind=1
     AND ea2.end_effective_dt_tm > sysdate)
   ORDER BY p.person_id
   HEAD REPORT
    pl_cnt = 0
   HEAD p.person_id
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].f_person_id = p
    .person_id,
    m_rec->pat[pl_cnt].s_person_id = trim(cnvtstring(p.person_id,20),3), m_rec->pat[pl_cnt].
    s_name_full = trim(p.name_full_formatted,3), m_rec->pat[pl_cnt].s_sex = trim(uar_get_code_display
     (p.sex_cd),3),
    m_rec->pat[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"yyyy-mm-dd;;d"),3), m_rec->pat[pl_cnt].
    s_fin = trim(ea1.alias,3), m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias,3)
   WITH nocounter
  ;end select
 ELSEIF (textlen(ms_mrn)=0
  AND textlen(ms_fin)=0)
  CALL echo("select by name/dob/gender")
  SELECT INTO "nl:"
   FROM person p,
    person_alias pa,
    encounter e
   PLAN (p
    WHERE parser(ms_parse)
     AND p.active_ind=1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=mf_mrn_pa_cd)
    JOIN (e
    WHERE e.person_id=p.person_id
     AND e.active_ind=1)
   ORDER BY p.person_id
   HEAD REPORT
    pl_cnt = 0
   HEAD p.person_id
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat,pl_cnt), m_rec->pat[pl_cnt].f_person_id = p
    .person_id,
    m_rec->pat[pl_cnt].s_person_id = trim(cnvtstring(p.person_id,20),3), m_rec->pat[pl_cnt].
    s_name_full = trim(p.name_full_formatted,3), m_rec->pat[pl_cnt].s_sex = trim(uar_get_code_display
     (p.sex_cd),3),
    m_rec->pat[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"yyyy-mm-dd;;d"),3), m_rec->pat[pl_cnt].
    s_mrn = trim(pa.alias,3)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(ml_exp,1,size(m_rec->pat,5),p.parent_entity_id,m_rec->pat[ml_exp].f_person_id)
    AND p.parent_entity_name="PERSON"
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate
    AND p.phone_type_cd=mf_home_ph_cd
    AND p.phone_type_seq=1)
  ORDER BY p.parent_entity_id
  HEAD p.parent_entity_id
   ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),p.parent_entity_id,m_rec->pat[ml_loc].f_person_id)
   IF (ml_idx > 0)
    m_rec->pat[ml_idx].s_home_phone = trim(p.phone_num,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(ml_exp,1,size(m_rec->pat,5),a.parent_entity_id,m_rec->pat[ml_exp].f_person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate
    AND a.address_type_seq=1
    AND a.address_type_cd=mf_home_addr_cd)
  ORDER BY a.parent_entity_id
  HEAD a.parent_entity_id
   ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),a.parent_entity_id,m_rec->pat[ml_loc].f_person_id)
   IF (ml_idx > 0)
    IF (textlen(trim(a.street_addr,3)) > 0)
     ms_tmp = trim(a.street_addr,3)
    ENDIF
    IF (textlen(trim(a.street_addr2,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.street_addr2,3))
    ENDIF
    IF (textlen(trim(a.street_addr3,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.street_addr3,3))
    ENDIF
    IF (textlen(trim(a.street_addr4,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.street_addr4,3))
    ENDIF
    IF (textlen(trim(a.city,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.city,3))
    ENDIF
    IF (textlen(trim(a.state,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.state,3))
    ENDIF
    IF (textlen(trim(a.zipcode,3)) > 0)
     ms_tmp = concat(ms_tmp," ",trim(a.zipcode,3))
    ENDIF
    m_rec->pat[ml_idx].s_home_addr = ms_tmp
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE expand(ml_exp,1,size(m_rec->pat,5),ppr.person_id,m_rec->pat[ml_exp].f_person_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.person_prsnl_r_cd=mf_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.active_ind=1)
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   ml_idx = locateval(ml_loc,1,size(m_rec->pat,5),ppr.person_id,m_rec->pat[ml_loc].f_person_id)
   IF (ml_idx > 0)
    m_rec->pat[ml_idx].s_pcp_name = trim(p.name_full_formatted,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (size(m_rec->pat,5) > 0)
  SET m_rec->c_status = "S"
  SET m_rec->s_msg = "Success"
 ELSE
  SET m_rec->s_msg = "No Patients Found"
 ENDIF
#exit_script
 SET ms_tmp = cnvtrectojson(m_rec)
 SET ml_pos = (findstring(":",ms_tmp)+ 1)
 SET ms_tmp = substring(ml_pos,(textlen(ms_tmp) - ml_pos),ms_tmp)
 SET _memory_reply_string = ms_tmp
 CALL echo(_memory_reply_string)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
