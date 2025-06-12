CREATE PROGRAM cclnewsold:dba
 FREE DEFINE rtl
 DEFINE rtl "ccldir:cclnews_77.dat"
 SELECT
  cclnews = rtlt.line
  FROM rtlt
 ;end select
 FREE DEFINE rtl
END GO
