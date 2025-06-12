CREATE PROGRAM dm_ins_dm_ref_domain_val:dba
 SET c_mod = "DM_INS_DM_REF_DOMAIN_VAL 000"
 SET debug_ind = 0
 IF ( NOT (validate(i_debug_ind,0)=0
  AND validate(i_debug_ind,1)=1))
  SET debug_ind = i_debug_ind
 ENDIF
 SET csv_str = "refdomains.csv"
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
 DECLARE qual_cnt = i4
 SET qual_cnt = size(requestin->list_0,5)
 IF (qual_cnt > 0)
  FOR (mrg_cnt = 1 TO qual_cnt)
    UPDATE  FROM dm_ref_domain dr
     SET dr.table_name = cnvtupper(requestin->list_0[mrg_cnt].table_name), dr.display_column =
      cnvtupper(requestin->list_0[mrg_cnt].display_column), dr.cki_column = cnvtupper(requestin->
       list_0[mrg_cnt].cki_column),
      dr.primary_key_column = cnvtupper(requestin->list_0[mrg_cnt].primary_key_column), dr
      .unique_ident_column = cnvtupper(requestin->list_0[mrg_cnt].unique_ident_column), dr
      .from_clause = substring(1,255,requestin->list_0[mrg_cnt].from_clause),
      dr.where_clause = substring(1,255,requestin->list_0[mrg_cnt].where_clause), dr.human_reqd_ind
       = cnvtint(requestin->list_0[mrg_cnt].human_reqd_ind), dr.source_from_clause = substring(1,255,
       requestin->list_0[mrg_cnt].source_from_clause),
      dr.code_set = cnvtint(requestin->list_0[mrg_cnt].code_set), dr.display_header = cnvtupper(
       requestin->list_0[mrg_cnt].display_header), dr.active_column = cnvtupper(requestin->list_0[
       mrg_cnt].active_column),
      dr.order_by_column = cnvtupper(requestin->list_0[mrg_cnt].order_by_column), dr.translate_name
       = cnvtupper(requestin->list_0[mrg_cnt].translate_name)
     WHERE dr.ref_domain_name=cnvtupper(trim(requestin->list_0[mrg_cnt].ref_domain_name))
     WITH nocounter
    ;end update
    COMMIT
    IF (curqual=0)
     INSERT  FROM dm_ref_domain dr
      SET dr.ref_domain_name = cnvtupper(trim(requestin->list_0[mrg_cnt].ref_domain_name)), dr
       .table_name = cnvtupper(requestin->list_0[mrg_cnt].table_name), dr.display_column = cnvtupper(
        requestin->list_0[mrg_cnt].display_column),
       dr.cki_column = cnvtupper(requestin->list_0[mrg_cnt].cki_column), dr.primary_key_column =
       cnvtupper(requestin->list_0[mrg_cnt].primary_key_column), dr.unique_ident_column = cnvtupper(
        requestin->list_0[mrg_cnt].unique_ident_column),
       dr.from_clause = substring(1,255,requestin->list_0[mrg_cnt].from_clause), dr.where_clause =
       substring(1,255,requestin->list_0[mrg_cnt].where_clause), dr.human_reqd_ind = cnvtint(
        requestin->list_0[mrg_cnt].human_reqd_ind),
       dr.source_from_clause = substring(1,255,requestin->list_0[mrg_cnt].source_from_clause), dr
       .code_set = cnvtint(requestin->list_0[mrg_cnt].code_set), dr.display_header = cnvtupper(
        requestin->list_0[mrg_cnt].display_header),
       dr.active_column = cnvtupper(requestin->list_0[mrg_cnt].active_column), dr.order_by_column =
       cnvtupper(requestin->list_0[mrg_cnt].order_by_column), dr.translate_name = cnvtupper(requestin
        ->list_0[mrg_cnt].translate_name)
      WITH nocounter
     ;end insert
     COMMIT
    ENDIF
    SELECT INTO "nl:"
     FROM dm_ref_domain_r r
     WHERE r.group_name="ALL"
      AND r.ref_domain_name=cnvtupper(requestin->list_0[mrg_cnt].ref_domain_name)
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM dm_ref_domain_r r
      SET r.group_name = "ALL", r.ref_domain_name = cnvtupper(requestin->list_0[mrg_cnt].
        ref_domain_name)
      WITH nocounter
     ;end insert
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#end_of_program
END GO
