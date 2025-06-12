CREATE PROGRAM bhs_sso_get_pat_info:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient Person ID:" = 0,
  "encntr id" = 0
  WITH outdev, f_pat_id, f_encntr_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_cmrn = vc
   1 s_userid = vc
 ) WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PAT_ID))
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 SET m_rec->s_userid = trim(curuser)
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_alias_type_cd=mf_cmrn_cd
   AND pa.person_id=mf_person_id
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm >= sysdate
  HEAD pa.person_id
   m_rec->s_cmrn = trim(pa.alias)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  WHILE (textlen(m_rec->s_cmrn) < 7)
    SET m_rec->s_cmrn = concat("0",m_rec->s_cmrn)
  ENDWHILE
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  HEAD p.person_id
   m_rec->s_userid = trim(p.username)
  WITH nocounter
 ;end select
#exit_script
 CALL echo(cnvtrectojson(m_rec))
 SET _memory_reply_string = cnvtrectojson(m_rec)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
