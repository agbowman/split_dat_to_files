CREATE PROGRAM dm_ocd_check_domain:dba
 SET docd_reply->status = "S"
 SET link_name = fillstring(128," ")
 EXECUTE dm_upd_ccl_rec_len
 SELECT INTO "nl:"
  a.synonym_name
  FROM all_synonyms a
  WHERE a.synonym_name="DM_ENVIRONMENT"
  DETAIL
   link_name = trim(a.db_link)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = "NO SYNONYM EXISTS FOR DM_ENVIRONMENT. RUN DM_CDBA_SYNONYM."
  GO TO docd_exit
 ENDIF
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docd_reply->status = "L"
  SET docd_reply->err_msg = concat("CURRENT ADMIN DBLINK=",link_name)
  GO TO docd_exit
 ENDIF
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i,
   dm_environment e
  WHERE i.info_name="DM_ENV_ID"
   AND i.info_domain="DATA MANAGEMENT"
   AND i.info_number=e.environment_id
   AND i.info_number > 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docd_reply->status = "Z"
  SET docd_reply->err_msg = "SET UP ENVIRONMENT ROW IN DM_INFO."
  GO TO docd_exit
 ENDIF
 SET syn_cnt = 0
 SELECT INTO "nl:"
  a.synonym_name
  FROM all_synonyms a,
   (dummyt d  WITH seq = value(radm->tcnt))
  PLAN (d)
   JOIN (a
   WHERE (a.synonym_name=radm->qual[d.seq].tname))
  DETAIL
   syn_cnt = (syn_cnt+ 1), radm->qual[d.seq].syn_exist = 1
  WITH nocounter
 ;end select
 IF ((syn_cnt < radm->tcnt))
  SELECT INTO "dm_ocd_check_domain.log"
   d.seq
   FROM (dummyt d  WITH seq = value(radm->tcnt))
   PLAN (d
    WHERE (radm->qual[d.seq].syn_exist=0))
   HEAD REPORT
    row + 1, col 1, "THE FOLLOWING SYNONYMS DID NOT EXIST WHEN THE DOMAIN WAS CHECKED",
    row + 1
   DETAIL
    row + 1, radm->qual[d.seq].tname
   WITH nocounter
  ;end select
  SET docd_reply->status = "Z"
  SET docd_reply->err_msg = "CREATE SYNONYMS FOR OCD TABLES IN ADMIN."
  GO TO docd_exit
 ENDIF
 FOR (chk_cnt = 1 TO radm->tcnt)
   IF ( NOT (chk_ccl_tbl_def(radm->qual[chk_cnt].tname,radm->qual[chk_cnt].col_cnt)))
    SELECT INTO "dm_ocd_check_domain.log"
     d.seq
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     HEAD REPORT
      row + 1, col 1, "THE FOLLOWING CCL DEFINITION DID NOT EXIST",
      row + 1, col 1, "OR DID NOT HAVE CORRECT COLUMN COUNT",
      row + 1, col 1, "WHEN THE DOMAIN WAS CHECKED",
      row + 1
     DETAIL
      row + 1, radm->qual[chk_cnt].tname
     WITH nocounter
    ;end select
    SET docd_reply->status = "Z"
    SET docd_reply->err_msg = "CREATE CCL DEFS FOR OCD TABLES IN ADMIN."
    GO TO docd_exit
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="DM_TABLES_DOC_LOCAL"
   AND u.column_name="FREELIST_CNT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docd_reply->status = "Z"
  SET docd_reply->err_msg = "DM_TABLES_DOC_LOCAL DOES NOT HAVE NEW COLUMN FREELIST_CNT"
  GO TO docd_exit
 ENDIF
 SELECT INTO "nl:"
  l.attr_name
  FROM dtableattr a,
   dtableattrl l
  WHERE l.structtype="F"
   AND btest(l.stat,11)=0
   AND a.table_name="DM_SIZE_DB_VERSION"
   AND l.attr_name="CORE_SIZE"
   AND l.type="F"
   AND l.len=8
 ;end select
 IF (curqual=0)
  SET docd_reply->status = "Z"
  SET docd_reply->err_msg = "CORE_SIZE COLUMN ON DM_SIZE_DB_VERSION TABLE NOT SET TO F8"
  GO TO docd_exit
 ENDIF
 SUBROUTINE chk_ccl_tbl_def(ctd_tbl_name,ctd_col_cnt)
   IF (ctd_col_cnt=0)
    SELECT INTO "nl:"
     d.table_name
     FROM dtable d
     WHERE d.table_name=ctd_tbl_name
     WITH nocounter
    ;end select
    RETURN(curqual)
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr d,
      dtableattrl l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0
      AND d.table_name=ctd_tbl_name
     WITH nocounter
    ;end select
    IF (curqual >= ctd_col_cnt)
     RETURN(curqual)
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
 END ;Subroutine
#docd_exit
 IF ((docd_reply->status="Z"))
  SELECT INTO "nl:"
   i.info_name
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DOMAIN SETUP CURRENTLY EXECUTING"
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info i
    SET i.info_domain = "DATA MANAGEMENT", i.info_name = "DOMAIN SETUP CURRENTLY EXECUTING", i
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     i.updt_cnt = 0, i.updt_task = 0, i.updt_id = 0,
     i.updt_applctx = 0
    WITH nocounter
   ;end insert
   COMMIT
  ELSE
   SET docd_reply->status = "D"
   SET docd_reply->err_msg = concat("Another OCD is currently setting up the domain. ",
    "Please run ocd_incl_schema again in a few minutes.")
  ENDIF
 ENDIF
END GO
