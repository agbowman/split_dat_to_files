CREATE PROGRAM cclocdimportex:dba
 SET s_interactive = validate(reply->ops_event,"ZZZ")
 IF (s_interactive="ZZZ")
  CALL echo("*****************************************************************")
  CALL echo("*** ERROR - cclocdimportex has been replaced by euc_copy_ccl. ***")
  CALL echo("*****************************************************************")
 ELSE
  SET reply->status_data.status = "F"
  SET reply->ops_event = "ERROR - cclocdimportex has been replaced by euc_copy_ccl."
  SET hsys = 0
  SET sysstat = 0
  CALL uar_syscreatehandle(hsys,sysstat)
  CALL uar_sysevent(hsys,0,"CCLOCDImportEx",nullterm(trim(reply->ops_event)))
  CALL uar_sysdestroyhandle(hsys)
 ENDIF
END GO
