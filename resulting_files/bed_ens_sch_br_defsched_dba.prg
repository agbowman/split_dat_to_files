CREATE PROGRAM bed_ens_sch_br_defsched:dba
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
 SET error_flag = "Y"
 SET reply->status_data.status = "F"
 FOR (i = 1 TO size(request->templates,5))
   IF ((request->templates[i].action_flag=3))
    UPDATE  FROM br_sch_template bst
     SET bst.template_status_flag = 2, bst.updt_dt_tm = cnvtdatetime(curdate,curtime3), bst.updt_id
       = reqinfo->updt_id,
      bst.updt_task = reqinfo->updt_task, bst.updt_applctx = reqinfo->updt_applctx, bst.updt_cnt = (
      bst.updt_cnt+ 1)
     WHERE (bst.br_sch_template_id=request->templates[i].br_sch_template_id)
     WITH nocounter
    ;end update
   ELSEIF ((request->templates[i].action_flag=2))
    UPDATE  FROM br_sch_template bst
     SET bst.template_status_flag = 1, bst.updt_dt_tm = cnvtdatetime(curdate,curtime3), bst.updt_id
       = reqinfo->updt_id,
      bst.updt_task = reqinfo->updt_task, bst.updt_applctx = reqinfo->updt_applctx, bst.updt_cnt = (
      bst.updt_cnt+ 1)
     WHERE (bst.br_sch_template_id=request->templates[i].br_sch_template_id)
     WITH nocounter
    ;end update
   ELSE
    SET error_msg = "Invalid action flag"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
