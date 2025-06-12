CREATE PROGRAM ccl_dic_synch_rpt:dba
 PROMPT
  "Enter report extract name (MINE) : " = "MINE",
  "Enter node name to compare : " = "node1"
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 SET ccl_node_from = cnvtupper( $2)
 SELECT INTO  $1
  grp = concat(d.object,d.object_name), bindata = check(substring(41,800,c.datarec))
  FROM ccl_synch_cmp s,
   dprotect d,
   dcompile c
  PLAN (s
   WHERE s.node_name=ccl_node_from)
   JOIN (d
   WHERE s.object=d.object
    AND s.object_name=d.object_name
    AND s.cclgroup=d.group)
   JOIN (c
   WHERE "P"=c.object
    AND d.group=c.group
    AND d.object_name=c.object_name)
  HEAD REPORT
   line = fillstring(130,"="), cnt1 = 0, cnt2 = 0,
   cnt3 = 0, cnt4 = 0
  HEAD PAGE
   "Comparing objects from node:", ccl_node_from, " to node:",
   ccl_node, row + 1,
   "ObjectName                           Major       Minor      RecCnt    CheckSum  Description",
   row + 1, line, row + 1
  HEAD grp
   checksum2 = 0.0
  DETAIL
   FOR (num = 1 TO 800)
    ival = ichar(substring(num,1,bindata)),
    IF (ival != 32)
     checksum2 += ival
    ENDIF
   ENDFOR
  FOOT  grp
   IF (d.object_name != s.object_name)
    cnt1 += 1, s.object_name, col + 1,
    s.major_version, col + 1, s.minor_version,
    col + 1, s.binary_cnt, col + 1,
    s.checksum, "  (Object not found on this node)", row + 1
   ELSEIF (((d.app_major_version != cnvtint(s.major_version)) OR (d.app_minor_version != cnvtint(s
    .minor_version))) )
    cnt2 += 1, s.object_name, col + 1,
    s.major_version, col + 1, s.minor_version,
    col + 1, s.binary_cnt, col + 1,
    s.checksum, "  (Object version different)", row + 1
   ELSEIF (d.binary_cnt != cnvtint(s.binary_cnt))
    cnt3 += 1, s.object_name, col + 1,
    s.major_version, col + 1, s.minor_version,
    col + 1, s.binary_cnt, col + 1,
    s.checksum, "  (Object record count different)", row + 1
   ELSEIF (checksum2 != cnvtreal(s.checksum))
    cnt4 += 1, s.object_name, col + 1,
    s.major_version, col + 1, s.minor_version,
    col + 1, s.binary_cnt, col + 1,
    s.checksum, "  (Object check sum different)", row + 1
   ENDIF
  FOOT REPORT
   BREAK, "               Total objects not found = ", cnt1,
   row + 1, "  Total objects with different version = ", cnt2,
   row + 1, "Total objects with different rec count = ", cnt3,
   row + 1, "Total objects with different check sum = ", cnt4,
   row + 1, "=========================================",
   CALL print((((cnt1+ cnt2)+ cnt3)+ cnt4)),
   row + 1
  WITH counter, outerjoin = s
 ;end select
END GO
