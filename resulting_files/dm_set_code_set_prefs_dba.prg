CREATE PROGRAM dm_set_code_set_prefs:dba
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
 UPDATE  FROM dm_code_set dm
  SET dm.cvs_op_ind = request->cvs_pref, dm.cdf_op_ind = request->cdf_pref, dm.cse_op_ind = request->
   cse_pref,
   dm.cv_op_ind = request->cv_pref, dm.cve_op_ind = request->cve_pref, dm.cva_op_ind = request->
   cva_pref
  WHERE (dm.code_set=request->code_set)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO
