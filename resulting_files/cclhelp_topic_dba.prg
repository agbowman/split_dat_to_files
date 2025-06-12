CREATE PROGRAM cclhelp_topic:dba
 FREE DEFINE rtl
 DEFINE rtl "ccldir:cclhelp.dat"
 SELECT INTO mine
  line = substring(1,130,r.line)
  FROM rtlt r
  WHERE r.line != " "
  HEAD REPORT
   beg = 0
  DETAIL
   IF (beg=0)
    IF (line=concat("!!!TOPIC-", $1))
     beg = 1
    ENDIF
   ELSEIF (beg=1)
    IF (line="!!!TOPIC*"
     AND line != patstring(concat("!!!TOPIC-", $1,"*")))
     beg = 2
    ENDIF
   ENDIF
   IF (beg=1)
    line, row + 1
   ENDIF
  WITH nocounter, maxrow = 1, noformfeed
 ;end select
 FREE DEFINE rtl
END GO
