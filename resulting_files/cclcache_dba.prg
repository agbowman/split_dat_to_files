CREATE PROGRAM cclcache:dba
 SELECT INTO "nl:"
  a.format_mask, a.alias_pool_cd
  FROM alias_pool a
  WHERE a.format_mask != " "
   AND a.active_ind != 0
  ORDER BY a.alias_pool_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1,
   CALL cclcache_alias_put(cnt,a.format_mask,a.alias_pool_cd)
  WITH nocounter, maxrow = 1, noformfeed
 ;end select
END GO
