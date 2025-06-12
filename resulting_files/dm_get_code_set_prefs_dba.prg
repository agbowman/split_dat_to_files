CREATE PROGRAM dm_get_code_set_prefs:dba
 RECORD reply(
   1 cvs_pref = i2
   1 cdf_pref = i2
   1 cse_pref = i2
   1 cv_pref = i2
   1 cve_pref = i2
   1 cva_pref = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  dm.cvs_op_ind, dm.cdf_op_ind, dm.cse_op_ind,
  dm.cv_op_ind, dm.cve_op_ind, dm.cva_op_ind
  FROM dm_code_set dm
  WHERE (dm.code_set=request->code_set)
  DETAIL
   reply->cvs_pref = dm.cvs_op_ind, reply->cdf_pref = dm.cdf_op_ind, reply->cse_pref = dm.cse_op_ind,
   reply->cv_pref = dm.cv_op_ind, reply->cve_pref = dm.cve_op_ind, reply->cva_pref = dm.cva_op_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
