CREATE PROGRAM ccltablecrtddl:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCLTABLECRTDDL"), clear(3,2,78),
  text(03,05,"Generate definition from dictionary (SELECT INTO TABLE ONLY)"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"DICTIONARY TABLE NAME(pattern match allowed)"), text(07,05,
   "Drop old table definition(Y/N)"), accept(05,30,"X(31);CU","MINE"),
  accept(06,50,"P(30);CU","*"), accept(07,50,"P;CU","N")
 IF (( $3="N"))
  SET drop_delim = ";"
 ELSE
  SET drop_delim = " "
 ENDIF
 SELECT DISTINCT INTO trim( $1)
  flag = decode(k.seq,1,2), forg =
  IF (f.file_org="I") "INDEXED"
  ELSEIF (f.file_org="R") "RELATIVE"
  ELSEIF (f.file_org="S") "SEQUENTIAL"
  ENDIF
  , iskey =
  IF (btest(l.stat,3)) ",keyfield"
  ELSE "         "
  ENDIF
  ,
  unique_key =
  IF (k.dups_ind=1) "UNIQUE"
  ELSE "      "
  ENDIF
  , table_name = t.table_name, astat1 =
  IF (btest(l.stat,15)) "L"
  ELSEIF (btest(l.stat,1)) "Z"
  ELSEIF (l.type="I"
   AND btest(l.stat,0)=0) "U"
  ELSE " "
  ENDIF
  ,
  astat2 =
  IF (btest(l.stat,9)) "A"
  ELSEIF (btest(l.stat,10)) "B"
  ELSEIF (btest(l.stat,13)) "V"
  ELSEIF (btest(l.stat,12)
   AND btest(l.stat,6)) "S"
  ELSEIF (btest(l.stat,12)
   AND  NOT (btest(l.stat,6))) "W"
  ELSE " "
  ENDIF
  , astat3 =
  IF (btest(l.stat,14)) "G "
  ELSEIF (band(l.stat,224)=32) "T "
  ELSEIF (band(l.stat,224)=64) "D "
  ELSEIF (band(l.stat,224)=128) "R "
  ELSEIF (band(l.stat,224)=160) "RT"
  ELSEIF (band(l.stat,224)=192) "RD"
  ELSE "  "
  ENDIF
  FROM dtable t,
   dtableattr a,
   dtableattrl l,
   dfile f,
   dfilekey k
  PLAN (t
   WHERE (t.table_name= $2)
    AND (t.rectype_name= $2)
    AND (t.file_name= $2))
   JOIN (f
   WHERE t.file_name=f.file_name
    AND f.file_org IN ("I", "R", "S"))
   JOIN (((k)
   ) ORJOIN ((a
   WHERE t.table_name=a.table_name)
   JOIN (l
   WHERE l.structtype="F"
    AND l.seg_level=1)
   ))
  ORDER BY table_name, flag, k.seq,
   l.offset
  HEAD table_name
   drop_delim, "DROP database ", t.file_name,
   " WITH DEPS_DELETED GO", row + 1, drop_delim,
   "DROP TABLE ", table_name, " GO",
   row + 1, "create database ", t.file_name,
   row + 1,
   CALL print(build(" ORGANIZATION(",forg,")")), row + 1,
   CALL print(build(" FORMAT(",f.file_format,")")), row + 1,
   CALL print(build(" SIZE(",f.max_reclen,")")),
   row + 1,
   CALL print(build(" type(",f.file_dir_type,")")), row + 1,
   iskey_num = 0
  DETAIL
   CASE (flag)
    OF 1:
     IF (f.file_org="I")
      CALL print(build(unique_key," KEY ")), col + 1,
      CALL print(build(k.seq,"(  ",k.key_offset,",",k.key_len,
       ")")),
      row + 1
     ENDIF
    OF 2:
     IF (l.offset=0)
      "go", row + 1, "CREATE DDLRECORD ",
      t.rectype_name, " FROM DATABASE ", t.file_name,
      row + 1, "TABLE ", t.table_name,
      " WITH NULL = NONE", row + 1
     ENDIF
     ,
     IF (iskey != " ")
      iskey_num += 1, "1  KEY", iskey_num"#",
      row + 1, "2  "
     ELSE
      "1  "
     ENDIF
     ,l.attr_name," = ",
     CALL print(build(astat1,astat2,astat3,l.type,l.len))
     CALL print(build(" CCL(",l.attr_name,")"," ;off=",l.offset,
      iskey))row + 1
   ENDCASE
  FOOT  table_name
   "END TABLE ", t.table_name
   IF (t.access_code != " ")
    " WITH ACCESS_CODE=", t.access_code
   ENDIF
   " GO", row + 1, row + 1
  WITH nocounter, noformfeed, maxrow = 1,
   format = variable, dontcare = k
 ;end select
END GO
