CREATE PROGRAM bhs_athn_rem_diagnosis
 FREE RECORD result
 RECORD result(
   1 diagnosis_group = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4170155
 RECORD req4170155(
   1 item[*]
     2 action_ind = i2
     2 diagnosis_id = f8
     2 diagnosis_group = f8
     2 encntr_id = f8
     2 person_id = f8
     2 nomenclature_id = f8
     2 concept_cki = vc
     2 diag_ft_desc = vc
     2 diagnosis_display = vc
     2 conditional_qual_cd = f8
     2 confirmation_status_cd = f8
     2 diag_dt_tm = dq8
     2 classification_cd = f8
     2 clinical_service_cd = f8
     2 diag_type_cd = f8
     2 ranking_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 severity_class_cd = f8
     2 certainty_cd = f8
     2 probability = i4
     2 long_blob_id = f8
     2 comment = gvc
     2 active_ind = i2
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 diag_priority = i4
     2 clinical_diag_priority = i4
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 related_dx_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_dx_type_cd = f8
       3 child_clin_srv_cd = f8
       3 child_nomen_id = f8
       3 child_ft_desc = vc
     2 related_proc_list[*]
       3 active_ind = i2
       3 procedure_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 updt_trans_nomen_ind = i2
     2 trans_nomen_id = f8
   1 user_id = f8
 ) WITH protect
 FREE RECORD rep4170155
 RECORD rep4170155(
   1 error_string = vc
   1 item[*]
     2 diagnosis_id = f8
     2 diagnosis_group = f8
     2 review_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callremovediagnosis(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID DIAGNOSIS ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM diagnosis d
  PLAN (d
   WHERE (d.diagnosis_id= $2)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm < sysdate
    AND d.end_effective_dt_tm > sysdate)
  ORDER BY d.diagnosis_id
  HEAD d.diagnosis_id
   result->diagnosis_group = d.diagnosis_group
  WITH nocounter, time = 30
 ;end select
 SET stat = callremovediagnosis(null)
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
 FREE RECORD req4170155
 FREE RECORD rep4170155
 SUBROUTINE callremovediagnosis(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(4170140)
   DECLARE requestid = i4 WITH constant(4170155)
   DECLARE errmsg = vc WITH protect, noconstant("")
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
   SET stat = alterlist(req4170155->item,1)
   SET req4170155->item[1].action_ind = 3
   SET req4170155->item[1].diagnosis_id =  $2
   SET req4170155->item[1].diagnosis_group = result->diagnosis_group
   CALL echorecord(req4170155)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4170155,
    "REC",rep4170155,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4170155)
   IF ((rep4170155->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
