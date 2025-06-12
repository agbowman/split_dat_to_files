CREATE PROGRAM dm_schema_ign_err:dba
 DECLARE dsie_cnt = i4
 SET dsie_cnt = size(requestin->list_0,5)
 IF (dsie_cnt > 0)
  DELETE  FROM dm_info
   WHERE info_domain="DATA MANAGEMENT"
    AND info_char="SCHEMA_IGNORED_ERROR"
  ;end delete
  INSERT  FROM dm_info d,
    (dummyt t  WITH seq = value(dsie_cnt))
   SET d.seq = 1, d.info_domain = "DATA MANAGEMENT", d.info_name = requestin->list_0[t.seq].
    error_name,
    d.info_char = "SCHEMA_IGNORED_ERROR"
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
END GO
