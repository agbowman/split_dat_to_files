CREATE PROGRAM bed_cpy_fn_col_view:dba
 FREE SET reply
 RECORD reply(
   1 column_view_id = f8
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
 SELECT INTO "NL:"
  j = seq(carenet_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->column_view_id = cnvtreal(j)
  WITH format, counter
 ;end select
 INSERT  FROM predefined_prefs
  (predefined_prefs_id, predefined_type_meaning, name,
  active_ind, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)(SELECT
   reply->column_view_id, pp.predefined_type_meaning, request->to_column_view_name,
   1, reqinfo->updt_applctx, 0,
   cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task
   FROM predefined_prefs pp
   WHERE pp.active_ind=1
    AND (pp.predefined_prefs_id=request->from_column_view_id))
  WITH nocounter
 ;end insert
 INSERT  FROM name_value_prefs
  (name_value_prefs_id, parent_entity_name, parent_entity_id,
  pvc_name, pvc_value, active_ind,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task, merge_name,
  merge_id, sequence)(SELECT
   seq(carenet_seq,nextval), nvp.parent_entity_name, reply->column_view_id,
   nvp.pvc_name, nvp.pvc_value, 1,
   reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
   nvp.merge_id, nvp.sequence
   FROM name_value_prefs nvp
   WHERE nvp.active_ind=1
    AND trim(nvp.parent_entity_name)="PREDEFINED_PREFS"
    AND (nvp.parent_entity_id=request->from_column_view_id))
  WITH nocounter
 ;end insert
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_CPY_TRK_GROUP","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
