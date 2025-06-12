CREATE PROGRAM dm_env_roll_segs_ship:dba
 SET ders_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   ders_inhouse = 1
  WITH nocounter
 ;end select
 IF (ders_inhouse)
  GO TO exit_script
 ENDIF
 DECLARE ders_cnt = i4
 SET ders_cnt = size(requestin->list_0,5)
 SET ders_u_id = 222
 SET ders_u_task = 333
 IF (ders_cnt > 0)
  INSERT  FROM dm_env_roll_segs_ship d,
    (dummyt t  WITH seq = value(ders_cnt))
   SET d.environment_name = requestin->list_0[t.seq].environment_name, d.rollback_seg_name =
    requestin->list_0[t.seq].rollback_seg_name, d.tablespace_name = requestin->list_0[t.seq].
    tablespace_name,
    d.disk_name = requestin->list_0[t.seq].disk_name, d.initial_extent = cnvtreal(requestin->list_0[t
     .seq].initial_extent), d.next_extent = cnvtreal(requestin->list_0[t.seq].next_extent),
    d.min_extents = cnvtint(requestin->list_0[t.seq].min_extents), d.max_extents = cnvtint(requestin
     ->list_0[t.seq].max_extents), d.optimal = cnvtint(requestin->list_0[t.seq].optimal),
    d.updt_applctx = cnvtint(requestin->list_0[t.seq].updt_applctx), d.updt_dt_tm = cnvtdatetime(
     curdate,0), d.updt_cnt = cnvtint(requestin->list_0[t.seq].updt_cnt),
    d.updt_id = ders_u_id, d.updt_task = ders_u_task
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
