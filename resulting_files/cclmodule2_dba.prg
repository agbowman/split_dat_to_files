CREATE PROGRAM cclmodule2:dba
 PROMPT
  "Extension of text file   : " = "SUB",
  "Diretory                 : " = "CCLSOURCE",
  "CCLSOURCE text file name : " = "JCM"
 IF (findfile("ccldir:dicmod.dat")=0)
  SELECT INTO TABLE "ccldir:dicmod"
   modkey = fillstring(40," "), datestamp = 0, timestamp = 0,
   source = fillstring(500," ")
   WHERE 1=0
   ORDER BY modkey
   WITH nocounter, organization = indexed
  ;end select
 ENDIF
 DEFINE dicmod "ccldir:dicmod"  WITH modify
 DECLARE modbuffer = c500
 DECLARE modkey = c40
 DECLARE buffer = c200
 DECLARE module_dir = c30
 DECLARE module_ext = c3
 DECLARE module_name = c30
 DECLARE stat = i4
 DECLARE stat2 = i4
 DECLARE len = i4
 DECLARE pos = i4
 RECORD mrec(
   1 nrow = i4
   1 qual[1]
     2 line = c500
 )
 SET module_ext = cnvtlower( $1)
 SET module_dir = cnvtlower( $2)
 SET module_name = cnvtlower( $3)
 SET buffer = concat(trim(module_dir),":",trim(module_name),".",trim(module_ext))
 SET stat = findfile(trim(buffer))
 IF (stat=1)
  FREE DEFINE rtl
  DEFINE rtl trim(buffer)  WITH modify
  SET modbuffer = " "
  SET pos = 1
  SET mrec->nrow = 1
  SELECT INTO "nl:"
   r.line
   FROM rtlt r
   WHERE r.line != " "
   DETAIL
    len = size(trim(r.line))
    IF (((((((pos+ len)+ 3)+ 4)+ 4)+ 10) >= size(modbuffer)))
     stat2 = alter(mrec->qual,(mrec->nrow+ 1)), mrec->qual[mrec->nrow].line = modbuffer, mrec->nrow
      += 1,
     pos = 1, modbuffer = " "
    ENDIF
    stat2 = movestring(format(len,"###;rp0"),1,modbuffer,pos,3), pos += 3, stat2 = movestring(r.line,
     1,modbuffer,pos,len),
    pos += len
   FOOT REPORT
    mrec->qual[mrec->nrow].line = modbuffer
   WITH nocounter, maxrow = 1, noformfeed
  ;end select
  DELETE  FROM dicmod m
   WHERE m.modkey=patstring(concat(cnvtupper(module_name),cnvtupper(module_ext),"*"))
   WITH nocounter
  ;end delete
  SET datestamp = curdate
  SET timestamp = curtime2
  INSERT  FROM dicmod m,
    (dummyt d  WITH seq = value(mrec->nrow))
   SET modkey = concat(cnvtupper(module_name),cnvtupper(module_ext),format(d.seq,"#######;rp0")), m
    .modkey = modkey, m.datestamp = datestamp,
    m.timestamp = timestamp, m.source = mrec->qual[d.seq].line
   PLAN (d)
    JOIN (m
    WHERE "<notfound>"=m.modkey)
   WITH nocounter, dontexist, outerjoin = d
  ;end insert
  FREE DEFINE rtl
 ENDIF
 FREE DEFINE rtl
 SET g_status = stat
END GO
