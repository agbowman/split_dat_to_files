CREATE PROGRAM dcp_readme_2357:dba
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
 SET modify = predeclare
 DECLARE g_cnt_qual = i4 WITH public, noconstant(0)
 SET g_cnt_qual = 0
 SELECT INTO "nl:"
  FROM code_value_set cvs
  WHERE cvs.code_set=6020
  WITH nocounter, forupdate(cvs)
 ;end select
 IF (curqual=0)
  GO TO error_row_locked
 ELSE
  SET g_cnt_qual = curqual
 ENDIF
 UPDATE  FROM code_value_set cvs
  SET cvs.add_access_ind = 0, cvs.chg_access_ind = 0, cvs.del_access_ind = 0,
   cvs.inq_access_ind = 1, cvs.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvs.updt_id = 0,
   cvs.updt_task = 2357, cvs.updt_applctx = 2357, cvs.updt_cnt = (cvs.updt_cnt+ 1)
  WHERE cvs.code_set=6020
  WITH nocounter
 ;end update
 IF (g_cnt_qual != curqual)
  GO TO error_row_update
 ENDIF
 SET readme_data->message = "Code_value_set table has been changed to not allow updates by crmcode32"
 SET readme_data->status = "S"
 COMMIT
 GO TO end_readme
#error_row_locked
 SET readme_data->message = "The Code_value_set row is locked."
 SET readme_data->status = "F"
 GO TO end_readme
#error_row_update
 SET readme_data->message = "Code_value_set table has not been updated!"
 SET readme_data->status = "F"
 ROLLBACK
#end_readme
 SET modify = nopredeclare
 EXECUTE dm_readme_status
END GO
