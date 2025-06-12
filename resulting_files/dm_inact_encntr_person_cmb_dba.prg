CREATE PROGRAM dm_inact_encntr_person_cmb:dba
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
 DECLARE iepc_inc = f8 WITH protect, noconstant(100000.0)
 DECLARE iepc_minid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_maxid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_minencntrid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_minpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_maxencntrid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_maxpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE iepc_errmsg = vc
 DECLARE iepc_errcode = i4 WITH protect, noconstant(0)
 DECLARE iepc_updtcnt = i4 WITH protect, noconstant(0)
 DECLARE iepc_recsize = i4 WITH protect, noconstant(0)
 DECLARE iepc_inforows = i4 WITH protect, noconstant(0)
 DECLARE loopiter = i4 WITH protect, noconstant(0)
 DECLARE iepc_new_info_name = vc
 SET readme_data->status = "F"
 SET readme_data->message = "Failed while trying to inactivate person and encounter combine rows."
 SELECT INTO "nl:"
  themin = di.info_number
  FROM dm_info di
  WHERE di.info_domain="DM EVALUATE ENCNTR_COMBINES WITH NO DETAIL"
   AND di.info_name="MAX ENCNTR_COMBINE_ID EVALUATED"
  DETAIL
   iepc_minencntrid = themin
  WITH nocounter
 ;end select
 SET iepc_errcode = error(iepc_errmsg,1)
 IF (iepc_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure during DM_INFO select:",iepc_errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DM EVALUATE ENCNTR_COMBINES WITH NO DETAIL", di.info_name =
    "MAX ENCNTR_COMBINE_ID EVALUATED", di.info_number = 1,
    di.info_date = cnvtdatetime(curdate,curtime3)
  ;end insert
  SET iepc_errcode = error(iepc_errmsg,1)
  IF (iepc_errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure during DM_INFO insert:",iepc_errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
  SET iepc_minencntrid = 1
 ENDIF
 SELECT INTO "nl:"
  themin = di.info_number
  FROM dm_info di
  WHERE di.info_domain="DM EVALUATE PERSON_COMBINES WITH NO DETAIL"
   AND di.info_name="MAX PERSON_COMBINE_ID EVALUATED"
  DETAIL
   iepc_minpersonid = themin
  WITH nocounter
 ;end select
 SET iepc_errcode = error(iepc_errmsg,1)
 IF (iepc_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure during DM_INFO select:",iepc_errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DM EVALUATE PERSON_COMBINES WITH NO DETAIL", di.info_name =
    "MAX PERSON_COMBINE_ID EVALUATED", di.info_number = 1,
    di.info_date = cnvtdatetime(curdate,curtime3)
  ;end insert
  SET iepc_errcode = error(iepc_errmsg,1)
  IF (iepc_errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure during DM_INFO insert:",iepc_errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
  SET iepc_minpersonid = 1
 ENDIF
 FREE RECORD rec_id
 RECORD rec_id(
   1 array[*]
     2 id = f8
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_id = f8
 )
 CALL echo("*** Determining the Max ID values ***")
 SELECT INTO "nl:"
  themax = max(encntr_combine_id)
  FROM encntr_combine
  WHERE encntr_combine_id > 0
  DETAIL
   iepc_maxencntrid = themax
  WITH nocounter
 ;end select
 SET iepc_errcode = error(iepc_errmsg,1)
 IF (iepc_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure during ENCNTR_COMBINE select:",iepc_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  themax = max(person_combine_id)
  FROM person_combine
  WHERE person_combine_id > 0
  DETAIL
   iepc_maxpersonid = themax
  WITH nocounter
 ;end select
 SET iepc_errcode = error(iepc_errmsg,1)
 IF (iepc_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure during PERSON_COMBINE select:",iepc_errmsg)
  GO TO exit_script
 ENDIF
 CALL echo(build("*** Min ENCNTR_COMBINE_ID: ",iepc_minencntrid))
 CALL echo(build("*** Max ENCNTR_COMBINE_ID: ",iepc_maxencntrid))
 CALL echo(build("*** Min PERSON_COMBINE_ID: ",iepc_minpersonid))
 CALL echo(build("*** Max PERSON_COMBINE_ID: ",iepc_maxpersonid))
 CALL echo(build("*** Range increment Value: ",iepc_inc))
 CALL echo("*** Beginning to Update ENCNTR_COMBINE table ***")
 SET iepc_minid = iepc_minencntrid
 SET iepc_maxid = (iepc_minencntrid+ iepc_inc)
 SET iepc_updtcnt = 0
 SET stat = alterlist(rec_id->array,0)
 WHILE (iepc_minid < iepc_maxencntrid)
   IF (iepc_maxid > iepc_maxencntrid)
    SET iepc_maxid = (iepc_maxencntrid+ 1)
   ENDIF
   CALL echo(build("Processing rows (",iepc_minid,") to (",iepc_maxid,") out of (",
     iepc_maxencntrid,")"))
   SELECT INTO "nl:"
    FROM encntr_combine ec
    WHERE ec.encntr_combine_id BETWEEN iepc_minid AND iepc_maxid
     AND  NOT ( EXISTS (
    (SELECT
     ecd.encntr_combine_id
     FROM encntr_combine_det ecd
     WHERE ecd.encntr_combine_id=ec.encntr_combine_id)))
     AND ec.active_ind=1
    HEAD REPORT
     iepc_recsize = 0
    DETAIL
     iepc_recsize = (iepc_recsize+ 1)
     IF (mod(iepc_recsize,10)=1)
      stat = alterlist(rec_id->array,(iepc_recsize+ 9))
     ENDIF
     rec_id->array[iepc_recsize].id = ec.encntr_combine_id, rec_id->array[iepc_recsize].updt_dt_tm =
     ec.updt_dt_tm, rec_id->array[iepc_recsize].updt_id = ec.updt_id,
     rec_id->array[iepc_recsize].updt_task = ec.updt_task
    FOOT REPORT
     stat = alterlist(rec_id->array,iepc_recsize)
    WITH nocounter
   ;end select
   SET iepc_errcode = error(iepc_errmsg,1)
   IF (iepc_errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during ENCNTR_COMBINE select:",iepc_errmsg)
    GO TO exit_script
   ENDIF
   IF (size(rec_id->array,5) > 0)
    FOR (loopiter = 1 TO size(rec_id->array,5))
      SET iepc_inforows = (iepc_inforows+ 1)
      SET iepc_new_info_name = build("EC_ID=",rec_id->array[loopiter].id,";UPDT_DT_TM=",format(rec_id
        ->array[loopiter].updt_dt_tm,";;Q"),";UPDT_TASK=",
       rec_id->array[loopiter].updt_task,";UPDT_ID=",rec_id->array[loopiter].updt_id)
      INSERT  FROM dm_info di
       SET di.info_domain = "DM INACTIVATE ENCNTR_COMBINE_ID WITH NO DETAIL", di.info_name =
        iepc_new_info_name, di.info_number = rec_id->array[loopiter].id,
        di.updt_task = 426, di.updt_applctx = 426, di.updt_id = 426
      ;end insert
    ENDFOR
    SET iepc_errcode = error(iepc_errmsg,1)
    IF (iepc_errcode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during DM_INFO insert:",iepc_errmsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM encntr_combine ec,
      (dummyt d  WITH seq = value(size(rec_id->array,5)))
     SET ec.active_ind = 0, ec.updt_task = 426, ec.updt_applctx = 426,
      ec.updt_id = 426, ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (ec
      WHERE (ec.encntr_combine_id=rec_id->array[d.seq].id))
     WITH nocounter
    ;end update
    SET iepc_errcode = error(iepc_errmsg,1)
    IF (iepc_errcode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during ENCNTR_COMBINE update:",iepc_errmsg)
     GO TO exit_script
    ENDIF
    COMMIT
    SET iepc_updtcnt = (iepc_updtcnt+ curqual)
   ENDIF
   UPDATE  FROM dm_info di
    SET di.info_number = iepc_maxid, di.info_date = cnvtdatetime(curdate,curtime3)
    WHERE di.info_domain="DM EVALUATE ENCNTR_COMBINES WITH NO DETAIL"
     AND di.info_name="MAX ENCNTR_COMBINE_ID EVALUATED"
   ;end update
   SET iepc_errcode = error(iepc_errmsg,1)
   IF (iepc_errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during DM_INFO update:",iepc_errmsg)
    GO TO exit_script
   ENDIF
   COMMIT
   SET iepc_minid = (iepc_maxid+ 1)
   SET iepc_maxid = (iepc_maxid+ iepc_inc)
   SET stat = alterlist(rec_id->array,0)
   SET iepc_recsize = 0
 ENDWHILE
 CALL echo(build("+++ Total rows updated: ",iepc_updtcnt))
 CALL echo(build("+++ Total rows shown: ",iepc_inforows))
 CALL echo("*** Beginning to Update PERSON_COMBINE table ***")
 SET iepc_updtcnt = 0
 SET iepc_inforows = 0
 SET iepc_minid = iepc_minpersonid
 SET iepc_maxid = (iepc_minpersonid+ iepc_inc)
 WHILE (iepc_minid < iepc_maxpersonid)
   IF (iepc_maxid > iepc_maxpersonid)
    SET iepc_maxid = (iepc_maxpersonid+ 1)
   ENDIF
   CALL echo(build("Processing rows (",iepc_minid,") to (",iepc_maxid,") out of (",
     iepc_maxpersonid,")"))
   SELECT INTO "nl:"
    FROM person_combine pc
    WHERE pc.person_combine_id BETWEEN iepc_minid AND iepc_maxid
     AND  NOT ( EXISTS (
    (SELECT
     pcd.person_combine_id
     FROM person_combine_det pcd
     WHERE pcd.person_combine_id=pc.person_combine_id)))
     AND ((pc.encntr_id+ 0)=0)
     AND pc.active_ind=1
    HEAD REPORT
     iepc_recsize = 0
    DETAIL
     iepc_recsize = (iepc_recsize+ 1)
     IF (mod(iepc_recsize,10)=1)
      stat = alterlist(rec_id->array,(iepc_recsize+ 9))
     ENDIF
     rec_id->array[iepc_recsize].id = pc.person_combine_id, rec_id->array[iepc_recsize].updt_dt_tm =
     pc.updt_dt_tm, rec_id->array[iepc_recsize].updt_id = pc.updt_id,
     rec_id->array[iepc_recsize].updt_task = pc.updt_task
    FOOT REPORT
     stat = alterlist(rec_id->array,iepc_recsize)
    WITH nocounter
   ;end select
   IF (size(rec_id->array,5) > 0)
    FOR (loopiter = 1 TO size(rec_id->array,5))
      SET iepc_inforows = (iepc_inforows+ 1)
      SET iepc_new_info_name = build("PC_ID=",rec_id->array[loopiter].id,";UPDT_DT_TM=",format(rec_id
        ->array[loopiter].updt_dt_tm,";;Q"),";UPDT_TASK=",
       rec_id->array[loopiter].updt_task,";UPDT_ID=",rec_id->array[loopiter].updt_id)
      INSERT  FROM dm_info di
       SET di.info_domain = "DM INACTIVATE PERSON_COMBINE_ID WITH NO DETAIL", di.info_name =
        iepc_new_info_name, di.info_number = rec_id->array[loopiter].id,
        di.updt_task = 426, di.updt_applctx = 426, di.updt_id = 426
      ;end insert
    ENDFOR
    SET iepc_errcode = error(iepc_errmsg,1)
    IF (iepc_errcode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during DM_INFO insert:",iepc_errmsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM person_combine pc,
      (dummyt d  WITH seq = value(size(rec_id->array,5)))
     SET pc.active_ind = 0, pc.updt_task = 426, pc.updt_applctx = 426,
      pc.updt_id = 426, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (pc
      WHERE (pc.person_combine_id=rec_id->array[d.seq].id))
     WITH nocounter
    ;end update
    SET iepc_errcode = error(iepc_errmsg,1)
    IF (iepc_errcode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during PERSON_COMBINE update:",iepc_errmsg)
     GO TO exit_script
    ENDIF
    COMMIT
    SET iepc_updtcnt = (iepc_updtcnt+ curqual)
   ENDIF
   UPDATE  FROM dm_info di
    SET di.info_number = iepc_maxid, di.info_date = cnvtdatetime(curdate,curtime3)
    WHERE di.info_domain="DM EVALUATE PERSON_COMBINES WITH NO DETAIL"
     AND di.info_name="MAX PERSON_COMBINE_ID EVALUATED"
   ;end update
   SET iepc_errcode = error(iepc_errmsg,1)
   IF (iepc_errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during DM_INFO update:",iepc_errmsg)
    GO TO exit_script
   ENDIF
   COMMIT
   SET iepc_minid = (iepc_maxid+ 1)
   SET iepc_maxid = (iepc_maxid+ iepc_inc)
   SET stat = alterlist(rec_id->array,0)
   SET iepc_recsize = 0
 ENDWHILE
 CALL echo(build("+++ Total rows updated: ",iepc_updtcnt))
 CALL echo(build("+++ Total rows shown: ",iepc_inforows))
 SET readme_data->status = "S"
 SET readme_data->message = "All combine rows updated successfully."
 COMMIT
#exit_script
 IF (iepc_errcode != 0)
  ROLLBACK
 ENDIF
 CALL echo("*** Exiting script ***")
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
