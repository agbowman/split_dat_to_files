CREATE PROGRAM dm_check_tspace:dba
 SET dm_env_name = fs_proc->env[1].name
 SET envid = fs_proc->env[1].id
 SET system = cnvtupper(cursys)
 FREE RECORD tsp
 RECORD tsp(
   1 str = vc
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
  ORDER BY tbl_name, ind_name
  HEAD ind_name
   col_sum = 0.0, ind_tot = 0.0
  DETAIL
   FOR (ci = 1 TO tgtdb->tbl[dt.seq].tbl_col_cnt)
     IF ((tgtdb->tbl[dt.seq].tbl_col[ci].col_name=tgtdb->tbl[dt.seq].ind[di.seq].ind_col[dc.seq].
     col_name))
      col_sum = (col_sum+ tgtdb->tbl[dt.seq].tbl_col[ci].data_length), ci = tgtdb->tbl[dt.seq].
      tbl_col_cnt
     ENDIF
   ENDFOR
  FOOT  ind_name
   ind_tot = (col_sum * tgtdb->tbl[dt.seq].row_cnt)
   IF ((ind_tot < (min_ind_size_factor * fs_proc->db[1].block_size)))
    tgtdb->tbl[dt.seq].ind[di.seq].size = (min_ind_size_factor * fs_proc->db[1].block_size)
   ELSE
    tgtdb->tbl[dt.seq].ind[di.seq].size = ind_tot
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
  ORDER BY tbl_name
  HEAD tbl_name
   col_sum = 0.0, col_tot = 0.0, used_space = 0.0
  DETAIL
   col_sum = (col_sum+ tgtdb->tbl[dt.seq].tbl_col[dc.seq].data_length)
  FOOT  tbl_name
   col_tot = (col_sum * tgtdb->tbl[dt.seq].row_cnt)
   IF ((col_tot < (min_tbl_size_factor * fs_proc->db[1].block_size)))
    tgtdb->tbl[dt.seq].size = (min_ind_size_factor * fs_proc->db[1].block_size)
   ELSE
    tgtdb->tbl[dt.seq].size = col_tot
   ENDIF
  WITH nocounter
 ;end select
 FREE SET newlist
 RECORD newlist(
   1 qual[*]
     2 new_tb_name = vc
     2 total_size = f8
     2 partitioned_bytes = f8
     2 file_count = i4
   1 count = i4
 )
 SET newlist->count = 0
 SET stat = alterlist(newlist->qual,10)
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
     2 files[*]
       3 file_id = f8
       3 free_bytes = f8
   1 count = i4
 )
 SET existlist->count = 0
 SET stat = alterlist(existlist->qual,10)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tgtdb->tspace_cnt))
  PLAN (d
   WHERE (tgtdb->tspace[d.seq].new_ind=1))
  DETAIL
   newlist->count = (newlist->count+ 1), stat = alterlist(newlist->qual,newlist->count), newlist->
   qual[newlist->count].new_tb_name = tgtdb->tspace[d.seq].tspace_name,
   newlist->qual[newlist->count].total_size = 0.0, newlist->qual[newlist->count].partitioned_bytes =
   0.0, newlist->qual[newlist->count].file_count = 0
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
   existlist->qual[existlist->count].file_count = 0, stat = alterlist(existlist->qual[existlist->
    count].files,0)
   FOR (c_tsp = 1 TO curdb->tspace_cnt)
     IF ((tgtdb->tspace[d.seq].tspace_name=curdb->tspace[c_tsp].tspace_name))
      existlist->qual[existlist->count].init_ext = curdb->tspace[c_tsp].initial_extent, existlist->
      qual[existlist->count].next_ext = curdb->tspace[c_tsp].next_extent, c_tsp = curdb->tspace_cnt
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET cnt1 = newlist->count
 SET ecnt1 = existlist->count
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
   temp_sum = 0.0, tsp->str = newlist->qual[ts.seq].new_tb_name
  DETAIL
   IF ((tgtdb->tbl[dt.seq].new_ind=1))
    obj_in_tspace = (obj_in_tspace+ 1), new_tab_size = (new_tab_size+ tgtdb->tbl[dt.seq].init_ext)
   ELSEIF ((tgtdb->tbl[dt.seq].size > 0))
    tab_size = (tab_size+ tgtdb->tbl[dt.seq].size)
   ENDIF
  FOOT  ts.seq
   temp_sum = (tab_size+ new_tab_size), newlist->qual[ts.seq].partitioned_bytes = (((round((temp_sum
    / (partition_size * mbyte)),0)+ 1) * partition_size) * mbyte)
  WITH nocounter
 ;end select
 SET str_cnt = (cnt1+ 1)
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
   temp_sum = 0.0, tsp->str = newlist->qual[ts.seq].new_tb_name
  DETAIL
   IF ((tgtdb->tbl[dt.seq].new_ind=1))
    obj_in_tspace = (obj_in_tspace+ 1), new_ind_size = (new_ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].
    init_ext)
   ELSEIF ((tgtdb->tbl[dt.seq].ind[di.seq].size > 0))
    ind_size = (ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].size)
   ENDIF
  FOOT  ts.seq
   temp_sum = (ind_size+ new_ind_size), newlist->qual[ts.seq].partitioned_bytes = (newlist->qual[ts
   .seq].partitioned_bytes+ (((round((temp_sum/ (partition_size * mbyte)),0)+ 1) * partition_size) *
   mbyte))
  WITH nocounter
 ;end select
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
   obj_in_tspace = 0, new_tab_size = 0.0, init_ext_size = 0.0,
   tab_size = 0.0, temp_sum = 0.0, tsp->str = existlist->qual[ts.seq].tb_name
  DETAIL
   IF ((tgtdb->tbl[dt.seq].new_ind=1))
    obj_in_tspace = (obj_in_tspace+ 1), new_tab_size = (new_tab_size+ tgtdb->tbl[dt.seq].init_ext),
    init_ext_size = (init_ext_size+ tgtdb->tbl[dt.seq].init_ext)
   ELSEIF ((tgtdb->tbl[dt.seq].size > 0))
    tab_size = (tab_size+ tgtdb->tbl[dt.seq].size)
   ENDIF
  FOOT  ts.seq
   temp_sum = (tab_size+ new_tab_size), existlist->qual[ts.seq].calc_size = temp_sum, existlist->
   qual[ts.seq].new_obj_size = (existlist->qual[ts.seq].new_obj_size+ new_tab_size),
   existlist->qual[ts.seq].init_ext_size = (existlist->qual[ts.seq].init_ext_size+ init_ext_size)
  WITH nocounter
 ;end select
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
   obj_in_tspace = 0, new_ind_size = 0.0, init_ext_size = 0.0,
   ind_size = 0.0, temp_sum = 0.0, tsp->str = existlist->qual[ts.seq].tb_name
  DETAIL
   init_ext_size = (init_ext_size+ tgtdb->tbl[dt.seq].ind[di.seq].init_ext)
   IF ((tgtdb->tbl[dt.seq].new_ind=1))
    obj_in_tspace = (obj_in_tspace+ 1), new_ind_size = (new_ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].
    init_ext)
   ELSEIF ((tgtdb->tbl[dt.seq].ind[di.seq].size > 0))
    ind_size = (ind_size+ tgtdb->tbl[dt.seq].ind[di.seq].size)
   ENDIF
  FOOT  ts.seq
   temp_sum = (ind_size+ new_ind_size), existlist->qual[ts.seq].calc_size = (existlist->qual[ts.seq].
   calc_size+ temp_sum), existlist->qual[ts.seq].new_obj_size = (existlist->qual[ts.seq].new_obj_size
   + new_ind_size),
   existlist->qual[ts.seq].init_ext_size = (existlist->qual[ts.seq].init_ext_size+ init_ext_size)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.tablespace_name, total_space = sum(d.bytes)
  FROM (dummyt ts  WITH seq = value(existlist->count)),
   dba_data_files d
  PLAN (ts)
   JOIN (d
   WHERE (d.tablespace_name=existlist->qual[ts.seq].tb_name))
  GROUP BY d.tablespace_name
  DETAIL
   existlist->qual[ts.seq].total_space = total_space
  WITH nocounter
 ;end select
 IF ((fs_proc->inhouse_ind=0))
  SELECT INTO "nl:"
   FROM dm_min_tspace_size a,
    dm_env_functions b,
    (dummyt ts  WITH seq = value(existlist->count))
   PLAN (ts)
    JOIN (a
    WHERE (a.tablespace_name=existlist->qual[ts.seq].tb_name))
    JOIN (b
    WHERE b.function_id=a.function_id
     AND (b.environment_id=fs_proc->env[1].id))
   DETAIL
    size_diff = 0.0
    IF ((existlist->qual[ts.seq].total_space < a.minimum_size))
     size_diff = (a.minimum_size - existlist->qual[ts.seq].total_space)
     IF ((existlist->qual[ts.seq].calc_size < size_diff))
      existlist->qual[ts.seq].calc_size = size_diff
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET max_file_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt ts  WITH seq = value(existlist->count)),
   dba_free_space d
  PLAN (ts)
   JOIN (d
   WHERE (d.tablespace_name=existlist->qual[ts.seq].tb_name))
  ORDER BY d.tablespace_name, d.bytes DESC
  HEAD d.tablespace_name
   existlist->qual[ts.seq].file_count = 0, stat = alterlist(existlist->qual[ts.seq].files,0), cnt = 0
  DETAIL
   existlist->qual[ts.seq].file_count = (existlist->qual[ts.seq].file_count+ 1), cnt = existlist->
   qual[ts.seq].file_count, stat = alterlist(existlist->qual[ts.seq].files,cnt),
   existlist->qual[ts.seq].files[cnt].file_id = d.file_id, existlist->qual[ts.seq].files[cnt].
   free_bytes = d.bytes, max_file_cnt = greatest(max_file_cnt,existlist->qual[ts.seq].file_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tbl_space = existlist->qual[ts.seq].tb_name, tbl_name = tgtdb->tbl[dt.seq].tbl_name, tbl_init_ext
   = tgtdb->tbl[dt.seq].init_ext
  FROM (dummyt dt  WITH seq = value(tgtdb->tbl_cnt)),
   (dummyt ts  WITH seq = value(existlist->count))
  PLAN (ts)
   JOIN (dt
   WHERE (tgtdb->tbl[dt.seq].tspace_name=existlist->qual[ts.seq].tb_name)
    AND (tgtdb->tbl[dt.seq].new_ind=1))
  ORDER BY ts.seq, tbl_init_ext
  DETAIL
   max_free_space = 0.0, max_free_ind = 0
   FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
     IF ((existlist->qual[ts.seq].files[fi].free_bytes > max_free_space)
      AND (existlist->qual[ts.seq].files[fi].free_bytes > tbl_init_ext))
      max_free_space = existlist->qual[ts.seq].files[fi].free_bytes, max_free_ind = fi
     ENDIF
   ENDFOR
   IF (max_free_ind > 0)
    existlist->qual[ts.seq].files[max_free_ind].free_bytes = (existlist->qual[ts.seq].files[
    max_free_ind].free_bytes - tbl_init_ext), existlist->qual[ts.seq].free_space = (existlist->qual[
    ts.seq].free_space+ tbl_init_ext)
   ENDIF
   tsp->str = existlist->qual[ts.seq].tb_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tbl_space = existlist->qual[ts.seq].tb_name, ind_name = tgtdb->tbl[dt.seq].tbl_name, ind_init_ext
   = tgtdb->tbl[dt.seq].ind[di.seq].init_ext
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
  ORDER BY ts.seq, ind_init_ext
  DETAIL
   max_free_space = 0.0, max_free_ind = 0
   FOR (fi = 1 TO existlist->qual[ts.seq].file_count)
     IF ((existlist->qual[ts.seq].files[fi].free_bytes > max_free_space)
      AND (existlist->qual[ts.seq].files[fi].free_bytes > ind_init_ext))
      max_free_space = existlist->qual[ts.seq].files[fi].free_bytes, max_free_ind = fi
     ENDIF
   ENDFOR
   IF (max_free_ind > 0)
    existlist->qual[ts.seq].files[max_free_ind].free_bytes = (existlist->qual[ts.seq].files[
    max_free_ind].free_bytes - ind_init_ext), existlist->qual[ts.seq].free_space = (existlist->qual[
    ts.seq].free_space+ ind_init_ext)
   ENDIF
   tsp->str = existlist->qual[ts.seq].tb_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tbl_space = existlist->qual[ts.seq].tb_name
  FROM (dummyt ts  WITH seq = value(existlist->count)),
   (dummyt df  WITH seq = value(max_file_cnt))
  PLAN (ts)
   JOIN (df
   WHERE (df.seq <= existlist->qual[ts.seq].file_count)
    AND (existlist->qual[ts.seq].files[df.seq].free_bytes > (min_free_blocks * fs_proc->db[1].
   block_size)))
  DETAIL
   existlist->qual[ts.seq].free_space = (existlist->qual[ts.seq].free_space+ existlist->qual[ts.seq].
   files[df.seq].free_bytes), existlist->qual[ts.seq].files[df.seq].free_bytes = 0, tsp->str =
   existlist->qual[ts.seq].tb_name
  WITH nocounter
 ;end select
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
    WHILE (total_size > 0)
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
    IF ((existlist->qual[a].free_space < existlist->qual[a].calc_size))
     SET diff = (existlist->qual[a].calc_size - existlist->qual[a].free_space)
     SET existlist->qual[a].partitioned_bytes = (((round((diff/ (partition_size * mbyte)),0)+ 1) *
     partition_size) * mbyte)
     SET db_count = 0
     SELECT INTO "nl:"
      a.file_name
      FROM dba_data_files a
      WHERE (a.tablespace_name=existlist->qual[a].tb_name)
      DETAIL
       db_count = (db_count+ 1)
      WITH nocounter
     ;end select
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
    SET diff = 0.0
    SET existlist->qual[a].partitioned_bytes = 0.0
    IF ((existlist->qual[a].free_space < existlist->qual[a].calc_size))
     SET diff = (existlist->qual[a].calc_size - existlist->qual[a].free_space)
     SET existlist->qual[a].partitioned_bytes = (((round((diff/ (partition_size * mbyte)),0)+ 1) *
     partition_size) * mbyte)
     SET row_count = 1
     SET total_size = existlist->qual[a].partitioned_bytes
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
       SET tspace_files->tname[tspace_files->fcount].tspace_name = existlist->qual[a].tb_name
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
       SET fname = build(cnvtlower(database_name),"_",format(cnvtstring((raw_size/ (1024.0 * 1024.0))
          ),"####;P0"),"_",format(cnvtstring(tspace_files->tname[tspace_files->fcount].size_seq),
         "###;P0"))
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
         def.tablespace_name = tspace_files->tname[tspace_files->fcount].tspace_name, def.file_name
          = tspace_files->tname[tspace_files->fcount].fname, def.tablespace_exist_ind = 1
        WITH nocounter
       ;end insert
     ENDWHILE
    ENDIF
  ENDFOR
 ENDIF
 COMMIT
#end_program
END GO
