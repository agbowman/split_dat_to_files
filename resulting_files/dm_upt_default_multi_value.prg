CREATE PROGRAM dm_upt_default_multi_value
 RECORD rids(
   1 str = vc
 )
 SET finished = 0
 SET loop_cnt = 0
 SET rids->str = concat("rdb update ",duds->tname," t ")
 FOR (i = 1 TO duds->qual_cnt)
  IF (i=1)
   SET rids->str = concat(rids->str," set ")
  ELSE
   SET rids->str = concat(rids->str," , ")
  ENDIF
  IF ((((duds->qual[i].data_type="NUMBER")) OR ((duds->qual[i].data_type="FLOAT"))) )
   SET rids->str = concat(rids->str," t.",duds->qual[i].cname," = ",duds->qual[i].default_value,
    " ")
  ELSEIF ((duds->qual[i].data_type="DATE"))
   SET rids->str = concat(rids->str," t.",duds->qual[i].cname," = ",duds->qual[i].default_value)
  ELSE
   SET rids->str = concat(rids->str," t.",duds->qual[i].cname,' = "',duds->qual[i].default_value,
    '" ')
  ENDIF
 ENDFOR
 FOR (i = 1 TO duds->qual_cnt)
   IF (i=1)
    SET rids->str = concat(rids->str," where t.",duds->qual[i].cname," is null ")
   ELSE
    SET rids->str = concat(rids->str,"   and t.",duds->qual[i].cname," is null ")
   ENDIF
 ENDFOR
 SET rids->str = concat(rids->str," and rownum < 20000 go")
 CALL echo(rids->str)
 WHILE (finished=0)
   CALL parser(rids->str)
   IF (curqual=0)
    SET finished = 1
   ENDIF
   COMMIT
 ENDWHILE
END GO
