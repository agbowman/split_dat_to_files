CREATE PROGRAM bed_ens_psn_selections:dba
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
 SET error_flag = " "
 FOR (x = 1 TO pcnt)
   IF ((request->plist[x].action_flag=1)
    AND (request->plist[x].position_code_value > 0))
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = concat(request->plist[x].
       step_cat_mean,"PSNSELECTED"), bnv.br_name = "CVFROMCS88",
      bnv.br_value = cnvtstring(request->plist[x].position_code_value), bnv.updt_id = reqinfo->
      updt_id, bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF ((request->plist[x].category_id > 0))
     SELECT INTO "NL:"
      FROM br_position_cat_comp bpcc
      WHERE (bpcc.category_id=request->plist[x].category_id)
       AND (bpcc.position_cd=request->plist[x].position_code_value)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM br_position_cat_comp bpcc
       SET bpcc.category_id = request->plist[x].category_id, bpcc.position_cd = request->plist[x].
        position_code_value, bpcc.sequence = 1,
        bpcc.physician_ind = 0, bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpcc.updt_id =
        reqinfo->updt_id,
        bpcc.updt_task = reqinfo->updt_task, bpcc.updt_cnt = 0, bpcc.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual != 1)
       SET error_flag = "F"
       SET error_msg = concat("Error adding position to br_pos_cat_comp for ",cnvtstring(request->
         plist[i].code_value),".")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->plist[x].action_flag=3))
    DELETE  FROM br_name_value bnv
     WHERE bnv.br_nv_key1=concat(request->plist[x].step_cat_mean,"PSNSELECTED")
      AND bnv.br_name="CVFROMCS88"
      AND bnv.br_value=cnvtstring(request->plist[x].position_code_value)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag != "F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
