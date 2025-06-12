CREATE PROGRAM bed_add_name_value:dba
 FREE SET reply
 RECORD reply(
   1 br_name_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ierrcode = 0
 SET name_value_id = 0.0
 SELECT INTO "nl:"
  y = seq(bedrock_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   name_value_id = cnvtreal(y)
  WITH format, counter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_name_value br
  SET br.br_name_value_id = name_value_id, br.br_nv_key1 = request->br_nv_key1, br.br_name = request
   ->br_name,
   br.br_value = request->br_value, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
   br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
