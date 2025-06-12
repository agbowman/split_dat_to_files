CREATE PROGRAM dm_sqlplan_child
 SET width = 132
 IF (validate(call_prog,"x")="x")
  SET call_prog = "x"
  CALL echo("**************************************************************")
  CALL echo("")
  CALL echo("This program can only be called from DM_SQLAPLAN or CCLSQLAREA")
  CALL echo("")
  CALL echo("**************************************************************")
  GO TO done
 ENDIF
 SET r = fillstring(132," ")
 SET s = fillstring(132," ")
 SET t = fillstring(132," ")
 SET w1 = fillstring(132," ")
 SET w2 = fillstring(132," ")
 IF (( $2 > " "))
  SET script_name = build("*",cnvtupper(trim( $2)),"*")
 ELSE
  SET script_name = "*"
 ENDIF
 SET load_time =  $4
 IF (call_prog="CCLSQLAREA")
  IF (( $3="B"))
   SET r = "a.buffer_gets/a.executions"
   SET s = "a.address"
   SET t = "0"
  ELSE
   SET r = "substring(1,60,a.sql_text)"
   SET s = "a.address"
   SET t = "0"
  ENDIF
  SET w1 = build("a.buffer_gets >=", $1)
  SET w2 = build("a.buffer_gets/a.executions >=", $1)
 ELSE
  SET w1 = "a.buffer_gets > 0"
  SET w2 = "a.executions  > 0"
  IF ((validate(script_num,- (1))=- (1)))
   DECLARE script_num = i4
  ENDIF
  IF (( $1 > 0))
   SET script_num =  $1
  ELSE
   GO TO done
  ENDIF
  IF (((( $3=1)) OR (( $3=0))) )
   SET r = "a.buffer_gets"
   SET s = "a.disk_reads"
   SET t = "a.address"
  ELSEIF (( $3=2))
   SET r = "a.disk_reads"
   SET s = "a.buffer_gets"
   SET t = "a.address"
  ELSEIF (( $3=3))
   SET r = "ratio"
   SET s = "a.buffer_gets"
   SET t = "a.disk_reads"
  ELSEIF (( $3=4))
   SET r = "a.executions"
   SET s = "a.buffer_gets"
   SET t = "a.disk_reads"
  ELSEIF (( $3=5))
   SET r = "A_SCORE"
   SET s = "a.buffer_gets"
   SET t = "a.disk_reads"
  ENDIF
 ENDIF
 DECLARE cnt = i4
 CALL echo("Working...")
 RECORD str(
   1 str = vc
 )
 SELECT
  IF (call_prog="CCLSQLAREA")
   ORDER BY parser(r) DESC, parser(s)
  ELSE
   ORDER BY parser(r) DESC, parser(s) DESC, parser(t)
  ENDIF
  INTO "nl:"
  a.address, a.buffer_gets, a.executions,
  a.disk_reads, a.first_load_time, ratio = (a.buffer_gets/ a.executions),
  dratio = (a.disk_reads/ a.executions), a.sql_text, a.hash_value,
  a_score = ((a.buffer_gets+ (a.executions * 200))+ (a.disk_reads * 200))
  FROM v$sqlarea a
  WHERE a.buffer_gets > 0
   AND a.executions > 0
   AND parser(w1)
   AND parser(w2)
   AND a.first_load_time >= load_time
   AND a.sql_text != "*CCLSQLAREA*"
   AND a.sql_text != "*DM_SQLAREA*"
   AND a.sql_text != "*DM_SQLPLAN*"
   AND a.sql_text != "*DM_SQL_PLAN*"
   AND a.sql_text != "*V$SQLAREA*"
   AND a.sql_text != "*PLAN_TABLE*"
   AND ((a.sql_text=patstring(script_name)) OR (((a.sql_text=patstring(cnvtupper(script_name))) OR (a
  .sql_text=patstring(cnvtlower(script_name)))) ))
  HEAD REPORT
   sql_text->text_cnt = 0, script_cnt = 0
  DETAIL
   script_cnt = (script_cnt+ 1)
   IF (call_prog="CCLSQLAREA")
    script_num = script_cnt
   ENDIF
   IF (script_cnt <= script_num)
    sql_text->text_cnt = (sql_text->text_cnt+ 1), stat = alterlist(sql_text->qual,sql_text->text_cnt),
    sql_text->qual[sql_text->text_cnt].piece_cnt = 0,
    sql_text->qual[sql_text->text_cnt].address = a.address, sql_text->qual[sql_text->text_cnt].
    hash_value = a.hash_value, sql_text->qual[sql_text->text_cnt].buff = a.buffer_gets,
    sql_text->qual[sql_text->text_cnt].exec = a.executions, sql_text->qual[sql_text->text_cnt].disk
     = a.disk_reads, sql_text->qual[sql_text->text_cnt].first_time = a.first_load_time,
    sql_text->qual[sql_text->text_cnt].rat = ratio, sql_text->qual[sql_text->text_cnt].drat = dratio,
    sql_text->qual[sql_text->text_cnt].parse_calls = a.parse_calls,
    sql_text->qual[sql_text->text_cnt].loads = a.loads, sql_text->qual[sql_text->text_cnt].
    users_executing = a.users_executing, sql_text->qual[sql_text->text_cnt].sorts = a.sorts,
    sql_text->qual[sql_text->text_cnt].parsing_user_id = a.parsing_user_id, sql_text->qual[sql_text->
    text_cnt].stmt_flag = 0, sql_text->qual[sql_text->text_cnt].score = a_score,
    sql_text->qual[sql_text->text_cnt].stmt_len = textlen(trim(a.sql_text)), sql_text->qual[sql_text
    ->text_cnt].stmt = trim(a.sql_text), sql_text->qual[sql_text->text_cnt].sharable_mem = a
    .sharable_mem,
    sql_text->qual[sql_text->text_cnt].cpu_time = validate(a.cpu_time,- (1)), sql_text->qual[sql_text
    ->text_cnt].optimizer_mode = trim(a.optimizer_mode)
    IF ((sql_text->qual[sql_text->text_cnt].stmt_len >= 990))
     sql_text->qual[sql_text->text_cnt].stmt_flag = 1
    ENDIF
    str->str = " "
   ENDIF
  FOOT REPORT
   row + 0
  WITH counter, maxcol = 32000
 ;end select
 IF (size(sql_text->qual,5) > 0)
  SELECT INTO "nl:"
   t.address, t.hash_value, t.sql_text,
   t.piece
   FROM (sys.v_$sqltext t),
    (dummyt d  WITH seq = value(size(sql_text->qual,5)))
   PLAN (d
    WHERE (sql_text->qual[d.seq].stmt_len >= 990))
    JOIN (t
    WHERE (((t.hash_value=sql_text->qual[d.seq].hash_value)) OR ((t.address=sql_text->qual[d.seq].
    address)))
     AND t.sql_text=substring(1,64,sql_text->qual[d.seq].stmt)
     AND t.piece=0)
   ORDER BY t.hash_value, t.piece
   DETAIL
    sql_text->qual[d.seq].stmt = " ", sql_text->qual[d.seq].hash_value = t.hash_value, sql_text->
    qual[d.seq].stmt_flag = 0
   WITH counter, maxcol = 32000
  ;end select
 ENDIF
 IF (size(sql_text->qual,5) > 0)
  SELECT INTO "nl:"
   t.address, t.hash_value, t.sql_text,
   t.piece
   FROM (sys.v_$sqltext t),
    (dummyt d  WITH seq = value(size(sql_text->qual,5)))
   PLAN (d
    WHERE (sql_text->qual[d.seq].stmt_len >= 990))
    JOIN (t
    WHERE (t.hash_value=sql_text->qual[d.seq].hash_value))
   ORDER BY t.hash_value, t.piece
   HEAD t.hash_value
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(sql_text->qual[d.seq].qual,pcnt), sql_text->qual[d.seq].qual[
    pcnt].text = t.sql_text
   FOOT  t.hash_value
    FOR (z = 1 TO pcnt)
      need_a_space = 0
      IF (z > 1)
       IF (substring(64,1,sql_text->qual[d.seq].qual[(z - 1)].text)=" ")
        need_a_space = 1
       ENDIF
      ENDIF
      IF (need_a_space=1)
       sql_text->qual[d.seq].stmt = concat(sql_text->qual[d.seq].stmt," ",sql_text->qual[d.seq].qual[
        z].text)
      ELSE
       sql_text->qual[d.seq].stmt = concat(sql_text->qual[d.seq].stmt,sql_text->qual[d.seq].qual[z].
        text)
      ENDIF
    ENDFOR
    sql_text->qual[d.seq].piece_cnt = pcnt
   WITH counter, maxcol = 32000
  ;end select
 ENDIF
#done
END GO
