CREATE PROGRAM bed_ens_coll_class_instr_reltn:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SET scnt = size(request->service_resources,5)
 FOR (s = 1 TO scnt)
   IF ((request->service_resources[s].action_flag=1))
    INSERT  FROM br_coll_class_instr_reltn b
     SET b.collection_class_cd = request->collection_class_code_value, b.service_resource_cd =
      request->service_resources[s].code_value, b.updt_applctx = reqinfo->updt_applctx,
      b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSEIF ((request->service_resources[s].action_flag=3))
    DELETE  FROM br_coll_class_instr_reltn b
     WHERE (b.collection_class_cd=request->collection_class_code_value)
      AND (b.service_resource_cd=request->service_resources[s].code_value)
     WITH nocounter
    ;end delete
   ELSE
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
