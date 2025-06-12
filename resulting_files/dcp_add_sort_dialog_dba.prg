CREATE PROGRAM dcp_add_sort_dialog:dba
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
 INSERT  FROM dcp_custom_cols_sort dcp,
   (dummyt d1  WITH seq = value(col_to_add))
  SET dcp.column_sort_id = cnvtreal(seq(carenet_seq,nextval)), dcp.spread_type_cd = request->qual[d1
   .seq].spread_type_cd, dcp.sort_level_flag = request->qual[d1.seq].sort_level_flag,
   dcp.sort_type_flag = request->qual[d1.seq].sort_type_flag, dcp.column_description = request->qual[
   d1.seq].column_description, dcp.position_cd = request->qual[d1.seq].position_cd,
   dcp.prsnl_id = request->qual[d1.seq].prsnl_id, dcp.column_cd = request->qual[d1.seq].column_cd,
   dcp.sort_direction_ind = request->qual[d1.seq].sort_direction_ind
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP SORT DIALOG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
