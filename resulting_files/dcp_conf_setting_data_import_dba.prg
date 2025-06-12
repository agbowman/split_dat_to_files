CREATE PROGRAM dcp_conf_setting_data_import:dba
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
 SET readme_data->message = "Readme Failed: Starting dcp_conf_setting_data_import script"
 DECLARE PUBLIC::copydatafromrequestinrecord(null) = null WITH protect
 DECLARE PUBLIC::evaluaterecordtoaddupdate(null) = null WITH protect
 DECLARE PUBLIC::addcsvdata(null) = null WITH protect
 DECLARE PUBLIC::updatecsvdata(null) = null WITH protect
 DECLARE PUBLIC::main(null) = null WITH private
 FREE SET data
 RECORD data(
   1 item[*]
     2 config_type = vc
     2 config_domain = vc
     2 config_name = vc
     2 config_display = vc
     2 config_desc = vc
     2 refurl = vc
     2 addind = i2
     2 updateind = i2
 ) WITH protect
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE reccountinput = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE reccountvalid = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   IF (reccountinput > 0)
    CALL copydatafromrequestinrecord(null)
    CALL evaluaterecordtoaddupdate(null)
    CALL addcsvdata(null)
    CALL updatecsvdata(null)
    COMMIT
    SET readme_data->status = "S"
    SET readme_data->message = "Successfully added rows into the configuration_setting table"
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::copydatafromrequestinrecord(null)
   SET stat = alterlist(data->item,reccountinput)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = reccountinput)
    PLAN (d
     WHERE (requestin->list_0[d.seq].config_name > " "))
    DETAIL
     pos = locateval(idx,1,size(data->item,5),requestin->list_0[d.seq].config_name,data->item[idx].
      config_name)
     IF (pos=0)
      reccountvalid = (reccountvalid+ 1), data->item[reccountvalid].config_type = requestin->list_0[d
      .seq].config_type, data->item[reccountvalid].config_domain = requestin->list_0[d.seq].
      config_domain,
      data->item[reccountvalid].config_name = requestin->list_0[d.seq].config_name, data->item[
      reccountvalid].config_display = requestin->list_0[d.seq].config_display, data->item[
      reccountvalid].config_desc = requestin->list_0[d.seq].config_desc,
      data->item[reccountvalid].refurl = requestin->list_0[d.seq].refurl, data->item[reccountvalid].
      addind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(data->item,reccountvalid)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Fail to copy records from request to data: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::evaluaterecordtoaddupdate(null)
   SET reccountvalid = size(data->item,5)
   SELECT INTO "nl:"
    FROM dcp_config_setting dcs
    WHERE dcs.dcp_config_setting_id > 0.0
    DETAIL
     pos = locateval(idx,1,reccountvalid,dcs.config_name,data->item[idx].config_name)
     IF (pos > 0)
      IF ((dcs.config_desc=data->item[pos].config_desc)
       AND (dcs.config_display=data->item[pos].config_display)
       AND (dcs.config_domain=data->item[pos].config_domain)
       AND (dcs.config_type=data->item[pos].config_type)
       AND (dcs.refurl_txt=data->item[pos].refurl))
       data->item[pos].addind = 0, data->item[pos].updateind = 0
      ELSE
       data->item[pos].addind = 0, data->item[pos].updateind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure reading dcp_conf_setting: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::addcsvdata(null)
   INSERT  FROM dcp_config_setting dcs,
     (dummyt d  WITH seq = reccountvalid)
    SET dcs.dcp_config_setting_id = seq(carenet_seq,nextval), dcs.config_type = data->item[d.seq].
     config_type, dcs.config_domain = data->item[d.seq].config_domain,
     dcs.config_name = data->item[d.seq].config_name, dcs.config_display = data->item[d.seq].
     config_display, dcs.config_desc = data->item[d.seq].config_desc,
     dcs.refurl_txt = data->item[d.seq].refurl, dcs.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcs
     .updt_id = reqinfo->updt_id,
     dcs.updt_applctx = reqinfo->updt_applctx, dcs.updt_task = reqinfo->updt_task, dcs.updt_cnt = 0
    PLAN (d
     WHERE (data->item[d.seq].addind=1))
     JOIN (dcs)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure inserting dcp_conf_setting data: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::updatecsvdata(null)
   UPDATE  FROM dcp_config_setting dcs,
     (dummyt d  WITH seq = reccountvalid)
    SET dcs.config_type = data->item[d.seq].config_type, dcs.config_domain = data->item[d.seq].
     config_domain, dcs.config_display = data->item[d.seq].config_display,
     dcs.config_desc = data->item[d.seq].config_desc, dcs.refurl_txt = data->item[d.seq].refurl, dcs
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dcs.updt_id = reqinfo->updt_id, dcs.updt_applctx = reqinfo->updt_applctx, dcs.updt_task =
     reqinfo->updt_task,
     dcs.updt_cnt = (dcs.updt_cnt+ 1)
    PLAN (d
     WHERE data->item[d.seq].updateind)
     JOIN (dcs
     WHERE (dcs.config_name=data->item[d.seq].config_name))
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure updating dcp_conf_setting data: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(data)
 ENDIF
 FREE SET data
END GO
