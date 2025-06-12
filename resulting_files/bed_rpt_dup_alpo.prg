CREATE PROGRAM bed_rpt_dup_alpo
 FREE SET poolrec
 RECORD pool(
   1 pools[*]
     2 pool_cd = f8
     2 pool_disp = vc
     2 org_id = f8
     2 org_disp = vc
     2 type_cd = f8
 )
 DECLARE fin_cd = f8
 DECLARE mrn_cd = f8
 DECLARE cnt = i4
 SET mrn_cd = 0.0
 SET fin_cd = 0.0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4
    AND cv.cdf_meaning="MRN"
    AND cv.active_ind=1)
  DETAIL
   mrn_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=319
    AND cv.cdf_meaning="FIN NBR"
    AND cv.active_ind=1)
  DETAIL
   fin_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (((mrn_cd=0.0) OR (fin_cd=0.0)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM org_alias_pool_reltn oapr,
   org_alias_pool_reltn oapr2,
   organization o,
   code_value c
  PLAN (oapr
   WHERE oapr.alias_entity_alias_type_cd=fin_cd
    AND oapr.active_ind=1)
   JOIN (oapr2
   WHERE oapr2.alias_pool_cd=oapr.alias_pool_cd
    AND oapr2.organization_id=oapr.organization_id
    AND oapr2.alias_entity_name="PERSON_ALIAS"
    AND oapr2.alias_entity_alias_type_cd != fin_cd
    AND oapr2.alias_entity_alias_type_cd != mrn_cd
    AND oapr2.active_ind=1)
   JOIN (o
   WHERE o.organization_id=oapr2.organization_id)
   JOIN (c
   WHERE c.code_value=oapr2.alias_pool_cd)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pool->pools,cnt), pool->pools[cnt].pool_cd = oapr2.alias_pool_cd,
   pool->pools[cnt].pool_disp = c.display, pool->pools[cnt].org_id = oapr2.organization_id, pool->
   pools[cnt].type_cd = oapr2.alias_entity_alias_type_cd,
   pool->pools[cnt].org_disp = o.org_name
  WITH nocounter
 ;end select
 SELECT
  org = pool->pools[d.seq].org_disp
  FROM (dummyt d  WITH seq = value(size(pool->pools,5)))
  ORDER BY org
  HEAD REPORT
   col 0, "Organization", col 40,
   "Alias Pool", col 70, "Type"
  DETAIL
   row + 1, pool->pools[d.seq].org_disp, col 40,
   pool->pools[d.seq].pool_disp, col 70, pool->pools[d.seq].type_cd
  WITH nocounter
 ;end select
#exit_script
END GO
