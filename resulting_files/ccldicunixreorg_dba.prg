CREATE PROGRAM ccldicunixreorg:dba
 PROMPT
  "(R)rebuild (X)xrebuild (M)move Dictionary: " = " ",
  "from dictionary (ccldir:dic): " = "ccldir:dic"
 IF (cursys != "AIX")
  CALL echo("Ccldicunix utility is only valid on unix")
  RETURN
 ENDIF
 DECLARE com = c100
 DECLARE stat = i4
 SET tempdir = "ccluserdir"
 CALL echo(build("tempdir for build=",tempdir))
 CASE (cnvtupper(substring(1,1, $1)))
  OF "R":
   SELECT INTO TABLE "ccldir:dic3"
    ky1 = fillstring(40," "), data = fillstring(810," ")
    FROM dummyt d
    WHERE 1=0
    ORDER BY ky1
    WITH nocounter, organization = indexed
   ;end select
   FREE DEFINE dic3
   DEFINE dic3  $2  WITH nomodify
   SELECT INTO TABLE value(build(tempdir,":dicreorg"))
    d3.ky1, d3.data
    FROM dic3 d3
    WHERE d3.ky1 > " "
    ORDER BY d3.ky1
    WITH counter, organization = indexed
   ;end select
   SET com = build("$cer_exe/cclisamcheck dicreorg")
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
  OF "X":
   SELECT INTO TABLE "ccldir:dic4"
    ky1 = fillstring(40," "), data = fillstring(810," ")
    FROM dummyt d
    WHERE 1=0
    WITH nocounter, organization = sequential
   ;end select
   FREE DEFINE dic4
   DEFINE dic4  $2  WITH nomodify
   SELECT INTO TABLE value(build(tempdir,":dicreorg"))
    d4.ky1, d4.data
    FROM dic4 d4
    WHERE d4.ky1 > " "
    ORDER BY d4.ky1
    WITH counter, organization = indexed
   ;end select
   SET com = build("$cer_exe/cclisamcheck dicreorg")
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
  OF "M":
   SET com = "rm $CCLDIR/dic3.dat"
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
   SET com = "rm $CCLDIR/dic.dat"
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
   SET com = "rm $CCLDIR/dic.idx"
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
   SET com = build("mv $",cnvtupper(tempdir),"/dicreorg.dat $CCLDIR/dic.dat")
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
   SET com = build("mv $",cnvtupper(tempdir),"/dicreorg.idx $CCLDIR/dic.idx")
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
   SET com = build("$cer_exe/cclisamcheck $CCLDIR/dic")
   CALL echo(com)
   CALL dcl(com,size(trim(com)),stat)
 ENDCASE
END GO
