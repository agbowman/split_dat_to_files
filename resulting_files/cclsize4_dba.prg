CREATE PROGRAM cclsize4:dba
 PROMPT
  "Enter cclsize3 domain 1 file : " = "cclsize3a",
  "Enter cclsize3 domain 2 file : " = "cclsize3b",
  "Enter option (1=missing) (2=diff) (3=all) : " = 3
 RECORD rec1(
   1 qual[*]
     2 object = c1
     2 group = i1
     2 object_name = c30
     2 binary_count = i4
     2 check_sum = f8
     2 source_name = c35
 )
 RECORD rec2(
   1 qual[*]
     2 object = c1
     2 group = i1
     2 object_name = c30
     2 binary_count = i4
     2 check_sum = f8
     2 source_name = c35
 )
 FREE DEFINE rtl
 DEFINE rtl  $1
 SET rnum = 0
 SELECT INTO nl
  object = substring(1,1,r.line), group = cnvtint(substring(11,2,r.line)), object_name = substring(16,
   30,r.line),
  binary_count = cnvtint(substring(45,8,r.line)), check_sum = cnvtreal(substring(53,10,r.line)),
  source_name = substring(102,35,r.line)
  FROM rtlt r
  WHERE substring(2,1,r.line)=" "
  DETAIL
   rnum += 1, stat = alterlist(rec1->qual,rnum), rec1->qual[rnum].object = object,
   rec1->qual[rnum].group = group, rec1->qual[rnum].object_name = object_name, rec1->qual[rnum].
   binary_count = binary_count,
   rec1->qual[rnum].check_sum = check_sum, rec1->qual[rnum].source_name = source_name
   IF (mod(rnum,500)=0)
    CALL echo(build("1)Row:",rnum))
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 DEFINE rtl  $2
 SET rnum = 0
 SELECT INTO nl
  object = substring(1,1,r.line), group = cnvtint(substring(11,2,r.line)), object_name = substring(16,
   30,r.line),
  binary_count = cnvtint(substring(45,8,r.line)), check_sum = cnvtreal(substring(53,10,r.line)),
  source_name = substring(102,35,r.line)
  FROM rtlt r
  WHERE substring(2,1,r.line)=" "
  DETAIL
   rnum += 1, stat = alterlist(rec2->qual,rnum), rec2->qual[rnum].object = object,
   rec2->qual[rnum].group = group, rec2->qual[rnum].object_name = object_name, rec2->qual[rnum].
   binary_count = binary_count,
   rec2->qual[rnum].check_sum = check_sum, rec2->qual[rnum].source_name = source_name
   IF (mod(rnum,500)=0)
    CALL echo(build("2)Row:",rnum))
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 SELECT
  FROM dummyt d
  HEAD REPORT
   line = fillstring(130,"="), r1_tot = size(rec1->qual,5), r2_tot = size(rec2->qual,5),
   last_fnd = 0
  HEAD PAGE
   "Report comparing objects between domain ",  $1, " to ",
    $2, row + 1,
   "Object Group   ObjectName                    Records(1)  CheckSum(1) Records(2)  CheckSum(2)          SourceName",
   row + 1, line, row + 1
  DETAIL
   FOR (r1 = 1 TO r1_tot)
     IF (mod(r1,500)=0)
      CALL echo(build("3)Row:",r1,"/",r1_tot))
     ENDIF
     fnd = 0
     FOR (r2 = (last_fnd+ 1) TO r2_tot)
       IF ((rec1->qual[r1].object=rec2->qual[r2].object)
        AND (rec1->qual[r1].group=rec2->qual[r2].group)
        AND (rec1->qual[r1].object_name=rec2->qual[r2].object_name))
        fnd = 1, last_fnd = r2
        IF (( $3 IN (2, 3))
         AND (((rec1->qual[r1].binary_count != rec2->qual[r2].binary_count)) OR ((rec1->qual[r1].
        check_sum != rec2->qual[r2].check_sum))) )
         col 00, rec1->qual[r1].object, col 10,
         rec1->qual[r1].group"##", col 15, rec1->qual[r1].object_name,
         col + 3, rec1->qual[r1].binary_count"######", col + 3,
         rec1->qual[r1].check_sum"#########", col + 3, rec2->qual[r2].binary_count"######",
         col + 3, rec2->qual[r2].check_sum"#########", col 102,
         rec1->qual[r1].source_name, row + 1
        ENDIF
        r2 = (r2_tot+ 1)
       ENDIF
     ENDFOR
     IF (fnd=0
      AND ( $3 IN (1, 3)))
      col 00, rec1->qual[r1].object, col 10,
      rec1->qual[r1].group"##", col 15, rec1->qual[r1].object_name,
      col + 3, rec1->qual[r1].binary_count"######", col + 3,
      rec1->qual[r1].check_sum"#########", col 80, "Missing in 2",
      col 102, rec1->qual[r1].source_name, row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 140
 ;end select
END GO
