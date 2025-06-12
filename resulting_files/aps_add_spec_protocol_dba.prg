CREATE PROGRAM aps_add_spec_protocol:dba
 RECORD reply(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
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
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 SELECT INTO "nl:"
  asp.*
  FROM ap_specimen_protocol asp
  PLAN (asp
   WHERE (request->spec_cd=asp.specimen_cd)
    AND (request->prefix_id=asp.prefix_id)
    AND (request->path_cd=asp.pathologist_id))
  DETAIL
   reply->parent_entity_id = asp.protocol_id, reply->parent_entity_name = "AP_SPECIMEN_PROTOCOL"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "P"
  CALL handle_errors("SELECT","P","TABLE","AP_SPECIMEN_PROTOCOL EXIST")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seq_nbr = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->parent_entity_id = cnvtreal(seq_nbr)
  WITH format, counter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","REFERENCE_SEQ")
  GO TO exit_script
 ENDIF
 INSERT  FROM ap_specimen_protocol asp
  SET asp.protocol_id = reply->parent_entity_id, asp.specimen_cd = request->spec_cd, asp.prefix_id =
   request->prefix_id,
   asp.pathologist_id = request->path_cd, asp.updt_dt_tm = cnvtdatetime(curdate,curtime3), asp
   .updt_id = reqinfo->updt_id,
   asp.updt_task = reqinfo->updt_task, asp.updt_applctx = reqinfo->updt_applctx, asp.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  CALL handle_errors("INSERT","F","TABLE","AP_SPECIMEN_PROTOCOL")
  GO TO exit_script
 ENDIF
 INSERT  FROM ap_processing_grp_r agi,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET agi.parent_entity_name = "AP_SPECIMEN_PROTOCOL", agi.parent_entity_id = reply->parent_entity_id,
   agi.task_assay_cd = request->qual[d.seq].task_assay_cd,
   agi.begin_section = request->qual[d.seq].begin_section, agi.begin_level = request->qual[d.seq].
   begin_level, agi.end_section = request->qual[d.seq].begin_section,
   agi.end_level = request->qual[d.seq].begin_level, agi.no_charge_ind = request->qual[d.seq].
   no_charge_ind, agi.sequence = request->qual[d.seq].sequence,
   agi.updt_dt_tm = cnvtdatetime(curdate,curtime3), agi.updt_id = reqinfo->updt_id, agi.updt_task =
   reqinfo->updt_task,
   agi.updt_applctx = reqinfo->updt_applctx, agi.updt_cnt = 0
  PLAN (d)
   JOIN (agi
   WHERE (agi.parent_entity_id=reply->parent_entity_id)
    AND agi.parent_entity_name="AP_SPECIMEN_PROTOCOL"
    AND (agi.sequence=request->qual[d.seq].sequence))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_to_insert)
  CALL handle_errors("INSERT","F","TABLE","AP_PROCESSING_GRP_R")
  GO TO exit_script
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
  SET reqinfo->commit_ind = 0
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
