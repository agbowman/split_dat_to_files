CREATE PROGRAM bed_ens_coll_container:dba
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
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 2051
  SET request_cv->cd_value_list[1].display = request->display
  SET request_cv->cd_value_list[1].description = request->description
  SET request_cv->cd_value_list[1].definition = request->description
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   INSERT  FROM specimen_container sc
    SET sc.spec_cntnr_cd = reply_cv->qual[1].code_value, sc.aliquot_ind = request->aliquot_ind, sc
     .volume_units = " ",
     sc.volume_units_cd = request->volume_units_cd, sc.updt_cnt = 0, sc.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     sc.updt_id = reqinfo->updt_id, sc.updt_task = reqinfo->updt_task, sc.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET vcnt = size(request->vlist,5)
    FOR (v = 1 TO vcnt)
      SET next_sequence = 0.0
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        next_sequence = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM specimen_container_volume scv
       SET scv.spec_cntnr_cd = reply_cv->qual[1].code_value, scv.volume = request->vlist[v].volume,
        scv.updt_cnt = 0,
        scv.updt_dt_tm = cnvtdatetime(curdate,curtime), scv.updt_id = reqinfo->updt_id, scv.updt_task
         = reqinfo->updt_task,
        scv.updt_applctx = reqinfo->updt_applctx, scv.spec_cntnr_seq = next_sequence
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].code_set = 2051
  SET request_cv->cd_value_list[1].code_value = request->code_value
  SET request_cv->cd_value_list[1].display = request->display
  SET request_cv->cd_value_list[1].description = request->description
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  UPDATE  FROM specimen_container sc
   SET sc.aliquot_ind = request->aliquot_ind, sc.volume_units_cd = request->volume_units_cd, sc
    .updt_cnt = (sc.updt_cnt+ 1),
    sc.updt_dt_tm = cnvtdatetime(curdate,curtime), sc.updt_id = reqinfo->updt_id, sc.updt_task =
    reqinfo->updt_task,
    sc.updt_applctx = reqinfo->updt_applctx
   WHERE (sc.spec_cntnr_cd=request->code_value)
   WITH nocounter
  ;end update
  DELETE  FROM specimen_container_volume scv
   WHERE (scv.spec_cntnr_cd=request->code_value)
   WITH nocounter
  ;end delete
  SET vcnt = size(request->vlist,5)
  FOR (v = 1 TO vcnt)
    SET next_sequence = 0.0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      next_sequence = cnvtreal(y)
     WITH format, nocounter
    ;end select
    INSERT  FROM specimen_container_volume scv
     SET scv.spec_cntnr_cd = request->code_value, scv.volume = request->vlist[v].volume, scv.updt_cnt
       = 0,
      scv.updt_dt_tm = cnvtdatetime(curdate,curtime), scv.updt_id = reqinfo->updt_id, scv.updt_task
       = reqinfo->updt_task,
      scv.updt_applctx = reqinfo->updt_applctx, scv.spec_cntnr_seq = next_sequence
     WITH nocounter
    ;end insert
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
