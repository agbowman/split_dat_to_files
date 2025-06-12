CREATE PROGRAM cv_util_sync_nomenclature:dba
 PROMPT
  "Output(Mine):" = mine
 EXECUTE cv_updt_response_with_nomen
 COMMIT
END GO
