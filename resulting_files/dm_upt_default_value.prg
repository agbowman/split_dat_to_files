CREATE PROGRAM dm_upt_default_value
 SET tname =  $1
 SET cname =  $2
 SET default_value =  $3
 SET data_type =  $4
 RECORD rids(
   1 last_rowid = vc
   1 str = vc
   1 rowid_count = i4
   1 qual[100000]
     2 rowid = vc
 )
 SET rids->last_rowid = "00000000.0000.0000"
 SET finished = 0
 SET loop_cnt = 0
 WHILE (finished=0)
   SET rids->rowid_count = 0
   SET rids->str = concat('select into "nl:" ',"       c.rowid from ",tname," c "," where c.",
    cname," = null ","detail ","	rids->rowid_count=rids->rowid_count+1 ",
    "	rids->qual[rids->rowid_count]->rowid = c.rowid ",
    " with maxqual(c, 50000) go")
   CALL echo(rids->str)
   CALL parser(rids->str)
   SET rids->last_rowid = rids->qual[rids->rowid_count].rowid
   CALL echo(rids->last_rowid)
   IF ((rids->rowid_count=0))
    SET finished = 1
   ELSE
    IF (((data_type="NUMBER") OR (data_type="FLOAT")) )
     SET rids->str = concat("update into ",tname,
      " t, (dummyt d with seq = value(rids->rowid_count)) "," set t.",cname,
      " = ",default_value," ")
    ELSEIF (data_type="DATE")
     SET rids->str = concat("update into ",tname,
      " t, (dummyt d with seq = value(rids->rowid_count)) "," set t.",cname,
      ' = cnvtdatetime("',default_value,'") ')
    ELSE
     SET rids->str = concat("update into ",tname,
      " t, (dummyt d with seq = value(rids->rowid_count)) "," set t.",cname,
      ' = "',default_value,'" ')
    ENDIF
    CALL echo(rids->str)
    CALL parser(rids->str)
    CALL parser(concat("plan d where d.seq >=1 and d.seq <=10000 ",
      "join t where t.rowid = rids->qual[d.seq]->rowid ","with nocounter go"))
    COMMIT
    CALL parser(rids->str)
    CALL parser(concat("plan d where d.seq >=10001 and d.seq <=20000 ",
      "join t where t.rowid = rids->qual[d.seq]->rowid ","with nocounter go"))
    COMMIT
    CALL parser(rids->str)
    CALL parser(concat("plan d where d.seq >=20001 and d.seq <=30000 ",
      "join t where t.rowid = rids->qual[d.seq]->rowid ","with nocounter go"))
    COMMIT
    CALL parser(rids->str)
    CALL parser(concat("plan d where d.seq >=30001 and d.seq <=40000 ",
      "join t where t.rowid = rids->qual[d.seq]->rowid ","with nocounter go"))
    COMMIT
    CALL parser(rids->str)
    CALL parser(concat("plan d where d.seq >=40001 and d.seq <=50000 ",
      "join t where t.rowid = rids->qual[d.seq]->rowid ","with nocounter go"))
    COMMIT
   ENDIF
 ENDWHILE
END GO
