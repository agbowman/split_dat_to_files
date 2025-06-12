CREATE PROGRAM dcp_reltn_codeset_inact:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE rdm_errcode = i4 WITH public, noconstant(0)
 DECLARE rdm_errmsg = c132 WITH public, noconstant(fillstring(132," "))
 UPDATE  FROM code_value cv
  SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = 0, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=6022
   AND cv.cdf_meaning IN ("PTRELTNLST")
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 UPDATE  FROM code_value cv
  SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = 0, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=27360
   AND cv.cdf_meaning IN ("RELTN")
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  CALL echo("unable to inactivate the code_set:")
  SET readme_data->message = "The fields have not been Inactivated"
  SET readme_data->status = "F"
  ROLLBACK
 ELSE
  CALL echo("is inactivating the code_set:")
  SET readme_data->message = "The fields are Inactive."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
