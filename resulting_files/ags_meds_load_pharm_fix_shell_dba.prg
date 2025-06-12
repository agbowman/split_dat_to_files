CREATE PROGRAM ags_meds_load_pharm_fix_shell:dba
 PROMPT
  "TASK_ID (0.0) = " = 0
  WITH datid
 CALL echo("<===== AGS_MEDS_LOAD_PHARM_FIX_SHELL Begin =====>")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD email
 RECORD email(
   1 qual_knt = i4
   1 qual[*]
     2 address = vc
     2 send_flag = i2
 )
 RECORD log(
   1 qual_knt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 )
 SET define_logging_sub = true
 DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
 DECLARE insert_error = i2 WITH public, noconstant(4)
 DECLARE update_error = i2 WITH public, noconstant(5)
 DECLARE delete_error = i2 WITH public, noconstant(6)
 DECLARE select_error = i2 WITH public, noconstant(7)
 DECLARE lock_error = i2 WITH public, noconstant(8)
 DECLARE input_error = i2 WITH public, noconstant(9)
 DECLARE exe_error = i2 WITH public, noconstant(10)
 DECLARE failed = i2 WITH public, noconstant(false)
 DECLARE table_name = c50 WITH public, noconstant(" ")
 DECLARE serrmsg = vc WITH public, noconstant(" ")
 DECLARE ierrcode = i2 WITH public, noconstant(0)
 DECLARE ilog_status = i2 WITH public, noconstant(0)
 DECLARE sstatus_email = vc WITH public, noconstant("")
 DECLARE sstatus_file_name = vc WITH public, constant(concat("AGS_MEDS_LOAD_PHARM_FIX_SHELL",format(
    cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 DECLARE dagstaskid = f8 WITH public, constant(cnvtreal( $DATID))
 EXECUTE ags_meds_load_pharm_fix value(dagstaskid)
#exit_script
 CALL echo("<===== AGS_MEDS_LOAD_PHARM_FIX_SHELL End =====>")
END GO
