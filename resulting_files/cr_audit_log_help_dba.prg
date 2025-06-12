CREATE PROGRAM cr_audit_log_help:dba
 FREE DEFINE rtl
 DEFINE rtl "CER_DATA_DATA:cr_audit.dat"
 SELECT
  helpfile = rtlt.line
  FROM rtlt
 ;end select
 FREE DEFINE rtl
END GO
