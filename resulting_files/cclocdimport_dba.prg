CREATE PROGRAM cclocdimport:dba
 SET interactive = validate(reply->ops_event,"ZZZ")
 IF (interactive="ZZZ")
  CALL echo("****************************************************************")
  CALL echo("*** ERROR - cclocdimport was used by Installation Manager.   ***")
  CALL echo("***         Installation Manager was replaced by Environment ***")
  CALL echo("***         Manager in this environment.                     ***")
  CALL echo("****************************************************************")
 ELSE
  SET reply->status_data.status = "F"
  SET reply->ops_event =
  "ERROR - Installation Manager was replaced by Environment Manager in this environment."
  SET hsys = 0
  SET sysstat = 0
  CALL uar_syscreatehandle(hsys,sysstat)
  CALL uar_sysevent(hsys,0,"CCLOCDImport",nullterm(trim(reply->ops_event)))
  CALL uar_sysdestroyhandle(hsys)
 ENDIF
END GO
