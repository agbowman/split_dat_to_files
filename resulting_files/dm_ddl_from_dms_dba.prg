CREATE PROGRAM dm_ddl_from_dms:dba
 SET trace = nocost
 SET message = noinformation
 DECLARE init_extent = vc
 DECLARE next_extent = vc
 DECLARE pct_free = vc
 DECLARE pct_used = vc
 DECLARE default_value_str = vc
 DECLARE v_dms = vc
 DECLARE v_fmt_dms = vc
 DECLARE count = i4
 DECLARE table_count = i4
 DECLARE fk_str = vc
 DECLARE table_pk = vc
 SET count = 0
 SET v_dms = cnvtupper( $1)
 SET v_fmt_dms = trim(replace(v_dms," ","_",0))
 SET v_fmt_dms = trim(replace(v_fmt_dms,"/","_",0))
 SET v_fmt_dms = trim(replace(v_fmt_dms,",","_",0))
 SET v_fmt_dms = trim(replace(v_fmt_dms,"-","_",0))
 IF (size(v_fmt_dms,1) > 21)
  SET filename1 = concat("DMS_",substring(1,22,v_fmt_dms),".sql")
 ELSE
  SET filename1 = concat("DMS_",v_fmt_dms,".sql")
 ENDIF
 FREE SET tablespace
 RECORD tablespace(
   1 tables[10]
     2 table_name = vc
 )
 CALL echo(build("Retrieving table names from dm_tables_doc for DMS (",v_dms,")"))
 SELECT INTO "nl:"
  table_name
  FROM dm_tables_doc dtd
  WHERE cnvtupper(dtd.data_model_section)=v_dms
  ORDER BY dtd.table_name
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alter(tablespace->tables,(count+ 9))
   ENDIF
   tablespace->tables[count].table_name = dtd.table_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(build("No Tables found for DMS (",v_dms,")"))
  GO TO exit_script
 ENDIF
 SET stat = alter(tablespace->tables,count)
 CALL echo(build("Creating File (",filename1,")"))
 FREE SET x
 FOR (x = 1 TO count)
   FREE SET v_table_name
   SET v_table_name = tablespace->tables[x].table_name
   CALL echo(build("Processing Table (",v_table_name,")"))
   SELECT INTO value(filename1)
    uic.column_name, uic.data_type, uic.data_length,
    uic.nullable, uic.column_id, uic.table_name,
    default_value = substring(1,40,uic.data_default)
    FROM user_tab_columns uic
    WHERE table_name=v_table_name
    ORDER BY uic.column_id
    HEAD REPORT
     "/***************************************************************************", row + 1,
     "* this section creates the target table",
     row + 1, "***************************************************************************/", row + 1,
     "/*DROP TABLE ", uic.table_name, " GO */",
     row + 1, "CREATE TABLE ", uic.table_name,
     row + 1, col 10, "("
    DETAIL
     IF (uic.column_id > 1)
      ","
     ENDIF
     row + 1, col 10, uic.column_name,
     col 50, uic.data_type
     IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
      col 60, "(", col 61,
      uic.data_length"####;;I", col 66, ")"
     ENDIF
     IF (default_value != fillstring(40," "))
      default_value_str = trim(default_value), " DEFAULT ", default_value_str
     ENDIF
     IF (uic.nullable="N")
      " NOT NULL"
     ENDIF
    FOOT REPORT
     row + 1, col 10, ")"
    WITH nocounter, append, format = stream,
     noheading, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
   SELECT INTO value(filename1)
    ut.pct_free, ut.pct_used, ut.tablespace_name,
    ut.initial_extent, ut.next_extent
    FROM user_tables ut
    WHERE table_name=v_table_name
    HEAD REPORT
     pct_free = cnvtstring(ut.pct_free), col 10, "PCTFREE ",
     pct_free, row + 1, pct_used = cnvtstring(ut.pct_used),
     col 10, "PCTUSED ", pct_used,
     row + 1, col 10, "TABLESPACE ",
     ut.tablespace_name, row + 1, col 10,
     "STORAGE ("
    DETAIL
     row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ut.initial_extent/ 1024),11,0)),"K"),
     col 15,
     init_extent, row + 1, next_extent = concat("NEXT ",trim(cnvtstring((ut.next_extent/ 1024),11,0)),
      "K"),
     col 15, next_extent, row + 1,
     col 10, ")"
    FOOT REPORT
     row + 1, ";", row + 1
    WITH nocounter, append, format = stream,
     noheading, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
   IF (curqual=0)
    SELECT INTO value(filename1)
     HEAD REPORT
      "/*No data found on user_table for */", row + 1,
      "/*PCTFREE, PCTUSED, TABLESPACE, or STORAGE */",
      row + 1
     FOOT REPORT
      ";", row + 1
     WITH nocounter, append, format = stream,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
   SELECT INTO value(filename1)
    uc.constraint_name, uc.table_name, ucc.column_name,
    ucc.position, ui.tablespace_name, ui.initial_extent,
    ui.next_extent, uc.status
    FROM user_indexes ui,
     user_cons_columns ucc,
     user_constraints uc
    WHERE uc.owner=ucc.owner
     AND uc.constraint_name=ui.index_name
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.table_name=uc.table_name
     AND uc.table_name=v_table_name
     AND uc.constraint_type="P"
    ORDER BY uc.table_name, ucc.position
    HEAD REPORT
     "/***************************************************************************", row + 1,
     "* this section creates the primary key on the target table",
     row + 1, "***************************************************************************/", row + 1
    HEAD uc.table_name
     table_pk = uc.constraint_name, "ALTER TABLE ", uc.table_name,
     row + 1, col 10, "ADD CONSTRAINT ",
     uc.constraint_name, row + 1, col 15,
     "PRIMARY KEY ("
    DETAIL
     IF (ucc.position > 1)
      ","
     ENDIF
     row + 1, col 20, ucc.column_name
    FOOT  uc.table_name
     row + 1, col 15, ")",
     row + 1, col 15, "USING INDEX TABLESPACE ",
     ui.tablespace_name, " "
     IF (uc.status="DISABLED")
      "DISABLE"
     ENDIF
     row + 1, col 15, "STORAGE (",
     row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ui.initial_extent/ 1024),11,0)),"K"),
     col 20,
     init_extent, row + 1, next_extent = concat("NEXT ",trim(cnvtstring((ui.next_extent/ 1024),11,0)),
      "K"),
     col 20, next_extent, row + 1,
     col 15, ")", row + 1,
     ";"
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
   SET fk_str = ""
   SELECT INTO value(filename1)
    c.column_name, c.position, b.table_name,
    c.constraint_name, a.table_name, b.status
    FROM user_cons_columns c,
     user_constraints a,
     user_constraints b
    WHERE b.constraint_type="R"
     AND b.r_constraint_name=a.constraint_name
     AND b.owner=a.owner
     AND b.constraint_name=c.constraint_name
     AND b.owner=c.owner
     AND b.table_name=v_table_name
    ORDER BY c.constraint_name, c.position
    HEAD REPORT
     "/***************************************************************************", row + 1,
     "* this section recreates the foreign key constraints on this table",
     row + 1, "***************************************************************************/", row + 1
    HEAD c.constraint_name
     "ALTER TABLE ", b.table_name, row + 1,
     col 10, "ADD CONSTRAINT ", c.constraint_name,
     row + 1, col 15, "FOREIGN KEY ("
    DETAIL
     IF (c.position > 1)
      fk_str = concat(fk_str,",",c.column_name)
     ELSE
      fk_str = c.column_name
     ENDIF
    FOOT  c.constraint_name
     fk_str, ")", row + 1,
     col 10, "REFERENCES ", a.table_name,
     "(", fk_str, ")"
     IF (b.status="DISABLED")
      " DISABLE"
     ENDIF
     ";", row + 1
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
   SELECT INTO value(filename1)
    ai.table_name, ai.table_owner, ai.tablespace_name,
    ai.index_name, ai.uniqueness, aic.column_name,
    aic.column_position, aic.column_length
    FROM (sys.all_indexes ai),
     (sys.all_ind_columns aic)
    WHERE ai.table_name=v_table_name
     AND ai.table_owner="V500"
     AND ai.index_name=aic.index_name
     AND ai.index_name != table_pk
     AND ai.table_name=aic.table_name
     AND ai.table_owner=aic.table_owner
    ORDER BY ai.index_name, aic.column_position
    HEAD REPORT
     "/***************************************************************************", row + 1,
     "* this section creates the indexes on this table",
     row + 1, "***************************************************************************/"
    HEAD ai.index_name
     row + 1, "CREATE "
     IF (ai.uniqueness="UNIQUE")
      ai.uniqueness
     ENDIF
     " INDEX ", ai.index_name, row + 1,
     col 10, "ON ", ai.table_name,
     "("
    DETAIL
     IF (aic.column_position > 1)
      ","
     ENDIF
     row + 1, col 15, aic.column_name
    FOOT  ai.index_name
     row + 1, col 10, ")",
     row + 1, col 10, "TABLESPACE ",
     ai.tablespace_name, row + 1, col 10,
     "STORAGE (", row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ai.initial_extent/ 1024),
        11,0)),"K"),
     col 15, init_extent, row + 1,
     next_extent = concat("NEXT ",trim(cnvtstring((ai.next_extent/ 1024),11,0)),"K"), col 15,
     next_extent,
     row + 1, col 10, ")",
     row + 1, ";", row + 1
    WITH nocounter, format = stream, noheading,
     append, formfeed = none, maxcol = 512,
     maxrow = 1
   ;end select
 ENDFOR
 CALL echo(build("Created File (",filename1,")"))
#exit_script
END GO
