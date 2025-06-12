CREATE PROGRAM aps_get_spec_protocol_detail:dba
 RECORD reply(
   1 qual[10]
     2 task_assay_cd = f8
     2 task_disp = c40
     2 begin_section = i4
     2 begin_level = i4
     2 no_charge_ind = i2
     2 sequence = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 CALL echo(">>>>>",0)
 CALL echo(">>>>>",0)
 CALL echo(request->protocol_id)
 SELECT INTO "nl:"
  apgr.*
  FROM ap_processing_grp_r apgr
  WHERE (request->protocol_id=apgr.parent_entity_id)
   AND apgr.parent_entity_name="AP_SPECIMEN_PROTOCOL"
  HEAD REPORT
   ncnt = 0, maxncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > maxncnt)
    stat = alter(reply->qual,(ncnt+ 10)), maxncnt = (ncnt+ 10)
   ENDIF
   reply->qual[ncnt].task_assay_cd = apgr.task_assay_cd, reply->qual[ncnt].begin_section = apgr
   .begin_section, reply->qual[ncnt].begin_level = apgr.begin_level,
   reply->qual[ncnt].no_charge_ind = apgr.no_charge_ind, reply->qual[ncnt].sequence = apgr.sequence,
   reply->qual[ncnt].updt_cnt = apgr.updt_cnt
  FOOT REPORT
   stat = alter(reply->qual,ncnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL handle_errors("SELECT","Z","TABLE","AP_PROCESSING_GRP_R")
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
