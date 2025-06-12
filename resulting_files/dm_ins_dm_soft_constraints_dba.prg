CREATE PROGRAM dm_ins_dm_soft_constraints:dba
 SET c_mod = "DM_INS_DM_SOFT_CONSTRAINTS 000"
 DECLARE debug_ind = i4
 SET debug_ind = 0
 IF ( NOT (validate(i_debug_ind,0)=0
  AND validate(i_debug_ind,1)=1))
  SET debug_ind = i_debug_ind
 ENDIF
 SET csv_str = "dmsoftcons.csv"
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
 )
 IF (debug_ind)
  SET trace = callecho
 ENDIF
 DECLARE qual_cnt = i4
 SET qual_cnt = size(requestin->list_0,5)
 DECLARE column_ind = i4
 SET column_ind = 1
 IF (validate(requestin->list_0[1].code_set,"0")="0"
  AND validate(requestin->list_0[1].code_set,"1")="1")
  SET column_ind = 0
 ENDIF
 IF (qual_cnt > 0)
  SET stat = alterlist(rec_action->qual,qual_cnt)
  SET errcode = error(errmsg,1)
  IF (column_ind=1)
   INSERT  FROM dm_soft_constraints dsc,
     (dummyt d  WITH seq = value(qual_cnt))
    SET dsc.parent_table = trim(cnvtupper(requestin->list_0[d.seq].parent_table)), dsc.child_table =
     trim(cnvtupper(requestin->list_0[d.seq].child_table)), dsc.parent_column = trim(cnvtupper(
       requestin->list_0[d.seq].parent_column)),
     dsc.child_column = trim(cnvtupper(requestin->list_0[d.seq].child_column)), dsc.child_where =
     trim(cnvtupper(requestin->list_0[d.seq].child_where)), dsc.code_set = cnvtint(requestin->list_0[
      d.seq].code_set),
     dsc.exclude_ind = cnvtint(requestin->list_0[d.seq].exclude_ind), dsc.reference_ind = cnvtint(
      requestin->list_0[d.seq].reference_ind)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dsc)
    WITH nocounter, outerjoin = d
   ;end insert
   COMMIT
  ELSE
   INSERT  FROM dm_soft_constraints dsc,
     (dummyt d  WITH seq = value(qual_cnt))
    SET dsc.parent_table = trim(cnvtupper(requestin->list_0[d.seq].parent_table)), dsc.child_table =
     trim(cnvtupper(requestin->list_0[d.seq].child_table)), dsc.parent_column = trim(cnvtupper(
       requestin->list_0[d.seq].parent_column)),
     dsc.child_column = trim(cnvtupper(requestin->list_0[d.seq].child_column)), dsc.child_where =
     trim(cnvtupper(requestin->list_0[d.seq].child_where))
    PLAN (d
     WHERE (requestin->list_0[d.seq].parent_table != ""))
     JOIN (dsc)
    WITH nocounter, outerjoin = d
   ;end insert
   COMMIT
  ENDIF
  IF ( NOT (debug_ind))
   DELETE  FROM dm_soft_constraints a
    WHERE  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_user_tab_cols b
     WHERE a.child_table=b.table_name
      AND a.child_column=b.column_name)))
    WITH nocounter
   ;end delete
   COMMIT
  ENDIF
 ENDIF
#end_of_program
END GO
