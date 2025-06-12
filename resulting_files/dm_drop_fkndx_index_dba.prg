CREATE PROGRAM dm_drop_fkndx_index:dba
 PAINT
 CALL text(2,1,"***** This program will drop all foreign      *****")
 CALL text(3,1,"***** key indexes with an index name          *****")
 CALL text(4,1,"***** starting with 'FKNDX'.                  *****")
 CALL text(5,1,"***** 'D' = Do NOT Drop Indexes, Display Only *****")
 CALL text(6,1,"***** 'C' = Drop Indexes and Display          *****")
 CALL text(7,1,"***** 'Q' = Quit & Exit Program               *****")
#display
 CALL text(10,1,"Enter D)isplay Only, C)ontinue, Q)uit:           ")
 CALL accept(10,41,"A;cu","Q")
 IF (curaccept != "D"
  AND curaccept != "C"
  AND curaccept != "Q")
  GO TO display
 ELSE
  IF (curaccept="Q")
   GO TO end_program
  ENDIF
 ENDIF
 SET answer = curaccept
 RECORD list(
   1 index[*]
     2 buffer = c120
 )
 SET stat = alterlist(list->index,10)
 SET icnt = 0
 SELECT INTO "NL:"
  ui.index_name
  FROM user_indexes ui
  WHERE ui.index_name="FKNDX*"
  DETAIL
   icnt = (icnt+ 1)
   IF (mod(icnt,10)=1
    AND icnt != 1)
    stat = alterlist(list->index,(icnt+ 9))
   ENDIF
   list->index[icnt].buffer = concat("rdb drop index ",ui.index_name," go ")
  WITH nocounter
 ;end select
 IF (icnt > 0)
  FOR (x = 1 TO icnt)
   CALL text(12,1,substring(1,75,list->index[x].buffer))
   IF (answer="C")
    CALL parser(list->index[x].buffer,1)
   ENDIF
  ENDFOR
 ENDIF
END GO
