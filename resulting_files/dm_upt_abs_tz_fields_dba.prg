CREATE PROGRAM dm_upt_abs_tz_fields:dba
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
 SET readme_data->message = "Readme Failure: starting dm_upt_abs_tz_fields.prg script"
 FREE RECORD tmppersontz
 RECORD tmppersontz(
   1 qual[*]
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 abs_birth_dt_tm = dq8
     2 birth_tz = i4
     2 max_reg_dt_tm = f8
     2 max_updt_dt_tm = f8
   1 qual_cnt = i2
 )
 IF (curcclrev < 8.1)
  SET readme_data->status = "S"
  SET readme_data->message = "AUTO-SUCCESS.  Readme should not run in less than 8.1 environment."
  GO TO end_program
 ENDIF
 DECLARE lstat = i4 WITH noconstant(0)
 DECLARE bstop = i2 WITH noconstant(false)
 DECLARE nstartindex = i2 WITH noconstant(0)
 DECLARE ntempsize = i2 WITH noconstant(0)
 DECLARE nloopcount = i2 WITH noconstant(0)
 DECLARE btimezoneempty = i2 WITH noconstant(true)
 DECLARE dmrncd = f8 WITH noconstant(0.0)
 DECLARE ndx = i2 WITH noconstant(0)
 DECLARE ndx2 = i2 WITH noconstant(0)
 DECLARE dprevmaxpersonid = f8 WITH noconstant(0.0)
 DECLARE errmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE nbatch_size = i2 WITH constant(80)
 DECLARE ncommit_batch_size = i2 WITH constant(1000)
 CALL echo("start time:")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET errcode = error(errmsg,1)
 SET btimezoneempty = 1
 SELECT INTO "nl:"
  FROM time_zone_r t
  WHERE t.parent_entity_id != 0
   AND t.parent_entity_name IN ("LOCATION", "ORGANIZATION")
   AND t.time_zone IS NOT null
  DETAIL
   btimezoneempty = 0
  WITH nocounter, maxqual(t,10)
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  DETAIL
   dmrncd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
  GO TO end_program
 ENDIF
 WHILE (bstop=false)
   CALL echo("*****Finding rows that need updates*****")
   SET lstat = alterlist(tmppersontz->qual,0)
   SET tmppersontz->qual_cnt = 0
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE p.person_id > dprevmaxpersonid
      AND p.birth_dt_tm != null
      AND ((p.abs_birth_dt_tm=null) OR (((curutc=1
      AND ((p.birth_tz=null) OR (p.birth_tz=0)) ) OR (curutc=0
      AND p.birth_tz != null
      AND p.birth_tz != 0)) )) )
    ORDER BY p.person_id
    HEAD REPORT
     nperscount = 0, lstat = alterlist(tmppersontz->qual,ncommit_batch_size)
    DETAIL
     nperscount = (nperscount+ 1), tmppersontz->qual[nperscount].person_id = p.person_id, tmppersontz
     ->qual[nperscount].birth_dt_tm = p.birth_dt_tm,
     tmppersontz->qual[nperscount].abs_birth_dt_tm = p.birth_dt_tm
     IF (curutc=1)
      tmppersontz->qual[nperscount].birth_tz = p.birth_tz
     ELSE
      tmppersontz->qual[nperscount].birth_tz = 0
     ENDIF
    FOOT REPORT
     lstat = alterlist(tmppersontz->qual,nperscount), tmppersontz->qual_cnt = nperscount
    WITH nocounter, maxqual(p,value(ncommit_batch_size))
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
    GO TO end_program
   ENDIF
   IF ((tmppersontz->qual_cnt > 0))
    IF (curutc=1)
     CALL echo("*****Getting time zone data*****")
     SET nstartindex = 1
     SET nloopcount = ceil((cnvtreal(tmppersontz->qual_cnt)/ nbatch_size))
     SET ntempsize = (nloopcount * nbatch_size)
     SET lstat = alterlist(tmppersontz->qual,ntempsize)
     FOR (x = (tmppersontz->qual_cnt+ 1) TO ntempsize)
       SET tmppersontz->qual[x].person_id = tmppersontz->qual[tmppersontz->qual_cnt].person_id
     ENDFOR
     DECLARE tmptimezone = i4 WITH private
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(nloopcount)),
       contributor_system cs,
       person p
      PLAN (d
       WHERE initarray(nstartindex,evaluate(d.seq,1,1,(nstartindex+ nbatch_size))))
       JOIN (p
       WHERE expand(x,nstartindex,((nstartindex+ nbatch_size) - 1),p.person_id,tmppersontz->qual[x].
        person_id)
        AND ((p.contributor_system_cd+ 0) > 0))
       JOIN (cs
       WHERE cs.contributor_system_cd=p.contributor_system_cd)
      DETAIL
       ndx = locateval(ndx2,1,tmppersontz->qual_cnt,p.person_id,tmppersontz->qual[ndx2].person_id)
       IF (ndx > 0)
        tmppersontz->qual[ndx].birth_tz = datetimezonebyname(trim(cs.time_zone,3))
        IF ((tmppersontz->qual[ndx].birth_tz > 0))
         tmppersontz->qual[ndx].abs_birth_dt_tm = datetimezone(tmppersontz->qual[ndx].birth_dt_tm,
          tmppersontz->qual[ndx].birth_tz)
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
      GO TO end_program
     ENDIF
     IF (btimezoneempty=false
      AND locateval(ndx2,1,tmppersontz->qual_cnt,0,tmppersontz->qual[ndx2].birth_tz) > 0)
      SET nstartindex = 1
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(nloopcount)),
        encounter e
       PLAN (d
        WHERE initarray(nstartindex,evaluate(d.seq,1,1,(nstartindex+ nbatch_size))))
        JOIN (e
        WHERE expand(x,nstartindex,((nstartindex+ nbatch_size) - 1),e.person_id,tmppersontz->qual[x].
         person_id,
         0,tmppersontz->qual[x].birth_tz))
       ORDER BY e.person_id, e.reg_dt_tm DESC
       HEAD e.person_id
        ndx = locateval(ndx2,1,tmppersontz->qual_cnt,e.person_id,tmppersontz->qual[ndx2].person_id)
        IF (ndx > 0)
         tmppersontz->qual[ndx].max_reg_dt_tm = e.reg_dt_tm
        ENDIF
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
       GO TO end_program
      ENDIF
      SET nstartindex = 1
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(nloopcount)),
        encounter e,
        time_zone_r tz
       PLAN (d
        WHERE initarray(nstartindex,evaluate(d.seq,1,1,(nstartindex+ nbatch_size))))
        JOIN (e
        WHERE expand(x,nstartindex,((nstartindex+ nbatch_size) - 1),e.person_id,tmppersontz->qual[x].
         person_id,
         0,tmppersontz->qual[x].birth_tz,cnvtdatetime(e.reg_dt_tm),tmppersontz->qual[x].max_reg_dt_tm
         )
         AND ((e.loc_facility_cd+ 0) > 0))
        JOIN (tz
        WHERE (tz.parent_entity_id=(e.loc_facility_cd+ 0))
         AND tz.parent_entity_name="LOCATION")
       DETAIL
        ndx = locateval(ndx2,1,tmppersontz->qual_cnt,e.person_id,tmppersontz->qual[ndx2].person_id)
        IF (ndx > 0)
         tmppersontz->qual[ndx].birth_tz = datetimezonebyname(trim(tz.time_zone,3))
         IF ((tmppersontz->qual[ndx].birth_tz > 0))
          tmppersontz->qual[ndx].abs_birth_dt_tm = datetimezone(tmppersontz->qual[ndx].birth_dt_tm,
           tmppersontz->qual[ndx].birth_tz)
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
       GO TO end_program
      ENDIF
      IF (locateval(ndx2,1,tmppersontz->qual_cnt,0,tmppersontz->qual[ndx2].birth_tz) > 0)
       SET nstartindex = 1
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(nloopcount)),
         person_alias pa
        PLAN (d
         WHERE initarray(nstartindex,evaluate(d.seq,1,1,(nstartindex+ nbatch_size))))
         JOIN (pa
         WHERE expand(x,nstartindex,((nstartindex+ nbatch_size) - 1),pa.person_id,tmppersontz->qual[x
          ].person_id,
          0,tmppersontz->qual[x].birth_tz)
          AND pa.person_alias_type_cd=dmrncd)
        ORDER BY pa.person_id, pa.updt_dt_tm DESC
        HEAD pa.person_id
         bfound = false
        DETAIL
         IF (bfound=false)
          ndx = locateval(ndx2,1,tmppersontz->qual_cnt,pa.person_id,tmppersontz->qual[ndx2].person_id
           )
          IF (ndx > 0)
           tmppersontz->qual[ndx].max_updt_dt_tm = pa.updt_dt_tm
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
        GO TO end_program
       ENDIF
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(nloopcount)),
         time_zone_r tz,
         org_alias_pool_reltn oap,
         person_alias pa
        PLAN (d
         WHERE initarray(nstartindex,evaluate(d.seq,1,1,(nstartindex+ nbatch_size))))
         JOIN (pa
         WHERE expand(x,nstartindex,((nstartindex+ nbatch_size) - 1),pa.person_id,tmppersontz->qual[x
          ].person_id,
          0,tmppersontz->qual[x].birth_tz,cnvtdatetime(pa.updt_dt_tm),tmppersontz->qual[x].
          max_updt_dt_tm)
          AND pa.person_alias_type_cd=dmrncd
          AND ((pa.alias_pool_cd+ 0) > 0))
         JOIN (oap
         WHERE (oap.alias_pool_cd=(pa.alias_pool_cd+ 0))
          AND ((oap.organization_id+ 0) > 0))
         JOIN (tz
         WHERE (tz.parent_entity_id=(oap.organization_id+ 0))
          AND tz.parent_entity_name="ORGANIZATION")
        DETAIL
         ndx = locateval(ndx2,1,tmppersontz->qual_cnt,pa.person_id,tmppersontz->qual[ndx2].person_id)
         IF (ndx > 0)
          tmppersontz->qual[ndx].birth_tz = datetimezonebyname(trim(tz.time_zone,3))
          IF ((tmppersontz->qual[ndx].birth_tz > 0))
           tmppersontz->qual[ndx].abs_birth_dt_tm = datetimezone(tmppersontz->qual[ndx].birth_dt_tm,
            tmppersontz->qual[ndx].birth_tz)
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
        GO TO end_program
       ENDIF
      ENDIF
     ENDIF
     SET lstat = alterlist(tmppersontz->qual,tmppersontz->qual_cnt)
     SET ndx = 1
     WHILE (ndx > 0)
      SET ndx = locateval(ndx2,ndx,tmppersontz->qual_cnt,0,tmppersontz->qual[ndx2].birth_tz)
      IF (ndx > 0)
       SET tmppersontz->qual[ndx].birth_tz = curtimezonesys
      ENDIF
     ENDWHILE
    ENDIF
    CALL echo("*****Performing the needed updates*****")
    UPDATE  FROM person_matches pm,
      (dummyt d  WITH seq = value(tmppersontz->qual_cnt))
     SET pm.a_birth_tz = tmppersontz->qual[d.seq].birth_tz, pm.b_birth_tz = tmppersontz->qual[d.seq].
      birth_tz, pm.updt_applctx = reqinfo->updt_applctx,
      pm.updt_cnt = (pm.updt_cnt+ 1), pm.updt_id = reqinfo->updt_id, pm.updt_task = reqinfo->
      updt_task,
      pm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (pm
      WHERE (pm.a_person_id=tmppersontz->qual[d.seq].person_id)
       AND pm.active_ind=1)
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
     GO TO end_program
    ENDIF
    COMMIT
    UPDATE  FROM hna_except_audit hea,
      (dummyt d  WITH seq = value(tmppersontz->qual_cnt))
     SET hea.dob_tz = tmppersontz->qual[d.seq].birth_tz, hea.updt_applctx = reqinfo->updt_applctx,
      hea.updt_cnt = (hea.updt_cnt+ 1),
      hea.updt_id = reqinfo->updt_id, hea.updt_task = reqinfo->updt_task, hea.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (hea
      WHERE (hea.person_id=tmppersontz->qual[d.seq].person_id))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
     GO TO end_program
    ENDIF
    COMMIT
    UPDATE  FROM person p,
      (dummyt d  WITH seq = value(tmppersontz->qual_cnt))
     SET p.abs_birth_dt_tm = cnvtdatetime(tmppersontz->qual[d.seq].abs_birth_dt_tm), p.birth_tz =
      tmppersontz->qual[d.seq].birth_tz, p.updt_applctx = reqinfo->updt_applctx,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (p
      WHERE (p.person_id=tmppersontz->qual[d.seq].person_id))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme FAILURE. ERROR: ",errmsg)
     GO TO end_program
    ENDIF
    COMMIT
    SET dprevmaxpersonid = tmppersontz->qual[tmppersontz->qual_cnt].person_id
    CALL echo(build2("##### Max Person_id: ",build(dprevmaxpersonid)," #####"))
   ELSE
    SET bstop = true
   ENDIF
 ENDWHILE
 SET readme_data->message = "- Readme SUCCESS. DM_UPT_ABS_TZ_FIELDS."
 SET readme_data->status = "S"
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id != 0
   AND p.birth_dt_tm != null
   AND p.abs_birth_dt_tm=null
  DETAIL
   readme_data->message = concat("- Readme FAILURE. DM_UPT_ABS_TZ_FIELDS. Person id -",trim(
     cnvtstring(p.person_id),3),"- has not been updated."), readme_data->status = "F"
  WITH nocounter, maxqual(p,1)
 ;end select
#end_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ENDIF
 FREE RECORD tmppersontz
 CALL echo("end time:")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
END GO
