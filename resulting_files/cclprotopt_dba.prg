CREATE PROGRAM cclprotopt:dba
 PAINT
  video(r), box(1,1,11,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLPROTOPT"), clear(3,2,78),
  text(03,05,"Report to get protection info for CCL object(s) with options."), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME TYPE(pattern match allowed)"), text(07,05,
   "D=DATABASE M=MENU P=PROGRAM T=TABLE V=VIEW E=EKMODULE *=ALL"), text(08,05,
   "OBJECT NAME(pattern match allowed)"),
  text(09,05,"RdbOptimizer Begin(0-15)"), text(10,05,"RdbOptimizer End(0-15)"), accept(05,30,
   "X(31);CU","MINE"),
  accept(06,45,"P;CU","P"), accept(08,45,"P(30);CU","*"), accept(09,45,"99",0),
  accept(10,45,"99",15)
 DECLARE optname[20] = c10 WITH constant("NONE","RULE","CHOOSE","FIRST_1","FIRST_10",
  "FIRST_100","FIRST_1000","FIRST","ALL","choose",
  "first_1","first_10","first_100","first_1000","first",
  "all")
 SELECT INTO  $1
  object = substring(1,1,g.rest), object_name = substring(2,30,g.rest), group = ichar(substring(32,1,
    g.rest)),
  rdboptval = evaluate(substring(274,6,g.data),"<sec1>",ichar(substring(248,1,g.data)),0), rdboptqry
   = evaluate(substring(274,6,g.data),"<sec1>",substring(249,25,g.data),fillstring(25,char(0))),
  rdbopt = evaluate(substring(274,6,g.data),"<sec1>","Y","N")
  FROM (dgeneric g  WITH access_code = "5", user_code = none)
  WHERE g.platform="H0000"
   AND g.rcode="5"
   AND g.rest=patstring(concat( $2,trim( $3),"*"))
   AND evaluate(substring(274,6,g.data),"<sec1>",band(ichar(substring(248,1,g.data)),15),0) BETWEEN
   $4 AND  $5
  HEAD REPORT
   num = 0, num1 = 0, num3 = 0,
   val = 0, val1 = 0, val2 = 0,
   line = fillstring(130,"=")
  HEAD PAGE
   col 0, "Object", col 8,
   "Grp", col 12, "ObjectName",
   col 42, "RdbOptDef", col 53,
   "RdbOptQry", row + 1, line,
   row + 1
  DETAIL
   num3 = 1, val1 = (band(rdboptval,240)/ 16), val2 = band(rdboptval,15),
   col 0, object, col 8,
   group"###", col 12, object_name,
   col 41, col + 1, optname[(val2+ 1)],
   col 53, "Q00(", optname[(val1+ 1)],
   ")"
   IF (rdbopt="Y")
    FOR (num = 1 TO 25)
     val = ichar(substring(num,1,rdboptqry)),
     IF (val)
      num2 = (num * 2), num1 = (num2 - 1), val1 = (band(val,240)/ 16),
      val2 = band(val,15)
      IF (val1)
       num3 += 1
       IF (num3 > 5)
        row + 1, col 53, num3 = 1
       ENDIF
       "Q", num1"##;rp0", "(",
       optname[(val1+ 1)], ")"
      ENDIF
      IF (val2)
       num3 += 1
       IF (num3 > 5)
        row + 1, col 53, num3 = 1
       ENDIF
       "Q", num2"##;rp0", "(",
       optname[(val2+ 1)], ")"
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   row + 1
  WITH counter, maxcol = 132
 ;end select
END GO
