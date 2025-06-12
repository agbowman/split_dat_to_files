CREATE PROGRAM dm_stat_export
 SET dm_stat_export_from_dt = cnvtdatetime((curdate - 1),0)
 SET dm_stat_export_to_dt = cnvtdatetime((curdate - 1),235959)
 CALL echo(format(dm_stat_export_from_dt,"dd-mmm-yyyy HH:MM:SS;;d"))
 CALL echo(format(dm_stat_export_to_dt,"dd-mmm-yyyy HH:MM:SS;;d"))
 EXECUTE dm_stat_export_range
END GO
