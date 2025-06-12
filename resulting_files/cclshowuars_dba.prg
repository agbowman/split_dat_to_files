CREATE PROGRAM cclshowuars:dba
 PROMPT
  "Enter output name: " = "MINE"
 DECLARE cnt = i4 WITH noconstant(0)
 RECORD rec(
   1 qual[*]
     2 name = vc
 )
 DECLARE tcnt = i4 WITH noconstant(100)
 DECLARE stat = i4
 DECLARE tmpname = vc WITH noconstant(build("show_uars",curprcname,".ccl"))
 IF (cursys="AXP")
  SET tmpname = cnvtupper(tmpname)
 ENDIF
 SET stat = alterlist(rec->qual,tcnt)
 SELECT INTO nl
  d.object_name
  FROM dprotect d
  WHERE d.group=0
   AND d.object="P"
   AND d.object_name="*RTL"
  DETAIL
   cnt += 1
   IF (cnt > tcnt)
    tcnt += 100, stat = alterlist(rec->qual,tcnt)
   ENDIF
   rec->qual[cnt].name = d.object_name
  WITH counter
 ;end select
 CALL parser(concat("TRANSLATE INTO '",tmpname,"' "," CCLSTARTUP:DBA GO"))
 FOR (num = 1 TO cnt)
   CALL parser(concat("TRANSLATE INTO '",tmpname,"' ",rec->qual[num].name,":DBA WITH APPEND GO"))
