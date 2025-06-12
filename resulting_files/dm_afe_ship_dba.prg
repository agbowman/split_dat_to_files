CREATE PROGRAM dm_afe_ship:dba
 SET das_inhouse = 0
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="INHOUSE DOMAIN"
  DETAIL
   das_inhouse = 1
  WITH nocounter
 ;end select
 IF (das_inhouse)
  GO TO exit_script
 ENDIF
 SET das_cnt = 0
 SET das_cnt = size(requestin->list_0,5)
 SET das_i_mode = "222"
 SET das_c_ind = "333"
 IF (das_cnt > 0)
  INSERT  FROM dm_afe_ship d,
    (dummyt t  WITH seq = value(das_cnt))
   SET d.alpha_feature_nbr = cnvtint(requestin->list_0[t.seq].alpha_feature_nbr), d.environment_name
     = requestin->list_0[t.seq].environment_name, d.start_dt_tm = cnvtdatetime(curdate,0),
    d.end_dt_tm = cnvtdatetime(curdate,0), d.status = requestin->list_0[t.seq].status, d.inst_mode =
    das_i_mode,
    d.calling_script = requestin->list_0[t.seq].calling_script, d.curr_migration_ind = das_c_ind
   PLAN (t
    WHERE t.seq > 0)
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
#exit_script
END GO
