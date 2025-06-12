CREATE PROGRAM dm_ins_upt_dm_info:dba
 SET msg = fillstring(255," ")
 SET msgnum = 0
 IF (validate(request->info_char,"Z") != "Z")
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(request->info_date), di.info_char = request->info_char, di
    .info_number = request->info_number,
    di.info_long_id = request->info_long_id, di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
    updt_task
   WHERE (di.info_domain=request->info_domain)
    AND (di.info_name=request->info_name)
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_date = cnvtdatetime(request->info_date), di.info_char = request->info_char, di
     .info_number = request->info_number,
     di.info_long_id = request->info_long_id, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
     updt_task,
     di.info_domain = request->info_domain, di.info_name = request->info_name
    WITH nocounter
   ;end insert
  ENDIF
  SET msgnum = error(msg,1)
  IF (msgnum > 0)
   SET reply->error_ind = 1
  ENDIF
  SET reply->error_msg = msg
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(dm_info_request->info_date), di.info_char = dm_info_request->
    info_char, di.info_number = dm_info_request->info_number,
    di.info_long_id = dm_info_request->info_long_id, di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
    updt_task
   WHERE (di.info_domain=dm_info_request->info_domain)
    AND (di.info_name=dm_info_request->info_name)
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_date = cnvtdatetime(dm_info_request->info_date), di.info_char = dm_info_request->
     info_char, di.info_number = dm_info_request->info_number,
     di.info_long_id = dm_info_request->info_long_id, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
     updt_task,
     di.info_domain = dm_info_request->info_domain, di.info_name = dm_info_request->info_name
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
#end_program
END GO
