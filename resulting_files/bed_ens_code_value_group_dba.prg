CREATE PROGRAM bed_ens_code_value_group:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 parent_code_value = f8
    1 child_code_value = f8
    1 code_set = i4
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 INSERT  FROM code_value_group cvg
  SET cvg.parent_code_value = request->parent_code_value, cvg.child_code_value = request->
   child_code_value, cvg.code_set = request->code_set,
   cvg.collation_seq = 0, cvg.updt_applctx = reqinfo->updt_applctx, cvg.updt_cnt = 0,
   cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id, cvg.updt_task =
   reqinfo->updt_task
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "F"
  SET error_msg = "Error ensuring the child code to the code value group table"
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
