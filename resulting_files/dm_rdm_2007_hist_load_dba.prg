CREATE PROGRAM dm_rdm_2007_hist_load:dba
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
 SET readme_data->message = "Readme Failed: Starting script - dm_rdm_2007_hist_load.prg..."
 FREE RECORD histload
 RECORD histload(
   1 hist_load[*]
     2 project_type = c12
     2 project_name = c100
     2 project_instance = i4
     2 ocd = i4
     2 exist_ind = i2
 )
 DECLARE tmp_toolset_usage = i2
 DECLARE inhsechk = i4
 DECLARE currenvid = f8
 DECLARE cnt = i4
 DECLARE z = i4
 DECLARE errcode = i4
 DECLARE errmsg = c132
 SET hist_2007_load_version = "000"
 SET inhsechk = 0
 SET currenvid = 0.0
 SET cnt = 0
 SET z = 0
 SET errcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   inhsechk = 1
  WITH nocounter
 ;end select
 IF (inhsechk=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Auto-Success - readme is not to run in an inhouse domain."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   currenvid = di.info_number
  WITH nocounter
 ;end select
 CALL echo(build("Current Environment ID:",currenvid))
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(histload->hist_load,cnt)
 FOR (z = 1 TO cnt)
   SET histload->hist_load[z].project_type = trim(requestin->list_0[z].project_type,3)
   SET histload->hist_load[z].project_name = trim(requestin->list_0[z].project_name,3)
   SET histload->hist_load[z].project_instance = cnvtint(requestin->list_0[z].project_instance)
   SET histload->hist_load[z].ocd = cnvtint(requestin->list_0[z].ocd)
   SET histload->hist_load[z].exist_ind = 0
 ENDFOR
 SELECT INTO "nl:"
  FROM dm_ocd_log dol,
   (dummyt dt  WITH seq = value(size(histload->hist_load,5)))
  PLAN (dt)
   JOIN (dol
   WHERE dol.environment_id=currenvid
    AND (dol.project_type=histload->hist_load[dt.seq].project_type)
    AND (dol.project_name=histload->hist_load[dt.seq].project_name)
    AND (dol.ocd=histload->hist_load[dt.seq].ocd)
    AND (dol.project_instance=histload->hist_load[dt.seq].project_instance))
  DETAIL
   histload->hist_load[dt.seq].exist_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM dm_ocd_log dol,
   (dummyt dt  WITH seq = value(size(histload->hist_load,5)))
  SET dol.seq = 1, dol.environment_id = currenvid, dol.project_type = histload->hist_load[dt.seq].
   project_type,
   dol.project_name = histload->hist_load[dt.seq].project_name, dol.project_instance = histload->
   hist_load[dt.seq].project_instance, dol.ocd = histload->hist_load[dt.seq].ocd,
   dol.batch_dt_tm = cnvtdatetime(curdate,curtime3), dol.status = "SUCCESS", dol.start_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dol.end_dt_tm = cnvtdatetime(curdate,curtime3), dol.driver_count = 0, dol.estimated_time = 0.0,
   dol.message = concat("THIS ROW WAS INSERTED BY dm_rdm_2007_hist_load.prg ",
    "TO BACKFILL PROCESSED README HISTORY FOR 2007 RELEASE."), dol.active_ind = 1, dol.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dol.appl_ident = " "
  PLAN (dt
   WHERE (histload->hist_load[dt.seq].exist_ind=0))
   JOIN (dol)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: Error occurred during backfill insert."
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_log dol,
   (dummyt dt  WITH seq = value(size(histload->hist_load,5)))
  PLAN (dt
   WHERE (histload->hist_load[dt.seq].exist_ind=0))
   JOIN (dol
   WHERE dol.environment_id=currenvid
    AND (dol.project_type=histload->hist_load[dt.seq].project_type)
    AND (dol.project_name=histload->hist_load[dt.seq].project_name)
    AND (dol.ocd=histload->hist_load[dt.seq].ocd)
    AND (dol.project_instance=histload->hist_load[dt.seq].project_instance))
  DETAIL
   histload->hist_load[dt.seq].exist_ind = 1
  WITH nocounter
 ;end select
 FOR (z = 1 TO cnt)
   IF ((histload->hist_load[z].exist_ind != 1))
    SET readme_data->message =
    "Readme Failed to insert backfill rows of readme history for 2007 release."
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message =
 "Readme Successful: All backfill rows of readme history for 2007 release inserted successfully."
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
