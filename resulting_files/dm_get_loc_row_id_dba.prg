CREATE PROGRAM dm_get_loc_row_id:dba
 RECORD reply(
   1 source_loc_rowid = c18
   1 target_loc_rowid = c18
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  l1.rowid
  FROM location@loc_mrg_link l1
  WHERE (l1.location_cd=request->source_loc_cd)
  DETAIL
   reply->source_loc_rowid = l1.rowid
  WITH nocounter
 ;end select
 IF ((request->target_loc_cd > 0))
  SELECT INTO "nl:"
   l2.rowid
   FROM location l2
   WHERE (l2.location_cd=request->target_loc_cd)
   DETAIL
    reply->target_loc_rowid = l2.rowid
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
