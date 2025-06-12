CREATE PROGRAM cclcompile:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLCOMPILE"), clear(3,2,78),
  text(03,05,"Report to get size of ccl compiled programs"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME(pattern match allowed)"), text(07,05,"SORT by (S)ize or (N)ame"), accept(05,
   30,"X(31);CU","MINE"),
  accept(06,45,"P(30);CU","*"), accept(07,45,"P1;CU","S")
 RECORD rec_tmp(
   1 qual[*]
     2 object_name = c30
     2 num_records = i2
     2 group = i2
     2 debugflag = i2
     2 optflag = i2
     2 lckflag = i2
 )
 SET cnt = 0
 SELECT
  IF (( $3="S"))
   ORDER BY d.object, d.qual DESC, d.object_name
  ELSE
   ORDER BY d.object, d.object_name, d.qual DESC
  ENDIF
  INTO "nl:"
  grp = concat(d.object_name,format(d.group,"####")), debugflag = btest(ichar(substring(42,1,d
     .datarec)),0), optflag = btest(ichar(substring(42,1,d.datarec)),5),
  lckflag = btest(ichar(substring(42,1,d.datarec)),3)
  FROM dcompile d
  WHERE d.object="P"
   AND (d.object_name= $2)
  HEAD grp
   fnd = 0
   FOR (num = 1 TO cnt)
     IF ((rec_tmp->qual[num].object_name=d.object_name)
      AND (rec_tmp->qual[num].group=d.group))
      fnd = 1
     ENDIF
   ENDFOR
   IF (fnd=0)
    cnt += 1, stat = alterlist(rec_tmp->qual,cnt), rec_tmp->qual[cnt].group = d.group,
    rec_tmp->qual[cnt].object_name = d.object_name, rec_tmp->qual[cnt].num_records = (d.qual+ 1),
    rec_tmp->qual[cnt].debugflag = debugflag,
    rec_tmp->qual[cnt].optflag = optflag, rec_tmp->qual[cnt].lckflag = lckflag,
    CALL print(build(d.group,d.object_name,(d.qual+ 1))),
    row + 1
   ENDIF
  WITH counter
 ;end select
 CALL text(10,1,build("count=",cnt))
 SELECT
  d.*
  FROM (dummyt d  WITH seq = value(cnt))
  HEAD PAGE
   "FLAG   PROGRAM NAME                      GROUP_NUM     RECORDS       BLOCKS", row + 1,
   "---------------------------------------------------------------------------",
   row + 2
  DETAIL
   num_blocks = ((cnvtreal(rec_tmp->qual[d.seq].num_records) * 850.0)/ 512.0), col 0
   IF ((rec_tmp->qual[d.seq].debugflag=1))
    "Dbg"
   ELSEIF ((rec_tmp->qual[d.seq].optflag=1))
    "Opt"
   ELSE
    "   "
   ENDIF
   col 07, rec_tmp->qual[d.seq].object_name, col 46,
   rec_tmp->qual[d.seq].group"###", col 56, rec_tmp->qual[d.seq].num_records"#####",
   col 66, num_blocks"#####.##;;f", row + 1
  WITH maxcol = 80
 ;end select
END GO
