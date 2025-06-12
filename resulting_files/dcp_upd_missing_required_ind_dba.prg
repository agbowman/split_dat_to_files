CREATE PROGRAM dcp_upd_missing_required_ind:dba
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
 FREE RECORD phase
 RECORD phase(
   1 count = i4
   1 size = i4
   1 list[*]
     2 pathway_catalog_id = f8
 )
 FREE RECORD query_missing_required_request
 RECORD query_missing_required_request(
   1 initialized = i2
   1 debug = i2
   1 count = i4
   1 size = i4
   1 batch_size = i4
   1 loop_count = i4
   1 resize_reply_ind = i2
   1 list[*]
     2 pathway_comp_id = f8
 )
 FREE RECORD query_missing_required_reply
 RECORD query_missing_required_reply(
   1 start = i4
   1 count = i4
   1 size = i4
   1 batch_size = i4
   1 loop_count = i4
   1 status = c1
   1 status_description = vc
   1 list[*]
     2 pathway_comp_id = f8
     2 order_sentence_id = f8
     2 missing_required_ind = i2
 )
 FREE RECORD missing_required
 RECORD missing_required(
   1 start = i4
   1 idx = i4
   1 size = i4
   1 batch_size = i4
   1 loop_count = i4
   1 list[*]
     2 pathway_comp_id = f8
     2 order_sentence_id = f8
 )
 FREE RECORD not_missing_required
 RECORD not_missing_required(
   1 start = i4
   1 idx = i4
   1 size = i4
   1 batch_size = i4
   1 loop_count = i4
   1 list[*]
     2 pathway_comp_id = f8
     2 order_sentence_id = f8
 )
 DECLARE cstatus = c1 WITH protect, noconstant("F")
 DECLARE err_msg = vc WITH private
 DECLARE err_code = i4 WITH private, noconstant(1)
 DECLARE l_missing_required_idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE request_size = i4 WITH protect, noconstant(0)
 DECLARE request_count = i4 WITH protect, noconstant(0)
 DECLARE request_batch_size = i4 WITH protect, noconstant(100)
 DECLARE phase_idx = i4 WITH protect, noconstant(0)
 DECLARE dm_info_date = dq8 WITH public, noconstant(cnvtdatetime(0,0))
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed in starting the script dcp_upd_missing_required_ind.prg"
 SELECT INTO "nl:"
  d.info_date
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="DCP_UPD_MISSING_REQUIRED_IND"
    AND d.info_name="Uptime Processed Date")
  DETAIL
   dm_info_date = cnvtdatetime(d.info_date)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   pc.pathway_catalog_id
   FROM pathway_catalog pc
   PLAN (pc
    WHERE pc.pathway_catalog_id > 0.0)
   ORDER BY pc.pathway_catalog_id
   DETAIL
    phase->count = (phase->count+ 1)
    IF ((phase->size < phase->count))
     phase->size = (phase->size+ 100), stat = alterlist(phase->list,phase->size)
    ENDIF
    phase->list[phase->count].pathway_catalog_id = pc.pathway_catalog_id
   FOOT REPORT
    IF ((phase->count > 0))
     IF ((phase->count < phase->size))
      phase->size = phase->count, stat = alterlist(phase->list,phase->count)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   pc.pathway_catalog_id
   FROM pathway_catalog pc
   PLAN (pc
    WHERE pc.pathway_catalog_id > 0.0
     AND pc.updt_dt_tm > cnvtdatetime(dm_info_date))
   ORDER BY pc.pathway_catalog_id
   DETAIL
    phase->count = (phase->count+ 1)
    IF ((phase->size < phase->count))
     phase->size = (phase->size+ 100), stat = alterlist(phase->list,phase->size)
    ENDIF
    phase->list[phase->count].pathway_catalog_id = pc.pathway_catalog_id
   FOOT REPORT
    IF ((phase->count > 0))
     IF ((phase->count < phase->size))
      phase->size = phase->count, stat = alterlist(phase->list,phase->count)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((phase->count < 1))
  SET readme_data->status = "Z"
 ENDIF
 FOR (phase_idx = 1 TO phase->count)
   SET last_pathway_catalog_id = phase->list[phase_idx].pathway_catalog_id
   SET request_size = 0
   SET request_count = 0
   SET stat = alterlist(query_missing_required_request->list,0)
   SELECT INTO "nl:"
    pcor.pathway_comp_id
    FROM pathway_comp pc,
     pw_comp_os_reltn pcor
    PLAN (pc
     WHERE (pc.pathway_catalog_id=phase->list[phase_idx].pathway_catalog_id))
     JOIN (pcor
     WHERE pcor.pathway_comp_id=pc.pathway_comp_id
      AND pcor.order_sentence_id > 0.0)
    ORDER BY pcor.pathway_comp_id
    HEAD pcor.pathway_comp_id
     request_count = (request_count+ 1)
     IF (request_size < request_count)
      request_size = (request_size+ request_batch_size), stat = alterlist(
       query_missing_required_request->list,request_size)
     ENDIF
     query_missing_required_request->list[request_count].pathway_comp_id = pcor.pathway_comp_id
    DETAIL
     dummy = 0
    FOOT REPORT
     IF (request_count > 0)
      query_missing_required_request->count = request_count, query_missing_required_request->size =
      request_size, query_missing_required_request->batch_size = request_batch_size
      IF (request_count < request_size)
       stat = alterlist(query_missing_required_request->list,request_count)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   EXECUTE dcp_get_missing_required_ind_r
   IF (cnvtupper(query_missing_required_reply->status)="F")
    SET readme_data->status = "F"
    SET readme_data->message = trim(query_missing_required_reply->status_description)
    GO TO exit_script
   ENDIF
   IF (((cnvtupper(query_missing_required_reply->status)="Z") OR ((query_missing_required_reply->
   count < 1))) )
    SET cstatus = "Z"
   ELSE
    SET cstatus = "S"
   ENDIF
   IF (cstatus="S")
    SET missing_required->idx = 0
    SET missing_required->size = 0
    SET missing_required->batch_size = 10
    SET not_missing_required->idx = 0
    SET not_missing_required->size = 0
    SET not_missing_required->batch_size = 10
    FOR (l_missing_required_idx = 1 TO query_missing_required_reply->count)
      IF ((query_missing_required_reply->list[l_missing_required_idx].missing_required_ind=1))
       SET missing_required->idx = (missing_required->idx+ 1)
       IF ((missing_required->size < missing_required->idx))
        SET missing_required->size = (missing_required->size+ missing_required->batch_size)
        SET stat = alterlist(missing_required->list,missing_required->size)
       ENDIF
       SET missing_required->list[missing_required->idx].pathway_comp_id =
       query_missing_required_reply->list[l_missing_required_idx].pathway_comp_id
       SET missing_required->list[missing_required->idx].order_sentence_id =
       query_missing_required_reply->list[l_missing_required_idx].order_sentence_id
      ELSE
       SET not_missing_required->idx = (not_missing_required->idx+ 1)
       IF ((not_missing_required->size < not_missing_required->idx))
        SET not_missing_required->size = (not_missing_required->size+ not_missing_required->
        batch_size)
        SET stat = alterlist(not_missing_required->list,not_missing_required->size)
       ENDIF
       SET not_missing_required->list[not_missing_required->idx].pathway_comp_id =
       query_missing_required_reply->list[l_missing_required_idx].pathway_comp_id
       SET not_missing_required->list[not_missing_required->idx].order_sentence_id =
       query_missing_required_reply->list[l_missing_required_idx].order_sentence_id
      ENDIF
    ENDFOR
    SET stat = alterlist(missing_required->list,missing_required->idx)
    SET stat = alterlist(not_missing_required->list,not_missing_required->idx)
    IF ((missing_required->idx > 0))
     UPDATE  FROM (dummyt d1  WITH seq = value(missing_required->idx)),
       pw_comp_os_reltn pcor
      SET pcor.missing_required_ind = 1, pcor.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcor
       .updt_id = reqinfo->updt_id,
       pcor.updt_task = reqinfo->updt_task, pcor.updt_cnt = (pcor.updt_cnt+ 1)
      PLAN (d1)
       JOIN (pcor
       WHERE (pcor.pathway_comp_id=missing_required->list[d1.seq].pathway_comp_id)
        AND (pcor.order_sentence_id=missing_required->list[d1.seq].order_sentence_id))
      WITH nocounter
     ;end update
     SET err_msg = fillstring(132," ")
     SET err_code = error(err_msg,0)
     IF (err_code != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat(trim("UPDATE OSes missing requried fields failed")," - ",trim
       (err_msg))
      ROLLBACK
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
     SET readme_data->status = "S"
    ENDIF
    IF ((not_missing_required->idx > 0))
     UPDATE  FROM (dummyt d1  WITH seq = value(not_missing_required->idx)),
       pw_comp_os_reltn pcor
      SET pcor.missing_required_ind = 0, pcor.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcor
       .updt_id = reqinfo->updt_id,
       pcor.updt_task = reqinfo->updt_task, pcor.updt_cnt = (pcor.updt_cnt+ 1)
      PLAN (d1)
       JOIN (pcor
       WHERE (pcor.pathway_comp_id=not_missing_required->list[d1.seq].pathway_comp_id)
        AND (pcor.order_sentence_id=not_missing_required->list[d1.seq].order_sentence_id))
      WITH nocounter
     ;end update
     SET err_msg = fillstring(132," ")
     SET err_code = error(err_msg,0)
     IF (err_code != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat(trim("UPDATE OSes not missing requried fields failed")," - ",
       trim(err_msg))
      ROLLBACK
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
     SET readme_data->status = "S"
    ENDIF
    IF ((readme_data->status != "S"))
     SET readme_data->status = "Z"
    ENDIF
   ELSEIF ((readme_data->status != "S"))
    SET readme_data->status = "Z"
   ENDIF
 ENDFOR
#exit_script
 IF ((readme_data->status="Z"))
  SET readme_data->status = "S"
  SET readme_data->message = "No items were updated."
 ELSEIF ((readme_data->status="S"))
  SET readme_data->message = "The readme was successful."
 ENDIF
 IF ((readme_data->status="S"))
  IF (dm_info_date=0)
   INSERT  FROM dm_info d
    SET d.info_domain = "DCP_UPD_MISSING_REQUIRED_IND", d.info_name = "Uptime Processed Date", d
     .info_date = sysdate
   ;end insert
  ELSE
   UPDATE  FROM dm_info d
    SET d.info_date = sysdate
    WHERE d.info_domain="DCP_UPD_MISSING_REQUIRED_IND"
     AND d.info_name="Uptime Processed Date"
   ;end update
  ENDIF
  SET err_msg = fillstring(132," ")
  SET err_code = error(err_msg,0)
  IF (err_code != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(trim("INSERT into dm_info failed")," - ",trim(err_msg))
   ROLLBACK
  ELSE
   COMMIT
  ENDIF
 ENDIF
 FREE RECORD phase
 FREE RECORD missing_required
 FREE RECORD not_missing_required
 FREE RECORD query_missing_required_request
 FREE RECORD query_missing_required_reply
 DECLARE dcp_upd_missing_required_ind_last_mod = c3 WITH public, constant("000")
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
