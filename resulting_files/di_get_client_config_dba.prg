CREATE PROGRAM di_get_client_config:dba
 SET trace = nocost
 SET message = noinformation
 RECORD reply(
   1 config_list[*]
     2 di_client_config_id = f8
     2 service_resource_cd = f8
     2 device_name = c256
     2 subscription_name = c256
     2 oper_mode_flag = c1
     2 order_service = i2
     2 lab_type_cd = f8
     2 lab_type_meaning = c12
     2 edc_service_type_cd = f8
     2 edc_service_type_meaning = c12
     2 result_format_cd = f8
     2 result_format_meaning = c12
     2 log_flag = i2
     2 active_ind = i2
     2 edc_environment = c256
     2 sample_period = i4
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
     2 login_loc_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i4
 SET count = 0
 SET robo_inlet = 0.0
 SET stat = uar_get_meaning_by_codeset(2068,"ROBO_INLET",1,robo_inlet)
 IF ((request->service_resource_cd > 0))
  CALL echo("service_resource defined")
  SELECT INTO "nl:"
   FROM di_client_config dcc,
    lab_instrument li,
    service_resource_lab_type_r srl
   PLAN (dcc
    WHERE (dcc.service_resource_cd=request->service_resource_cd)
     AND (dcc.active_ind >= request->active_ind))
    JOIN (li
    WHERE li.service_resource_cd=dcc.service_resource_cd)
    JOIN (srl
    WHERE srl.service_resource_cd=li.service_resource_cd)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->config_list,(count+ 9))
    ENDIF
    reply->config_list[count].di_client_config_id = dcc.di_client_config_id, reply->config_list[count
    ].service_resource_cd = dcc.service_resource_cd, reply->config_list[count].device_name = dcc
    .device_name,
    reply->config_list[count].subscription_name = dcc.subscription_name, reply->config_list[count].
    edc_environment = dcc.edc_environment, reply->config_list[count].oper_mode_flag = li.oper_mode,
    reply->config_list[count].lab_type_cd = srl.lab_type_cd, reply->config_list[count].
    lab_type_meaning = uar_get_code_meaning(srl.lab_type_cd), reply->config_list[count].
    edc_service_type_cd = dcc.edc_service_type_cd,
    reply->config_list[count].edc_service_type_meaning = uar_get_code_meaning(dcc.edc_service_type_cd
     ), reply->config_list[count].result_format_cd = li.result_format_cd, reply->config_list[count].
    result_format_meaning = uar_get_code_meaning(li.result_format_cd)
    IF (li.station="OSVC")
     reply->config_list[count].order_service = 1
    ELSE
     reply->config_list[count].order_service = 0
    ENDIF
    reply->config_list[count].log_flag = li.log_flag, reply->config_list[count].active_ind = dcc
    .active_ind, reply->config_list[count].updt_id = dcc.updt_id,
    reply->config_list[count].updt_dt_tm = dcc.updt_dt_tm, reply->config_list[count].updt_task = dcc
    .updt_task, reply->config_list[count].updt_cnt = dcc.updt_cnt,
    reply->config_list[count].updt_applctx = dcc.updt_applctx
   FOOT REPORT
    stat = alterlist(reply->config_list,count)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM di_client_config dcc,
    lab_instrument li,
    service_resource_lab_type_r srl,
    robotics_items ri
   PLAN (dcc
    WHERE dcc.service_resource_cd > 0
     AND (dcc.active_ind >= request->active_ind))
    JOIN (li
    WHERE li.service_resource_cd=dcc.service_resource_cd)
    JOIN (srl
    WHERE srl.service_resource_cd=li.service_resource_cd)
    JOIN (ri
    WHERE ri.robotics_service_resource_cd=outerjoin(dcc.service_resource_cd)
     AND ri.robotics_item_type_cd=outerjoin(robo_inlet))
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->config_list,count), reply->config_list[count].
    di_client_config_id = dcc.di_client_config_id,
    reply->config_list[count].service_resource_cd = dcc.service_resource_cd, reply->config_list[count
    ].device_name = dcc.device_name, reply->config_list[count].subscription_name = dcc
    .subscription_name,
    reply->config_list[count].edc_environment = dcc.edc_environment, reply->config_list[count].
    oper_mode_flag = li.oper_mode, reply->config_list[count].lab_type_cd = srl.lab_type_cd,
    reply->config_list[count].lab_type_meaning = uar_get_code_meaning(srl.lab_type_cd), reply->
    config_list[count].edc_service_type_cd = dcc.edc_service_type_cd, reply->config_list[count].
    edc_service_type_meaning = uar_get_code_meaning(dcc.edc_service_type_cd),
    reply->config_list[count].result_format_cd = li.result_format_cd, reply->config_list[count].
    result_format_meaning = uar_get_code_meaning(li.result_format_cd)
    IF (li.station="OSVC")
     reply->config_list[count].order_service = 1
    ELSE
     reply->config_list[count].order_service = 0
    ENDIF
    reply->config_list[count].log_flag = li.log_flag, reply->config_list[count].active_ind = dcc
    .active_ind, reply->config_list[count].sample_period = dcc.sample_period,
    reply->config_list[count].updt_id = dcc.updt_id, reply->config_list[count].updt_dt_tm = dcc
    .updt_dt_tm, reply->config_list[count].updt_task = dcc.updt_task,
    reply->config_list[count].updt_cnt = dcc.updt_cnt, reply->config_list[count].updt_applctx = dcc
    .updt_applctx, reply->config_list[count].login_loc_cd = ri.login_loc_cd
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
 IF (count=0)
  SET reply->status_data.status = "Z"
  CALL echo(build("status_data->status = ",reply->status_data.status))
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("status_data->status = ",reply->status_data.status))
 ENDIF
END GO
