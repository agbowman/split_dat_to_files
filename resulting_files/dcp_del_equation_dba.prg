CREATE PROGRAM dcp_del_equation:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD version_request(
   1 task_assay_cd = f8
 )
 RECORD version_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE eqn_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET dta_cd = 0.0
 IF (validate(request->eqn_id)=0)
  SET eqn_id = request->equation_id
 ELSE
  SET eqn_id = request->eqn_id
 ENDIF
 SELECT INTO "NL:"
  e.task_assay_cd
  FROM equation e
  WHERE e.equation_id=eqn_id
  DETAIL
   dta_cd = e.task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (checkprg("DCP_ADD_DTA_VERSION"))
  SET version_request->task_assay_cd = dta_cd
  EXECUTE dcp_add_dta_version  WITH replace("REQUEST","VERSION_REQUEST"), replace("REPLY",
   "VERSION_REPLY")
  IF ((version_reply->status_data.status="F"))
   GO TO versioning_failed
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  FROM equation e
  WHERE e.equation_id=eqn_id
  WITH forupdate(e), nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 CALL echo(request->equation_id)
 UPDATE  FROM equation e
  SET e.active_ind = 0, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id,
   e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->updt_applctx, e.updt_cnt = (e.updt_cnt
   + 1)
  WHERE e.equation_id=eqn_id
  WITH nocounter
 ;end update
 GO TO exit_script
#versioning_failed
 SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_add_dta_version"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
  "Insert aborted.  DTA Versioning failed:",version_reply->status_data.targetobjectvalue)
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  EXECUTE then
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Delete"
  SET reply->status_data.operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  CALL echo("Got this Far13")
 ENDIF
 FREE RECORD version_request
 FREE RECORD version_reply
END GO
