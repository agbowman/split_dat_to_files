CREATE PROGRAM dm_get_sizing_data:dba
 SET rep_seq =  $1
 SET bsize = fs_proc->db[1].block_size
 SET def_tbl_ext = (2.0 * bsize)
 SET def_ind_ext = (2.0 * bsize)
 IF ((fs_proc->inhouse_ind=1))
  SET def_tbl_ext = (128.0 * 1024.0)
  SET def_ind_ext = (128.0 * 1024.0)
 ENDIF
 IF (rep_seq > 0)
  IF ((tgtdb->tbl_cnt > 0))
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
     space_objects so
    PLAN (d)
     JOIN (so
     WHERE so.report_seq=rep_seq
      AND (so.instance_cd=fs_proc->space_summary[1].instance_cd)
      AND so.owner="V500"
      AND (so.segment_name=tgtdb->tbl[d.seq].tbl_name)
      AND so.segment_type="TABLE")
    DETAIL
     tgtdb->tbl[d.seq].row_cnt = so.row_count, tgtdb->tbl[d.seq].total_space = so.total_space, tgtdb
     ->tbl[d.seq].free_space = so.free_space
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   IF ((tgtdb->tbl[t_tbl].new_ind=1))
    SET tgtdb->tbl[t_tbl].init_ext = def_tbl_ext
    SET tgtdb->tbl[t_tbl].next_ext = def_tbl_ext
   ENDIF
 ENDFOR
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
     IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=1))
      SELECT INTO "nl:"
       d.seq
       FROM (dummyt d  WITH seq = value(tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt)),
        (dummyt d2  WITH seq = value(tgtdb->tbl[t_tbl].tbl_col_cnt))
       PLAN (d)
        JOIN (d2
        WHERE (tgtdb->tbl[t_tbl].ind[t_ind].ind_col[d.seq].col_name=tgtdb->tbl[t_tbl].tbl_col[d2.seq]
        .col_name))
       HEAD REPORT
        ind_len = 0
       DETAIL
        ind_len = (ind_len+ tgtdb->tbl[t_tbl].tbl_col[d2.seq].data_length)
       FOOT REPORT
        tgtdb->tbl[t_tbl].ind[t_ind].init_ext = (ceil((((tgtdb->tbl[t_tbl].row_cnt * ind_len)/ 10)/
         bsize)) * bsize)
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].init_ext < def_ind_ext))
         tgtdb->tbl[t_tbl].ind[t_ind].init_ext = def_ind_ext
        ENDIF
        tgtdb->tbl[t_tbl].ind[t_ind].next_ext = (ceil((((tgtdb->tbl[t_tbl].row_cnt * ind_len)/ 10)/
         bsize)) * bsize)
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].next_ext < def_ind_ext))
         tgtdb->tbl[t_tbl].ind[t_ind].next_ext = def_ind_ext
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
#end_program
END GO
