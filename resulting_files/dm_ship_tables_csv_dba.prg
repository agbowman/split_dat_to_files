CREATE PROGRAM dm_ship_tables_csv:dba
 EXECUTE dm_create_ship_csv "DM_ENVIRONMENT_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_ENV_CON_FILES_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_ENV_FILES_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_ENV_REDO_LOGS_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_ENV_ROLL_SEGS_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_ENV_FUNCTIONS_SHIP@R7ADM1"
 EXECUTE dm_create_ship_csv "DM_AFE_SHIP@R7ADM1"
END GO
