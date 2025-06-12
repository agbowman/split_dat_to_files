CREATE PROGRAM ccldicdiff2:dba
 FREE DEFINE rtl
 DEFINE rtl "cclcheck1"
 SELECT INTO "cclcheck2"
  object = substring(1,1,r.line), object_name = substring(3,31,r.line), group = cnvtint(substring(36,
    2,r.line)),
  datestamp = cnvtint(substring(39,5,r.line)), timestamp = cnvtint(substring(45,6,r.line))
  FROM dprotect d,
   rtlt r
  PLAN (r
   WHERE r.line > " ")
   JOIN (d
   WHERE substring(1,1,r.line)=d.object
    AND substring(3,31,r.line)=d.object_name
    AND cnvtint(substring(36,2,r.line))=d.group
    AND cnvtint(substring(39,5,r.line))=d.datestamp
    AND cnvtint(substring(45,6,r.line))=d.timestamp)
  WITH counter, check, outerjoin = r,
   dontexist, noheading
 ;end select
 FREE DEFINE rtl
END GO
