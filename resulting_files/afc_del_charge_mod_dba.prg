CREATE PROGRAM afc_del_charge_mod:dba
 IF ("Z"=validate(afc_del_charge_mod_vrsn,"Z"))
  DECLARE afc_del_charge_mod_vrsn = vc WITH noconstant("RCBACM-17802.008")
 ENDIF
 SET afc_del_charge_mod_vrsn = "RCBACM-17802.008"
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
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
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_mod_qual = i2
    1 charge_mod[*]
      2 charge_mod_id = f8
      2 charge_item_id = f8
      2 action_type = c3
      2 charge_mod_type_cd = f8
      2 field1_id = f8
      2 field2_id = f8
      2 field3_id = f8
      2 field6 = vc
      2 field7 = vc
      2 nomen_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->charge_mod_qual
  SET reply->charge_mod_qual = request->charge_mod_qual
 ENDIF
 RECORD cmreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cmrep(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE active_code = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,active_code)
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE_MOD"
 CALL del_charge_mod(action_begin,action_end)
 CALL del_nomen_entity_reltn(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
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
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE del_charge_mod(del_begin,del_end)
   DECLARE chargemodcnt = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   FOR (x = del_begin TO del_end)
     IF ((request->charge_mod[x].action_type="DEL"))
      SET chargemodcnt += 1
      SET stat = alterlist(cmreq->objarray,chargemodcnt)
      SELECT INTO "nl:"
       FROM charge_mod cm
       WHERE (cm.charge_mod_id=request->charge_mod[x].charge_mod_id)
       DETAIL
        cmreq->objarray[chargemodcnt].action_type = "DEL", cmreq->objarray[chargemodcnt].
        charge_item_id = cm.charge_item_id, cmreq->objarray[chargemodcnt].charge_mod_id = request->
        charge_mod[x].charge_mod_id,
        cmreq->objarray[chargemodcnt].active_status_cd = nullcheck(active_code,request->charge_mod[x]
         .active_status_cd,
         IF ((request->charge_mod[x].active_status_cd=0)) 0
         ELSE 1
         ENDIF
         ), cmreq->objarray[chargemodcnt].updt_cnt = cm.updt_cnt
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to inactivate")
   ELSE
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(cmreq)
    ENDIF
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
     SET failed = update_error
     RETURN
    ELSE
     FOR (x = del_begin TO del_end)
      SET stat = alterlist(reply->charge_mod,x)
      IF (validate(reply->charge_mod[x].charge_mod_id,99999) != 99999)
       SET reply->charge_mod[x].charge_mod_id = request->charge_mod[x].charge_mod_id
       SET reply->charge_mod[x].action_type = request->charge_mod[x].action_type
       SET reply->charge_mod[x].charge_item_id = request->charge_mod[x].charge_item_id
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL echo("Done.")
 END ;Subroutine
 SUBROUTINE del_nomen_entity_reltn(del_begin,del_end)
   DECLARE code_value = f8
   DECLARE codeset14002meaning = c12
   DECLARE nomen_entity_reltn_id = f8
   DECLARE charge_item_id = f8
   FOR (x = del_begin TO del_end)
     IF ((request->charge_mod[x].action_type="DEL"))
      SET field1_id = 0.0
      SET nomen_id = 0.0
      SET charge_item_id = 0.0
      SELECT INTO "nl:"
       FROM charge_mod cm
       WHERE (cm.charge_mod_id=request->charge_mod[x].charge_mod_id)
       DETAIL
        field1_id = cm.field1_id, nomen_id = cm.nomen_id, charge_item_id = cm.charge_item_id
       WITH nocounter
      ;end select
      IF (nomen_id > 0)
       SET code_value = field1_id
       SET codeset14002meaning = uar_get_code_meaning(code_value)
       CALL echo(build("CodeSet14002Meaning is: ",codeset14002meaning))
       IF (((codeset14002meaning="ICD9") OR (((codeset14002meaning="PROCCODE") OR (
       codeset14002meaning="CPT4")) )) )
        SELECT INTO "nl:"
         FROM nomen_entity_reltn ner
         WHERE ner.parent_entity_name="CHARGE"
          AND ner.parent_entity_id=charge_item_id
          AND ner.nomenclature_id=nomen_id
          AND ner.active_ind=1
         DETAIL
          nomen_entity_reltn_id = ner.nomen_entity_reltn_id
         WITH nocounter
        ;end select
        CALL echo(build("nomen_entity_reltn_id: ",nomen_entity_reltn_id))
        IF (nomen_entity_reltn_id > 0)
         UPDATE  FROM nomen_entity_reltn ner
          SET ner.active_ind = false, ner.updt_cnt = (ner.updt_cnt+ 1), ner.updt_dt_tm = cnvtdatetime
           (sysdate),
           ner.updt_id = reqinfo->updt_id, ner.updt_applctx = reqinfo->updt_applctx, ner.updt_task =
           reqinfo->updt_task
          WHERE ner.nomen_entity_reltn_id=nomen_entity_reltn_id
          WITH nocounter
         ;end update
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
