CREATE PROGRAM dm_check_tspace2:dba
 SET dm_env_name = fs_proc->env[1].name
 SET envid = fs_proc->env[1].id
 SET system = cnvtupper(cursys)
 SET dm_debug_check_tspace = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_check_tspace = 1
 ENDIF
 FREE RECORD tsp
 RECORD tsp(
   1 str = vc
 )
 FREE RECORD dct_work
 RECORD dct_work(
   1 str = vc
   1 obj_rem_size = f8
   1 free_space = f8
   1 file_cnt = i4
   1 files[*]
     2 file_id = f8
     2 bytes = f8
   1 extra_size = f8
 )
 SET mbyte = (1024.0 * 1024.0)
 SET max_size = 0.0
 SET partition_size = 0.0
 SET database_name = fillstring(10," ")
 SET max_size = (fs_proc->env[1].max_file_size * mbyte)
 SET partition_size = fs_proc->env[1].partition_size
 SET database_name = fs_proc->env[1].db_name
 SET min_tbl_size_factor = 2
 SET min_ind_size_factor = 2
 SET min_free_blocks = 4
 DECLARE max_file_nbr = i4 WITH noconstant(0)
 SET max_file_nbr = 0
 DECLARE eind_cnt = i4 WITH noconstant(0)
 SET eind_cnt = 0
 SET ext_factor = 1.1
 FREE RECORD e_index_size
 RECORD e_index_size(
   1 qual[*]
     2 ind_name = vc
     2 tspace_name = vc
     2 file_cnt = i4
     2 file[*]
       3 file_id = f8
       3 size = f8
 )
 DECLARE dct_get_datafile_seq(gds_tablespace_name) = i4
 SELECT INTO "nl:"
  x_tbl_name = curdb->tbl[dt.seq].tbl_name, x_ind_name = curdb->tbl[dt.seq].ind[di.seq].ind_name
  FROM (dummyt dt  WITH seq = value(curdb->tbl_cnt)),
   (dummyt di  WITH seq = 50)
  PLAN (dt
   WHERE dt.seq > 0)
   JOIN (di
   WHERE (di.seq <= curdb->tbl[dt.seq].ind_cnt)
    AND (curdb->tbl[dt.seq].ind[di.seq].drop_ind=1)
    AND (curdb->tbl[dt.seq].ind[di.seq].rename_ind=0))
  ORDER BY dt.seq, di.seq
  DETAIL
   eind_cnt = (eind_cnt+ 1), stat = alterlist(e_index_size->qual,eind_cnt), e_index_size->qual[
   eind_cnt].ind_name = curdb->tbl[dt.seq].ind[di.seq].ind_name,
   e_index_size->qual[eind_cnt].tspace_name = curdb->tbl[dt.seq].ind[di.seq].tspace_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   ind_name = e_index_size->qual[d.seq].ind_name
   FROM (dummyt d  WITH seq = value(eind_cnt)),
    dba_extents e
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE e.segment_type="INDEX"
     AND (e_index_size->qual[d.seq].ind_name=e.segment_name)
     AND (e_index_size->qual[d.seq].tspace_name=e.tablespace_name))
   ORDER BY d.seq, e.file_id
   HEAD d.seq
    file_cnt = 0
   HEAD e.file_id
    file_size = 0
   DETAIL
    file_size = (file_size+ e.bytes)
   FOOT  e.file_id
    file_cnt = (file_cnt+ 1), stat = alterlist(e_index_size->qual[d.seq].file,file_cnt), e_index_size
    ->qual[d.seq].file[file_cnt].file_id = e.file_id,
    e_index_size->qual[d.seq].file[file_cnt].size = file_size
   FOOT  d.seq
    e_index_size->qual[d.seq].file_cnt = file_cnt, max_file_nbr = greatest(max_file_nbr,file_cnt)
   WITH nocounter
  ;end select
 ENDIF
 FREE SET newlist
 RECORD newlist(
   1 qual[*]
     2 new_tb_name = vc
     2 total_size = f8
     2 partitioned_bytes = f8
     2 file_count = i4
     2 max_ext_size = f8
   1 count = i4
 )
 SET newlist->count = 0
 FREE SET existlist
 RECORD existlist(
   1 qual[*]
     2 tb_name = vc
     2 total_size = f8
     2 partitioned_bytes = f8
     2 calc_size = f8
     2 new_obj_size = f8
     2 init_ext_size = f8
     2 total_space = f8
     2 free_space = f8
     2 init_ext = f8
     2 next_ext = f8
     2 file_count = i4
     2 schema_change = i4
     2 max_ext_size = f8
     2 pct_increase = f8
     2 extra_size = f8
     2 files[*]
       3 file_id = f8
       3 free_bytes = f8
   1 count = i4
 )
 SET existlist->count = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tgtdb->tspace_cnt))
  PLAN (d
   WHERE (tgtdb->tspace[d.seq].new_ind=1))
  DETAIL
   newlist->count = (newlist->count+ 1), stat = alterlist(newlist->qual,newlist->count), newlist->
   qual[newlist->count].new_tb_name = tgtdb->tspace[d.seq].tspace_name,
   newlist->qual[newlist->count].total_size = 0.0, newlist->qual[newlist->count].partitioned_bytes =
   0.0, newlist->qual[newlist->count].file_count = 0,
   newlist->qual[newlist->count].max_ext_size = 0.0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tgtdb->tspace_cnt))
  PLAN (d
   WHERE (tgtdb->tspace[d.seq].new_ind=0))
  DETAIL
   existlist->count = (existlist->count+ 1), stat = alterlist(existlist->qual,existlist->count),
   existlist->qual[existlist->count].tb_name = tgtdb->tspace[d.seq].tspace_name,
   existlist->qual[existlist->count].total_size = 0.0, existlist->qual[existlist->count].
   partitioned_bytes = 0.0, existlist->qual[existlist->count].calc_size = 0.0,
   existlist->qual[existlist->count].new_obj_size = 0.0, existlist->qual[existlist->count].
   init_ext_size = 0.0, existlist->qual[existlist->count].init_ext = (2.0 * fs_proc->db[1].block_size
   ),
   existlist->qual[existlist->count].next_ext = (2.0 * fs_proc->db[1].block_size), existlist->qual[
   existlist->count].free_space = 0.0, existlist->qual[existlist->count].total_space = 0.0,
   existlist->qual[existlist->count].file_count = 0, existlist->qual[existlist->count].max_ext_size
    = 0.0, existlist->qual[existlist->count].schema_change = 0,
   existlist->qual[existlist->count].init_ext = curdb->tspace[tgtdb->tspace[d.seq].cur_idx].
   initial_extent, existlist->qual[existlist->count].next_ext = curdb->tspace[tgtdb->tspace[d.seq].
   cur_idx].next_extent, existlist->qual[existlist->count].pct_increase = curdb->tspace[tgtdb->
   tspace[d.seq].cur_idx].pct_increase,
   existlist->qual[existlist->count].extra_size = 0.0, stat = alterlist(existlist->qual[existlist->
    count].files,0)
  WITH nocounter
 ;end select
 IF ((newlist->count > 0))
  SELECT INTO "nl:"
   tbl_space = newlist->qual[ts.seq].new_tb_name
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(newlist->count))
   PLAN (ts)
    JOIN (dt
    WHERE (tgtdb->tbl[dt.seq].tspace_name=newlist->qual[ts.seq].new_tb_name))
   ORDER BY ts.seq
   HEAD ts.seq
    obj_in_tspace = 0, new_tab_size = 0.0, tab_size = 0.0,
    temp_sum = 0.0
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("tbl space:",newlist->qual[ts.seq].new_tb_name," parms initialized!")),
     CALL echo("***")
    ENDIF
   DETAIL
    IF ((tgtdb->tbl[dt.seq].new_ind=1))
     obj_in_tspace = (obj_in_tspace+ 1), new_tab_size = (new_tab_size+ tgtdb->tbl[dt.seq].init_ext)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("new tbl:",tgtdb->tbl[dt.seq].tbl_name)),
      CALL echo(build("init:",tgtdb->tbl[dt.seq].init_ext)),
      CALL echo("***")
     ENDIF
    ELSEIF ((tgtdb->tbl[dt.seq].size > 0))
     tab_size = (tab_size+ tgtdb->tbl[dt.seq].size)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("exist tbl:",tgtdb->tbl[dt.seq].tbl_name)),
      CALL echo(build("size:",tgtdb->tbl[dt.seq].size)),
      CALL echo("***")
     ENDIF
    ENDIF
    newlist->qual[ts.seq].max_ext_size = greatest(newlist->qual[ts.seq].max_ext_size,tgtdb->tbl[dt
     .seq].init_ext), newlist->qual[ts.seq].max_ext_size = greatest(newlist->qual[ts.seq].
     max_ext_size,tgtdb->tbl[dt.seq].next_ext)
   FOOT  ts.seq
    temp_sum = (tab_size+ new_tab_size), newlist->qual[ts.seq].partitioned_bytes = (((round((temp_sum
     / (partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("temp_sum:",temp_sum)),
     CALL echo(build("part_bytes:",newlist->qual[ts.seq].partitioned_bytes)),
     CALL echo(build("max_ext_size =",newlist->qual[ts.seq].max_ext_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
  FREE SET tbl_space
  SELECT INTO "nl:"
   tbl_space = newlist->qual[ts.seq].new_tb_name
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(newlist->count)),
    (dummyt di  WITH seq = 50)
   PLAN (ts)
    JOIN (dt)
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].tspace_name=newlist->qual[ts.seq].new_tb_name))
   ORDER BY ts.seq
   HEAD ts.seq
    obj_in_tspace = 0, new_ind_size = 0.0, ind_size = 0.0,
    temp_sum = 0.0
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("tbl space:",newlist->qual[ts.seq].new_tb_name," parms initialized")),
     CALL echo("***")
    ENDIF
   DETAIL
    IF ((tgtdb->tbl[dt.seq].new_ind=1))
     obj_in_tspace = (obj_in_tspace+ 1), new_ind_size = (new_ind_size+ tgtdb->tbl[dt.seq].ind[di.seq]
     .init_ext)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("new tbl indx:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
      CALL echo(build("init:",tgtdb->tbl[dt.seq].ind[di.seq].init_ext)),
      CALL echo("***")
     ENDIF
    ELSEIF ((tgtdb->tbl[dt.seq].ind[di.seq].size > 0))
     ind_size = (ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].size)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("exist tbl indx:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
      CALL echo(build("size:",tgtdb->tbl[dt.seq].ind[di.seq].size)),
      CALL echo("***")
     ENDIF
    ENDIF
    newlist->qual[ts.seq].max_ext_size = greatest(newlist->qual[ts.seq].max_ext_size,tgtdb->tbl[dt
     .seq].ind[di.seq].init_ext), newlist->qual[ts.seq].max_ext_size = greatest(newlist->qual[ts.seq]
     .max_ext_size,tgtdb->tbl[dt.seq].ind[di.seq].next_ext)
   FOOT  ts.seq
    temp_sum = (ind_size+ new_ind_size), newlist->qual[ts.seq].partitioned_bytes = (newlist->qual[ts
    .seq].partitioned_bytes+ (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size)
     * mbyte))
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("temp_sum:",temp_sum)),
     CALL echo(build("partitioned_bytes:",newlist->qual[ts.seq].partitioned_bytes)),
     CALL echo(build("max_ext_size =",newlist->qual[ts.seq].max_ext_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((existlist->count > 0))
  FREE SET tbl_space
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count))
   PLAN (ts)
    JOIN (dt
    WHERE (tgtdb->tbl[dt.seq].tspace_name=existlist->qual[ts.seq].tb_name))
   ORDER BY ts.seq
   HEAD ts.seq
    obj_in_tspace = 0, new_tab_size = 0.0, tab_size = 0.0,
    temp_sum = 0.0
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("tspace:",existlist->qual[ts.seq].tb_name," parms initialized")),
     CALL echo("***")
    ENDIF
   DETAIL
    IF ((tgtdb->tbl[dt.seq].new_ind=1))
     existlist->qual[ts.seq].schema_change = 1, obj_in_tspace = (obj_in_tspace+ 1), new_tab_size = (
     new_tab_size+ tgtdb->tbl[dt.seq].init_ext),
     existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,tgtdb->tbl[
      dt.seq].init_ext)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("new tbl:",tgtdb->tbl[dt.seq].tbl_name)),
      CALL echo(build("init:",tgtdb->tbl[dt.seq].init_ext)),
      CALL echo(build("max_ext:",existlist->qual[ts.seq].max_ext_size)),
      CALL echo("***")
     ENDIF
    ELSEIF ((tgtdb->tbl[dt.seq].size > 0))
     existlist->qual[ts.seq].schema_change = 1, tab_size = (tab_size+ tgtdb->tbl[dt.seq].size),
     existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,curdb->tbl[
      tgtdb->tbl[dt.seq].cur_idx].init_ext),
     existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,curdb->tbl[
      tgtdb->tbl[dt.seq].cur_idx].next_ext)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("exist tbl:",tgtdb->tbl[dt.seq].tbl_name)),
      CALL echo(build("size=",tgtdb->tbl[dt.seq].size)),
      CALL echo(build("init_ext=",curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].init_ext)),
      CALL echo(build("next_ext=",curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].next_ext)),
      CALL echo(build("max_ext:",existlist->qual[ts.seq].max_ext_size)),
      CALL echo("***")
     ENDIF
    ENDIF
   FOOT  ts.seq
    temp_sum = (tab_size+ new_tab_size), existlist->qual[ts.seq].calc_size = temp_sum, existlist->
    qual[ts.seq].new_obj_size = (existlist->qual[ts.seq].new_obj_size+ new_tab_size)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("calc_size=",existlist->qual[ts.seq].calc_size)),
     CALL echo(build("max_ext_size =",existlist->qual[ts.seq].max_ext_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
  FREE SET tbl_space
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt di  WITH seq = 50)
   PLAN (ts)
    JOIN (dt)
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].tspace_name=existlist->qual[ts.seq].tb_name))
   ORDER BY ts.seq
   HEAD ts.seq
    obj_in_tspace = 0, new_ind_size = 0.0, ind_size = 0.0,
    temp_sum = 0.0
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("tspace:",existlist->qual[ts.seq].tb_name," parms initialized")),
     CALL echo("***")
    ENDIF
   DETAIL
    cur_init_ext = 0.0, cur_next_ext = 0.0
    IF ((tgtdb->tbl[dt.seq].new_ind=1))
     existlist->qual[ts.seq].schema_change = 1, obj_in_tspace = (obj_in_tspace+ 1), new_ind_size = (
     new_ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].init_ext),
     existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,tgtdb->tbl[
      dt.seq].ind[di.seq].init_ext), existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[
      ts.seq].max_ext_size,tgtdb->tbl[dt.seq].ind[di.seq].next_ext)
     IF (dm_debug_check_tspace)
      CALL echo("***"),
      CALL echo(build("new index on new table:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
      CALL echo(build("init:",tgtdb->tbl[dt.seq].ind[di.seq].init_ext)),
      CALL echo(build("max_ext=",existlist->qual[ts.seq].max_ext_size)),
      CALL echo("***")
     ENDIF
    ELSEIF ((tgtdb->tbl[dt.seq].ind[di.seq].size > 0))
     existlist->qual[ts.seq].schema_change = 1, ind_size = (ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].
     size)
     IF ((tgtdb->tbl[dt.seq].ind[di.seq].build_ind=0))
      cur_init_ext = curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].ind[tgtdb->tbl[dt.seq].ind[di.seq].
      cur_idx].init_ext, cur_next_ext = curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].ind[tgtdb->tbl[dt.seq]
      .ind[di.seq].cur_idx].next_ext, existlist->qual[ts.seq].max_ext_size = greatest(existlist->
       qual[ts.seq].max_ext_size,cur_init_ext),
      existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,
       cur_next_ext)
      IF (dm_debug_check_tspace)
       CALL echo("***"),
       CALL echo(build("exist index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
       CALL echo(build("ind_size=",tgtdb->tbl[dt.seq].ind[di.seq].size)),
       CALL echo(build("init_ext=",cur_init_ext)),
       CALL echo(build("next_ext=",cur_next_ext)),
       CALL echo(build("max_ext=",existlist->qual[ts.seq].max_ext_size)),
       CALL echo("***")
      ENDIF
     ELSE
      existlist->qual[ts.seq].max_ext_size = greatest(existlist->qual[ts.seq].max_ext_size,tgtdb->
       tbl[dt.seq].ind[di.seq].init_ext), existlist->qual[ts.seq].max_ext_size = greatest(existlist->
       qual[ts.seq].max_ext_size,tgtdb->tbl[dt.seq].ind[di.seq].next_ext)
      IF (dm_debug_check_tspace)
       CALL echo("***"),
       CALL echo(build("new index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name)),
       CALL echo(build("ind_size=",tgtdb->tbl[dt.seq].ind[di.seq].size)),
       CALL echo(build("init_ext=",tgtdb->tbl[dt.seq].ind[di.seq].init_ext)),
       CALL echo(build("next_ext=",tgtdb->tbl[dt.seq].ind[di.seq].next_ext)),
       CALL echo(build("max_ext=",existlist->qual[ts.seq].max_ext_size)),
       CALL echo("***")
      ENDIF
     ENDIF
    ENDIF
   FOOT  ts.seq
    temp_sum = (ind_size+ new_ind_size), existlist->qual[ts.seq].calc_size = (existlist->qual[ts.seq]
    .calc_size+ temp_sum), existlist->qual[ts.seq].new_obj_size = (existlist->qual[ts.seq].
    new_obj_size+ new_ind_size)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("calc_size=",existlist->qual[ts.seq].calc_size)),
     CALL echo(build("max_ext_size =",existlist->qual[ts.seq].max_ext_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (t = 1 TO existlist->count)
   IF ((existlist->qual[t].schema_change=1))
    SET dct_work->str = concat("rdb alter tablespace ",existlist->qual[t].tb_name," coalesce go")
    IF (dm_debug_check_tspace)
     CALL echo(dct_work->str)
    ENDIF
    CALL parser(dct_work->str)
   ENDIF
 ENDFOR
 SET max_file_cnt = 0
 IF ((existlist->count > 0))
  SELECT INTO "nl:"
   d.tablespace_name, d.file_id, d.bytes
   FROM (dummyt ts  WITH seq = value(existlist->count)),
    dba_free_space d
   PLAN (ts)
    JOIN (d
    WHERE (d.tablespace_name=existlist->qual[ts.seq].tb_name))
   ORDER BY d.tablespace_name, d.file_id, d.bytes DESC
   HEAD d.tablespace_name
    existlist->qual[ts.seq].file_count = 0, stat = alterlist(existlist->qual[ts.seq].files,0), cnt =
    0
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("Capture free chunks for tbl_space=",d.tablespace_name)),
     CALL echo("***")
    ENDIF
   DETAIL
    existlist->qual[ts.seq].file_count = (existlist->qual[ts.seq].file_count+ 1), cnt = existlist->
    qual[ts.seq].file_count, stat = alterlist(existlist->qual[ts.seq].files,cnt),
    existlist->qual[ts.seq].files[cnt].file_id = d.file_id, existlist->qual[ts.seq].files[cnt].
    free_bytes = d.bytes, max_file_cnt = greatest(max_file_cnt,existlist->qual[ts.seq].file_count)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("file_id=",d.file_id," bytes=",d.bytes)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (max_file_nbr > 0)
  SELECT INTO "nl:"
   existlist->qual[ts.seq].tb_name, existlist->qual[ts.seq].files[tsf.seq].file_id, tsf.seq,
   e_index_size->qual[ti.seq].ind_name, ti.seq, e_index_size->qual[ti.seq].file[tif.seq].file_id,
   tif.seq
   FROM (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt tsf  WITH seq = value(max_file_cnt)),
    (dummyt ti  WITH seq = value(eind_cnt)),
    (dummyt tif  WITH seq = value(max_file_nbr))
   PLAN (ti
    WHERE ti.seq > 0)
    JOIN (tif
    WHERE (tif.seq <= e_index_size->qual[ti.seq].file_cnt))
    JOIN (ts
    WHERE (existlist->qual[ts.seq].tb_name=e_index_size->qual[ti.seq].tspace_name))
    JOIN (tsf
    WHERE (tsf.seq <= existlist->qual[ts.seq].file_count)
     AND (existlist->qual[ts.seq].files[tsf.seq].file_id=e_index_size->qual[ti.seq].file[tif.seq].
    file_id))
   ORDER BY ti.seq, tif.seq, tsf.seq
   HEAD ti.seq
    row + 0
   HEAD tif.seq
    existlist->qual[ts.seq].files[tsf.seq].free_bytes = (existlist->qual[ts.seq].files[tsf.seq].
    free_bytes+ e_index_size->qual[ti.seq].file[tif.seq].size)
   FOOT  tif.seq
    row + 0
   FOOT  ti.seq
    row + 0
   WITH nocounter
  ;end select
  FREE RECORD added_file
  RECORD added_file(
    1 file_cnt = i4
    1 file[*]
      2 file_id = i4
      2 ts_seq = i4
      2 file_seq = i4
  )
  SET a_file_cnt = 0
  SELECT INTO "nl:"
   e_index_size->qual[ti.seq].tspace_name, e_index_size->qual[ti.seq].file[tif.seq].file_id
   FROM (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt tsf  WITH seq = value(max_file_cnt)),
    (dummyt ti  WITH seq = value(eind_cnt)),
    (dummyt tif  WITH seq = value(max_file_nbr)),
    dummyt d
   PLAN (ti)
    JOIN (ts
    WHERE (existlist->qual[ts.seq].tb_name=e_index_size->qual[ti.seq].tspace_name))
    JOIN (tif
    WHERE (tif.seq <= e_index_size->qual[ti.seq].file_cnt))
    JOIN (d)
    JOIN (tsf
    WHERE (tsf.seq <= existlist->qual[ts.seq].file_count)
     AND (e_index_size->qual[ti.seq].file[tif.seq].file_id=existlist->qual[ts.seq].files[tsf.seq].
    file_id))
   ORDER BY ts.seq, ti.seq, tif.seq
   HEAD ts.seq
    a_file_cnt = 0
   HEAD ti.seq
    row + 0
   DETAIL
    added_flag = 0
    FOR (file_i = 1 TO a_file_cnt)
      IF ((added_file->file[file_i].file_id=e_index_size->qual[ti.seq].file[tif.seq].file_id))
       existlist->qual[added_file->file[file_i].ts_seq].files[added_file->file[file_i].file_seq].
       free_bytes = (existlist->qual[added_file->file[file_i].ts_seq].files[added_file->file[file_i].
       file_seq].free_bytes+ e_index_size->qual[ti.seq].file[tif.seq].size), file_i = a_file_cnt,
       added_flag = 1
      ENDIF
    ENDFOR
    IF (added_flag=0)
     existlist->qual[ts.seq].file_count = (existlist->qual[ts.seq].file_count+ 1), stat = alterlist(
      existlist->qual[ts.seq].files,existlist->qual[ts.seq].file_count), existlist->qual[ts.seq].
     files[existlist->qual[ts.seq].file_count].file_id = e_index_size->qual[ti.seq].file[tif.seq].
     file_id,
     existlist->qual[ts.seq].files[existlist->qual[ts.seq].file_count].free_bytes = e_index_size->
     qual[ti.seq].file[tif.seq].size, a_file_cnt = (a_file_cnt+ 1), stat = alterlist(added_file->file,
      a_file_cnt),
     added_file->file[a_file_cnt].file_id = e_index_size->qual[ti.seq].file[tif.seq].file_id,
     added_file->file[a_file_cnt].ts_seq = ts.seq, added_file->file[a_file_cnt].file_seq = existlist
     ->qual[ts.seq].file_count,
     added_file->file_cnt = a_file_cnt
    ENDIF
   FOOT  ti.seq
    row + 0
   FOOT  ts.seq
    stat = alterlist(added_file->file,0)
   WITH outerjoin = d, dontexist, nocounter
  ;end select
 ENDIF
 IF (dm_debug_check_tspace)
  SELECT INTO "nl:"
   FROM (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt tf  WITH seq = value(max_file_cnt))
   PLAN (ts)
    JOIN (tf
    WHERE (tf.seq <= existlist->qual[ts.seq].file_count))
   ORDER BY ts.seq, existlist->qual[ts.seq].files[tf.seq].file_id
   HEAD ts.seq
    CALL echo("***"),
    CALL echo(build("Available free chunks for tbl_space=",existlist->qual[ts.seq].tb_name))
   DETAIL
    CALL echo(build("file_id=",existlist->qual[ts.seq].files[tf.seq].file_id," bytes=",existlist->
     qual[ts.seq].files[tf.seq].free_bytes))
   FOOT  ts.seq
    CALL echo("***")
   WITH nocounter
  ;end select
 ENDIF
 IF (dm_debug_check_tspace)
  CALL echo("**********")
  CALL echo("Loop through new tables...")
  CALL echo("**********")
 ENDIF
 IF ((existlist->count > 0))
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name, tbl_name = tgtdb->tbl[dt.seq].tbl_name
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count))
   PLAN (ts)
    JOIN (dt
    WHERE (tgtdb->tbl[dt.seq].tspace_name=existlist->qual[ts.seq].tb_name)
     AND (tgtdb->tbl[dt.seq].new_ind=1))
   ORDER BY ts.seq, tgtdb->tbl[dt.seq].init_ext
   HEAD REPORT
    tbl_init_ext = 0.0
   DETAIL
    tbl_init_ext = (tgtdb->tbl[dt.seq].init_ext * ext_factor), min_free_space = 0.0, min_free_ind = 0
    FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
      IF ((existlist->qual[ts.seq].files[fi].free_bytes > tbl_init_ext))
       IF (min_free_space > 0)
        IF ((existlist->qual[ts.seq].files[fi].free_bytes < min_free_space))
         min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
        ENDIF
       ELSE
        min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
       ENDIF
      ENDIF
    ENDFOR
    IF (min_free_ind > 0)
     existlist->qual[ts.seq].files[min_free_ind].free_bytes = (existlist->qual[ts.seq].files[
     min_free_ind].free_bytes - tbl_init_ext), existlist->qual[ts.seq].free_space = (existlist->qual[
     ts.seq].free_space+ tbl_init_ext)
    ELSE
     existlist->qual[ts.seq].extra_size = (existlist->qual[ts.seq].extra_size+ tbl_init_ext)
    ENDIF
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("n_tbl_space=",existlist->qual[ts.seq].tb_name)),
     CALL echo(build("extra_size=",existlist->qual[ts.seq].extra_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
  IF (dm_debug_check_tspace)
   CALL echo("**********")
   CALL echo("Loop through existing tables...")
   CALL echo("**********")
  ENDIF
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name, tbl_name = tgtdb->tbl[dt.seq].tbl_name,
   table_next_extent = curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].next_ext
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count))
   PLAN (ts)
    JOIN (dt
    WHERE (tgtdb->tbl[dt.seq].tspace_name=existlist->qual[ts.seq].tb_name)
     AND (tgtdb->tbl[dt.seq].new_ind=0)
     AND (tgtdb->tbl[dt.seq].diff_ind=1))
   ORDER BY ts.seq, table_next_extent
   HEAD REPORT
    dct_work->obj_rem_size = 0, tbl_next_ext = 0.0, need_space = 0,
    SUBROUTINE dct_save_tspace_file_info(stf_tspace_idx)
      dct_work->file_cnt = size(existlist->qual[stf_tspace_idx].files,5), stat = alterlist(dct_work->
       files,dct_work->file_cnt)
      FOR (stf_i = 1 TO dct_work->file_cnt)
       dct_work->files[stf_i].file_id = existlist->qual[stf_tspace_idx].files[stf_i].file_id,dct_work
       ->files[stf_i].bytes = existlist->qual[stf_tspace_idx].files[stf_i].free_bytes
      ENDFOR
      dct_work->free_space = existlist->qual[stf_tspace_idx].free_space
    END ;Subroutine report
    ,
    SUBROUTINE dct_restore_tspace_file_info(rtf_tspace_idx)
      FOR (rtf_i = 1 TO dct_work->file_cnt)
       existlist->qual[rtf_tspace_idx].files[rtf_i].file_id = dct_work->files[rtf_i].file_id,
       existlist->qual[rtf_tspace_idx].files[rtf_i].free_bytes = dct_work->files[rtf_i].bytes
      ENDFOR
      existlist->qual[rtf_tspace_idx].free_space = dct_work->free_space, dct_work->file_cnt = 0, stat
       = alterlist(dct_work->files,dct_work->file_cnt)
    END ;Subroutine report
   DETAIL
    need_space = 0, dct_work->extra_size = 0, tbl_next_ext = (curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].
    next_ext * ext_factor)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("Try to fit existing table:",tgtdb->tbl[dt.seq].tbl_name," in tspace:",existlist
      ->qual[ts.seq].tb_name)),
     CALL echo(build("tbl_size=",tgtdb->tbl[dt.seq].size," next_ext=",tbl_next_ext)),
     CALL echo("***")
    ENDIF
    dct_work->obj_rem_size = tgtdb->tbl[dt.seq].size,
    CALL dct_save_tspace_file_info(ts.seq)
    IF (tbl_next_ext > 0)
     extent_factor = 0.0
     IF ((tgtdb->tbl[dt.seq].minimum_extent > 0))
      extent_factor = tgtdb->tbl[dt.seq].minimum_extent
     ELSE
      extent_factor = (5 * fs_proc->db[1].block_size)
     ENDIF
     WHILE ((dct_work->obj_rem_size > 0))
       IF ((curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].pct_increase > 0))
        tbl_next_ext = (ceil(((tbl_next_ext * (1+ (curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].
         pct_increase/ 100)))/ extent_factor)) * extent_factor)
        IF (dm_debug_check_tspace)
         CALL echo(build("pct_increase =",curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].pct_increase)),
         CALL echo(build("tbl_next_ext =",tbl_next_ext))
        ENDIF
       ENDIF
       IF ( NOT (need_space))
        min_free_space = 0.0, min_free_ind = 0
        FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
          IF ((existlist->qual[ts.seq].files[fi].free_bytes > tbl_next_ext))
           IF (min_free_space > 0)
            IF ((existlist->qual[ts.seq].files[fi].free_bytes < min_free_space))
             min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
            ENDIF
           ELSE
            min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
           ENDIF
          ENDIF
        ENDFOR
        IF (min_free_ind > 0)
         existlist->qual[ts.seq].files[min_free_ind].free_bytes = (existlist->qual[ts.seq].files[
         min_free_ind].free_bytes - tbl_next_ext)
         IF (dm_debug_check_tspace)
          CALL echo(build("file_id:",existlist->qual[ts.seq].files[min_free_ind].file_id,
           " file_free:",existlist->qual[ts.seq].files[min_free_ind].free_bytes))
         ENDIF
         existlist->qual[ts.seq].free_space = (existlist->qual[ts.seq].free_space+ tbl_next_ext)
        ELSE
         need_space = 1
        ENDIF
       ENDIF
       dct_work->obj_rem_size = (dct_work->obj_rem_size - tbl_next_ext)
       IF (dm_debug_check_tspace)
        CALL echo(build("tbl_rem_size=",dct_work->obj_rem_size))
       ENDIF
       dct_work->extra_size = (dct_work->extra_size+ tbl_next_ext)
     ENDWHILE
     IF (need_space)
      CALL dct_restore_tspace_file_info(ts.seq), existlist->qual[ts.seq].extra_size = (existlist->
      qual[ts.seq].extra_size+ dct_work->extra_size)
      IF (dm_debug_check_tspace)
       CALL echo(build("Cannot fit remaining bytes:",dct_work->extra_size))
      ENDIF
     ENDIF
    ENDIF
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("e_tbl_space=",existlist->qual[ts.seq].tb_name)),
     CALL echo(build("extra_size=",existlist->qual[ts.seq].extra_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
  IF (dm_debug_check_tspace)
   CALL echo("**********")
   CALL echo("Loop through index has build_ind =0...")
   CALL echo("**********")
  ENDIF
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name, ind_name = tgtdb->tbl[dt.seq].ind[di.seq].ind_name,
   index_next_extent = curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].ind[tgtdb->tbl[dt.seq].ind[di.seq].
   cur_idx].next_ext,
   ind_size = tgtdb->tbl[dt.seq].ind[di.seq].size
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt di  WITH seq = 50)
   PLAN (ts)
    JOIN (dt
    WHERE (tgtdb->tbl[dt.seq].new_ind=0)
     AND (tgtdb->tbl[dt.seq].diff_ind=1))
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].tspace_name=existlist->qual[ts.seq].tb_name)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].build_ind=0)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].size > 0))
   ORDER BY ts.seq, tgtdb->tbl[dt.seq].ind[di.seq].size
   HEAD REPORT
    dct_work->obj_rem_size = 0, ind_next_ext = 0.0, need_space = 0,
    SUBROUTINE dct_save_tspace_file_info(stf_tspace_idx)
      dct_work->file_cnt = size(existlist->qual[stf_tspace_idx].files,5), stat = alterlist(dct_work->
       files,dct_work->file_cnt)
      FOR (stf_i = 1 TO dct_work->file_cnt)
       dct_work->files[stf_i].file_id = existlist->qual[stf_tspace_idx].files[stf_i].file_id,dct_work
       ->files[stf_i].bytes = existlist->qual[stf_tspace_idx].files[stf_i].free_bytes
      ENDFOR
      dct_work->free_space = existlist->qual[stf_tspace_idx].free_space
    END ;Subroutine report
    ,
    SUBROUTINE dct_restore_tspace_file_info(rtf_tspace_idx)
      FOR (rtf_i = 1 TO dct_work->file_cnt)
       existlist->qual[rtf_tspace_idx].files[rtf_i].file_id = dct_work->files[rtf_i].file_id,
       existlist->qual[rtf_tspace_idx].files[rtf_i].free_bytes = dct_work->files[rtf_i].bytes
      ENDFOR
      existlist->qual[rtf_tspace_idx].free_space = dct_work->free_space, dct_work->file_cnt = 0, stat
       = alterlist(dct_work->files,dct_work->file_cnt)
    END ;Subroutine report
   DETAIL
    need_space = 0, dct_work->extra_size = 0, ind_next_ext = (curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].
    ind[tgtdb->tbl[dt.seq].ind[di.seq].cur_idx].next_ext * ext_factor)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("Try to fit index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name," in tspace:",
      existlist->qual[ts.seq].tb_name)),
     CALL echo(build("ind_size=",tgtdb->tbl[dt.seq].ind[di.seq].size," next=",ind_next_ext)),
     CALL echo("***")
    ENDIF
    dct_work->obj_rem_size = tgtdb->tbl[dt.seq].ind[di.seq].size,
    CALL dct_save_tspace_file_info(ts.seq)
    IF (ind_next_ext > 0)
     extent_factor = 0.0
     IF ((tgtdb->tbl[dt.seq].ind[di.seq].minimum_extent > 0))
      extent_factor = tgtdb->tbl[dt.seq].ind[di.seq].minimum_extent
     ELSE
      extent_factor = (5 * fs_proc->db[1].block_size)
     ENDIF
     WHILE ((dct_work->obj_rem_size > 0))
       IF ((curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].ind[tgtdb->tbl[dt.seq].ind[di.seq].cur_idx].
       pct_increase > 0))
        ind_pct_increase = 0.0, ind_pct_increase = (curdb->tbl[tgtdb->tbl[dt.seq].cur_idx].ind[tgtdb
        ->tbl[dt.seq].ind[di.seq].cur_idx].pct_increase/ 100), ind_next_ext = (ceil(((ind_next_ext *
         (1+ ind_pct_increase))/ extent_factor)) * extent_factor)
        IF (dm_debug_check_tspace)
         CALL echo(build("pct_increase =",ind_pct_increase)),
         CALL echo(build("ind_next_ext =",ind_next_ext))
        ENDIF
       ENDIF
       IF ( NOT (need_space))
        min_free_space = 0.0, min_free_ind = 0
        FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
          IF ((existlist->qual[ts.seq].files[fi].free_bytes > ind_next_ext))
           IF (min_free_space > 0)
            IF ((existlist->qual[ts.seq].files[fi].free_bytes < min_free_space))
             min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
            ENDIF
           ELSE
            min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
           ENDIF
          ENDIF
        ENDFOR
        IF (min_free_ind > 0)
         existlist->qual[ts.seq].files[min_free_ind].free_bytes = (existlist->qual[ts.seq].files[
         min_free_ind].free_bytes - ind_next_ext)
         IF (dm_debug_check_tspace)
          CALL echo(build("file_id:",existlist->qual[ts.seq].files[min_free_ind].file_id,
           " file_free:",existlist->qual[ts.seq].files[min_free_ind].free_bytes))
         ENDIF
         existlist->qual[ts.seq].free_space = (existlist->qual[ts.seq].free_space+ ind_next_ext)
        ELSE
         need_space = 1
        ENDIF
       ENDIF
       dct_work->obj_rem_size = (dct_work->obj_rem_size - ind_next_ext)
       IF (dm_debug_check_tspace)
        CALL echo(build("ind_rem_size=",dct_work->obj_rem_size))
       ENDIF
       dct_work->extra_size = (dct_work->extra_size+ ind_next_ext)
     ENDWHILE
     IF (need_space)
      existlist->qual[ts.seq].extra_size = (existlist->qual[ts.seq].extra_size+ dct_work->extra_size)
      IF (dm_debug_check_tspace)
       CALL echo(build("Cannot fit remaining bytes:",dct_work->extra_size))
      ENDIF
      CALL dct_restore_tspace_file_info(ts.seq)
     ENDIF
    ENDIF
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("ind_tbl_space=",existlist->qual[ts.seq].tb_name)),
     CALL echo(build("extra_size=",existlist->qual[ts.seq].extra_size)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
  IF (dm_debug_check_tspace)
   CALL echo("**********")
   CALL echo("loop through indexes with build_ind =1 ...")
   CALL echo("**********")
  ENDIF
  SELECT INTO "nl:"
   tbl_space = existlist->qual[ts.seq].tb_name, ind_name = tgtdb->tbl[dt.seq].ind[di.seq].ind_name,
   index_next_extent = tgtdb->tbl[dt.seq].ind[di.seq].next_ext,
   ind_size = tgtdb->tbl[dt.seq].ind[di.seq].size
   FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt ts  WITH seq = value(existlist->count)),
    (dummyt di  WITH seq = 50)
   PLAN (ts)
    JOIN (dt
    WHERE (((tgtdb->tbl[dt.seq].new_ind=1)) OR ((tgtdb->tbl[dt.seq].diff_ind=1))) )
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[dt.seq].ind_cnt)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].tspace_name=existlist->qual[ts.seq].tb_name)
     AND (tgtdb->tbl[dt.seq].ind[di.seq].build_ind=1))
   ORDER BY ts.seq, tgtdb->tbl[dt.seq].ind[di.seq].size
   HEAD REPORT
    dct_work->obj_rem_size = 0, ind_next_ext = 0.0, need_space = 0,
    ind_init_ext = 0.0,
    SUBROUTINE dct_save_tspace_file_info(stf_tspace_idx)
      dct_work->file_cnt = size(existlist->qual[stf_tspace_idx].files,5), stat = alterlist(dct_work->
       files,dct_work->file_cnt)
      FOR (stf_i = 1 TO dct_work->file_cnt)
       dct_work->files[stf_i].file_id = existlist->qual[stf_tspace_idx].files[stf_i].file_id,dct_work
       ->files[stf_i].bytes = existlist->qual[stf_tspace_idx].files[stf_i].free_bytes
      ENDFOR
      dct_work->free_space = existlist->qual[stf_tspace_idx].free_space
    END ;Subroutine report
    ,
    SUBROUTINE dct_restore_tspace_file_info(rtf_tspace_idx)
      FOR (rtf_i = 1 TO dct_work->file_cnt)
       existlist->qual[rtf_tspace_idx].files[rtf_i].file_id = dct_work->files[rtf_i].file_id,
       existlist->qual[rtf_tspace_idx].files[rtf_i].free_bytes = dct_work->files[rtf_i].bytes
      ENDFOR
      existlist->qual[rtf_tspace_idx].free_space = dct_work->free_space, dct_work->file_cnt = 0, stat
       = alterlist(dct_work->files,dct_work->file_cnt)
    END ;Subroutine report
   DETAIL
    need_space = 0, dct_work->extra_size = 0, ind_init_ext = (tgtdb->tbl[dt.seq].ind[di.seq].init_ext
     * ext_factor),
    ind_next_ext = (tgtdb->tbl[dt.seq].ind[di.seq].next_ext * ext_factor)
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("Try to fit index:",tgtdb->tbl[dt.seq].ind[di.seq].ind_name," in tspace:",
      existlist->qual[ts.seq].tb_name)),
     CALL echo(build("ind_size=",tgtdb->tbl[dt.seq].ind[di.seq].size," init=",ind_init_ext," next=",
      ind_next_ext)),
     CALL echo("***")
    ENDIF
    dct_work->obj_rem_size = tgtdb->tbl[dt.seq].ind[di.seq].size,
    CALL dct_save_tspace_file_info(ts.seq), min_free_space = 0.0,
    min_free_ind = 0
    FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
      IF ((existlist->qual[ts.seq].files[fi].free_bytes > ind_init_ext))
       IF (min_free_space > 0)
        IF ((existlist->qual[ts.seq].files[fi].free_bytes < min_free_space))
         min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
        ENDIF
       ELSE
        min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
       ENDIF
      ENDIF
    ENDFOR
    IF (min_free_ind > 0)
     existlist->qual[ts.seq].files[min_free_ind].free_bytes = (existlist->qual[ts.seq].files[
     min_free_ind].free_bytes - ind_init_ext)
     IF (dm_debug_check_tspace)
      CALL echo(build("file_id:",existlist->qual[ts.seq].files[min_free_ind].file_id," file_free:",
       existlist->qual[ts.seq].files[min_free_ind].free_bytes))
     ENDIF
     existlist->qual[ts.seq].free_space = (existlist->qual[ts.seq].free_space+ ind_init_ext)
    ELSE
     need_space = 1
    ENDIF
    dct_work->extra_size = (dct_work->extra_size+ ind_init_ext), dct_work->obj_rem_size = (dct_work->
    obj_rem_size - ind_init_ext)
    IF (dm_debug_check_tspace)
     CALL echo(build("ind_rem_size=",dct_work->obj_rem_size))
    ENDIF
    IF ((tgtdb->tbl[dt.seq].new_ind=0))
     IF ((tgtdb->tbl[dt.seq].ind[di.seq].next_ext > 0))
      first_next_ext = 1, extent_factor = 0.0
      IF ((tgtdb->tbl[dt.seq].ind[di.seq].minimum_extent > 0))
       extent_factor = tgtdb->tbl[dt.seq].ind[di.seq].minimum_extent
      ELSE
       extent_factor = (5 * fs_proc->db[1].block_size)
      ENDIF
      IF (dm_debug_check_tspace)
       CALL echo("Try to fit next extent..."),
       CALL echo(build("ext_factor=",extent_factor))
      ENDIF
      WHILE ((dct_work->obj_rem_size > 0))
        IF (first_next_ext=0)
         IF ((existlist->qual[ts.seq].pct_increase > 0))
          ind_next_ext = (ceil(((ind_next_ext * (1+ (existlist->qual[ts.seq].pct_increase/ 100)))/
           extent_factor)) * extent_factor)
          IF (dm_debug_check_tspace)
           CALL echo(build("pct_increase =",existlist->qual[ts.seq].pct_increase)),
           CALL echo(build("ind_next_ext =",ind_next_ext))
          ENDIF
         ENDIF
        ENDIF
        IF ( NOT (need_space))
         min_free_space = 0.0, min_free_ind = 0
         FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
           IF ((existlist->qual[ts.seq].files[fi].free_bytes > ind_next_ext))
            IF (min_free_space > 0)
             IF ((existlist->qual[ts.seq].files[fi].free_bytes < min_free_space))
              min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
             ENDIF
            ELSE
             min_free_space = existlist->qual[ts.seq].files[fi].free_bytes, min_free_ind = fi
            ENDIF
           ENDIF
         ENDFOR
         IF (min_free_ind > 0)
          existlist->qual[ts.seq].files[min_free_ind].free_bytes = (existlist->qual[ts.seq].files[
          min_free_ind].free_bytes - ind_next_ext)
          IF (dm_debug_check_tspace)
           CALL echo(build("file_id:",existlist->qual[ts.seq].files[min_free_ind].file_id,
            " file_free:",existlist->qual[ts.seq].files[min_free_ind].free_bytes))
          ENDIF
          existlist->qual[ts.seq].free_space = (existlist->qual[ts.seq].free_space+ ind_next_ext)
         ELSE
          need_space = 1
         ENDIF
        ENDIF
        dct_work->obj_rem_size = (dct_work->obj_rem_size - ind_next_ext)
        IF (dm_debug_check_tspace)
         CALL echo(build("ind_rem_size=",dct_work->obj_rem_size))
        ENDIF
        dct_work->extra_size = (dct_work->extra_size+ ind_next_ext)
      ENDWHILE
      IF (need_space)
       existlist->qual[ts.seq].extra_size = (existlist->qual[ts.seq].extra_size+ dct_work->extra_size
       )
       IF (dm_debug_check_tspace)
        CALL echo(build("Cannot fit remaining bytes:",existlist->qual[ts.seq].extra_size))
       ENDIF
       CALL dct_restore_tspace_file_info(ts.seq)
      ENDIF
     ENDIF
    ENDIF
    IF (dm_debug_check_tspace)
     CALL echo("***"),
     CALL echo(build("ind_tbl_space=",existlist->qual[ts.seq].tb_name)),
     CALL echo(build("free_space=",existlist->qual[ts.seq].free_space)),
     CALL echo("***")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM dm_env_files d
  WHERE (d.environment_id=fs_proc->env[1].id)
   AND d.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end delete
 COMMIT
 IF (system != "AIX")
  FOR (c = 1 TO newlist->count)
    SET newlist->qual[c].file_count = 0
    SET file_count = 0
    SET raw_size = 0.0
    SET total_size = newlist->qual[c].partitioned_bytes
    IF ((total_size < (newlist->qual[c].max_ext_size+ (10 * fs_proc->db[1].block_size))))
     SET total_size = (newlist->qual[c].max_ext_size+ (10 * fs_proc->db[1].block_size))
     SET total_size = (((round((total_size/ (partition_size * mbyte)),0)+ 1) * partition_size) *
     mbyte)
    ENDIF
    WHILE (total_size > 0)
      SET file_count = dct_get_datafile_seq(newlist->qual[c].new_tb_name)
      SET file_count = (file_count+ 1)
      IF (total_size > max_size)
       SET raw_size = max_size
      ELSE
       SET raw_size = total_size
      ENDIF
      SET total_size = (total_size - raw_size)
      SET newlist->qual[c].total_size = raw_size
      SET newlist->qual[c].file_count = file_count
      SET fname = fillstring(40," ")
      SET fname = build(newlist->qual[c].new_tb_name,"_",format(cnvtstring(newlist->qual[c].
         file_count),"###;P0"))
      INSERT  FROM dm_env_files def
       SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
        def.updt_id = 0, def.updt_task = 0, def.file_type =
        IF (substring(1,1,newlist->qual[c].new_tb_name)="I") "INDEX"
        ELSE "DATA"
        ENDIF
        ,
        def.file_size = newlist->qual[c].total_size, def.size_sequence = file_count, def
        .environment_id = fs_proc->env[1].id,
        def.tablespace_name = newlist->qual[c].new_tb_name, def.file_name = fname
       WITH nocounter
      ;end insert
    ENDWHILE
  ENDFOR
  FOR (a = 1 TO existlist->count)
    SET diff = 0.0
    SET existlist->qual[a].partitioned_bytes = 0.0
    IF ((existlist->qual[a].extra_size > 0))
     IF (dm_debug_check_tspace)
      CALL echo(build("tspace: ",existlist->qual[a].tb_name))
      CALL echo(build("extra_size =",existlist->qual[a].extra_size))
     ENDIF
     IF ((existlist->qual[a].extra_size < (existlist->qual[a].max_ext_size+ (10 * fs_proc->db[1].
     block_size))))
      SET existlist->qual[a].extra_size = (existlist->qual[a].max_ext_size+ (10 * fs_proc->db[1].
      block_size))
      IF (dm_debug_check_tspace)
       CALL echo("object size is less than max_ext_size")
       CALL echo(build("new_extra_size = ",existlist->qual[a].extra_size))
      ENDIF
     ENDIF
     SET existlist->qual[a].partitioned_bytes = (((round((existlist->qual[a].extra_size/ (
      partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)
     IF (dm_debug_check_tspace)
      CALL echo(build("partition_size= ",partition_size))
      CALL echo(build("mbyte =",mbyte))
      CALL echo(build("partitioned_bytes =",existlist->qual[a].partitioned_bytes))
     ENDIF
     SET db_count = 0
     SET db_count = dct_get_datafile_seq(existlist->qual[a].tb_name)
     SET existlist->qual[a].file_count = db_count
     SET total_size = existlist->qual[a].partitioned_bytes
     WHILE (total_size > 0)
       SET file_count = (existlist->qual[a].file_count+ 1)
       IF (total_size > max_size)
        SET raw_size = max_size
       ELSE
        SET raw_size = total_size
       ENDIF
       SET total_size = (total_size - raw_size)
       SET existlist->qual[a].total_size = raw_size
       SET existlist->qual[a].file_count = file_count
       SET fname = fillstring(40," ")
       SET fname = build(existlist->qual[a].tb_name,"_",format(cnvtstring(existlist->qual[a].
          file_count),"###;P0"))
       INSERT  FROM dm_env_files def
        SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
         def.updt_id = 0, def.updt_task = 0, def.file_type =
         IF (substring(1,1,existlist->qual[a].tb_name)="I") "INDEX"
         ELSE "DATA"
         ENDIF
         ,
         def.file_size = existlist->qual[a].total_size, def.size_sequence = file_count, def
         .environment_id = fs_proc->env[1].id,
         def.tablespace_name = existlist->qual[a].tb_name, def.file_name = fname, def
         .tablespace_exist_ind = 1
        WITH nocounter
       ;end insert
     ENDWHILE
    ENDIF
  ENDFOR
 ELSE
  FREE SET file_sizes
  RECORD file_sizes(
    1 scount = i4
    1 sizes[*]
      2 size = f8
      2 size_seq = f8
  )
  SET file_sizes->scount = 0
  SET dclcom = build("ls /dev/r",cnvtlower(database_name),"_*  >vol_out.dat")
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET db_length = size(trim(database_name),1)
  SET sb_length = (db_length+ 8)
  SET ss_length = (sb_length+ 5)
  FREE DEFINE rtl
  FREE SET file_loc
  SET logical file_loc "vol_out.dat"
  DEFINE rtl "file_loc"
  SELECT INTO "nl:"
   r.line
   FROM rtlt r
   DETAIL
    size_found = 0, size_bytes = ((cnvtint(substring(sb_length,4,r.line)) - 1) * mbyte), size_seq =
    cnvtint(substring(ss_length,3,r.line))
    FOR (i = 1 TO file_sizes->scount)
      IF ((size_bytes=file_sizes->sizes[i].size))
       IF ((file_sizes->sizes[i].size_seq < size_seq))
        file_sizes->sizes[i].size_seq = size_seq
       ENDIF
       size_found = 1
      ENDIF
    ENDFOR
    IF (size_found=0)
     file_sizes->scount = (file_sizes->scount+ 1)
     IF (mod(file_sizes->scount,10)=1)
      stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
     ENDIF
     file_sizes->sizes[file_sizes->scount].size = size_bytes, file_sizes->sizes[file_sizes->scount].
     size_seq = size_seq
    ENDIF
   WITH nocounter
  ;end select
  FREE SET tspace_files
  RECORD tspace_files(
    1 fcount = i4
    1 tname[*]
      2 size = f8
      2 raw_size = f8
      2 tspace_name = c32
      2 fname = c40
      2 size_seq = f8
  )
  SET tspace_files->fcount = 0
  FOR (kount = 1 TO newlist->count)
    SET row_count = 1
    SET total_size = newlist->qual[kount].partitioned_bytes
    IF ((total_size < (newlist->qual[kount].max_ext_size+ (10 * fs_proc->db[1].block_size))))
     SET total_size = (newlist->qual[kount].max_ext_size+ (10 * fs_proc->db[1].block_size))
     SET total_size = (((round((total_size/ (partition_size * mbyte)),0)+ 1) * partition_size) *
     mbyte)
    ENDIF
    WHILE (total_size > 0.0)
      SET tspace_files->fcount = (tspace_files->fcount+ 1)
      IF (mod(tspace_files->fcount,10)=1)
       SET stat = alterlist(tspace_files->tname,(tspace_files->fcount+ 9))
      ENDIF
      IF (total_size > max_size)
       SET raw_size = max_size
      ELSE
       SET raw_size = total_size
      ENDIF
      SET total_size = (total_size - raw_size)
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
      SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
      SET tspace_files->tname[tspace_files->fcount].tspace_name = newlist->qual[kount].new_tb_name
      SET size_found = 0
      FOR (i = 1 TO file_sizes->scount)
        IF (((raw_size - mbyte)=file_sizes->sizes[i].size))
         SET file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1)
         SET tspace_files->tname[tspace_files->fcount].size_seq = file_sizes->sizes[i].size_seq
         SET size_found = 1
        ENDIF
      ENDFOR
      IF (size_found=0)
       SET file_sizes->scount = (file_sizes->scount+ 1)
       IF (mod(file_sizes->scount,10)=1)
        SET stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
       ENDIF
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
       SET file_sizes->sizes[file_sizes->scount].size_seq = 1
       SET tspace_files->tname[tspace_files->fcount].size_seq = 1
      ENDIF
      SET fname = fillstring(80," ")
      SET file_seq = format(cnvtstring(row_count),"###;P0")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024.0 * 1024.0))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
      SET row_count = (row_count+ 1)
      SET tspace_files->tname[tspace_files->fcount].fname = fname
      INSERT  FROM dm_env_files def
       SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
        def.updt_id = 0, def.updt_task = 0, def.file_type =
        IF (substring(1,1,tspace_files->tname[tspace_files->fcount].tspace_name)="I") "INDEX"
        ELSE "DATA"
        ENDIF
        ,
        def.file_size = tspace_files->tname[tspace_files->fcount].size, def.size_sequence =
        tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = fs_proc->env[1].id,
        def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name =
        tspace_files->tname[tspace_files->fcount].fname
       WITH nocounter
      ;end insert
    ENDWHILE
  ENDFOR
  COMMIT
  FREE SET tspace_files
  RECORD tspace_files(
    1 fcount = i4
    1 tname[*]
      2 size = f8
      2 raw_size = f8
      2 tspace_name = c32
      2 fname = c40
      2 size_seq = f8
  )
  SET tspace_files->fcount = 0
  FOR (a = 1 TO existlist->count)
   SET existlist->qual[a].partitioned_bytes = 0.0
   IF ((existlist->qual[a].extra_size > 0))
    IF (dm_debug_check_tspace)
     CALL echo(build("tspace: ",existlist->qual[a].tb_name))
     CALL echo(build("extra_size =",existlist->qual[a].extra_size))
    ENDIF
    IF ((existlist->qual[a].extra_size < (existlist->qual[a].max_ext_size+ (10 * fs_proc->db[1].
    block_size))))
     SET existlist->qual[a].extra_size = (existlist->qual[a].max_ext_size+ (10 * fs_proc->db[1].
     block_size))
     IF (dm_debug_check_tspace)
      CALL echo("object size is less than max_ext_size")
      CALL echo(build("new_extra_size = ",existlist->qual[a].extra_size))
     ENDIF
    ENDIF
    SET existlist->qual[a].partitioned_bytes = (((round((existlist->qual[a].extra_size/ (
     partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)
    SET row_count = 1
    SET total_size = existlist->qual[a].partitioned_bytes
    IF (dm_debug_check_tspace)
     CALL echo(build("partition_size: ",partition_size))
     CALL echo(build("mbyte =",mbyte))
     CALL echo(build("total_size: ",total_size))
    ENDIF
    WHILE (total_size > 0.0)
      SET tspace_files->fcount = (tspace_files->fcount+ 1)
      IF (mod(tspace_files->fcount,10)=1)
       SET stat = alterlist(tspace_files->tname,(tspace_files->fcount+ 9))
      ENDIF
      IF (total_size > max_size)
       SET raw_size = max_size
      ELSE
       SET raw_size = total_size
      ENDIF
      SET total_size = (total_size - raw_size)
      IF (dm_debug_check_tspace)
       CALL echo(build("mbyte:: ",mbyte))
      ENDIF
      SET tspace_files->tname[tspace_files->fcount].size = (raw_size - mbyte)
      SET tspace_files->tname[tspace_files->fcount].raw_size = raw_size
      SET tspace_files->tname[tspace_files->fcount].tspace_name = existlist->qual[a].tb_name
      IF (dm_debug_check_tspace)
       CALL echo(build("size: ",tspace_files->tname[tspace_files->fcount].size))
       CALL echo(build("tspace: ",tspace_files->tname[tspace_files->fcount].tspace_name))
      ENDIF
      SET size_found = 0
      FOR (i = 1 TO file_sizes->scount)
        IF (((raw_size - mbyte)=file_sizes->sizes[i].size))
         SET file_sizes->sizes[i].size_seq = (file_sizes->sizes[i].size_seq+ 1)
         SET tspace_files->tname[tspace_files->fcount].size_seq = file_sizes->sizes[i].size_seq
         SET size_found = 1
        ENDIF
      ENDFOR
      IF (size_found=0)
       SET file_sizes->scount = (file_sizes->scount+ 1)
       IF (mod(file_sizes->scount,10)=1)
        SET stat = alterlist(file_sizes->sizes,(file_sizes->scount+ 9))
       ENDIF
       SET file_sizes->sizes[file_sizes->scount].size = (raw_size - mbyte)
       SET file_sizes->sizes[file_sizes->scount].size_seq = 1
       SET tspace_files->tname[tspace_files->fcount].size_seq = 1
      ENDIF
      SET fname = fillstring(80," ")
      SET file_seq = format(cnvtstring(row_count),"###;P0")
      SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024.0 * 1024.0))),
        "####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),"###;P0"
        ))
      SET row_count = (row_count+ 1)
      SET tspace_files->tname[tspace_files->fcount].fname = fname
      INSERT  FROM dm_env_files def
       SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
        def.updt_id = 0, def.updt_task = 0, def.file_type =
        IF (substring(1,1,tspace_files->tname[tspace_files->fcount].tspace_name)="I") "INDEX"
        ELSE "DATA"
        ENDIF
        ,
        def.file_size = tspace_files->tname[tspace_files->fcount].size, def.size_sequence =
        tspace_files->tname[tspace_files->fcount].size_seq, def.environment_id = fs_proc->env[1].id,
        def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name =
        tspace_files->tname[tspace_files->fcount].fname, def.tablespace_exist_ind = 1
       WITH nocounter
      ;end insert
    ENDWHILE
   ENDIF
  ENDFOR
 ENDIF
 COMMIT
 SUBROUTINE dct_get_datafile_seq(gds_tablespace_name)
   SET max_seq = 0
   SELECT INTO "nl:"
    a.file_name
    FROM dba_data_files a
    WHERE findstring(gds_tablespace_name,a.file_name) > 0
    HEAD REPORT
     beg_pos = 0, end_pos = 0, ts_end_pos = 0,
     seq_beg_pos = 0, seq_cnt = 0, num_flag = 1,
     seq = 0, ts_name = fillstring(30," "), letter = fillstring(1," "),
     name = fillstring(257," ")
    DETAIL
     beg_pos = 0, end_pos = 0, ts_end_pos = 0,
     seq_beg_pos = 0, seq_cnt = 0, num_flag = 1,
     seq = 0, ts_name = fillstring(30," "), beg_pos = findstring("]",a.file_name),
     name = substring((beg_pos+ 1),257,a.file_name), end_pos = (findstring(".",name) - 1), name =
     substring(1,end_pos,name)
     WHILE (end_pos >= 1)
       letter = substring(end_pos,1,name), seq_cnt = (seq_cnt+ 1), num_flag = isnumeric(letter)
       IF (num_flag=0)
        IF (letter="_")
         seq_beg_pos = (end_pos+ 1), ts_end_pos = (end_pos - 1), end_pos = 0,
         seq_cnt = (seq_cnt - 1)
        ENDIF
       ENDIF
       end_pos = (end_pos - 1)
     ENDWHILE
     IF (ts_end_pos > 0
      AND seq_beg_pos > 0
      AND seq_cnt > 0)
      ts_name = substring(1,ts_end_pos,name), seq = cnvtint(substring(seq_beg_pos,seq_cnt,name))
      IF (ts_name=gds_tablespace_name)
       IF (max_seq < seq)
        max_seq = seq
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   RETURN(max_seq)
 END ;Subroutine
#end_program
END GO
