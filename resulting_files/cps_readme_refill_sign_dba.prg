CREATE PROGRAM cps_readme_refill_sign:dba
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
 DECLARE dnv_id = f8
 DECLARE itoadd = i4 WITH noconstant(0)
 DECLARE imm = i2 WITH noconstant(0)
 DECLARE ies = i2 WITH noconstant(0)
 DECLARE iss = i2 WITH noconstant(0)
 DECLARE imgknt = i4 WITH noconstant(0)
 DECLARE idpknt = i4 WITH noconstant(0)
 DECLARE sline = c120 WITH constant(fillstring(120,"="))
 DECLARE ierror = i2 WITH noconstant(0)
 DECLARE serrmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE ierrcode = i2 WITH noconstant(0)
 DECLARE ddp_id = f8 WITH noconstant(0.0)
 DECLARE last_mod = vc
 DECLARE ineedprocess = i2 WITH noconstant(1)
 DECLARE iappknt = i4 WITH noconstant(0)
 FREE SET data
 RECORD data(
   1 current_qual[*]
     2 name_value_prefs_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 pvc_value = vc
     2 remove_ind = i2
     2 application_number = f8
     2 position_cd = f8
     2 prsnl_id = f8
   1 add_qual[*]
     2 detail_prefs_id = f8
   1 migrate_qual[*]
     2 app_number = f8
     2 detail_prefs_qual[3]
       3 detail_prefs_id = f8
       3 exist_ind = i2
       3 view_name = vc
       3 name_value_prefs_id = f8
       3 pvc_value = vc
 )
 SELECT INTO "nl:"
  *
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="ENABLE_REFILL_SIGN"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(data->current_qual,cnt), data->current_qual[cnt].
   name_value_prefs_id = nvp.name_value_prefs_id,
   data->current_qual[cnt].parent_entity_name = nvp.parent_entity_name, data->current_qual[cnt].
   parent_entity_id = nvp.parent_entity_id, data->current_qual[cnt].pvc_value = nvp.pvc_value
   IF (nvp.parent_entity_name="APP_PREFS")
    data->current_qual[cnt].remove_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message =
   "ERROR :: A script error occurred while searching ENABLE_REFILL_SIGN preferences."
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET ierror = 1
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Info :: There is no data to convert in name_value_prefs table"
   EXECUTE dm_readme_status
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dp.application_number, dp.position_cd, dp.prsnl_id
  FROM (dummyt d  WITH seq = value(size(data->current_qual,5))),
   detail_prefs dp
  PLAN (d
   WHERE (data->current_qual[d.seq].parent_entity_name="DETAIL_PREFS"))
   JOIN (dp
   WHERE (dp.detail_prefs_id=data->current_qual[d.seq].parent_entity_id))
  DETAIL
   data->current_qual[d.seq].application_number = dp.application_number, data->current_qual[d.seq].
   position_cd = dp.position_cd, data->current_qual[d.seq].prsnl_id = dp.prsnl_id
   IF (dp.application_number > 0)
    IF (((dp.position_cd > 0) OR (dp.prsnl_id > 0)) )
     data->current_qual[d.seq].remove_ind = 1
    ENDIF
   ELSE
    data->current_qual[d.seq].remove_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ap.application_number, ap.position_cd, ap.prsnl_id
  FROM (dummyt d  WITH seq = value(size(data->current_qual,5))),
   app_prefs ap
  PLAN (d
   WHERE (data->current_qual[d.seq].parent_entity_name="APP_PREFS"))
   JOIN (ap
   WHERE (ap.app_prefs_id=data->current_qual[d.seq].parent_entity_id))
  DETAIL
   data->current_qual[d.seq].application_number = ap.application_number, data->current_qual[d.seq].
   position_cd = ap.position_cd, data->current_qual[d.seq].prsnl_id = ap.prsnl_id,
   data->current_qual[d.seq].remove_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  data->current_qual[d.seq].application_number
  FROM (dummyt d  WITH seq = value(size(data->current_qual,5))),
   dummyt d2,
   (dummyt d3  WITH seq = value(size(data->current_qual,5)))
  PLAN (d
   WHERE (data->current_qual[d.seq].remove_ind > 0)
    AND (data->current_qual[d.seq].parent_entity_name="APP_PREFS"))
   JOIN (d2)
   JOIN (d3
   WHERE (data->current_qual[d3.seq].parent_entity_name="DETAIL_PREFS")
    AND (data->current_qual[d3.seq].application_number=data->current_qual[d.seq].application_number)
    AND (data->current_qual[d3.seq].position_cd=0)
    AND (data->current_qual[d3.seq].prsnl_id=0))
  DETAIL
   IF ((data->current_qual[d.seq].application_number > 0))
    data->current_qual[d.seq].remove_ind = 2
   ENDIF
  WITH outerjoin = d2, dontexist
 ;end select
 FOR (x = 1 TO value(size(data->current_qual,5)))
   IF ((data->current_qual[x].remove_ind != 1))
    SET ineedprocess = 1
    SET iappknt = value(size(data->migrate_qual,5))
    FOR (y = 1 TO iappknt)
      IF ((data->current_qual[x].application_number=data->migrate_qual[y].app_number))
       SET ineedprocess = 0
      ENDIF
    ENDFOR
    CALL echo(build("iNeedProcess = ",ineedprocess))
    IF (ineedprocess=1)
     SET ddp_id = 0
     SET imgknt = (imgknt+ 1)
     SET idpknt = 0
     SET itoadd = 0
     SET imm = 0
     SET ies = 0
     SET iss = 0
     SET stat = alterlist(data->migrate_qual,imgknt)
     SET data->migrate_qual[imgknt].app_number = data->current_qual[x].application_number
     SELECT INTO "nl:"
      *
      FROM detail_prefs dp
      WHERE (dp.application_number=data->current_qual[x].application_number)
       AND dp.prsnl_id=0
       AND dp.position_cd=0
       AND dp.view_name IN ("MEDPROFILE", "ESMEDPROFILE", "SSMEDPROFILE")
      DETAIL
       IF ((data->current_qual[x].remove_ind=2))
        itoadd = (itoadd+ 1), stat = alterlist(data->add_qual,itoadd), data->add_qual[itoadd].
        detail_prefs_id = dp.detail_prefs_id,
        idpknt = (idpknt+ 1), data->migrate_qual[imgknt].detail_prefs_qual[idpknt].detail_prefs_id =
        dp.detail_prefs_id, data->migrate_qual[imgknt].detail_prefs_qual[idpknt].exist_ind = 1,
        data->migrate_qual[imgknt].detail_prefs_qual[idpknt].view_name = dp.view_name
       ENDIF
       IF (dp.view_name="MEDPROFILE")
        imm = 1
       ELSEIF (dp.view_name="ESMEDPROFILE")
        ies = 1
       ELSE
        iss = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (imm=0)
      SELECT INTO "nl:"
       nextseq = seq(carenet_seq,nextval)"##############################;rp0"
       FROM dual
       DETAIL
        ddp_id = cnvtreal(nextseq)
       WITH format, nocounter
      ;end select
      INSERT  FROM detail_prefs dp
       SET dp.detail_prefs_id = ddp_id, dp.application_number = data->current_qual[x].
        application_number, dp.position_cd = 0,
        dp.prsnl_id = 0, dp.person_id = 0, dp.view_name = "MEDPROFILE",
        dp.view_seq = 0, dp.comp_name = "MEDPROFILE", dp.comp_seq = 0,
        dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
        dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_task = reqinfo->updt_task, dp
        .updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET itoadd = (itoadd+ 1)
      SET stat = alterlist(data->add_qual,itoadd)
      SET data->add_qual[itoadd].detail_prefs_id = ddp_id
      SET idpknt = (idpknt+ 1)
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].detail_prefs_id = ddp_id
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].exist_ind = 2
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].view_name = "MEDPROFILE"
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET readme_data->message =
       "ERROR :: A script error occurred while inserting a MEDPROFILE row."
       EXECUTE dm_readme_status
       SET readme_data->message = trim(serrmsg)
       EXECUTE dm_readme_status
       SET ierror = 1
       GO TO exit_script
      ENDIF
     ENDIF
     IF (ies=0)
      SELECT INTO "nl:"
       nextseq = seq(carenet_seq,nextval)"##############################;rp0"
       FROM dual
       DETAIL
        ddp_id = cnvtreal(nextseq)
       WITH format, nocounter
      ;end select
      INSERT  FROM detail_prefs dp
       SET dp.detail_prefs_id = ddp_id, dp.application_number = data->current_qual[x].
        application_number, dp.position_cd = 0,
        dp.prsnl_id = 0, dp.person_id = 0, dp.view_name = "ESMEDPROFILE",
        dp.view_seq = 0, dp.comp_name = "ESMEDPROFILE", dp.comp_seq = 0,
        dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
        dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_task = reqinfo->updt_task, dp
        .updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET itoadd = (itoadd+ 1)
      SET stat = alterlist(data->add_qual,itoadd)
      SET data->add_qual[itoadd].detail_prefs_id = ddp_id
      SET idpknt = (idpknt+ 1)
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].detail_prefs_id = ddp_id
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].exist_ind = 2
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].view_name = "ESMEDPROFILE"
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET readme_data->message =
       "ERROR :: A script error occurred while inserting a ESMEDPROFILE row."
       EXECUTE dm_readme_status
       SET readme_data->message = trim(serrmsg)
       EXECUTE dm_readme_status
       SET ierror = 1
       GO TO exit_script
      ENDIF
     ENDIF
     IF (iss=0)
      SELECT INTO "nl:"
       nextseq = seq(carenet_seq,nextval)"##############################;rp0"
       FROM dual
       DETAIL
        ddp_id = cnvtreal(nextseq)
       WITH format, nocounter
      ;end select
      INSERT  FROM detail_prefs dp
       SET dp.detail_prefs_id = ddp_id, dp.application_number = data->current_qual[x].
        application_number, dp.position_cd = 0,
        dp.prsnl_id = 0, dp.person_id = 0, dp.view_name = "SSMEDPROFILE",
        dp.view_seq = 0, dp.comp_name = "SSMEDPROFILE", dp.comp_seq = 0,
        dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
        dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_task = reqinfo->updt_task, dp
        .updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET itoadd = (itoadd+ 1)
      SET stat = alterlist(data->add_qual,itoadd)
      SET data->add_qual[itoadd].detail_prefs_id = ddp_id
      SET idpknt = (idpknt+ 1)
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].detail_prefs_id = ddp_id
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].exist_ind = 2
      SET data->migrate_qual[imgknt].detail_prefs_qual[idpknt].view_name = "SSMEDPROFILE"
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET readme_data->message =
       "ERROR :: A script error occurred while inserting a SSMEDPROFILE row."
       EXECUTE dm_readme_status
       SET readme_data->message = trim(serrmsg)
       EXECUTE dm_readme_status
       SET ierror = 1
       GO TO exit_script
      ENDIF
     ENDIF
     FOR (y = 1 TO itoadd)
       SELECT INTO "nl:"
        nextseq = seq(carenet_seq,nextval)"##############################;rp0"
        FROM dual
        DETAIL
         dnv_id = cnvtreal(nextseq)
        WITH format, nocounter
       ;end select
       INSERT  FROM name_value_prefs nv
        SET nv.name_value_prefs_id = dnv_id, nv.parent_entity_name = "DETAIL_PREFS", nv
         .parent_entity_id = data->add_qual[y].detail_prefs_id,
         nv.pvc_name = "ENABLE_REFILL_SIGN", nv.pvc_value = data->current_qual[x].pvc_value, nv
         .updt_cnt = 0,
         nv.updt_id = reqinfo->updt_id, nv.updt_id = reqinfo->updt_id, nv.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         nv.updt_task = reqinfo->updt_task, nv.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET data->migrate_qual[imgknt].detail_prefs_qual[y].name_value_prefs_id = dnv_id
       SET data->migrate_qual[imgknt].detail_prefs_qual[y].pvc_value = data->current_qual[x].
       pvc_value
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET readme_data->message =
        "ERROR :: A script error occurred while inserting a NAME_VALUE_PREFS row."
        EXECUTE dm_readme_status
        SET readme_data->message = trim(serrmsg)
        EXECUTE dm_readme_status
        SET ierror = 1
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF (value(size(data->current_qual,5)) > 0)
  DELETE  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(size(data->current_qual,5)))
   SET nvp.seq = nvp.seq
   PLAN (d
    WHERE (data->current_qual[d.seq].remove_ind IN (1, 2)))
    JOIN (nvp
    WHERE (nvp.name_value_prefs_id=data->current_qual[d.seq].name_value_prefs_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred while DELETING a MEDPROFILE row."
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET ierror = 1
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (ierror=1)
  ROLLBACK
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_README_CNVT_ENABLE_REFILL_SIGN  END : ",trim(status_msg),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET last_mod = "001 04/15/05 PC3603"
END GO
