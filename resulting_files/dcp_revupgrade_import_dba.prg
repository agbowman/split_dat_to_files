CREATE PROGRAM dcp_revupgrade_import:dba
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE importfile = vc
 DECLARE importfilepath = vc
 DECLARE importcount = i4
 DECLARE initrecommend = i2
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
 SET readme_data->status = "F"
 SET readme_data->message = "Failed starting dcp_revupgrade_import."
 SET errcode = 0
 SET importfile = build("hxrev")
 CALL echo(concat("Import file name: ",importfile))
 IF (cnvtupper(cursys)="AXP")
  SET importfilepath = cnvtlower(build(logical("cer_install"),importfile,".dat"))
 ELSEIF (cnvtupper(cursys)="AIX")
  SET importfilepath = cnvtlower(build(logical("cer_install"),"/",importfile,".dat"))
 ELSEIF (cnvtupper(cursys)="WIN")
  SET importfilepath = cnvtlower(build(logical("cer_install"),"\",importfile,".dat"))
 ELSE
  SET errcode = 1
  SET errmsg = "CURSYS must be AIX/AXP/WIN.  Readme failure."
 ENDIF
 IF (errcode=0)
  CALL echo(concat("Looking for file: ",importfilepath))
  IF ( NOT (findfile(importfilepath)))
   SET errcode = 1
   SET errmsg = concat("Import File: ",importfilepath," was not found.  Readme failure.")
  ELSE
   SET readme_data->message = "Starting to import Discern Template changes"
   CALL echo(readme_data->message)
   SET input = importfile
   EXECUTE eks_import
   IF (errcode=0)
    SET errcode = error(errmsg,0)
   ELSE
    SET errmsg = readme_data->message
   ENDIF
  ENDIF
 ENDIF
#exit_program
 IF (errcode)
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
  CALL echo(readme_data->message)
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Discern Expert Templates have been imported."
  CALL echo(readme_data->message)
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
