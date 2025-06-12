CREATE PROGRAM dm_schema_benchmark:dba
 PAINT
 SET width = 132
 SET validate = off
 IF ( NOT (validate(dm_schema_log,0)))
  FREE SET dm_schema_log
  RECORD dm_schema_log(
    1 env_id = f8
    1 run_id = f8
    1 ocd = i4
    1 schema_date = dq8
    1 operation = vc
    1 file_name = vc
    1 table_name = vc
    1 object_name = vc
    1 column_name = vc
    1 op_id = f8
    1 options = vc
  )
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    dm_schema_log->env_id = i.info_number
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE row_count(rc_table)
   SET rc_count = 0
   SELECT INTO "nl:"
    o.row_count
    FROM ref_report_log l,
     ref_report_parms_log p,
     space_objects o,
     ref_instance_id i
    PLAN (l
     WHERE l.report_cd=1
      AND l.end_date IS NOT null)
     JOIN (p
     WHERE (p.report_seq=(l.report_seq+ 0))
      AND p.parm_cd=1)
     JOIN (i
     WHERE (i.environment_id=dm_schema_log->env_id)
      AND cnvtstring(i.instance_cd)=p.parm_value)
     JOIN (o
     WHERE o.segment_name=rc_table
      AND ((o.report_seq+ 0)=l.report_seq))
    ORDER BY l.begin_date
    DETAIL
     rc_count = o.row_count
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
 SUBROUTINE table_missing(tm_dummy)
   SET tm_flag = 1
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name="DM_SCHEMA_LOG"
    DETAIL
     tm_flag = 0
    WITH nocounter
   ;end select
   RETURN(tm_flag)
 END ;Subroutine
 DECLARE def_ttspace = vc
 DECLARE def_itspace = vc
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_main TO 2999_main_exit
 GO TO 9999_exit_program
 SUBROUTINE dsb_get_tspace(dummy)
   SELECT INTO "nl:"
    t.tablespace_name, i.tablespace_name
    FROM user_tables t,
     user_indexes i
    PLAN (t
     WHERE t.table_name="PERSON")
     JOIN (i
     WHERE t.table_name=i.table_name)
    DETAIL
     def_ttspace = t.tablespace_name, def_itspace = i.tablespace_name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_benchmark(lb_tablespace,lb_operation)
   SET lb_value = 0.0
   SELECT INTO "nl:"
    i.info_number
    FROM dm_info i
    WHERE i.info_domain=lb_operation
     AND i.info_name=lb_tablespace
    DETAIL
     lb_value = i.info_number
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    SELECT INTO "nl:"
     i.info_number
     FROM dm_info i
     WHERE i.info_domain=lb_operation
      AND i.info_name=cdefault
     DETAIL
      lb_value = i.info_number
     WITH nocounter
    ;end select
   ENDIF
   RETURN(lb_value)
 END ;Subroutine
 SUBROUTINE log_time(lt_tablespace,lt_operation,lt_start,lt_stop,lt_rows)
   IF (per_row(lt_operation))
    SET lt_temp = lt_rows
   ELSE
    SET lt_temp = 1
   ENDIF
   SET lt_value = 0.0
   SET lt_value = (((lt_stop - lt_start)/ 10000000.0)/ lt_temp)
   CALL update_benchmark(lt_tablespace,lt_operation,lt_value)
 END ;Subroutine
 SUBROUTINE per_row(pr_operation)
   IF (((findstring(cadd_not_null_constraint,pr_operation)) OR (((findstring(cadd_foreign_key,
    pr_operation)) OR (((findstring(cadd_primary_key,pr_operation)) OR (((findstring(ccreate_index,
    pr_operation)) OR (((findstring(ccreate_unique_index,pr_operation)) OR (((findstring(cdrop_index,
    pr_operation)) OR (((findstring(cpopulate_default,pr_operation)) OR (((findstring(
    ccreate_index_online,pr_operation)) OR (((findstring(ccreate_unique_index_online,pr_operation))
    OR (((findstring(cadd_not_null_constraint_novalidate,pr_operation)) OR (findstring(
    cenable_not_null_constraint,pr_operation))) )) )) )) )) )) )) )) )) )) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE update_benchmark(ub_tablespace,ub_operation,ub_value)
   DELETE  FROM dm_info i
    WHERE i.info_domain=ub_operation
     AND i.info_name=ub_tablespace
    WITH nocounter
   ;end delete
   FREE SET ub_char
   IF (per_row(ub_operation))
    SET ub_char = "R"
   ELSE
    SET ub_char = ""
   ENDIF
   IF (ub_value)
    INSERT  FROM dm_info i
     SET i.info_domain = ub_operation, i.info_name = ub_tablespace, i.info_date = null,
      i.info_char = ub_char, i.info_number = ub_value, i.info_long_id = 0,
      i.updt_applctx = 0, i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_cnt = 0,
      i.updt_id = 0, i.updt_task = 0
     WITH nocounter
    ;end insert
    IF ( NOT (curqual))
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE working(w_message)
   CALL text(24,1,fillstring(131," "))
   CALL text(24,3,w_message)
   CALL text(24,130," ")
 END ;Subroutine
#1000_initialize
 IF (table_missing(0))
  SET message = nowindow
  CALL echo("The necessary schema (DM_SCHEMA_LOG and DM_SCHEMA_OP_LOG) doesn't yet exist.")
  GO TO 9999_exit_program
 ENDIF
 ROLLBACK
 SET cformat = fillstring(15," ")
 SET cdefault = fillstring(7," ")
 SET cdata_prefix = fillstring(2," ")
 SET cindex_prefix = fillstring(2," ")
 SET call_tablespaces = fillstring(3," ")
 SET cview = 0
 SET cedit = 0
 SET ccapture = 0
 SET ctemp_table = fillstring(9," ")
 SET cdomain = fillstring(16," ")
 SET cadd_column = fillstring(27," ")
 SET cadd_default_value = fillstring(34," ")
 SET cadd_foreign_key = fillstring(43," ")
 SET cadd_not_null_constraint = fillstring(40," ")
 SET cadd_primary_key = fillstring(43," ")
 SET ccoalesce = fillstring(36," ")
 SET ccreate_index = fillstring(29," ")
 SET ccreate_sequence = fillstring(32," ")
 SET ccreate_table = fillstring(29," ")
 SET ccreate_unique_index = fillstring(36," ")
 SET cdrop_constraint = fillstring(32," ")
 SET cdrop_index = fillstring(27," ")
 SET cmodify_column = fillstring(40," ")
 SET cpopulate_default = fillstring(39," ")
 SET cadd_not_null_constraint_novalidate = fillstring(51," ")
 SET cget_not_null_constraint_name = fillstring(45," ")
 SET cenable_not_null_constraint = fillstring(43," ")
 SET ccreate_index_online = fillstring(36," ")
 SET ccreate_unique_index_online = fillstring(43," ")
 SET crename_index = fillstring(29," ")
 SET cdefault = "DEFAULT"
 SET cdata_prefix = "D_"
 SET cindex_prefix = "I_"
 SET call_tablespaces = "ALL"
 SET cview = 1
 SET cedit = 2
 SET ccapture = 3
 SET ctemp_table = "TMP_BMARK"
 SET cformat = "####.######;RP "
 SET cdomain = "SCHEMA BENCHMARK"
 SET cadd_column = concat(cdomain," ADD COLUMN")
 SET cadd_default_value = concat(cdomain," ADD DEFAULT VALUE")
 SET cadd_foreign_key = concat(cdomain," ADD FOREIGN KEY CONSTRAINT")
 SET cadd_not_null_constraint = concat(cdomain," ADD NOT NULL CONSTRAINT")
 SET cadd_primary_key = concat(cdomain," ADD PRIMARY KEY CONSTRAINT")
 SET ccoalesce = concat(cdomain," COALESCE TABLESPACE")
 SET ccreate_index = concat(cdomain," CREATE INDEX")
 SET ccreate_sequence = concat(cdomain," CREATE SEQUENCE")
 SET ccreate_table = concat(cdomain," CREATE TABLE")
 SET ccreate_unique_index = concat(cdomain," CREATE UNIQUE INDEX")
 SET cdrop_constraint = concat(cdomain," DROP CONSTRAINT")
 SET cdrop_index = concat(cdomain," DROP INDEX")
 SET cmodify_column = concat(cdomain," MODIFY COLUMN DATA TYPE")
 SET cpopulate_default = concat(cdomain," POPULATE DEFAULT VALUE")
 SET cadd_not_null_constraint_novalidate = concat(cdomain," ADD NOT NULL CONSTRAINT NOVALIDATE")
 SET cget_not_null_constraint_name = concat(cdomain," GET NOT NULL CONSTRAINT NAME")
 SET cenable_not_null_constraint = concat(cdomain," ENABLE NOT NULL CONSTRAINT")
 SET ccreate_index_online = concat(cdomain," CREATE INDEX ONLINE")
 SET ccreate_unique_index_online = concat(cdomain," CREATE UNIQUE INDEX ONLINE")
 SET crename_index = concat(cdomain," RENAME INDEX")
 SET mode = 0
 SET flag = 0
 SET i = 0
 SET j = 0
 SET k = 0
 FREE SET work
 RECORD work(
   1 txt = vc
   1 tablespace = vc
   1 dtablespace = vc
   1 itablespace = vc
   1 log_dtablespace = vc
   1 log_itablespace = vc
   1 ora_complete_version = vc
   1 cons_name = vc
 )
 SELECT INTO "nl:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   work->ora_complete_version = p.version
  WITH nocounter
 ;end select
#1999_initialize_exit
#2000_main
 IF (validate(defaults_missing,0))
  FREE SET tspaces
  RECORD tspaces(
    1 tspace[1]
      2 name = vc
      2 default = i2
  )
  SET rows = 1000
  SET tspace_count = 1
  SET tspaces->tspace[1].default = 1
  SET tspace_index = 1
  EXECUTE FROM 2510_generate_start TO 2590_generate_end
  GO TO 9999_exit_program
 ENDIF
 EXECUTE FROM 2100_screen TO 2199_screen_exit
 EXECUTE FROM 2200_menu TO 2299_menu_exit
 EXECUTE FROM 2300_view TO 2399_view_exit
 EXECUTE FROM 2400_edit TO 2499_edit_exit
 EXECUTE FROM 2500_capture TO 2599_capture_exit
 GO TO 2000_main
#2999_main_exit
#2100_screen
 CALL clear(1,1)
 CALL box(1,1,3,132)
 CALL text(2,3,"S C H E M A   B E N C H M A R K   U T I L I T Y")
 SET work->txt = ""
 SELECT INTO "nl:"
  d.name
  FROM v$database d
  DETAIL
   work->txt = concat("Database: ",trim(d.name,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.instance
  FROM v$thread t
  WHERE t.status="OPEN"
  DETAIL
   work->txt = concat(work->txt,"  |  SID: ",trim(t.instance,3))
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  SELECT INTO "nl:"
   t.instance
   FROM v$parameter p,
    v$thread t
   WHERE p.name="thread"
    AND p.value=cnvtstring(t.thread#)
   DETAIL
    work->txt = concat(work->txt,"  |  SID: ",trim(t.instance,3))
   WITH nocounter
  ;end select
 ENDIF
 SET i = ((132 - size(work->txt)) - 1)
 CALL text(2,i,work->txt)
#2199_screen_exit
#2200_menu
 CALL text(5,3,"1) View existing benchmarks")
 CALL text(6,3,"2) Edit benchmarks")
 CALL text(7,3,"3) Capture benchmarks")
 CALL text(8,3,"4) Exit")
 CALL text(10,3,"> Make your selection:")
 SET mode = 0
 WHILE ( NOT (mode))
  CALL accept(10,26,"9",0)
  CASE (curaccept)
   OF 1:
    SET mode = cview
   OF 2:
    SET mode = cedit
   OF 3:
    SET mode = ccapture
   OF 4:
    GO TO 9999_exit_program
  ENDCASE
 ENDWHILE
#2299_menu_exit
#2300_view
 IF (mode != cview)
  GO TO 2399_view_exit
 ENDIF
 SELECT
  i.info_name
  FROM dm_info i
  WHERE i.info_domain=patstring(concat(cdomain,"*"))
  ORDER BY i.info_domain, i.info_name
  HEAD REPORT
   CALL print("SCHEMA OPERATION BENCHMARKS"), row + 2,
   CALL print("Operation                           Tablespace                             Seconds"),
   row + 1,
   CALL print("---------                           ----------                         -----------"),
   row + 1
  HEAD i.info_domain
   col 0,
   CALL print(trim(replace(i.info_domain,cdomain,"",0),3))
  DETAIL
   col 36,
   CALL print(trim(i.info_name,3)), col 66,
   CALL print(format(i.info_number,cformat))
   IF (per_row(i.info_domain))
    col 78, "per row"
   ENDIF
   row + 1
  FOOT  i.info_domain
   row + 1
  FOOT REPORT
   "*** end of report ***"
  WITH nocounter, noformfeed
 ;end select
#2399_view_exit
#2400_edit
 IF (mode != cedit)
  GO TO 2499_edit_exit
 ENDIF
 CALL clear(4,1)
 CALL text(5,3,"> Enter tablespace name (or 'DEFAULT' for default benchmarks)(shift F5 for help):")
 SET work->tablespace = ""
 SET flag = 1
 WHILE (flag
  AND  NOT (size(trim(work->tablespace,3))))
   SET help =
   SELECT INTO "nl:"
    u.tablespace_name
    FROM user_tablespaces u
    WHERE u.status="ONLINE"
     AND ((substring(1,2,u.tablespace_name)=cdata_prefix) OR (substring(1,2,u.tablespace_name)=
    cindex_prefix))
    ORDER BY substring(3,28,u.tablespace_name)
    WITH nocounter
   ;end select
   CALL accept(5,85,"P(30);CU")
   SET help = off
   IF (size(trim(curaccept,3)))
    SET work->tablespace = cnvtupper(trim(curaccept,3))
    IF ((work->tablespace=cdefault))
     SET work->dtablespace = cdefault
     SET work->itablespace = cdefault
    ELSE
     IF (size(work->tablespace) > 2)
      IF (((substring(1,2,work->tablespace)=cdata_prefix) OR (substring(1,2,work->tablespace)=
      cindex_prefix)) )
       SET work->tablespace = substring(3,(size(work->tablespace) - 2),work->tablespace)
      ENDIF
     ENDIF
     SET work->dtablespace = concat(cdata_prefix,work->tablespace)
     SET work->itablespace = concat(cindex_prefix,work->tablespace)
     SELECT INTO "nl:"
      u.tablespace_name
      FROM user_tablespaces u
      WHERE u.tablespace_name=concat(cdata_prefix,work->tablespace)
       AND u.status="ONLINE"
      WITH nocounter
     ;end select
     IF ( NOT (curqual))
      SET work->tablespace = ""
      CALL text(6,4,"The tablespace name entered is either invalid or offline.")
      CALL text(7,4,"Would you like to try another tablespace?   (Y/N)")
      CALL accept(7,60,"P;CU")
      IF (curaccept="N")
       GO TO 2000_main
      ENDIF
      CALL clear(6,1)
      CALL clear(7,1)
     ENDIF
    ENDIF
   ELSE
    SET flag = 0
   ENDIF
 ENDWHILE
 IF ( NOT (size(trim(work->tablespace,3))))
  GO TO 2499_edit_exit
 ENDIF
 IF (substring(1,5,work->ora_complete_version) < "8.1.7")
  IF ((work->tablespace=cdefault))
   SET benchmark_count = 14
  ELSE
   SET benchmark_count = 13
  ENDIF
 ELSEIF ((work->tablespace=cdefault))
  SET benchmark_count = 20
 ELSE
  SET benchmark_count = 19
 ENDIF
 FREE SET benchmarks
 RECORD benchmarks(
   1 benchmark[benchmark_count]
     2 tablespace = vc
     2 operation = vc
     2 value = f8
 )
 SET benchmarks->benchmark[1].tablespace = work->dtablespace
 SET benchmarks->benchmark[1].operation = cadd_column
 SET benchmarks->benchmark[1].value = load_benchmark(work->dtablespace,cadd_column)
 SET benchmarks->benchmark[2].tablespace = work->dtablespace
 SET benchmarks->benchmark[2].operation = cadd_default_value
 SET benchmarks->benchmark[2].value = load_benchmark(work->dtablespace,cadd_default_value)
 SET benchmarks->benchmark[3].tablespace = work->itablespace
 SET benchmarks->benchmark[3].operation = cadd_foreign_key
 SET benchmarks->benchmark[3].value = load_benchmark(work->itablespace,cadd_foreign_key)
 SET benchmarks->benchmark[4].tablespace = work->itablespace
 SET benchmarks->benchmark[4].operation = cadd_not_null_constraint
 SET benchmarks->benchmark[4].value = load_benchmark(work->itablespace,cadd_not_null_constraint)
 SET benchmarks->benchmark[5].tablespace = work->itablespace
 SET benchmarks->benchmark[5].operation = cadd_primary_key
 SET benchmarks->benchmark[5].value = load_benchmark(work->itablespace,cadd_primary_key)
 SET benchmarks->benchmark[6].tablespace = work->dtablespace
 SET benchmarks->benchmark[6].operation = ccoalesce
 SET benchmarks->benchmark[6].value = load_benchmark(work->dtablespace,ccoalesce)
 SET benchmarks->benchmark[7].tablespace = work->itablespace
 SET benchmarks->benchmark[7].operation = ccreate_index
 SET benchmarks->benchmark[7].value = load_benchmark(work->itablespace,ccreate_index)
 SET benchmarks->benchmark[8].tablespace = work->dtablespace
 SET benchmarks->benchmark[8].operation = ccreate_table
 SET benchmarks->benchmark[8].value = load_benchmark(work->dtablespace,ccreate_table)
 SET benchmarks->benchmark[9].tablespace = work->itablespace
 SET benchmarks->benchmark[9].operation = ccreate_unique_index
 SET benchmarks->benchmark[9].value = load_benchmark(work->itablespace,ccreate_unique_index)
 SET benchmarks->benchmark[10].tablespace = work->itablespace
 SET benchmarks->benchmark[10].operation = cdrop_constraint
 SET benchmarks->benchmark[10].value = load_benchmark(work->itablespace,cdrop_constraint)
 SET benchmarks->benchmark[11].tablespace = work->itablespace
 SET benchmarks->benchmark[11].operation = cdrop_index
 SET benchmarks->benchmark[11].value = load_benchmark(work->itablespace,cdrop_index)
 SET benchmarks->benchmark[12].tablespace = work->dtablespace
 SET benchmarks->benchmark[12].operation = cmodify_column
 SET benchmarks->benchmark[12].value = load_benchmark(work->dtablespace,cmodify_column)
 SET benchmarks->benchmark[13].tablespace = work->dtablespace
 SET benchmarks->benchmark[13].operation = cpopulate_default
 SET benchmarks->benchmark[13].value = load_benchmark(work->dtablespace,cpopulate_default)
 IF (substring(1,5,work->ora_complete_version) >= "8.1.7")
  SET benchmarks->benchmark[14].tablespace = work->itablespace
  SET benchmarks->benchmark[14].operation = ccreate_index_online
  SET benchmarks->benchmark[14].value = load_benchmark(work->itablespace,ccreate_index_online)
  SET benchmarks->benchmark[15].tablespace = work->itablespace
  SET benchmarks->benchmark[15].operation = ccreate_unique_index_online
  SET benchmarks->benchmark[15].value = load_benchmark(work->itablespace,ccreate_unique_index_online)
  SET benchmarks->benchmark[16].tablespace = work->itablespace
  SET benchmarks->benchmark[16].operation = cadd_not_null_constraint_novalidate
  SET benchmarks->benchmark[16].value = load_benchmark(work->itablespace,
   cadd_not_null_constraint_novalidate)
  SET benchmarks->benchmark[17].tablespace = work->dtablespace
  SET benchmarks->benchmark[17].operation = cget_not_null_constraint_name
  SET benchmarks->benchmark[17].value = load_benchmark(work->itablespace,
   cget_not_null_constraint_name)
  SET benchmarks->benchmark[18].tablespace = work->dtablespace
  SET benchmarks->benchmark[18].operation = cenable_not_null_constraint
  SET benchmarks->benchmark[18].value = load_benchmark(work->itablespace,cenable_not_null_constraint)
  SET benchmarks->benchmark[19].tablespace = work->itablespace
  SET benchmarks->benchmark[19].operation = crename_index
  SET benchmarks->benchmark[19].value = load_benchmark(work->itablespace,crename_index)
  IF (benchmark_count >= 20)
   SET benchmarks->benchmark[20].tablespace = work->dtablespace
   SET benchmarks->benchmark[20].operation = ccreate_sequence
   SET benchmarks->benchmark[20].value = load_benchmark(work->dtablespace,ccreate_sequence)
  ENDIF
 ELSE
  IF (benchmark_count >= 14)
   SET benchmarks->benchmark[14].tablespace = work->dtablespace
   SET benchmarks->benchmark[14].operation = ccreate_sequence
   SET benchmarks->benchmark[14].value = load_benchmark(work->dtablespace,ccreate_sequence)
  ENDIF
 ENDIF
 CALL text(6,6,"Operation")
 CALL text(6,48,"Seconds")
 CALL text(6,73,"Operation")
 CALL text(6,112,"Seconds")
 CALL text(7,6,"---------")
 CALL text(7,48,"---------")
 CALL text(7,73,"---------")
 CALL text(7,112,"---------")
 SET j = 7
 FOR (i = 1 TO benchmark_count)
  SET j = (j+ 1)
  IF (j <= 22)
   CALL text(j,3,concat(trim(cnvtstring(i),3),") ",trim(replace(benchmarks->benchmark[i].operation,
       cdomain,"",0),3)))
   CALL text(j,45,format(benchmarks->benchmark[i].value,cformat))
   IF (per_row(benchmarks->benchmark[i].operation))
    CALL text(j,57,"per row")
   ENDIF
  ELSE
   SET j = ((j - 22)+ 7)
   CALL text(j,70,concat(trim(cnvtstring(i),3),") ",trim(replace(benchmarks->benchmark[i].operation,
       cdomain,"",0),3)))
   CALL text(j,109,format(benchmarks->benchmark[i].value,cformat))
   IF (per_row(benchmarks->benchmark[i].operation))
    CALL text(j,122,"per row")
   ENDIF
   SET j = ((j+ 22) - 7)
  ENDIF
 ENDFOR
 SET j = 24
 SET flag = 1
 WHILE (flag)
   CALL text(j,1,fillstring(131," "))
   CALL text(j,3,"> Enter the line number of a benchmark to edit ('0' to exit):")
   CALL accept(j,65,"99",0)
   IF (curaccept)
    IF (curaccept <= benchmark_count)
     SET k = curaccept
     IF (((k+ 7) <= 22))
      CALL text((k+ 7),1,"->")
     ELSE
      CALL text((((k+ 7) - 22)+ 7),68,"->")
     ENDIF
     CALL text(j,72,"> New value ('0' to revert to default):")
     CALL accept(j,112,"N(8)",trim(format(benchmarks->benchmark[k].value,cformat),3))
     IF (update_benchmark(benchmarks->benchmark[k].tablespace,benchmarks->benchmark[k].operation,
      curaccept))
      SET benchmarks->benchmark[k].value = load_benchmark(benchmarks->benchmark[k].tablespace,
       benchmarks->benchmark[k].operation)
      IF (((k+ 7) <= 22))
       CALL text((k+ 7),48,trim(format(benchmarks->benchmark[k].value,cformat),3))
      ELSE
       CALL text((((k+ 7) - 22)+ 7),112,trim(format(benchmarks->benchmark[k].value,cformat),3))
      ENDIF
     ENDIF
     IF (((k+ 7) <= 22))
      CALL text((k+ 7),1,"  ")
     ELSE
      CALL text((((k+ 7) - 22)+ 7),68,"  ")
     ENDIF
    ENDIF
   ELSE
    SET flag = 0
   ENDIF
 ENDWHILE
#2499_edit_exit
#2500_capture
 IF (mode != ccapture)
  GO TO 2599_capture_exit
 ENDIF
 CALL clear(4,1)
 SET start_time = cnvtdatetime(curdate,curtime3)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 FREE SET tspaces
 RECORD tspaces(
   1 tspace[*]
     2 name = vc
     2 default = i2
 )
 SET tspace_count = 0
 CALL text(5,3,"In the following prompt, enter the name of a tablespace for which")
 CALL text(6,3,"benchmarks should be captured.  Enter 'DEFAULT' to capture default")
 CALL text(7,3,"benchmarks.  Enter 'ALL' to capture benchmarks for all tablespaces.")
 CALL text(9,3,"> Tablespace name: (shift F5 for help)")
 SET flag = 1
 WHILE (flag
  AND  NOT (tspace_count))
   SET help =
   SELECT INTO "nl:"
    u.tablespace_name
    FROM user_tablespaces u
    WHERE u.status="ONLINE"
     AND ((substring(1,2,u.tablespace_name)=cdata_prefix) OR (substring(1,2,u.tablespace_name)=
    cindex_prefix))
    ORDER BY substring(3,28,u.tablespace_name)
    WITH nocounter
   ;end select
   CALL accept(9,50,"P(30);CU")
   SET help = off
   IF (size(trim(curaccept,3)))
    SET work->tablespace = cnvtupper(trim(curaccept,3))
    CASE (work->tablespace)
     OF call_tablespaces:
      CALL working("Loading names of all tablespaces...")
      SELECT INTO "nl:"
       t.tablespace_name
       FROM user_tablespaces t
       WHERE t.tablespace_name="D_*"
        AND t.status="ONLINE"
        AND  EXISTS (
       (SELECT
        x.tablespace_name
        FROM user_tablespaces x
        WHERE x.tablespace_name=concat("I_",trim(substring(3,30,t.tablespace_name),3))
         AND x.status="ONLINE"))
       ORDER BY t.tablespace_name
       DETAIL
        tspace_count = (tspace_count+ 1), stat = alterlist(tspaces->tspace,tspace_count), tspaces->
        tspace[tspace_count].name = trim(substring(3,30,t.tablespace_name),3)
       WITH nocounter
      ;end select
      CALL working("")
     OF cdefault:
      SET tspace_count = 1
      SET stat = alterlist(tspaces->tspace,1)
      SET tspaces->tspace[1].default = 1
     ELSE
      IF (size(work->tablespace) > 2)
       IF (((substring(1,2,work->tablespace)=cdata_prefix) OR (substring(1,2,work->tablespace)=
       cindex_prefix)) )
        SET work->tablespace = substring(3,(size(work->tablespace) - 2),work->tablespace)
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       u.tablespace_name
       FROM user_tablespaces u
       WHERE u.tablespace_name=concat(cdata_prefix,work->tablespace)
        AND u.status="ONLINE"
       DETAIL
        tspace_count = 1, stat = alterlist(tspaces->tspace,1), tspaces->tspace[1].name = work->
        tablespace
       WITH nocounter
      ;end select
      IF ( NOT (curqual))
       CALL text(10,4,"The tablespace name entered is either invalid or offline.")
       CALL text(11,4,"Would you like to try another tablespace?  (Y/N)")
       CALL accept(11,60,"P;CU")
       IF (curaccept="N")
        GO TO 2000_main
       ENDIF
       CALL clear(10,1)
       CALL clear(11,1)
      ENDIF
    ENDCASE
   ELSE
    SET flag = 0
   ENDIF
 ENDWHILE
 IF ( NOT (tspace_count))
  GO TO 2599_capture_exit
 ENDIF
 CALL text(11,3,"> Enter the number of rows to add to sample table:")
 CALL accept(11,54,"9(6)",1000)
 SET rows = curaccept
 IF ( NOT (rows))
  GO TO 2599_capture_exit
 ENDIF
 SET tspace_index = 0
#2500_next
 SET tspace_index = (tspace_index+ 1)
 IF (tspace_index > tspace_count)
  CALL working("")
  CALL text(24,3,"Capture complete.  Capture benchmarks for another tablespace (Y/N)?")
  CALL accept(24,71,"P;CU","N"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="Y")
   GO TO 2500_capture
  ELSE
   GO TO 2599_capture_exit
  ENDIF
 ENDIF
#2510_generate_start
 SET work->dtablespace = concat(cdata_prefix,tspaces->tspace[tspace_index].name)
 SET work->itablespace = concat(cindex_prefix,tspaces->tspace[tspace_index].name)
 IF (tspaces->tspace[tspace_index].default)
  CALL dsb_get_tspace(null)
  SET work->dtablespace = def_ttspace
  SET work->itablespace = def_itspace
  SET work->log_itablespace = cdefault
  SET work->log_dtablespace = cdefault
 ELSE
  SET work->log_itablespace = work->itablespace
  SET work->log_dtablespace = work->dtablespace
 ENDIF
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"..."))
 SELECT INTO "nl:"
  t.table_name
  FROM user_tables t
  WHERE t.table_name=ctemp_table
  WITH nocounter
 ;end select
 IF (curqual)
  CALL parser(concat("rdb drop table ",ctemp_table," go"),1)
 ENDIF
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create temporary table"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb create table ",ctemp_table," (","n1 float, n2 float, n3 float, ",
   "s1 varchar2(80), s2 varchar2(80), s3 varchar2(80), ",
   "d1 date, d2 date, d3 date) "," tablespace ",work->dtablespace," go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,ccreate_table,start_time,stop_time,rows)
 IF (tspace_index <= 1)
  EXECUTE oragen3 ctemp_table
  SELECT INTO "nl:"
   p.object_name
   FROM dprotect p
   WHERE p.object="P"
    AND p.object_name="TMP_BENCH_LOAD"
   WITH nocounter
  ;end select
  IF (curqual)
   CALL parser("drop program TMP_BENCH_LOAD go",1)
  ENDIF
  CALL parser("create program TMP_BENCH_LOAD",1)
  CALL parser(concat("for (bl_i = 1 to ",trim(cnvtstring(rows),3),")"))
  CALL parser(concat("insert into ",ctemp_table),1)
  CALL parser("set n1 = bl_i,",1)
  CALL parser("    n2 = bl_i,",1)
  CALL parser("    n3 = 0,",1)
  CALL parser("    s1 = 'string1',",1)
  CALL parser("    s2 = 'string2',",1)
  CALL parser("    s3 = 'string3',",1)
  CALL parser("    d1 = cnvtdatetime(curdate, curtime3),",1)
  CALL parser("    d2 = cnvtdatetime(curdate, curtime3),",1)
  CALL parser("    d3 = cnvtdatetime(curdate, curtime3)",1)
  CALL parser("with nocounter",1)
  CALL parser("if (not mod(bl_i, 100))",1)
  CALL parser("commit",1)
  CALL parser("endif",1)
  CALL parser("endfor",1)
  CALL parser("commit",1)
  CALL parser("end go",1)
 ENDIF
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... load data into temporary table"))
 EXECUTE tmp_bench_load
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create non-unique index"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb create index xie1",ctemp_table," on ",ctemp_table," (s1) tablespace ",
   work->itablespace," go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,ccreate_index,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... drop non-unique index"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb drop index xie1",ctemp_table," go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,cdrop_index,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create unique index"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb create unique index xpk",ctemp_table," on ",ctemp_table," (n1) tablespace ",
   work->itablespace," go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,ccreate_unique_index,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create primary key constraint"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," add constraint xpk",ctemp_table,
   " primary key (n1) go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,cadd_primary_key,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create foreign key constraint"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," add constraint xfk1",ctemp_table,
   " foreign key (n3) ",
   "references code_value disable go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,cadd_foreign_key,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... add column"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," add (n4 float) go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,cadd_column,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... modify default value"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," modify (n4 float default 0) go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,cadd_default_value,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... populate default value"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser("rdb asis('declare')",1)
 CALL parser("asis('cursor c1 is')",1)
 CALL parser("asis('select rowid')",1)
 CALL parser(concat(^asis('from "^,ctemp_table,^"')^),1)
 CALL parser("asis(' where N4 is null') asis (';')",1)
 CALL parser("asis(' finished number:=0;')",1)
 CALL parser("asis(' err_num number;')",1)
 CALL parser("asis('begin')",1)
 CALL parser("asis('while (finished=0) loop')",1)
 CALL parser("asis('  finished:=1;')",1)
 CALL parser("asis('  begin')",1)
 CALL parser("asis('  for c1rec in c1 loop')",1)
 CALL parser(concat(^asis('    update "^,ctemp_table,^" set')^),1)
 CALL parser("asis(^  N4 = nvl(N4, 0)^)",1)
 CALL parser("asis('    where rowid = c1rec.rowid;')",1)
 CALL parser("asis('    commit;')",1)
 CALL parser("asis('  end loop;')",1)
 CALL parser("asis('  exception when others then')",1)
 CALL parser("asis('    err_num:=sqlcode;')",1)
 CALL parser("asis('    if (err_num=-1555 or err_num=1555) then')",1)
 CALL parser("asis('      finished:=0;')",1)
 CALL parser("asis('    end if;')",1)
 CALL parser("asis('  end;')",1)
 CALL parser("asis('end loop;')",1)
 CALL parser("asis('end;')",1)
 CALL parser("go",1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,cpopulate_default,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... add not null constraint"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," modify (n2 not null) go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,cadd_not_null_constraint,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... coalesce data tablespace"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter tablespace ",work->dtablespace," coalesce go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,ccoalesce,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... coalesce index tablespace"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter tablespace ",work->itablespace," coalesce go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,ccoalesce,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... drop constraint"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," drop constraint xpk",ctemp_table," go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_itablespace,cdrop_constraint,start_time,stop_time,rows)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... modify datatype"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser(concat("rdb alter table ",ctemp_table," modify (n2 float) go"),1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL log_time(work->log_dtablespace,cmodify_column,start_time,stop_time,rows)
 IF (substring(1,5,work->ora_complete_version) >= "8.1.7")
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... create non-unique index online"))
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat("rdb create index xie1",ctemp_table," on ",ctemp_table," (s1) tablespace ",
    work->itablespace," online go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,ccreate_index_online,start_time,stop_time,rows)
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... rename index"))
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat("rdb alter index xie1",ctemp_table," rename to xit1",ctemp_table," go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,crename_index,start_time,stop_time,rows)
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... create unique index online"))
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat("rdb create unique index xpk",ctemp_table," on ",ctemp_table," (n1) tablespace ",
    work->itablespace," online go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,ccreate_unique_index_online,start_time,stop_time,rows)
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... add not null constraint novalidate"))
  CALL parser(concat("rdb alter table ",ctemp_table," modify n2 null go"),1)
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat("rdb alter table ",ctemp_table," modify n2 not null enable novalidate go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,cadd_not_null_constraint_novalidate,start_time,stop_time,rows)
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... get not null constraint name"))
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat(
    "select into 'nl:' u.constraint_name from user_constraints u, user_cons_columns uc ",
    "plan u where u.table_name = '",ctemp_table,"' and u.constraint_type = 'C'",
    " and u.status = 'ENABLED' and u.validated = 'NOT VALIDATED'",
    " join uc where u.constraint_name = uc.constraint_name and uc.column_name = 'N2'",
    " detail work->cons_name = u.constraint_name go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,cget_not_null_constraint_name,start_time,stop_time,rows)
  CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
    trim(cnvtstring(tspace_count),3),"... enable not null constraint"))
  SET start_time = cnvtdatetime(curdate,curtime3)
  CALL parser(concat("rdb alter table ",ctemp_table," enable constraint ",work->cons_name," go"),1)
  SET stop_time = cnvtdatetime(curdate,curtime3)
  CALL log_time(work->log_itablespace,cenable_not_null_constraint,start_time,stop_time,rows)
 ENDIF
 CALL parser(concat("rdb drop table ",ctemp_table," go"),1)
 CALL working(concat("Generating benchmarks for tablespace ",trim(cnvtstring(tspace_index),3)," of ",
   trim(cnvtstring(tspace_count),3),"... create sequence"))
 SET start_time = cnvtdatetime(curdate,curtime3)
 CALL parser("rdb create sequence BENCHMARK_TEMP go",1)
 SET stop_time = cnvtdatetime(curdate,curtime3)
 CALL parser("rdb drop sequence BENCHMARK_TEMP go",1)
 CALL log_time(cdefault,ccreate_sequence,start_time,stop_time,1)
#2590_generate_end
 GO TO 2500_next
#2599_capture_exit
#9999_exit_program
 CALL clear(1,1)
END GO
