CREATE PROGRAM dm_get_current_schema3:dba
 SET curdb->tbl_cnt = 0
 SET tcnt = 0
 SET tc_cnt = 0
 SET icnt = 0
 SET ic_cnt = 0
 SET ccnt = 0
 SET cc_cnt = 0
 SET ttl_col_cnt = 0
 SET ttl_ind_cnt = 0
 SET ttl_ind_col_cnt = 0
 SET ttl_cons_cnt = 0
 SET ttl_cons_col_cnt = 0
 IF ((tgtdb->tbl_cnt=0))
  GO TO end_program
 ENDIF
 SET oracle_ver = 0
 SELECT INTO "nl:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   IF (cnvtupper(substring(1,7,p.product))="ORACLE7")
    oracle_ver = 7
   ELSE
    oracle_ver = 8
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF ((fs_proc->ocd_ind=1)
   AND (fs_proc->online_ind=1))
   FROM user_tab_columns c,
    user_tables t,
    dm_afd_tables a
   WHERE (a.alpha_feature_nbr=fs_proc->ocd_number)
    AND (a.table_name=fs_proc->online_table_name)
    AND t.table_name=concat(trim(substring(1,28,a.table_name)),"$C")
    AND c.table_name=t.table_name
  ELSEIF ((fs_proc->ocd_ind=1)
   AND (fs_proc->online_ind=0))
   FROM user_tab_columns c,
    user_tables t,
    dm_afd_tables a
   WHERE (a.alpha_feature_nbr=fs_proc->ocd_number)
    AND a.table_name=t.table_name
    AND t.table_name=c.table_name
  ELSEIF ((fs_proc->inhouse_ind=1)
   AND dis_utc_ind=1)
   FROM user_tab_columns c,
    user_tables t,
    dm_adm_tables a
   WHERE a.schema_date=cnvtdatetimeutc(fs_proc->schema_date)
    AND (a.table_name=fs_proc->inhouse_table_name)
    AND a.table_name=t.table_name
    AND t.table_name=c.table_name
  ELSEIF ((fs_proc->inhouse_ind=1)
   AND dis_utc_ind=0)
   FROM user_tab_columns c,
    user_tables t,
    dm_adm_tables a
   WHERE a.schema_date=cnvtdatetime(fs_proc->schema_date)
    AND (a.table_name=fs_proc->inhouse_table_name)
    AND a.table_name=t.table_name
    AND t.table_name=c.table_name
  ELSEIF ((fs_proc->ocd_ind=0)
   AND (fs_proc->inhouse_ind=0)
   AND (fs_proc->online_ind=1)
   AND dis_utc_ind=1)
   FROM user_tab_columns c,
    user_tables t,
    dm_tables a
   WHERE a.schema_date=cnvtdatetimeutc(fs_proc->schema_date)
    AND (a.table_name=fs_proc->online_table_name)
    AND t.table_name=concat(trim(substring(1,28,a.table_name)),"$C")
    AND c.table_name=t.table_name
  ELSEIF ((fs_proc->ocd_ind=0)
   AND (fs_proc->inhouse_ind=0)
   AND (fs_proc->online_ind=1)
   AND dis_utc_ind=0)
   FROM user_tab_columns c,
    user_tables t,
    dm_tables a
   WHERE a.schema_date=cnvtdatetime(fs_proc->schema_date)
    AND (a.table_name=fs_proc->online_table_name)
    AND t.table_name=concat(trim(substring(1,28,a.table_name)),"$C")
    AND c.table_name=t.table_name
  ELSEIF (dis_utc_ind=1)
   FROM user_tab_columns c,
    user_tables t,
    dm_tables a
   WHERE a.schema_date=cnvtdatetimeutc(fs_proc->schema_date)
    AND cnvtupper(a.table_name)=t.table_name
    AND cnvtupper(t.table_name)=c.table_name
  ELSE
   FROM user_tab_columns c,
    user_tables t,
    dm_tables a
   WHERE a.schema_date=cnvtdatetime(fs_proc->schema_date)
    AND cnvtupper(a.table_name)=t.table_name
    AND cnvtupper(t.table_name)=c.table_name
  ENDIF
  INTO "nl:"
  ORDER BY c.table_name, c.column_name
  HEAD c.table_name
   curdb->tbl_cnt = (curdb->tbl_cnt+ 1), tcnt = curdb->tbl_cnt, stat = alterlist(curdb->tbl,tcnt),
   curdb->tbl[tcnt].tbl_name = c.table_name, curdb->tbl[tcnt].tspace_name = t.tablespace_name, curdb
   ->tbl[tcnt].bad_tspace_ind = 0,
   curdb->tbl[tcnt].tbl_col_cnt = 0, curdb->tbl[tcnt].ind_cnt = 0, curdb->tbl[tcnt].cons_cnt = 0
  DETAIL
   curdb->tbl[tcnt].tbl_col_cnt = (curdb->tbl[tcnt].tbl_col_cnt+ 1), tc_cnt = curdb->tbl[tcnt].
   tbl_col_cnt, stat = alterlist(curdb->tbl[tcnt].tbl_col,tc_cnt),
   curdb->tbl[tcnt].tbl_col[tc_cnt].col_name = c.column_name, curdb->tbl[tcnt].tbl_col[tc_cnt].
   data_type = c.data_type, curdb->tbl[tcnt].tbl_col[tc_cnt].data_length = c.data_length,
   curdb->tbl[tcnt].tbl_col[tc_cnt].data_default = trim(c.data_default), curdb->tbl[tcnt].tbl_col[
   tc_cnt].nullable = c.nullable
  WITH nocounter
 ;end select
 IF ((curdb->tbl_cnt > 0))
  SELECT
   IF (oracle_ver=7)
    FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
     dba_ind_columns c,
     dba_indexes i
    PLAN (d)
     JOIN (i
     WHERE (i.table_name=curdb->tbl[d.seq].tbl_name)
      AND i.table_owner=currdbuser)
     JOIN (c
     WHERE (c.table_name=curdb->tbl[d.seq].tbl_name)
      AND c.table_owner=currdbuser
      AND c.index_owner=currdbuser
      AND c.index_name=i.index_name)
   ELSEIF (oracle_ver=8)
    FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
     dba_indexes i,
     dba_ind_columns c
    PLAN (d)
     JOIN (c
     WHERE (c.table_name=curdb->tbl[d.seq].tbl_name)
      AND c.table_owner=currdbuser
      AND c.index_owner=currdbuser)
     JOIN (i
     WHERE (i.table_name=curdb->tbl[d.seq].tbl_name)
      AND i.table_owner=currdbuser
      AND c.index_name=i.index_name)
   ELSE
   ENDIF
   INTO "nl:"
   d.seq
   ORDER BY c.table_name, c.index_name, c.column_position
   HEAD c.index_name
    curdb->tbl[d.seq].ind_cnt = (curdb->tbl[d.seq].ind_cnt+ 1), icnt = curdb->tbl[d.seq].ind_cnt,
    stat = alterlist(curdb->tbl[d.seq].ind,icnt),
    curdb->tbl[d.seq].ind[icnt].ind_name = c.index_name, curdb->tbl[d.seq].ind[icnt].tspace_name = i
    .tablespace_name
    IF (i.uniqueness="UNIQUE")
     curdb->tbl[d.seq].ind[icnt].unique_ind = 1
    ELSEIF (i.uniqueness="NONUNIQUE")
     curdb->tbl[d.seq].ind[icnt].unique_ind = 0
    ENDIF
    curdb->tbl[d.seq].ind[icnt].bad_tspace_ind = 0, curdb->tbl[d.seq].ind[icnt].drop_ind = 0, curdb->
    tbl[d.seq].ind[icnt].downtime_ind = 0,
    curdb->tbl[d.seq].ind[icnt].ind_col_cnt = 0, ttl_ind_cnt = (ttl_ind_cnt+ 1)
   DETAIL
    curdb->tbl[d.seq].ind[icnt].ind_col_cnt = (curdb->tbl[d.seq].ind[icnt].ind_col_cnt+ 1), ic_cnt =
    curdb->tbl[d.seq].ind[icnt].ind_col_cnt, stat = alterlist(curdb->tbl[d.seq].ind[icnt].ind_col,
     ic_cnt),
    curdb->tbl[d.seq].ind[icnt].ind_col[ic_cnt].col_name = c.column_name, curdb->tbl[d.seq].ind[icnt]
    .ind_col[ic_cnt].col_position = c.column_position
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
    user_cons_columns cc,
    user_constraints c
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=curdb->tbl[d.seq].tbl_name)
     AND c.constraint_type IN ("P", "U")
     AND c.owner=currdbuser)
    JOIN (cc
    WHERE cc.table_name=c.table_name
     AND cc.constraint_name=c.constraint_name
     AND cc.owner=c.owner)
   ORDER BY cc.table_name, cc.constraint_name, cc.position
   HEAD cc.constraint_name
    curdb->tbl[d.seq].cons_cnt = (curdb->tbl[d.seq].cons_cnt+ 1), ccnt = curdb->tbl[d.seq].cons_cnt,
    stat = alterlist(curdb->tbl[d.seq].cons,ccnt),
    curdb->tbl[d.seq].cons[ccnt].cons_name = c.constraint_name, curdb->tbl[d.seq].cons[ccnt].
    cons_type = c.constraint_type
    IF (c.status="ENABLED")
     curdb->tbl[d.seq].cons[ccnt].status_ind = 1
    ELSEIF (c.status="DISABLED")
     curdb->tbl[d.seq].cons[ccnt].status_ind = 0
    ENDIF
    curdb->tbl[d.seq].cons[ccnt].r_constraint_name = c.r_constraint_name, curdb->tbl[d.seq].cons[ccnt
    ].drop_ind = 0, curdb->tbl[d.seq].cons[ccnt].downtime_ind = 0,
    curdb->tbl[d.seq].cons[ccnt].fk_cnt = 0, stat = alterlist(curdb->tbl[d.seq].cons[ccnt].fk,0),
    curdb->tbl[d.seq].cons[ccnt].cons_col_cnt = 0
   DETAIL
    curdb->tbl[d.seq].cons[ccnt].cons_col_cnt = (curdb->tbl[d.seq].cons[ccnt].cons_col_cnt+ 1),
    cc_cnt = curdb->tbl[d.seq].cons[ccnt].cons_col_cnt, stat = alterlist(curdb->tbl[d.seq].cons[ccnt]
     .cons_col,cc_cnt),
    curdb->tbl[d.seq].cons[ccnt].cons_col[cc_cnt].col_name = cc.column_name, curdb->tbl[d.seq].cons[
    ccnt].cons_col[cc_cnt].col_position = cc.position
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
    user_cons_columns cc,
    user_constraints c,
    user_constraints c2
   PLAN (d)
    JOIN (c
    WHERE (c.table_name=curdb->tbl[d.seq].tbl_name)
     AND c.owner=currdbuser
     AND c.constraint_type="R")
    JOIN (cc
    WHERE cc.table_name=c.table_name
     AND cc.constraint_name=c.constraint_name
     AND cc.owner=c.owner)
    JOIN (c2
    WHERE c2.constraint_name=c.r_constraint_name
     AND c2.owner=c.owner)
   ORDER BY cc.table_name, cc.constraint_name, cc.position
   HEAD cc.constraint_name
    curdb->tbl[d.seq].cons_cnt = (curdb->tbl[d.seq].cons_cnt+ 1), ccnt = curdb->tbl[d.seq].cons_cnt,
    stat = alterlist(curdb->tbl[d.seq].cons,ccnt),
    curdb->tbl[d.seq].cons[ccnt].cons_name = c.constraint_name, curdb->tbl[d.seq].cons[ccnt].
    cons_type = c.constraint_type
    IF (c.status="ENABLED")
     curdb->tbl[d.seq].cons[ccnt].status_ind = 1
    ELSEIF (c.status="DISABLED")
     curdb->tbl[d.seq].cons[ccnt].status_ind = 0
    ENDIF
    curdb->tbl[d.seq].cons[ccnt].r_constraint_name = c.r_constraint_name, curdb->tbl[d.seq].cons[ccnt
    ].cons_col_cnt = 0, curdb->tbl[d.seq].cons[ccnt].parent_table = c2.table_name
    FOR (pti = 1 TO curdb->tbl_cnt)
      IF ((curdb->tbl[pti].tbl_name=c2.table_name))
       FOR (pci = 1 TO curdb->tbl[pti].cons_cnt)
         IF ((curdb->tbl[pti].cons[pci].cons_name=c.r_constraint_name))
          FOR (pcc = 1 TO curdb->tbl[pti].cons[pci].cons_col_cnt)
            IF (pcc=1)
             curdb->tbl[d.seq].cons[ccnt].parent_table_columns = curdb->tbl[pti].cons[pci].cons_col[
             pcc].col_name
            ELSE
             curdb->tbl[d.seq].cons[ccnt].parent_table_columns = build(curdb->tbl[d.seq].cons[ccnt].
              parent_table_columns,",",curdb->tbl[pti].cons[pci].cons_col[pcc].col_name)
            ENDIF
          ENDFOR
          pci = curdb->tbl[pti].cons_cnt
         ENDIF
       ENDFOR
       pti = curdb->tbl_cnt
      ENDIF
    ENDFOR
   DETAIL
    curdb->tbl[d.seq].cons[ccnt].cons_col_cnt = (curdb->tbl[d.seq].cons[ccnt].cons_col_cnt+ 1),
    cc_cnt = curdb->tbl[d.seq].cons[ccnt].cons_col_cnt, stat = alterlist(curdb->tbl[d.seq].cons[ccnt]
     .cons_col,cc_cnt),
    curdb->tbl[d.seq].cons[ccnt].cons_col[cc_cnt].col_name = cc.column_name, curdb->tbl[d.seq].cons[
    ccnt].cons_col[cc_cnt].col_position = cc.position
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE dm_get_current_tspace
#end_program
END GO
