CREATE PROGRAM dm_import_outlines:dba
 IF (currdb="DB2UDB")
  CALL echo("** Auto Exit for DB2 **")
  GO TO exit_immediately
 ENDIF
 DECLARE cont = i2
 DECLARE i_min_table = i4
 DECLARE i_min_index = i4
 DECLARE fix_sql_file(fn=vc) = i2
 DECLARE check_tablespace(ts_type=vc,ts_default=vc) = i2
 DECLARE check_for_tablespace(ts_name=vc) = i2
 DECLARE check_ts_size(ts_name=vc) = f8
 DECLARE move_indexes(d=i2) = i2
 DECLARE create_vms_compile_files(d=vc) = i2
 DECLARE create_aix_compile_files(d=vc) = i2
 DECLARE export_outlines(i=i2) = i2
 DECLARE build_tables(i=i2) = i2
 RECORD temp(
   1 choice = vc
   1 temp1 = vc
   1 file_full_path = vc
   1 cnct_str = vc
   1 ts_table = vc
   1 ts_table_old = vc
   1 ts_index = vc
   1 ts_index_old = vc
   1 com_file = vc
   1 err_msg = vc
   1 chose_exit = i2
 )
 RECORD indexes(
   1 qual[*]
     2 name = vc
 )
 SET i_min_index = 30
 SET i_min_table = 295
 SET temp->chose_exit = 0
 SELECT INTO "nl:"
  d.info_number, e.v500_connect_string
  FROM dm_info d,
   dm_environment e
  PLAN (d
   WHERE d.info_domain=cnvtupper("DATA MANAGEMENT")
    AND d.info_name="DM_ENV_ID")
   JOIN (e
   WHERE e.environment_id=d.info_number)
  DETAIL
   temp->cnct_str = e.v500_connect_string
  WITH nocounter
 ;end select
 SET temp->cnct_str = substring(findstring("@",temp->cnct_str),textlen(temp->cnct_str),temp->cnct_str
  )
 SET width = 132
 SET message = window
 CALL clear(1,1)
 CALL text(3,2,"OL$ and OL$HINTS will be exported and the contents deleted.")
 CALL text(4,2,"Do you wish to continue (Y/N) ")
 CALL accept(4,31,"A(1);CU","Y")
 SET temp->choice = trim(curaccept,3)
 SET message = nowindow
 IF ((temp->choice != "Y"))
  GO TO exit_script
 ENDIF
 CALL echo("Gathering system information")
 SELECT INTO "nl:"
  d.tablespace_name
  FROM dba_tables d
  WHERE d.table_name="OL$"
  DETAIL
   temp->ts_table = trim(d.tablespace_name,3), temp->ts_table_old = trim(d.tablespace_name,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.segment_name, d.tablespace_name
  FROM dba_segments d
  WHERE d.segment_name="OL$*"
   AND d.segment_type="INDEX"
  HEAD REPORT
   cnt = 0
  DETAIL
   temp->ts_index = trim(d.tablespace_name,3), temp->ts_index_old = trim(d.tablespace_name,3), cnt =
   (cnt+ 1),
   stat = alterlist(indexes->qual,cnt), indexes->qual[cnt].name = trim(d.segment_name,3)
  WITH nocounter
 ;end select
 CALL export_outlines(0)
 SET width = 132
 SET message = window
 CALL clear(1,1)
 SET cont = 0
 CALL text(3,2,"Please enter the directory where the outline.dmp file is located or E[X]it.")
 WHILE (cont=0)
   CALL accept(4,2,"P(128);C")
   SET temp->choice = trim(curaccept,3)
   IF ((temp->choice="X"))
    SET temp->chose_exit = 1
    GO TO exit_script
   ENDIF
   IF (cnvtupper(substring((textlen(temp->choice) - 3),4,temp->choice)) != ".DMP")
    SET temp->choice = concat(temp->choice,"outline.dmp")
   ENDIF
   IF (findfile(temp->choice)=0)
    SET cont = 0
    CALL text(2,2,"Invalid file name. Please make sure you have a fully qualified path.")
   ELSE
    SET cont = 1
    SET temp->file_full_path = concat("$",temp->choice)
    SET temp->file_full_path = temp->choice
   ENDIF
 ENDWHILE
 CALL clear(2,2,128)
 IF ((temp->ts_table="SYSTEM"))
  CALL text(5,2,"Please enter a tablespace name to place OL$ and OL$HINTS or E[X]it")
  CALL check_tablespace("TABLES","D_OUTLINE")
 ELSE
  IF (check_ts_size(temp->ts_table) < i_min_table)
   CALL text(5,2,"Please enter a tablespace name to place OL$ and OL$HINTS or E[X]it")
   CALL check_tablespace("TABLES","D_OUTLINE")
  ENDIF
 ENDIF
 CALL clear(2,2,128)
 IF ((temp->ts_index="SYSTEM"))
  CALL text(7,2,"Please enter a tablespace name to place indexes or E[X]it")
  CALL check_tablespace("INDEX","D_OUTLINE")
 ELSE
  IF (check_ts_size(temp->ts_index) < i_min_index)
   CALL text(7,2,"Please enter a tablespace name to place indexes or E[X]it")
   CALL check_tablespace("INDEX","D_OUTLINE")
  ENDIF
 ENDIF
 CALL clear(1,1)
 SET message = nowindow
 CALL echo("Importing data........")
 CALL build_tables(0)
 IF (cursys="AIX")
  CALL move_indexes(0)
  SET temp->temp1 = concat("$ORACLE_HOME/bin/imp OUTLN/OUTLN",temp->cnct_str," FILE=",temp->
   file_full_path," TABLES='OL$' 'OL$HINTS' ",
   "IGNORE=Y BUFFER=1200000 SILENT=Y")
  CALL echo(temp->temp1)
  SET stat = exec_cmd(temp->temp1)
 ELSE
  CALL move_indexes(0)
  SET temp->temp1 = concat("$IMP OUTLN/OUTLN",temp->cnct_str," FILE=",temp->file_full_path,
   " TABLES=OL$ OL$HINTS ",
   "IGNORE=Y BUFFER=1200000 SILENT=Y")
  CALL echo(temp->temp1)
  CALL create_vms_compile_files(temp->temp1)
  IF (exec_cmd(temp->com_file)=0)
   CALL echo("Failed executing import")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE build_tables(i)
   IF (cursys="AIX")
    SET temp->temp1 = concat("$ORACLE_HOME/bin/imp OUTLN/OUTLN",temp->cnct_str,
     " FILE=$CCLUSERDIR/outline_local.dmp"," indexfile=$CCLUSERDIR/outline_temp.sql",
     " silent=y ignore=y full=y")
    CALL echo(temp->temp1)
    SET stat = exec_cmd(temp->temp1)
    CALL create_aix_compile_files("$CCLUSERDIR/outline_temp.sql")
    CALL fix_sql_file("ccluserdir:outline_temp.sql")
    SET temp->temp1 = concat("RDB ALTER USER OUTLN DEFAULT TABLESPACE ",temp->ts_table)
    CALL echo(temp->temp1)
    CALL parser(temp->temp1)
    SET temp->temp1 = concat("$ORACLE_HOME/bin/sqlplus OUTLN/OUTLN",temp->cnct_str,
     " @$CCLUSERDIR/outline.sql")
    CALL echo(temp->temp1)
    SET stat = exec_cmd(temp->temp1)
   ELSE
    SET temp->temp1 = concat("$IMP OUTLN/OUTLN",temp->cnct_str," FILE=",
     "ccluserdir:outline_local.dmp"," indexfile=ccluserdir:outline_temp.sql",
     " silent=y ignore=y full=y")
    CALL echo(temp->temp1)
    CALL create_vms_compile_files(temp->temp1)
    IF (exec_cmd(temp->com_file)=0)
     CALL echo("Failed executing import index file")
     GO TO exit_script
    ENDIF
    CALL fix_sql_file("ccluserdir:outline_temp.sql")
    SET temp->temp1 = concat("RDB ALTER USER OUTLN DEFAULT TABLESPACE ",temp->ts_table)
    CALL echo(temp->temp1)
    CALL parser(temp->temp1)
    SET temp->temp1 = concat("$SQLPLUS OUTLN/OUTLN",temp->cnct_str," @ccluserdir:outline.sql")
    CALL echo(temp->temp1)
    CALL create_vms_compile_files(temp->temp1)
    IF (exec_cmd(temp->com_file)=0)
     CALL echo("Failed executing sqlplus")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_cmd(e_cmd)
   SET e_flag = 0
   CALL dcl(e_cmd,size(e_cmd),e_flag)
   RETURN(e_flag)
 END ;Subroutine
 SUBROUTINE create_vms_compile_files(d)
   SET temp->com_file = concat("ccluserdir:dm",format(curtime3,"hhmmsscc;3;m"),".com")
   SELECT INTO value(temp->com_file)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     CALL print(d), row + 1,
     CALL print("$exit"),
     row + 1
    WITH nocounter, format = variable, maxrow = 1,
     noformfeed, maxcol = 500
   ;end select
   CALL echo(d)
   SET temp->com_file = concat("@",temp->com_file)
 END ;Subroutine
 SUBROUTINE fix_sql_file(fn)
   DECLARE temp_str = vc
   DECLARE file_name = vc
   DECLARE file_new = vc
   DECLARE str = vc
   DECLARE i_first = i4
   DECLARE ct_found = i2
   DECLARE ci_found = i2
   DECLARE i_ts = i4
   DECLARE i_beg = i4
   DECLARE i_end = i4
   DECLARE killrow = i2
   SET file_new = "outline.sql"
   IF (fn != "")
    SET logical file_name value(fn)
    FREE DEFINE rtl2
    DEFINE rtl2 "file_name"
    SELECT INTO value(file_new)
     t.line
     FROM rtl2t t
     HEAD REPORT
      ct_found = 0, ci_found = 0
     DETAIL
      killrow = 0, i_beg = 0, i_end = 0,
      i_ts = 0, str = trim(t.line,3)
      IF (i_first=0)
       IF (findstring("CREATE TABLE",str,0) > 0)
        i_first = 1
       ENDIF
      ENDIF
      IF (findstring("REM  ... 0 rows",str,0) > 0)
       killrow = 1
      ENDIF
      IF (substring(1,3,str)="REM"
       AND killrow=0)
       str = substring(4,(textlen(str) - 3),str)
      ENDIF
      IF (findstring("CONNECT OUTLN;",str,0) > 0)
       killrow = 1
      ELSEIF (findstring("skipping table",str,0) > 0)
       killrow = 1
      ELSEIF (findstring(". importing OUTLN's objects into OUTLN",str,0) > 0)
       killrow = 1
      ELSEIF (findstring("import done in US7ASCII character set and US7ASCII NCHAR character set",str,
       0) > 0)
       killrow = 1
      ELSEIF (findstring("Export file created by",str,0) > 0)
       killrow = 1
      ENDIF
      IF (i_first != 0
       AND killrow=0)
       str = replace(str,'"',"",0)
       IF (findstring("CREATE TABLE",str,0) > 0)
        ct_found = 1, ci_found = 0
       ELSEIF (findstring("CREATE UNIQUE INDEX",str,0) > 0)
        ct_found = 0, ci_found = 1
       ENDIF
       IF (ci_found=1)
        str = replace(str,temp->ts_table_old,temp->ts_table,0)
       ELSEIF (ct_found=1)
        str = replace(str,temp->ts_index_old,temp->ts_index,0)
       ENDIF
       col 0, str, row + 1
      ENDIF
     FOOT REPORT
      row + 1, col 0, "exit"
     WITH nocounter, noformfeed, maxcol = 2100
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE check_tablespace(ts_type,ts_default)
   DECLARE i_min = i4
   IF (ts_type="INDEX")
    SET i_min = i_min_index
   ELSE
    SET i_min = i_min_table
   ENDIF
   SET cont = 0
   WHILE (cont=0)
     IF (ts_type="INDEX")
      CALL accept(8,2,"P(30);CU",ts_default)
     ELSE
      CALL accept(6,2,"P(30);CU",ts_default)
     ENDIF
     SET temp->choice = trim(curaccept,3)
     IF ((temp->choice="X"))
      SET temp->chose_exit = 1
      GO TO exit_script
     ENDIF
     IF (check_for_tablespace(temp->choice)=0)
      SET cont = 0
      CALL clear(2,2,128)
      CALL text(2,2,"Invalid tablespace name!")
     ELSE
      IF (check_ts_size(temp->choice) < i_min)
       SET cont = 0
       CALL clear(2,2,128)
       CALL text(2,2,"Not enough free space in tablespace!")
      ELSE
       SET cont = 1
       IF (ts_type="INDEX")
        SET temp->ts_index = temp->choice
       ELSE
        SET temp->ts_table = temp->choice
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE check_for_tablespace(ts_name)
  SELECT INTO "nl:"
   d.status
   FROM dba_tablespaces d
   WHERE d.tablespace_name=ts_name
   WITH nocounter
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE check_ts_size(ts_name)
   DECLARE bytes_total = f8
   SELECT INTO "nl:"
    bytes_ttl = sum(bytes)
    FROM dba_free_space
    WHERE tablespace_name=ts_name
    DETAIL
     bytes_total = bytes_ttl
    WITH nocounter
   ;end select
   SET bytes_total = (bytes_total/ 1048576)
   RETURN(bytes_total)
 END ;Subroutine
 SUBROUTINE move_indexes(d)
   FOR (x = 1 TO value(size(indexes->qual,5)))
     SET temp->temp1 = concat("RDB ALTER INDEX ",indexes->qual[x].name," rebuild tablespace ",temp->
      ts_index)
     CALL echo(temp->temp1)
     CALL parser(temp->temp1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE create_aix_compile_files(file_name)
   DECLARE str = c200
   SET str = concat("chmod 777 ",file_name)
   CALL echo(str)
   CALL exec_cmd(trim(str,3))
 END ;Subroutine
 SUBROUTINE export_outlines(i)
   DECLARE exp_err_msg = i4
   CALL echo("Truncating OL$* tables")
   SET temp->temp1 = "RDB TRUNCATE TABLE OUTLN.OL$HINTS GO"
   CALL echo(temp->temp1)
   CALL parser(temp->temp1)
   SET temp->temp1 = "RDB TRUNCATE TABLE OUTLN.OL$ GO"
   CALL echo(temp->temp1)
   CALL parser(temp->temp1)
   CALL echo("Exporting tables...")
   IF (cursys="AIX")
    SET temp->temp1 = concat("$ORACLE_HOME/bin/exp OUTLN/OUTLN",temp->cnct_str,
     " FILE=$CCLUSERDIR/outline_local.dmp"," TABLES='OL$','OL$HINTS' SILENT=y ROWS=N COMPRESS=N")
    CALL echo(temp->temp1)
    IF (exec_cmd(temp->temp1)=0)
     CALL echo("Failed executing export")
     GO TO exit_script
    ENDIF
   ELSE
    SET temp->temp1 = concat("$EXP OUTLN/OUTLN",temp->cnct_str," FILE=ccluserdir:outline_local.dmp",
     " TABLES=(OL$,OL$HINTS) SILENT=y ROWS=N COMPRESS=N")
    CALL echo(temp->temp1)
    CALL create_vms_compile_files(temp->temp1)
    SET exp_err_msg = exec_cmd(temp->com_file)
    IF (exp_err_msg=0)
     CALL echo("Failed executing export")
     CALL echo(exp_err_msg)
     GO TO exit_script
    ENDIF
   ENDIF
   IF (error(temp->err_msg,0) > 0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(2,2,"Exporting has errors. Do you wish to continue (Y/N)")
    CALL accept(3,2,"A(1);CU","Y")
    SET temp->choice = trim(curaccept,3)
    CALL clear(1,1)
    SET message = nowindow
    IF ((temp->choice="N"))
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo("Dropping tables...")
   CALL parser("RDB DROP TABLE OUTLN.OL$HINTS go")
   CALL parser("RDB DROP TABLE OUTLN.OL$ go")
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF ((temp->chose_exit=1))
  CALL build_tables(0)
 ENDIF
#exit_immediately
END GO
