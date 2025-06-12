CREATE PROGRAM dcp_confcomp_rel_data_import:dba
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
 SET readme_data->message = "Readme Failed: Starting <dcp_confcomp_rel_data_import.prg> script"
 FREE SET data
 RECORD data(
   1 item[*]
     2 comp_name = vc
     2 config_name = vc
     2 dcp_config_comp_id = f8
     2 dcp_config_setting_id = f8
     2 skip_insert_ind = i2
 )
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE reccountinput = i4 WITH constant(size(requestin->list_0,5))
 DECLARE reccountvalid = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 IF (reccountinput > 0)
  SET stat = alterlist(data->item,reccountinput)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = reccountinput)
   PLAN (d
    WHERE (requestin->list_0[d.seq].comp_name > " ")
     AND (requestin->list_0[d.seq].config_name > " "))
   DETAIL
    pos = 0
    FOR (idx = 1 TO reccountvalid)
      IF ((requestin->list_0[d.seq].comp_name=data->item[idx].comp_name)
       AND (requestin->list_0[d.seq].config_name=data->item[idx].config_name))
       pos = idx, idx = reccountvalid
      ENDIF
    ENDFOR
    IF (pos=0)
     reccountvalid = (reccountvalid+ 1), data->item[reccountvalid].comp_name = requestin->list_0[d
     .seq].comp_name, data->item[reccountvalid].config_name = requestin->list_0[d.seq].config_name
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
  SELECT INTO "nl:"
   FROM dcp_config_comp dcc,
    dcp_config_setting dcs,
    dcp_config_comp_reltn dccr
   WHERE dcc.dcp_config_comp_id=dccr.dcp_config_comp_id
    AND dcs.dcp_config_setting_id=dccr.dcp_config_setting_id
   DETAIL
    pos = 0
    FOR (idx = 1 TO reccountvalid)
      IF ((dcc.comp_name=data->item[idx].comp_name)
       AND (dcs.config_name=data->item[idx].config_name))
       pos = idx, idx = reccountvalid
      ENDIF
    ENDFOR
    IF (pos > 0)
     data->item[pos].skip_insert_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure reading dcp_config_comp_reltn: ",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM dcp_config_comp dcc
   WHERE dcc.dcp_config_comp_id > 0.0
   DETAIL
    pos = locateval(idx,1,reccountvalid,dcc.comp_name,data->item[idx].comp_name)
    WHILE (pos > 0)
     data->item[pos].dcp_config_comp_id = dcc.dcp_config_comp_id,pos = locateval(idx,(1+ pos),
      reccountvalid,dcc.comp_name,data->item[idx].comp_name)
    ENDWHILE
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure reading dcp_config_comp: ",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM dcp_config_setting dcs
   WHERE dcs.dcp_config_setting_id > 0.0
   DETAIL
    pos = locateval(idx,1,reccountvalid,dcs.config_name,data->item[idx].config_name)
    WHILE (pos > 0)
     data->item[pos].dcp_config_setting_id = dcs.dcp_config_setting_id,pos = locateval(idx,(1+ pos),
      reccountvalid,dcs.config_name,data->item[idx].config_name)
    ENDWHILE
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure reading dcp_config_setting: ",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM dcp_config_comp_reltn dccr,
    (dummyt d  WITH seq = reccountvalid)
   SET dccr.dcp_config_comp_reltn_id = seq(carenet_seq,nextval), dccr.dcp_config_comp_id = data->
    item[d.seq].dcp_config_comp_id, dccr.dcp_config_setting_id = data->item[d.seq].
    dcp_config_setting_id,
    dccr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dccr.updt_id = reqinfo->updt_id, dccr
    .updt_applctx = reqinfo->updt_applctx,
    dccr.updt_task = reqinfo->updt_task, dccr.updt_cnt = 0
   PLAN (d
    WHERE (data->item[d.seq].skip_insert_ind=0)
     AND (data->item[d.seq].dcp_config_comp_id > 0.0)
     AND (data->item[d.seq].dcp_config_setting_id > 0.0))
    JOIN (dccr)
   WITH nocounter
  ;end insert
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting dcp_config_comp_reltn data: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully added rows into the dcp_config_comp_reltn table"
#exit_script
 FREE SET data
END GO
