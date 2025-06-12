CREATE PROGRAM ccl_rpt_audit_config:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  audit_type = substring(1,15,d.info_char), name = substring(1,30,d.info_name), d.info_date
  "@MEDIUMDATETIME",
  prsnl_id = d.info_number, d.updt_dt_tm"@MEDIUMDATETIME", updt_username = p.username
  FROM dm_info d,
   prsnl p
  PLAN (d
   WHERE d.info_domain="CCL_REPORT_AUDIT")
   JOIN (p
   WHERE (d.updt_id= Outerjoin(p.person_id)) )
  ORDER BY d.info_char, d.info_name
  WITH format, separator = " "
 ;end select
END GO
