CREATE PROGRAM dm_common_data_foundation
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
 SET cdf_meaning = cnvtupper(dmrequest->cdf_meaning)
 UPDATE  FROM common_data_foundation c
  SET c.display = dmrequest->display, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
   reqinfo->updt_id,
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx
  WHERE (c.code_set=dmrequest->code_set)
   AND c.cdf_meaning=cdf_meaning
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM common_data_foundation c
   SET c.code_set = dmrequest->code_set, c.cdf_meaning = cdf_meaning, c.display = dmrequest->display,
    c.definition = dmrequest->definition, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
    reqinfo->updt_id,
    c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
