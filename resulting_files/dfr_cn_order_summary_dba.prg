CREATE PROGRAM dfr_cn_order_summary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  ed.*
  FROM encntr_domain ed
  PLAN (ed)
  WITH check
 ;end select
END GO
