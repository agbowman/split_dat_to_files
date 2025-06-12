CREATE PROGRAM dm_get_target_tspace:dba
 IF ((tgtdb->tbl_cnt > 0))
  SET tgtdb->tspace_cnt = 0
  SET stat = alterlist(tgtdb->tspace,0)
  SET max_ind_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (d)
   ORDER BY tgtdb->tbl[d.seq].tspace_name
   HEAD REPORT
    fnd = 0
   DETAIL
    max_ind_cnt = greatest(tgtdb->tbl[d.seq].ind_cnt,max_ind_cnt), fnd = 0
    FOR (ti = 1 TO tgtdb->tspace_cnt)
      IF ((tgtdb->tspace[ti].tspace_name=tgtdb->tbl[d.seq].tspace_name))
       fnd = ti, ti = tgtdb->tspace_cnt
      ENDIF
    ENDFOR
    IF (fnd=0)
     tgtdb->tspace_cnt = (tgtdb->tspace_cnt+ 1), stat = alterlist(tgtdb->tspace,tgtdb->tspace_cnt),
     fnd = tgtdb->tspace_cnt,
     tgtdb->tspace[fnd].tspace_name = tgtdb->tbl[d.seq].tspace_name, tgtdb->tspace[fnd].
     initial_extent = (16.0 * 1024.0), tgtdb->tspace[fnd].next_extent = (16.0 * 1024.0),
     tgtdb->tspace[fnd].pct_increase = 0, tgtdb->tspace[fnd].weighting = 0, tgtdb->tspace[fnd].
     new_ind = 0,
     tgtdb->tspace[fnd].cur_idx = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tgtdb->tbl_cnt)),
    (dummyt di  WITH seq = value(max_ind_cnt))
   PLAN (d)
    JOIN (di
    WHERE (di.seq <= tgtdb->tbl[d.seq].ind_cnt))
   ORDER BY tgtdb->tbl[d.seq].ind[di.seq].tspace_name
   HEAD REPORT
    fnd = 0
   DETAIL
    fnd = 0
    FOR (ti = 1 TO tgtdb->tspace_cnt)
      IF ((tgtdb->tspace[ti].tspace_name=tgtdb->tbl[d.seq].ind[di.seq].tspace_name))
       fnd = ti, ti = tgtdb->tspace_cnt
      ENDIF
    ENDFOR
    IF (fnd=0)
     tgtdb->tspace_cnt = (tgtdb->tspace_cnt+ 1), stat = alterlist(tgtdb->tspace,tgtdb->tspace_cnt),
     fnd = tgtdb->tspace_cnt,
     tgtdb->tspace[fnd].tspace_name = tgtdb->tbl[d.seq].ind[di.seq].tspace_name, tgtdb->tspace[fnd].
     initial_extent = (16.0 * 1024.0), tgtdb->tspace[fnd].next_extent = (16.0 * 1024.0),
     tgtdb->tspace[fnd].pct_increase = 0, tgtdb->tspace[fnd].weighting = 0
    ENDIF
   WITH nocounter
  ;end select
  IF ((fs_proc->ocd_number=0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtdb->tspace_cnt)),
     dm_tablespace dt
    PLAN (d)
     JOIN (dt
     WHERE (dt.tablespace_name=tgtdb->tspace[d.seq].tspace_name))
    DETAIL
     tgtdb->tspace[d.seq].initial_extent = dt.initial_extent, tgtdb->tspace[d.seq].next_extent = dt
     .next_extent, tgtdb->tspace[d.seq].pct_increase = dt.pctincrease,
     tgtdb->tspace[d.seq].weighting = dt.weighting
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
