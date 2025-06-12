CREATE PROGRAM dcp_add_custom_columns:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET count1 = 0
 SET col_to_add = size(request->qual,5)
 INSERT  FROM dcp_custom_columns dcp,
   (dummyt d1  WITH seq = value(col_to_add))
  SET dcp.seq = 1, dcp.spread_column_id = cnvtreal(seq(reference_seq,nextval)), dcp.spread_type_cd =
   request->qual[d1.seq].spread_type_cd,
   dcp.custom_column_cd = request->qual[d1.seq].custom_column_cd, dcp.custom_column_meaning = request
   ->qual[d1.seq].custom_column_meaning, dcp.position_cd = request->qual[d1.seq].position_cd,
   dcp.prsnl_id = request->qual[d1.seq].prsnl_id, dcp.caption = request->qual[d1.seq].caption, dcp
   .sequence_ind = request->qual[d1.seq].sequence_ind,
   dcp.updt_dt_tm = cnvtdatetime(curdate,curtime), dcp.updt_id = reqinfo->updt_id, dcp.updt_task =
   reqinfo->updt_task,
   dcp.updt_applctx = reqinfo->updt_applctx, dcp.updt_cnt = 0
  PLAN (d1)
   JOIN (dcp)
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP CUSTOM COLUMNS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
