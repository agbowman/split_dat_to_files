CREATE PROGRAM dm_get_sizing_data2:dba
 SET rep_seq =  $1
 SET bsize = fs_proc->db[1].block_size
 SET def_tbl_ext = (2.0 * bsize)
 SET def_ind_ext = (2.0 * bsize)
 SET dm_debug_check_tspace = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_check_tspace = 1
 ENDIF
 IF (rep_seq > 0)
  IF ((tgtdb->tbl_cnt > 0))
   SELECT
    IF ((fs_proc->online_ind=1))
     PLAN (d)
      JOIN (so
      WHERE so.report_seq=rep_seq
       AND (so.instance_cd=fs_proc->space_summary[1].instance_cd)
       AND so.owner="V500"
       AND (so.segment_name=fs_proc->online_table_name)
       AND so.segment_type="TABLE")
    ELSE
     PLAN (d)
      JOIN (so
      WHERE so.report_seq=rep_seq
       AND (so.instance_cd=fs_proc->space_summary[1].instance_cd)
       AND so.owner="V500"
       AND (so.segment_name=tgtdb->tbl[d.seq].tbl_name)
       AND so.segment_type="TABLE")
    ENDIF
    INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     space_objects so
    DETAIL
     tgtdb->tbl[d.seq].row_cnt = so.row_count, tgtdb->tbl[d.seq].total_space = so.total_space, tgtdb
     ->tbl[d.seq].free_space = so.free_space
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 DECLARE ecol_cnt = i4 WITH noconstant(0)
 DECLARE dct_tbl_name = c30 WITH noconstant(" ")
 DECLARE dct_col_name = c30 WITH noconstant(" ")
 DECLARE average_s = f8 WITH noconstant(0.0)
 DECLARE dct_tbl_seq = i4 WITH noconstant(0)
 DECLARE dct_ind_seq = i4 WITH noconstant(0)
 DECLARE dct_col_seq = i4 WITH noconstant(0)
 DECLARE dct_ind_size = f8 WITH noconstant(0.0)
 DECLARE nn_cnt = i4 WITH noconstant(0)
 DECLARE rat = f8 WITH noconstant(0.0)
 DECLARE def_size = i4 WITH noconstant(0)
 DECLARE nn_tbl_name = c30 WITH noconstant(" ")
 DECLARE nn_col_name = c30 WITH noconstant(" ")
 DECLARE nn_tbl_seq = i4 WITH noconstant(0)
 DECLARE nn_col_seq = i4 WITH noconstant(0)
 DECLARE nn_tbl_size = f8 WITH noconstant(0.0)
 DECLARE a_sum = f8 WITH noconstant(0.0)
 DECLARE b_sum = f8 WITH noconstant(0.0)
 DECLARE a_b_sum = f8 WITH noconstant(0.0)
 DECLARE v_str = c120 WITH noconstant(" ")
 SET ind_header = 9
 SET tbl_header = 3
 SET date_len = 7
 SET ind_factor = 1.45
 SET tbl_factor = 1
 FREE RECORD new_i_exist_col
 RECORD new_i_exist_col(
   1 qual[*]
     2 tbl_seq = i4
     2 ind_seq = i4
     2 col_seq = i4
 )
 FREE RECORD e_col_not_null
 RECORD e_col_not_null(
   1 qual[*]
     2 tbl_seq = i4
     2 col_seq = i4
 )
 FREE RECORD dgs_str
 RECORD dgs_str(
   1 dct_s = vc
 )
 SET min_tbl_size_factor = 2
 SET min_ind_size_factor = 2
 SELECT INTO "nl:"
  tbl_name = tgtdb->tbl[dt.seq].tbl_name, ind_name = tgtdb->tbl[dt.seq].ind[di.seq].ind_name,
  ind_col_name = tgtdb->tbl[dt.seq].ind[di.seq].ind_col[dc.seq].col_name
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt di  WITH seq = 50),
   (dummyt dc  WITH seq = 25)
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].diff_ind=1))
   JOIN (di
   WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
    AND (tgtdb->tbl[dt.seq].ind[di.seq].build_ind=1))
   JOIN (dc
   WHERE (dc.seq <= tgtdb->tbl[dt.seq].ind[di.seq].ind_col_cnt))
  ORDER BY dt.seq, di.seq
  HEAD di.seq
   col_sum = 0.0, ind_tot = 0.0, min_flag = 1
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name," parms initialized")),
    CALL echo(build("row_cnt=",tgtdb->tbl[dt.seq].row_cnt)),
    CALL echo("***")
   ENDIF
  DETAIL
   FOR (ci = 1 TO tgtdb->tbl[dt.seq].tbl_col_cnt)
     IF ((tgtdb->tbl[dt.seq].tbl_col[ci].col_name=tgtdb->tbl[dt.seq].ind[di.seq].ind_col[dc.seq].
     col_name))
      IF ((tgtdb->tbl[dt.seq].tbl_col[ci].new_ind=0)
       AND (tgtdb->tbl[dt.seq].row_cnt >= 10000)
       AND  NOT ((tgtdb->tbl[dt.seq].tbl_col[ci].data_type IN ("CHAR", "DATE"))))
       ecol_cnt = (ecol_cnt+ 1), stat = alterlist(new_i_exist_col->qual,ecol_cnt), new_i_exist_col->
       qual[ecol_cnt].tbl_seq = dt.seq,
       new_i_exist_col->qual[ecol_cnt].ind_seq = di.seq, new_i_exist_col->qual[ecol_cnt].col_seq = dc
       .seq, min_flag = 0
      ELSEIF ((tgtdb->tbl[dt.seq].tbl_col[ci].new_ind=0)
       AND (tgtdb->tbl[dt.seq].row_cnt >= 10000)
       AND (tgtdb->tbl[dt.seq].tbl_col[ci].data_type IN ("CHAR", "DATE")))
       CASE (tgtdb->tbl[dt.seq].tbl_col[ci].data_type)
        OF "CHAR":
         col_sum = ((col_sum+ tgtdb->tbl[dt.seq].tbl_col[ci].data_length)+ 1)
        OF "DATE":
         col_sum = ((col_sum+ date_len)+ 1)
       ENDCASE
      ELSEIF ((tgtdb->tbl[dt.seq].tbl_col[ci].data_default != "NULL"))
       CASE (tgtdb->tbl[dt.seq].tbl_col[ci].data_type)
        OF "CHAR":
         col_sum = ((col_sum+ tgtdb->tbl[dt.seq].tbl_col[ci].data_length)+ 1)
        OF "DATE":
         col_sum = ((col_sum+ date_len)+ 1)
        ELSE
         col_sum = ((col_sum+ size(trim(tgtdb->tbl[dt.seq].tbl_col[ci].data_default)))+ 1)
       ENDCASE
      ELSE
       col_sum = (col_sum+ 1)
      ENDIF
      ci = tgtdb->tbl[dt.seq].tbl_col_cnt
     ENDIF
   ENDFOR
  FOOT  di.seq
   ind_tot = col_sum, tgtdb->tbl[dt.seq].ind[di.seq].size = ind_tot
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("col_sum=",col_sum)),
    CALL echo(build("ind_tot=",ind_tot)),
    CALL echo(build("size=",tgtdb->tbl[dt.seq].ind[di.seq].size)),
    CALL echo("***")
   ENDIF
  WITH nocounter
 ;end select
 FOR (ecol_ind = 1 TO ecol_cnt)
   SET average_s = 0.0
   SET dct_tbl_seq = new_i_exist_col->qual[ecol_ind].tbl_seq
   SET dct_ind_seq = new_i_exist_col->qual[ecol_ind].ind_seq
   SET dct_col_seq = new_i_exist_col->qual[ecol_ind].col_seq
   SET dct_tbl_name = tgtdb->tbl[dct_tbl_seq].tbl_name
   SET dct_col_name = tgtdb->tbl[dct_tbl_seq].ind[dct_ind_seq].ind_col[dct_col_seq].col_name
   SET dct_ind_size = tgtdb->tbl[dct_tbl_seq].ind[dct_ind_seq].size
   SET dgs_str->dct_s = build("vsize(d.",dct_col_name,")")
   SELECT INTO "nl:"
    s = sqlpassthru(dgs_str->dct_s,0)
    FROM (value(dct_tbl_name) d)
    WHERE parser(build("d.",dct_col_name," != null"))
    HEAD REPORT
     row + 0
    FOOT REPORT
     average_s = avg(s)
    WITH maxqual(d,10000), nocounter
   ;end select
   IF (dm_debug_check_tspace)
    CALL echo("***")
    CALL echo(build("dct_s:",dgs_str->dct_s))
    CALL echo(build("average: ",average_s))
    CALL echo("***")
   ENDIF
   SET tgtdb->tbl[dct_tbl_seq].ind[dct_ind_seq].size = (dct_ind_size+ (average_s+ 1))
 ENDFOR
 SELECT INTO "nl:"
  tbl_name = tgtdb->tbl[dt.seq].tbl_name, ind_name = tgtdb->tbl[dt.seq].ind[di.seq].ind_name
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt di  WITH seq = 50)
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].diff_ind=1))
   JOIN (di
   WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
    AND (tgtdb->tbl[dt.seq].ind[di.seq].build_ind=1))
  DETAIL
   tgtdb->tbl[dt.seq].ind[di.seq].size = (((tgtdb->tbl[dt.seq].ind[di.seq].size+ ind_header) * tgtdb
   ->tbl[dt.seq].row_cnt) * ind_factor)
   IF ((tgtdb->tbl[dt.seq].ind[di.seq].size < (min_ind_size_factor * fs_proc->db[1].block_size)))
    tgtdb->tbl[dt.seq].ind[di.seq].size = (min_ind_size_factor * fs_proc->db[1].block_size)
   ENDIF
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
    CALL echo(build("size=",tgtdb->tbl[dt.seq].ind[di.seq].size)),
    CALL echo("***")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tbl_name = tgtdb->tbl[dt.seq].tbl_name, col_name = tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt dc  WITH seq = 500)
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].diff_ind=1))
   JOIN (dc
   WHERE (dc.seq <= tgtdb->tbl[dt.seq].tbl_col_cnt)
    AND (tgtdb->tbl[dt.seq].tbl_col[dc.seq].null_to_notnull_ind=1))
  ORDER BY dt.seq
  HEAD dt.seq
   col_sum = 0.0, col_tot = 0.0, used_space = 0.0,
   min_flag = 1
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("tbl:",tgtdb->tbl[dt.seq].tbl_name," parms initialized")),
    CALL echo(build("row_cnt=",tgtdb->tbl[dt.seq].row_cnt)),
    CALL echo("***")
   ENDIF
  DETAIL
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("col=",tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name)),
    CALL echo(build("data_type=",tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_type)),
    CALL echo(build("nullable=",tgtdb->tbl[dt.seq].tbl_col[dc.seq].nullable)),
    CALL echo(build("new=",tgtdb->tbl[dt.seq].tbl_col[dc.seq].new_ind)),
    CALL echo("***")
   ENDIF
   IF ((((tgtdb->tbl[dt.seq].tbl_col[dc.seq].new_ind=1)) OR ((tgtdb->tbl[dt.seq].tbl_col[dc.seq].
   new_ind=0)
    AND (tgtdb->tbl[dt.seq].row_cnt < 10000))) )
    CASE (tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_type)
     OF "CHAR":
      col_sum = ((col_sum+ tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_length)+ 1)
     OF "DATE":
      col_sum = ((col_sum+ date_len)+ 1)
     ELSE
      col_sum = ((col_sum+ size(trim(tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_default)))+ 1)
    ENDCASE
   ELSE
    nn_cnt = (nn_cnt+ 1), stat = alterlist(e_col_not_null->qual,nn_cnt), e_col_not_null->qual[nn_cnt]
    .tbl_seq = dt.seq,
    e_col_not_null->qual[nn_cnt].col_seq = dc.seq, min_flag = 0
   ENDIF
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("col_sum: ",col_sum)),
    CALL echo("***")
   ENDIF
  FOOT  dt.seq
   col_tot = col_sum
   IF (col_tot > 0)
    tgtdb->tbl[dt.seq].size = col_tot
   ENDIF
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("col_tot: ",col_tot)),
    CALL echo(build("tbl_size=",tgtdb->tbl[dt.seq].size)),
    CALL echo("***")
   ENDIF
  WITH nocounter
 ;end select
 FOR (nn_ind = 1 TO nn_cnt)
   SET nn_tbl_seq = e_col_not_null->qual[nn_ind].tbl_seq
   SET nn_col_seq = e_col_not_null->qual[nn_ind].col_seq
   SET nn_tbl_name = tgtdb->tbl[nn_tbl_seq].tbl_name
   SET nn_col_name = tgtdb->tbl[nn_tbl_seq].tbl_col[nn_col_seq].col_name
   SET nn_tbl_size = tgtdb->tbl[nn_tbl_seq].size
   IF (dm_debug_check_tspace)
    CALL echo("***")
    CALL echo(build("tbl=",tgtdb->tbl[nn_tbl_seq].tbl_name))
    CALL echo(build("col=",tgtdb->tbl[nn_tbl_seq].tbl_col[nn_col_seq].col_name))
    CALL echo("***")
   ENDIF
   SELECT INTO "nl:"
    parser(build("t.",nn_col_name)), ni = nullind(parser(build("t.",nn_col_name)))
    FROM (value(nn_tbl_name) t)
    HEAD REPORT
     a_sum = 0.0
    FOOT REPORT
     a_sum = sum(evaluate(ni,1,1,0))
    WITH maxqual(t,10000), nocounter
   ;end select
   SELECT INTO "nl:"
    parser(build("t.",nn_col_name)), ni = nullind(parser(build("t.",nn_col_name)))
    FROM (value(nn_tbl_name) t)
    HEAD REPORT
     b_sum = 0.0
    FOOT REPORT
     b_sum = sum(evaluate(ni,1,0,1))
    WITH maxqual(t,10000), nocounter
   ;end select
   SET a_b_sum = (a_sum+ b_sum)
   SET rat = (a_sum/ a_b_sum)
   IF (dm_debug_check_tspace)
    CALL echo("***")
    CALL echo(build("ratio=",rat))
    CALL echo("***")
   ENDIF
   CASE (tgtdb->tbl[nn_tbl_seq].tbl_col[nn_col_seq].data_type)
    OF "CHAR":
     SET def_size = (tgtdb->tbl[nn_tbl_seq].tbl_col[nn_col_seq].data_length+ 1)
    OF "DATE":
     SET def_size = (date_len+ 1)
    ELSE
     SET def_size = (size(trim(tgtdb->tbl[nn_tbl_seq].tbl_col[nn_col_seq].data_default))+ 1)
   ENDCASE
   SET tgtdb->tbl[nn_tbl_seq].size = (nn_tbl_size+ (def_size * rat))
   IF ((tgtdb->tbl[nn_tbl_seq].size=0.0))
    SET tgtdb->tbl[nn_tbl_seq].size = 1
   ENDIF
   IF (dm_debug_check_tspace)
    CALL echo("***")
    CALL echo(build("tbl=",tgtdb->tbl[nn_tbl_seq].tbl_name))
    CALL echo(build("tbl_size=",tgtdb->tbl[nn_tbl_seq].size))
    CALL echo("***")
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  tbl_name = tgtdb->tbl[dt.seq].tbl_name
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt))
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].diff_ind=1)
    AND (tgtdb->tbl[dt.seq].size > 0))
  DETAIL
   tgtdb->tbl[dt.seq].size = (((tgtdb->tbl[dt.seq].size+ tbl_header) * tgtdb->tbl[dt.seq].row_cnt) *
   tbl_factor)
   IF ((tgtdb->tbl[dt.seq].size < (min_tbl_size_factor * fs_proc->db[1].block_size)))
    tgtdb->tbl[dt.seq].size = (min_tbl_size_factor * fs_proc->db[1].block_size)
   ENDIF
   IF (dm_debug_check_tspace)
    CALL echo("***"),
    CALL echo(build("Table:",tgtdb->tbl[dt.seq].tbl_name)),
    CALL echo(build("size=",tgtdb->tbl[dt.seq].size)),
    CALL echo("***")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tbl_name = tgtdb->tbl[dt.seq].tbl_name, col_name = tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt dc  WITH seq = 500)
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].diff_ind=1)
    AND (tgtdb->tbl[dt.seq].size > 0))
   JOIN (dc
   WHERE (dc.seq <= tgtdb->tbl[dt.seq].tbl_col_cnt)
    AND (tgtdb->tbl[dt.seq].tbl_col[dc.seq].new_ind=0)
    AND (tgtdb->tbl[dt.seq].tbl_col[dc.seq].null_to_notnull_ind=1))
  ORDER BY dt.seq, dc.seq
  DETAIL
   FOR (t_ind = 1 TO tgtdb->tbl[dt.seq].ind_cnt)
     IF ((tgtdb->tbl[dt.seq].ind[t_ind].build_ind=0))
      FOR (i_col = 1 TO tgtdb->tbl[dt.seq].ind[t_ind].ind_col_cnt)
        IF ((tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name=tgtdb->tbl[dt.seq].ind[t_ind].ind_col[i_col]
        .col_name))
         CASE (tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_type)
          OF "CHAR":
           tgtdb->tbl[dt.seq].ind[t_ind].size = (tgtdb->tbl[dt.seq].ind[t_ind].size+ (((tgtdb->tbl[dt
           .seq].tbl_col[dc.seq].data_length+ 1) * tgtdb->tbl[dt.seq].row_cnt) * ind_factor))
          OF "DATE":
           tgtdb->tbl[dt.seq].ind[t_ind].size = (tgtdb->tbl[dt.seq].ind[t_ind].size+ (((date_len+ 1)
            * tgtdb->tbl[dt.seq].row_cnt) * ind_factor))
          ELSE
           tgtdb->tbl[dt.seq].ind[t_ind].size = (tgtdb->tbl[dt.seq].ind[t_ind].size+ (((size(trim(
             tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_default))+ 1) * tgtdb->tbl[dt.seq].row_cnt) *
           ind_factor))
         ENDCASE
         IF (dm_debug_check_tspace)
          CALL echo("***"),
          CALL echo(build("col_name in index:",tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name)),
          CALL echo(build("index_name:",tgtdb->tbl[dt.seq].ind[t_ind].ind_name)),
          CALL echo(build("index size=",tgtdb->tbl[dt.seq].ind[t_ind].size)),
          CALL echo("***")
         ENDIF
         i_col = tgtdb->tbl[dt.seq].ind[t_ind].ind_col_cnt, t_ind = tgtdb->tbl[dt.seq].ind_cnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  FOOT  dt.seq
   row + 0
  WITH nocounter
 ;end select
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   IF ((tgtdb->tbl[t_tbl].new_ind=1))
    SET tgtdb->tbl[t_tbl].init_ext = def_tbl_ext
    SET tgtdb->tbl[t_tbl].next_ext = def_tbl_ext
   ENDIF
 ENDFOR
 IF (dm_debug_check_tspace)
  CALL echo("find existing init and next extents from user_tables...")
  FREE SET tspace_curtime
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 SELECT INTO "nl:"
  u.table_name
  FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
   user_tables u
  PLAN (d)
   JOIN (u
   WHERE (curdb->tbl[d.seq].tbl_name=u.table_name))
  ORDER BY d.seq
  DETAIL
   curdb->tbl[d.seq].init_ext = u.initial_extent, curdb->tbl[d.seq].next_ext = u.next_extent, curdb->
   tbl[d.seq].pct_increase = u.pct_increase
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  CALL echo("populate record CurExt...")
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 FREE RECORD curext
 RECORD curext(
   1 obj[*]
     2 obj_name = vc
     2 obj_type = vc
     2 last_extent = f8
 )
 SET obj_cnt = 0
 SET stat = alterlist(curext->obj,0)
 SELECT
  IF (substring(1,1,fs_proc->ora_complete_version)="9")
   WITH nocounter, orahint("rule")
  ELSE
  ENDIF
  INTO "nl:"
  e.segment_name, e.segment_type, max_bytes = max(e.bytes)
  FROM dba_extents e
  WHERE e.owner=currdbuser
   AND e.segment_type IN ("TABLE", "INDEX")
  GROUP BY e.segment_name, e.segment_type
  HEAD REPORT
   obj_cnt = 0
  DETAIL
   obj_cnt = (obj_cnt+ 1)
   IF (mod(obj_cnt,1000)=1)
    stat = alterlist(curext->obj,(obj_cnt+ 999))
   ENDIF
   curext->obj[obj_cnt].obj_name = e.segment_name, curext->obj[obj_cnt].obj_type = e.segment_type,
   curext->obj[obj_cnt].last_extent = max_bytes
  FOOT REPORT
   stat = alterlist(curext->obj,obj_cnt)
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  CALL echo("find pct_increase for existing tables from dba_extents...")
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(curdb->tbl_cnt)),
   (dummyt d1  WITH seq = value(obj_cnt))
  PLAN (d
   WHERE (curdb->tbl[d.seq].pct_increase > 0))
   JOIN (d1
   WHERE (curdb->tbl[d.seq].tbl_name=curext->obj[d1.seq].obj_name)
    AND (curext->obj[d1.seq].obj_type="TABLE"))
  DETAIL
   curdb->tbl[d.seq].next_ext = curext->obj[d1.seq].last_extent
   IF (dm_debug_check_tspace)
    CALL echo(build("tbl_name=",curdb->tbl[d.seq].tbl_name)),
    CALL echo(build("pct_increase=",curdb->tbl[d.seq].pct_increase)),
    CALL echo(build("last_used_ext=",curext->obj[d1.seq].last_extent))
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  CALL echo("find existing init and next extents from user_indexes...")
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 SELECT INTO "nl:"
  u.index_name
  FROM (dummyt dt  WITH seq = value(curdb->tbl_cnt)),
   (dummyt di  WITH seq = 50),
   user_indexes u
  PLAN (dt)
   JOIN (di
   WHERE (di.seq <= curdb->tbl[dt.seq].ind_cnt))
   JOIN (u
   WHERE (curdb->tbl[dt.seq].ind[di.seq].ind_name=u.index_name)
    AND (u.table_name=curdb->tbl[dt.seq].tbl_name))
  ORDER BY dt.seq, di.seq
  DETAIL
   curdb->tbl[dt.seq].ind[di.seq].init_ext = u.initial_extent, curdb->tbl[dt.seq].ind[di.seq].
   next_ext = u.next_extent, curdb->tbl[dt.seq].ind[di.seq].pct_increase = u.pct_increase
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  CALL echo("find pct_increase for existing indexes from dba_extents...")
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(curdb->tbl_cnt)),
   (dummyt di  WITH seq = 50),
   (dummyt d  WITH seq = value(obj_cnt))
  PLAN (dt)
   JOIN (di
   WHERE (di.seq <= curdb->tbl[dt.seq].ind_cnt)
    AND (curdb->tbl[dt.seq].ind[di.seq].pct_increase > 0))
   JOIN (d
   WHERE (curext->obj[d.seq].obj_name=curdb->tbl[dt.seq].ind[di.seq].ind_name)
    AND (curext->obj[d.seq].obj_type="INDEX"))
  DETAIL
   curdb->tbl[dt.seq].ind[di.seq].next_ext = curext->obj[d.seq].last_extent
   IF (dm_debug_check_tspace)
    CALL echo(build("index_name=",curext->obj[d.seq].obj_name)),
    CALL echo(build("pct_increase=",curdb->tbl[dt.seq].ind[di.seq].pct_increase)),
    CALL echo(build("last_used_ext=",curext->obj[d.seq].last_extent))
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  SET tspace_curtime = cnvtdatetime(curdate,curtime3)
  CALL echo(build("curtime=",format(tspace_curtime,";;q")))
 ENDIF
 IF ((fs_proc->ora_version=8))
  SELECT INTO "nl:"
   u.min_extlen
   FROM user_tablespaces u,
    (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt di  WITH seq = 50)
   PLAN (dt)
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt))
    JOIN (u
    WHERE (((tgtdb->tbl[dt.seq].tspace_name=u.tablespace_name)) OR ((tgtdb->tbl[dt.seq].ind[di.seq].
    tspace_name=u.tablespace_name))) )
   DETAIL
    IF ((tgtdb->tbl[dt.seq].tspace_name=u.tablespace_name))
     tgtdb->tbl[dt.seq].minimum_extent = u.min_extlen
    ELSE
     tgtdb->tbl[dt.seq].ind[di.seq].minimum_extent = u.min_extlen
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
     IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=1))
      IF ((fs_proc->ora_version=7))
       IF (((ceil(((tgtdb->tbl[t_tbl].ind[t_ind].size/ 10)/ bsize)) * bsize) < (5 * bsize)))
        CALL dgs_cal_ext(t_tbl,t_ind,bsize)
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].init_ext < def_ind_ext))
         SET tgtdb->tbl[t_tbl].ind[t_ind].init_ext = def_ind_ext
        ENDIF
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].next_ext < def_ind_ext))
         SET tgtdb->tbl[t_tbl].ind[t_ind].next_ext = def_ind_ext
        ENDIF
       ELSE
        CALL dgs_cal_ext(t_tbl,t_ind,(5 * bsize))
       ENDIF
      ELSEIF ((fs_proc->ora_version=8))
       IF ((tgtdb->tbl[t_tbl].ind[t_ind].minimum_extent=0.0))
        IF (((ceil(((tgtdb->tbl[t_tbl].ind[t_ind].size/ 10)/ bsize)) * bsize) < (5 * bsize)))
         CALL dgs_cal_ext(t_tbl,t_ind,bsize)
         IF ((tgtdb->tbl[t_tbl].ind[t_ind].init_ext < def_ind_ext))
          SET tgtdb->tbl[t_tbl].ind[t_ind].init_ext = def_ind_ext
         ENDIF
         IF ((tgtdb->tbl[t_tbl].ind[t_ind].next_ext < def_ind_ext))
          SET tgtdb->tbl[t_tbl].ind[t_ind].next_ext = def_ind_ext
         ENDIF
        ELSE
         CALL dgs_cal_ext(t_tbl,t_ind,(5 * bsize))
        ENDIF
       ELSE
        CALL dgs_cal_ext(t_tbl,t_ind,tgtdb->tbl[t_tbl].ind[t_ind].minimum_extent)
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].init_ext < def_ind_ext))
         SET tgtdb->tbl[t_tbl].ind[t_ind].init_ext = def_ind_ext
        ENDIF
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].next_ext < def_ind_ext))
         SET tgtdb->tbl[t_tbl].ind[t_ind].next_ext = def_ind_ext
        ENDIF
       ENDIF
      ENDIF
      SET tgtdb->tbl[t_tbl].ind[t_ind].size = (tgtdb->tbl[t_tbl].ind[t_ind].init_ext * 10)
      IF (dm_debug_check_tspace)
       CALL echo("***")
       CALL echo(build("ora_version: ",fs_proc->ora_version))
       CALL echo(build("minimum_extent: ",tgtdb->tbl[t_tbl].ind[t_ind].minimum_extent))
       CALL echo(build("index:",tgtdb->tbl[t_tbl].ind[t_ind].ind_name))
       CALL echo(build("init=",tgtdb->tbl[t_tbl].ind[t_ind].init_ext))
       CALL echo(build("next=",tgtdb->tbl[t_tbl].ind[t_ind].next_ext))
       CALL echo(build("index_size=",tgtdb->tbl[t_tbl].ind[t_ind].size))
       CALL echo("***")
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FREE RECORD pop_def
 RECORD pop_def(
   1 tbl[*]
     2 tbl_name = vc
     2 col_name = vc
     2 row_cnt = f8
   1 cnt = i4
 )
 SET pop_def->cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt dc  WITH seq = 500)
  PLAN (dt
   WHERE (tgtdb->tbl[dt.seq].sql_cursor_ind=1))
   JOIN (dc
   WHERE (dc.seq <= tgtdb->tbl[dt.seq].tbl_col_cnt)
    AND (tgtdb->tbl[dt.seq].tbl_col[dc.seq].null_to_notnull_ind=1))
  ORDER BY dt.seq
  HEAD dt.seq
   pop_def->cnt = (pop_def->cnt+ 1), stat = alterlist(pop_def->tbl,pop_def->cnt), pop_def->tbl[
   pop_def->cnt].tbl_name = tgtdb->tbl[dt.seq].tbl_name,
   pop_def->tbl[pop_def->cnt].row_cnt = tgtdb->tbl[dt.seq].row_cnt, first_col = 1
  DETAIL
   IF (first_col=1)
    IF (dm_debug_check_tspace)
     CALL echo(build("first_col=",tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name))
    ENDIF
    pop_def->tbl[pop_def->cnt].col_name = tgtdb->tbl[dt.seq].tbl_col[dc.seq].col_name, first_col = 0
   ELSE
    pop_def->tbl[pop_def->cnt].col_name = concat(pop_def->tbl[pop_def->cnt].col_name,", ",tgtdb->tbl[
     dt.seq].tbl_col[dc.seq].col_name)
   ENDIF
  FOOT  dt.seq
   IF (size(pop_def->tbl[pop_def->cnt].col_name,1) > 255)
    pop_def->tbl[pop_def->cnt].col_name = substring(1,255,pop_def->tbl[pop_def->cnt].col_name)
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_debug_check_tspace)
  CALL echorecord(pop_def)
 ENDIF
 DELETE  FROM dm_info
  WHERE info_domain="POPULATE DEFAULT VALUE"
  WITH nocounter
 ;end delete
 INSERT  FROM dm_info d,
   (dummyt t  WITH seq = value(pop_def->cnt))
  SET d.info_domain = "POPULATE DEFAULT VALUE", d.info_name = pop_def->tbl[t.seq].tbl_name, d
   .info_char = pop_def->tbl[t.seq].col_name,
   d.info_number = pop_def->tbl[t.seq].row_cnt
  PLAN (t)
   JOIN (d)
  WITH nocounter
 ;end insert
 COMMIT
 SUBROUTINE dgs_cal_ext(tbl_seq,ind_seq,min_size)
  SET tgtdb->tbl[tbl_seq].ind[ind_seq].init_ext = (ceil(((tgtdb->tbl[tbl_seq].ind[ind_seq].size/ 10)
   / min_size)) * min_size)
  SET tgtdb->tbl[tbl_seq].ind[ind_seq].next_ext = (ceil(((tgtdb->tbl[tbl_seq].ind[ind_seq].size/ 10)
   / min_size)) * min_size)
 END ;Subroutine
#end_program
END GO
