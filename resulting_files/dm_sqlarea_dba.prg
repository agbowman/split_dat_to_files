CREATE PROGRAM dm_sqlarea:dba
 DROP DDLRECORD v_$sqltext FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD v_$sqltext FROM DATABASE v500
 TABLE v_$sqltext
  1 address  = gc4 CCL(address)
  1 hash_value  = f8 CCL(hash_value)
  1 piece  = f8 CCL(piece)
  1 sql_text  = vc64 CCL(sql_text)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE v_$sqltext
 SET ratio = 0.0
 SET executions = 0.0
 SET buffer_gets = 0.0
 SELECT
  a.buffer_gets, a.executions, a.first_load_time,
  a.sql_text, t.address, t.hash_value,
  t.piece, t.sql_text
  FROM (sys.v_$sqltext t),
   v$sqlarea a
  WHERE a.sql_text != patstring("*V$SQLAREA*")
   AND ((a.sql_text=patstring( $1)) OR (((a.sql_text=patstring(cnvtupper( $1))) OR (a.sql_text=
  patstring(cnvtlower( $1)))) ))
   AND a.buffer_gets > 0
   AND t.hash_value=a.hash_value
  ORDER BY a.buffer_gets DESC, t.address, t.hash_value,
   t.piece
  HEAD REPORT
   line1 = fillstring(110,"*")
  DETAIL
   IF (t.piece=0)
    col 0, line1, row + 1,
    col 0, "BUFFER GETS: ", a.buffer_gets,
    "  EXECUTIONS: ", a.executions, "  RATIO: ",
    buffer_gets = a.buffer_gets, executions = a.executions, ratio = (buffer_gets/ executions),
    ratio, "  FIRST LOAD TIME: ", a.first_load_time,
    row + 1
   ENDIF
   col 10, t.sql_text, row + 1
  WITH counter
 ;end select
END GO
