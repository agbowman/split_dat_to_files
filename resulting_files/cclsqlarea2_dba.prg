CREATE PROGRAM cclsqlarea2:dba
 PROMPT
  "Enter output name                (MINE)  : " = "MINE",
  "Enter program to search in sqlarea  (*)  : " = "*",
  "Enter minimum average bufgets       (0)  : " = 0,
  "Sort by (B)uffget (T)ext (E)xecutes (B)  : " = "B",
  "Begin Load time  (yyyy-mm-dd/hh:mm:ss)   : " = " "
 SET load_time =  $5
 SET var = concat("*+ *<",cnvtupper(trim( $2)),"*")
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
  t.piece, t.sql_text, s.sql_text,
  s.buffer_gets, s.disk_reads, s.parse_calls,
  s.loads, s.executions, s.users_executing,
  s.sorts, s.first_load_time, s.parsing_user_id
  FROM (sys.v_$sqltext t),
   v$sqlarea s
  WHERE s.sql_text=patstring(var)
   AND (s.buffer_gets >=  $3)
   AND (t.hash_value= Outerjoin(s.hash_value))
   AND s.sql_text != "*CCLSQLAREA*"
   AND s.executions >= 0
   AND (s.buffer_gets >= ( $3 * s.executions))
   AND s.first_load_time >= load_time
  HEAD REPORT
   line = fillstring(130,"="), sep = fillstring(130,"*"), "CCLSQLAREA report for search string of (",
    $2, ")", row + 1,
   line, row + 1, cnt = 0
  DETAIL
   IF (t.piece=0)
    IF (mod(cnt,2)=1)
     row + 1
    ENDIF
    sep, row + 1, cnt = 0
   ENDIF
   cnt += 1
   IF (mod(cnt,2)=1)
    col 0, t.sql_text
   ELSE
    col 64, t.sql_text, row + 1
   ENDIF
  FOOT REPORT
   row + 1, sep
  WITH maxcol = 200, heading = 4, noformfeed,
   maxrow = 1
 ;end select
END GO
