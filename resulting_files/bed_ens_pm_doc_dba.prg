CREATE PROGRAM bed_ens_pm_doc:dba
 FREE SET reply
 RECORD reply(
   01 document_id = f8
   01 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 IF (active_code=0)
  SET error_msg = "Unable to find active code on code set 48"
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  SET new_nbr = 0.0
  SELECT INTO "nl:"
   y = seq(pm_document_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_nbr = cnvtreal(y)
   WITH format, counter
  ;end select
  IF (new_nbr=0)
   SET error_flag = "Y"
   SET error_msg = "Unable to get sequence for pm doc"
   GO TO exit_script
  ENDIF
  INSERT  FROM pm_doc_document pdd
   SET pdd.document_id = new_nbr, pdd.document_name = request->document_name, pdd.document_desc =
    request->document_name,
    pdd.program_name = request->program_name, pdd.active_ind = 1, pdd.active_status_cd = active_code,
    pdd.active_status_prsnl_id = reqinfo->updt_id, pdd.active_status_dt_tm = cnvtdatetime(curdate,
     curtime), pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
    pdd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pdd.updt_id = reqinfo->updt_id,
    pdd.updt_task = reqinfo->updt_task,
    pdd.updt_applctx = reqinfo->updt_applctx, pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd
    .updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "Unable to write pm_doc_document row"
   GO TO exit_script
  ENDIF
  SET reply->document_id = new_nbr
 ELSEIF ((request->action_flag=2))
  UPDATE  FROM pm_doc_document pdd
   SET pdd.document_name = request->document_name, pdd.document_desc = request->document_name, pdd
    .program_name = request->program_name,
    pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx = reqinfo->
    updt_applctx,
    pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd.updt_cnt = (pdd.updt_cnt+ 1)
   WHERE (pdd.document_id=request->document_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "Unable to update pm_doc_document row"
   GO TO exit_script
  ENDIF
  SET reply->document_id = request->document_id
 ELSEIF ((request->action_flag=3))
  UPDATE  FROM pm_doc_document pdd
   SET pdd.active_ind = 0, pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task,
    pdd.updt_applctx = reqinfo->updt_applctx, pdd.updt_dt_tm = cnvtdatetime(curdate,curtime), pdd
    .updt_cnt = (pdd.updt_cnt+ 1)
   WHERE (pdd.document_id=request->document_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "Unable to delete pm_doc_document row"
   GO TO exit_script
  ENDIF
  SET reply->document_id = request->document_id
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
