CREATE PROGRAM dm_add_cs_owner:dba
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
 SET cs_desc = fillstring(30," ")
 SELECT INTO "nl:"
  cs.display
  FROM code_value_set cs
  WHERE (code_set=request->code_set)
  DETAIL
   cs_desc = cs.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_set
  FROM dm_code_set c
  WHERE (c.code_set=request->code_set)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_code_set dm
   SET dm.owner_name = trim(request->owner_name), dm.description = cs_desc, dm.updt_id = reqinfo->
    updt_id,
    dm.updt_cnt = (dm.updt_cnt+ 1), dm.updt_applctx = reqinfo->updt_applctx, dm.updt_task = reqinfo->
    updt_task,
    dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (dm.code_set=request->code_set)
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM dm_code_set dm
   SET dm.code_set = request->code_set, dm.owner_name = trim(request->owner_name), dm.description =
    cs_desc,
    dm.updt_id = reqinfo->updt_id, dm.updt_cnt = 0, dm.updt_applctx = reqinfo->updt_applctx,
    dm.updt_task = reqinfo->updt_task, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO
