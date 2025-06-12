CREATE PROGRAM dcp_get_dl_name:dba
 SET modify = predeclare
 RECORD reply(
   1 label_name = vc
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
  FROM ce_dynamic_label dl
  WHERE (dl.ce_dynamic_label_id=request->dynamic_label_id)
  DETAIL
   reply->label_name = dl.label_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
