CREATE PROGRAM cclcompiledbg:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLCOMPILEDBG"), clear(3,2,78),
  text(03,05,"Report to get debug info for ccl compiled programs"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME(pattern match allowed)"), text(07,05,"SHOW(0:nodebug, 1:debug, 2:all)"),
  accept(05,30,"X(31);CU","MINE"),
  accept(06,45,"P(30);CU","*"), accept(07,45,"9",2)
 SELECT
  IF (( $3=0))
   WHERE d.object="P"
    AND (d.object_name= $2)
    AND d.qual=0
    AND btest(ichar(substring(42,1,d.datarec)),0)=0
  ELSEIF (( $3=1))
   WHERE d.object="P"
    AND (d.object_name= $2)
    AND d.qual=0
    AND btest(ichar(substring(42,1,d.datarec)),0)=1
  ELSE
  ENDIF
  INTO  $1
  d.object, d.object_name, d.group,
  dbg_flag = btest(ichar(substring(42,1,d.datarec)),0), opt_flag = btest(ichar(substring(42,1,d
     .datarec)),5), lck_flag = btest(ichar(substring(42,1,d.datarec)),3)
  FROM dcompile d
  WHERE d.object="P"
   AND (d.object_name= $2)
   AND d.qual=0
  WITH counter
 ;end select
END GO
