CREATE PROGRAM bhs_athn_get_mcds_citations
 FREE RECORD req680422
 RECORD req680422(
   1 drug_drug_interaction_criterias[*]
     2 unique_identifier = vc
     2 subject_cki = vc
     2 causing_cki = vc
   1 drug_food_interaction_criterias[*]
     2 unique_identifier = vc
     2 subject_cki = vc
   1 allergy_criterias[*]
     2 unique_identifier = vc
     2 subject_cki = vc
     2 causing_cki = vc
     2 interaction_type
       3 drug_ind = i2
       3 category_ind = i2
       3 class_ind = i2
 ) WITH protect
 FREE RECORD rep680422
 RECORD rep680422(
   1 transaction_uid = vc
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 drug_drug_interactions[*]
     2 unique_identifier = vc
     2 citations[*]
       3 journal_abbreviation = vc
       3 volume_issue = vc
       3 title = vc
       3 authors = vc
       3 pages = vc
       3 year_complete = vc
   1 drug_food_interactions[*]
     2 unique_identifier = vc
     2 citations[*]
       3 journal_abbreviation = vc
       3 volume_issue = vc
       3 title = vc
       3 authors = vc
       3 pages = vc
       3 year_complete = vc
   1 allergy_interactions[*]
     2 unique_identifier = vc
     2 citations[*]
       3 journal_abbreviation = vc
       3 volume_issue = vc
       3 title = vc
       3 authors = vc
       3 pages = vc
       3 year_complete = vc
 ) WITH protect
 FREE RECORD out_rec
 RECORD out_rec(
   1 alert_text = vc
 ) WITH protect
 DECLARE callgetcitations(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 DECLARE citation = vc
 DECLARE html_header = vc
 DECLARE html_footer = vc
 DECLARE license = vc
 SET stat = callgetcitations(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(out_rec)
 IF (size(trim(moutputdevice,3)) > 0)
  SET html_header = build2("<html><?xml version=",'"',"1.0",'"'," encoding=",
   '"',"UTF-8",'"'," ?><body>")
  SET html_footer = build2("</body></html>")
  IF (( $4=0)
   AND size(rep680422->drug_drug_interactions,5) > 0)
   SET license =
   "&copy; Copyright 1996 - 2020 Cerner Multum, Inc. Revision Date: Multum (United States): March 2020 v200316"
   FOR (idx = 1 TO size(rep680422->drug_drug_interactions[1].citations,5))
     IF ((rep680422->drug_drug_interactions[1].citations[idx].authors != ""))
      SET citation = concat(citation,trim(rep680422->drug_drug_interactions[1].citations[idx].authors
        ))
     ENDIF
     IF ((rep680422->drug_drug_interactions[1].citations[idx].title != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_drug_interactions[1].citations[idx].
        title))
     ENDIF
     IF ((rep680422->drug_drug_interactions[1].citations[idx].journal_abbreviation != ""))
      SET citation = concat(citation,", <i>",concat(trim(rep680422->drug_drug_interactions[1].
         citations[idx].journal_abbreviation),"</i>"))
     ENDIF
     IF ((rep680422->drug_drug_interactions[1].citations[idx].year_complete != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_drug_interactions[1].citations[idx].
        year_complete))
     ENDIF
     IF ((rep680422->drug_drug_interactions[1].citations[idx].volume_issue != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_drug_interactions[1].citations[idx].
        volume_issue))
     ENDIF
     IF ((rep680422->drug_drug_interactions[1].citations[idx].pages != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_drug_interactions[1].citations[idx].
        pages))
     ENDIF
     SET citation = build2(concat(citation,"<br/><br/>"))
   ENDFOR
  ELSEIF (( $4=1)
   AND size(rep680422->drug_food_interactions,5) > 0)
   SET license =
   "&copy; Copyright 1996 - 2020 Cerner Multum, Inc. Revision Date: Multum (United States): January 2020 v200122"
   FOR (idx = 1 TO size(rep680422->drug_food_interactions[1].citations,5))
     IF ((rep680422->drug_food_interactions[1].citations[idx].authors != ""))
      SET citation = concat(citation,trim(rep680422->drug_food_interactions[1].citations[idx].authors
        ))
     ENDIF
     IF ((rep680422->drug_food_interactions[1].citations[idx].title != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_food_interactions[1].citations[idx].
        title))
     ENDIF
     IF ((rep680422->drug_food_interactions[1].citations[idx].journal_abbreviation != ""))
      SET citation = concat(citation,", <i>",concat(trim(rep680422->drug_food_interactions[1].
         citations[idx].journal_abbreviation),"</i>"))
     ENDIF
     IF ((rep680422->drug_food_interactions[1].citations[idx].year_complete != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_food_interactions[1].citations[idx].
        year_complete))
     ENDIF
     IF ((rep680422->drug_food_interactions[1].citations[idx].volume_issue != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_food_interactions[1].citations[idx].
        volume_issue))
     ENDIF
     IF ((rep680422->drug_food_interactions[1].citations[idx].pages != ""))
      SET citation = concat(citation,", ",trim(rep680422->drug_food_interactions[1].citations[idx].
        pages))
     ENDIF
     SET citation = build2(concat(citation,"<br/><br/>"))
   ENDFOR
  ELSEIF (( $4=2)
   AND size(rep680422->allergy_interactions,5) > 0)
   SET license =
   "&copy; Copyright 1996 - 2020 Cerner Multum, Inc. Revision Date: Multum (United States): January 2020 v200122"
   FOR (idx = 1 TO size(rep680422->allergy_interactions[1].citations,5))
     IF ((rep680422->allergy_interactions[1].citations[idx].authors != ""))
      SET citation = concat(citation,trim(rep680422->allergy_interactions[1].citations[idx].authors))
     ENDIF
     IF ((rep680422->allergy_interactions[1].citations[idx].title != ""))
      SET citation = concat(citation,", ",trim(rep680422->allergy_interactions[1].citations[idx].
        title))
     ENDIF
     IF ((rep680422->allergy_interactions[1].citations[idx].journal_abbreviation != ""))
      SET citation = concat(citation,", <i>",concat(trim(rep680422->allergy_interactions[1].
         citations[idx].journal_abbreviation),"</i>"))
     ENDIF
     IF ((rep680422->allergy_interactions[1].citations[idx].year_complete != ""))
      SET citation = concat(citation,", ",trim(rep680422->allergy_interactions[1].citations[idx].
        year_complete))
     ENDIF
     IF ((rep680422->allergy_interactions[1].citations[idx].volume_issue != ""))
      SET citation = concat(citation,", ",trim(rep680422->allergy_interactions[1].citations[idx].
        volume_issue))
     ENDIF
     IF ((rep680422->allergy_interactions[1].citations[idx].pages != ""))
      SET citation = concat(citation,", ",trim(rep680422->allergy_interactions[1].citations[idx].
        pages))
     ENDIF
     SET citation = build2(concat(citation,"<br/><br/>"))
   ENDFOR
  ENDIF
  IF (textlen(citation) > 0)
   SET out_rec->alert_text = build2(concat(html_header,concat(concat(citation,license),html_footer)))
  ENDIF
  IF (validate(_memory_reply_string))
   SET _memory_reply_string = cnvtrectojson(out_rec)
  ELSE
   CALL echojson(out_rec,moutputdevice)
  ENDIF
  FREE RECORD out_rec
 ENDIF
 FREE RECORD result
 FREE RECORD req680422
 FREE RECORD rep680422
 SUBROUTINE callgetcitations(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(680422)
   IF (( $4=0))
    SET stat = alterlist(req680422->drug_drug_interaction_criterias,1)
    SET req680422->drug_drug_interaction_criterias[1].unique_identifier = "0"
    SET req680422->drug_drug_interaction_criterias[1].subject_cki =  $2
    SET req680422->drug_drug_interaction_criterias[1].causing_cki =  $3
   ELSEIF (( $4=1))
    SET stat = alterlist(req680422->drug_food_interaction_criterias,1)
    SET req680422->drug_food_interaction_criterias[1].unique_identifier = "0"
    SET req680422->drug_food_interaction_criterias[1].subject_cki =  $2
   ELSEIF (( $4=2))
    SET stat = alterlist(req680422->allergy_criterias,1)
    SET req680422->allergy_criterias[1].unique_identifier = "0"
    SET req680422->allergy_criterias[1].subject_cki =  $2
    SET req680422->allergy_criterias[1].causing_cki =  $2
    SET req680422->allergy_criterias[1].interaction_type.category_ind = 1
   ENDIF
   CALL echorecord(req680422)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req680422,
    "REC",rep680422,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep680422)
   IF ((rep680422->transaction_status.success_ind=0))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
