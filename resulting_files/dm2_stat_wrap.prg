CREATE PROGRAM dm2_stat_wrap
 EXECUTE dm2_dbstats_chk_rpt "*", 30
 SET dm2_oragen_system_defs = 1
 EXECUTE dm2_create_system_defs
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
END GO
