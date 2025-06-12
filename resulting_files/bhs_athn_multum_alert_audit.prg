CREATE PROGRAM bhs_athn_multum_alert_audit
 FREE RECORD result
 RECORD result(
   1 drug_drug_alerts[*]
     2 audit_uid = vc
     2 subject_order_id = f8
     2 subject_catalog_cd = f8
     2 causing_order_id = f8
     2 causing_catalog_cd = f8
     2 override_reason_cd = f8
     2 freetext_override_reason = vc
     2 severity_level = vc
     2 action = vc
   1 drug_food_alerts[*]
     2 audit_uid = vc
     2 subject_order_id = f8
     2 subject_catalog_cd = f8
     2 override_reason_cd = f8
     2 freetext_override_reason = vc
     2 severity_level = vc
     2 action = vc
   1 drug_allergy_alerts[*]
     2 audit_uid = vc
     2 subject_order_id = f8
     2 subject_catalog_cd = f8
     2 allergy_id = f8
     2 nomenclature_id = f8
     2 override_reason_cd = f8
     2 freetext_override_reason = vc
     2 severity_level = vc
     2 action = vc
   1 duplicate_therapy_alerts[*]
     2 audit_uid = vc
     2 subject_order_id = f8
     2 subject_catalog_cd = f8
     2 causing_order_id = f8
     2 causing_catalog_cd = f8
     2 override_reason_cd = f8
     2 freetext_override_reason = vc
     2 severity_level = vc
     2 action = vc
   1 error_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
   1 drug_drug_auditing
     2 subject_orders[*]
       3 order_id = f8
       3 encounter_id = f8
       3 interactions[*]
         4 drug_drug_audit_uid = vc
         4 subject_ingredient
           5 catalog_cd = f8
         4 causing_order
           5 order_id = f8
           5 catalog_cd = f8
           5 discontinued_ind = i2
         4 override
           5 override_reason_cd = f8
           5 freetext_override_reason = vc
         4 severity_level
           5 minor_severity_ind = i2
           5 moderate_severity_ind = i2
           5 major_severity_ind = i2
         4 action
           5 display_only_ind = i2
           5 canceled_ind = i2
           5 alert_override_ind = i2
   1 drug_allergy_auditing
     2 subject_orders[*]
       3 order_id = f8
       3 encounter_id = f8
       3 interactions[*]
         4 drug_allergy_audit_uid = vc
         4 subject_ingredient
           5 catalog_cd = f8
         4 causing_allergy
           5 allergy_id = f8
           5 nomenclature_id = f8
         4 override
           5 override_reason_cd = f8
           5 freetext_override_reason = vc
         4 severity_level
           5 minor_severity_ind = i2
           5 moderate_severity_ind = i2
           5 major_severity_ind = i2
         4 action
           5 display_only_ind = i2
           5 canceled_ind = i2
           5 alert_override_ind = i2
   1 drug_food_auditing
     2 subject_orders[*]
       3 order_id = f8
       3 encounter_id = f8
       3 interactions[*]
         4 drug_food_audit_uid = vc
         4 subject_ingredient
           5 catalog_cd = f8
         4 override
           5 override_reason_cd = f8
           5 freetext_override_reason = vc
         4 severity_level
           5 minor_severity_ind = i2
           5 moderate_severity_ind = i2
           5 major_severity_ind = i2
         4 action
           5 display_only_ind = i2
           5 canceled_ind = i2
           5 alert_override_ind = i2
   1 duplicate_therapy_auditing
     2 subject_orders[*]
       3 order_id = f8
       3 encounter_id = f8
       3 duplications[*]
         4 duplicate_therapy_audit_uid = vc
         4 subject_ingredient
           5 catalog_cd = f8
         4 causing_order
           5 order_id = f8
           5 catalog_cd = f8
           5 discontinued_ind = i2
         4 override
           5 override_reason_cd = f8
           5 freetext_override_reason = vc
         4 severity_level
           5 minor_severity_ind = i2
           5 moderate_severity_ind = i2
           5 major_severity_ind = i2
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
 DECLARE parsedrugdrugalerts(null) = i4
 DECLARE parsedrugfoodalerts(null) = i4
 DECLARE parsedrugallergyalerts(null) = i4
 DECLARE parseduplicatetherapyalerts(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE ocnt = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = parsedrugdrugalerts(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = parsedrugfoodalerts(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = parsedrugallergyalerts(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = parseduplicatetherapyalerts(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (((size(result->drug_drug_alerts,5) > 0) OR (((size(result->drug_food_alerts,5) > 0) OR (((size(
  result->drug_allergy_alerts,5) > 0) OR (size(result->duplicate_therapy_alerts,5) > 0)) )) )) )
  SET stat = callauditclinicalchecking(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<ErrorMessage>",trim(replace(replace(replace(replace(replace(substring(1,
            439,result->error_message),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
       "&quot;",0),3),"</ErrorMessage>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD req680414
 FREE RECORD rep680414
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE parsedrugdrugalerts(null)
   DECLARE drugdrugparam = vc WITH protect, noconstant("")
   DECLARE drugdrugblockcnt = i4 WITH protect, noconstant(0)
   DECLARE drugdrugstartpos = i4 WITH protect, noconstant(0)
   DECLARE drugdrugendpos = i4 WITH protect, noconstant(0)
   DECLARE drugdrugblock = vc WITH protect, noconstant("")
   DECLARE drugdrugfieldcnt = i4 WITH protect, noconstant(0)
   DECLARE drugdrugfieldcntvalidind = i2 WITH protect, noconstant(0)
   SET drugdrugstartpos = 1
   SET drugdrugparam = trim( $4,3)
   IF (size(drugdrugparam)=0)
    RETURN(success)
   ENDIF
   FREE RECORD drugdrugblocks
   RECORD drugdrugblocks(
     1 list[*]
       2 drugdrugblock = vc
   ) WITH protect
   WHILE (size(drugdrugparam) > 0)
     SET drugdrugendpos = (findstring("|",drugdrugparam,1) - 1)
     IF (drugdrugendpos <= 0)
      SET drugdrugendpos = size(drugdrugparam)
     ENDIF
     CALL echo(build("DRUGDRUGENDPOS:",drugdrugendpos))
     IF (drugdrugstartpos < drugdrugendpos)
      SET drugdrugblock = substring(1,drugdrugendpos,drugdrugparam)
      CALL echo(build("DRUGDRUGBLOCK:",drugdrugblock))
      IF (size(drugdrugblock) > 0)
       SET drugdrugblock = replace(drugdrugblock,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO DRUGDRUGBLOCKLIST: ",drugdrugblock))
       SET drugdrugblockcnt += 1
       CALL echo(build("DRUGDRUGBLOCKCNT:",drugdrugblockcnt))
       SET stat = alterlist(drugdrugblocks->list,drugdrugblockcnt)
       SET drugdrugblocks->list[drugdrugblockcnt].drugdrugblock = drugdrugblock
      ENDIF
     ENDIF
     SET drugdrugparam = substring((drugdrugendpos+ 2),(size(drugdrugparam) - drugdrugendpos),
      drugdrugparam)
     CALL echo(build("DRUGDRUGPARAM:",drugdrugparam))
     CALL echo(build("SIZE(DRUGDRUGPARAM):",size(drugdrugparam)))
   ENDWHILE
   SET stat = alterlist(result->drug_drug_alerts,drugdrugblockcnt)
   FOR (idx = 1 TO drugdrugblockcnt)
     SET drugdrugblock = drugdrugblocks->list[idx].drugdrugblock
     SET drugdrugfieldcnt = 0
     SET drugdrugstartpos = 0
     IF (((idx=1) OR (drugdrugfieldcntvalidind=1)) )
      SET drugdrugfieldcntvalidind = 0
      WHILE (size(drugdrugblock) > 0)
        IF (substring(1,1,drugdrugblock)=";")
         SET drugdrugendpos = 1
         SET drugdrugparam = ""
        ELSE
         SET drugdrugendpos = (findstring(";",drugdrugblock,1) - 1)
         IF (drugdrugendpos <= 0)
          SET drugdrugendpos = size(drugdrugblock)
         ENDIF
         SET drugdrugparam = substring(1,drugdrugendpos,drugdrugblock)
        ENDIF
        CALL echo(build("DRUGDRUGENDPOS:",drugdrugendpos))
        CALL echo(build("DRUGDRUGPARAM:",drugdrugparam))
        IF (drugdrugstartpos < drugdrugendpos)
         SET drugdrugparam = replace(drugdrugparam,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO DRUG_DRUG_ALERTS LIST: ",drugdrugparam))
         SET drugdrugfieldcnt += 1
         CALL echo(build("DRUGDRUGFIELDCNT:",drugdrugfieldcnt))
         IF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=1)
          SET result->drug_drug_alerts[idx].audit_uid = drugdrugparam
         ELSEIF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=2)
          SET result->drug_drug_alerts[idx].subject_order_id = cnvtreal(drugdrugparam)
         ELSEIF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=3)
          SET result->drug_drug_alerts[idx].subject_catalog_cd = cnvtreal(drugdrugparam)
         ELSEIF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=4)
          SET result->drug_drug_alerts[idx].causing_order_id = cnvtreal(drugdrugparam)
         ELSEIF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=5)
          SET result->drug_drug_alerts[idx].causing_catalog_cd = cnvtreal(drugdrugparam)
         ELSEIF (size(drugdrugparam) > 0
          AND drugdrugfieldcnt=6)
          SET result->drug_drug_alerts[idx].override_reason_cd = cnvtreal(drugdrugparam)
         ELSEIF (drugdrugfieldcnt=7)
          IF (size(drugdrugparam) > 0)
           SET req_format_str->param = drugdrugparam
           EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace(
            "REPLY","REP_FORMAT_STR")
           SET result->drug_drug_alerts[idx].freetext_override_reason = rep_format_str->param
          ELSE
           SET result->drug_drug_alerts[idx].freetext_override_reason = ""
          ENDIF
         ELSEIF (drugdrugfieldcnt=8)
          SET result->drug_drug_alerts[idx].severity_level = cnvtupper(drugdrugparam)
         ELSEIF (drugdrugfieldcnt=9)
          SET result->drug_drug_alerts[idx].action = cnvtupper(drugdrugparam)
          SET drugdrugfieldcntvalidind = 1
         ELSEIF (drugdrugfieldcnt > 9)
          CALL echorecord(drugdrugblocks)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          RETURN(fail)
         ENDIF
        ENDIF
        IF (size(trim(drugdrugparam,3)) > 0)
         SET drugdrugblock = substring((drugdrugendpos+ 2),(size(drugdrugblock) - drugdrugendpos),
          drugdrugblock)
        ELSE
         SET drugdrugblock = substring(2,(size(drugdrugblock) - 1),drugdrugblock)
        ENDIF
        CALL echo(build("DRUGDRUGBLOCK:",drugdrugblock))
        CALL echo(size(drugdrugblock))
      ENDWHILE
     ENDIF
   ENDFOR
   IF (drugdrugfieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    CALL echorecord(drugdrugblocks)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE parsedrugfoodalerts(null)
   DECLARE drugfoodparam = vc WITH protect, noconstant("")
   DECLARE drugfoodblockcnt = i4 WITH protect, noconstant(0)
   DECLARE drugfoodstartpos = i4 WITH protect, noconstant(0)
   DECLARE drugfoodendpos = i4 WITH protect, noconstant(0)
   DECLARE drugfoodblock = vc WITH protect, noconstant("")
   DECLARE drugfoodfieldcnt = i4 WITH protect, noconstant(0)
   DECLARE drugfoodfieldcntvalidind = i2 WITH protect, noconstant(0)
   SET drugfoodstartpos = 1
   SET drugfoodparam = trim( $5,3)
   IF (size(drugfoodparam)=0)
    RETURN(success)
   ENDIF
   FREE RECORD drugfoodblocks
   RECORD drugfoodblocks(
     1 list[*]
       2 drugfoodblock = vc
   ) WITH protect
   WHILE (size(drugfoodparam) > 0)
     SET drugfoodendpos = (findstring("|",drugfoodparam,1) - 1)
     IF (drugfoodendpos <= 0)
      SET drugfoodendpos = size(drugfoodparam)
     ENDIF
     CALL echo(build("DRUGFOODENDPOS:",drugfoodendpos))
     IF (drugfoodstartpos < drugfoodendpos)
      SET drugfoodblock = substring(1,drugfoodendpos,drugfoodparam)
      CALL echo(build("DRUGFOODBLOCK:",drugfoodblock))
      IF (size(drugfoodblock) > 0)
       SET drugfoodblock = replace(drugfoodblock,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO DRUGFOODBLOCKLIST: ",drugfoodblock))
       SET drugfoodblockcnt += 1
       CALL echo(build("DRUGFOODBLOCKCNT:",drugfoodblockcnt))
       SET stat = alterlist(drugfoodblocks->list,drugfoodblockcnt)
       SET drugfoodblocks->list[drugfoodblockcnt].drugfoodblock = drugfoodblock
      ENDIF
     ENDIF
     SET drugfoodparam = substring((drugfoodendpos+ 2),(size(drugfoodparam) - drugfoodendpos),
      drugfoodparam)
     CALL echo(build("DRUGFOODPARAM:",drugfoodparam))
     CALL echo(build("SIZE(DRUGFOODPARAM):",size(drugfoodparam)))
   ENDWHILE
   SET stat = alterlist(result->drug_food_alerts,drugfoodblockcnt)
   FOR (idx = 1 TO drugfoodblockcnt)
     SET drugfoodblock = drugfoodblocks->list[idx].drugfoodblock
     SET drugfoodfieldcnt = 0
     SET drugfoodstartpos = 0
     IF (((idx=1) OR (drugfoodfieldcntvalidind=1)) )
      SET drugfoodfieldcntvalidind = 0
      WHILE (size(drugfoodblock) > 0)
        IF (substring(1,1,drugfoodblock)=";")
         SET drugfoodendpos = 1
         SET drugfoodparam = ""
        ELSE
         SET drugfoodendpos = (findstring(";",drugfoodblock,1) - 1)
         IF (drugfoodendpos <= 0)
          SET drugfoodendpos = size(drugfoodblock)
         ENDIF
         SET drugfoodparam = substring(1,drugfoodendpos,drugfoodblock)
        ENDIF
        CALL echo(build("DRUGFOODENDPOS:",drugfoodendpos))
        CALL echo(build("DRUGFOODPARAM:",drugfoodparam))
        IF (drugfoodstartpos < drugfoodendpos)
         SET drugfoodparam = replace(drugfoodparam,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO DRUG_FOOD_ALERTS LIST: ",drugfoodparam))
         SET drugfoodfieldcnt += 1
         CALL echo(build("DRUGFOODFIELDCNT:",drugfoodfieldcnt))
         IF (size(drugfoodparam) > 0
          AND drugfoodfieldcnt=1)
          SET result->drug_food_alerts[idx].audit_uid = drugfoodparam
         ELSEIF (size(drugfoodparam) > 0
          AND drugfoodfieldcnt=2)
          SET result->drug_food_alerts[idx].subject_order_id = cnvtreal(drugfoodparam)
         ELSEIF (size(drugfoodparam) > 0
          AND drugfoodfieldcnt=3)
          SET result->drug_food_alerts[idx].subject_catalog_cd = cnvtreal(drugfoodparam)
         ELSEIF (size(drugfoodparam) > 0
          AND drugfoodfieldcnt=4)
          SET result->drug_food_alerts[idx].override_reason_cd = cnvtreal(drugfoodparam)
         ELSEIF (drugfoodfieldcnt=5)
          IF (size(drugfoodparam) > 0)
           SET req_format_str->param = drugfoodparam
           EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace(
            "REPLY","REP_FORMAT_STR")
           SET result->drug_food_alerts[idx].freetext_override_reason = rep_format_str->param
          ELSE
           SET result->drug_food_alerts[idx].freetext_override_reason = ""
          ENDIF
         ELSEIF (drugfoodfieldcnt=6)
          SET result->drug_food_alerts[idx].severity_level = cnvtupper(drugfoodparam)
         ELSEIF (drugfoodfieldcnt=7)
          SET result->drug_food_alerts[idx].action = cnvtupper(drugfoodparam)
          SET drugfoodfieldcntvalidind = 1
         ELSEIF (drugfoodfieldcnt > 7)
          CALL echorecord(drugfoodblocks)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          RETURN(fail)
         ENDIF
        ENDIF
        IF (size(trim(drugfoodparam,3)) > 0)
         SET drugfoodblock = substring((drugfoodendpos+ 2),(size(drugfoodblock) - drugfoodendpos),
          drugfoodblock)
        ELSE
         SET drugfoodblock = substring(2,(size(drugfoodblock) - 1),drugfoodblock)
        ENDIF
        CALL echo(build("DRUGFOODBLOCK:",drugfoodblock))
        CALL echo(size(drugfoodblock))
      ENDWHILE
     ENDIF
   ENDFOR
   IF (drugfoodfieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    CALL echorecord(drugfoodblocks)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE parsedrugallergyalerts(null)
   DECLARE drugallergyparam = vc WITH protect, noconstant("")
   DECLARE drugallergyblockcnt = i4 WITH protect, noconstant(0)
   DECLARE drugallergystartpos = i4 WITH protect, noconstant(0)
   DECLARE drugallergyendpos = i4 WITH protect, noconstant(0)
   DECLARE drugallergyblock = vc WITH protect, noconstant("")
   DECLARE drugallergyfieldcnt = i4 WITH protect, noconstant(0)
   DECLARE drugallergyfieldcntvalidind = i2 WITH protect, noconstant(0)
   SET drugallergystartpos = 1
   SET drugallergyparam = trim( $6,3)
   IF (size(drugallergyparam)=0)
    RETURN(success)
   ENDIF
   FREE RECORD drugallergyblocks
   RECORD drugallergyblocks(
     1 list[*]
       2 drugallergyblock = vc
   ) WITH protect
   WHILE (size(drugallergyparam) > 0)
     SET drugallergyendpos = (findstring("|",drugallergyparam,1) - 1)
     IF (drugallergyendpos <= 0)
      SET drugallergyendpos = size(drugallergyparam)
     ENDIF
     CALL echo(build("DRUGALLERGYENDPOS:",drugallergyendpos))
     IF (drugallergystartpos < drugallergyendpos)
      SET drugallergyblock = substring(1,drugallergyendpos,drugallergyparam)
      CALL echo(build("DRUGALLERGYBLOCK:",drugallergyblock))
      IF (size(drugallergyblock) > 0)
       SET drugallergyblock = replace(drugallergyblock,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO DRUGALLERGYBLOCKLIST: ",drugallergyblock))
       SET drugallergyblockcnt += 1
       CALL echo(build("DRUGALLERGYBLOCKCNT:",drugallergyblockcnt))
       SET stat = alterlist(drugallergyblocks->list,drugallergyblockcnt)
       SET drugallergyblocks->list[drugallergyblockcnt].drugallergyblock = drugallergyblock
      ENDIF
     ENDIF
     SET drugallergyparam = substring((drugallergyendpos+ 2),(size(drugallergyparam) -
      drugallergyendpos),drugallergyparam)
     CALL echo(build("DRUGALLERGYPARAM:",drugallergyparam))
     CALL echo(build("SIZE(DRUGALLERGYPARAM):",size(drugallergyparam)))
   ENDWHILE
   SET stat = alterlist(result->drug_allergy_alerts,drugallergyblockcnt)
   FOR (idx = 1 TO drugallergyblockcnt)
     SET drugallergyblock = drugallergyblocks->list[idx].drugallergyblock
     SET drugallergyfieldcnt = 0
     SET drugallergystartpos = 0
     IF (((idx=1) OR (drugallergyfieldcntvalidind=1)) )
      SET drugallergyfieldcntvalidind = 0
      WHILE (size(drugallergyblock) > 0)
        IF (substring(1,1,drugallergyblock)=";")
         SET drugallergyendpos = 1
         SET drugallergyparam = ""
        ELSE
         SET drugallergyendpos = (findstring(";",drugallergyblock,1) - 1)
         IF (drugallergyendpos <= 0)
          SET drugallergyendpos = size(drugallergyblock)
         ENDIF
         SET drugallergyparam = substring(1,drugallergyendpos,drugallergyblock)
        ENDIF
        CALL echo(build("DRUGALLERGYENDPOS:",drugallergyendpos))
        CALL echo(build("DRUGALLERGYPARAM:",drugallergyparam))
        IF (drugallergystartpos < drugallergyendpos)
         SET drugallergyparam = replace(drugallergyparam,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO DRUG_ALLERGY_ALERTS LIST: ",drugallergyparam))
         SET drugallergyfieldcnt += 1
         CALL echo(build("DRUGALLERGYFIELDCNT:",drugallergyfieldcnt))
         IF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=1)
          SET result->drug_allergy_alerts[idx].audit_uid = drugallergyparam
         ELSEIF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=2)
          SET result->drug_allergy_alerts[idx].subject_order_id = cnvtreal(drugallergyparam)
         ELSEIF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=3)
          SET result->drug_allergy_alerts[idx].subject_catalog_cd = cnvtreal(drugallergyparam)
         ELSEIF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=4)
          SET result->drug_allergy_alerts[idx].allergy_id = cnvtreal(drugallergyparam)
         ELSEIF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=5)
          SET result->drug_allergy_alerts[idx].nomenclature_id = cnvtreal(drugallergyparam)
         ELSEIF (size(drugallergyparam) > 0
          AND drugallergyfieldcnt=6)
          SET result->drug_allergy_alerts[idx].override_reason_cd = cnvtreal(drugallergyparam)
         ELSEIF (drugallergyfieldcnt=7)
          IF (size(drugallergyparam) > 0)
           SET req_format_str->param = drugallergyparam
           EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace(
            "REPLY","REP_FORMAT_STR")
           SET result->drug_allergy_alerts[idx].freetext_override_reason = rep_format_str->param
          ELSE
           SET result->drug_allergy_alerts[idx].freetext_override_reason = ""
          ENDIF
         ELSEIF (drugallergyfieldcnt=8)
          SET result->drug_allergy_alerts[idx].severity_level = cnvtupper(drugallergyparam)
         ELSEIF (drugallergyfieldcnt=9)
          SET result->drug_allergy_alerts[idx].action = cnvtupper(drugallergyparam)
          SET drugallergyfieldcntvalidind = 1
         ELSEIF (drugallergyfieldcnt > 9)
          CALL echorecord(drugallergyblocks)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          RETURN(fail)
         ENDIF
        ENDIF
        IF (size(trim(drugallergyparam,3)) > 0)
         SET drugallergyblock = substring((drugallergyendpos+ 2),(size(drugallergyblock) -
          drugallergyendpos),drugallergyblock)
        ELSE
         SET drugallergyblock = substring(2,(size(drugallergyblock) - 1),drugallergyblock)
        ENDIF
        CALL echo(build("DRUGALLERGYBLOCK:",drugallergyblock))
        CALL echo(size(drugallergyblock))
      ENDWHILE
     ENDIF
   ENDFOR
   IF (drugallergyfieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    CALL echorecord(drugallergyblocks)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE parseduplicatetherapyalerts(null)
   DECLARE duptherapyparam = vc WITH protect, noconstant("")
   DECLARE duptherapyblockcnt = i4 WITH protect, noconstant(0)
   DECLARE duptherapystartpos = i4 WITH protect, noconstant(0)
   DECLARE duptherapyendpos = i4 WITH protect, noconstant(0)
   DECLARE duptherapyblock = vc WITH protect, noconstant("")
   DECLARE duptherapyfieldcnt = i4 WITH protect, noconstant(0)
   DECLARE duptherapyfieldcntvalidind = i2 WITH protect, noconstant(0)
   SET duptherapystartpos = 1
   SET duptherapyparam = trim( $7,3)
   IF (size(duptherapyparam)=0)
    RETURN(success)
   ENDIF
   FREE RECORD duptherapyblocks
   RECORD duptherapyblocks(
     1 list[*]
       2 duptherapyblock = vc
   ) WITH protect
   WHILE (size(duptherapyparam) > 0)
     SET duptherapyendpos = (findstring("|",duptherapyparam,1) - 1)
     IF (duptherapyendpos <= 0)
      SET duptherapyendpos = size(duptherapyparam)
     ENDIF
     CALL echo(build("DUPTHERAPYENDPOS:",duptherapyendpos))
     IF (duptherapystartpos < duptherapyendpos)
      SET duptherapyblock = substring(1,duptherapyendpos,duptherapyparam)
      CALL echo(build("DUPTHERAPYBLOCK:",duptherapyblock))
      IF (size(duptherapyblock) > 0)
       SET duptherapyblock = replace(duptherapyblock,"-!pipe!-","|",0)
       CALL echo(build("ADDING FIELD TO DUPTHERAPYBLOCKLIST: ",duptherapyblock))
       SET duptherapyblockcnt += 1
       CALL echo(build("DUPTHERAPYBLOCKCNT:",duptherapyblockcnt))
       SET stat = alterlist(duptherapyblocks->list,duptherapyblockcnt)
       SET duptherapyblocks->list[duptherapyblockcnt].duptherapyblock = duptherapyblock
      ENDIF
     ENDIF
     SET duptherapyparam = substring((duptherapyendpos+ 2),(size(duptherapyparam) - duptherapyendpos),
      duptherapyparam)
     CALL echo(build("DUPTHERAPYPARAM:",duptherapyparam))
     CALL echo(build("SIZE(DUPTHERAPYPARAM):",size(duptherapyparam)))
   ENDWHILE
   SET stat = alterlist(result->duplicate_therapy_alerts,duptherapyblockcnt)
   FOR (idx = 1 TO duptherapyblockcnt)
     SET duptherapyblock = duptherapyblocks->list[idx].duptherapyblock
     SET duptherapyfieldcnt = 0
     SET duptherapystartpos = 0
     IF (((idx=1) OR (duptherapyfieldcntvalidind=1)) )
      SET duptherapyfieldcntvalidind = 0
      WHILE (size(duptherapyblock) > 0)
        IF (substring(1,1,duptherapyblock)=";")
         SET duptherapyendpos = 1
         SET duptherapyparam = ""
        ELSE
         SET duptherapyendpos = (findstring(";",duptherapyblock,1) - 1)
         IF (duptherapyendpos <= 0)
          SET duptherapyendpos = size(duptherapyblock)
         ENDIF
         SET duptherapyparam = substring(1,duptherapyendpos,duptherapyblock)
        ENDIF
        CALL echo(build("DUPTHERAPYENDPOS:",duptherapyendpos))
        CALL echo(build("DUPTHERAPYPARAM:",duptherapyparam))
        IF (duptherapystartpos < duptherapyendpos)
         SET duptherapyparam = replace(duptherapyparam,"ltscolgt",";",0)
         CALL echo(build("ADDING FIELD TO DUPLICATE_THERAPY_ALERTS LIST: ",duptherapyparam))
         SET duptherapyfieldcnt += 1
         CALL echo(build("DUPTHERAPYFIELDCNT:",duptherapyfieldcnt))
         IF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=1)
          SET result->duplicate_therapy_alerts[idx].audit_uid = duptherapyparam
         ELSEIF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=2)
          SET result->duplicate_therapy_alerts[idx].subject_order_id = cnvtreal(duptherapyparam)
         ELSEIF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=3)
          SET result->duplicate_therapy_alerts[idx].subject_catalog_cd = cnvtreal(duptherapyparam)
         ELSEIF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=4)
          SET result->duplicate_therapy_alerts[idx].causing_order_id = cnvtreal(duptherapyparam)
         ELSEIF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=5)
          SET result->duplicate_therapy_alerts[idx].causing_catalog_cd = cnvtreal(duptherapyparam)
         ELSEIF (size(duptherapyparam) > 0
          AND duptherapyfieldcnt=6)
          SET result->duplicate_therapy_alerts[idx].override_reason_cd = cnvtreal(duptherapyparam)
         ELSEIF (duptherapyfieldcnt=7)
          IF (size(duptherapyparam) > 0)
           SET req_format_str->param = duptherapyparam
           EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace(
            "REPLY","REP_FORMAT_STR")
           SET result->duplicate_therapy_alerts[idx].freetext_override_reason = rep_format_str->param
          ELSE
           SET result->duplicate_therapy_alerts[idx].freetext_override_reason = ""
          ENDIF
         ELSEIF (duptherapyfieldcnt=8)
          SET result->duplicate_therapy_alerts[idx].severity_level = cnvtupper(duptherapyparam)
         ELSEIF (duptherapyfieldcnt=9)
          SET result->duplicate_therapy_alerts[idx].action = cnvtupper(duptherapyparam)
          SET duptherapyfieldcntvalidind = 1
         ELSEIF (duptherapyfieldcnt > 9)
          CALL echorecord(duptherapyblocks)
          CALL echo("INVALID NUMBER OF FIELDS (TOO MANY)...EXITING")
          CALL echo(
           "CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
          RETURN(fail)
         ENDIF
        ENDIF
        IF (size(trim(duptherapyparam,3)) > 0)
         SET duptherapyblock = substring((duptherapyendpos+ 2),(size(duptherapyblock) -
          duptherapyendpos),duptherapyblock)
        ELSE
         SET duptherapyblock = substring(2,(size(duptherapyblock) - 1),duptherapyblock)
        ENDIF
        CALL echo(build("DUPTHERAPYBLOCK:",duptherapyblock))
        CALL echo(size(duptherapyblock))
      ENDWHILE
     ENDIF
   ENDFOR
   IF (duptherapyfieldcntvalidind=0)
    CALL echo("INVALID NUMBER OF FIELDS (TOO FEW)...EXITING")
    CALL echo("CHECK THAT FIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
    CALL echorecord(duptherapyblocks)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callauditclinicalchecking(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600060)
   DECLARE requestid = i4 WITH constant(680414)
   DECLARE sbjctidx = i4 WITH protect, noconstant(0)
   DECLARE ddsbjctcnt = i4 WITH protect, noconstant(0)
   DECLARE dfsbjctcnt = i4 WITH protect, noconstant(0)
   DECLARE dasbjctcnt = i4 WITH protect, noconstant(0)
   DECLARE dtsbjctcnt = i4 WITH protect, noconstant(0)
   DECLARE intcnt = i4 WITH protect, noconstant(0)
   DECLARE dfcnt = i4 WITH protect, noconstant(0)
   DECLARE dacnt = i4 WITH protect, noconstant(0)
   DECLARE dtcnt = i4 WITH protect, noconstant(0)
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FOR (idx = 1 TO size(result->drug_drug_alerts,5))
     SET sbjctidx = locateval(locidx,1,ddsbjctcnt,result->drug_drug_alerts[idx].subject_order_id,
      req680414->drug_drug_auditing.subject_orders[locidx].order_id)
     IF (sbjctidx=0)
      SET ddsbjctcnt += 1
      SET stat = alterlist(req680414->drug_drug_auditing.subject_orders,ddsbjctcnt)
      SET sbjctidx = ddsbjctcnt
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].order_id = result->drug_drug_alerts[
      idx].subject_order_id
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].encounter_id =  $2
     ENDIF
     SET intcnt = (size(req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions,5)+ 1)
     SET stat = alterlist(req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions,intcnt)
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].
     drug_drug_audit_uid = result->drug_drug_alerts[idx].audit_uid
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].
     subject_ingredient.catalog_cd = result->drug_drug_alerts[idx].subject_catalog_cd
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].causing_order.
     order_id = result->drug_drug_alerts[idx].causing_order_id
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].causing_order.
     catalog_cd = result->drug_drug_alerts[idx].causing_catalog_cd
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].causing_order.
     discontinued_ind = 0
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].override.
     override_reason_cd = result->drug_drug_alerts[idx].override_reason_cd
     SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].override.
     freetext_override_reason = result->drug_drug_alerts[idx].freetext_override_reason
     IF ((result->drug_drug_alerts[idx].severity_level="MINOR"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].severity_level.
      minor_severity_ind = 1
     ELSEIF ((result->drug_drug_alerts[idx].severity_level="MODERATE"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].severity_level.
      moderate_severity_ind = 1
     ELSEIF ((result->drug_drug_alerts[idx].severity_level="MAJOR"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].severity_level.
      major_severity_ind = 1
     ENDIF
     IF ((result->drug_drug_alerts[idx].action="DISPLAY_ONLY"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].action.
      display_only_ind = 1
     ELSEIF ((result->drug_drug_alerts[idx].action="CANCELED"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].action.
      canceled_ind = 1
     ELSEIF ((result->drug_drug_alerts[idx].action="OVERRIDE"))
      SET req680414->drug_drug_auditing.subject_orders[sbjctidx].interactions[intcnt].action.
      alert_override_ind = 1
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size(result->drug_food_alerts,5))
     SET sbjctidx = locateval(locidx,1,dfsbjctcnt,result->drug_food_alerts[idx].subject_order_id,
      req680414->drug_food_auditing.subject_orders[locidx].order_id)
     IF (sbjctidx=0)
      SET dfsbjctcnt += 1
      SET stat = alterlist(req680414->drug_food_auditing.subject_orders,dfsbjctcnt)
      SET sbjctidx = dfsbjctcnt
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].order_id = result->drug_food_alerts[
      idx].subject_order_id
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].encounter_id =  $2
     ENDIF
     SET dfcnt = (size(req680414->drug_food_auditing.subject_orders[sbjctidx].interactions,5)+ 1)
     SET stat = alterlist(req680414->drug_food_auditing.subject_orders[sbjctidx].interactions,dfcnt)
     SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].
     drug_food_audit_uid = result->drug_food_alerts[idx].audit_uid
     SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].
     subject_ingredient.catalog_cd = result->drug_food_alerts[idx].subject_catalog_cd
     SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].override.
     override_reason_cd = result->drug_food_alerts[idx].override_reason_cd
     SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].override.
     freetext_override_reason = result->drug_food_alerts[idx].freetext_override_reason
     IF ((result->drug_food_alerts[idx].severity_level="MINOR"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].severity_level.
      minor_severity_ind = 1
     ELSEIF ((result->drug_food_alerts[idx].severity_level="MODERATE"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].severity_level.
      moderate_severity_ind = 1
     ELSEIF ((result->drug_food_alerts[idx].severity_level="MAJOR"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].severity_level.
      major_severity_ind = 1
     ENDIF
     IF ((result->drug_food_alerts[idx].action="DISPLAY_ONLY"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].action.
      display_only_ind = 1
     ELSEIF ((result->drug_food_alerts[idx].action="CANCELED"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].action.
      canceled_ind = 1
     ELSEIF ((result->drug_food_alerts[idx].action="OVERRIDE"))
      SET req680414->drug_food_auditing.subject_orders[sbjctidx].interactions[dfcnt].action.
      alert_override_ind = 1
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size(result->drug_allergy_alerts,5))
     SET sbjctidx = locateval(locidx,1,dasbjctcnt,result->drug_allergy_alerts[idx].subject_order_id,
      req680414->drug_allergy_auditing.subject_orders[locidx].order_id)
     IF (sbjctidx=0)
      SET dasbjctcnt += 1
      SET stat = alterlist(req680414->drug_allergy_auditing.subject_orders,dasbjctcnt)
      SET sbjctidx = dasbjctcnt
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].order_id = result->
      drug_allergy_alerts[idx].subject_order_id
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].encounter_id =  $2
     ENDIF
     SET dacnt = (size(req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions,5)+ 1)
     SET stat = alterlist(req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions,
      dacnt)
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
     drug_allergy_audit_uid = result->drug_allergy_alerts[idx].audit_uid
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
     subject_ingredient.catalog_cd = result->drug_allergy_alerts[idx].subject_catalog_cd
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
     causing_allergy.allergy_id = result->drug_allergy_alerts[idx].allergy_id
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
     causing_allergy.nomenclature_id = result->drug_allergy_alerts[idx].nomenclature_id
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].override.
     override_reason_cd = result->drug_allergy_alerts[idx].override_reason_cd
     SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].override.
     freetext_override_reason = result->drug_allergy_alerts[idx].freetext_override_reason
     IF ((result->drug_allergy_alerts[idx].severity_level="MINOR"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
      severity_level.minor_severity_ind = 1
     ELSEIF ((result->drug_allergy_alerts[idx].severity_level="MODERATE"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
      severity_level.moderate_severity_ind = 1
     ELSEIF ((result->drug_allergy_alerts[idx].severity_level="MAJOR"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].
      severity_level.major_severity_ind = 1
     ENDIF
     IF ((result->drug_allergy_alerts[idx].action="DISPLAY_ONLY"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].action.
      display_only_ind = 1
     ELSEIF ((result->drug_allergy_alerts[idx].action="CANCELED"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].action.
      canceled_ind = 1
     ELSEIF ((result->drug_allergy_alerts[idx].action="OVERRIDE"))
      SET req680414->drug_allergy_auditing.subject_orders[sbjctidx].interactions[dacnt].action.
      alert_override_ind = 1
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size(result->duplicate_therapy_alerts,5))
     SET sbjctidx = locateval(locidx,1,dtsbjctcnt,result->duplicate_therapy_alerts[idx].
      subject_order_id,req680414->duplicate_therapy_auditing.subject_orders[locidx].order_id)
     IF (sbjctidx=0)
      SET dtsbjctcnt += 1
      SET stat = alterlist(req680414->duplicate_therapy_auditing.subject_orders,dtsbjctcnt)
      SET sbjctidx = dtsbjctcnt
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].order_id = result->
      duplicate_therapy_alerts[idx].subject_order_id
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].encounter_id =  $2
     ENDIF
     SET dtcnt = (size(req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications,5)
     + 1)
     SET stat = alterlist(req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications,
      dtcnt)
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
     duplicate_therapy_audit_uid = result->duplicate_therapy_alerts[idx].audit_uid
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
     subject_ingredient.catalog_cd = result->duplicate_therapy_alerts[idx].subject_catalog_cd
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
     causing_order.order_id = result->duplicate_therapy_alerts[idx].causing_order_id
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
     causing_order.catalog_cd = result->duplicate_therapy_alerts[idx].causing_catalog_cd
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
     causing_order.discontinued_ind = 0
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].override.
     override_reason_cd = result->duplicate_therapy_alerts[idx].override_reason_cd
     SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].override.
     freetext_override_reason = result->duplicate_therapy_alerts[idx].freetext_override_reason
     IF ((result->duplicate_therapy_alerts[idx].severity_level="MINOR"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
      severity_level.minor_severity_ind = 1
     ELSEIF ((result->duplicate_therapy_alerts[idx].severity_level="MODERATE"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
      severity_level.moderate_severity_ind = 1
     ELSEIF ((result->duplicate_therapy_alerts[idx].severity_level="MAJOR"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].
      severity_level.major_severity_ind = 1
     ENDIF
     IF ((result->duplicate_therapy_alerts[idx].action="DISPLAY_ONLY"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].action.
      display_only_ind = 1
     ELSEIF ((result->duplicate_therapy_alerts[idx].action="CANCELED"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].action.
      canceled_ind = 1
     ELSEIF ((result->duplicate_therapy_alerts[idx].action="OVERRIDE"))
      SET req680414->duplicate_therapy_auditing.subject_orders[sbjctidx].duplications[dtcnt].action.
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
