CREATE PROGRAM dm2_get_cursch_x:dba
 DECLARE db2_db = vc WITH public, constant("DB2UDB")
 DECLARE oracle_db = vc WITH public, constant("ORACLE")
 DECLARE alloc_unit = i2 WITH public, constant(10)
 DECLARE tgt_tbl_max = i2 WITH public, constant(300)
 DECLARE c_mod = vc WITH private, constant("000")
 DECLARE dgc_oracle_ver = i2 WITH protect, noconstant(0)
 DECLARE get_full_sch_ind = i2 WITH protect, noconstant(0)
 DECLARE determine_oracle_version() = null
 DECLARE get_tables_columns() = null
 DECLARE get_indexes_index_columns() = null
 DECLARE get_primary_and_unique_constraints() = null
 DECLARE get_referential_integrity_constraints() = null
 DECLARE get_tablespaces() = null
 DECLARE get_sequences() = null
 SET dm_err->eproc = "Starting DM2_GET_CURSCH"
 CALL disp_msg("",dm_err->logfile,0)
 IF (validate(dm2_call_prog,"X")="X")
  DECLARE dm2_call_prog = vc WITH public, noconstant("DM2_GET_CURSCH")
 ELSE
  IF (dm2_call_prog="DM2_CAPTURE_SCHEMA")
   SET get_full_sch_ind = true
  ELSE
   SET get_full_sch_ind = false
  ENDIF
 ENDIF
 IF ((((tgtsch->tbl_cnt > 0)) OR (get_full_sch_ind=true)) )
  IF (currdb=oracle_db)
   CALL determine_oracle_version(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
  ENDIF
  CALL get_tables_columns(null)
  IF ((dm_err->err_ind > 0))
   GO TO end_program
  ENDIF
  IF ((cur_sch->tbl_cnt > 0))
   CALL get_indexes_index_columns(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
   CALL get_primary_and_unique_constraints(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
   CALL get_referential_integrity_constraints(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
   CALL get_tablespaces(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
   CALL get_sequences(null)
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
  ELSE
   SET dm_err->eproc = "No Tables to Load From Current Schema"
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
 ELSE
  SET dm_err->eproc = "MAIN ROUTINE"
  SET dm_err->err_ind = 1
  CALL disp_msg("Target Schema Contains No Tables",dm_err->logfile,1)
  GO TO end_program
 ENDIF
 SET dm_err->eproc = "Ending DM2_GET_CURSCH"
 CALL disp_msg("",dm_err->logfile,0)
 SUBROUTINE determine_oracle_version(null)
   SET dm_err->eproc = "Determine Oracle Version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    p.product
    FROM product_component_version p
    DETAIL
     CASE (cnvtupper(substring(1,7,p.product)))
      OF "ORACLE7":
       dgc_oracle_ver = 7
      OF "ORACLE8":
       dgc_oracle_ver = 8
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error("Determine Oracle Version")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dgc_oracle_ver=0)
    SET dm_err->eproc = "Determine_Oracle_Version"
    SET dm_err->err_ind = 1
    CALL disp_msg("Could Not Determine Oracle Version From Data in the Product_Component_Version",
     dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_tables_columns(null)
   SET dm_err->eproc = "Get Tables Columns"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE table_cnt = i4 WITH private
   DECLARE table_col_cnt = i4 WITH private
   SET curalias gt_tab cur_sch->tbl[table_cnt]
   SET curalias gt_tab_col cur_sch->tbl[table_cnt].tbl_col[table_col_cnt]
   CALL parser("SELECT")
   CALL parser("   IF (TgtSch->tbl_cnt > tgt_tbl_max OR get_full_sch_ind = 1)")
   CALL parser("      FROM  USER_TAB_COLUMNS c,")
   CALL parser("            USER_TABLES      t")
   CALL parser("      WHERE c.table_name = t.table_name")
   CALL parser(
    '      AND t.table_name in ("PERSON", "PERSON_PATIENT", "DM_ENV_MRG_AUDIT", "LONG_BLOB",')
   CALL parser('          "LONG_TEXT", "LONG_BLOB_REFERENCE", "DM_INFO", "DM_TRANSACTION_ACTIVITY",')
   CALL parser('          "ABN_CROSS_REFERENCE")')
   CALL parser("   ELSE")
   CALL parser("      FROM (DUMMYT d WITH seq = value (TgtSch->tbl_cnt)),")
   CALL parser("            USER_TAB_COLUMNS c,")
   CALL parser("            USER_TABLES      t")
   CALL parser("      PLAN d ")
   CALL parser("      JOIN c WHERE c.table_name = TgtSch->tbl[d.seq]->tbl_name")
   CALL parser("      JOIN t WHERE t.table_name = c.table_name")
   CALL parser("   ENDIF")
   CALL parser('   INTO "nl:"')
   CALL parser("ORDER BY c.table_name")
   CALL parser("       , c.column_name")
   CALL parser("HEAD REPORT")
   CALL parser("   table_cnt = 0")
   CALL parser("   table_col_cnt = 0")
   CALL parser("HEAD c.table_name")
   CALL parser("   table_cnt = table_cnt + 1")
   CALL parser("   IF (MOD(table_cnt, alloc_unit) = 1 )")
   CALL parser("      stat = ALTERLIST(Cur_Sch->tbl, table_cnt + (alloc_unit - 1))")
   CALL parser("   ENDIF")
   CALL parser("   gt_tab->tbl_name     = t.table_name")
   CALL parser("   gt_tab->tspace_name  = t.tablespace_name")
   CALL parser("   gt_tab->pct_increase = t.pct_increase")
   CALL parser("   gt_tab->pct_used     = t.pct_used")
   CALL parser("   gt_tab->pct_free     = t.pct_free")
   CALL parser("   gt_tab->init_ext     = t.initial_extent")
   CALL parser("   gt_tab->next_ext     = t.next_extent")
   IF (currdb=db2_db)
    CALL parser("   gt_tab->long_tspace = t.long_tbspace")
    CALL parser("   gt_tab->ind_tspace  = t.index_tbspace")
   ELSE
    CALL parser('   gt_tab->long_tspace = " "')
    CALL parser('   gt_tab->ind_tspace  = " "')
   ENDIF
   CALL parser("DETAIL")
   CALL parser("   table_col_cnt = table_col_cnt + 1")
   CALL parser("   IF (MOD(table_col_cnt, alloc_unit) = 1)")
   CALL parser(
    "      stat = ALTERLIST(Cur_Sch->tbl[table_cnt]->tbl_col, table_col_cnt + (alloc_unit - 1))")
   CALL parser("   ENDIF")
   CALL parser("   gt_tab_col->col_name     = c.column_name")
   CALL parser("   gt_tab_col->col_seq      = c.column_id")
   CALL parser("   gt_tab_col->data_type    = c.data_type")
   CALL parser("   gt_tab_col->data_length  = c.data_length")
   CALL parser("   gt_tab_col->data_default = c.data_default")
   CALL parser("   gt_tab_col->nullable     = c.nullable")
   CALL parser("FOOT c.table_name")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl[table_cnt]->tbl_col, table_col_cnt)")
   CALL parser("   gt_tab->tbl_col_cnt = table_col_cnt")
   CALL parser("   table_col_cnt = 0")
   CALL parser("FOOT REPORT")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl, table_cnt)")
   CALL parser("   Cur_Sch->tbl_cnt = table_cnt")
   CALL parser("   table_cnt = 0")
   CALL parser("WITH nocounter  GO")
   IF (check_error("Get_Tables_Columns")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET curalias gt_tab off
   SET curalias gt_tab_col off
 END ;Subroutine
 SUBROUTINE get_indexes_index_columns(null)
   SET dm_err->eproc = "Get Indexes Index Columns"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE index_cnt = i4 WITH protect
   DECLARE index_col_cnt = i4 WITH protect
   SET curalias gi_ind cur_sch->tbl[d.seq].ind[index_cnt]
   SET curalias gi_ind_col cur_sch->tbl[d.seq].ind[index_cnt].ind_col[index_col_cnt]
   CALL parser("SELECT")
   CALL parser("   IF ((dgc_oracle_ver = 8) OR (currdb = DB2_db))")
   CALL parser("      FROM  (DUMMYT d WITH seq = value (Cur_Sch->tbl_cnt)),")
   CALL parser("             DBA_IND_COLUMNS c,")
   CALL parser("             DBA_INDEXES     i")
   CALL parser("      PLAN d")
   CALL parser("      JOIN c WHERE c.table_name  = Cur_Sch->tbl[d.seq]->tbl_name")
   CALL parser("               AND c.table_owner = currdbuser")
   CALL parser("               AND c.index_owner = currdbuser")
   CALL parser("      JOIN i WHERE i.table_name  = c.table_name")
   CALL parser("               AND i.table_owner = c.table_owner")
   CALL parser("               AND i.index_name  = c.index_name")
   CALL parser("   ELSEIF (dgc_oracle_ver = 7)")
   CALL parser("      FROM  (DUMMYT d WITH seq = value (Cur_Sch->tbl_cnt)),")
   CALL parser("             DBA_INDEXES     i,")
   CALL parser("             DBA_IND_COLUMNS c")
   CALL parser("      PLAN d")
   CALL parser("      JOIN i WHERE i.table_name  = Cur_Sch->tbl[d.seq]->tbl_name")
   CALL parser("               AND i.table_owner = currdbuser")
   CALL parser("      JOIN c WHERE c.table_name  = i.table_name")
   CALL parser("               AND c.table_owner = i.table_owner")
   CALL parser("               AND c.index_owner = i.owner")
   CALL parser("               AND c.index_name  = i.index_name")
   CALL parser("   ENDIF")
   CALL parser('INTO "nl:"')
   CALL parser("    d.seq")
   CALL parser("ORDER BY c.table_name")
   CALL parser("       , c.index_name")
   CALL parser("       , c.column_position")
   CALL parser("HEAD c.table_name")
   CALL parser("   index_cnt = 0")
   CALL parser("   index_col_cnt = 0")
   CALL parser("HEAD c.index_name")
   CALL parser("   index_cnt = index_cnt + 1")
   CALL parser("   IF (MOD(index_cnt, alloc_unit) = 1)")
   CALL parser("      stat = ALTERLIST(Cur_Sch->tbl[d.seq]->ind, index_cnt + (alloc_unit - 1))")
   CALL parser("   ENDIF")
   CALL parser("   gi_ind->ind_name     = i.index_name")
   CALL parser("   gi_ind->tspace_name  = i.tablespace_name")
   CALL parser("   gi_ind->pct_increase = i.pct_increase")
   CALL parser("   gi_ind->pct_free     = i.pct_free")
   CALL parser("   gi_ind->init_ext     = i.initial_extent")
   CALL parser("   gi_ind->next_ext     = i.next_extent")
   CALL parser('   IF (i.uniqueness = "UNIQUE")')
   CALL parser("       gi_ind->unique_ind = 1")
   CALL parser('   ELSEIF (i.uniqueness = "NONUNIQUE")')
   CALL parser("       gi_ind->unique_ind = 0")
   CALL parser("   ENDIF")
   IF (currdb=db2_db)
    CALL parser("gi_ind->full_ind_name = i.full_index_name")
   ELSEIF (currdb=oracle_db)
    CALL parser("gi_ind->full_ind_name = i.index_name")
   ENDIF
   CALL parser("DETAIL")
   CALL parser("   index_col_cnt = index_col_cnt + 1")
   CALL parser("   IF (MOD(index_col_cnt, alloc_unit) = 1)")
   CALL parser(
    "      stat = ALTERLIST(Cur_Sch->tbl[d.seq]->ind[index_cnt]->ind_col, index_col_cnt + (alloc_unit - 1))"
    )
   CALL parser("   ENDIF")
   CALL parser("   gi_ind_col->col_name     = c.column_name")
   CALL parser("   gi_ind_col->col_position = c.column_position")
   CALL parser("FOOT c.index_name ;reset index column info")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->ind[index_cnt]->ind_col, index_col_cnt)")
   CALL parser("   gi_ind->ind_col_cnt = index_col_cnt")
   CALL parser("   Index_col_cnt = 0")
   CALL parser("FOOT c.table_name ;reset index info")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->ind, index_cnt)")
   CALL parser("   Cur_Sch->tbl[d.seq]->ind_cnt = index_cnt")
   CALL parser("   Index_cnt = 0")
   CALL parser("WITH nocounter  GO")
   IF (check_error("Get_Indexes_Index_Columns")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET curalias gi_ind off
   SET curalias gi_ind_col off
 END ;Subroutine
 SUBROUTINE get_primary_and_unique_constraints(null)
   SET dm_err->eproc = "Get Primary and Unique Constraints"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE constraint_cnt = i4
   DECLARE constraint_col_cnt = i4
   SET curalias pu_cons cur_sch->tbl[d.seq].cons[constraint_cnt]
   SET curalias pu_cons_col cur_sch->tbl[d.seq].cons[constraint_cnt].cons_col[constraint_col_cnt]
   CALL parser('SELECT into "nl:"')
   CALL parser("    d.seq")
   CALL parser("FROM (dummyt d with seq = value (Cur_Sch->tbl_cnt)),")
   CALL parser("      USER_CONS_COLUMNS cc,")
   CALL parser("      USER_CONSTRAINTS   c")
   CALL parser("PLAN d")
   CALL parser("JOIN c  WHERE c.table_name = Cur_Sch->tbl[d.seq]->tbl_name")
   CALL parser('          AND c.constraint_type in ("P","U")')
   CALL parser("          AND c.owner = currdbuser")
   CALL parser("JOIN cc WHERE cc.table_name = c.table_name")
   CALL parser("          AND cc.constraint_name = c.constraint_name")
   CALL parser("          AND cc.owner = c.owner")
   CALL parser("ORDER BY cc.table_name")
   CALL parser("       , cc.constraint_name")
   CALL parser("       , cc.position")
   CALL parser("HEAD cc.table_name")
   CALL parser("   constraint_cnt = 0")
   CALL parser("   constraint_col_cnt = 0")
   CALL parser("HEAD cc.constraint_name")
   CALL parser("   constraint_cnt = constraint_cnt + 1")
   CALL parser("   IF (MOD(constraint_cnt, alloc_unit) = 1)")
   CALL parser("      stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons, constraint_cnt + (alloc_unit - 1))"
    )
   CALL parser("   ENDIF")
   CALL parser("   pu_cons->cons_name         = c.constraint_name")
   CALL parser("   pu_cons->cons_type         = c.constraint_type")
   CALL parser("   pu_cons->r_constraint_name = c.r_constraint_name")
   IF (currdb=db2_db)
    CALL parser("pu_cons->full_cons_name = c.full_constraint_name")
    CALL parser("pu_cons->status_ind     = 1")
   ELSEIF (currdb=oracle_db)
    CALL parser("pu_cons->full_cons_name = c.constraint_name")
    CALL parser('IF (c.status = "ENABLED")')
    CALL parser("   pu_cons->status_ind = 1")
    CALL parser('ELSEIF (c.status = "DISABLED")')
    CALL parser("   pu_cons->status_ind = 0")
    CALL parser("ENDIF")
   ENDIF
   CALL parser("DETAIL")
   CALL parser("   constraint_col_cnt = constraint_col_cnt + 1")
   CALL parser("   IF (MOD(constraint_col_cnt, alloc_unit) = 1)")
   CALL parser(
    "      stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons[constraint_cnt]->cons_col, constraint_col_cnt + (alloc_unit - 1))"
    )
   CALL parser("   ENDIF")
   CALL parser("   pu_cons_col->col_name = cc.column_name")
   CALL parser("   pu_cons_col->col_position = cc.position")
   CALL parser("FOOT cc.constraint_name")
   CALL parser(
    "   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons[constraint_cnt]->cons_col, constraint_col_cnt)")
   CALL parser("   pu_cons->cons_col_cnt = constraint_col_cnt")
   CALL parser("   constraint_col_cnt = 0")
   CALL parser("FOOT cc.table_name")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons, constraint_cnt)")
   CALL parser("   Cur_Sch->tbl[d.seq]->cons_cnt = constraint_cnt")
   CALL parser("   constraint_cnt = 0")
   CALL parser("WITH nocounter   GO")
   IF (check_error("Get_Primary_and_Unique_Constraints")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET curalias pu_cons off
   SET curalias pu_cons_col off
 END ;Subroutine
 SUBROUTINE get_referential_integrity_constraints(null)
   SET dm_err->eproc = "Get Referential Integrity Constraints"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE constraint_cnt = i4 WITH private
   DECLARE constraint_col_cnt = i4 WITH private
   DECLARE pt_col_cnt = i4 WITH private
   SET curalias ri_cons cur_sch->tbl[d.seq].cons[constraint_cnt]
   SET curalias ri_cons_col cur_sch->tbl[d.seq].cons[constraint_cnt].cons_col[constraint_col_cnt]
   CALL parser('SELECT into "nl:"')
   CALL parser("    d.seq")
   CALL parser("FROM (dummyt d with seq = value (Cur_Sch->tbl_cnt)),")
   CALL parser("      USER_CONSTRAINTS    c,")
   CALL parser("      USER_CONS_COLUMNS  cc,")
   CALL parser("      USER_CONSTRAINTS   c2,")
   CALL parser("      USER_CONS_COLUMNS cc2")
   CALL parser("PLAN   d")
   CALL parser("JOIN   c WHERE   c.table_name = Cur_Sch->tbl[d.seq]->tbl_name")
   CALL parser("           AND   c.owner = currdbuser")
   CALL parser('           AND   c.constraint_type = "R"')
   CALL parser("JOIN  cc WHERE  cc.table_name = c.table_name")
   CALL parser("           AND  cc.constraint_name = c.constraint_name")
   CALL parser("           AND  cc.owner = c.owner")
   CALL parser("JOIN  c2 WHERE  c2.constraint_name = c.r_constraint_name")
   CALL parser("           AND  c2.owner = c.owner")
   CALL parser("JOIN cc2 WHERE cc2.table_name = c2.table_name")
   CALL parser("           AND cc2.constraint_name = c2.constraint_name")
   CALL parser("           AND cc2.owner = c2.owner")
   CALL parser("           AND cc2.position = cc.position")
   CALL parser("ORDER BY   c.table_name")
   CALL parser("       ,   c.constraint_name")
   CALL parser("       , cc2.position")
   CALL parser("HEAD c.table_name")
   CALL parser("   constraint_cnt = Cur_Sch->tbl[d.seq]->cons_cnt")
   CALL parser("   constraint_col_cnt = 0")
   CALL parser("HEAD  c.constraint_name")
   CALL parser("   pt_col_cnt = 0")
   CALL parser("   constraint_cnt = constraint_cnt + 1")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons, constraint_cnt)")
   CALL parser("   ri_cons->cons_name         = c.constraint_name")
   CALL parser("   ri_cons->cons_type         = c.constraint_type")
   CALL parser("   ri_cons->r_constraint_name = c.r_constraint_name")
   CALL parser("   ri_cons->parent_table      = c2.table_name")
   IF (currdb=db2_db)
    CALL parser("   ri_cons->full_cons_name = c.full_constraint_name")
    CALL parser("   ri_cons->status_ind     = 1")
   ELSEIF (currdb=oracle_db)
    CALL parser("   ri_cons->full_cons_name = c.constraint_name")
    CALL parser('   IF (c.status = "ENABLED")')
    CALL parser("      ri_cons->status_ind = 1")
    CALL parser('   ELSEIF (c.status = "DISABLED")')
    CALL parser("      ri_cons->status_ind = 0")
    CALL parser("   ENDIF")
   ENDIF
   CALL parser("DETAIL")
   CALL parser("   constraint_col_cnt = constraint_col_cnt + 1")
   CALL parser("   IF (MOD(constraint_col_cnt, alloc_unit) = 1)")
   CALL parser(
    "      stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons[constraint_cnt]->cons_col,constraint_col_cnt + (alloc_unit - 1))"
    )
   CALL parser("   ENDIF")
   CALL parser("   ri_cons_col->col_name     = cc.column_name")
   CALL parser("   ri_cons_col->col_position = cc.position")
   CALL parser("   IF (pt_col_cnt > 0)")
   CALL parser(
    '      ri_cons->parent_table_columns = concat(ri_cons->parent_table_columns, " ",trim(cc.column_name))'
    )
   CALL parser("   ELSE")
   CALL parser("      ri_cons->parent_table_columns = trim(cc.column_name)")
   CALL parser("   ENDIF")
   CALL parser("   pt_col_cnt = pt_col_cnt + 1")
   CALL parser("FOOT c.constraint_name")
   CALL parser(
    "   stat = ALTERLIST(Cur_Sch->tbl[d.seq]->cons[constraint_cnt]->cons_col, constraint_col_cnt)")
   CALL parser("   ri_cons->cons_col_cnt = constraint_col_cnt")
   CALL parser("   constraint_col_cnt = 0")
   CALL parser("FOOT c.table_name")
   CALL parser("   Cur_Sch->tbl[d.seq]->cons_cnt = constraint_cnt")
   CALL parser("   Constraint_cnt = 0")
   CALL parser("WITH nocounter   GO")
   IF (check_error("Get_Referential_Integrity_Constraints")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET curalias ri_cons off
   SET curalias ri_cons_col off
 END ;Subroutine
 SUBROUTINE get_tablespaces(null)
   SET dm_err->eproc = "Get Tablespaces"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE tablespace_cnt = i4 WITH protect
   SET curalias tspace cur_sch->tspace[tablespace_cnt]
   SET tablespace_cnt = 0
   CALL parser('SELECT INTO "NL:"')
   CALL parser("FROM   USER_TABLESPACES ut")
   CALL parser('WHERE  ut.status != "INVALID"')
   CALL parser("ORDER BY ut.Tablespace_name")
   CALL parser("DETAIL")
   CALL parser("tablespace_cnt = tablespace_cnt + 1")
   CALL parser("IF (MOD(tablespace_cnt, alloc_unit) = 1) ")
   CALL parser("   stat = ALTERLIST(Cur_Sch->tspace, tablespace_cnt + (alloc_unit - 1)) ")
   CALL parser("ENDIF")
   CALL parser("tspace->tspace_name     = ut.tablespace_name")
   CALL parser("tspace->initial_extent  = ut.initial_extent")
   CALL parser("tspace->next_extent     = ut.next_extent")
   CALL parser("tspace->pct_increase    = ut.pct_increase")
   CALL parser("tspace->min_extents     = ut.min_extents")
   CALL parser("tspace->max_extents     = ut.max_extents")
   CALL parser("tspace->status          = ut.status")
   CALL parser("tspace->contents        = ut.contents")
   CALL parser("tspace->pagesize        = 0")
   CALL parser('tspace->bufferpool_name = "ut.bufferpoolid"')
   IF (currdb=db2_db)
    CALL parser("tspace->full_tspace_name = ut.full_tablespace_name")
    CALL parser('tspace->tspace_type      = "ut.tbspacetype"')
    CALL parser('tspace->nodegroup        = "ut.ngname"')
   ELSEIF (currdb=oracle_db)
    CALL parser("tspace->full_tspace_name = ut.tablespace_name")
    CALL parser('tspace->tspace_type      = " "')
    CALL parser('tspace->nodegroup        = " "')
   ENDIF
   CALL parser("WITH  nocounter GO")
   SET stat = alterlist(cur_sch->tspace,tablespace_cnt)
   SET cur_sch->tspace_cnt = tablespace_cnt
   SET tablespace_cnt = 0
   IF (check_error("Get_Tablespaces")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET curalias tspace off
 END ;Subroutine
 SUBROUTINE get_sequences(null)
   SET dm_err->eproc = "Get Sequences"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE sequence_cnt = i4 WITH protect
   SELECT INTO "NL:"
    FROM user_sequences s
    ORDER BY s.sequence_name
    DETAIL
     sequence_cnt = (sequence_cnt+ 1)
     IF (mod(sequence_cnt,alloc_unit)=1)
      stat = alterlist(cur_sch->sequence,(sequence_cnt+ (alloc_unit - 1)))
     ENDIF
     cur_sch->sequence[sequence_cnt].seq_name = s.sequence_name, cur_sch->sequence[sequence_cnt].
     min_val = s.min_value, cur_sch->sequence[sequence_cnt].max_val = s.max_value,
     cur_sch->sequence[sequence_cnt].cycle_flag = s.cycle_flag, cur_sch->sequence[sequence_cnt].
     increment_by = s.increment_by
    WITH nocounter
   ;end select
   SET stat = alterlist(cur_sch->sequence,sequence_cnt)
   SET cur_sch->sequence_cnt = sequence_cnt
   SET sequence_cnt = 0
   IF (check_error("Get_Sequences")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
#end_program
END GO
