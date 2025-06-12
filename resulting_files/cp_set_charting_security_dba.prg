CREATE PROGRAM cp_set_charting_security:dba
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
 SELECT INTO "nl:"
  df.info_name
  FROM dm_info df
  WHERE df.info_domain="CHARTING SECURITY"
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info df
   SET df.info_domain = "CHARTING SECURITY", df.info_name = request->charting_security, df.info_date
     = cnvtdatetime(curdate,curtime3),
    df.updt_applctx = reqinfo->updt_applctx, df.updt_id = reqinfo->updt_id, df.updt_task = reqinfo->
    updt_task,
    df.updt_dt_tm = cnvtdatetime(curdate,curtime3), df.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL echo("Unable to insert dm_info table.")
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  UPDATE  FROM dm_info df
   SET df.info_name = request->charting_security, df.info_date = cnvtdatetime(curdate,curtime3), df
    .updt_applctx = reqinfo->updt_applctx,
    df.updt_id = reqinfo->updt_id, df.updt_task = reqinfo->updt_task, df.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    df.updt_cnt = (df.updt_cnt+ 1)
   WHERE df.info_domain="CHARTING SECURITY"
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("Unable to update dm_info table.")
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
