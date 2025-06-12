CREATE PROGRAM dm_check_row_counts:dba
 RECORD dm_check_count(
   1 tlist[*]
     2 current_count = f8
     2 initial_count = f8
 )
 SET stat = alterlist(dm_check_count->tlist,dm_check->tcount)
 IF ((dm_check->tmode=1))
  CALL parser("rdb create table temp_row_counts (table_name varchar2(30), row_count number) go")
  EXECUTE oragen3 "temp_row_counts"
  DELETE  FROM temp_row_counts
   WHERE 1=1
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 FOR (icnt = 1 TO dm_check->tcount)
   CALL parser(concat("execute oragen3 '",dm_check->tlist[icnt].tname,"' go"))
   SET tempstr = fillstring(255," ")
   SET tempstr = concat('select into "nl:" y=count(*) from ',dm_check->tlist[icnt].tname)
   CALL echo(tempstr)
   CALL parser(tempstr)
   IF ((dm_check->tmode=1))
    SET tempstr = concat(" detail dm_check_count->tlist[",cnvtstring(icnt),"]->initial_count=y")
   ELSE
    SET tempstr = concat(" detail dm_check_count->tlist[",cnvtstring(icnt),"]->current_count=y")
   ENDIF
   CALL parser(tempstr)
   CALL parser("with nocounter go")
 ENDFOR
 IF ((dm_check->tmode=2))
  SELECT INTO "nl:"
   trc.*
   FROM temp_row_counts trc,
    (dummyt d  WITH seq = value(dm_check->tcount))
   PLAN (d)
    JOIN (trc
    WHERE (trc.table_name=dm_check->tlist[d.seq].tname))
   DETAIL
    dm_check_count->tlist[d.seq].initial_count = trc.row_count
   WITH nocounter
  ;end select
  SELECT
   *
   FROM dual
   HEAD REPORT
    "Table Name", col 35, "Initial Row Count",
    col 55, "Current Row Count", row + 1
   DETAIL
    FOR (i = 1 TO dm_check->tcount)
      IF ((dm_check_count->tlist[i].initial_count != dm_check_count->tlist[i].current_count))
       row + 1, "**********ERROR ROW COUNT MISMATCH*********", row + 1
      ENDIF
      dm_check->tlist[i].tname, col 35, dm_check_count->tlist[i].initial_count,
      col 55, dm_check_count->tlist[i].current_count, row + 1
      IF ((dm_check_count->tlist[i].initial_count != dm_check_count->tlist[i].current_count))
       row + 1
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  CALL parser("rdb drop table temp_row_counts go")
 ELSE
  FOR (i = 1 TO dm_check->tcount)
   INSERT  FROM temp_row_counts trc
    SET trc.table_name = dm_check->tlist[i].tname, trc.row_count = dm_check_count->tlist[i].
     initial_count
    WITH nocounter
   ;end insert
   COMMIT
  ENDFOR
 ENDIF
END GO
