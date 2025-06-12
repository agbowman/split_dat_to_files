CREATE PROGRAM cclprot:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLPROT"), clear(3,2,78),
  text(03,05,"Report to get protection info for CCL object(s)."), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME TYPE(pattern match allowed)"), text(07,05,
   "D=DATABASE M=MENU P=PROGRAM T=TABLE V=VIEW E=EKMODULE *=ALL"), text(08,05,
   "OBJECT NAME(pattern match allowed)"),
  text(09,05,"Display Include Source Name"), accept(05,30,"X(31);CU","MINE"), accept(06,45,"P;CU","*"
   ),
  accept(08,45,"P(30);CU","*"), accept(09,45,"P;CU","N")
 RECORD dicprotect_rec FROM dic,dicprotect,dicprotect
 SET max_group = 10
 IF (( $4 != "Y"))
  SET max_group = 3
 ENDIF
 SELECT INTO  $1
  group = p.group, p.binary_cnt, p.app_minor_version,
  p.app_major_version, ccl_version = mod(p.ccl_version,100), ccl_reg =
  IF (p.ccl_version > 100) " Ureg"
  ELSE "  Reg"
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
  p.user_name, p.datestamp, p.timestamp,
  updt_id =
  IF (ccl_version >= 2) 0.0
  ELSE 0.0
  ENDIF
  , updt_task =
  IF (ccl_version >= 2) validate(p.updt_task,0)
  ELSE 0
  ENDIF
  , updt_applctx =
  IF (ccl_version >= 2) validate(p.updt_applctx,0)
  ELSE 0
  ENDIF
  ,
  prcname =
  IF (ccl_version >= 2) validate(p.prcname,"               ")
  ELSE "               "
  ENDIF
  FROM dprotect p
  WHERE (p.object= $2)
   AND (p.object_name= $3)
  HEAD REPORT
   line = fillstring(130,"-"), last_group = 0
  HEAD PAGE
   "OBJECT", col 35, "GROUP",
   col 41, "TYPE", col 46,
   "OWNER", col 57, "SIZE",
   col 66, "APP_VER", col 78,
   "CCL_VER", col 86, "DATE    TIME",
   col 105, "(0 TO ", max_group"##",
   " PROTECTION)", row + 1, col 46,
   "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate", row + 1, line,
   row + 1
  HEAD object_break
   object_name, last_group = group
  HEAD group
   IF (last_group != group)
    row + 1, "<Dup Warning>"
   ENDIF
   col 35, group"###", col 44,
   p.object
   IF (p.datestamp BETWEEN 69000 AND curdate)
    new_format = 1, col 46, p.user_name,
    col 55, p.binary_cnt"######", col 65,
    CALL print(build(p.app_major_version,".",app_ocdmajor,".",app_ocdminor)), col 78, ccl_version"##",
    ccl_reg, col 86, p.datestamp"DDMMMYY;;D",
    " ", p.timestamp"HH:MM:SS;2;m"
   ELSE
    new_format = 0
   ENDIF
  DETAIL
   stat = moverec(p.seq,dicprotect_rec), scol = 95
   FOR (gnum = 0 TO max_group)
    permit_info = dicprotect_rec->groups[(gnum+ 1)].permit_info,
    IF (permit_info != 0)
     IF (scol >= 125)
      row + 1, scol = 55
     ELSE
      scol += 8
     ENDIF
     col scol, gnum"##:"
     IF (permit_info=255)
      "ALL"
     ELSE
      IF (btest(permit_info,0)=1)
       "S"
      ENDIF
      IF (btest(permit_info,1)=1)
       "R"
      ENDIF
      IF (btest(permit_info,2)=1)
       "E"
      ENDIF
      IF (btest(permit_info,3)=1)
       "W"
      ENDIF
      IF (btest(permit_info,4)=1)
       "D"
      ENDIF
      IF (btest(permit_info,5)=1)
       "I"
      ENDIF
      IF (btest(permit_info,6)=1)
       "U"
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
  FOOT  object_break
   IF (( $4="Y"))
    row + 1
    IF (new_format=1)
     col 0,
     CALL print(build("Source=",check(p.source_name)))
    ELSE
     col 0,
     CALL print(build("Source=",substring(1,31,check(p.source_name))))
    ENDIF
    col 80, "Srv="
    IF (cnvtupper(substring(1,3,prcname))="SRV")
     prcname
    ENDIF
    col 100,
    CALL print(build("App=",format(updt_id,"#########;l"),",",updt_task,",",
     updt_applctx))
   ENDIF
   row + 1
  WITH format, maxcol = 140, counter,
   outerjoin = p
 ;end select
END GO
