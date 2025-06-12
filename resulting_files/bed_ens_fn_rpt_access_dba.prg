CREATE PROGRAM bed_ens_fn_rpt_access:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET rcnt = 0
 SET rcnt = size(request->reports,5)
 FOR (r = 1 TO rcnt)
   SET ierrcode = 0
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="PREDEFINED_PREFS"
     AND (nvp.parent_entity_id=request->reports[r].id)
     AND nvp.pvc_name="position"
     AND nvp.active_ind=1
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE pos_list = vc
 SET scnt = 0
 SET scnt = size(request->positions_selected,5)
 SET pos_list = " "
 IF (scnt > 0
  AND (request->positions_selected[1].code_value > 0.0))
  SET pos_list = concat(trim(cnvtstring(scnt)),";")
  FOR (s = 1 TO scnt)
    IF (s=scnt)
     SET pos_list = concat(pos_list,trim(cnvtstring(request->positions_selected[s].code_value)))
    ELSE
     SET pos_list = concat(pos_list,trim(cnvtstring(request->positions_selected[s].code_value)),",")
    ENDIF
  ENDFOR
  FOR (r = 1 TO rcnt)
    SET ierrcode = 0
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
      "PREDEFINED_PREFS", nvp.parent_entity_id = request->reports[r].id,
      nvp.pvc_name = "position", nvp.pvc_value = pos_list, nvp.active_ind = 1,
      nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime
       ),
      nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name =
      null,
      nvp.merge_id = 0.0, nvp.sequence = null
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
  ENDFOR
 ELSE
  FOR (r = 1 TO rcnt)
    SET ierrcode = 0
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
      "PREDEFINED_PREFS", nvp.parent_entity_id = request->reports[r].id,
      nvp.pvc_name = "position", nvp.pvc_value = " ", nvp.active_ind = 1,
      nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime
       ),
      nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name =
      null,
      nvp.merge_id = 0.0, nvp.sequence = null
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
