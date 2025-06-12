CREATE PROGRAM aps_next_foreign_ws_id:dba
 RECORD reply(
   1 id = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE next_id = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM pathology_case pc
  PLAN (pc
   WHERE (request->case_id > 0)
    AND (pc.case_id=request->case_id))
  DETAIL
   next_id = pc.next_foreign_ws_nbr
  WITH nocounter, forupdatewait(pc), time = 120
 ;end select
 SET errcode = error(errmsg,0)
 IF (((errcode > 0) OR (curqual != 1)) )
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET next_id = (next_id+ 1)
 UPDATE  FROM pathology_case pc
  SET pc.next_foreign_ws_nbr = next_id
  WHERE (request->case_id > 0)
   AND (pc.case_id=request->case_id)
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (((errcode > 0) OR (curqual != 1)) )
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET reply->id = next_id
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
