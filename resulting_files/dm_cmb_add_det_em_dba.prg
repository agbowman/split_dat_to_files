CREATE PROGRAM dm_cmb_add_det_em:dba
 SUBROUTINE chk_ccl_def_tbl_col(ctbl_name,ccol_name)
   SET tbl_ignore_ind = 0
   SET col_ignore_ind = 0
   SET tbl_ignore_ind = chk_ccl_def_tbl(ctbl_name)
   IF ((((tbl_ignore_ind=- (1))) OR (tbl_ignore_ind=1)) )
    RETURN(tbl_ignore_ind)
   ELSE
    SET col_ignore_ind = chk_ccl_def_col(ctbl_name,ccol_name)
    RETURN(col_ignore_ind)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_ccl_def_tbl(dtbl_name)
   SET tbl_row_cnt = - (1)
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name=cnvtupper(trim(dtbl_name,3))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     table_name
     FROM user_tab_columns
     WHERE table_name=cnvtupper(trim(dtbl_name,3))
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
    SET tbl_row_cnt = chk_row_cnt(dtbl_name)
    IF (dm_debug_cmb)
     CALL echo(build("Table ",dtbl_name,"'s row_cnt =",tbl_row_cnt))
    ENDIF
    IF (((tbl_row_cnt=1) OR (tbl_row_cnt=0)) )
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_ccl_def_col(ftbl_name,fcol_name)
   FREE RECORD ccdc_excl
   RECORD ccdc_excl(
     1 excl_cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   DECLARE ccdc_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM user_tab_cols u
    WHERE u.table_name=cnvtupper(trim(ftbl_name,3))
     AND ((u.hidden_column="YES") OR (((u.virtual_column="YES") OR (u.column_name="LAST_UTC_TS")) ))
    DETAIL
     ccdc_excl->excl_cnt += 1, stat = alterlist(ccdc_excl->qual,ccdc_excl->excl_cnt), ccdc_excl->
     qual[ccdc_excl->excl_cnt].column_name = u.column_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (expand(ccdc_idx,1,ccdc_excl->excl_cnt,l.attr_name,ccdc_excl->qual[ccdc_idx].
     column_name))
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE chk_row_cnt(rtbl_name)
   SET cr_cnt = - (1)
   DELETE  FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    WITH nocounter
   ;end delete
   CALL parser("rdb insert into dm_info (info_domain, info_name, info_number) ")
   CALL parser(concat(" (select 'CMB ROW CNT', '",trim(cnvtupper(rtbl_name)),"', t.cnt ",
     "from (select count(*) cnt from ",trim(cnvtupper(rtbl_name)),
     " ) t) go"))
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    DETAIL
     cr_cnt = d.info_number
    WITH nocounter
   ;end select
   DELETE  FROM dm_info d
    WHERE d.info_domain="CMB ROW CNT"
     AND d.info_name=cnvtupper(rtbl_name)
    WITH nocounter
   ;end delete
   RETURN(cr_cnt)
 END ;Subroutine
 SUBROUTINE ucb_chk_ccl_def_tbl(utbl_name)
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name=cnvtupper(trim(utbl_name,3))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     u.table_name
     FROM user_tab_columns u
     WHERE u.table_name=cnvtupper(trim(utbl_name,3))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(- (1))
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE cmb_get_ccl_version(null) = i4
 SUBROUTINE cmb_get_ccl_version(null)
   DECLARE cmb_ccl_version = i4
   IF (validate(curcclver,0) != 0)
    SET cmb_ccl_version = curcclver
   ELSE
    SET cmb_ccl_version = ((cnvtint((currev * 10000))+ cnvtint((currevminor * 100)))+ cnvtint(
     currevminor2))
   ENDIF
   RETURN(cmb_ccl_version)
 END ;Subroutine
 FREE RECORD cmb_temp
 RECORD cmb_temp(
   1 list[*]
     2 row_exists = i4
     2 pk_id = f8
   1 det_cnt = i4
   1 child_table = vc
   1 child_cmb_col = vc
   1 child_pk_col = vc
   1 parent_table = vc
   1 parent_cmb_col = vc
   1 from_clause = vc
   1 where_clause = vc
   1 cmd_str = vc
   1 err_code = i4
   1 err_msg = c132
   1 row_cnt = i4
 )
 SET stat = alterlist(request->xxx_combine_det,0)
 SET stat = alterlist(cmb_temp->list,0)
 SET cmb_temp->det_cnt = 0
 SET idx = 0
 SET cmb_temp->child_table =  $1
 SET cmb_temp->child_cmb_col =  $2
 SET cmb_temp->child_pk_col =  $3
 SET cmb_temp->parent_table =  $4
 SET cmb_temp->parent_cmb_col =  $5
 SET cmb_temp->from_clause =  $6
 SET cmb_temp->where_clause =  $7
 SET cmb_temp->where_clause = replace(cmb_temp->where_clause,"<<CMB_FROM_ID>>",
  "request->xxx_combine[iCombine].from_xxx_id")
 SET cmb_temp->where_clause = replace(cmb_temp->where_clause,"<<CMB_TO_ID>>",
  "request->xxx_combine[iCombine].to_xxx_id")
 SET cmb_temp->where_clause = replace(cmb_temp->where_clause,"<<CMB_ENCNTR_ID>>",
  "request->xxx_combine[iCombine].encntr_id")
 SET dm_str = fillstring(132," ")
 SET cmb_det_exists_cnt = 0
 SET cmb_temp->err_code = error(cmb_temp->err_msg,1)
 SET cmb_temp->cmd_str = concat("select distinct into 'nl:' ",cmb_temp->child_table,".",cmb_temp->
  child_pk_col,char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str," from ",cmb_temp->from_clause,char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"where ",cmb_temp->where_clause,char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"and ",cmb_temp->child_table,".",cmb_temp->
  child_pk_col,
  " not in",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"  (select pcd.entity_id from ",trim(cmb_det_table),
  " pcd",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   where pcd.",trim(cmb_table_id),
  " = request->xxx_combine[iCombine]->xxx_combine_id ",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   and pcd.entity_name = '",cmb_temp->child_table,
  "'",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   and pcd.attribute_name = '",cmb_temp->
  child_cmb_col,"')",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"detail cmb_temp->det_cnt = cmb_temp->det_cnt + 1",
  char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,
  "stat = alterlist(cmb_temp->list, cmb_temp->det_cnt)",char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"cmb_temp->list[cmb_temp->det_cnt].pk_id = ",
  cmb_temp->child_table,".",cmb_temp->child_pk_col,
  char(10))
 SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"with nocounter go")
 IF (dm_debug_cmb)
  CALL echo(cmb_temp->cmd_str)
 ENDIF
 CALL parser(cmb_temp->cmd_str,1)
 SET cmb_temp->err_code = error(cmb_temp->err_msg,1)
 IF ((cmb_temp->err_code != 0))
  SET cmb_temp->row_cnt = chk_row_cnt(cmb_temp->child_table)
  IF (dm_debug_cmb)
   CALL echo(build("Table:",cmb_temp->child_table," row_cnt =",cmb_temp->row_cnt))
  ENDIF
  IF ((cmb_temp->row_cnt > 1))
   SET request->error_message = cmb_temp->err_msg
   SET error_table = cmb_temp->child_table
   SET failed = select_error
   GO TO cmb_check_error
  ELSE
   SET cmb_temp->err_code = 0
   IF (dm_debug_cmb)
    CALL echo("Error for table:",cmb_temp->child_table," will be ignored")
   ENDIF
  ENDIF
 ENDIF
 IF (dm_debug_cmb)
  CALL echorecord(cmb_temp)
 ENDIF
 IF ((cmb_temp->det_cnt > 0))
  SET cmb_temp->cmd_str = concat("update into ",cmb_temp->child_table," x",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"  set x.",cmb_temp->child_cmb_col,
   " = request->xxx_combine[iCombine].to_xxx_id",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,",x.updt_cnt = x.updt_cnt + 1",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,",x.updt_dt_tm = cnvtdatetime(curdate, curtime3)",
   char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,",x.updt_id = reqinfo->updt_id",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,",x.updt_task = 100102",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,",x.updt_applctx = reqinfo->updt_applctx",char(10)
   )
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"where expand(idx,1,cmb_temp->det_cnt,",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"x.",cmb_temp->child_pk_col,
   ",cmb_temp->list[idx].pk_id)",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"and x.",cmb_temp->child_pk_col," not in",char(10)
   )
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"  (select pcd.entity_id from ",trim(cmb_det_table
    )," pcd",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   where pcd.",trim(cmb_table_id),
   " = request->xxx_combine[iCombine]->xxx_combine_id ",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   and pcd.entity_name = '",cmb_temp->child_table,
   "'",char(10))
  SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"   and pcd.attribute_name = '",cmb_temp->
   child_cmb_col,"')",char(10))
  IF (cmb_get_ccl_version(null) > 81001
   AND (cmb_temp->det_cnt > 200))
   SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"with nocounter, expand=2 go")
  ELSEIF (cmb_get_ccl_version(null) <= 81001
   AND (cmb_temp->det_cnt > 200))
   SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"with nocounter, expand=1 go")
  ELSE
   SET cmb_temp->cmd_str = concat(cmb_temp->cmd_str,"with nocounter go")
  ENDIF
  IF (dm_debug_cmb)
   CALL echo(cmb_temp->cmd_str)
  ENDIF
  CALL parser(cmb_temp->cmd_str,1)
  IF ((curqual != cmb_temp->det_cnt))
   SET error_table = cmb_temp->child_table
   SET request->error_message = concat(
    "Count of encounter move updates does not match count of rows found.  Try again.")
   SET failed = update_error
   GO TO cmb_check_error
  ENDIF
  SET stat = alterlist(request->xxx_combine_det,cmb_temp->det_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(request->xxx_combine_det,5))
   DETAIL
    request->xxx_combine_det[d.seq].xxx_combine_id = request->xxx_combine[icombine].xxx_combine_id,
    request->xxx_combine_det[d.seq].combine_action_cd = upt, request->xxx_combine_det[d.seq].
    combine_desc_cd = uptem,
    request->xxx_combine_det[d.seq].entity_id = cmb_temp->list[d.seq].pk_id, request->
    xxx_combine_det[d.seq].entity_name = cmb_temp->child_table, request->xxx_combine_det[d.seq].
    attribute_name = cmb_temp->child_cmb_col,
    request->xxx_combine_det[d.seq].to_record_ind = 0, cmb_temp->list[d.seq].row_exists = 0
   WITH nocounter
  ;end select
  SET dm_str = concat("insert into ",trim(cmb_det_table),
   " cdt, (dummyt d with seq = size(request->xxx_combine_det,5)) ")
  CALL parser(dm_str)
  SET dm_str = concat("set cdt.attribute_name= ","request->xxx_combine_det[d.seq]->attribute_name,")
  CALL parser(dm_str)
  SET dm_str = concat("cdt.combine_action_cd= ","request->xxx_combine_det[d.seq]->combine_action_cd,"
   )
  CALL parser(dm_str)
  SET dm_str = concat("cdt.",trim(cmb_table_id)," = request->xxx_combine[ICOMBINE]->xxx_combine_id,")
  CALL parser(dm_str)
  SET dm_str = "cdt.entity_id=request->xxx_combine_det[d.seq]->entity_id,"
  CALL parser(dm_str)
  SET dm_str = "cdt.entity_name=request->xxx_combine_det[d.seq]->entity_name,"
  CALL parser(dm_str)
  SET dm_str = concat("cdt.",trim(cmb_det_table_id),"=seq(",trim(cmb_seq),", nextval),")
  CALL parser(dm_str)
  SET dm_str = "cdt.updt_cnt=INIT_UPDT_CNT,"
  CALL parser(dm_str)
  SET dm_str = "cdt.updt_dt_tm=cnvtdatetime(curdate, curtime3),"
  CALL parser(dm_str)
  SET dm_str = "cdt.updt_id=reqinfo->updt_id,"
  CALL parser(dm_str)
  SET dm_str = "cdt.updt_task=reqinfo->updt_task,"
  CALL parser(dm_str)
  SET dm_str = "cdt.updt_applctx=reqinfo->updt_applctx,"
  CALL parser(dm_str)
  SET dm_str = "cdt.active_ind=ACTIVE_ACTIVE_IND,"
  CALL parser(dm_str)
  SET dm_str = "cdt.active_status_cd=reqdata->active_status_cd,"
  CALL parser(dm_str)
  SET dm_str = "cdt.active_status_dt_tm=cnvtdatetime(curdate, curtime3),"
  CALL parser(dm_str)
  SET dm_str = "cdt.active_status_prsnl_id=reqinfo->updt_id,"
  CALL parser(dm_str)
  SET dm_str = concat("cdt.prev_active_ind = ","request->xxx_combine_det[d.seq]->prev_active_ind,")
  CALL parser(dm_str)
  SET dm_str = concat("cdt.combine_desc_cd = ","request->xxx_combine_det[d.seq]->combine_desc_cd,")
  CALL parser(dm_str)
  SET dm_str = concat("cdt.to_record_ind = ","request->xxx_combine_det[d.seq]->to_record_ind,")
  CALL parser(dm_str)
  SET dm_str = concat("cdt.prev_active_status_cd = ",
   "request->xxx_combine_det[d.seq]->prev_active_status_cd,")
  CALL parser(dm_str)
  SET dm_str = concat("cdt.prev_end_eff_dt_tm = ",
   "cnvtdatetime(request->xxx_combine_det[d.seq]->prev_end_eff_dt_tm) ")
  CALL parser(dm_str)
  SET dm_str = "plan d where cmb_temp->list[d.seq].row_exists = 0"
  CALL parser(dm_str)
  SET dm_str = "join cdt "
  CALL parser(dm_str)
  SET dm_str = " go "
  CALL parser(dm_str,1)
  IF ((curqual != cmb_temp->det_cnt))
   SET error_table = cmb_temp->child_table
   SET request->error_message =
   "Count of encounter move detail records inserted does not match count of rows found. Try again."
   SET failed = insert_error
   GO TO cmb_check_error
  ENDIF
  SET icombinedetem = curqual
 ENDIF
#cmb_check_error
#end_program
END GO
