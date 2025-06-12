CREATE PROGRAM edw_exec_admin_scripts:dba
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
 DECLARE rdmprint(text=vc(value)) = null WITH public
 DECLARE error_ind = i2 WITH protect, noconstant(0)
 DECLARE log_filename = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting edw_exec_admin_scripts.prg"
 SET log_filename = concat("CCLUSERDIR:edw_exec_admin_scripts_log_",format(sysdate,"MMDDYY;;D"),"_",
  format(sysdate,"HHMM;;M"),".log")
 CALL echo(concat("Log file is located at ",log_filename))
 CALL rdmprint("Starting edw_exec_admin_scripts")
 CALL rdmprint("------------------------------------------------")
 CALL rdmprint("*****EDW_DATE_TIME_IMPORT*****")
 CALL rdmprint("Calling EDW_DATE_TIME_IMPORT")
 EXECUTE edw_date_time_import  WITH replace("REPLY","README_DATA")
 IF ((readme_data->status="F"))
  SET error_ind = 1
  CALL rdmprint(readme_data->message)
  GO TO exit_script
 ENDIF
 CALL rdmprint("EDW_DATE_TIME_IMPORT done")
 CALL rdmprint("------------------------------------------------")
 CALL rdmprint("*****EDW_TIME_ZONE_IMPORT*****")
 CALL rdmprint("Calling EDW_TIME_ZONE_IMPORT")
 EXECUTE edw_time_zone_import  WITH replace("REPLY","README_DATA")
 IF ((readme_data->status="F"))
  SET error_ind = 1
  CALL rdmprint(readme_data->message)
 ENDIF
 CALL rdmprint("EDW_TIME_ZONE_IMPORT done")
 CALL rdmprint("------------------------------------------------")
 IF (error_ind != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failure.  EDW_EXEC_ADMIN_SCRIPTS completed with errors",
   readme_data->message)
  GO TO exit_script
 ENDIF
 SUBROUTINE rdmprint(text)
   IF (validate(log_filename))
    SELECT INTO value(log_filename)
     FROM dummyt
     DETAIL
      CALL print(text)
     WITH noheading, nocounter, format = lfstream,
      maxcol = 1999, maxrow = 1, append
    ;end select
   ELSE
    CALL echo(text)
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL rdmprint(readme_data->message)
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET script_version = "000 01/27/11 RP019504"
END GO
