CREATE PROGRAM aps_chg_transfer_reports:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_items = 0
 SET nbr_reports = cnvtint(size(request->qual,5))
 SET updt_cnts_array[1000] = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  rt.report_id
  FROM report_task rt,
   (dummyt d  WITH seq = value(nbr_reports))
  PLAN (d)
   JOIN (rt
   WHERE (request->qual[d.seq].report_id=rt.report_id))
  HEAD REPORT
   nbr_items = 0
  DETAIL
   nbr_items = (nbr_items+ 1), updt_cnts_array[nbr_items] = rt.updt_cnt
   IF ((request->tracking_transfer_flag=1))
    IF ((request->qual[d.seq].service_resource_cd=0.0))
     request->qual[d.seq].service_resource_cd = rt.service_resource_cd
    ENDIF
    IF ((request->qual[d.seq].responsible_pathologist_id=0.0))
     request->qual[d.seq].responsible_pathologist_id = rt.responsible_pathologist_id
    ENDIF
    IF ((request->qual[d.seq].responsible_resident_id=0.0))
     request->qual[d.seq].responsible_resident_id = rt.responsible_resident_id
    ENDIF
   ENDIF
  WITH nocounter, forupdate(rt)
 ;end select
 IF (nbr_items != nbr_reports)
  CALL handle_errors("LOCK","F","TABLE","REPORT_TASK")
 ENDIF
 FOR (nbr_items = 1 TO nbr_reports)
   IF ((request->qual[nbr_items].updt_cnt != updt_cnts_array[nbr_items]))
    CALL handle_errors("UPDATE_CNT","F","TABLE","REPORT_TASK")
   ENDIF
 ENDFOR
 UPDATE  FROM report_task rt,
   (dummyt d  WITH seq = value(nbr_reports))
  SET rt.service_resource_cd = request->qual[d.seq].service_resource_cd, rt
   .responsible_pathologist_id = request->qual[d.seq].responsible_pathologist_id, rt
   .responsible_resident_id = request->qual[d.seq].responsible_resident_id,
   rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id = reqinfo->updt_id, rt.updt_task =
   reqinfo->updt_task,
   rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = (rt.updt_cnt+ 1)
  PLAN (d)
   JOIN (rt
   WHERE (rt.report_id=request->qual[d.seq].report_id))
  WITH nocounter
 ;end update
 IF (curqual != nbr_reports)
  CALL handle_errors("UPDATE","F","TABLE","REPORT_TASK")
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET reqinfo->commit_ind = 0
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
