CREATE PROGRAM di_manage_client_config:dba
 SET trace = nocost
 SET message = noinformation
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE x = i4
 DECLARE new_config_id = f8
 DECLARE failed_status = i4
 DECLARE upcnt = i4
 DECLARE edc_service_type_cd = f8
 DECLARE lab_type_cd = f8
 DECLARE sr_lab_type_cd = f8
 DECLARE sample_period_exists = i4
 DECLARE di_client_config_id = f8
 SET sample_period_exists = checkdic("DI_CLIENT_CONFIG.SAMPLE_PERIOD","A",0)
 SET failed_status = 2
 FOR (x = 1 TO size(request->config_list,5))
   IF ((request->config_list[x].edc_service_type_cd=0))
    SET edc_service_type_cd = uar_get_code_by("MEANING",4002001,nullterm(request->config_list[x].
      edc_service_type))
   ELSE
    SET edc_service_type_cd = request->config_list[x].edc_service_type_cd
   ENDIF
   IF ((request->config_list[x].operation="0"))
    SET lab_type_cd = uar_get_code_by("MEANING",31520,nullterm(request->config_list[x].lab_type))
    CALL check_config(0)
   ELSEIF ((request->config_list[x].operation="1"))
    CALL update_config(0)
   ELSEIF ((request->config_list[x].operation="2"))
    CALL delete_config(0)
   ELSEIF ((request->config_list[x].operation="3"))
    CALL check_duplicate_guid(0)
   ENDIF
   IF (failed_status > 0)
    GO TO checkerror
   ENDIF
 ENDFOR
 GO TO checkerror
 SUBROUTINE check_config(a)
  SELECT INTO "nl:"
   FROM di_client_config dcc
   PLAN (dcc
    WHERE (dcc.device_name=request->config_list[x].device_name)
     AND (dcc.service_resource_cd=request->config_list[x].service_resource_cd)
     AND dcc.active_ind=0)
   DETAIL
    di_client_config_id = dcc.di_client_config_id
   WITH nocounter
  ;end select
  IF (curqual=1)
   IF (sample_period_exists=0)
    UPDATE  FROM di_client_config dcc
     SET dcc.active_ind = 1, dcc.service_resource_cd = request->config_list[x].service_resource_cd,
      dcc.device_name = request->config_list[x].device_name,
      dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
      request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
      dcc.active_ind = 1, dcc.updt_cnt = (upcnt+ 1), dcc.updt_dt_tm = cnvtdatetime(sysdate),
      dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx
     WHERE dcc.di_client_config_id=di_client_config_id
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET failed_status = 0
    ENDIF
   ELSE
    UPDATE  FROM di_client_config dcc
     SET dcc.active_ind = 1, dcc.service_resource_cd = request->config_list[x].service_resource_cd,
      dcc.device_name = request->config_list[x].device_name,
      dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
      request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
      dcc.sample_period = request->config_list[x].sample_period, dcc.active_ind = 1, dcc.updt_cnt = (
      upcnt+ 1),
      dcc.updt_dt_tm = cnvtdatetime(sysdate), dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx =
      reqinfo->updt_applctx
     WHERE dcc.di_client_config_id=di_client_config_id
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual=1)
    SET failed_status = 0
   ENDIF
  ELSE
   CALL insert_config(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE update_config(a)
  SELECT INTO "nl:"
   FROM di_client_config dcc
   PLAN (dcc
    WHERE (dcc.di_client_config_id=request->config_list[x].di_client_config_id))
   DETAIL
    upcnt = dcc.updt_cnt
   WITH nocounter
  ;end select
  IF (curqual=1)
   IF (sample_period_exists=0)
    UPDATE  FROM di_client_config dcc
     SET dcc.active_ind = 1, dcc.service_resource_cd = request->config_list[x].service_resource_cd,
      dcc.device_name = request->config_list[x].device_name,
      dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
      request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
      dcc.updt_dt_tm = cnvtdatetime(sysdate), dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx =
      reqinfo->updt_applctx,
      dcc.updt_cnt = (upcnt+ 1)
     WHERE (dcc.di_client_config_id=request->config_list[x].di_client_config_id)
     WITH nocounter
    ;end update
    CALL echo(build("upd curqual: ",curqual))
    IF (curqual=1)
     SET failed_status = 0
    ELSE
     CALL insert_config(0)
    ENDIF
   ELSE
    UPDATE  FROM di_client_config dcc
     SET dcc.active_ind = 1, dcc.service_resource_cd = request->config_list[x].service_resource_cd,
      dcc.device_name = request->config_list[x].device_name,
      dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
      request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
      dcc.sample_period = request->config_list[x].sample_period, dcc.updt_dt_tm = cnvtdatetime(
       sysdate), dcc.updt_task = reqinfo->updt_task,
      dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = (upcnt+ 1)
     WHERE (dcc.di_client_config_id=request->config_list[x].di_client_config_id)
     WITH nocounter
    ;end update
    CALL echo(build("upd curqual: ",curqual))
    IF (curqual=1)
     SET failed_status = 0
    ELSE
     CALL insert_config(0)
    ENDIF
   ENDIF
  ELSE
   SET failed_status = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_config(a)
  SELECT INTO "nl:"
   FROM di_client_config dcc
   PLAN (dcc
    WHERE (dcc.device_name=request->config_list[x].device_name)
     AND (dcc.subscription_name=request->config_list[x].subscription_name)
     AND dcc.active_ind=1)
   DETAIL
    di_client_config_id = dcc.di_client_config_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    FROM di_client_config dcc
    PLAN (dcc
     WHERE (dcc.device_name=request->config_list[x].device_name)
      AND (dcc.service_resource_cd=request->config_list[x].service_resource_cd)
      AND dcc.active_ind=1)
    DETAIL
     di_client_config_id = dcc.di_client_config_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      new_config_id = nextseqnum
     WITH nocounter
    ;end select
    IF (new_config_id > 0)
     CALL echo(build(" Inserting row: ",new_config_id))
     IF (sample_period_exists=0)
      INSERT  FROM di_client_config dcc
       SET dcc.di_client_config_id = new_config_id, dcc.service_resource_cd = request->config_list[x]
        .service_resource_cd, dcc.device_name = request->config_list[x].device_name,
        dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
        request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
        dcc.active_ind = 1, dcc.updt_id = reqinfo->updt_id, dcc.updt_dt_tm = cnvtdatetime(sysdate),
        dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt =
        0
       PLAN (dcc)
       WITH nocounter
      ;end insert
      IF (curqual=1)
       SET failed_status = 0
       CALL checkadd_labtype(0)
      ENDIF
     ELSE
      INSERT  FROM di_client_config dcc
       SET dcc.di_client_config_id = new_config_id, dcc.service_resource_cd = request->config_list[x]
        .service_resource_cd, dcc.device_name = request->config_list[x].device_name,
        dcc.subscription_name = request->config_list[x].subscription_name, dcc.edc_environment =
        request->config_list[x].edc_environment, dcc.edc_service_type_cd = edc_service_type_cd,
        dcc.active_ind = 1, dcc.sample_period = request->config_list[x].sample_period, dcc.updt_id =
        reqinfo->updt_id,
        dcc.updt_dt_tm = cnvtdatetime(sysdate), dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx
         = reqinfo->updt_applctx,
        dcc.updt_cnt = 0
       PLAN (dcc)
       WITH nocounter
      ;end insert
      IF (curqual=1)
       SET failed_status = 0
       CALL checkadd_labtype(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    CALL echo(build("Multiple active row exists for device name ",request->config_list[x].device_name
      ))
   ENDIF
  ELSE
   CALL echo(build("Multiple active row exists for device name and subscription_name.",request->
     config_list[x].device_name))
  ENDIF
 END ;Subroutine
 SUBROUTINE checkadd_labtype(a)
  SELECT INTO "nl:"
   FROM service_resource_lab_type_r sr
   PLAN (sr
    WHERE (sr.service_resource_cd=request->config_list[x].service_resource_cd))
   DETAIL
    sr_labtype_cd = sr.lab_type_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM service_resource_lab_type_r srlt
    SET srlt.service_resource_cd = request->config_list[x].service_resource_cd, srlt.lab_type_cd =
     lab_type_cd, srlt.updt_id = reqinfo->updt_id,
     srlt.updt_dt_tm = cnvtdatetime(sysdate), srlt.updt_task = reqinfo->updt_task, srlt.updt_applctx
      = reqinfo->updt_applctx,
     srlt.updt_cnt = 0
    PLAN (srlt)
    WITH nocounter
   ;end insert
   IF (curqual=1)
    SET failed_status = 0
   ELSE
    SET failed_status = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE delete_config(a)
  SELECT INTO "nl:"
   FROM di_client_config dcc
   PLAN (dcc
    WHERE (dcc.di_client_config_id=request->config_list[x].di_client_config_id))
   DETAIL
    upcnt = dcc.updt_cnt
   WITH nocounter
  ;end select
  IF (curqual=1)
   UPDATE  FROM di_client_config dcc
    SET dcc.active_ind = 0, dcc.updt_cnt = (upcnt+ 1), dcc.updt_id = reqinfo->updt_id,
     dcc.updt_dt_tm = cnvtdatetime(sysdate), dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx =
     reqinfo->updt_applctx
    WHERE (dcc.di_client_config_id=request->config_list[x].di_client_config_id)
    WITH nocounter
   ;end update
   IF (curqual=1)
    SET failed_status = 0
   ENDIF
  ELSE
   SET failed_status = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE check_duplicate_guid(a)
  SELECT INTO "nl:"
   FROM di_client_config dcc,
    service_resource sr
   PLAN (dcc)
    JOIN (sr
    WHERE dcc.service_resource_cd=sr.service_resource_cd
     AND (dcc.device_name=request->config_list[x].device_name)
     AND (dcc.subscription_name=request->config_list[x].subscription_name)
     AND (dcc.edc_service_type_cd=request->config_list[x].edc_service_type_cd)
     AND (dcc.service_resource_cd != request->config_list[x].service_resource_cd)
     AND dcc.active_ind=1
     AND (sr.organization_id=
    (SELECT
     organization_id
     FROM service_resource
     WHERE (service_resource_cd=request->config_list[x].service_resource_cd))))
   DETAIL
    di_client_config_id = dcc.di_client_config_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed_status = 0
  ELSEIF (curqual > 0)
   SET failed_status = 2
  ENDIF
 END ;Subroutine
#checkerror
 IF (failed_status=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failed_status=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
