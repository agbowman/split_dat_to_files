CREATE PROGRAM cclinclude:dba
 PROMPT
  "                 Enter Include file to build (ccl.inc): " = "ccl.inc",
  "           Enter Directory to include from (cclsource): " = "cclsource",
  "Enter file to include with wild card allowed (xxx.prg): " = "xxx.prg"
 DECLARE com = c100
 IF (cursys="AXP")
  SET com = concat("dir/col=1/select=file=nover/versions=1/output=tmp__1",trim( $1)," ",trim( $2),":",
   trim( $3))
 ELSE
  SET com = concat("rm tmp__1",trim( $1))
  SET com = concat("rm tmp__2",trim( $1))
  CALL dcl(com,size(com),0)
  SET logical "CCLINCLUDEDIR" value(logical( $2))
  SET com = concat('find $CCLINCLUDEDIR -name "',trim( $3),'" -exec ls -1 {} \; >> tmp__1',trim( $1))
 ENDIF
 CALL echo(com)
 CALL dcl(com,size(com),0)
 FREE DEFINE rtl
 DEFINE rtl concat("tmp__1",trim( $1))
 SET cnt = 0
 SELECT INTO concat("tmp__2",trim( $1))
  r.line
  FROM rtlt r
  WHERE  NOT (r.line IN (" ", "Grand total*", "Directory *", "Total *"))
  WITH nocounter, noheading
 ;end select
 FREE DEFINE rtl
 DEFINE rtl concat("tmp__2",trim( $1))
 SELECT INTO trim( $1)
  r.line
  FROM rtlt r
  ORDER BY r.line
  HEAD REPORT
   "%d noecho", row + 1, "set trace rebuild go",
   row + 1
  DETAIL
   cnt += 1
   IF (cursys="AXP")
    com = concat("%i ",trim( $2),":",trim(r.line))
   ELSE
    com = concat("%i ",trim(r.line))
   ENDIF
   com, row + 1
  FOOT REPORT
   "set trace norebuild go"
  WITH nocounter, noformfeed, maxrow = 1
 ;end select
 FREE DEFINE rtl
 SET stat = remove(build("tmp__1",trim( $1)))
 SET stat = remove(build("tmp__2",trim( $1)))
 CALL echo(build2(">>>The include file ", $1," contains ",cnt," objects from (",
    $2,":", $3,")"))
END GO
