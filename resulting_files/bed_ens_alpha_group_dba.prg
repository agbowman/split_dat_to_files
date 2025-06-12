CREATE PROGRAM bed_ens_alpha_group:dba
 FREE SET reply
 RECORD reply(
   1 glist[*]
     2 group_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET tot_count = 0
 SET nomen_count = 0
 SET group_cnt = size(request->glist,5)
 SET stat = alterlist(reply->glist,group_cnt)
 FOR (x = 1 TO group_cnt)
   IF ((request->glist[x].action_flag=1))
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->glist[x].group_id = new_id
    INSERT  FROM br_alpha_group ap
     SET ap.group_id = new_id, ap.description = request->glist[x].description, ap
      .source_vocabulary_cd = request->glist[x].source_vocabulary_code_value,
      ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_id = reqinfo->
      updt_id,
      ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0, ap.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(request->glist[x].description),
      " into the br_alpha_group table.")
     GO TO exit_script
    ELSE
     SET nomen_cnt = size(request->glist[x].nlist,5)
     FOR (i = 1 TO nomen_cnt)
      INSERT  FROM br_alpha_group_components apc
       SET apc.group_id = new_id, apc.nomenclature_id = request->glist[x].nlist[i].nomenclature_id,
        apc.sequence = request->glist[x].nlist[i].sequence,
        apc.default_ind = request->glist[x].nlist[i].default_ind, apc.reference_ind = request->glist[
        x].nlist[i].reference_ind, apc.result_process_cd = request->glist[x].nlist[i].
        result_process_code_value,
        apc.use_units_ind = request->glist[x].nlist[i].use_units_ind, apc.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), apc.updt_id = reqinfo->updt_id,
        apc.updt_task = reqinfo->updt_task, apc.updt_cnt = 0, apc.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->glist[x].nlist[i].nomenclature_id),
        " into the br_alpha_group_components table.")
       GO TO exit_script
      ENDIF
     ENDFOR
    ENDIF
   ELSEIF ((request->glist[x].action_flag=2))
    SET reply->glist[x].group_id = request->glist[x].group_id
    UPDATE  FROM br_alpha_group ap
     SET ap.description = request->glist[x].description, ap.source_vocabulary_cd = request->glist[x].
      source_vocabulary_code_value, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_cnt = (ap.updt_cnt+ 1
      ),
      ap.updt_applctx = reqinfo->updt_applctx
     WHERE (ap.group_id=request->glist[x].group_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",trim(request->glist[x].description),
      " on the br_alpha_group table.")
     GO TO exit_script
    ENDIF
    SET nomen_cnt = size(request->glist[x].nlist,5)
    IF (nomen_cnt > 0)
     DELETE  FROM br_alpha_group_components apc
      WHERE (apc.group_id=request->glist[x].group_id)
      WITH nocounter
     ;end delete
     FOR (i = 1 TO nomen_cnt)
      INSERT  FROM br_alpha_group_components apc
       SET apc.group_id = request->glist[x].group_id, apc.nomenclature_id = request->glist[x].nlist[i
        ].nomenclature_id, apc.sequence = request->glist[x].nlist[i].sequence,
        apc.default_ind = request->glist[x].nlist[i].default_ind, apc.reference_ind = request->glist[
        x].nlist[i].reference_ind, apc.result_process_cd = request->glist[x].nlist[i].
        result_process_code_value,
        apc.use_units_ind = request->glist[x].nlist[i].use_units_ind, apc.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), apc.updt_id = reqinfo->updt_id,
        apc.updt_task = reqinfo->updt_task, apc.updt_cnt = 0, apc.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->glist[x].nlist[i].nomenclature_id),
        " into the br_alpha_group_components table.")
       GO TO exit_script
      ENDIF
     ENDFOR
    ENDIF
   ELSEIF ((request->glist[x].action_flag=3))
    SET reply->glist[x].group_id = request->glist[x].group_id
    UPDATE  FROM br_alpha_group ap
     SET ap.active_ind = 0, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_id = reqinfo->
      updt_id,
      ap.updt_task = reqinfo->updt_task, ap.updt_cnt = (ap.updt_cnt+ 1), ap.updt_applctx = reqinfo->
      updt_applctx
     WHERE (ap.group_id=request->glist[x].group_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete ",trim(request->glist[x].description),
      " from the br_alpha_group table.")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ALPHA_GROUP","  >> ERROR MSG: ",error_msg
   )
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
