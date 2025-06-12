CREATE PROGRAM bed_ens_br_name_value:dba
 FREE SET reply
 RECORD reply(
   1 values[*]
     2 name_value_id = f8
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
 SET nv_cnt = size(request->values,5)
 SET stat = alterlist(reply->values,nv_cnt)
 CALL echo(build("nv_cnt",nv_cnt))
 FOR (nv = 1 TO nv_cnt)
   IF ((request->values[nv].action_flag=1))
    SET name_value_id = 0.0
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      name_value_id = cnvtreal(y)
     WITH format, counter
    ;end select
    SET reply->values[nv].name_value_id = name_value_id
    INSERT  FROM br_name_value br
     SET br.br_name_value_id = name_value_id, br.br_nv_key1 = request->values[nv].br_nv_key1, br
      .br_name = request->values[nv].br_name,
      br.br_value = request->values[nv].br_value, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert into br_name_value",request->values[nv].br_nv_key1,
      " with value = ",request->values[nv].br_value)
     GO TO exit_script
    ENDIF
   ELSEIF ((request->values[nv].action_flag=2))
    SET reply->values[nv].name_value_id = request->values[nv].name_value_id
    UPDATE  FROM br_name_value br
     SET br.br_name = request->values[nv].br_name, br.br_value = request->values[nv].br_value, br
      .updt_cnt = (br.updt_cnt+ 1),
      br.updt_dt_tm = cnvtdatetime(curdate,curtime), br.updt_id = reqinfo->updt_id, br.updt_task =
      reqinfo->updt_task,
      br.updt_applctx = reqinfo->updt_applctx
     WHERE (br.br_name_value_id=request->values[nv].name_value_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update br_name_value with id = ",cnvtstring(request->values[nv
       ].name_value_id))
     GO TO exit_script
    ENDIF
   ELSEIF ((request->values[nv].action_flag=3))
    SET reply->values[nv].name_value_id = request->values[nv].name_value_id
    DELETE  FROM br_name_value br
     WHERE (br.br_name_value_id=request->values[nv].name_value_id)
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo(error_msg)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
