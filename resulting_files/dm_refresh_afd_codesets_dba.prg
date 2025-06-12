CREATE PROGRAM dm_refresh_afd_codesets:dba
 SET tempstr = fillstring(255," ")
 SET cnumber = cnvtstring(afd_nbr)
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   row + 2, "execute dm_ocd_refresh_cvs go", row + 1,
   tempstr = build("%i ccluserdir:dm_ocd_refresh_cvs_",cnumber,".dat"), tempstr, row + 1,
   "execute dm_ocd_refresh_cdf go", row + 1, tempstr = build("%i ccluserdir:dm_ocd_refresh_cdf_",
    cnumber,".dat"),
   tempstr, row + 1, "execute dm_ocd_refresh_cse go",
   row + 1, tempstr = build("%i ccluserdir:dm_ocd_refresh_cse_",cnumber,".dat"), tempstr,
   row + 1, "execute dm_ocd_refresh_cv go", row + 1,
   tempstr = build("%i ccluserdir:dm_ocd_refresh_cv_",cnumber,".dat"), tempstr, row + 1,
   "execute dm_ocd_refresh_cva go", row + 1, tempstr = build("%i ccluserdir:dm_ocd_refresh_cva_",
    cnumber,".dat"),
   tempstr, row + 1, "execute dm_ocd_refresh_cve go",
   row + 1, tempstr = build("%i ccluserdir:dm_ocd_refresh_cve_",cnumber,".dat"), tempstr,
   row + 4
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 1
 ;end select
END GO
