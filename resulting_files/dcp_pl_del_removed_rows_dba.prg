CREATE PROGRAM dcp_pl_del_removed_rows:dba
 FREE RECORD reply
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
 SET count = size(request->qual,5)
 DELETE  FROM dcp_pl_prioritization p,
   (dummyt d  WITH seq = value(count))
  SET p.seq = 1
  PLAN (d)
   JOIN (p
   WHERE (p.patient_list_id=request->patient_list_id)
    AND (p.person_id=request->qual[d.seq].person_id)
    AND (p.encntr_id=request->qual[d.seq].encounter_id)
    AND p.remove_ind=1
    AND p.priority_id > 0)
  WITH nocounter
 ;end delete
 IF (curqual != count)
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_PL_DEL_REMOVED_ROWS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO DELETE"
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
