CREATE PROGRAM cqm_add_lconfig
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET listener_id = 0.0
 FREE SET failed
 SET failed = "F"
 SELECT INTO "nl:"
  lc.application_name, lc.listener_alias, lc.listener_id
  FROM cqm_listener_config lc
  WHERE lc.application_name=trim(request->app_name,3)
   AND lc.listener_alias=trim(request->listener_alias,3)
  DETAIL
   listener_id = lc.listener_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   nextseqnum = seq(cqm_listener_id_seq,nextval)
   FROM dual
   DETAIL
    listener_id = nextseqnum
   WITH nocounter
  ;end select
  INSERT  FROM cqm_listener_config l
   (l.listener_id, l.application_name, l.listener_alias,
   l.listener_trigger_table_ext, l.comm_params, l.create_dt_tm,
   l.updt_dt_tm, l.updt_id, l.updt_task,
   l.updt_applctx, l.updt_cnt)
   VALUES(listener_id, trim(request->app_name), trim(request->listener_alias),
   request->trig_table_ext, request->comm_params, cnvtdatetime(sysdate),
   cnvtdatetime(sysdate), 1, 1255000,
   1255000, 0)
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSEIF (curqual=1)
  UPDATE  FROM cqm_listener_config l
   SET l.listener_trigger_table_ext = trim(request->trig_table_ext,3), l.comm_params = trim(request->
     comm_params,3), l.updt_dt_tm = cnvtdatetime(sysdate),
    l.updt_id = 1, l.updt_task = 1255000, l.updt_applctx = 1255000,
    l.updt_cnt = (l.updt_cnt+ 1)
   WHERE l.listener_id=listener_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  IF (validate(reqinfo->commit_ind,0) != 0)
   SET reqinfo->commit_ind = 0
  ELSE
   ROLLBACK
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  IF (validate(reqinfo->commit_ind,0) != 0)
   SET reqinfo->commit_ind = 1
  ELSE
   COMMIT
  ENDIF
 ENDIF
END GO
