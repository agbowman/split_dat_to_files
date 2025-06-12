CREATE PROGRAM code_out:dba
 PAINT
 SET modify = system
 SET width = 132
#1000_start
 EXECUTE FROM 2000_display_window TO 2099_display_window_exit
 EXECUTE FROM 3000_initialize TO 3099_initialize_exit
 EXECUTE FROM 4000_write_cvs_load TO 4099_write_cvs_load_exit
 EXECUTE FROM 4000_write_cv_load TO 4099_write_cv_load_exit
 EXECUTE FROM 4000_write_cva_load TO 4099_write_cva_load_exit
 GO TO 9999_end
#2000_display_window
 CALL box(7,35,15,85)
 CALL video(r)
 CALL text(8,36,"            ***  Code Conversion  ***            ")
 CALL video(n)
 CALL text(11,49,"Starting...")
 CALL text(23,1," ")
 CALL video(r)
 CALL text(14,36,"            ***  Code Conversion  ***            ")
 CALL video(n)
 EXECUTE FROM 9000_start_log TO 9099_start_log_exit
#2099_display_window_exit
#3000_initialize
 SET nbr_code_sets = 0
 SET nbr_codes = 0
 SET nbr_code_alias = 0
 SET nbr_coded_values = 0
 SET error_message = fillstring(100," ")
 EXECUTE FROM 9000_initialize_log TO 9099_initialize_log_exit
#3099_initialize_exit
#4000_write_cvs_load
 CALL clear(11,49,33)
 CALL text(11,49,"Writing CVS_LOAD...")
 CALL text(23,1," ")
 SELECT INTO TABLE cvs_load
  cs.*
  FROM code_set cs
  WHERE cs.code_set >= 0
  WITH nocounter
 ;end select
 SET nbr_code_sets = curqual
 IF (nbr_code_sets=0)
  SET error_message = "%ERROR writing CVS_LOAD"
  EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
 ENDIF
 EXECUTE FROM 9000_write_code_set_log TO 9099_write_code_set_log_exit
#4099_write_cvs_load_exit
#4000_write_cv_load
 CALL clear(11,49,33)
 CALL text(11,49,"Writing CV_LOAD...")
 CALL text(23,1," ")
 SELECT INTO TABLE cv_load
  c.*
  FROM code c
  WHERE c.code_set >= 0
  WITH nocounter
 ;end select
 SET nbr_codes = curqual
 IF (nbr_codes=0)
  SET error_message = "%ERROR writing CV_LOAD"
  EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
 ENDIF
 EXECUTE FROM 9000_write_code_log TO 9099_write_code_log_exit
#4099_write_cv_load_exit
#4000_write_cva_load
 CALL clear(11,49,33)
 CALL text(11,49,"Writing CVA_LOAD...")
 CALL text(23,1," ")
 SELECT INTO TABLE cva_load
  ca.*
  FROM code_alias ca
  WHERE ca.code_set >= 0
  WITH nocounter
 ;end select
 SET nbr_code_alias = curqual
 IF (nbr_code_alias=0)
  SET error_message = "%ERROR writing CVA_LOAD"
  EXECUTE FROM 9000_log_insert_error TO 9099_log_insert_error_exit
 ENDIF
 EXECUTE FROM 9000_write_code_alias_log TO 9099_write_code_alias_log_exit
#4099_write_cva_load_exit
#9000_start_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  FOOT REPORT
   col 01, "******************** Code Conversion Out Log File ********************", row + 1,
   " ", row + 1, col 01,
   "Date - ", curdate, row + 1,
   col 01, "User - ", curuser,
   row + 1, col 01, "Program - CODE_CONV (Export)",
   row + 1, " ", row + 1,
   col 01, curtime2, " - Started"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading
 ;end select
#9099_start_log_exit
#9000_initialize_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime2, " - Variables Initialized"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_initialize_log_exit
#9000_write_code_set_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime2, " - CVS_LOAD rows written = ",
   nbr_code_sets"#####"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_write_code_set_log_exit
#9000_write_code_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime2, " - CV_LOAD rows written = ",
   nbr_codes"#####"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_write_code_log_exit
#9000_write_code_alias_log
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime2, " - CVA_LOAD rows written = ",
   nbr_code_alias"#####", row + 1, col 01,
   curtime2, " - Output Files Completed", row + 1,
   " ", row + 1, col 01,
   "******************** Code Conversion Out Log File ********************"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_write_code_alias_log_exit
#9000_log_insert_error
 SELECT INTO code_conv_log
  d.seq
  FROM dummyt d
  DETAIL
   col 01, curtime2, " - ",
   error_message
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading, append
 ;end select
#9099_log_insert_error_exit
#9999_end
 CALL clear(11,49,33)
 CALL text(11,49,"Output Files Completed")
 CALL text(23,1," ")
END GO
