CREATE PROGRAM dm_check_unused_tspace:dba
 FREE SET rnewtspace
 RECORD rnewtspace(
   1 tspace_count = i4
   1 qual[10]
     2 tspace_name = c30
     2 inuse_ind = i4
 )
 SET rnewtspace->tspace_count = 0
 FREE SET rtspacefile
 RECORD rtspacefile(
   1 tspace_file_count = i4
   1 qual[10]
     2 tspace_name = c30
     2 file_name = c80
 )
 SET rtspacefile->tspace_file_count = 0
 SET status_line = fillstring(80," ")
 SET status_line = "building dm_segments"
 SELECT INTO "nl:"
  u.table_name
  FROM user_tables u
  WHERE table_name="DM_SEGMENTS"
  WITH nocounter
 ;end select
 IF (curqual != 0)
  CALL parser("rdb drop table dm_segments go",1)
 ENDIF
 CALL parser("rdb create table dm_segments as select * from dba_segments go",1)
 CALL parser("rdb create index ie1_dm_segments on dm_segments (tablespace_name) go",1)
 EXECUTE oragen3 "DM_SEGMENTS"
 SELECT INTO "nl:"
  d.tablespace_name
  FROM dba_tablespaces d
  WHERE d.tablespace_name != "TEMP"
   AND status != "INVALID"
  DETAIL
   rnewtspace->tspace_count = (rnewtspace->tspace_count+ 1)
   IF (mod(rnewtspace->tspace_count,10)=1
    AND (rnewtspace->tspace_count != 1))
    stat = alter(rnewtspace->qual,(rnewtspace->tspace_count+ 9))
   ENDIF
   rnewtspace->qual[rnewtspace->tspace_count].tspace_name = d.tablespace_name, rnewtspace->qual[
   rnewtspace->tspace_count].inuse_ind = 1
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO rnewtspace->tspace_count)
   SET status_line = concat("Checking ",cnvtstring(cnt)," of ",cnvtstring(rnewtspace->tspace_count),
    " ",
    rnewtspace->qual[cnt].tspace_name)
   SELECT INTO "nl:"
    y = count(*)
    FROM dm_segments
    WHERE (tablespace_name=rnewtspace->qual[cnt].tspace_name)
    DETAIL
     IF (y=0)
      rnewtspace->qual[cnt].inuse_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF ((rnewtspace->qual[cnt].inuse_ind=0))
    SELECT INTO "nl:"
     ddf.tablespace_name, ddf.file_name
     FROM dba_data_files ddf
     WHERE (ddf.tablespace_name=rnewtspace->qual[cnt].tspace_name)
     DETAIL
      rtspacefile->tspace_file_count = (rtspacefile->tspace_file_count+ 1)
      IF (mod(rtspacefile->tspace_file_count,10)=1
       AND (rtspacefile->tspace_file_count != 1))
       stat = alter(rtspacefile->qual,(rtspacefile->tspace_file_count+ 9))
      ENDIF
      rtspacefile->qual[rtspacefile->tspace_file_count].tspace_name = ddf.tablespace_name,
      rtspacefile->qual[rtspacefile->tspace_file_count].file_name = ddf.file_name
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SELECT INTO drop_tspace
  d.seq
  FROM (dummyt d  WITH seq = value(rnewtspace->tspace_count))
  PLAN (d
   WHERE (rnewtspace->qual[d.seq].inuse_ind=0))
  DETAIL
   row + 1, "rdb DROP TABLESPACE ", rnewtspace->qual[d.seq].tspace_name,
   " go"
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1, noheading
 ;end select
 IF ((rtspacefile->tspace_file_count > 0))
  IF (cursys != "AIX")
   SELECT INTO "drop_tspace_file.com"
    d.seq
    FROM (dummyt d  WITH seq = value(rtspacefile->tspace_file_count))
    DETAIL
     path = fillstring(80," "), path = build(rtspacefile->qual[d.seq].file_name,";*"), row + 1,
     "$del ", path
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, noheading, maxcol = 255
   ;end select
  ELSE
   SELECT INTO "drop_tspace_file.ksh"
    d.seq
    FROM (dummyt d  WITH seq = value(rtspacefile->tspace_file_count))
    HEAD REPORT
     ". /tmp/v500_install.def", row + 1, ". /tmp/setup_oracle_variables $DbName",
     row + 1, "echo  >drop_tspace_rmlv.ksh", row + 1
    DETAIL
     fname = build('"',rtspacefile->qual[d.seq].file_name,'"'), fname2 = build(" ",rtspacefile->qual[
      d.seq].file_name," "), "tmpwork=",
     fname, row + 1, "device=${tmpwork#/dev/r}",
     row + 1, "link=$(ls -l $ORA_LINKS/* | grep ", fname2,
     " | awk '{print $9}')", row + 1, 'echo "rmlv -f $device" >> drop_tspace_rmlv.ksh',
     row + 1, 'echo "rm $link" >> drop_tspace_rmlv.ksh', row + 1
    FOOT REPORT
     "chmod 775 drop_tspace_rmlv.ksh", row + 1
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, noheading, maxcol = 255
   ;end select
  ENDIF
 ENDIF
 CALL parser("rdb drop table dm_segments go",1)
 FREE SET rnewtspace
END GO
