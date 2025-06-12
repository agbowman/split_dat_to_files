CREATE PROGRAM dm_omf_groupings:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 UPDATE  FROM omf_groupings og
  SET og.grouping_cd = request->grouping_cd, og.omf_grouping_id = request->omf_grouping_id, og
   .valid_from_dt_tm = cnvtdatetime(request->valid_from_dt_tm),
   og.valid_until_dt_tm = cnvtdatetime(request->valid_until_dt_tm), og.grouping_status_cd = request->
   grouping_status_cd, og.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   og.updt_id = reqinfo->updt_id, og.updt_applctx = reqinfo->updt_applctx, og.updt_task = reqinfo->
   updt_task,
   og.updt_cnt = (og.updt_cnt+ 1)
  WHERE (og.key1=request->key1)
   AND (og.key2=request->key2)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_groupings og
   SET og.grouping_cd = request->grouping_cd, og.omf_grouping_id = request->omf_grouping_id, og
    .valid_from_dt_tm = cnvtdatetime(request->valid_from_dt_tm),
    og.valid_until_dt_tm = cnvtdatetime(request->valid_until_dt_tm), og.grouping_status_cd = request
    ->grouping_status_cd, og.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    og.updt_id = reqinfo->updt_id, og.updt_applctx = reqinfo->updt_applctx, og.updt_task = reqinfo->
    updt_task,
    og.updt_cnt = 0, og.key1 = request->key1, og.key2 = request->key2
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET reqinfo->commit_ind = 3
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO
