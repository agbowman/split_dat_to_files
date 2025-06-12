CREATE PROGRAM dm_get_current_tspace:dba
 SET curdb->tspace_cnt = 0
 SET stat = alterlist(curdb->tspace,0)
 SELECT INTO "nl:"
  FROM user_tablespaces ut
  WHERE ut.status != "INVALID"
  ORDER BY ut.tablespace_name
  HEAD REPORT
   fnd = 0
  DETAIL
   curdb->tspace_cnt = (curdb->tspace_cnt+ 1), stat = alterlist(curdb->tspace,curdb->tspace_cnt), fnd
    = curdb->tspace_cnt,
   curdb->tspace[fnd].tspace_name = ut.tablespace_name, curdb->tspace[fnd].initial_extent = ut
   .initial_extent, curdb->tspace[fnd].next_extent = ut.next_extent,
   curdb->tspace[fnd].pct_increase = ut.pct_increase, curdb->tspace[fnd].min_extents = ut.min_extents,
   curdb->tspace[fnd].max_extents = ut.max_extents,
   curdb->tspace[fnd].status = ut.status, curdb->tspace[fnd].contents = ut.contents
  WITH nocounter
 ;end select
END GO
