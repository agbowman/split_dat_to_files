CREATE PROGRAM bhs_athn_save_future_diag:dba
 FREE RECORD result
 RECORD result(
   1 diagnoses[*]
     2 orig_string = vc
     2 search_nomenclature_id = f8
     2 target_nomenclature_id = f8
     2 annotated_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req510801
 RECORD req510801(
   1 person_id = f8
   1 action_personnel_id = f8
   1 orders[*]
     2 order_id = f8
     2 last_action_sequence = i2
     2 diagnoses[*]
       3 search_nomenclature_id = f8
       3 target_nomenclature_id = f8
       3 annotated_display = vc
     2 proposal_ind = i2
 ) WITH protect
 FREE RECORD rep510801
 RECORD rep510801(
   1 success_ind = i2
   1 debug_error_message = vc
 ) WITH protect
 DECLARE callmaintainpotentialdiagnosis(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE diagnosiscnt = i4 WITH protect, constant(cnvtint( $6))
 DECLARE diagnosislistparam = vc WITH protect, constant(replace(replace(replace(replace(replace( $7,
       "ltpercgt","%",0),"ltampgt","&",0),"ltsquotgt","'",0),"ltscolgt",";",0),"ltpipgt","|",0))
 IF (diagnosiscnt > 0)
  SET stat = alterlist(result->diagnoses,diagnosiscnt)
  FOR (idx = 1 TO diagnosiscnt)
    SET result->diagnoses[idx].orig_string = piece(diagnosislistparam,"|",idx,"N/A")
    SET result->diagnoses[idx].search_nomenclature_id = cnvtint(substring(1,(findstring(";",result->
       diagnoses[idx].orig_string,0) - 1),result->diagnoses[idx].orig_string))
    SET result->diagnoses[idx].target_nomenclature_id = cnvtint(substring((findstring(";",result->
       diagnoses[idx].orig_string,1,0)+ 1),(findstring(";",result->diagnoses[idx].orig_string,1,1) -
      (findstring(";",result->diagnoses[idx].orig_string,1,0)+ 1)),result->diagnoses[idx].orig_string
      ))
    SET result->diagnoses[idx].annotated_display = substring((findstring(";",result->diagnoses[idx].
      orig_string,1,1)+ 1),size(trim(result->diagnoses[idx].orig_string,3)),result->diagnoses[idx].
     orig_string)
  ENDFOR
 ENDIF
 SET stat = callmaintainpotentialdiagnosis(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req510801
 FREE RECORD rep510801
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callmaintainpotentialdiagnosis(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH constant(510801)
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
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req510801->person_id =  $2
   SET req510801->action_personnel_id =  $3
   SET stat = alterlist(req510801->orders,1)
   SET req510801->orders[1].order_id =  $4
   SET req510801->orders[1].last_action_sequence =  $5
   SET stat = alterlist(req510801->orders[1].diagnoses,size(result->diagnoses,5))
   FOR (idx = 1 TO size(result->diagnoses,5))
     SET req510801->orders[1].diagnoses[idx].search_nomenclature_id = result->diagnoses[idx].
     search_nomenclature_id
     SET req510801->orders[1].diagnoses[idx].target_nomenclature_id = result->diagnoses[idx].
     target_nomenclature_id
     SET req510801->orders[1].diagnoses[idx].annotated_display = result->diagnoses[idx].
     annotated_display
   ENDFOR
   CALL echorecord(req510801)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req510801,
    "REC",rep510801,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
