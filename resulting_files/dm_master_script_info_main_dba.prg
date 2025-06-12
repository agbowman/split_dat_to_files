CREATE PROGRAM dm_master_script_info_main:dba
 DECLARE dm_date = vc WITH protect
 DECLARE dm_unique_dat = vc WITH protect
 DECLARE dm_environ_id = f8 WITH protect
 DECLARE temp_req_ins_inc = vc WITH protect
 DECLARE temp_bus_ins_inc = vc WITH protect
 DECLARE temp_req_upd_inc = vc WITH protect
 DECLARE temp_bus_upd_inc = vc WITH protect
 DECLARE temp_req_del_inc = vc WITH protect
 DECLARE temp_bus_del_inc = vc WITH protect
 DECLARE temp_suffix_name = vc WITH protect
 SET dm_date = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy;;d")
 SET dm_unique_dat = concat(trim(curuser,3),"_mstr_rpt.dat")
 CALL echo("*********************************************")
 CALL echo(concat("Unique .dat file created: ",dm_unique_dat))
 CALL echo("*********************************************")
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dm_environ_id = di.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("**************************************")
  CALL echo("Error: Could not find Environment ID.")
  CALL echo("**************************************")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE table_name=cnvtupper( $1)
  DETAIL
   temp_suffix_name = dtd.suffixed_table_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("************************************************")
  CALL echo(concat("Scripts not found for table: ",trim(cnvtupper( $1),3)))
  CALL echo("************************************************")
  GO TO exit_script
 ENDIF
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_I_",trim(temp_suffix_name,3))
  HEAD REPORT
   col 0, "*********************************", row + 1,
   col 0, "Table Name: ", col + 1,
    $1, row + 1, col 0,
   "Date: ", col + 1, dm_date,
   row + 1, col 0, "*********************************",
   row + 2
  DETAIL
   col 0, "**********************************", row + 1,
   col 0, "Master Insert Script Information: ", row + 1,
   col 0, "**********************************", row + 1,
   col 0, "Script Name: ", col + 1,
   ds.script_name, row + 1, col 0,
   "Request Number: ", col + 1, ds.request_number,
   row + 1, "Request/Reply File Name: ", col + 1,
   ds.request_include_file, row + 1, col 0,
   "Request/Reply: ", row + 2, temp_req_ins_inc = ds.request_include_file,
   temp_bus_ins_inc = ds.business_include_file
  WITH nocounter, format = variable
 ;end select
 IF (curqual=0)
  CALL echo(
   "*******************************************************************************************")
  CALL echo(concat("GM_I_",trim(temp_suffix_name,3)," not found on the dm_script_info_master table.")
   )
  CALL echo(
   "*******************************************************************************************")
  GO TO update_step
 ENDIF
 SET dm_dclcom = concat("append cclsource:",temp_req_ins_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 1 **")
 ENDIF
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_I_",trim(temp_suffix_name,3))
  DETAIL
   row + 2, col 0, "Test Include File Name: ",
   col + 1, ds.test_include_file, row + 2,
   col 0, "Business Include File Name: ", col + 1,
   temp_bus_ins_inc
  WITH nocounter, append
 ;end select
 SET dm_dclcom = concat("append cclsource:",temp_bus_ins_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 1.5 **")
 ENDIF
#update_step
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_U_",trim(temp_suffix_name,3))
  DETAIL
   row + 3, col 0, "**********************************",
   row + 1, col 0, "Master Update Script Information: ",
   row + 1, col 0, "**********************************",
   row + 1, col 0, "Script Name: ",
   col + 1, ds.script_name, row + 1,
   col 0, "Request Number: ", col + 1,
   ds.request_number, row + 1, "Request/Reply File Name: ",
   col + 1, ds.request_include_file, row + 1,
   col 0, "Request/Reply: ", row + 2,
   temp_req_upd_inc = ds.request_include_file, temp_bus_upd_inc = ds.business_include_file
  WITH nocounter, format = variable, append
 ;end select
 IF (curqual=0)
  CALL echo(
   "*******************************************************************************************")
  CALL echo(concat("GM_U_",trim(temp_suffix_name,3)," not found on the dm_script_info_master table.")
   )
  CALL echo(
   "*******************************************************************************************")
  GO TO delete_step
 ENDIF
 SET dm_dclcom = concat("append cclsource:",temp_req_upd_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 2 **")
 ENDIF
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_U_",trim(temp_suffix_name,3))
  DETAIL
   row + 2, col 0, "Test Include File Name: ",
   col + 1, ds.test_include_file, row + 2,
   col 0, "Business Include File Name: ", col + 1,
   temp_bus_upd_inc
  WITH nocounter, append
 ;end select
 SET dm_dclcom = concat("append cclsource:",temp_bus_upd_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 2.5 **")
 ENDIF
#delete_step
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_D_",trim(temp_suffix_name,3))
  DETAIL
   row + 3, col 0, "**********************************",
   row + 1, col 0, "Master Delete Script Information: ",
   row + 1, col 0, "**********************************",
   row + 1, col 0, "Script Name: ",
   col + 1, ds.script_name, row + 1,
   col 0, "Request Number: ", col + 1,
   ds.request_number, row + 1, col 0,
   "Request/Reply File Name: ", col + 1, ds.request_include_file,
   row + 1, col 0, "Request/Reply: ",
   row + 2, temp_req_del_inc = ds.request_include_file, temp_bus_del_inc = ds.business_include_file
  WITH nocounter, format = variable, append
 ;end select
 IF (curqual=0)
  CALL echo(
   "*******************************************************************************************")
  CALL echo(concat("GM_D_",trim(temp_suffix_name,3)," not found on the dm_script_info_master table.")
   )
  CALL echo(
   "*******************************************************************************************")
  GO TO final_step
 ENDIF
 SET dm_dclcom = concat("append cclsource:",temp_req_del_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 3 **")
 ENDIF
 SELECT INTO value(dm_unique_dat)
  FROM dm_si_master_ds ds
  WHERE ds.script_name=concat("GM_D_",trim(temp_suffix_name,3))
  DETAIL
   row + 2, col 0, "Test Include File Name: ",
   col + 1, ds.test_include_file, row + 2,
   col 0, "Business Include File Name: ", col + 1,
   temp_bus_del_inc
  WITH nocounter, append
 ;end select
 SET dm_dclcom = concat("append cclsource:",temp_bus_del_inc,".inc ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** ERROR 3.5 **")
 ENDIF
#final_step
 IF (cnvtupper( $2)="MINE")
  CALL parser(concat('set logical search_logical "',dm_unique_dat,'" go'))
  FREE DEFINE rtl2
  DEFINE rtl2 "search_logical"
  SELECT INTO  $2
   t.line
   FROM rtl2t t
   WITH nocounter, format = variable
  ;end select
 ELSE
  SET dm_dclcom = concat("cop ",dm_unique_dat," ", $2)
  SET dm_len = size(trim(dm_dclcom))
  SET dm_status = 0
  CALL dcl(dm_dclcom,dm_len,dm_status)
  IF (dm_status=0)
   CALL echo("** ERROR 4 **")
  ENDIF
 ENDIF
#exit_script
 SET dm_dclcom = concat("purge ",dm_unique_dat)
 SET dm_len = size(trim(dm_dclcom))
 SET dm_status = 0
 CALL dcl(dm_dclcom,dm_len,dm_status)
 IF (dm_status=0)
  CALL echo("** Purge DAT Files Failed **")
 ELSE
  CALL echo(concat("** Purge of ",dm_unique_dat," complete **"))
 ENDIF
END GO
