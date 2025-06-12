CREATE PROGRAM dm2_dbstats_tbl_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Table Criteria:" = "",
  "Display Histogram (YES/NO) : " = ""
  WITH outdev, i_table, i_hist
 EXECUTE dm2_dbstats_table_rpt "NOPROMPT",  $I_TABLE, value( $OUTDEV),
 "LIVE",  $I_HIST
END GO
