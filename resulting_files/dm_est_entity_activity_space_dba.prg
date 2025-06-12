CREATE PROGRAM dm_est_entity_activity_space:dba
 SET ea_trg_tbl_list = "DM_ENTITY_ACTIVITY_TRIGGER"
 SET ea_tbl_name = "DM_ENTITY_ACTIVITY"
 SET di_domain = "POPULATE DEFAULT VALUE"
 SET ea_tbl_factor = 1
 SET ea_ind_factor = 1.25
 SET dm_debug_ea_space = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_ea_space = 1
 ENDIF
 SELECT INTO "nl:"
  FROM user_tables u
  WHERE u.table_name=ea_trg_tbl_list
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL ea_exit_msg("Entity Activity triggers not found in this database.")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_entity_activity_trigger d
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL ea_exit_msg("Entity Activity triggers not found in this database.")
 ENDIF
 SELECT INTO "nl:"
  FROM user_triggers u
  WHERE u.trigger_name="TRG*EA"
   AND status="ENABLED"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL ea_exit_msg("Entity Activity triggers do not exist or are not enabled in this database.")
 ENDIF
 FREE RECORD ea_tbl
 RECORD ea_tbl(
   1 tcnt = i4
   1 qual[*]
     2 tbl_name = vc
     2 tgt_name = vc
     2 row_cnt = f8
 )
 SET ea_tbl->tcnt = 0
 SET stat = alterlist(ea_tbl->qual,0)
 SELECT INTO "nl:"
  FROM dm_entity_activity_trigger et,
   dm_info di
  WHERE di.info_domain=di_domain
   AND et.table_name=di.info_name
  HEAD REPORT
   xcnt = 0
  DETAIL
   xcnt = (xcnt+ 1)
   IF (mod(xcnt,50)=1)
    stat = alterlist(ea_tbl->qual,(xcnt+ 49))
   ENDIF
   ea_tbl->tcnt = xcnt, ea_tbl->qual[xcnt].tbl_name = et.table_name, ea_tbl->qual[xcnt].tgt_name = di
   .info_char,
   ea_tbl->qual[xcnt].row_cnt = di.info_number
  FOOT REPORT
   IF ((ea_tbl->tcnt > 0))
    stat = alterlist(ea_tbl->qual,ea_tbl->tcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL ea_exit_msg("Entity Activity tables do not have schema differences.")
 ENDIF
 FREE RECORD ea_obj
 RECORD ea_obj(
   1 tbl_cnt = i4
   1 tbl[*]
     2 tbl_name = vc
     2 tspace_name = vc
     2 init_extent = f8
     2 next_extent = f8
     2 row_len = f8
     2 calc_size = f8
     2 col_cnt = i4
     2 col[*]
       3 col_name = vc
       3 data_type = vc
       3 data_length = i4
     2 ind_cnt = i4
     2 ind[*]
       3 ind_name = vc
       3 tspace_name = vc
       3 init_extent = f8
       3 next_extent = f8
       3 row_len = f8
       3 calc_size = f8
 )
 SET ea_obj->tbl_cnt = 0
 SET stat = alterlist(ea_obj->tbl,0)
 SELECT INTO "nl:"
  FROM user_tables u
  WHERE u.table_name=ea_tbl_name
  HEAD REPORT
   xcnt = 0
  DETAIL
   xcnt = (xcnt+ 1), stat = alterlist(ea_obj->tbl,xcnt), ea_obj->tbl_cnt = xcnt,
   ea_obj->tbl[xcnt].tbl_name = u.table_name, ea_obj->tbl[xcnt].tspace_name = u.tablespace_name,
   ea_obj->tbl[xcnt].init_extent = u.initial_extent,
   ea_obj->tbl[xcnt].next_extent = u.next_extent, ea_obj->tbl[xcnt].calc_size = 0.0
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL ea_exit_msg(build("ERROR:",ea_tbl_name," not found in this database."))
 ENDIF
 SELECT INTO "nl:"
  FROM user_tab_columns u,
   (dummyt d  WITH seq = value(ea_obj->tbl_cnt))
  PLAN (d)
   JOIN (u
   WHERE (u.table_name=ea_obj->tbl[d.seq].tbl_name))
  ORDER BY u.table_name, u.column_id
  HEAD REPORT
   xcnt = 0
  HEAD u.table_name
   xcnt = 0, ea_obj->tbl[d.seq].col_cnt = 0, stat = alterlist(ea_obj->tbl[d.seq].col,0),
   row_len = 0.0, ea_obj->tbl[d.seq].row_len = 0.0
  DETAIL
   xcnt = (xcnt+ 1)
   IF (mod(xcnt,20)=1)
    stat = alterlist(ea_obj->tbl[d.seq].col,(xcnt+ 19))
   ENDIF
   ea_obj->tbl[d.seq].col_cnt = xcnt, ea_obj->tbl[d.seq].col[xcnt].col_name = u.column_name, ea_obj->
   tbl[d.seq].col[xcnt].data_type = u.data_type,
   ea_obj->tbl[d.seq].col[xcnt].data_length = u.data_length
   CASE (u.data_type)
    OF "NUMBER":
    OF "FLOAT":
     row_len = (row_len+ 15.0)
    OF "DATE":
     row_len = (row_len+ 7.0)
    ELSE
     row_len = (row_len+ u.data_length)
   ENDCASE
  FOOT  u.table_name
   IF ((ea_obj->tbl[d.seq].col_cnt > 0))
    ea_obj->tbl[d.seq].row_len = row_len, stat = alterlist(ea_obj->tbl[d.seq].col,ea_obj->tbl[d.seq].
     col_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_indexes u,
   (dummyt d  WITH seq = value(ea_obj->tbl_cnt))
  PLAN (d)
   JOIN (u
   WHERE (u.table_name=ea_obj->tbl[d.seq].tbl_name))
  ORDER BY u.table_name, u.index_name
  HEAD REPORT
   xcnt = 0
  HEAD u.table_name
   xcnt = 0, ea_obj->tbl[d.seq].ind_cnt = 0, stat = alterlist(ea_obj->tbl[d.seq].ind,0)
  DETAIL
   xcnt = (xcnt+ 1)
   IF (mod(xcnt,10)=1)
    stat = alterlist(ea_obj->tbl[d.seq].ind,(xcnt+ 9))
   ENDIF
   ea_obj->tbl[d.seq].ind_cnt = xcnt, ea_obj->tbl[d.seq].ind[xcnt].ind_name = u.index_name, ea_obj->
   tbl[d.seq].ind[xcnt].tspace_name = u.tablespace_name,
   ea_obj->tbl[d.seq].ind[xcnt].init_extent = u.initial_extent, ea_obj->tbl[d.seq].ind[xcnt].
   next_extent = u.next_extent, ea_obj->tbl[d.seq].ind[xcnt].calc_size = 0.0
  FOOT  u.table_name
   IF ((ea_obj->tbl[d.seq].ind_cnt > 0))
    stat = alterlist(ea_obj->tbl[d.seq].ind,ea_obj->tbl[d.seq].ind_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_ind_columns u,
   (dummyt d  WITH seq = value(ea_obj->tbl_cnt)),
   (dummyt di  WITH seq = 50),
   (dummyt dc  WITH seq = 255)
  PLAN (d)
   JOIN (di
   WHERE (di.seq <= ea_obj->tbl[d.seq].ind_cnt))
   JOIN (dc
   WHERE (dc.seq <= ea_obj->tbl[d.seq].col_cnt))
   JOIN (u
   WHERE (u.table_name=ea_obj->tbl[d.seq].tbl_name)
    AND (u.index_name=ea_obj->tbl[d.seq].ind[di.seq].ind_name)
    AND (u.column_name=ea_obj->tbl[d.seq].col[dc.seq].col_name))
  ORDER BY u.table_name, u.index_name
  HEAD u.table_name
   row_len = 0.0
  HEAD u.index_name
   row_len = 0.0, ea_obj->tbl[d.seq].ind[di.seq].row_len = 0.0
  DETAIL
   CASE (ea_obj->tbl[d.seq].col[dc.seq].data_type)
    OF "NUMBER":
    OF "FLOAT":
     row_len = (row_len+ 15.0)
    OF "DATE":
     row_len = (row_len+ 7.0)
    ELSE
     row_len = (row_len+ ea_obj->tbl[d.seq].col[dc.seq].data_length)
   ENDCASE
  FOOT  u.index_name
   IF (row_len > 0)
    ea_obj->tbl[d.seq].ind[di.seq].row_len = row_len
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(ea_tbl->tcnt))
  HEAD REPORT
   tbl_sum = 0
  FOOT REPORT
   tbl_sum = sum(ea_tbl->qual[dt.seq].row_cnt)
   FOR (ti = 1 TO ea_obj->tbl_cnt)
     ea_obj->tbl[ti].calc_size = ((ea_obj->tbl[ti].row_len * tbl_sum) * ea_tbl_factor)
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(ea_tbl->tcnt))
  HEAD REPORT
   ind_sum = 0
  FOOT REPORT
   ind_sum = sum(ea_tbl->qual[dt.seq].row_cnt)
   FOR (ti = 1 TO ea_obj->tbl_cnt)
     FOR (di = 1 TO ea_obj->tbl[ti].ind_cnt)
       ea_obj->tbl[ti].ind[di].calc_size = ((ea_obj->tbl[ti].ind[di].row_len * ind_sum) *
       ea_ind_factor)
     ENDFOR
   ENDFOR
  WITH nocounter
 ;end select
 FREE RECORD ea_tspace
 RECORD ea_tspace(
   1 tsp_cnt = i4
   1 qual[*]
     2 tspace_name = vc
     2 max_next_extent = f8
     2 calc_size = f8
     2 free_bytes = f8
     2 reqd_bytes = f8
 )
 SET ea_tspace->tsp_cnt = 0
 SET stat = alterlist(ea_tspace->qual,0)
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(ea_obj->tbl_cnt))
  PLAN (dt)
  ORDER BY ea_obj->tbl[dt.seq].tspace_name, ea_obj->tbl[dt.seq].next_extent DESC
  HEAD REPORT
   xcnt = 0, ti = 0, fnd = 0
  DETAIL
   fnd = 0
   IF ((ea_tspace->tsp_cnt > 0))
    fnd = locateval(ti,1,ea_tspace->tsp_cnt,ea_obj->tbl[dt.seq].tspace_name,ea_tspace->qual[ti].
     tspace_name)
   ENDIF
   IF ((((ea_tspace->tsp_cnt=0)) OR (fnd=0)) )
    xcnt = (xcnt+ 1), stat = alterlist(ea_tspace->qual,xcnt), ea_tspace->tsp_cnt = xcnt,
    ea_tspace->qual[xcnt].tspace_name = ea_obj->tbl[dt.seq].tspace_name, ea_tspace->qual[xcnt].
    max_next_extent = ea_obj->tbl[dt.seq].next_extent, ea_tspace->qual[xcnt].calc_size = 0.0,
    ea_tspace->qual[xcnt].free_bytes = 0.0, ea_tspace->qual[xcnt].reqd_bytes = 0.0, fnd = xcnt
   ENDIF
   ea_tspace->qual[fnd].calc_size = (ea_tspace->qual[fnd].calc_size+ ea_obj->tbl[dt.seq].calc_size)
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(ea_obj->tbl_cnt)),
   (dummyt di  WITH seq = 50)
  PLAN (dt)
   JOIN (di
   WHERE (di.seq <= ea_obj->tbl[dt.seq].ind_cnt))
  ORDER BY ea_obj->tbl[dt.seq].ind[di.seq].tspace_name, ea_obj->tbl[dt.seq].ind[di.seq].next_extent
    DESC
  HEAD REPORT
   xcnt = ea_tspace->tsp_cnt, ti = 0, fnd = 0
  DETAIL
   fnd = 0
   IF ((ea_tspace->tsp_cnt > 0))
    fnd = locateval(ti,1,ea_tspace->tsp_cnt,ea_obj->tbl[dt.seq].ind[di.seq].tspace_name,ea_tspace->
     qual[ti].tspace_name)
   ENDIF
   IF ((((ea_tspace->tsp_cnt=0)) OR (fnd=0)) )
    xcnt = (xcnt+ 1), stat = alterlist(ea_tspace->qual,xcnt), ea_tspace->tsp_cnt = xcnt,
    ea_tspace->qual[xcnt].tspace_name = ea_obj->tbl[dt.seq].ind[di.seq].tspace_name, ea_tspace->qual[
    xcnt].max_next_extent = ea_obj->tbl[dt.seq].ind[di.seq].next_extent, ea_tspace->qual[xcnt].
    calc_size = 0.0,
    ea_tspace->qual[xcnt].free_bytes = 0.0, ea_tspace->qual[xcnt].reqd_bytes = 0.0, fnd = xcnt
   ENDIF
   ea_tspace->qual[fnd].calc_size = (ea_tspace->qual[fnd].calc_size+ ea_obj->tbl[dt.seq].ind[di.seq].
   calc_size)
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 IF (dm_debug_ea_space=1)
  CALL echorecord(ea_tbl)
  CALL echorecord(ea_obj)
  CALL echorecord(ea_tspace)
 ENDIF
 SELECT INTO "nl:"
  d.tablespace_name, free_bytes = sum(d.bytes)
  FROM dba_free_space d,
   (dummyt t  WITH seq = value(ea_tspace->tsp_cnt))
  PLAN (t)
   JOIN (d
   WHERE (d.tablespace_name=ea_tspace->qual[t.seq].tspace_name)
    AND (d.bytes > ea_tspace->qual[t.seq].max_next_extent))
  DETAIL
   ea_tspace->qual[t.seq].free_bytes = free_bytes
  WITH nocounter
 ;end select
 CALL echo("***")
 SET reqd_bytes = 0
 FOR (tsi = 1 TO ea_tspace->tsp_cnt)
  SET ea_tspace->qual[tsi].reqd_bytes = (ea_tspace->qual[tsi].calc_size - ea_tspace->qual[tsi].
  free_bytes)
  IF ((ea_tspace->qual[tsi].reqd_bytes > 0))
   IF (reqd_bytes=0)
    CALL echo("The following tablespaces need indicated amount of space.")
   ENDIF
   SET reqd_bytes = 1
   CALL echo(build(ea_tspace->qual[tsi].tspace_name," needs: ",cnvtint(ea_tspace->qual[tsi].
      reqd_bytes)," bytes"))
  ENDIF
 ENDFOR
 IF (reqd_bytes=0)
  CALL echo("Sufficient tablespace is available for Entity Activity triggers")
 ENDIF
 CALL echo("***")
 SUBROUTINE ea_disp_msg(ead_msg)
   CALL echo("***")
   CALL echo(build("*"," ",ead_msg))
   CALL echo("***")
 END ;Subroutine
 SUBROUTINE ea_exit_msg(eax_msg)
  CALL ea_disp_msg(eax_msg)
  GO TO end_program
 END ;Subroutine
#end_program
END GO
