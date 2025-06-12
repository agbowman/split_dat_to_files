CREATE PROGRAM bmdi_lab_type_r_import:dba
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
 DECLARE count = i4
 DECLARE index = i4
 DECLARE serrormsg = vc WITH public, noconstant("")
 DECLARE temp_cd = f8 WITH public, noconstant(0.0)
 SET count = 0
 SET index = 0
 SET readme_data->status = "F"
 SET serrormsg = "Failure - an error occured while importing data to the strt_model_lab_type_r table"
 SET count = size(requestin->list_0,5)
 FOR (index = 1 TO count)
   IF (textlen(trim(requestin->list_0[index].lab_type_cdf)) > 0)
    SET temp_cd = 0.0
    SELECT INTO "nl:"
     cv.code_value, cv.cdf_meaning
     FROM code_value cv
     WHERE code_set=31520
      AND cv.cdf_meaning=trim(cnvtstring(requestin->list_0[index].lab_type_cdf))
     DETAIL
      temp_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET requestin->list_0[index].lab_type_cd = cnvtstring(temp_cd)
    ELSE
     SET requestin->list_0[index].lab_type_cd = cnvtstring(0)
    ENDIF
   ELSE
    SET requestin->list_0[index].lab_type_cd = cnvtstring(0)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  smltr.strt_model_id, smltr.lab_type_cd
  FROM strt_model_lab_type_r smltr,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (smltr
   WHERE smltr.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  DETAIL
   requestin->list_0[d.seq].exists_ind = cnvtstring(1)
  WITH nocounter
 ;end select
 IF (error(serrormsg,0) != 0)
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM strt_model_lab_type_r smltr,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smltr.strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id), smltr.lab_type_cd =
   cnvtreal(requestin->list_0[d.seq].lab_type_cd), smltr.updt_id = reqinfo->updt_id,
   smltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), smltr.updt_task = reqinfo->updt_task, smltr
   .updt_applctx = reqinfo->updt_applctx,
   smltr.updt_cnt = cnvtint((smltr.updt_cnt+ 1))
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(1)))
   JOIN (smltr
   WHERE smltr.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  WITH nocounter
 ;end update
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 INSERT  FROM strt_model_lab_type_r smltr,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smltr.strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id), smltr.lab_type_cd =
   cnvtreal(requestin->list_0[d.seq].lab_type_cd), smltr.updt_id = reqinfo->updt_id,
   smltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), smltr.updt_task = reqinfo->updt_task, smltr
   .updt_applctx = reqinfo->updt_applctx,
   smltr.updt_cnt = 0
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(0)))
   JOIN (smltr)
  WITH nocounter
 ;end insert
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success - all strt_model_lab_type_r rows inserted and update successfully."
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
