CREATE PROGRAM auto_corsp_process:dba
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
 DECLARE contrib_sys_cd = f8
 DECLARE doc_cd = f8
 DECLARE eventcd = f8
 DECLARE succession_type = f8
 DECLARE storage = f8
 DECLARE format = f8
 DECLARE record_status = f8
 DECLARE result_status = f8
 DECLARE subject_line = vc
 DECLARE applicationid = i4 WITH constant(1000012)
 DECLARE taskid = i4 WITH constant(1000012)
 DECLARE requestid = i4 WITH constant(1000012)
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hstep = i4
 DECLARE hreq = i4
 DECLARE hrep = i4
 DECLARE hreply = i4
 DECLARE hce = i4
 DECLARE hrb_list = i4
 DECLARE hblob = i4
 DECLARE hblob2 = i4
 DECLARE notesize = i4
 EXECUTE auto_corsp_builder
 IF ((processnote->finalnote=""))
  SET msg = "There is no note to post to clinical_event."
  GO TO exit_script
 ENDIF
 IF ((((refnote->referralnote=cv_echo_ref)) OR ((((refnote->referralnote=cv_cath_ref)) OR ((refnote->
 referralnote=cv_nuc_ref))) )) )
  EXECUTE auto_corsp_replace_tag
 ENDIF
 SET notesize = size(processnote->finalnote,1)
 CALL echo(notesize)
 SET contrib_sys_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(89,"POWERCHART",1,contrib_sys_cd)
 IF (contrib_sys_cd <= 0)
  SET msg = "There is no cdf_meaning named POWERCHART under codeset 89 in the database."
  GO TO exit_script
 ENDIF
 SET doc_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(53,"DOC",1,doc_cd)
 IF (doc_cd <= 0)
  SET msg = "There is no cdf_meaning named DOC under codeset 53 in the database."
  GO TO exit_script
 ENDIF
 SET eventcd = 0.0
 IF ((refnote->event_cd > 0))
  SET eventcd = refnote->event_cd
 ELSEIF ((refnote->referralnote=cv_echo_ref))
  SET iret = uar_get_meaning_by_codeset(72,"CV_ECHO",1,eventcd)
  IF (eventcd <= 0)
   SET msg = "There is no cdf_meaning named CV_ECHO under codeset 72 in the database."
   GO TO exit_script
  ENDIF
 ELSEIF ((refnote->referralnote=cv_cath_ref))
  SET iret = uar_get_meaning_by_codeset(72,"CV_CATH",1,eventcd)
  IF (eventcd <= 0)
   SET msg = "There is no cdf_meaning named CV_CATH under codeset 72 in the database."
   GO TO exit_script
  ENDIF
 ELSEIF ((refnote->referralnote=cv_nuc_ref))
  SET iret = uar_get_meaning_by_codeset(72,"CV_NUC",1,eventcd)
  IF (eventcd <= 0)
   SET msg = "There is no cdf_meaning named CV_NUC under codeset 72 in the database."
   GO TO exit_script
  ENDIF
 ENDIF
 SET succession_type = 0.0
 IF ((refnote->succession_type > 0))
  SET succession_type = refnote->succession_type
 ELSE
  SET iret = uar_get_meaning_by_codeset(63,"FINAL",1,succession_type)
  IF (succession_type <= 0)
   SET msg = "There is no cdf_meaning named FINAL under codeset 63 in the database."
   GO TO exit_script
  ENDIF
 ENDIF
 SET storage = 0.0
 SET iret = uar_get_meaning_by_codeset(25,"BLOB",1,storage)
 IF (storage <= 0)
  SET msg = "There is no cdf_meaning named BLOB under codeset 25 in the database."
  GO TO exit_script
 ENDIF
 SET format = 0.0
 SET iret = uar_get_meaning_by_codeset(23,"RTF",1,format)
 IF (format <= 0)
  SET msg = "There is no cdf_meaning named RTF under codeset 23 in the database."
  GO TO exit_script
 ENDIF
 SET record_status = 0.0
 IF ((refnote->record_status > 0))
  SET record_status = refnote->record_status
 ELSE
  SET iret = uar_get_meaning_by_codeset(48,"ACTIVE",1,record_status)
  IF (record_status <= 0)
   SET msg = "There is no cdf_meaning named ACTIVE under codeset 48 in the database."
   GO TO exit_script
  ENDIF
 ENDIF
 SET result_status = 0.0
 IF ((refnote->result_status > 0))
  SET result_status = refnote->result_status
 ELSE
  SET iret = uar_get_meaning_by_codeset(8,"AUTH",1,result_status)
  IF (result_status <= 0)
   SET msg = "There is no cdf_meaning named AUTH under codeset 8 in the database."
   GO TO exit_script
  ENDIF
 ENDIF
 SET subject_line = ""
 IF ((refnote->subject_line != ""))
  SET subject_line = refnote->subject_line
 ENDIF
 EXECUTE crmrtl
 EXECUTE srvrtl
 SET iret = uar_crmbeginapp(applicationid,happ)
 IF (iret != 0)
  CALL echo("hApp => uar_crm_begin_app failed in post_to_clinical_event")
  SET msg = "hApp => uar_crm_begin_app failed in post_to_clinical_event"
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbegintask(happ,taskid,htask)
 IF (iret != 0)
  CALL echo("hTask => uar_crm_begin_task failed in post_to_clinical_event")
  SET msg = "hTask => uar_crm_begin_task failed in post_to_clinical_event"
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
 IF (iret != 0)
  CALL echo("hStep => uar_crm_begin_Request failed in post_to_clinical_event")
  SET msg = "hStep => uar_crm_begin_Request failed in post_to_clinical_event"
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 SET hce = uar_srvgetstruct(hreq,"clin_event")
 IF (hce)
  SET srvstat = uar_srvsetshort(hce,"ensure_type",2)
  SET srvstat = uar_srvsetdouble(hce,"person_id",requestin->clin_detail_list.person_id)
  SET srvstat = uar_srvsetdouble(hce,"contributor_system_cd",contrib_sys_cd)
  SET srvstat = uar_srvsetdouble(hce,"event_class_cd",doc_cd)
  SET srvstat = uar_srvsetdouble(hce,"encntr_id",requestin->clin_detail_list.encntr_id)
  SET srvstat = uar_srvsetdouble(hce,"event_cd",eventcd)
  SET srvstat = uar_srvsetdouble(hce,"result_status_cd",result_status)
  SET srvstat = uar_srvsetdate(hce,"event_end_dt_tm",cnvtdatetime(curdate,curtime3))
  SET srvstat = uar_srvsetdouble(hce,"record_status_cd",record_status)
  SET srvstat = uar_srvsetdate(hce,"event_start_dt_tm",cnvtdatetime(curdate,curtime3))
  SET srvstat = uar_srvsetlong(hce,"view_level",1)
  SET srvstat = uar_srvsetshort(hce,"authentic_flag",1)
  SET srvstat = uar_srvsetshort(hce,"publish_flag",1)
  SET srvstat = uar_srvsetstring(hce,"event_title_text",subject_line)
  SET hblob = uar_srvadditem(hce,"blob_result")
  IF (hblob)
   SET srvstat = uar_srvsetdouble(hblob,"succession_type_cd",succession_type)
   SET srvstat = uar_srvsetdouble(hblob,"storage_cd",storage)
   SET srvstat = uar_srvsetdouble(hblob,"format_cd",format)
   SET hblob2 = uar_srvadditem(hblob,"blob")
   IF (hblob2)
    SET srvstat = uar_srvsetasis(hblob2,"blob_contents",processnote->finalnote,notesize)
   ENDIF
  ENDIF
 ENDIF
 SET iret = uar_crmperform(hstep)
 CALL echo(build("uar_CrmPerform: ",iret))
 IF (iret > 0)
  SET msg = "iRet => uar_CrmPerform failed"
  GO TO exit_script
 ENDIF
 SET hrep = uar_crmgetreply(hstep)
 CALL echo(build("uar_CrmGetReply: ",hrep))
 IF (hrep <= 0)
  SET msg = "hRep = > uar_CrmGetReply failed"
  GO TO exit_script
 ENDIF
 IF (hrep)
  CALL processsb(hrep)
 ENDIF
 SUBROUTINE processsb(hreply)
   SET hsb = uar_srvgetstruct(hreply,"sb")
   IF (hsb)
    SET severity = uar_srvgetlong(hsb,"severityCd")
    CALL echo(build("severityCD: ",severity))
    SET scd = uar_srvgetlong(hsb,"statusCd")
    CALL echo(build("statusCd: ",scd))
    SET stext = uar_srvgetstring(hsb,"statusText",0,0)
    CALL echo(build("statusText: ",stext))
   ENDIF
   SET hrb = 0
   IF ((validate(reply->clinical_event_id,- (99)) != - (99)))
    SET ltotal = 0
    SET ltotal = uar_srvgetitemcount(hreply,"rb_list")
    IF (ltotal > 0)
     SET hrb = uar_srvgetitem(hreply,"rb_list",0)
     IF (hrb != 0)
      SET reply->clinical_event_id = uar_srvgetdouble(hrb,"clinical_event_id")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (hstep)
  CALL uar_crmendreq(hstep)
 ENDIF
 IF (htask)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ)
  CALL uar_crmendapp(happ)
 ENDIF
 SET script_version = "001 12/05/03 IH6582"
END GO
