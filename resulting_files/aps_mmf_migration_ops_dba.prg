CREATE PROGRAM aps_mmf_migration_ops:dba
 SET modify = predeclare
 DECLARE susername = c60 WITH protect, noconstant(fillstring(60," "))
 DECLARE nprocesshours = i2 WITH protect, noconstant(0)
 DECLARE ndividerpos = i2 WITH protect, noconstant(0)
 DECLARE lprocesssecs = i4 WITH protect, noconstant(0)
 SET ndividerpos = findstring("|",request->batch_selection)
 SET susername = cnvtupper(substring(1,(ndividerpos - 1),request->batch_selection))
 SET nprocesshours = cnvtint(substring((ndividerpos+ 1),(size(request->batch_selection,1) -
   ndividerpos),request->batch_selection))
 IF (isnumeric(nprocesshours)=1)
  SET lprocesssecs = nprocesshours
  SET lprocesssecs = (lprocesssecs * 3600)
  EXECUTE aps_mmf_migration lprocesssecs, 0
 ENDIF
END GO
