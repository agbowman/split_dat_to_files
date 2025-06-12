CREATE PROGRAM dts_del_trans_queue:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 DELETE  FROM dts_trans_queue d
  WHERE (d.trans_name=request->trans_name)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  GO TO exit_script
 ENDIF
#exit_script
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  CALL echo("FAILED TO DELETE!...")
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  CALL echo("SUCCESS!...")
 ENDIF
END GO
