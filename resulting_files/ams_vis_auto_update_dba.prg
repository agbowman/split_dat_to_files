CREATE PROGRAM ams_vis_auto_update:dba
 DECLARE mn_error_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_error_msg = vc WITH protect, noconstant("")
 EXECUTE ams_define_toolkit_common
 EXECUTE ams_secure_ftp_get_file "ams_vis_dates.csv"
 EXECUTE dm_dbimport value("ams_vis_dates.csv"), "ams_vis_update_driver", 1000
#exit_script
 SET script_version = "000 11/16/15 TC017703"
END GO
