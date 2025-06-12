CREATE PROGRAM afc_add_charge_mod:dba
 IF ("Z"=validate(afc_add_charge_mod_vrsn,"Z"))
  DECLARE afc_add_charge_mod_vrsn = vc WITH noconstant("557665.022")
 ENDIF
 SET afc_add_charge_mod_vrsn = "557665.022"
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
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
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_mod_qual = i2
    1 charge_mod[*]
      2 charge_mod_id = f8
      2 charge_item_id = f8
      2 charge_mod_type_cd = f8
      2 field1_id = f8
      2 field2_id = f8
      2 field3_id = f8
      2 field6 = vc
      2 field7 = vc
      2 nomen_id = f8
      2 action_type = c3
      2 nomen_entity_reltn_id = f8
      2 cm1_nbr = f8
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
 RECORD addchargeeventmodreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_mod_type_cd = f8
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
 RECORD addchargeeventmodrep(
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
     2 charge_mod_source_cd = f8
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
 IF ((validate(action_begin,- (1))=- (1)))
  SET action_begin = 1
  SET action_end = request->charge_mod_qual
 ENDIF
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
 ENDIF
 DECLARE codeset14002meaning = c12
 DECLARE codeset13019meaning = c12
 DECLARE codeset4518006meaning = c12
 DECLARE new_nbr = f8 WITH noconstant(0.0)
 DECLARE nskipcem = i2 WITH noconstant(0)
 DECLARE billcodemeaning = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,billcodemeaning)
 DECLARE active_code = f8
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,active_code)
 DECLARE data_status_code = f8
 SET code_set = 8
 SET cdf_meaning = "UNAUTH"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,data_status_code)
 DECLARE chargeicd9 = f8
 SET code_set = 23549
 SET cdf_meaning = "CHARGEICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,chargeicd9)
 DECLARE chargecpt4 = f8
 SET code_set = 23549
 SET cdf_meaning = "CHARGECPT4"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,chargecpt4)
 CALL echo("**************  AFC_ADD_CHARGE_MOD ******************")
 CALL echo(build("action_begin is: ",action_begin))
 CALL echo(build("action_end is: ",action_end))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->charge_mod,request->charge_mod_qual)
 SET nskipcem = validate(request->skip_charge_event_mod_ind,0)
 CALL echo(concat("BillCodeMeaning: ",cnvtstring(billcodemeaning)))
 SET table_name = "CHARGE_MOD"
 CALL add_charge_mod(action_begin,action_end)
 CALL add_nomen_entity_reltn(action_begin,action_end)
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
 SUBROUTINE (add_charge_mod(add_start=i4,add_stop=i4) =null)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   DECLARE billcdcnt2 = i4 WITH protect, noconstant(0)
   DECLARE modcnt = i4 WITH protect, noconstant(0)
   DECLARE tempcharge_event_id = f8 WITH protect, noconstant(0)
   FOR (x = add_start TO add_stop)
     IF ((request->charge_mod[x].action_type="ADD"))
      SET new_nbr = 0.0
      SELECT INTO "nl:"
       yy = seq(charge_event_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_nbr = cnvtreal(yy)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET request->charge_mod[x].charge_mod_id = new_nbr
      ENDIF
      SET billcdcnt2 += 1
      SET stat = alterlist(cmreq->objarray,billcdcnt2)
      SET cmreq->objarray[billcdcnt2].action_type = "ADD"
      SET cmreq->objarray[billcdcnt2].charge_mod_id = new_nbr
      IF ((request->charge_mod[x].charge_item_id=0))
       SET cmreq->objarray[billcdcnt2].charge_item_id = 0
      ELSE
       SET cmreq->objarray[billcdcnt2].charge_item_id = request->charge_mod[x].charge_item_id
      ENDIF
      IF ((request->charge_mod[x].charge_mod_type_cd=0))
       SET cmreq->objarray[billcdcnt2].charge_mod_type_cd = billcodemeaning
      ELSE
       SET cmreq->objarray[billcdcnt2].charge_mod_type_cd = request->charge_mod[x].charge_mod_type_cd
      ENDIF
      SET cmreq->objarray[billcdcnt2].field1 = request->charge_mod[x].field1
      SET cmreq->objarray[billcdcnt2].field2 = request->charge_mod[x].field2
      SET cmreq->objarray[billcdcnt2].field3 = request->charge_mod[x].field3
      SET cmreq->objarray[billcdcnt2].field4 = request->charge_mod[x].field4
      SET cmreq->objarray[billcdcnt2].field5 = request->charge_mod[x].field5
      SET cmreq->objarray[billcdcnt2].field6 = request->charge_mod[x].field6
      SET cmreq->objarray[billcdcnt2].field7 = request->charge_mod[x].field7
      SET cmreq->objarray[billcdcnt2].field8 = request->charge_mod[x].field8
      SET cmreq->objarray[billcdcnt2].field9 = request->charge_mod[x].field9
      SET cmreq->objarray[billcdcnt2].field10 = request->charge_mod[x].field10
      IF ((request->charge_mod[x].activity_dt_tm <= 0))
       SET cmreq->objarray[billcdcnt2].activity_dt_tm = null
      ELSE
       SET cmreq->objarray[billcdcnt2].activity_dt_tm = cnvtdatetime(request->charge_mod[x].
        activity_dt_tm)
      ENDIF
      IF ((request->charge_mod[x].beg_effective_dt_tm <= 0))
       SET cmreq->objarray[billcdcnt2].beg_effective_dt_tm = cnvtdatetime(sysdate)
      ELSE
       SET cmreq->objarray[billcdcnt2].beg_effective_dt_tm = cnvtdatetime(request->charge_mod[x].
        beg_effective_dt_tm)
      ENDIF
      IF ((request->charge_mod[x].end_effective_dt_tm <= 0))
       SET cmreq->objarray[billcdcnt2].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      ELSE
       SET cmreq->objarray[billcdcnt2].end_effective_dt_tm = cnvtdatetime(request->charge_mod[x].
        end_effective_dt_tm)
      ENDIF
      IF ((request->charge_mod[x].active_ind_ind=false))
       SET cmreq->objarray[billcdcnt2].active_ind = true
      ELSE
       SET cmreq->objarray[billcdcnt2].active_ind = request->charge_mod[x].active_ind
      ENDIF
      IF ((request->charge_mod[x].active_status_cd=0))
       SET cmreq->objarray[billcdcnt2].active_status_cd = active_code
      ELSE
       SET cmreq->objarray[billcdcnt2].active_status_cd = request->charge_mod[x].active_status_cd
      ENDIF
      SET cmreq->objarray[billcdcnt2].active_status_prsnl_id = reqinfo->updt_id
      SET cmreq->objarray[billcdcnt2].active_status_dt_tm = cnvtdatetime(sysdate)
      SET cmreq->objarray[billcdcnt2].updt_cnt = 0
      SET cmreq->objarray[billcdcnt2].field1_id = request->charge_mod[x].field1_id
      SET cmreq->objarray[billcdcnt2].field2_id = request->charge_mod[x].field2_id
      SET cmreq->objarray[billcdcnt2].field3_id = request->charge_mod[x].field3_id
      SET cmreq->objarray[billcdcnt2].field4_id = request->charge_mod[x].field4_id
      SET cmreq->objarray[billcdcnt2].field5_id = request->charge_mod[x].field5_id
      SET cmreq->objarray[billcdcnt2].nomen_id = request->charge_mod[x].nomen_id
      SET cmreq->objarray[billcdcnt2].cm1_nbr = request->charge_mod[x].cm1_nbr
      SET cmreq->objarray[billcdcnt2].code1_cd = validate(request->charge_mod[x].code1_cd,0.0)
      SET cmreq->objarray[billcdcnt2].charge_mod_source_cd = validate(request->charge_mod[x].
       charge_mod_source_cd,0.0)
      SET codeset14002meaning = uar_get_code_meaning(request->charge_mod[x].field1_id)
      SET codeset13019meaning = uar_get_code_meaning(request->charge_mod[x].charge_mod_type_cd)
      SET codeset4518006meaning = uar_get_code_meaning(cmreq->objarray[billcdcnt2].
       charge_mod_source_cd)
      IF (((codeset14002meaning="ICD9") OR (((codeset13019meaning="USER DEF") OR (((
      codeset14002meaning="MODIFIER"
       AND codeset4518006meaning != "MANUALLY_ADD") OR (codeset14002meaning="NDC")) )) ))
       AND nskipcem=0)
       SET tempcharge_event_id = 0.0
       SELECT INTO "nl:"
        FROM charge c
        WHERE (c.charge_item_id=request->charge_mod[x].charge_item_id)
        DETAIL
         tempcharge_event_id = c.charge_event_id
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        yx = seq(charge_event_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(yx)
        WITH format, counter
       ;end select
       IF (curqual=0)
        SET failed = gen_nbr_error
        RETURN
       ENDIF
       SET billcdcnt += 1
       SET stat = alterlist(addchargeeventmodreq->objarray,billcdcnt)
       SET addchargeeventmodreq->objarray[billcdcnt].action_type = "ADD"
       SET addchargeeventmodreq->objarray[billcdcnt].charge_event_mod_id = new_nbr
       SET addchargeeventmodreq->objarray[billcdcnt].charge_event_id = tempcharge_event_id
       IF ((request->charge_mod[x].charge_mod_type_cd=0))
        SET addchargeeventmodreq->objarray[billcdcnt].charge_event_mod_type_cd = billcodemeaning
       ELSE
        SET addchargeeventmodreq->objarray[billcdcnt].charge_event_mod_type_cd = request->charge_mod[
        x].charge_mod_type_cd
       ENDIF
       SET addchargeeventmodreq->objarray[billcdcnt].field1 = request->charge_mod[x].field1
       SET addchargeeventmodreq->objarray[billcdcnt].field2 = request->charge_mod[x].field2
       SET addchargeeventmodreq->objarray[billcdcnt].field3 = request->charge_mod[x].field3
       SET addchargeeventmodreq->objarray[billcdcnt].field4 = request->charge_mod[x].field4
       SET addchargeeventmodreq->objarray[billcdcnt].field5 = request->charge_mod[x].field5
       SET addchargeeventmodreq->objarray[billcdcnt].field6 = request->charge_mod[x].field6
       SET addchargeeventmodreq->objarray[billcdcnt].field7 = request->charge_mod[x].field7
       SET addchargeeventmodreq->objarray[billcdcnt].field8 = request->charge_mod[x].field8
       SET addchargeeventmodreq->objarray[billcdcnt].field9 = request->charge_mod[x].field9
       SET addchargeeventmodreq->objarray[billcdcnt].field10 = request->charge_mod[x].field10
       IF ((request->charge_mod[x].beg_effective_dt_tm <= 0))
        SET addchargeeventmodreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
       ELSE
        SET addchargeeventmodreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(request->
         charge_mod[x].beg_effective_dt_tm)
       ENDIF
       IF ((request->charge_mod[x].end_effective_dt_tm <= 0))
        SET addchargeeventmodreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE
        SET addchargeeventmodreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime(request->
         charge_mod[x].end_effective_dt_tm)
       ENDIF
       IF ((request->charge_mod[x].active_ind_ind=false))
        SET addchargeeventmodreq->objarray[billcdcnt].active_ind = true
       ELSE
        SET addchargeeventmodreq->objarray[billcdcnt].active_ind = request->charge_mod[x].active_ind
       ENDIF
       IF ((request->charge_mod[x].active_status_cd=0))
        SET addchargeeventmodreq->objarray[billcdcnt].active_status_cd = active_code
       ELSE
        SET addchargeeventmodreq->objarray[billcdcnt].active_status_cd = request->charge_mod[x].
        active_status_cd
       ENDIF
       SET addchargeeventmodreq->objarray[billcdcnt].active_status_prsnl_id = reqinfo->updt_id
       SET addchargeeventmodreq->objarray[billcdcnt].active_status_dt_tm = cnvtdatetime(sysdate)
       SET addchargeeventmodreq->objarray[billcdcnt].updt_cnt = 0
       SET addchargeeventmodreq->objarray[billcdcnt].field1_id = request->charge_mod[x].field1_id
       SET addchargeeventmodreq->objarray[billcdcnt].field2_id = request->charge_mod[x].field2_id
       SET addchargeeventmodreq->objarray[billcdcnt].field3_id = request->charge_mod[x].field3_id
       SET addchargeeventmodreq->objarray[billcdcnt].field4_id = request->charge_mod[x].field4_id
       SET addchargeeventmodreq->objarray[billcdcnt].field5_id = request->charge_mod[x].field5_id
       SET addchargeeventmodreq->objarray[billcdcnt].nomen_id = request->charge_mod[x].nomen_id
       SET addchargeeventmodreq->objarray[billcdcnt].cm1_nbr = request->charge_mod[x].cm1_nbr
       SET addchargeeventmodreq->objarray[billcdcnt].code1_cd = validate(request->charge_mod[x].
        code1_cd,0.0)
      ENDIF
     ENDIF
   ENDFOR
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to add")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
     SET failed = insert_error
     RETURN
    ELSE
     FOR (modcnt = 1 TO size(cmreq->objarray,5))
      IF (modcnt > size(reply->charge_mod,5))
       SET stat = alterlist(reply->charge_mod,modcnt)
      ENDIF
      IF (validate(reply->charge_mod[modcnt].charge_mod_id,99999) != 99999)
       SET reply->charge_mod[modcnt].charge_mod_id = cmreq->objarray[modcnt].charge_mod_id
       SELECT INTO "nl:"
        FROM charge_mod cm
        WHERE (cm.charge_mod_id=cmreq->objarray[modcnt].charge_mod_id)
        DETAIL
         reply->charge_mod[modcnt].charge_item_id = cm.charge_item_id, reply->charge_mod[modcnt].
         charge_mod_type_cd = cm.charge_mod_type_cd, reply->charge_mod[modcnt].field1_id = cm
         .field1_id,
         reply->charge_mod[modcnt].field2_id = cm.field2_id, reply->charge_mod[modcnt].field3_id = cm
         .field3_id, reply->charge_mod[modcnt].field6 = cm.field6,
         reply->charge_mod[modcnt].field7 = cm.field7, reply->charge_mod[modcnt].nomen_id = cm
         .nomen_id, reply->charge_mod[modcnt].action_type = cmreq->objarray[modcnt].action_type,
         reply->charge_mod[modcnt].cm1_nbr = cm.cm1_nbr
        WITH nocounter
       ;end select
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (size(addchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to add")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",addchargeeventmodreq), replace("REPLY",
     addchargeeventmodrep)
    IF ((addchargeeventmodrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(addchargeeventmodreq)
      CALL echorecord(addchargeeventmodrep)
     ENDIF
     SET failed = insert_error
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_nomen_entity_reltn(add_start,add_stop)
   DECLARE codeset14002meaning = c12
   DECLARE code_value = f8
   DECLARE tempperson_id = f8 WITH protect, noconstant(0)
   DECLARE tempencntr_id = f8 WITH protect, noconstant(0)
   FOR (x = add_start TO add_stop)
     IF ((request->charge_mod[x].action_type="ADD"))
      SET code_value = request->charge_mod[x].field1_id
      SET codeset14002meaning = uar_get_code_meaning(code_value)
      IF (((codeset14002meaning="ICD9") OR (((codeset14002meaning="PROCCODE") OR (codeset14002meaning
      ="CPT4")) )) )
       SET tempperson_id = 0.0
       SET tempencntr_id = 0.0
       SELECT INTO "nl:"
        FROM charge c
        WHERE (c.charge_item_id=request->charge_mod[x].charge_item_id)
        DETAIL
         tempperson_id = c.person_id, tempencntr_id = c.encntr_id
        WITH nocounter
       ;end select
       SET new_nbr = 0.0
       SELECT INTO "nl:"
        yz = seq(entity_reltn_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(yz)
        WITH format, counter
       ;end select
       INSERT  FROM nomen_entity_reltn n
        SET n.nomen_entity_reltn_id = new_nbr, n.nomenclature_id = request->charge_mod[x].nomen_id, n
         .parent_entity_id = request->charge_mod[x].charge_item_id,
         n.parent_entity_name = "CHARGE", n.child_entity_id = request->charge_mod[x].nomen_id, n
         .child_entity_name = "NOMENCLATURE",
         n.reltn_type_cd =
         IF (codeset14002meaning="CPT4") chargecpt4
         ELSE chargeicd9
         ENDIF
         , n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), n.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100 23:59:59.99"),
         n.updt_dt_tm = cnvtdatetime(curdate,curtime), n.updt_id = reqinfo->updt_id, n.updt_task =
         reqinfo->updt_task,
         n.updt_cnt = 0, n.updt_applctx = reqinfo->updt_applctx, n.person_id = tempperson_id,
         n.encntr_id = tempencntr_id, n.active_ind = 1
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = update_error
        RETURN
       ELSE
        SET reply->charge_mod[x].nomen_entity_reltn_id = new_nbr
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
