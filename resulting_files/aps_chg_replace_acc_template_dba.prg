CREATE PROGRAM aps_chg_replace_acc_template:dba
 RECORD reply(
   1 updt_cnt = i4
   1 template_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aptemp(
   1 details[*]
     2 detail_id = f8
     2 parent_entity_name = c30
 )
 DECLARE scase_priority = c16 WITH protect, constant("CASE_PRIORITY")
 DECLARE sreq_physician = c16 WITH protect, constant("REQ_PHYSICIAN")
 DECLARE sresp_pathologist = c16 WITH protect, constant("RESP_PATHOLOGIST")
 DECLARE sresp_resident = c16 WITH protect, constant("RESP_RESIDENT")
 DECLARE scopyto_physician = c16 WITH protect, constant("COPYTO_PHYSICIAN")
 DECLARE sspecimen_code = c16 WITH protect, constant("SPECIMEN_CODE")
 DECLARE sspec_adequacy = c16 WITH protect, constant("SPEC_ADEQUACY")
 DECLARE sspec_fixative = c16 WITH protect, constant("SPEC_FIXATIVE")
 DECLARE sspec_priority = c16 WITH protect, constant("SPEC_PRIORITY")
 DECLARE scode_value = c30 WITH protect, constant("CODE_VALUE")
 DECLARE sprsnl = c30 WITH protect, constant("PRSNL")
 DECLARE ldetailcnt = i4 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET debug = 0
 SET number_to_del = 0
 IF (debug=1)
  CALL echo("")
  CALL echo(build("Template :",request->name,"->",request->template_cd))
  CALL echo(build("Num to Add :",request->add_detail_cnt))
 ENDIF
 SELECT INTO "nl:"
  cv.description
  FROM code_value cv
  WHERE (cv.code_value=request->template_cd)
  DETAIL
   cur_updt_cnt = cv.updt_cnt
  WITH nocounter, forupdate(cv)
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  IF (debug=1)
   CALL echo("Error: Lock Code_Value failed!")
  ENDIF
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 IF ((request->updt_cnt != cur_updt_cnt))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  IF (debug=1)
   CALL echo("Error: Template updt_cnt is off!")
  ENDIF
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = request->name, cv.display = request->name, cv.display_key = cnvtupper(
    cnvtalphanum(request->name)),
   cv.active_ind = request->active_ind, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
   updt_applctx,
   cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.active_type_cd =
   IF ((request->active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , cv.data_status_cd = reqdata->data_status_cd,
   cv.data_status_dt_tm = cnvtdatetime(curdate,curtime), cv.data_status_prsnl_id = reqinfo->updt_id
  WHERE (cv.code_value=request->template_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  IF (debug=1)
   CALL echo("Error: Template update failed!")
  ENDIF
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 IF ((request->active_ind=0))
  SELECT INTO "nl:"
   apatr.template_cd
   FROM ap_prefix_accn_template_r apatr
   WHERE (apatr.template_cd=request->template_cd)
   HEAD REPORT
    number_to_del = 0
   DETAIL
    number_to_del = (number_to_del+ 1)
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL echo(build("Number_To_Del :",number_to_del))
  ENDIF
  DELETE  FROM ap_prefix_accn_template_r apatr
   WHERE (apatr.template_cd=request->template_cd)
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_ACCN_TEMPLATE_R"
   IF (debug=1)
    CALL echo("Error: Delete didn't work!")
    CALL echo(build("Curqual :",curqual))
   ENDIF
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM ap_accn_template_detail aatd
  WHERE (aatd.template_cd=request->template_cd)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_ACCN_TEMPLATE_DETAIL"
  IF (debug=1)
   CALL echo("Error: Delete didn't work!")
   CALL echo(build("Curqual :",curqual))
  ENDIF
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET stat = alterlist(aptemp->details,request->add_detail_cnt)
 FOR (ldetailcnt = 1 TO request->add_detail_cnt)
   IF ((request->add_detail_qual[ldetailcnt].detail_name IN (scase_priority, sspecimen_code,
   sspec_adequacy, sspec_fixative, sspec_priority))
    AND (request->add_detail_qual[ldetailcnt].detail_id > 0))
    SET aptemp->details[ldetailcnt].parent_entity_name = scode_value
   ELSEIF ((request->add_detail_qual[ldetailcnt].detail_name IN (sreq_physician, sresp_pathologist,
   sresp_resident, scopyto_physician))
    AND (request->add_detail_qual[ldetailcnt].detail_id > 0))
    SET aptemp->details[ldetailcnt].parent_entity_name = sprsnl
   ELSE
    SET aptemp->details[ldetailcnt].parent_entity_name = " "
   ENDIF
 ENDFOR
 INSERT  FROM ap_accn_template_detail aatd,
   (dummyt d  WITH seq = value(request->add_detail_cnt))
  SET aatd.template_detail_id = cnvtreal(seq(reference_seq,nextval)), aatd.template_cd = request->
   template_cd, aatd.detail_name = request->add_detail_qual[d.seq].detail_name,
   aatd.detail_flag = request->add_detail_qual[d.seq].detail_flag, aatd.detail_id = request->
   add_detail_qual[d.seq].detail_id, aatd.parent_entity_name = aptemp->details[d.seq].
   parent_entity_name,
   aatd.carry_forward_ind = request->add_detail_qual[d.seq].carry_forward_ind, aatd
   .carry_forward_spec_ind = request->add_detail_qual[d.seq].carry_forward_spec_ind, aatd.updt_cnt =
   0,
   aatd.updt_dt_tm = cnvtdatetime(curdate,curtime3), aatd.updt_id = reqinfo->updt_id, aatd.updt_task
    = reqinfo->updt_task,
   aatd.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (aatd)
  WITH nocounter
 ;end insert
 IF ((curqual != request->add_detail_cnt))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_ACCN_TEMPLATE_DETAIL"
  IF (debug=1)
   CALL echo("Error: New template_detail insert failed!")
   CALL echo(build("Cur_Qual :",curqual))
  ENDIF
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->template_cd = request->template_cd
 SET reply->updt_cnt = request->updt_cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#exit_script
 IF (debug=1)
  CALL echo("Script Completed!")
  CALL echo(build("Status :",reply->status_data.status))
 ENDIF
 FREE SET aptemp
END GO
