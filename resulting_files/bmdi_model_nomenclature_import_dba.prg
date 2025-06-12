CREATE PROGRAM bmdi_model_nomenclature_import:dba
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
 DECLARE serrormsg = vc WITH public, noconstant("")
 SET readme_data->status = "F"
 SET serrormsg =
 "Failure - an error occured while importing data to the strt_bmdi_model_nomenclature table"
 SELECT INTO "nl:"
  sbmn.strt_model_nomenclature_id, sbmn.strt_model_parameter_id, sbmn.strt_model_id
  FROM strt_bmdi_model_nomenclature sbmn,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (sbmn
   WHERE sbmn.strt_model_nomenclature_id=cnvtreal(requestin->list_0[d.seq].strt_model_nomenclature_id
    )
    AND sbmn.strt_model_parameter_id=cnvtreal(requestin->list_0[d.seq].strt_model_parameter_id)
    AND sbmn.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  DETAIL
   requestin->list_0[d.seq].exists_ind = cnvtstring(1)
  WITH nocounter
 ;end select
 IF (error(serrormsg,0) != 0)
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM strt_bmdi_model_nomenclature sbmn,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET sbmn.strt_model_nomenclature_id = cnvtreal(requestin->list_0[d.seq].strt_model_nomenclature_id),
   sbmn.strt_model_parameter_id = cnvtreal(requestin->list_0[d.seq].strt_model_parameter_id), sbmn
   .strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id),
   sbmn.default_value = requestin->list_0[d.seq].default_value, sbmn.alpha_translation = requestin->
   list_0[d.seq].alpha_translation, sbmn.updt_id = reqinfo->updt_id,
   sbmn.updt_dt_tm = cnvtdatetime(curdate,curtime3), sbmn.updt_task = reqinfo->updt_task, sbmn
   .updt_applctx = reqinfo->updt_applctx,
   sbmn.updt_cnt = cnvtint((sbmn.updt_cnt+ 1))
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(1)))
   JOIN (sbmn
   WHERE sbmn.strt_model_nomenclature_id=cnvtreal(requestin->list_0[d.seq].strt_model_nomenclature_id
    )
    AND sbmn.strt_model_parameter_id=cnvtreal(requestin->list_0[d.seq].strt_model_parameter_id)
    AND sbmn.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  WITH nocounter
 ;end update
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 INSERT  FROM strt_bmdi_model_nomenclature sbmn,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET sbmn.strt_model_nomenclature_id = cnvtreal(requestin->list_0[d.seq].strt_model_nomenclature_id),
   sbmn.strt_model_parameter_id = cnvtreal(requestin->list_0[d.seq].strt_model_parameter_id), sbmn
   .strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id),
   sbmn.default_value = requestin->list_0[d.seq].default_value, sbmn.alpha_translation = requestin->
   list_0[d.seq].alpha_translation, sbmn.updt_id = reqinfo->updt_id,
   sbmn.updt_dt_tm = cnvtdatetime(curdate,curtime3), sbmn.updt_task = reqinfo->updt_task, sbmn
   .updt_applctx = reqinfo->updt_applctx,
   sbmn.updt_cnt = 0
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(0)))
   JOIN (sbmn)
  WITH nocounter
 ;end insert
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success - all strt_bmdi_model_nomenclature rows inserted and update successfully."
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
 COMMIT
END GO
