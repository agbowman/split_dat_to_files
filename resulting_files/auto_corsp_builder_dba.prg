CREATE PROGRAM auto_corsp_builder:dba
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
 DECLARE authorpersonid = f8
 DECLARE smartscript = vc
 DECLARE smarttext = vc
 RECORD builderrep(
   1 note = vgc
   1 proc_date = dq8
   1 text = vc
   1 template_name = vc
   1 note_template = vc
 )
 CALL echo("inside auto_corsp_builder...")
 CALL echo(build("event code received: ",requestin->clin_detail_list.event_cd))
 CALL echo(build("patient ID received: ",requestin->clin_detail_list.person_id))
 CALL echo(build("encounter ID: ",requestin->clin_detail_list.encntr_id))
 SET count = 0
 SELECT INTO "nl:"
  FROM note_type_template_reltn tid,
   clinical_note_template nt
  PLAN (tid
   WHERE (tid.note_type_id=refnote->notetypeid)
    AND tid.default_ind=1)
   JOIN (nt
   WHERE nt.template_id=tid.template_id
    AND nt.smart_template_ind=1)
  DETAIL
   builderrep->template_name = nt.template_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET builderrep->note = "<SmartText>"
  CALL echo(build("Contents of SmartText: ",builderrep->note))
 ELSE
  SELECT INTO "nl:"
   FROM note_type_template_reltn tid,
    clinical_note_template nt,
    long_blob lb
   PLAN (tid
    WHERE (tid.note_type_id=refnote->notetypeid))
    JOIN (nt
    WHERE nt.template_id=tid.template_id
     AND nt.smart_template_ind < 2)
    JOIN (lb
    WHERE lb.long_blob_id=nt.long_blob_id)
   DETAIL
    builderrep->template_name = nt.template_name, builderrep->note_template = trim(lb.long_blob),
    builderrep->note = builderrep->note_template
   WITH nocounter
  ;end select
  CALL echo(build("TemplateName: ",builderrep->template_name))
  CALL echo(build("NoteTemplate: ",builderrep->note_template))
  CALL echo(build("Note: ",builderrep->note))
 ENDIF
 CALL echo("getting smart script...")
 SELECT INTO "nl:"
  FROM note_type_template_reltn tid,
   clinical_note_template nt,
   code_value cd
  PLAN (tid
   WHERE (tid.note_type_id=refnote->notetypeid))
   JOIN (nt
   WHERE nt.template_id=tid.template_id
    AND nt.smart_template_ind=1)
   JOIN (cd
   WHERE cd.code_value=nt.smart_template_cd)
  DETAIL
   smartscript = cnvtupper(cd.definition)
  WITH nocounter
 ;end select
 IF (textlen(smartscript) > 0)
  CALL echo(build("SmartScript: ",smartscript))
  EXECUTE value(smartscript)  WITH replace("REPLY","BUILDERREP")
  SET smarttext = builderrep->text
  SET builderrep->note = replace(builderrep->note,"<SmartText>",smarttext,0)
 ENDIF
 SET processnote->finalnote = builderrep->note
 CALL echo(build("Final Note:",processnote->finalnote))
 SET script_version = "001 12/05/03 IH6582"
END GO
