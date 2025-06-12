CREATE PROGRAM dcp_conf_comp_data_import:dba
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
 SET readme_data->message = "Readme Failed: Starting dcp_conf_comp_data_import script"
 FREE SET data
 RECORD data(
   1 item[*]
     2 dcp_config_comp_id = f8
     2 comp_name = vc
     2 comp_display = vc
     2 comp_desc = vc
     2 comp_ind = i2
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
   FROM (dummyt d  WITH seq = value(reccountinput))
   PLAN (d
    WHERE (requestin->list_0[d.seq].comp_name > " "))
   DETAIL
    pos = locateval(idx,1,size(data->item,5),requestin->list_0[d.seq].comp_name,data->item[idx].
     comp_name)
    IF (pos=0)
     reccountvalid = (reccountvalid+ 1), data->item[reccountvalid].comp_name = requestin->list_0[d
     .seq].comp_name, data->item[reccountvalid].comp_display = requestin->list_0[d.seq].comp_display,
     data->item[reccountvalid].comp_desc = requestin->list_0[d.seq].comp_desc
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
   FROM dcp_config_comp dcc
   WHERE dcc.dcp_config_comp_id > 0.0
   DETAIL
    pos = locateval(idx,1,reccountvalid,dcc.comp_name,data->item[idx].comp_name)
    IF (pos > 0)
     data->item[pos].skip_insert_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure reading dcp_config_comp: ",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM dcp_config_comp dcc,
    (dummyt d  WITH seq = reccountvalid)
   SET dcc.dcp_config_comp_id = cnvtreal(seq(carenet_seq,nextval)), dcc.comp_name = data->item[d.seq]
    .comp_name, dcc.comp_display = data->item[d.seq].comp_display,
    dcc.comp_desc = data->item[d.seq].comp_desc, dcc.comp_ind = data->item[d.seq].comp_ind, dcc
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    dcc.updt_id = reqinfo->updt_id, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_task = reqinfo
    ->updt_task,
    dcc.updt_cnt = 0
   PLAN (d
    WHERE (data->item[d.seq].skip_insert_ind=0))
    JOIN (dcc)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure inserting dcp_config_component data: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully inserted data into the dcp_config_component table"
#exit_script
 FREE SET data
END GO
