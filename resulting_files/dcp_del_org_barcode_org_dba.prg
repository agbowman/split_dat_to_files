CREATE PROGRAM dcp_del_org_barcode_org:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1
 SET failed = "F"
 DECLARE numbertochange = i4
 SET numbertochange = size(request->orgbarcodeorg,5)
 FOR (x = 1 TO value(numbertochange))
  DELETE  FROM org_barcode_org obf
   WHERE (obf.org_barcode_seq_id=request->orgbarcodeorg[x].org_barcode_seq_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Delete"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "ScriptMessage"
  SET reply->status_data.targetobjectvalue = "Exit -- Delete Failed"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
