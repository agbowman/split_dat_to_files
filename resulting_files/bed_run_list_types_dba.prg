CREATE PROGRAM bed_run_list_types:dba
 PROMPT
  "Enter 1 to allow rollback, 0 to auto-commit: " = "1"
  WITH response
 DECLARE dm_dbi_parent_commit_ind = i2
 DECLARE resp = vc
 SET resp =  $RESPONSE
 SET dm_dbi_parent_commit_ind = cnvtint(resp)
 SET filename = "CER_INSTALL:BED_LIST_TYPES.CSV"
 SET scriptname = "BED_IMP_LIST_TYPES"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
