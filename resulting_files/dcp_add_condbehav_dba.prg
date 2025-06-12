CREATE PROGRAM dcp_add_condbehav:dba
 RECORD reply(
   1 condition_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE condition_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  y = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   condition_id = cnvtreal(y)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "get sequence number"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "reference_seq"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to select next value"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM conditional_behavior cb
  SET cb.condition_id = condition_id, cb.input_form_cd = request->input_form_cd, cb
   .condition_control_cd = request->condition_control_cd,
   cb.effected_control_cd = request->effected_control_cd, cb.condition_flag = request->condition_flag,
   cb.behavior_flag = request->behavior_flag,
   cb.range_value_1 = request->range_value_1, cb.range_value_2 = request->range_value_2, cb
   .active_ind = request->active_ind,
   cb.updt_dt_tm = cnvtdatetime(curdate,curtime), cb.updt_id = reqinfo->updt_id, cb.updt_task =
   reqinfo->updt_task,
   cb.updt_applctx = reqinfo->updt_applctx, cb.updt_cnt = 0
  WITH counter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "conditional behavior table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->condition_id = condition_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
