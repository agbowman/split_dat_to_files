CREATE PROGRAM dm_ins_dm_columns_doc:dba
 SET c_mod = "DM_INS_DM_COLUMNS_DOC 000"
 DECLARE debug_ind = i4
 SET debug_ind = 0
 SET inhouse_ind = 0
 SELECT INTO "nl:"
  d.*
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   inhouse_ind = 1
  WITH nocounter
 ;end select
 IF (inhouse_ind=1)
  CALL echo("******************************************************",1,0)
  CALL echo("Inhouse environment detected.  Discontinuing activity.",1,0)
  CALL echo("******************************************************",1,0)
  GO TO end_of_program
 ENDIF
 SET update_ind = 1
 SET csv_str = "dmrcoldoc.csv"
 SET c_interactive_ccl = 0
 SET c_server = 1
 SET c_batch_process = 1
 IF (validate(requestin,"Y")="Y"
  AND validate(requestin,"Z")="Z"
  AND curenv=c_interactive_ccl)
  IF (cursys="AIX")
   SET com_proc_str = "ksh"
  ELSE
   SET com_proc_str = "com"
  ENDIF
  CALL echo(concat("Preparing to run dm_readme_batch to create and run a '.",com_proc_str,
    "' command file in ccluserdir."),1,0)
  IF (validate(block_int,0)=0
   AND validate(block_int,1)=1)
   SET block_int = 5000
  ENDIF
  FREE SET parser_str
  IF (debug_ind)
   SET parser_str = concat('pmw_readme_import "',trim(cnvtlower(csv_str)),'","',curprog,'",',
    build(block_int),",0 go")
  ELSE
   SET parser_str = concat('dm_readme_import "',trim(cnvtlower(csv_str)),'","',curprog,'",',
    build(block_int),",0 go")
  ENDIF
  CALL echo(parser_str,1,0)
  CALL parser(parser_str)
  GO TO end_of_program
 ENDIF
 SET errcode = 1
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,1)
 FREE RECORD rec_action
 RECORD rec_action(
   1 qual[*]
     2 status = i4
     2 errnum = i4
     2 errmsg = c132
     2 update_flag = i4
 )
 DECLARE commit_ind = i4
 IF ( NOT (validate(reqinfo,"Y")="Y"
  AND validate(reqinfo,"Z")="Z"))
  SET reqinfo->commit_ind = 1
  SET commit_ind = 1
 ENDIF
 IF ( NOT (validate(reply,"Y")="Y"
  AND validate(reply,"Z")="Z"))
  SET reply->status = "S"
 ENDIF
 CALL echo(curprog,1,0)
 DECLARE qual_cnt = i4
 SET qual_cnt = size(requestin->list_0,5)
 IF (qual_cnt > 0)
  SET stat = alterlist(rec_action->qual,qual_cnt)
  IF (update_ind)
   CALL echo("Performing update.",1,0)
   UPDATE  FROM dm_columns_doc t,
     (dummyt d  WITH seq = value(qual_cnt))
    SET t.sequence_name = requestin->list_0[d.seq].sequence_name, t.code_set = cnvtint(requestin->
      list_0[d.seq].code_set), t.unique_ident_ind = cnvtint(requestin->list_0[d.seq].unique_ident_ind
      ),
     t.root_entity_name = requestin->list_0[d.seq].root_entity_name, t.root_entity_attr = requestin->
     list_0[d.seq].root_entity_attr, t.parent_entity_col = requestin->list_0[d.seq].parent_entity_col,
     t.exception_flg = cnvtint(requestin->list_0[d.seq].exception_flg), t.constant_value = requestin
     ->list_0[d.seq].constant_value
    PLAN (d
     WHERE d.seq > 0)
     JOIN (t
     WHERE (t.table_name=requestin->list_0[d.seq].table_name)
      AND (t.column_name=requestin->list_0[d.seq].column_name))
    WITH nocounter, status(rec_action->qual[d.seq].status,rec_action->qual[d.seq].errnum,rec_action->
     qual[d.seq].errmsg)
   ;end update
   COMMIT
  ENDIF
  CALL echo("Performing insert.",1,0)
  INSERT  FROM dm_columns_doc t,
    (dummyt d  WITH seq = value(qual_cnt))
   SET t.table_name = requestin->list_0[d.seq].table_name, t.column_name = requestin->list_0[d.seq].
    column_name, t.sequence_name = requestin->list_0[d.seq].sequence_name,
    t.code_set = cnvtint(requestin->list_0[d.seq].code_set), t.unique_ident_ind = cnvtint(requestin->
     list_0[d.seq].unique_ident_ind), t.root_entity_name = requestin->list_0[d.seq].root_entity_name,
    t.root_entity_attr = requestin->list_0[d.seq].root_entity_attr, t.parent_entity_col = requestin->
    list_0[d.seq].parent_entity_col, t.exception_flg = cnvtint(requestin->list_0[d.seq].exception_flg
     ),
    t.constant_value = requestin->list_0[d.seq].constant_value
   PLAN (d
    WHERE (rec_action->qual[d.seq].status=0)
     AND  NOT ((requestin->list_0[d.seq].table_name IN ("", " ")))
     AND  NOT ((requestin->list_0[d.seq].column_name IN ("", " "))))
    JOIN (t)
   WITH nocounter, outerjoin = d, status(rec_action->qual[d.seq].status,rec_action->qual[d.seq].
    errnum,rec_action->qual[d.seq].errmsg)
  ;end insert
  COMMIT
 ENDIF
#end_of_program
END GO
