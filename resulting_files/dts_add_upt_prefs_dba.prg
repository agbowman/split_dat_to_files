CREATE PROGRAM dts_add_upt_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 FOR (cnt = 1 TO request->prefs_qual)
   CALL echo(concat("Attempting to update ",request->prefs[cnt].info_name))
   UPDATE  FROM dm_info di
    SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = request->prefs[cnt].info_char,
     di.info_number = request->prefs[cnt].info_number,
     di.info_long_id = request->prefs[cnt].info_long_id, di.updt_cnt = (di.updt_cnt+ 1), di
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
     updt_task
    WHERE (di.info_domain=request->info_domain)
     AND (di.info_name=request->prefs[cnt].info_name)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = request->info_domain, di
      .info_name = request->prefs[cnt].info_name,
      di.info_char = request->prefs[cnt].info_char, di.info_number = request->prefs[cnt].info_number,
      di.info_long_id = request->prefs[cnt].info_long_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx,
      di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "ADD_UPT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_INFO"
 ENDIF
 CALL echo(build("status = ",reply->status_data.status))
 SET reqinfo->commit_ind = 1
END GO
