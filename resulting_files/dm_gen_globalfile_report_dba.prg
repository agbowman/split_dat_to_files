CREATE PROGRAM dm_gen_globalfile_report:dba
 IF ((fs_proc->ocd_ind=0))
  SELECT
   IF (( $1=1))
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 131, maxrow = 1, append
   ELSE
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 131, maxrow = 1
   ENDIF
   INTO value(fs_proc->table_filename)
   FROM dual
   HEAD REPORT
    ddl_file = fillstring(30," "), com_file = fillstring(30," "), fi = 0,
    dmsteps_idx = 0
    FOR (fi = 1 TO rfiles->fcnt)
      IF (findstring("dmsteps",rfiles->qual[fi].fname) > 0)
       dmsteps_idx = fi, fi = rfiles->fcnt
      ENDIF
    ENDFOR
    IF (dmsteps_idx > 0)
     row + 1, "The following file contains global DM steps and should be", row + 1,
     "executed at the end, when no more schema differences remain.", row + 1, row + 1,
     row + 1
     IF (( $1=0))
      col 35, "Uptime/Downtime", col 55,
      "DDL Filename", col 90, "COM Filename",
      row + 1, col 35, "---------------",
      col 55, "------------", col 90,
      "------------", row + 1
     ENDIF
    ENDIF
   DETAIL
    IF (dmsteps_idx > 0)
     col 0, "DM Steps", col 35,
     "Downtime Only", ddl_file = rfiles->qual[dmsteps_idx].file2d, com_file = rfiles->qual[
     dmsteps_idx].file1dcom,
     col 55, ddl_file, col 90,
     com_file, row + 1
    ENDIF
  ;end select
 ENDIF
#end_program
END GO
