CREATE PROGRAM bhs_rad_audit_acc_class_format:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  accession_class = uar_get_code_display(ac.accession_class_cd), accession_format =
  uar_get_code_display(ac.accession_format_cd)
  FROM accession_class ac
  PLAN (ac)
  ORDER BY accession_class
  WITH nocounter, format
 ;end select
END GO
