CREATE PROGRAM cclnews:dba
 FREE DEFINE rtl
 DEFINE rtl "ccldir:cclnews.dat"
 SELECT
  cclnews = rtlt.line
  FROM rtlt
 ;end select
 FREE DEFINE rtl
END GO
