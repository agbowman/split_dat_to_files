CREATE PROGRAM dm_rdm_upd_pool_logical_domain:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_upd_pool_logical_domain..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD logicaldomainid
 RECORD logicaldomainid(
   1 qual[*]
     2 prsnl_group_id = f8
     2 logical_domain_id = f8
 )
 FREE RECORD inactivatemembers
 RECORD inactivatemembers(
   1 cnt = i4
   1 qual[*]
     2 prsnl_group_reltn_id = f8
 )
 FREE RECORD newteamlead
 RECORD newteamlead(
   1 qual[*]
     2 prsnl_group_id = f8
     2 person_id = f8
     2 prsnl_group_reltn_id = f8
 )
 FREE RECORD xdomain_pools
 RECORD xdomain_pools(
   1 qual[*]
     2 prsnl_group_id = f8
     2 primary_logical_domain_id = f8
     2 primary_prsnl_id = f8
     2 domains[*]
       3 logical_domain_id = f8
       3 members[*]
         4 prsnl_id = f8
 )
 SELECT INTO "nl:"
  FROM prsnl_group_pool pgp,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p
  PLAN (pgp
   WHERE pgp.active_ind=1
    AND pgp.prsnl_group_pool_id != 0)
   JOIN (pg
   WHERE pgp.prsnl_group_id=pg.prsnl_group_id
    AND pg.prsnl_group_id != 0
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.prsnl_group_reltn_id != 0
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.person_id != 0
    AND ((p.active_ind=0) OR (((p.end_effective_dt_tm < sysdate) OR ((p.active_status_cd !=
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.code_set=48
     AND c.cdf_meaning="ACTIVE"
    WITH maxrec = 1)))) )) )
  ORDER BY pgr.person_id, pg.prsnl_group_id
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (mod(cnt,10)=0)
    stat = alterlist(inactivatemembers->qual,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), inactivatemembers->qual[cnt].prsnl_group_reltn_id = pgr.prsnl_group_reltn_id
  FOOT REPORT
   inactivatemembers->cnt = cnt, stat = alterlist(inactivatemembers->qual,cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to Retrieve Pool Membership:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (size(inactivatemembers->qual,5) > 0)
  CALL echo(concat("commiting update ... this may take a few minutes."))
  UPDATE  FROM (dummyt d  WITH seq = size(inactivatemembers->qual,5)),
    prsnl_group_reltn p
   SET p.active_ind = 0, p.active_status_cd =
    (SELECT
     c.code_value
     FROM code_value c
     WHERE c.code_set=48
      AND c.cdf_meaning="INACTIVE"
     WITH maxrec = 1), p.primary_ind = 0,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo
    ->updt_id,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_group_reltn_id=inactivatemembers->qual[d.seq].prsnl_group_reltn_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to Inactivate Members from Pool: ",errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group_pool pgp,
   prsnl_group pg,
   prsnl_group_reltn pgr1,
   prsnl p
  WHERE pgp.active_ind=1
   AND pgp.prsnl_group_id=pg.prsnl_group_id
   AND pg.prsnl_group_id != 0
   AND pgr1.prsnl_group_id=pg.prsnl_group_id
   AND pgr1.active_ind=1
   AND p.person_id=pgr1.person_id
   AND  NOT (p.position_cd IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=88
    AND c.cdf_meaning="DBA"
   WITH maxrec = 1)))
   AND  NOT ( EXISTS (
  (SELECT
   pgr.prsnl_group_id
   FROM prsnl_group_reltn pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1
    AND pgr.primary_ind=1)))
  ORDER BY pg.prsnl_group_id, pgr1.beg_effective_dt_tm
  HEAD REPORT
   cnt = 0
  HEAD pg.prsnl_group_id
   IF (mod(cnt,10)=0)
    stat = alterlist(newteamlead->qual,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), newteamlead->qual[cnt].prsnl_group_id = pgr1.prsnl_group_id, newteamlead->qual[cnt
   ].person_id = pgr1.person_id,
   newteamlead->qual[cnt].prsnl_group_reltn_id = pgr1.prsnl_group_reltn_id
  FOOT REPORT
   stat = alterlist(newteamlead->qual,cnt)
  WITH nocounter, format = pcformat
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve the new leader: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (size(newteamlead->qual,5) > 0)
  UPDATE  FROM (dummyt d  WITH seq = size(newteamlead->qual,5)),
    prsnl_group_reltn p
   SET p.primary_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_group_reltn_id=newteamlead->qual[d.seq].prsnl_group_reltn_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update the new leader: ",errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SET stat = initrec(newteamlead)
 SELECT INTO "nl:"
  FROM prsnl_group_pool pgp,
   prsnl_group pg,
   prsnl_group_reltn pgr1,
   prsnl p
  WHERE pgp.active_ind=1
   AND pgp.prsnl_group_id=pg.prsnl_group_id
   AND pg.prsnl_group_id != 0
   AND pgr1.prsnl_group_id=pg.prsnl_group_id
   AND pgr1.active_ind=1
   AND p.person_id=pgr1.person_id
   AND  NOT ( EXISTS (
  (SELECT
   pgr.prsnl_group_id
   FROM prsnl_group_reltn pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1
    AND pgr.primary_ind=1)))
  ORDER BY pg.prsnl_group_id, pgr1.beg_effective_dt_tm
  HEAD REPORT
   cnt = 0
  HEAD pg.prsnl_group_id
   IF (mod(cnt,10)=0)
    stat = alterlist(newteamlead->qual,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), newteamlead->qual[cnt].prsnl_group_id = pgr1.prsnl_group_id, newteamlead->qual[cnt
   ].person_id = pgr1.person_id,
   newteamlead->qual[cnt].prsnl_group_reltn_id = pgr1.prsnl_group_reltn_id
  FOOT REPORT
   stat = alterlist(newteamlead->qual,cnt)
  WITH nocounter, format = pcformat
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve the oldest active personnel: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (size(newteamlead->qual,5) > 0)
  UPDATE  FROM (dummyt d  WITH seq = size(newteamlead->qual,5)),
    prsnl_group_reltn p
   SET p.primary_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_group_reltn_id=newteamlead->qual[d.seq].prsnl_group_reltn_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update oldest active personnel in the pool: ",errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group_pool pgp,
   prsnl_group_reltn pgr,
   prsnl p
  PLAN (pgp
   WHERE pgp.prsnl_group_pool_id != 0
    AND pgp.active_ind=1)
   JOIN (pgr
   WHERE pgp.prsnl_group_id=pgr.prsnl_group_id
    AND pgr.active_ind=1
    AND pgr.primary_ind=1)
   JOIN (p
   WHERE pgr.person_id=p.person_id
    AND p.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (mod(cnt,10)=0)
    stat = alterlist(logicaldomainid->qual,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), logicaldomainid->qual[cnt].prsnl_group_id = pgr.prsnl_group_id, logicaldomainid->
   qual[cnt].logical_domain_id = p.logical_domain_id
  FOOT REPORT
   stat = alterlist(logicaldomainid->qual,cnt)
  WITH nocounter, format = pcformat, orahintcbo("LEADING(PGP PGR P)")
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve logical_domain_id from prsnl table: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = size(logicaldomainid->qual,5)),
   prsnl_group_pool pgp1
  SET pgp1.logical_domain_id = logicaldomainid->qual[d.seq].logical_domain_id, pgp1.updt_cnt = (pgp1
   .updt_cnt+ 1), pgp1.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pgp1.updt_id = reqinfo->updt_id, pgp1.updt_applctx = reqinfo->updt_applctx, pgp1.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (pgp1
   WHERE (pgp1.prsnl_group_id=logicaldomainid->qual[d.seq].prsnl_group_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PRSNL_GROUP_POOL: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 FREE RECORD logicaldomainid
 FREE RECORD inactivatemembers
 FREE RECORD newteamlead
 FREE RECORD xdomain_pools
END GO
