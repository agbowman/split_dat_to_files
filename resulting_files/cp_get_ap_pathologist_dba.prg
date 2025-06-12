CREATE PROGRAM cp_get_ap_pathologist:dba
 RECORD reply(
   1 pathologist_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  pc.responsible_pathologist_id
  FROM pathology_case pc
  PLAN (pc
   WHERE (pc.accession_nbr=request->accession_nbr))
  DETAIL
   reply->pathologist_id = pc.responsible_pathologist_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed = "S"
 ELSE
  SET failed = "Z"
 ENDIF
#exit_script
 SET reply->status_data.status = failed
END GO
