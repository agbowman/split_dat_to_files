CREATE PROGRAM auto_corsp_get_note:dba
 IF ( NOT (validate(refnote,0)))
  FREE SET refnote
  RECORD refnote(
    1 event_cd = f8
    1 succession_type = f8
    1 record_status = f8
    1 result_status = f8
    1 referralnote = vc
    1 notetypeid = f8
    1 notetypedescription = vc
    1 subject_line = vc
  )
  DECLARE cv_echo = vc
  DECLARE cv_cath = vc
  DECLARE cv_nuc = vc
  SET cv_echo = "CV_ECHO_DOC*"
  SET cv_cath = "CV_CATH_DOC*"
  SET cv_nuc = "CV_NUC_DOC*"
 ENDIF
 IF ( NOT (validate(processnote,0)))
  FREE SET processnote
  RECORD processnote(
    1 finalnote = vgc
  )
 ENDIF
 IF ( NOT (validate(cv_echo_ref,0)))
  DECLARE cv_echo_ref = vc
  DECLARE cv_cath_ref = vc
  DECLARE cv_nuc_ref = vc
  SET cv_echo_ref = "Echo Referral Letter"
  SET cv_cath_ref = "Cath Referral Letter"
  SET cv_nuc_ref = "Nuclear Referral Letter"
 ENDIF
 DECLARE noteeventcd = f8
 SET noteeventcd = uar_get_code_by("DISPLAY",72,refnote->referralnote)
 SELECT INTO "nl:"
  FROM note_type nt
  WHERE nt.event_cd=noteeventcd
  DETAIL
   refnote->notetypeid = nt.note_type_id, refnote->notetypedescription = nt.note_type_description
  WITH nocounter
 ;end select
 SET script_version = "001 12/05/03 IH6582"
#exit_script
END GO
