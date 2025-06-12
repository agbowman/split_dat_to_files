CREATE PROGRAM dcp_del_name_value:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nv_cnt = request->nv_cnt
 SET count1 = 0
 DELETE  FROM name_value_prefs nvp,
   (dummyt d1  WITH seq = value(nv_cnt))
  SET nvp.seq = 1
  PLAN (d1
   WHERE (request->nv[d1.seq].name_value_prefs_id != 0))
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=request->nv[d1.seq].name_value_prefs_id))
  WITH nocounter
 ;end delete
 IF (curqual != nv_cnt)
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_DEL_NAME_VALUE"
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
