CREATE PROGRAM dcp_get_ref_text_mask:dba
 RECORD reply(
   1 ref_text_mask = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  oc.ref_text_mask
  FROM order_catalog oc
  WHERE (oc.catalog_cd=request->parent_entity_id)
  HEAD REPORT
   reply->ref_text_mask = oc.ref_text_mask,
   CALL echo(build("Ref mask = ",reply->ref_text_mask))
  DETAIL
   count1 = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "order_catalog table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
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
