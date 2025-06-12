CREATE PROGRAM ccloratable:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"HNA Millennium Data Model"), clear(3,2,78),
  text(03,10,"Report to show table index and attribute information"), video(n), text(05,02,
   "MINE/CRT/printer/file"),
  text(06,02,"TABLE NAME"), text(07,15,'ENTER AS:  PERSON OR "PERSON","ENCOUNTER"'), accept(05,25,
   "X(31);CU","MINE"),
  accept(06,15,"P(65);CU","*")
 IF (textlen(trim( $2)) < 3)
  SELECT
   FROM dummyt
   DETAIL
    col 0,
    "Failed to read table attributes. Table name must be minimum of three characters with wildcard."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 IF (substring(1,1, $2)='"')
  SET qual1 = concat("T.TABLE_NAME IN (",patstring(cnvtupper( $2)),")")
 ELSE
  SET qual1 = concat("T.TABLE_NAME = '",patstring(cnvtupper( $2)),"'")
 ENDIF
 SELECT
  IF (currdb="DB2UDB")
   FROM dtable t,
    dtableattr a,
    dtableattrl l,
    dba_ind_columns c,
    dba_indexes i,
    dm_tables_doc doc
   PLAN (t
    WHERE parser(qual1))
    JOIN (((a
    WHERE t.table_name=a.table_name)
    JOIN (l
    WHERE l.structtype != "K"
     AND btest(l.stat,11)=0)
    ) ORJOIN ((doc
    WHERE t.table_name=doc.table_name)
    JOIN (i
    WHERE doc.suffixed_table_name=i.table_name
     AND i.table_owner="V500")
    JOIN (c
    WHERE i.table_name=c.table_name
     AND i.index_name=c.index_name
     AND i.table_owner=c.table_owner)
    ))
  ELSE
   FROM dtable t,
    dtableattr a,
    dtableattrl l,
    dba_ind_columns c,
    dba_indexes i
   PLAN (t
    WHERE parser(qual1))
    JOIN (((a
    WHERE t.table_name=a.table_name)
    JOIN (l
    WHERE l.structtype != "K"
     AND btest(l.stat,11)=0)
    ) ORJOIN ((i
    WHERE t.table_name=i.table_name
     AND i.table_owner="V500")
    JOIN (c
    WHERE i.table_name=c.table_name
     AND i.index_name=c.index_name
     AND i.table_owner=c.table_owner)
    ))
  ENDIF
  INTO  $1
  flag = decode(i.seq,"I",a.seq,"A","Z"), brk = concat(i.table_owner,substring(1,30,c.index_name)),
  colname = substring(1,30,c.column_name),
  index_name = substring(1,30,c.index_name), c.column_position, i.uniqueness,
  iskey = btest(l.stat,3), t.file_name, table_name = check(t.table_name),
  attr_name = l.attr_name, l.type, l.len,
  astat1 =
  IF (btest(l.stat,9)) "A"
  ELSEIF (btest(l.stat,10)) "B"
  ELSEIF (btest(l.stat,14)) "G"
  ELSEIF (btest(l.stat,13)) "V"
  ELSE " "
  ENDIF
  , astat2 =
  IF (band(l.stat,224)=32) "T "
  ELSEIF (band(l.stat,224)=64) "D "
  ELSEIF (band(l.stat,224)=128) "R "
  ELSEIF (band(l.stat,224)=160) "RT"
  ELSEIF (band(l.stat,224)=192) "RD"
  ELSE "  "
  ENDIF
  , astat3 =
  IF (btest(l.stat,15)) "L"
  ELSE " "
  ENDIF
  ,
  atype =
  IF (l.precision) concat(l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
  ELSE concat(l.type,trim(cnvtstring(l.len)))
  ENDIF
  , offset = l.offset"#####"
  ORDER BY t.table_name, flag DESC, i.uniqueness DESC,
   brk, c.index_name, c.column_position,
   attr_name
  HEAD REPORT
   pline = fillstring(75,"="), bline = fillstring(75,"."), cnt = 0
  HEAD PAGE
   col 30, "DATE: ", curdate"DD-MMM-YYYY;;D",
   "  TIME: ", curtime, "  PAGE: ",
   curpage"######", row + 1,
   "DATABASE     TABLE_NAME         ATTRIBUTE                     TYPE   OFFSET",
   row + 1, pline, row + 1
  HEAD table_name
   cnt = 0, data_begin = 0, fldnum = 1,
   keynum = 1, col 0, t.file_name,
   col + 1, table_name, row + 2
  HEAD flag
   IF (flag="I")
    col 5, "INDEXES:", row + 1
   ENDIF
  HEAD brk
   IF (flag="I")
    cnt += 1, ind_name = concat(format(cnt,"##")," (",trim(index_name),")"), col 5,
    ind_name, col 62, i.uniqueness
   ENDIF
  DETAIL
   IF (flag="I")
    col 32, colname, row + 1
   ELSE
    IF (iskey=1)
     kpos = ichar(substring(keynum,1,l.keyfld_struct))
     IF (kpos=0)
      keynum += 1, fldnum = 1
     ENDIF
     IF (fldnum=1)
      col 16, keynum"KEY##:", lastkeyfld_off = 0
     ENDIF
     col 24, fldnum"##"
     IF (lastkeyfld_off > offset)
      "R"
     ENDIF
     fldnum += 1, lastkeyfld_off = offset
    ELSEIF (data_begin=0)
     col 16, "DATA:", data_begin = 1
    ENDIF
    col 32, attr_name, col 62,
    CALL print(build(astat3,astat1,astat2,atype)), col 70, offset"#####",
    row + 1
   ENDIF
  FOOT  index_name
   row + 1
  FOOT  table_name
   IF (((row+ 15) > maxrow))
    BREAK
   ELSE
    bline, row + 1
   ENDIF
  WITH maxrow = 60, counter, maxcol = 76,
   heading = 4, nullreport
 ;end select
#end_program
END GO
