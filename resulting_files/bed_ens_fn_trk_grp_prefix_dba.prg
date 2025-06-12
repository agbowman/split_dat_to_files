CREATE PROGRAM bed_ens_fn_trk_grp_prefix:dba
 FREE SET reply
 RECORD reply(
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
 IF ((request->action_flag=1))
  INSERT  FROM br_name_value bnv
   SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "FNTRKGRP_PREFIX", bnv
    .br_name = cnvtstring(request->trk_group_code_value),
    bnv.br_value = request->prefix, bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->
    updt_task,
    bnv.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET error_flag = "F"
   SET error_msg = concat("Error adding tracking group prefix to br_name_value for ",cnvtstring(
     request->trk_group_code_value),".")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  UPDATE  FROM br_name_value bnv
   SET bnv.br_value = request->prefix, bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->
    updt_task,
    bnv.updt_applctx = reqinfo->updt_applctx
   WHERE bnv.br_nv_key1="FNTRKGRP_PREFIX"
    AND bnv.br_name=cnvtstring(request->trk_group_code_value)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET error_flag = "F"
   SET error_msg = concat("Error updating tracking group prefix to br_name_value for ",cnvtstring(
     request->trk_group_code_value),".")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  DELETE  FROM br_name_value bnv
   WHERE bnv.br_nv_key1="FNTRKGRP_PREFIX"
    AND bnv.br_name=cnvtstring(request->trk_group_code_value)
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_TRK_GRP_PREFIX","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
