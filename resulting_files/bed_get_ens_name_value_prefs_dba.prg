CREATE PROGRAM bed_get_ens_name_value_prefs:dba
 FREE SET reply
 RECORD reply(
   1 nvplist[*]
     2 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->nvplist,5)
 SET stat = alterlist(reply->nvplist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->nvplist[lvar].action_flag="0"))
    SET reply->nvplist[lvar].name_value_prefs_id = 0.0
    IF (((trim(request->nvplist[lvar].parent_entity_name)="VIEW_PREFS"
     AND trim(request->nvplist[lvar].pvc_name)="DISPLAY_SEQ") OR (((trim(request->nvplist[lvar].
     parent_entity_name)="DETAIL_PREFS"
     AND trim(request->nvplist[lvar].pvc_name)="DX_DEFAULT_CLASSIFICATION") OR (trim(request->
     nvplist[lvar].parent_entity_name)="DETAIL_PREFS"
     AND trim(request->nvplist[lvar].pvc_name)="DX_DEFAULT_TYPE")) )) )
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_name=request->nvplist[lvar].parent_entity_name)
       AND (nvp.parent_entity_id=request->nvplist[lvar].parent_entity_id)
       AND (nvp.pvc_name=request->nvplist[lvar].pvc_name)
       AND nvp.active_ind=1
      DETAIL
       reply->nvplist[lvar].name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_name=request->nvplist[lvar].parent_entity_name)
       AND (nvp.parent_entity_id=request->nvplist[lvar].parent_entity_id)
       AND (nvp.pvc_name=request->nvplist[lvar].pvc_name)
       AND (nvp.pvc_value=request->nvplist[lvar].pvc_value)
       AND nvp.active_ind=1
      DETAIL
       reply->nvplist[lvar].name_value_prefs_id = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF ((request->nvplist[lvar].action_flag="1"))
    SET reply->nvplist[lvar].name_value_prefs_id = 0.0
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      reply->nvplist[lvar].name_value_prefs_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    IF ((reply->nvplist[lvar].name_value_prefs_id > 0))
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = reply->nvplist[lvar].name_value_prefs_id, nvp.parent_entity_name
        = request->nvplist[lvar].parent_entity_name, nvp.parent_entity_id = request->nvplist[lvar].
       parent_entity_id,
       nvp.pvc_name = request->nvplist[lvar].pvc_name, nvp.pvc_value = request->nvplist[lvar].
       pvc_value, nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->nvplist[lvar].action_flag="2"))
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = request->nvplist[lvar].pvc_value, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp
      .updt_id = reqinfo->updt_id,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
      .updt_applctx = reqinfo->updt_applctx
     WHERE (nvp.parent_entity_name=request->nvplist[lvar].parent_entity_name)
      AND (nvp.parent_entity_id=request->nvplist[lvar].parent_entity_id)
      AND (nvp.pvc_name=request->nvplist[lvar].pvc_name)
     WITH nocounter
    ;end update
   ELSEIF ((request->nvplist[lvar].action_flag="3"))
    IF (trim(request->nvplist[lvar].parent_entity_name)="VIEW_PREFS"
     AND trim(request->nvplist[lvar].pvc_name)="DISPLAY_SEQ")
     DELETE  FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_name=request->nvplist[lvar].parent_entity_name)
       AND (nvp.parent_entity_id=request->nvplist[lvar].parent_entity_id)
       AND (nvp.pvc_name=request->nvplist[lvar].pvc_name)
      WITH nocounter
     ;end delete
    ELSE
     DELETE  FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_name=request->nvplist[lvar].parent_entity_name)
       AND (nvp.parent_entity_id=request->nvplist[lvar].parent_entity_id)
       AND (nvp.pvc_name=request->nvplist[lvar].pvc_name)
       AND (nvp.pvc_value=request->nvplist[lvar].pvc_value)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
 ENDFOR
END GO
