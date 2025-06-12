CREATE PROGRAM dm_rdm_tst_import:dba
 DECLARE req_size = i4 WITH public, constant(size(requestin->list_0,5))
 SELECT INTO "nl:"
  FROM dm_table_list dtl
  WHERE dtl.table_name IN ("DM_README", "DM_TABLE_LIST", "JASON_TEST")
  WITH nocounter
 ;end select
 IF (curqual=0)
  FOR (for_cnt = 1 TO req_size)
    INSERT  FROM dm_table_list dtl
     SET dtl.table_name = requestin->list_0[for_cnt].table_name, dtl.process_flg = cnvtint(requestin
       ->list_0[for_cnt].process_flg), dtl.updt_applctx = 0,
      dtl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtl.updt_cnt = 0, dtl.updt_id = 0,
      dtl.updt_task = 0
     WITH nocounter
    ;end insert
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM dm_table_list dtl
  WHERE dtl.table_name IN ("DM_README", "DM_TABLE_LIST", "JASON_TEST")
  WITH nocounter
 ;end select
 IF (curqual=3)
  CALL echo("*** DM_TABLE_LIST import SUCCESSFUl ***")
  COMMIT
 ELSE
  CALL echo("*** ERROR: import failure ***")
  ROLLBACK
 ENDIF
END GO
