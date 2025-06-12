CREATE PROGRAM bmdi_create_param_on_fly:dba
 RECORD reply(
   1 qual[*]
     2 parameter_cd = f8
     2 strt_model_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE gm_code_value0619_def "I"
 SUBROUTINE (gm_i_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_type_cd = ival
     SET gm_i_code_value0619_req->active_type_cdi = 1
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_cd = ival
     SET gm_i_code_value0619_req->data_status_cdi = 1
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     SET gm_i_code_value0619_req->data_status_prsnl_idi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_code_value0619_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_code_value0619_req->qual[iqual].active_ind = ival
     SET gm_i_code_value0619_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_set":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].code_set = ival
     SET gm_i_code_value0619_req->code_seti = 1
    OF "collation_seq":
     SET gm_i_code_value0619_req->qual[iqual].collation_seq = ival
     SET gm_i_code_value0619_req->collation_seqi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->active_dt_tmi = 1
    OF "inactive_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->inactive_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->updt_dt_tmi = 1
    OF "begin_effective_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
    OF "data_status_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->data_status_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     SET gm_i_code_value0619_req->qual[iqual].cdf_meaning = ival
     SET gm_i_code_value0619_req->cdf_meaningi = 1
    OF "display":
     SET gm_i_code_value0619_req->qual[iqual].display = ival
     SET gm_i_code_value0619_req->displayi = 1
    OF "description":
     SET gm_i_code_value0619_req->qual[iqual].description = ival
     SET gm_i_code_value0619_req->descriptioni = 1
    OF "definition":
     SET gm_i_code_value0619_req->qual[iqual].definition = ival
     SET gm_i_code_value0619_req->definitioni = 1
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].cki = ival
     SET gm_i_code_value0619_req->ckii = 1
    OF "concept_cki":
     SET gm_i_code_value0619_req->qual[iqual].concept_cki = ival
     SET gm_i_code_value0619_req->concept_ckii = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 RECORD sim_bmdi_add_device_parameter_req(
   1 qual[1]
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
 RECORD sim_bmdi_add_device_parameter_rep(
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
 DECLARE qual_cnt = i2
 DECLARE lstatus = i2
 DECLARE dparametercd = f8 WITH public, noconstant(0.0)
 DECLARE strt_model_id = f8 WITH public, noconstant(0.0)
 DECLARE parameter_id = f8
 DECLARE addparameter(null) = i4
 DECLARE createparametercodevalue(null) = i4
 SET qual_cnt = size(request->qual,5)
 SET stat = alterlist(reply->qual,qual_cnt)
 SET reply->status_data.status = "F"
 FOR (devicecount = 1 TO qual_cnt)
   SET lstatus = createparametercodevalue(null)
   IF (lstatus != 0)
    SET reply->status_data.status = "Z"
    GO TO exit_script
   ENDIF
   SET lstatus = addparameter(null)
   IF (lstatus != 0)
    SET reply->status_data.status = "Z"
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE createparametercodevalue(null)
   DECLARE lfound = i4 WITH noconstant(0)
   SET parameter_id = 0
   SELECT INTO "nl:"
    FROM lab_instrument li,
     strt_model sm
    PLAN (li
     WHERE (li.service_resource_cd=request->qual[devicecount].service_resource_cd))
     JOIN (sm
     WHERE sm.strt_model_id=li.strt_model_id)
    DETAIL
     strt_model_id = sm.strt_model_id
    WITH nocounter
   ;end select
   SET tempstr = nullterm(cnvtupper(cnvtalphanum(trim(request->qual[devicecount].parameter_name))))
   SET dparametercd = uar_get_code_by("DISPLAYKEY",359573,nullterm(cnvtupper(cnvtalphanum(trim(
        request->qual[devicecount].parameter_name)))))
   CALL echo(build("The Parameter cd is = ",dparametercd))
   CALL echo(build("The Parameter name is =  ",nullterm(cnvtupper(cnvtalphanum(trim(request->qual[
         devicecount].parameter_name))))))
   IF (dparametercd > 0)
    SELECT INTO "nl:"
     FROM strt_bmdi_model_parameter sbmp
     WHERE sbmp.strt_model_id=strt_model_id
      AND sbmp.parameter_cd=dparametercd
     DETAIL
      parameter_id = sbmp.strt_model_parameter_id
     WITH nocounter
    ;end select
    IF (((curqual=0) OR (curqual > 0
     AND tempstr=patstring("GDA*",0))) )
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    SET gm_i_code_value0619_req->code_seti = 1
    SET gm_i_code_value0619_req->displayi = 1
    SET gm_i_code_value0619_req->descriptioni = 1
    SET gm_i_code_value0619_req->definitioni = 1
    SET gm_i_code_value0619_req->collation_seqi = 1
    SET gm_i_code_value0619_req->active_indi = 1
    SET gm_i_code_value0619_req->cdf_meaningi = 1
    SET gm_i_code_value0619_req->data_status_cdi = 1
    SET gm_i_code_value0619_req->active_type_cdi = 1
    SET stat = alterlist(gm_i_code_value0619_req->qual,1)
    SET gm_i_code_value0619_req->qual[1].code_set = 359573
    SET gm_i_code_value0619_req->qual[1].display = request->qual[devicecount].parameter_name
    SET gm_i_code_value0619_req->qual[1].description = request->qual[devicecount].parameter_name
    SET gm_i_code_value0619_req->qual[1].definition = request->qual[devicecount].parameter_name
    SET gm_i_code_value0619_req->qual[1].definition = request->qual[devicecount].parameter_name
    SET gm_i_code_value0619_req->qual[1].collation_seq = 1
    SET gm_i_code_value0619_req->qual[1].active_ind = 1
    SET gm_i_code_value0619_req->qual[1].cdf_meaning = cnvtupper(cnvtalphanum(trim(substring(1,12,
        request->qual[devicecount].parameter_name))))
    SET gm_i_code_value0619_req->qual[1].data_status_cd = uar_get_code_by("MEANING",8,"AUTH")
    SET gm_i_code_value0619_req->qual[1].active_type_cd = uar_get_code_by("MEANING",48,"ACTIVE")
    CALL echo(build("the model id ....",cnvtreal(strt_model_id)))
    EXECUTE gm_i_code_value0619  WITH replace("REQUEST",gm_i_code_value0619_req), replace("REPLY",
     gm_i_code_value0619_rep)
    COMMIT
    IF ((gm_i_code_value0619_rep->status_data.status="S"))
     SET dparametercd = gm_i_code_value0619_rep->qual[1].code_value
     IF (dparametercd <= 0)
      RETURN(1)
     ELSE
      SET reply->status_data.status = "S"
      RETURN(0)
     ENDIF
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addparameter(null)
   IF (parameter_id <= 0)
    SET parameter_id = 0
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"##################;RP0"
     FROM dual
     DETAIL
      parameter_id = cnvtint(nextseqnum)
     WITH nocounter
    ;end select
    INSERT  FROM strt_bmdi_model_parameter sbmp
     SET sbmp.strt_model_parameter_id = cnvtreal(parameter_id), sbmp.strt_model_id = cnvtreal(
       strt_model_id), sbmp.parameter_cd = cnvtreal(dparametercd),
      sbmp.result_type_cd = cnvtreal(request->qual[devicecount].result_type), sbmp.default_alias = "",
      sbmp.units_cd = cnvtreal("0"),
      sbmp.decimal_precision = 0, sbmp.alarm_high = "", sbmp.alarm_low = "",
      sbmp.updt_id = reqinfo->updt_id, sbmp.updt_dt_tm = cnvtdatetime(sysdate), sbmp.updt_task =
      reqinfo->updt_task,
      sbmp.updt_applctx = reqinfo->updt_applctx, sbmp.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET reply->qual[devicecount].strt_model_id = strt_model_id
   SET reply->qual[devicecount].parameter_cd = dparametercd
   CALL echorecord(reply)
   COMMIT
   IF ((request->qual[devicecount].parameter_alias != null)
    AND (request->qual[devicecount].parameter_alias != "")
    AND (request->qual[devicecount].parameter_alias != " "))
    SET sim_bmdi_add_device_parameter_req->qual[1].strt_model_parameter_id = parameter_id
    SET sim_bmdi_add_device_parameter_req->qual[1].device_cd = request->qual[devicecount].
    service_resource_cd
    SET sim_bmdi_add_device_parameter_req->qual[1].result_type_cd = request->qual[devicecount].
    result_type
    SET sim_bmdi_add_device_parameter_req->qual[1].task_assay_cd = request->qual[devicecount].
    task_assay_cd
    SET sim_bmdi_add_device_parameter_req->qual[1].parameter_alias = request->qual[devicecount].
    parameter_alias
    SET sim_bmdi_add_device_parameter_req->qual[1].units_cd = request->qual[devicecount].units_cd
    SET sim_bmdi_add_device_parameter_req->qual[1].alarm_high = request->qual[devicecount].alarm_high
    SET sim_bmdi_add_device_parameter_req->qual[1].alarm_high = request->qual[devicecount].alarm_low
    SET sim_bmdi_add_device_parameter_req->qual[1].event_cd = request->qual[devicecount].event_cd
    EXECUTE sim_bmdi_add_device_parameter  WITH replace("REQUEST",sim_bmdi_add_device_parameter_req),
    replace("REPLY",sim_bmdi_add_device_parameter_rep)
    CALL echorecord(sim_bmdi_add_device_parameter_rep)
   ENDIF
   SET reply->status_data.status = "S"
   RETURN(0)
 END ;Subroutine
#exit_script
END GO
