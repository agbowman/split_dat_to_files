CREATE PROGRAM dm_chk_local_admin_tables:dba
 RECORD rtables(
   1 qual[*]
     2 admin_tbl = vc
 )
 SET tbl_cnt = 0
 SET tbl_cnt = (tbl_cnt+ 1)
 SET stat = alterlist(rtables->qual,tbl_cnt)
 SET rtables->qual[tbl_cnt].admin_tbl = "DM_CODE_SET"
 SET tbl_cnt = (tbl_cnt+ 1)
 SET stat = alterlist(rtables->qual,tbl_cnt)
 SET rtables->qual[tbl_cnt].admin_tbl = "DM_TABLES_DOC"
 SET tbl_cnt = (tbl_cnt+ 1)
 SET stat = alterlist(rtables->qual,tbl_cnt)
 SET rtables->qual[tbl_cnt].admin_tbl = "DM_COLUMNS_DOC"
 SET x = 1
 SET error_ind = 0
 WHILE (x <= tbl_cnt
  AND error_ind=0)
   SET cnt = 0
   CALL parser("select into 'nl:' y = count(*) from ")
   CALL parser(rtables->qual[x].admin_tbl)
   CALL parser("detail")
   CALL parser("cnt = y")
   CALL parser("with nocounter go")
   SET cnt2 = 0
   CALL parser("select into 'nl:' z = count(*) from ")
   CALL parser(concat(rtables->qual[x].admin_tbl,"_LOCAL"))
   CALL parser("detail")
   CALL parser("cnt2 = z")
   CALL parser("with nocounter go")
   IF (cnt > 0)
    IF (cnt != cnt2)
     SET request->setup_proc[1].success_ind = 0
     SET request->setup_proc[1].error_msg = concat(rtables->qual[x].admin_tbl," has ",cnvtstring(cnt),
      " rows. ",rtables->qual[x].admin_tbl,
      "_LOCAL has ",cnvtstring(cnt2)," rows.")
     SET error_ind = 1
    ENDIF
   ELSE
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = concat(rtables->qual[x].admin_tbl,
     " has count(*)=0. Make sure synonyms to admin working.")
    SET error_ind = 1
   ENDIF
   SET x = (x+ 1)
 ENDWHILE
 IF (error_ind=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Local admin tables populated successfully."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
