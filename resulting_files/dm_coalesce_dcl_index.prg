CREATE PROGRAM dm_coalesce_dcl_index
 CALL parser("RDB alter index xie4dm_chg_log coalesce go",1)
 CALL echo("**************************************************************************")
 CALL echo("The index xie4dm_chg_log on the dm_chg_log table has been coaleseced")
 CALL echo("**************************************************************************")
END GO
