CREATE PROGRAM cp_ina_batch:dba
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
 SET failed = "F"
 SELECT INTO "nl:"
  c.*
  FROM charting_operations c
  WHERE (c.charting_operations_id=request->charting_operations_id)
  WITH nocounter, forupdate(c)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM charting_operations c
  SET c.active_ind = request->active_ind, c.active_status_cd =
   IF ((request->active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , c.updt_cnt = (c.updt_cnt+ 1),
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
   ->updt_task,
   c.updt_applctx = reqinfo->updt_applctx
  WHERE (c.charting_operations_id=request->charting_operations_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
