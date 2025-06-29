CREATE PROGRAM dm_ocd_bld_adm_list:dba
 CALL addtbl("DM_COLUMNS_DOC",25)
 CALL addtbl("DM_INSTALL_PLAN",2)
 CALL addtbl("DM_AFD_CODE_SET_EXTENSION",0)
 CALL addtbl("DM_AFD_CODE_VALUE",0)
 CALL addtbl("DM_AFD_CODE_VALUE_ALIAS",0)
 CALL addtbl("DM_AFD_CODE_VALUE_EXTENSION",0)
 CALL addtbl("DM_AFD_CODE_VALUE_SET",32)
 CALL addtbl("DM_AFD_COLUMNS",0)
 CALL addtbl("DM_AFD_COMMON_DATA_FOUNDATION",0)
 CALL addtbl("DM_AFD_CONSTRAINTS",14)
 CALL addtbl("DM_AFD_CONS_COLUMNS",0)
 CALL addtbl("DM_AFD_INDEXES",13)
 CALL addtbl("DM_AFD_INDEX_COLUMNS",0)
 CALL addtbl("DM_AFD_TABLES",14)
 CALL addtbl("DM_ALPHA_FEATURES",9)
 CALL addtbl("DM_ALPHA_FEATURES_ENV",0)
 CALL addtbl("DM_ENV_FILES",0)
 CALL addtbl("DM_MIN_TSPACE_SIZE",0)
 CALL addtbl("DM_OCD_APPLICATION",27)
 CALL addtbl("DM_OCD_APP_TASK_R",0)
 CALL addtbl("DM_OCD_FEATURES",0)
 CALL addtbl("DM_OCD_LOG",0)
 CALL addtbl("DM_OCD_PRODUCT_AREA",0)
 CALL addtbl("DM_OCD_README",0)
 CALL addtbl("DM_OCD_REQUEST",25)
 CALL addtbl("DM_OCD_TASK",18)
 CALL addtbl("DM_OCD_TASK_REQ_R",0)
 CALL addtbl("DM_README",0)
 CALL addtbl("DM_SCHEMA_VERSION",0)
 CALL addtbl("DM_TABLES_DOC",45)
 CALL addtbl("DM_INDEXES_DOC",13)
 CALL addtbl("REF_INSTANCE_ID",0)
 CALL addtbl("REF_REPORT_LOG",0)
 CALL addtbl("REF_REPORT_PARMS_LOG",0)
 CALL addtbl("SPACE_OBJECTS",0)
 CALL addtbl("REF_RPT_PARM_XREF",0)
 CALL addtbl("REF_REPORT_PARMS",0)
 CALL addtbl("REF_REPORTS",0)
 CALL addtbl("REF_DBA_FREE_SPACE",0)
 CALL addtbl("DM_ADM_PURGE_TEMPLATE",0)
 CALL addtbl("DM_ADM_PURGE_TOKEN",0)
 CALL addtbl("DM_ADM_PURGE_TABLE",0)
 CALL addtbl("DM_SIZE_DB_VERSION",0)
 CALL addtbl("DM_AFE_SHIP",0)
 CALL addtbl("DM_README_HIST_SHIP",0)
 CALL addtbl("DM_ENVIRONMENT",0)
 CALL addtbl("DM_REF_DOMAIN",0)
 CALL addtbl("DM_TS_PRECEDENCE",13)
 CALL addtbl("OCD_README_COMPONENT",6)
 CALL addtbl("DM_CODE_SET",17)
 CALL addtbl("DM_ENV_RELTN",5)
 CALL addtbl("DM_OCD_LOG_SHIP",14)
 CALL addtbl("DM_AFD_CODE_VALUE_GROUP",11)
 SUBROUTINE addtbl(at_tbl_name,at_col_cnt)
   SET radm->tcnt = (radm->tcnt+ 1)
   SET stat = alterlist(radm->qual,radm->tcnt)
   SET radm->qual[radm->tcnt].tname = at_tbl_name
   SET radm->qual[radm->tcnt].syn_exist = 0
   SET radm->qual[radm->tcnt].def_exist = 0
   SET radm->qual[radm->tcnt].col_cnt = at_col_cnt
 END ;Subroutine
END GO
