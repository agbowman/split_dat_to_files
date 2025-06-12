CREATE PROGRAM cclutil_findpat:dba
 PROMPT
  "Enter Output name (ccl_findpat): " = "ccl_findpat",
  "Enter Object type (P): " = "P",
  "Enter Program name to search (*): " = "*",
  "Enter pattern number (1): " = 1,
  "Show mode (0): " = 0
 SET message = noinformation
 RECORD rec(
   1 qual[*]
     2 pname = vc
     2 match = i1
   1 cnt = i4
   1 fnd = i4
   1 totmatch = i4
 )
 DECLARE p_name = vc
 DECLARE p_object = c1 WITH constant(cnvtupper( $2))
 IF (cnvtupper( $1)="MINE")
  SET p_name = "ccl_findpat.dat"
 ELSE
  SET p_name = build( $1,".dat")
 ENDIF
 IF ( NOT (p_object IN ("P", "E", "V")))
  RETURN
 ENDIF
 CALL echo("Loading program names into memory...")
 SELECT INTO nl
  d.object, d.object_name
  FROM dprotect d
  WHERE d.object=p_object
   AND d.object_name=patstring(cnvtupper( $3))
   AND d.group=0
  DETAIL
   IF (mod(rec->cnt,500)=0)
    stat = alterlist(rec->qual,(rec->cnt+ 500))
   ENDIF
   rec->cnt += 1, rec->qual[rec->cnt].pname = d.object_name
  WITH counter
 ;end select
 SET num = 0
 CALL echo(build("Checking (",rec->cnt,") programs for pattern..."))
 FOR (num = 1 TO rec->cnt)
   EXECUTE value(build("CCLUTIL_FINDPAT", $4)) value(concat("_",p_name)), value(rec->qual[num].pname),
   p_object
   SET rec->totmatch += rec->fnd
   SET rec->qual[num].match = rec->fnd
   IF (((( $5=1)) OR (mod(num,10)=0)) )
    CALL echo(build(num,"/",rec->cnt,"/",rec->totmatch,
      ")",rec->qual[num].pname))
   ENDIF
 ENDFOR
 IF (rec->totmatch)
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = value(rec->cnt))
   DETAIL
    IF (rec->qual[d.seq].match)
     rec->qual[d.seq].pname, row + 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Number match found(",rec->totmatch,") output file(",p_name,")"))
END GO
