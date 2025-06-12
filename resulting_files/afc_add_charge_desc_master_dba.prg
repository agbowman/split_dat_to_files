CREATE PROGRAM afc_add_charge_desc_master:dba
 DECLARE afc_add_charge_desc_master = vc WITH constant("CHARGSVC-12791.001")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_desc_master_qual = i4
    1 charge_desc_master[*]
      2 cdm_id = f8
      2 cdm_code = vc
      2 description = vc
      2 service_type = i2
      2 logical_domain_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 updt_applctx = f8
      2 updt_cnt = i4
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 updt_task = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(getcodevalue(48,"ACTIVE",0))
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echo(build2("CS48_ACTIVE_CD : ",cs48_active_cd))
 ENDIF
 DECLARE table_name = vc WITH protect, constant("CHARGE_DESC_MASTER")
 DECLARE listsize = i4 WITH protect, noconstant(0)
 IF (validate(request->charge_desc_master))
  SET listsize = size(request->charge_desc_master,5)
 ENDIF
 SET stat = alterlist(reply->charge_desc_master,listsize)
 SET reply->status_data.status = "F"
 SET reply->charge_desc_master_qual = 0
 CALL insertintochargedescmaster(listsize)
 SET stat = alterlist(reply->charge_desc_master,reply->charge_desc_master_qual)
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
 GO TO end_program
 SUBROUTINE (insertintochargedescmaster(listsize=i4) =null)
   DECLARE added_dt_tm = dq8 WITH protect
   DECLARE nextseqnbr = f8 WITH protect, noconstant(0)
   DECLARE updtid = f8 WITH protect
   DECLARE updtapplctx = f8 WITH protect
   DECLARE updttask = i4 WITH protect
   IF (validate(reqinfo->updt_id,1) <= 0)
    SET updtid = 0
   ELSE
    SET updtid = validate(reqinfo->updt_id,0)
   ENDIF
   IF (validate(reqinfo->updt_applctx,1) <= 0)
    SET updtapplctx = 0
   ELSE
    SET updtapplctx = validate(reqinfo->updt_applctx,0)
   ENDIF
   IF (validate(reqinfo->updt_task,1) <= 0)
    SET updttask = 0
   ELSE
    SET updttask = validate(reqinfo->updt_task,0)
   ENDIF
   IF (listsize > 0)
    FOR (loopcnt = 1 TO listsize)
      SET added_dt_tm = cnvtdatetime(sysdate)
      SELECT INTO "nl:"
       y = seq(price_sched_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        nextseqnbr = cnvtreal(y)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       IF (validate(debug,- (1)) > 0)
        CALL echo(build2("nextSeqNbr is : ",nextseqnbr))
       ENDIF
      ENDIF
      INSERT  FROM charge_desc_master c
       SET c.active_ind = 1, c.active_status_cd = cs48_active_cd, c.active_status_dt_tm =
        cnvtdatetime(added_dt_tm),
        c.active_status_prsnl_id = updtid, c.cdm_code_txt = request->charge_desc_master[loopcnt].
        cdm_code, c.charge_desc_master_id = nextseqnbr,
        c.description = request->charge_desc_master[loopcnt].description, c.logical_domain_id =
        request->charge_desc_master[loopcnt].logical_domain_id, c.service_type_flag =
        IF ((request->charge_desc_master[loopcnt].service_type=0)) null
        ELSE request->charge_desc_master[loopcnt].service_type
        ENDIF
        ,
        c.updt_applctx = updtapplctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(added_dt_tm),
        c.updt_id = updtid, c.updt_task = updttask
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = insert_error
       IF (validate(debug,- (1)) > 0)
        CALL echo(build2("failed to insert item #",loopcnt))
       ENDIF
       RETURN
      ELSE
       IF (validate(debug,- (1)) > 0)
        CALL echo(build2("successfully inserted item #",loopcnt))
       ENDIF
       SET reply->charge_desc_master_qual = loopcnt
       SET reply->charge_desc_master[loopcnt].active_ind = 1
       SET reply->charge_desc_master[loopcnt].active_status_cd = cs48_active_cd
       SET reply->charge_desc_master[loopcnt].active_status_dt_tm = cnvtdatetime(added_dt_tm)
       SET reply->charge_desc_master[loopcnt].active_status_prsnl_id = updtid
       SET reply->charge_desc_master[loopcnt].cdm_id = nextseqnbr
       SET reply->charge_desc_master[loopcnt].cdm_code = request->charge_desc_master[loopcnt].
       cdm_code
       SET reply->charge_desc_master[loopcnt].description = request->charge_desc_master[loopcnt].
       description
       SET reply->charge_desc_master[loopcnt].service_type = request->charge_desc_master[loopcnt].
       service_type
       SET reply->charge_desc_master[loopcnt].logical_domain_id = request->charge_desc_master[loopcnt
       ].logical_domain_id
       SET reply->charge_desc_master[loopcnt].updt_applctx = updtapplctx
       SET reply->charge_desc_master[loopcnt].updt_cnt = 0
       SET reply->charge_desc_master[loopcnt].updt_dt_tm = cnvtdatetime(added_dt_tm)
       SET reply->charge_desc_master[loopcnt].updt_id = updtid
       SET reply->charge_desc_master[loopcnt].updt_task = updttask
      ENDIF
    ENDFOR
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echo(build2("reply.charge_desc_master size = ",size(reply->charge_desc_master,5)))
    CALL echo(build2("reply.charge_desc_master_qual = ",reply->charge_desc_master_qual))
   ENDIF
 END ;Subroutine
#exit_script
#end_program
END GO
