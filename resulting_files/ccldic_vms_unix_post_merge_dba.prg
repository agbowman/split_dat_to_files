CREATE PROGRAM ccldic_vms_unix_post_merge:dba
 PROMPT
  "Show object names     (N): " = "N"
 DECLARE dictrcode_file = c1 WITH constant("1")
 DECLARE dictrcode_rectype = c1 WITH constant("2")
 DECLARE dictrcode_table = c1 WITH constant("3")
 DECLARE dictrcode_tableattr = c1 WITH constant("4")
 DECLARE dictrcode_protect = c1 WITH constant("5")
 DECLARE dictrcode_uaf = c1 WITH constant("6")
 DECLARE dictrcode_tam = c1 WITH constant("7")
 DECLARE dictrcode_gen = c1 WITH constant("8")
 DECLARE dictrcode_compile = c1 WITH constant("9")
 IF (findfile("ccldictmp2.dat")=0)
  CALL echo("ccldictmp2.dat file not found")
  RETURN
 ELSEIF (findfile("ccldir:dic.dat")=0)
  CALL echo("ccldir:dic.dat file not found")
  RETURN
 ENDIF
 FREE DEFINE dictmpfrom
 FREE DEFINE dictmpto
 SELECT INTO TABLE dictmpfrom
  ky1 = fillstring(40," "), data = fillstring(810," "), rest = " "
  FROM dummyt
  WHERE 1=0
  ORDER BY ky1
  WITH nocounter, format = binary
 ;end select
 UPDATE  FROM dfile d
  SET d.file_format = "B"
  WHERE d.file_name="DICTMPFROM"
   AND d.file_format != "B"
 ;end update
 SELECT INTO TABLE dictmpto
  ky1 = fillstring(40," "), data = fillstring(810," ")
  FROM dummyt
  WHERE 1=0
  ORDER BY ky1
  WITH nocounter, organization = i
 ;end select
 FREE DEFINE dictmpfrom
 FREE DEFINE dictmpto
 DEFINE dictmpfrom "ccldictmp2.dat"
 DEFINE dictmpto "ccldir:dic.dat"  WITH modify
 IF (cnvtupper( $1)="Y")
  SELECT INTO "MINE"
   ky1 = check(substring(1,40,d1.ky1))
   FROM dictmpfrom d1,
    dictmpto d2
   PLAN (d1
    WHERE d1.ky1="H0000*")
    JOIN (d2
    WHERE d1.ky1=d2.ky1)
   WITH counter, dontexist, outerjoin = d1
  ;end select
 ENDIF
 INSERT  FROM dictmpfrom d1,
   dictmpto d2
  SET d2.ky1 = d1.ky1, d2.data = d1.data
  PLAN (d1)
   JOIN (d2
   WHERE d1.ky1=d2.ky1)
  WITH nocounter, dontexist, outerjoin = d1
 ;end insert
 FREE DEFINE dictmpfrom
 FREE DEFINE dictmpto
END GO
