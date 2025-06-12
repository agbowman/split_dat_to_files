CREATE PROGRAM dm_refresh_afd_tables:dba
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   "execute dm_ocd_fix_schema go", row + 2, "execute dm_ocd_incl_fix go",
   row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 1
 ;end select
END GO
