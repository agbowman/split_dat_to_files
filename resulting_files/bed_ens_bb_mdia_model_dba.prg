CREATE PROGRAM bed_ens_bb_mdia_model:dba
 FREE SET reply
 RECORD reply(
   1 model_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 DECLARE model_code_value = f8 WITH noconstant(0.0), protect
 SET reply->status_data.status = "F"
 SET sfailed = "N"
 SET icnt = 0
 SET icnt = size(request->instruments,5)
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].active_ind = 1
  SET request_cv->cd_value_list[1].code_set = 73
  SET request_cv->cd_value_list[1].cdf_meaning = "BLOODBANK"
  SET request_cv->cd_value_list[1].display = substring(1,40,request->display)
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(substring(1,40,request->
     display)))
  SET request_cv->cd_value_list[1].definition = substring(1,100,request->display)
  SET request_cv->cd_value_list[1].description = substring(1,60,request->display)
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET model_code_value = reply_cv->qual[1].code_value
  ELSE
   SET sfailed = "Y"
   GO TO exit_script
  ENDIF
  IF ((request->br_bb_model_id > 0))
   UPDATE  FROM br_bb_model b
    SET b.model_cd = model_code_value, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx
    PLAN (b
     WHERE (b.br_bb_model_id=request->br_bb_model_id))
    WITH nocounter
   ;end update
  ENDIF
 ELSE
  SET model_code_value = request->model_code_value
 ENDIF
 IF (icnt > 0)
  INSERT  FROM code_value_group c,
    (dummyt d  WITH seq = value(icnt))
   SET c.parent_code_value = model_code_value, c.child_code_value = request->instruments[d.seq].
    code_value, c.collation_seq = 0,
    c.code_set = 221, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
    c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (request->instruments[d.seq].action_flag=1))
    JOIN (c)
   WITH nocounter
  ;end insert
  DELETE  FROM code_value_group c,
    (dummyt d  WITH seq = value(icnt))
   SET c.seq = 1
   PLAN (d
    WHERE (request->instruments[d.seq].action_flag=3))
    JOIN (c
    WHERE c.parent_code_value=model_code_value
     AND (c.child_code_value=request->instruments[d.seq].code_value)
     AND c.code_set=221)
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (sfailed="N")
  SET reply->status_data.status = "S"
  SET reply->model_code_value = model_code_value
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
