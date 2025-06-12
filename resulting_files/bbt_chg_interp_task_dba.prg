CREATE PROGRAM bbt_chg_interp_task:dba
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
 SELECT INTO "nl:"
  ir.*
  FROM interp_task_assay ir
  WHERE (ir.interp_id=request->interp_id)
   AND (ir.updt_cnt=request->updt_cnt)
  WITH nocounter, forupdate(ir)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM interp_task_assay ir
  SET ir.interp_option_cd = request->interp_opt_cd, ir.interp_type_cd =
   IF ((request->interp_type_cd=- (1))) 0
   ELSE request->interp_type_cd
   ENDIF
   , ir.generate_interp_flag = request->generate_interp_flag,
   ir.active_ind = request->active_ind, ir.updt_dt_tm = cnvtdatetime(curdate,curtime3), ir.updt_id =
   reqinfo->updt_id,
   ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->updt_applctx, ir.updt_cnt = (ir
   .updt_cnt+ 1)
  WHERE (ir.interp_id=request->interp_id)
   AND (ir.updt_cnt=request->updt_cnt)
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
