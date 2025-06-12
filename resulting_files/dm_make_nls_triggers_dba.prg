CREATE PROGRAM dm_make_nls_triggers:dba
 SET debug = validate(fa_debug,0)
 SET logfile = "dm_nls_triggers.log"
 SET dropfile = "dm_drop_nls_triggers.dat"
 SET international = 0
 SET table_name = fillstring(30," ")
 SET column_name = fillstring(30," ")
 SET nls_col = fillstring(33," ")
 SET trigger_name = fillstring(30," ")
 SET buff1 = fillstring(130," ")
 SET buff2 = fillstring(130," ")
 SET buff3 = fillstring(130," ")
 SET buff4 = fillstring(130," ")
 SET buff5 = fillstring(130," ")
 SET buff6 = fillstring(130," ")
 SET max_upd_cnt = 5000
 SELECT INTO "nl:"
  FROM v$nls_parameters
  WHERE ((parameter="NLS_LANGUAGE"
   AND value != "AMERICAN") OR (parameter="NLS_SORT"
   AND value != "AMERICAN"
   AND value != "BINARY"))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET international = 1
 ENDIF
 SELECT INTO value(logfile)
  FROM dual
  DETAIL
   "; Log file for creating NLS triggers"
   IF (international=0)
    row + 1, "; This is not an international (non-English) site"
   ENDIF
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 IF (international=0)
  CALL echo(">>> This is not an international (non-English) site!")
  GO TO exit_program
 ENDIF
 FREE SET table_list
 RECORD table_list(
   1 count = i2
   1 tables[*]
     2 name = c30
     2 trig = c30
     2 col_count = i2
     2 cols[*]
       3 name = c30
       3 nls_len = i4
 )
 SET stat = alterlist(table_list->tables,0)
 SET table_list->count = 0
 SET col_count = 0
 CALL echo(">>>")
 CALL echo(">>> Looking for tables with NLS columns...")
 CALL echo(">>>")
 SELECT
  IF (international=1)INTO value(logfile)
   FROM user_tab_columns dc,
    user_tab_columns ut
   WHERE ut.table_name=dc.table_name
    AND ut.column_name=concat(dc.column_name,"_NLS")
   ORDER BY dc.table_name, dc.column_id
   HEAD dc.table_name
    table_list->count = (table_list->count+ 1), stat = alterlist(table_list->tables,table_list->count
     ), tcount = table_list->count,
    trigger_name = fillstring(30," "), trigger_name = concat("TRG_",trim(substring(1,22,dc.table_name
       )),"_NLS"), table_list->tables[tcount].name = dc.table_name,
    table_list->tables[tcount].trig = trigger_name, stat = alterlist(table_list->tables[tcount].cols,
     0), table_list->tables[tcount].col_count = 0,
    row + 1, "create or replace trigger ", trigger_name,
    row + 1, "  before insert or update of ", row + 1
   DETAIL
    table_list->tables[tcount].col_count = (table_list->tables[tcount].col_count+ 1), stat =
    alterlist(table_list->tables[tcount].cols,table_list->tables[tcount].col_count), ccount =
    table_list->tables[tcount].col_count,
    table_list->tables[tcount].cols[ccount].name = dc.column_name, table_list->tables[tcount].cols[
    ccount].nls_len = ut.data_length
    IF (ccount=1)
     "    ", dc.column_name
    ELSE
     ",", row + 1, "    ",
     dc.column_name
    ENDIF
   FOOT  dc.table_name
    row + 1, "  on ", dc.table_name,
    " for each row begin", row + 1
    FOR (cloop = 1 TO table_list->tables[tcount].col_count)
      nls_col = fillstring(33," "), nls_col = concat(trim(table_list->tables[tcount].cols[cloop].name
        ),"_NLS"), "    :new.",
      nls_col, " := rtrim(substr(NLSSORT(:new.", table_list->tables[tcount].cols[cloop].name,
      "), 1, ", table_list->tables[tcount].cols[cloop].nls_len, "));",
      row + 1
    ENDFOR
    "  end;", row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ELSE
  ENDIF
 ;end select
 CALL echo(">>>")
 CALL echo(">>> Now creating triggers...")
 CALL echo(">>>")
 FOR (tloop = 1 TO table_list->count)
   SET buff1 = concat('rdb ASIS("create or replace trigger ',trim(table_list->tables[tloop].trig),
    ' ") ')
   SET buff2 = concat('ASIS("before insert or update of ") ')
   CALL parser(buff1,1)
   CALL parser(buff2,1)
   FOR (cloop = 1 TO table_list->tables[tloop].col_count)
    IF (cloop=1)
     SET buff3 = concat('ASIS("',trim(table_list->tables[tloop].cols[cloop].name),' ") ')
    ELSE
     SET buff3 = concat('ASIS(", ',trim(table_list->tables[tloop].cols[cloop].name),' ") ')
    ENDIF
    CALL parser(buff3,1)
   ENDFOR
   SET buff4 = concat('ASIS("on ',trim(table_list->tables[tloop].name),' for each row begin ") ')
   CALL parser(buff4,1)
   FOR (cloop = 1 TO table_list->tables[tloop].col_count)
     SET nls_col = fillstring(33," ")
     SET nls_col = concat(trim(table_list->tables[tloop].cols[cloop].name),"_NLS")
     SET buff5 = concat('ASIS(" :new.',trim(nls_col)," := rtrim(substr(NLSSORT(:new.",trim(table_list
       ->tables[tloop].cols[cloop].name),"), 1, ",
      trim(cnvtstring(table_list->tables[tloop].cols[cloop].nls_len)),')); ") ')
     CALL parser(buff5,1)
   ENDFOR
   SET buff6 = concat('ASIS("end;")  go')
   CALL parser(buff6,1)
   SET col_count = (col_count+ table_list->tables[tloop].col_count)
 ENDFOR
 SELECT
  IF (international=1)INTO value(dropfile)
   FROM (dummyt d  WITH seq = value(table_list->count))
   PLAN (d)
   HEAD REPORT
    "; DO NOT INCLUDE THIS FILE. FOR TESTING PURPOSES ONLY", row + 1,
    "; Delete file to remove all triggers placed for NLS columns",
    row + 1
   DETAIL
    row + 1, "rdb drop trigger ", table_list->tables[d.seq].trig,
    " go"
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ELSE
  ENDIF
 ;end select
 CALL echo(">>>")
 CALL echo(">>> Now updating existing rows...")
 CALL echo(">>>")
 SET upd_count = 0
 SET row_count = 0
 SET iter = 0
 SET last_tname = fillstring(30," ")
 FOR (tloop = 1 TO table_list->count)
   IF (debug=1)
    CALL echo(">>>")
    CALL echo(build(">>> row_count=",row_count))
    CALL echo(">>>")
   ENDIF
   SELECT INTO value(logfile)
    FROM dual
    DETAIL
     ";Updating table ", table_list->tables[tloop].name
    WITH noheading, format = variable, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   IF (debug=1)
    CALL echo(">>>")
   ENDIF
   SET row_count = 1
   WHILE (row_count > 0)
     SET buff1 = concat("update into ",trim(table_list->tables[tloop].name)," d set ")
     CALL parser(buff1,1)
     IF (debug=1)
      CALL echo(buff1)
     ENDIF
     FOR (cloop = 1 TO table_list->tables[tloop].col_count)
       IF (cloop=1)
        SET buff2 = concat("d.",trim(table_list->tables[tloop].cols[cloop].name)," = d.",trim(
          table_list->tables[tloop].cols[cloop].name)," ")
       ELSE
        SET buff2 = concat(", d.",trim(table_list->tables[tloop].cols[cloop].name)," = d.",trim(
          table_list->tables[tloop].cols[cloop].name)," ")
       ENDIF
       CALL parser(buff2,1)
       IF (debug=1)
        CALL echo(buff2)
       ENDIF
     ENDFOR
     FOR (cloop = 1 TO table_list->tables[tloop].col_count)
       IF (cloop=1)
        SET buff3 = concat("where (d.",trim(table_list->tables[tloop].cols[cloop].name),
         "_NLS is null and d.",trim(table_list->tables[tloop].cols[cloop].name)," is not null) ")
       ELSE
        SET buff3 = concat("or (d.",trim(table_list->tables[tloop].cols[cloop].name),
         "_NLS is null and d.",trim(table_list->tables[tloop].cols[cloop].name)," is not null) ")
       ENDIF
       CALL parser(buff3,1)
       IF (debug=1)
        CALL echo(buff3)
       ENDIF
     ENDFOR
     SET buff4 = concat(" with maxqual(d,",trim(cnvtstring(max_upd_cnt)),") go")
     CALL parser(buff4,1)
     IF (debug=1)
      CALL echo(buff4)
      CALL echo(">>>")
     ENDIF
     SET row_count = curqual
     COMMIT
     SELECT INTO value(logfile)
      FROM dual
      DETAIL
       ";... done! (", row_count";L;", ")"
      WITH noheading, format = variable, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
   ENDWHILE
   SET upd_count = (upd_count+ 1)
 ENDFOR
 CALL echo(concat(">>> Created ",trim(cnvtstring(table_list->count))," triggers on ",trim(cnvtstring(
     table_list->count))," tables for ",
   trim(cnvtstring(col_count))," columns!"))
 CALL echo(concat(">>> Updated ",trim(cnvtstring(upd_count))," tables to populate the NLS columns"))
#exit_program
END GO
