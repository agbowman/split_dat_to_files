CREATE PROGRAM dm_rdds_parse_stmts:dba
 DECLARE loop_cnt = i4
 SET loop_cnt = 0
 IF (validate(request->qual[1].parse_stmts,"N")="N")
  FREE RECORD request
  RECORD request(
    1 qual[*]
      2 parse_stmts = vc
  )
 ENDIF
 FOR (loop_cnt = 1 TO size(request->qual,5))
   IF (loop_cnt != size(request->qual,5))
    CALL parser(request->qual[loop_cnt].parse_stmts,0)
   ELSE
    CALL parser(request->qual[loop_cnt].parse_stmts,1)
   ENDIF
 ENDFOR
END GO
