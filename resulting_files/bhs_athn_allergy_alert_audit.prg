CREATE PROGRAM bhs_athn_allergy_alert_audit
 FREE RECORD result
 RECORD result(
   1 allergy_drug_alerts[*]
     2 audit_uid = vc
     2 allergy_id = f8
     2 nomenclature_id = f8
     2 causing_order_id = f8
     2 causing_catalog_cd = f8
     2 discontinued_ind = i2
     2 override_reason_cd = f8
     2 freetext_override_reason = vc
     2 action = vc
   1 error_message = vc
   1 status = c1
 ) WITH protect
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD i_request
 RECORD i_request(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD i_reply
 RECORD i_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req680414
 RECORD req680414(
   1 allergy_drug_auditing
     2 subject_allergies[*]
       3 allergy_id = f8
       3 nomenclature_id = f8
       3 encounter_id = f8
       3 interactions[*]
         4 allergy_drug_audit_uid = vc
         4 causing_order
           5 order_id = f8
           5 catalog_cd = f8
           5 discontinued_ind = i2
         4 override
           5 override_reason_cd = f8
           5 freetext_override_reason = vc
         4 action
           5 display_only_ind = i2
           5 canceled_ind = i2
           5 alert_override_ind = i2
 ) WITH protect
 FREE RECORD rep680414
 RECORD rep680414(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 transaction_uid = vc
 ) WITH protect
 DECLARE callauditclinicalchecking(null) = i4
 DECLARE parseallergydrugalerts(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE ocnt = i4 WITH protect, noconstant(0)
 SET result->status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = parseallergydrugalerts(null)
 IF (stat=fail)
  SET result->error_message = "ERROR WHILE PARSING INPUT PARAMS"
  GO TO exit_script
 ENDIF
 IF (size(result->allergy_drug_alerts,5) > 0)
  SET stat = callauditclinicalchecking(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 SET _memory_reply_string = cnvtrectojson(result,5)
 FREE RECORD result
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD req680414
 FREE RECORD rep680414
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE parseallergydrugalerts(null)
   DECLARE allergydrugparam = vc WITH protect, noconstant("")
   DECLARE allergydrugblockcnt = i4 WITH protect, noconstant(0)
   DECLARE allergydrugstartpos = i4 WITH protect, noconstant(0)
   DECLARE allergydrugendpos = i4 WITH protect, noconstant(0)
   DECLARE allergydrugblock = vc WITH protect, noconstant("")
   DECLARE allergydrugfieldcnt = i4 WITH protect, noconstant(0)
   DECLARE allergydrugfieldcntvalidind = i2 WITH protect, noconstant(0)
   SET allergydrugstartpos = 1
   SET allergydrugparam = trim( $4,3)
   IF (size(allergydrugparam)=0)
    RETURN(success)
   ENDIF
   FREE RECORD allergydrugblocks
   RECORD allergydrugblocks(
     1 list[*]
       2 allergydrugblock = vc
   ) WITH protect
   WHILE (size(allergydrugparam) > 0)
     SET allergydrugendpos = (findstring("|",allergydrugparam,1) - 1)
     IF (allergydrugendpos <= 0)
      SET allergydrugendpos = size(allergydrugparam)
     ENDIF
     CALL echo(build("ALLERGYDRUGENDPOS:",allergydrugendpos))
     IF (allergydrugstartpos < allergydrugendpos)
      SET allergydrugblock = substring(1,allergydrugendpos,allergydrugparam)
      CALL echo(build("ALLERGYDRUGBLOCK:",allergydrugblock))
      IF (size(allergydrugblock) > 0)
       SET allergydrugblock = replace(allergydrugblock,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO ALLERGYDRUGBLOCKLIST: ",allergydrugblock))
       SET allergydrugblockcnt += 1
       CALL echo(build("ALLERGYDRUGBLOCKCNT:",allergydrugblockcnt))
       SET stat = alterlist(allergydrugblocks->list,allergydrugblockcnt)
       SET allergydrugblocks->list[allergydrugblockcnt].allergydrugblock = allergydrugblock
      ENDIF
     ENDIF
     SET allergydrugparam = substring((allergydrugendpos+ 2),(size(allergydrugparam) -
      allergydrugendpos),allergydrugparam)
     CALL echo(build("ALLERGYDRUGPARAM:",allergydrugparam))
     CALL echo(build("SIZE(ALLERGYDRUGPARAM):",size(allergydrugparam)))
   ENDWHILE
   SET stat = alterlist(result->allergy_drug_alerts,allergydrugblockcnt)
   FOR (idx = 1 TO allergydrugblockcnt)
     SET allergydrugblock = allergydrugblocks->list[idx].allergydrugblock
     SET allergydrugfieldcnt = 0
     SET allergydrugendpos = 0
     IF (((idx=1) OR (allergydrugfieldcntvalidind=1)) )
      SET allergydrugfieldcntvalidind = 0
      WHILE (size(allergydrugblock) > 0)
        IF (substring(1,1,allergydrugblock)=";")
         SET allergydrugendpos = 1
         SET allergydrugparam = ""
        ELSE
         SET allergydrugendpos = (findstring(";",allergydrugblock,1) - 1)
         IF (allergydrugendpos <= 0)
          SET allergydrugendpos = size(allergydrugblock)
         ENDIF
         SET allergydrugparam = substring(1,allergydrugendpos,allergydrugblock)
        ENDIF
        CALL echo(build("ALLERGYDRUGENDPOS:",allergydrugendpos))
        CALL echo(build("ALLERGYDRUGPARAM:",allergydrugparam))
        IF (allergydrugstartpos <= allergydrugendpos)
         SET allergydrugparam = replace(allergydrugparam,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO ALLERGY_DRUG_ALERTS LIST: ",allergydrugparam))
         SET allergydrugfieldcnt += 1
         CALL echo(build("ALLERGYDRUGFIELDCNT:",allergydrugfieldcnt))
         IF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=1)
          SET result->allergy_drug_alerts[idx].audit_uid = allergydrugparam
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=2)
          SET result->allergy_drug_alerts[idx].allergy_id = cnvtreal(allergydrugparam)
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=3)
          SET result->allergy_drug_alerts[idx].nomenclature_id = cnvtreal(allergydrugparam)
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=4)
          SET result->allergy_drug_alerts[idx].causing_order_id = cnvtreal(allergydrugparam)
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=5)
          SET result->allergy_drug_alerts[idx].causing_catalog_cd = cnvtreal(allergydrugparam)
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=6)
          SET result->allergy_drug_alerts[idx].discontinued_ind = cnvtint(allergydrugparam)
         ELSEIF (size(allergydrugparam) > 0
          AND allergydrugfieldcnt=7)
          SET result->allergy_drug_alerts[idx].override_reason_cd = cnvtreal(allergydrugparam)
         ELSEIF (size(allergydrugparam)
          AND allergydrugfieldcnt=8)
          IF (size(allergydrugparam) > 0)
           SET req_format_str->param = allergydrugparam
           EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace(
            "REPLY","REP_FORMAT_STR")
           SET result->allergy_drug_alerts[idx].freetext_override_reason = rep_format_str->param
          ELSE
           SET result->allergy_drug_alerts[idx].freetext_override_reason = ""
          ENDIF
         ELSEIF (allergydrugfieldcnt=9)
          SET result->allergy_drug_alerts[idx].action = cnvtupper(allergydrugparam)
          SET allergydrugfieldcntvalidind = 1
         ELSEIF (allergydrugfieldcnt > 9)
          CALL echorecord(allergydrugblocks)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          RETURN(fail)
         ENDIF
        ENDIF
        IF (size(trim(allergydrugparam,3)) > 0)
         SET allergydrugblock = substring((allergydrugendpos+ 2),(size(allergydrugblock) -
          allergydrugendpos),allergydrugblock)
        ELSE
         SET allergydrugblock = substring(2,(size(allergydrugblock) - 1),allergydrugblock)
        ENDIF
        CALL echo(build("ALLERGYDRUGBLOCK:",allergydrugblock))
        CALL echo(size(allergydrugblock))
      ENDWHILE
     ENDIF
   ENDFOR
   IF (allergydrugfieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    CALL echorecord(allergydrugblocks)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callauditclinicalchecking(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680414)
   DECLARE sbjctidx = i4 WITH protect, noconstant(0)
   DECLARE adsbjctcnt = i4 WITH protect, noconstant(0)
   DECLARE intcnt = i4 WITH protect, noconstant(0)
   DECLARE adcnt = i4 WITH protect, noconstant(0)
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FOR (idx = 1 TO size(result->allergy_drug_alerts,5))
     SET sbjctidx = locateval(locidx,1,adsbjctcnt,result->allergy_drug_alerts[idx].allergy_id,
      req680414->allergy_drug_auditing.subject_allergies[locidx].allergy_id)
     IF (sbjctidx=0)
      SET adsbjctcnt += 1
      SET stat = alterlist(req680414->allergy_drug_auditing.subject_allergies,adsbjctcnt)
      SET sbjctidx = adsbjctcnt
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].allergy_id = result->
      allergy_drug_alerts[idx].allergy_id
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].nomenclature_id = result->
      allergy_drug_alerts[idx].nomenclature_id
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].encounter_id =  $2
     ENDIF
     SET adcnt = (size(req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions,5)+
     1)
     SET stat = alterlist(req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions,
      adcnt)
     SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].
     allergy_drug_audit_uid = result->allergy_drug_alerts[idx].audit_uid
     SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].
     causing_order.catalog_cd = result->allergy_drug_alerts[idx].causing_catalog_cd
     SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].
     causing_order.order_id = result->allergy_drug_alerts[idx].causing_order_id
     SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].
     causing_order.discontinued_ind = result->allergy_drug_alerts[idx].discontinued_ind
     SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].override.
     override_reason_cd = result->allergy_drug_alerts[idx].override_reason_cd
     IF ((result->allergy_drug_alerts[idx].override_reason_cd=0.00))
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].override.
      freetext_override_reason = result->allergy_drug_alerts[idx].freetext_override_reason
     ENDIF
     IF ((result->allergy_drug_alerts[idx].action="DISPLAY_ONLY"))
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].action.
      display_only_ind = 1
     ELSEIF ((result->allergy_drug_alerts[idx].action="CANCELED"))
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].action.
      canceled_ind = 1
     ELSEIF ((result->allergy_drug_alerts[idx].action="OVERRIDE"))
      SET req680414->allergy_drug_auditing.subject_allergies[sbjctidx].interactions[adcnt].action.
      alert_override_ind = 1
     ENDIF
   ENDFOR
   CALL echorecord(req680414)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680414,
    "REC",rep680414,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep680414)
   IF ((rep680414->transaction_status.success_ind=1))
    RETURN(success)
   ELSE
    SET result->error_message = rep680414->transaction_status.debug_error_message
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
