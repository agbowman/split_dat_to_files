CREATE PROGRAM bbd_chg_remove_results:dba
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
 SET count = 0
 SET falied = "T"
 DELETE  FROM interp_result ir
  WHERE (ir.interp_id=request->interp_id)
  WITH nocounter
 ;end delete
 IF (curqual != 0)
  SET failed = "F"
 ELSE
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
