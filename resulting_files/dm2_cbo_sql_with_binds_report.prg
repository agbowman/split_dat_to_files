CREATE PROGRAM dm2_cbo_sql_with_binds_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search by SQL_ID or TEXT:" = "",
  "Pick the query:" = ""
  WITH outdev, i_search, i_sqlid
 EXECUTE dm2_cbo_sql_with_binds_rpt  $I_SQLID, value( $OUTDEV)
END GO
