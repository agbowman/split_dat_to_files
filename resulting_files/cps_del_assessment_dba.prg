CREATE PROGRAM cps_del_assessment:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 SET number_total = size(request->qual,5)
 DELETE  FROM dsm_component dc,
   (dummyt d  WITH seq = value(number_total))
  SET dc.seq = 1
  PLAN (d)
   JOIN (dc
   WHERE (dc.dsm_assessment_id=request->qual[d.seq].dsm_assessment_id))
  WITH nocounter
 ;end delete
 DELETE  FROM dsm_assessment da,
   (dummyt d  WITH seq = value(number_total))
  SET da.seq = 1
  PLAN (d)
   JOIN (da
   WHERE (da.dsm_assessment_id=request->qual[d.seq].dsm_assessment_id))
  WITH nocounter
 ;end delete
 IF (curqual=number_total)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
