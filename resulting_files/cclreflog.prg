CREATE PROGRAM cclreflog
 PAINT
  text(1,10,"CclRefLog Report"), box(2,1,12,80), text(4,3,"Sort by desc date(Y/N)"),
  text(6,3,"View parameters(Y/N)"), text(8,3,"	Ref Table"), accept(4,30,"A;CU","N"),
  accept(6,30,"A;CU","N"), accept(8,30,"p(30);CU",char(42))
 SELECT
  IF (( $1="Y")
   AND ( $2="Y"))
   l.*, ref_text = b.ref_text, ref_bind_num = b.ref_bind_num,
   param_num = b.param_num
   FROM ccl_ref_logging l,
    ccl_ref_logging_bind b
   PLAN (l)
    JOIN (b
    WHERE (b.ref_id= Outerjoin(l.ref_id))
     AND l.ref_table=patstring( $3))
   ORDER BY l.ref_id DESC, b.ref_bind_num, b.param_num
  ELSEIF (( $1="Y"))
   l.*, ref_bind_num = 0, param_num = 0,
   ref_text = " "
   FROM ccl_ref_logging l
   PLAN (l
    WHERE l.ref_table=patstring( $3))
   ORDER BY l.ref_id DESC
  ELSEIF (( $2="Y"))
   l.*, ref_text = b.ref_text, ref_bind_num = b.ref_bind_num,
   param_num = b.param_num
   FROM ccl_ref_logging l,
    ccl_ref_logging_bind b
   PLAN (l)
    JOIN (b
    WHERE (b.ref_id= Outerjoin(l.ref_id))
     AND l.ref_table=patstring( $3))
  ELSE
   l.*, ref_bind_num = 0, param_num = 0,
   ref_text = " "
   FROM ccl_ref_logging l
   PLAN (l
    WHERE l.ref_table=patstring( $3))
  ENDIF
  HEAD REPORT
   line = fillstring(130,"-"), buf = fillstring(130," "), buf2 = fillstring(100," ")
  HEAD PAGE
   col 0, "RefLog DateTime: ",
   CALL print(format(cnvtdatetime(sysdate),";;q")),
   col 100, "Page: ", curpage"#######",
   row + 1, col 0, "Ref",
   col 10, "Type(U/I/D)", col 22,
   "Table", col 50, "PrcName",
   col 66, "DateTime", col 90,
   "Id", col 100, "Task",
   col 115, "ApplCtx", row + 1,
   line, row + 1
  HEAD l.ref_id
   col 0, l.ref_id";l", col 10,
   l.ref_type, col 22, l.ref_table,
   col 50, l.ref_prcname, col 66,
   l.updt_dt_tm";;q", col 90, l.updt_id";l",
   col 100, l.ref_username, col 115,
   l.ref_rdbmsname, row + 1, cc = 1
   FOR (num = 1 TO 20)
     buf = substring(cc,130,l.ref_command)
     IF (buf != " ")
      col 0,
      CALL print(trim(buf)), row + 1
     ENDIF
     cc += 130
   ENDFOR
  DETAIL
   first = 1, cc = 1
   FOR (num = 1 TO 20)
     buf2 = substring(cc,130,ref_text)
     IF (buf2 != " ")
      IF (first)
       col 0,
       CALL print(build("<Param(",ref_bind_num,".",param_num,")>::")), first = 0
      ENDIF
      col 20,
      CALL print(trim(buf2)), row + 1
     ENDIF
     cc += 100
   ENDFOR
  FOOT  l.ref_id
   row + 1
  WITH maxcol = 150
 ;end select
END GO
