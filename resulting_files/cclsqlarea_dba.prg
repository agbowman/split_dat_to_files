CREATE PROGRAM cclsqlarea:dba
 PROMPT
  "Enter output name                 (MINE) : " = "MINE",
  "Enter program to search in sqlarea   (*) : " = "*",
  "Enter minimum average bufgets      (200) : " = 200,
  "Sort by (B)uffget (T)ext (E)xecutes  (B) : " = "B",
  "Begin Load time    (yyyy-mm-dd/hh:mm:ss) : " = ""
 SET load_time =  $5
 SET var = concat("*+ *<",cnvtupper(trim( $2)),"*")
 SET min_bufget =  $3
 SELECT
  IF (cnvtupper( $4)="B")
   ORDER BY (s.buffer_gets/ s.executions) DESC, t.address, t.hash_value,
    t.piece, 0
  ELSEIF (cnvtupper( $4)="E")
   ORDER BY s.executions DESC, t.address, t.hash_value,
    t.piece
  ELSE
   ORDER BY substring(1,60,s.sql_text), t.address, t.hash_value,
    t.piece
  ENDIF
  INTO trim( $1)
  t.sql_text, s.sql_text, s.buffer_gets,
  s.disk_reads, s.parse_calls, s.loads,
  s.executions, s.users_executing, s.sorts,
  s.first_load_time, s.parsing_user_id
  FROM v$sqltext t,
   v$sqlarea s
  WHERE s.parsing_user_id != 0
   AND s.sql_text=patstring(var)
   AND s.buffer_gets >= min_bufget
   AND (t.hash_value= Outerjoin(s.hash_value))
   AND s.executions > 0
   AND (s.buffer_gets >= (min_bufget * s.executions))
   AND s.first_load_time >= load_time
   AND s.sql_text != "*SQLAREA*"
   AND s.sql_text != "*SQLPLAN*"
   AND s.sql_text != "*PLAN_TABLE*"
  HEAD REPORT
   line = fillstring(130,"="), sep = fillstring(130,"*"), "CCLSQLAREA report for search string of (",
    $2, ")", row + 1,
   "(AvgBufGets  )  BufferGets  DiskReads       Executes  UserExecutes  ParserCalls  Loads   Sorts UserId  LoadTime",
   row + 1, line,
   row + 1, cnt = 0
  DETAIL
   IF (t.piece=0)
    IF (mod(cnt,2)=1)
     row + 1
    ENDIF
    cnt = 0, sep, row + 1,
    av = (s.buffer_gets/ s.executions), av"(############)", col + 1,
    s.buffer_gets"###########", s.disk_reads"##########", col + 5,
    s.executions"##########", s.users_executing"#######", col + 5,
    s.parse_calls"##########", s.loads"##########", col + 2,
    s.sorts"#######", s.parsing_user_id"#####", col + 5,
    s.first_load_time, row + 1
   ENDIF
   cnt += 1
   IF (cnt=1
    AND t.sql_text=" ")
    vpos = 1
    WHILE (vpos < 1000)
     IF (substring(vpos,64,s.sql_text) != " ")
      col 0,
      CALL print(substring(vpos,64,s.sql_text)), row + 1
     ENDIF
     ,vpos += 64
    ENDWHILE
    col 0, "<sql_text not found on v_$sqltext table, used v$sqlarea>", row + 1
   ELSE
    IF (mod(cnt,2)=1)
     col 0, t.sql_text
    ELSE
     col 64, t.sql_text, row + 1
    ENDIF
   ENDIF
  WITH maxcol = 200, heading = 4, noformfeed,
   maxrow = 1
 ;end select
END GO
