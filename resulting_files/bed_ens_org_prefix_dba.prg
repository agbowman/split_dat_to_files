CREATE PROGRAM bed_ens_org_prefix:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SELECT INTO "NL:"
  FROM br_organization bo
  WHERE (bo.organization_id=request->organization_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM br_organization bo
   SET bo.br_prefix = trim(request->org_prefix), bo.updt_cnt = (bo.updt_cnt+ 1), bo.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    bo.updt_id = reqinfo->updt_id, bo.updt_task = reqinfo->updt_task, bo.updt_applctx = reqinfo->
    updt_applctx
   WHERE (bo.organization_id=request->organization_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Error updating br_organization row for org id: ",trim(cnvtstring(request->
      organization_id)))
  ENDIF
 ELSE
  INSERT  FROM br_organization bo
   SET bo.organization_id = request->organization_id, bo.br_prefix = trim(request->org_prefix), bo
    .acute_care_ind = 0,
    bo.outreach_ind = 0, bo.updt_dt_tm = cnvtdatetime(curdate,curtime3), bo.updt_id = reqinfo->
    updt_id,
    bo.updt_task = reqinfo->updt_task, bo.updt_cnt = 0, bo.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Error inserting br_organization row for org id: ",trim(cnvtstring(request
      ->organization_id)))
  ENDIF
 ENDIF
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ORG_PREFIX","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
