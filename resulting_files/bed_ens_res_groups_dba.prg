CREATE PROGRAM bed_ens_res_groups:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET req_cnt = size(request->ord_roles,5)
 FOR (x = 1 TO req_cnt)
   IF ((request->ord_roles[x].action_flag=1))
    INSERT  FROM br_name_value b
     SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "SCHRESGROUPROLE", b.br_name
       = cnvtstring(request->ord_roles[x].ord_role_id),
      b.br_value = cnvtstring(request->ord_roles[x].group_id), b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert order role: ",trim(cnvtstring(request->
        ord_roles[x].ord_role_id))," on br_name_value.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->ord_roles[x].action_flag=2))
    UPDATE  FROM br_name_value b
     SET b.br_value = cnvtstring(request->ord_roles[x].group_id), b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
      .updt_cnt+ 1)
     WHERE b.br_nv_key1="SCHRESGROUPROLE"
      AND b.br_name=cnvtstring(request->ord_roles[x].ord_role_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update order role: ",trim(cnvtstring(request->
        ord_roles[x].ord_role_id))," on br_name_value.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
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
