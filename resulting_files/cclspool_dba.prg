CREATE PROGRAM cclspool:dba
 PROMPT
  "Enter file name : " = "ccluserdir:jcm1.dat",
  "Enter printer name : " = "p353",
  "Enter print type (compress,landscape,postscript) : " = "compress",
  "Enter tray name : " = "tray1"
 RECORD rec(
   1 stat = i4
   1 pos = i4
   1 len = i4
   1 com = vc
   1 fname = vc
   1 debugit = i1
 )
 IF (cursys="AIX")
  SET rec->pos = findstring(":", $1)
  SET rec->len = size(trim( $1))
  IF (rec->pos)
   SET rec->fname = build(logical(substring(1,(rec->pos - 1),cnvtlower( $1))),"/",substring((rec->pos
     + 1),(rec->len - rec->pos),cnvtlower( $1)))
  ELSE
   SET rec->fname = build(logical("ccluserdir"),"/",substring((rec->pos+ 1),(rec->len - rec->pos),
     cnvtlower( $1)))
  ENDIF
  SET rec->com = build("$cer_forms/print_file -b -c1 -P",cnvtlower( $2)," -f",cnvtlower(substring(1,4,
      $3))," -f",
    $4,concat(" ",trim(rec->fname)))
  CALL dcl(rec->com,size(trim(rec->com)),rec->stat)
 ELSE
  SET rec->fname = cnvtlower( $1)
  CASE (cnvtlower( $3))
   OF "compress":
    SET spool value(rec->fname)  $2 WITH compress, print =  $4
   OF "landscape":
    SET spool value(rec->fname)  $2 WITH landscape, print =  $4
   OF "compress,landscape":
    SET spool value(rec->fname)  $2 WITH compress, landscape, print =  $4
   OF "postscript":
    SET spool value(rec->fname)  $2 WITH dio = 8, print =  $4
  ENDCASE
  SET rec->com = build("set spool ",concat(" ",value(rec->fname)),concat(" ",cnvtlower( $2)),concat(
    " with ", $3,",print=", $4))
 ENDIF
 SET rec->debugit = 0
 IF (rec->debugit)
  CALL echo(build("com=",rec->com," stat=",rec->stat))
 ENDIF
END GO
