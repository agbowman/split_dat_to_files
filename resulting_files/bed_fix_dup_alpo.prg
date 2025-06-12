CREATE PROGRAM bed_fix_dup_alpo
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
 DECLARE inactive_cd = f8
 DECLARE cnt = i4
 SET mrn_cd = 0.0
 SET fin_cd = 0.0
 SET inactive_cd = 0.0
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
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
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
    AND oapr2.alias_entity_alias_type_cd != mrn_cd)
   JOIN (o
   WHERE o.organization_id=oapr2.organization_id)
   JOIN (c
   WHERE c.code_value=oapr2.alias_pool_cd)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(pool->pools,cnt), pool->pools[cnt].pool_cd = oapr.alias_pool_cd,
   pool->pools[cnt].pool_disp = c.display, pool->pools[cnt].org_id = oapr.organization_id, pool->
   pools[cnt].type_cd = oapr.alias_entity_alias_type_cd,
   pool->pools[cnt].org_disp = o.org_name
  WITH nocounter
 ;end select
 CALL echorecord(pool)
 FOR (ii = 1 TO cnt)
   UPDATE  FROM org_alias_pool_reltn oapr
    SET oapr.active_ind = 0, oapr.active_status_cd = inactive_cd, oapr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     oapr.updt_cnt = (oapr.updt_cnt+ 1), oapr.updt_task = 3202004, oapr.updt_id = 3202004,
     oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (oapr.organization_id=pool->pools[ii].org_id)
     AND (oapr.alias_pool_cd=pool->pools[ii].pool_cd)
     AND (oapr.alias_entity_alias_type_cd=pool->pools[ii].type_cd)
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
#exit_script
END GO
