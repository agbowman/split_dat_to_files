CREATE PROGRAM br_ens_auto_processes:dba
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
 SET pcnt = size(request->plist,5)
 FOR (x = 1 TO pcnt)
   IF ((request->plist[x].process_name > " ")
    AND (request->plist[x].process_ind IN (0, 1)))
    UPDATE  FROM br_name_value bnv
     SET bnv.br_value = cnvtstring(request->plist[x].process_ind), bnv.updt_id = reqinfo->updt_id,
      bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_cnt = (bnv.updt_cnt+ 1), bnv.updt_dt_tm =
      cnvtdatetime(curdate,curtime)
     WHERE (bnv.br_name=request->plist[x].process_name)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM br_name_value bnv
      SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "AUTOPROCESSES", bnv
       .br_name = request->plist[x].process_name,
       bnv.br_value = cnvtstring(request->plist[x].process_ind), bnv.updt_id = reqinfo->updt_id, bnv
       .updt_task = reqinfo->updt_task,
       bnv.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
