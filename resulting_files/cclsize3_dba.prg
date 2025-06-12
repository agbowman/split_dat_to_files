CREATE PROGRAM cclsize3:dba
 PROMPT
  "Enter output name : " = "MINE",
  "Enter object name : " = "*"
 SELECT INTO  $1
  grp = concat(dp.object,dp.object_name), dp.object, dp.object_name,
  dp.key1, bindata = check(substring(41,800,dc.datarec)), debug = mod(ichar(substring(42,1,dc.datarec
     )),2)
  FROM dprotect dp,
   dcompile dc
  PLAN (dp
   WHERE dp.platform="H0000"
    AND dp.rcode="5"
    AND ((dp.object="E") OR (((dp.object="M") OR (dp.object="P")) ))
    AND dp.group=0
    AND dp.object_name=patstring(cnvtupper( $2)))
   JOIN (dc
   WHERE "P"=dc.object
    AND dp.group=dc.group
    AND dp.object_name=dc.object_name)
  HEAD REPORT
   line = fillstring(130,"=")
  HEAD PAGE
   "Object Group   ObjectName                  BinaryCnt  CheckSum Date      UserName     AppVer          SourceName",
   row + 1, line,
   row + 1
  HEAD grp
   checksum = 0.0, ival = 0
  DETAIL
   FOR (num = 1 TO 800)
    ival = ichar(substring(num,1,bindata)),
    IF (ival != 32)
     checksum += ival
    ENDIF
   ENDFOR
  FOOT  grp
   col 00, dp.object, col 01
   IF (debug)
    "(Debug)"
   ENDIF
   col 10, dp.group"##", col 15,
   dp.object_name, col + 1, dp.binary_cnt"######",
   col + 1, checksum"#########", col + 1,
   dp.datestamp"ddmmmyyyy;;d", col + 1, dp.user_name,
   col + 1,
   CALL print(build(dp.app_major_version,".",dp.app_minor_version))
   CASE (cursys)
    OF "AXP":
     pos1 = findstring(":",dp.source_name),pos2 = findstring("]",dp.source_name,1,1)
    OF "AIX":
     pos1 = findstring(":",dp.source_name),pos2 = findstring("/",dp.source_name,1,1)
    OF "WIN":
     pos1 = findstring(":",dp.source_name),pos2 = findstring("\",dp.source_name,1,1)
   ENDCASE
   pos1 = maxval(pos2,pos1), col 102,
   CALL print(cnvtlower(substring((pos1+ 1),35,dp.source_name))),
   row + 1
  WITH counter, maxcol = 140
 ;end select
END GO
