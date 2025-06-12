CREATE PROGRAM dcp_procedure_type_flag_rdm:dba
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
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE contributor_system_cs = i4 WITH protect, noconstant(89)
 DECLARE powerchart_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE errorcode = i4
 DECLARE errormsg = c132
 SET errormsg = fillstring(132," ")
 SET errorcode = 1
 SET readme_data->status = "F"
 SET readme_data->message = "Failed - Starting DCP_UPD_PROCEDURE_TYPE_FLAG_RDM.PRG script"
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=contributor_system_cs
   AND cv.cdf_meaning="POWERCHART"
   AND cv.active_ind=1
  DETAIL
   powerchart_system_cd = cv.code_value
  WITH nocounter
 ;end select
 UPDATE  FROM procedure p
  SET p.proc_type_flag = evaluate(p.contributor_system_cd,powerchart_system_cd,1.0,0.0,2.0), p
   .updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime)
  WHERE p.contributor_system_cd IN (0.0, powerchart_system_cd)
   AND p.proc_type_flag=0
  WITH nocounter
 ;end update
 SET errorcode = error(errormsg,0)
 IF (errorcode != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed - Error occurred while updating PROCEDURE: ",trim(
    errormsg))
  GO TO exit_program
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success - All required pathway rows were updated successfully."
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
