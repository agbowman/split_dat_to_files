CREATE PROGRAM dm_stat_lighthouse_wrapper:dba
 IF (checkprg("lh_load_lightson_metrics"))
  EXECUTE lh_load_lightson_metrics
 ENDIF
END GO
