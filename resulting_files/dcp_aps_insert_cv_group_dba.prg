CREATE PROGRAM dcp_aps_insert_cv_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET p_cnt = 0
 SET c_cnt = 0
 SET max_c_qual = 0
 SET x = 0
 SET y = 0
 SET p_cnt = size(request->parent_qual,5)
 FOR (x = 1 TO p_cnt)
   IF (size(request->parent_qual[x].child_qual,5) > max_c_qual)
    SET max_c_qual = size(request->parent_qual[x].child_qual,5)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  cv1.code_value
  FROM code_value cv1,
   code_value cv2,
   (dummyt d1  WITH seq = value(size(request->parent_qual,5))),
   (dummyt d2  WITH seq = value(max_c_qual)),
   dummyt d3,
   code_value_group cvg
  PLAN (d1)
   JOIN (cv1
   WHERE (cv1.code_set=request->parent_qual[d1.seq].parent_code_set)
    AND (cv1.cdf_meaning=request->parent_qual[d1.seq].parent_cdf_mean)
    AND cv1.active_ind=1
    AND cv1.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND cv1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2
   WHERE d2.seq <= size(request->parent_qual[d1.seq].child_qual,5))
   JOIN (cv2
   WHERE (cv2.code_set=request->parent_qual[d1.seq].child_qual[d2.seq].child_code_set)
    AND (cv2.cdf_meaning=request->parent_qual[d1.seq].child_qual[d2.seq].child_cdf_mean)
    AND cv2.active_ind=1
    AND cv2.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND cv2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (cvg
   WHERE cv1.code_value=cvg.parent_code_value
    AND cv2.code_value=cvg.child_code_value)
  HEAD cv1.code_value
   request->parent_qual[d1.seq].parent_code_value = cv1.code_value,
   CALL echo(build("parent cv :",cv1.code_value))
  DETAIL
   request->parent_qual[d1.seq].child_qual[d2.seq].child_code_value = cv2.code_value,
   CALL echo(build("child cv :",cv2.code_value))
  WITH nocounter, outerjoin = d3, dontexist
 ;end select
 INSERT  FROM code_value_group cvg,
   (dummyt d1  WITH seq = value(size(request->parent_qual,5))),
   (dummyt d2  WITH seq = value(max_c_qual))
  SET cvg.parent_code_value = request->parent_qual[d1.seq].parent_code_value, cvg.child_code_value =
   request->parent_qual[d1.seq].child_qual[d2.seq].child_code_value, cvg.code_set = request->
   parent_qual[d1.seq].child_qual[d2.seq].child_code_set,
   cvg.updt_dt_tm = cnvtdatetime(curdate,curtime), cvg.updt_id = reqinfo->updt_id, cvg.updt_task =
   reqinfo->updt_task,
   cvg.updt_applctx = reqinfo->updt_applctx, cvg.updt_cnt = 0
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->parent_qual[d1.seq].child_qual,5))
   JOIN (cvg
   WHERE (request->parent_qual[d1.seq].child_qual[d2.seq].child_code_value > 0))
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "TAG_GROUP_FOUNDATION"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
