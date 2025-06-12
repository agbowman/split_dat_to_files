CREATE PROGRAM cclprotdup:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLPROTDUP"), clear(3,2,78),
  text(03,05,"Report to find dup objects in multiple groups"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME TYPE(pattern match allowed)"), text(07,05,
   "D=DATABASE M=MENU P=PROGRAM T=TABLE V=VIEW E=EKMODULE *=ALL"), text(08,05,
   "OBJECT NAME(pattern match allowed)"),
  accept(05,30,"X(31);CU","MINE"), accept(06,45,"P;CU","*"), accept(08,45,"P(30);CU","*")
 RECORD dicprotect_rec FROM dic,dicprotect,dicprotect
 SET max_group = 10
 SELECT INTO  $1
  group = p.group, p.binary_cnt, p.app_minor_version,
  p.app_major_version, ccl_version = mod(p.ccl_version,100), ccl_reg =
  IF (p.ccl_version > 100) "*"
  ELSE " "
  ENDIF
  ,
  app_ocdmajor =
  IF (p.app_minor_version > 900000) mod(p.app_minor_version,1000000)
  ELSE p.app_minor_version
  ENDIF
  , app_ocdminor =
  IF (p.app_minor_version > 900000) cnvtint((p.app_minor_version/ 1000000.0))
  ELSE 0
  ENDIF
  , object_name = p.object_name,
  object_break = concat(p.object,p.object_name), p.object, p.source_name,
  p.user_name, p.datestamp, p.timestamp
  FROM dprotect p
  WHERE (p.object= $2)
   AND (p.object_name= $3)
  HEAD REPORT
   line = fillstring(130,"-"), last_group = 0
  HEAD PAGE
   "OBJECT", col 41, "TYPE",
   col 46, "OWNER", col 55,
   "Size", col 65, "APP_VER",
   col 78, "CCL_VER", col 86,
   "DATE    TIME", col 100, "GROUP",
   row + 1, line, row + 1
  HEAD object_break
   last_group = group
  HEAD group
   IF (last_group != group)
    col 00, object_name, col 44,
    p.object, col 46, p.user_name,
    col 55, p.binary_cnt"######", col 65,
    CALL print(build(p.app_major_version,".",app_ocdmajor,".",app_ocdminor)), col 78, ccl_version"##",
    ccl_reg, col 86, p.datestamp"DDMMMYY;;D",
    " ", p.timestamp"HH:MM:SS;2;m", col 100,
    last_group"###", ",", group"###",
    " <Dup>", row + 1
   ENDIF
  WITH format, maxcol = 140, counter,
   outerjoin = p
 ;end select
END GO
