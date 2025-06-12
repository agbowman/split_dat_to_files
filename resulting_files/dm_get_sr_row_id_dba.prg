CREATE PROGRAM dm_get_sr_row_id:dba
 RECORD reply(
   1 source_sr_rowid = c18
   1 target_sr_rowid = c18
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
  FROM service_resource@loc_mrg_link l1
  WHERE (l1.service_resource_cd=request->source_sr_cd)
  DETAIL
   reply->source_sr_rowid = l1.rowid
  WITH nocounter
 ;end select
 IF ((request->target_sr_cd > 0))
  SELECT INTO "nl:"
   l2.rowid
   FROM service_resource l2
   WHERE (l2.service_resource_cd=request->target_sr_cd)
   DETAIL
    reply->target_sr_rowid = l2.rowid
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
