CREATE PROGRAM cv_del_fld_xref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 DELETE  FROM cv_xref ref
  WHERE (ref.xref_id=request->xref_rec.xref_id)
  WITH nocounter
 ;end delete
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
