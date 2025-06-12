CREATE PROGRAM bmdi_copy_device_param_nomen:dba
 RECORD reply(
   1 qual[*]
     2 device_parameter_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_reply_src(
   1 qual[*]
     2 device_parameter_id = f8
 )
 RECORD param_request_dest(
   1 qual[*]
     2 strt_model_parameter_id = f8
     2 device_cd = f8
     2 result_type_cd = f8
     2 task_assay_cd = f8
     2 parameter_alias = vc
     2 units_cd = f8
     2 alarm_high = vc
     2 alarm_low = vc
     2 event_cd = f8
 )
 RECORD get_nomen_request(
   1 device_cd = f8
   1 device_parameter_id = f8
 )
 RECORD get_nomen_reply(
   1 qual[*]
     2 active_ind = i2
     2 device_nomenclature_id = f8
     2 device = vc
     2 device_cd = f8
     2 device_cdf = vc
     2 device_cs = i4
     2 parameter = vc
     2 parameter_cd = f8
     2 parameter_cdf = vc
     2 parameter_cs = i4
     2 device_value = vc
     2 default_value = vc
     2 alpha_translation = vc
     2 strt_model_nomenclature_id = f8
     2 nomenclature_id = f8
     2 updt_id = f8
     2 updt_name = vc
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_applctx = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD add_nomen_request(
   1 qual[*]
     2 device_cd = f8
     2 parameter_cd = f8
     2 device_value = vc
     2 default_value = vc
     2 alpha_translation = vc
     2 nomenclature_id = f8
 )
 RECORD add_nomen_reply(
   1 qual[*]
     2 device_nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE paramcnt = i4
 DECLARE var = i2
 DECLARE k = i2
 DECLARE device_parameter_id = f8
 DECLARE qual_cnt = i2
 SET var = 0
 SET k = 0
 SET paramcnt = 0
 SET device_parameter_id = 0
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SELECT INTO "nl:"
  FROM lab_instrument l1,
   lab_instrument l2
  WHERE l1.strt_model_id=l2.strt_model_id
   AND (l1.service_resource_cd=request->source_device_cd)
   AND (l2.service_resource_cd=request->destination_device_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(build("Gateway models mismatch ..... hence not copying"))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM bmdi_device_parameter bdp
   WHERE (bdp.device_cd=request->source_device_cd)
   DETAIL
    paramcnt += 1, stat = alterlist(param_request_dest->qual,paramcnt), stat = alterlist(
     temp_reply_src->qual,paramcnt),
    param_request_dest->qual[paramcnt].device_cd = request->destination_device_cd, param_request_dest
    ->qual[paramcnt].strt_model_parameter_id = bdp.strt_model_parameter_id, param_request_dest->qual[
    paramcnt].result_type_cd = bdp.result_type_cd,
    param_request_dest->qual[paramcnt].task_assay_cd = bdp.task_assay_cd, param_request_dest->qual[
    paramcnt].parameter_alias = bdp.parameter_alias, param_request_dest->qual[paramcnt].units_cd =
    bdp.units_cd,
    param_request_dest->qual[paramcnt].alarm_high = bdp.alarm_high, param_request_dest->qual[paramcnt
    ].alarm_low = bdp.alarm_low, param_request_dest->qual[paramcnt].event_cd = bdp.event_cd,
    temp_reply_src->qual[paramcnt].device_parameter_id = bdp.device_parameter_id
   WITH nocounter
  ;end select
  IF (paramcnt=0)
   CALL echo(build("Parameters are not built = ",paramcnt))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   CALL echo(build("Total parameters to build = ",paramcnt))
   EXECUTE sim_bmdi_add_device_parameter  WITH replace("REQUEST","PARAM_REQUEST_DEST"), replace(
    "REPLY","temp_reply_src")
   COMMIT
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->copy_nomen_ind=1))
  CALL echo(build("total paramcnt is =======",paramcnt))
  FOR (i = 1 TO paramcnt)
    SET get_nomen_request->device_cd = request->source_device_cd
    SET get_nomen_request->device_parameter_id = temp_reply_src->qual[i].device_parameter_id
    CALL echorecord(get_nomen_request)
    EXECUTE sim_bmdi_get_dvc_nomenclature  WITH replace("REQUEST","GET_NOMEN_REQUEST"), replace(
     "REPLY","GET_NOMEN_REPLY")
    IF ((get_nomen_reply->status_data.status="S"))
     CALL echorecord(get_nomen_reply)
     SET qual_cnt = size(get_nomen_reply->qual,5)
     SELECT INTO "nl:"
      FROM bmdi_device_parameter bdp1,
       bmdi_device_parameter bdp
      PLAN (bdp1
       WHERE (bdp1.device_cd=request->destination_device_cd))
       JOIN (bdp
       WHERE bdp.parameter_alias=bdp1.parameter_alias
        AND (bdp.device_cd=request->source_device_cd)
        AND (bdp.device_parameter_id=get_nomen_request->device_parameter_id))
      DETAIL
       device_parameter_id = bdp1.device_parameter_id
      WITH nocounter
     ;end select
     CALL echo(build("device_parameter_id is =======",device_parameter_id))
     CALL echo(build("Total nomenclatures to copy = ",qual_cnt))
     FOR (k = 1 TO qual_cnt)
       SET stat = alterlist(add_nomen_request->qual,k)
       SET add_nomen_request->qual[k].device_cd = request->destination_device_cd
       SET add_nomen_request->qual[k].parameter_cd = device_parameter_id
       SET add_nomen_request->qual[k].device_value = get_nomen_reply->qual[k].device_value
       SET add_nomen_request->qual[k].default_value = get_nomen_reply->qual[k].default_value
       SET add_nomen_request->qual[k].alpha_translation = get_nomen_reply->qual[k].alpha_translation
       SET add_nomen_request->qual[k].nomenclature_id = get_nomen_reply->qual[k].
       strt_model_nomenclature_id
     ENDFOR
     CALL echorecord(add_nomen_request)
     EXECUTE sim_bmdi_add_dvc_nomenclature  WITH replace("REQUEST","ADD_NOMEN_REQUEST"), replace(
      "REPLY","ADD_NOMEN_REPLY")
     COMMIT
     CALL echorecord(add_nomen_reply)
     SET reply->status_data.status = add_nomen_reply->status_data.status
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
