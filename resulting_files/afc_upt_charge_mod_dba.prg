CREATE PROGRAM afc_upt_charge_mod:dba
 IF ("Z"=validate(afc_upt_charge_mod_vrsn,"Z"))
  DECLARE afc_upt_charge_mod_vrsn = vc WITH noconstant("CHARGSRV-13049.023")
 ENDIF
 SET afc_upt_charge_mod_vrsn = "CHARGSRV-13049.023"
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
 IF ((validate(action_begin,- (1))=- (1)))
  SET action_begin = 1
  SET action_end = request->charge_mod_qual
 ENDIF
 RECORD uptchargeeventmodreq(
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
     2 updateicdcodes[*]
       3 chargeitemid = f8
       3 chargemodid = f8
       3 field6 = vc
 ) WITH protect
 RECORD uptchargeeventmodrep(
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
 SET reply->status_data.status = "F"
 DECLARE codeset14002meaning = c12
 DECLARE codeset13019meaning = c12
 DECLARE blank_date = dq8 WITH protect, noconstant(null)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE active_status_code = f8 WITH protect, noconstant(0)
 DECLARE icd9codevalue = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 14002
 SET cdf_meaning = "ICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,icd9codevalue)
 IF ( NOT (validate(cs4518006_manually_added)))
  DECLARE cs4518006_manually_added = f8 WITH protect, constant(getcodevalue(4518006,"MANUALLY_ADD",0)
   )
 ENDIF
 SET table_name = "CHARGE_MOD"
 CALL upt_charge_mod(action_begin,action_end)
 CALL upt_nomen_entity_reltn(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
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
 SUBROUTINE upt_charge_mod(upt_begin,upt_end)
   DECLARE cemtypecd = f8 WITH protect, noconstant(0)
   DECLARE cemtypecd2 = f8 WITH protect, noconstant(0)
   DECLARE chargemodcnt = i4 WITH protect, noconstant(0)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   DECLARE ceid = f8 WITH protect, noconstant(0)
   DECLARE updtcnt = i4 WITH protect, noconstant(0)
   DECLARE activeind = i2 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE modcount = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (x = upt_begin TO upt_end)
     IF ((request->charge_mod[x].action_type="UPT"))
      SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
      SET count1 = 0
      SET active_status_code = 0
      SELECT INTO "nl:"
       c.*
       FROM charge_mod c
       WHERE (c.charge_mod_id=request->charge_mod[x].charge_mod_id)
       HEAD REPORT
        count1 = 0
       DETAIL
        count1 += 1
        IF ((request->charge_mod[x].active_status_cd > 0))
         active_status_code = c.active_status_cd
        ENDIF
       WITH forupdate(c)
      ;end select
      IF (curqual=0)
       SET failed = lock_error
       RETURN
      ENDIF
      SET chargemodcnt += 1
      SET stat = alterlist(cmreq->objarray,chargemodcnt)
      SET cmreq->objarray[chargemodcnt].action_type = "UPT"
      SELECT INTO "nl"
       FROM charge_mod c
       WHERE (c.charge_mod_id=request->charge_mod[x].charge_mod_id)
       DETAIL
        cmreq->objarray[chargemodcnt].charge_mod_id = c.charge_mod_id, cmreq->objarray[chargemodcnt].
        charge_item_id = evaluate(request->charge_mod[x].charge_item_id,0.0,c.charge_item_id,- (1.0),
         0.0,
         request->charge_mod[x].charge_item_id), cmreq->objarray[chargemodcnt].charge_mod_type_cd =
        evaluate(request->charge_mod[x].charge_mod_type_cd,0.0,c.charge_mod_type_cd,- (1.0),0.0,
         request->charge_mod[x].charge_mod_type_cd),
        cmreq->objarray[chargemodcnt].field1 =
        IF (trim(request->charge_mod[x].field1,3)="") cnvtstring(icd9codevalue,17,2)
        ELSE request->charge_mod[x].field1
        ENDIF
        , cmreq->objarray[chargemodcnt].field2 = evaluate(request->charge_mod[x].field2,"",c.field2,
         '""',null,
         request->charge_mod[x].field2), cmreq->objarray[chargemodcnt].field3 = evaluate(request->
         charge_mod[x].field3,"",c.field3,'""',null,
         request->charge_mod[x].field3),
        cmreq->objarray[chargemodcnt].field4 = evaluate(request->charge_mod[x].field4,"",c.field4,
         '""',null,
         request->charge_mod[x].field4), cmreq->objarray[chargemodcnt].field5 = evaluate(request->
         charge_mod[x].field5,"",c.field5,'""',null,
         request->charge_mod[x].field5), cmreq->objarray[chargemodcnt].field6 = evaluate(request->
         charge_mod[x].field6,"",c.field6,'""',null,
         request->charge_mod[x].field6),
        cmreq->objarray[chargemodcnt].field7 = evaluate(request->charge_mod[x].field7,"",c.field7,
         '""',null,
         request->charge_mod[x].field7), cmreq->objarray[chargemodcnt].field8 = evaluate(request->
         charge_mod[x].field8,"",c.field8,'""',null,
         request->charge_mod[x].field8), cmreq->objarray[chargemodcnt].field9 = evaluate(request->
         charge_mod[x].field9,"",c.field9,'""',null,
         request->charge_mod[x].field9),
        cmreq->objarray[chargemodcnt].field10 = evaluate(request->charge_mod[x].field10,"",c.field10,
         '""',null,
         request->charge_mod[x].field10), cmreq->objarray[chargemodcnt].field1_id = request->
        charge_mod[x].field1_id, cmreq->objarray[chargemodcnt].field2_id = evaluate(request->
         charge_mod[x].field2_id,0.0,c.field2_id,- (1.0),0.0,
         request->charge_mod[x].field2_id),
        cmreq->objarray[chargemodcnt].field3_id = request->charge_mod[x].field3_id, cmreq->objarray[
        chargemodcnt].field4_id = request->charge_mod[x].field4_id, cmreq->objarray[chargemodcnt].
        field5_id = request->charge_mod[x].field5_id,
        cmreq->objarray[chargemodcnt].nomen_id = request->charge_mod[x].nomen_id, cmreq->objarray[
        chargemodcnt].cm1_nbr = request->charge_mod[x].cm1_nbr, cmreq->objarray[chargemodcnt].
        activity_dt_tm = evaluate(request->charge_mod[x].activity_dt_tm,0.0,c.activity_dt_tm,
         blank_date,null,
         cnvtdatetime(request->charge_mod[x].activity_dt_tm)),
        cmreq->objarray[chargemodcnt].beg_effective_dt_tm = evaluate(request->charge_mod[x].
         beg_effective_dt_tm,0.0,c.beg_effective_dt_tm,blank_date,null,
         cnvtdatetime(request->charge_mod[x].beg_effective_dt_tm)), cmreq->objarray[chargemodcnt].
        end_effective_dt_tm = evaluate(request->charge_mod[x].end_effective_dt_tm,0.0,c
         .end_effective_dt_tm,blank_date,null,
         cnvtdatetime(request->charge_mod[x].end_effective_dt_tm)), cmreq->objarray[chargemodcnt].
        active_ind = nullcheck(c.active_ind,request->charge_mod[x].active_ind,
         IF ((request->charge_mod[x].active_ind_ind=false)) 0
         ELSE 1
         ENDIF
         ),
        cmreq->objarray[chargemodcnt].active_status_cd = nullcheck(c.active_status_cd,request->
         charge_mod[x].active_status_cd,
         IF ((request->charge_mod[x].active_status_cd=active_status_code)) 0
         ELSE 1
         ENDIF
         ), cmreq->objarray[chargemodcnt].active_status_prsnl_id = nullcheck(c.active_status_prsnl_id,
         reqinfo->updt_id,
         IF ((request->charge_mod[x].active_status_cd=active_status_code)) 0
         ELSE 1
         ENDIF
         ), cmreq->objarray[chargemodcnt].active_status_dt_tm = nullcheck(c.active_status_dt_tm,
         cnvtdatetime(sysdate),
         IF ((request->charge_mod[x].active_status_cd=active_status_code)) 0
         ELSE 1
         ENDIF
         ),
        cmreq->objarray[chargemodcnt].updt_cnt = c.updt_cnt, cmreq->objarray[chargemodcnt].
        charge_mod_source_cd = validate(request->charge_mod[x].charge_mod_source_cd,0.0)
       WITH nocounter
      ;end select
      FOR (i = 1 TO request->charge_mod_qual)
        IF ((request->charge_mod[i].action_type="UPT")
         AND uar_get_code_meaning(request->charge_mod[i].field1_id)="ICD9")
         SET modcount += 1
         SET stat = alterlist(cmreq->objarray[chargemodcnt].updateicdcodes,modcount)
         SET cmreq->objarray[chargemodcnt].updateicdcodes[modcount].chargeitemid = request->
         charge_mod[i].charge_item_id
         SET cmreq->objarray[chargemodcnt].updateicdcodes[modcount].chargemodid = request->
         charge_mod[i].charge_mod_id
         SET cmreq->objarray[chargemodcnt].updateicdcodes[modcount].field6 = request->charge_mod[i].
         field6
        ENDIF
      ENDFOR
      SET codeset14002meaning = uar_get_code_meaning(request->charge_mod[x].field1_id)
      SET codeset13019meaning = uar_get_code_meaning(request->charge_mod[x].charge_mod_type_cd)
      IF ((cmreq->objarray[chargemodcnt].charge_mod_source_cd=cs4518006_manually_added)
       AND codeset14002meaning="MODIFIER"
       AND validate(request->charge_mod[x].charge_event_mod_id,0.0) != 0.0)
       IF (uptchargeeventmodactiveind(request->charge_mod[x].charge_event_mod_id))
        CALL logmessage(curprog,build("Successfully updated active ind for charge_event_mod_id: ",
          request->charge_mod[x].charge_event_mod_id),log_debug)
       ELSE
        CALL logmessage(curprog,"uptChargeEventModActiveInd failed to update charge_event_mod table",
         log_debug)
       ENDIF
      ELSEIF (((codeset14002meaning="ICD9") OR (((codeset13019meaning="USER DEF") OR (((
      codeset14002meaning="MODIFIER"
       AND (cmreq->objarray[chargemodcnt].charge_mod_source_cd != cs4518006_manually_added)) OR (
      codeset14002meaning="NDC")) )) )) )
       IF ((validate(request->charge_mod[x].charge_event_mod_id,- (1.0)) != - (1.0)))
        SET ceid = 0.0
        SELECT INTO "nl:"
         FROM charge c
         WHERE (c.charge_item_id=request->charge_mod[x].charge_item_id)
         DETAIL
          ceid = c.charge_event_id
         WITH nocounter
        ;end select
        SET updtcnt = 0.0
        SET cemtypecd2 = 0.0
        SET activeind = 0
        SELECT INTO "nl:"
         FROM charge_event_mod cem
         WHERE (cem.charge_event_mod_id=request->charge_mod[x].charge_event_mod_id)
         DETAIL
          updtcnt = cem.updt_cnt, cemtypecd2 = cem.charge_event_mod_type_cd, activeind = cem
          .active_ind
         WITH nocounter
        ;end select
        SET billcdcnt += 1
        SET stat = alterlist(uptchargeeventmodreq->objarray,billcdcnt)
        SET uptchargeeventmodreq->objarray[billcdcnt].action_type = "UPT"
        SET uptchargeeventmodreq->objarray[billcdcnt].charge_event_mod_id = request->charge_mod[x].
        charge_event_mod_id
        SET uptchargeeventmodreq->objarray[billcdcnt].charge_event_id = ceid
        SET cemtypecd = evaluate(request->charge_mod[x].charge_mod_type_cd,0.0,cemtypecd2,- (1.0),0.0,
         request->charge_mod[x].charge_mod_type_cd)
        SET uptchargeeventmodreq->objarray[billcdcnt].charge_event_mod_type_cd = cemtypecd
        SET uptchargeeventmodreq->objarray[billcdcnt].field1 = request->charge_mod[x].field1
        SET uptchargeeventmodreq->objarray[billcdcnt].field2 = request->charge_mod[x].field2
        SET uptchargeeventmodreq->objarray[billcdcnt].field3 = request->charge_mod[x].field3
        SET uptchargeeventmodreq->objarray[billcdcnt].field4 = request->charge_mod[x].field4
        SET uptchargeeventmodreq->objarray[billcdcnt].field5 = request->charge_mod[x].field5
        SET uptchargeeventmodreq->objarray[billcdcnt].field6 = request->charge_mod[x].field6
        SET uptchargeeventmodreq->objarray[billcdcnt].field7 = request->charge_mod[x].field7
        SET uptchargeeventmodreq->objarray[billcdcnt].field8 = request->charge_mod[x].field8
        SET uptchargeeventmodreq->objarray[billcdcnt].field9 = request->charge_mod[x].field9
        SET uptchargeeventmodreq->objarray[billcdcnt].field10 = request->charge_mod[x].field10
        SET uptchargeeventmodreq->objarray[billcdcnt].active_ind = nullcheck(activeind,request->
         charge_mod[x].active_ind,
         IF ((request->charge_mod[x].active_ind_ind=false)) 0
         ELSE 1
         ENDIF
         )
        SET uptchargeeventmodreq->objarray[billcdcnt].updt_cnt = updtcnt
        SET uptchargeeventmodreq->objarray[billcdcnt].field1_id = request->charge_mod[x].field1_id
        SET uptchargeeventmodreq->objarray[billcdcnt].field2_id = request->charge_mod[x].field2_id
        SET uptchargeeventmodreq->objarray[billcdcnt].field3_id = request->charge_mod[x].field3_id
        SET uptchargeeventmodreq->objarray[billcdcnt].field4_id = request->charge_mod[x].field4_id
        SET uptchargeeventmodreq->objarray[billcdcnt].field5_id = request->charge_mod[x].field5_id
        SET uptchargeeventmodreq->objarray[billcdcnt].nomen_id = request->charge_mod[x].nomen_id
        SET uptchargeeventmodreq->objarray[billcdcnt].cm1_nbr = request->charge_mod[x].cm1_nbr
        IF ((request->charge_mod[x].beg_effective_dt_tm <= 0))
         SET uptchargeeventmodreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
        ELSE
         SET uptchargeeventmodreq->objarray[billcdcnt].beg_effective_dt_tm = cnvtdatetime(request->
          charge_mod[x].beg_effective_dt_tm)
        ENDIF
        IF ((request->charge_mod[x].end_effective_dt_tm <= 0))
         SET uptchargeeventmodreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime(
          "31-DEC-2100 00:00:00.00")
        ELSE
         SET uptchargeeventmodreq->objarray[billcdcnt].end_effective_dt_tm = cnvtdatetime(request->
          charge_mod[x].end_effective_dt_tm)
        ENDIF
        IF ((request->charge_mod[x].activity_dt_tm <= 0))
         SET uptchargeeventmodreq->objarray[billcdcnt].activity_dt_tm = null
        ELSE
         SET uptchargeeventmodreq->objarray[billcdcnt].activity_dt_tm = cnvtdatetime(request->
          charge_mod[x].activity_dt_tm)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to update")
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
     FOR (x = upt_begin TO upt_end)
      SET stat = alterlist(reply->charge_mod,x)
      IF ((validate(reply->charge_mod[x].charge_mod_id,- (1)) != - (1)))
       SET reply->charge_mod[x].charge_mod_id = request->charge_mod[x].charge_mod_id
       SELECT INTO "nl:"
        cm.*
        FROM charge_mod cm
        WHERE (cm.charge_mod_id=request->charge_mod[x].charge_mod_id)
        DETAIL
         reply->charge_mod[x].charge_item_id = cm.charge_item_id, reply->charge_mod[x].
         charge_mod_type_cd = cm.charge_mod_type_cd, reply->charge_mod[x].field1_id = cm.field1_id,
         reply->charge_mod[x].field2_id = cm.field2_id, reply->charge_mod[x].field3_id = cm.field3_id,
         reply->charge_mod[x].field6 = cm.field6,
         reply->charge_mod[x].field7 = cm.field7, reply->charge_mod[x].nomen_id = cm.nomen_id, reply
         ->charge_mod[x].cm1_nbr = cm.cm1_nbr,
         reply->charge_mod[x].action_type = "UPT"
        WITH nocounter
       ;end select
       SET reply->status_data.status = "S"
       SET reqinfo->commit_ind = 1
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (size(uptchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to update")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargeeventmodreq), replace("REPLY",
     uptchargeeventmodrep)
    IF ((uptchargeeventmodrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(uptchargeeventmodreq)
      CALL echorecord(uptchargeeventmodrep)
     ENDIF
     SET failed = update_error
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_nomen_entity_reltn(add_start,add_stop)
  DECLARE code_value = f8
  FOR (x = add_start TO add_stop)
    IF ((request->charge_mod[x].action_type="UPT"))
     SET code_value = request->charge_mod[x].field1_id
     SET codeset14002meaning = uar_get_code_meaning(code_value)
     IF (((codeset14002meaning="ICD9") OR (((codeset14002meaning="PROCCODE") OR (codeset14002meaning=
     "CPT4")) )) )
      UPDATE  FROM nomen_entity_reltn n
       SET n.nomenclature_id = request->charge_mod[x].nomen_id, n.child_entity_id = request->
        charge_mod[x].nomen_id, n.updt_dt_tm = cnvtdatetime(curdate,curtime),
        n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_cnt = 0,
        n.updt_applctx = reqinfo->updt_applctx
       WHERE (n.nomen_entity_reltn_id=request->charge_mod[x].nomen_entity_reltn_id)
      ;end update
      IF (curqual=0)
       SET failed = update_error
       RETURN
      ELSE
       SET reply->charge_mod[x].nomen_entity_reltn_id = request->charge_mod[x].nomen_entity_reltn_id
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE (uptchargeeventmodactiveind(prchargeeventmodid=f8) =i2)
   CALL logmessage(curprog,"Entering uptChargeEventModActiveInd...",log_debug)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   SET billcdcnt += 1
   SET stat = alterlist(uptchargeeventmodreq->objarray,billcdcnt)
   SELECT INTO "nl:"
    FROM charge_event_mod cem
    WHERE cem.charge_event_mod_id=prchargeeventmodid
     AND cem.active_ind=true
    DETAIL
     uptchargeeventmodreq->objarray[billcdcnt].action_type = "DEL", uptchargeeventmodreq->objarray[
     billcdcnt].charge_event_id = cem.charge_event_id, uptchargeeventmodreq->objarray[billcdcnt].
     charge_event_mod_id = prchargeeventmodid,
     uptchargeeventmodreq->objarray[billcdcnt].updt_cnt = cem.updt_cnt, uptchargeeventmodreq->
     objarray[billcdcnt].active_ind = false
    WITH nocounter
   ;end select
   IF (size(uptchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to update")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargeeventmodreq), replace("REPLY",
     uptchargeeventmodrep)
    IF ((uptchargeeventmodrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(uptchargeeventmodreq)
      CALL echorecord(uptchargeeventmodrep)
     ENDIF
     SET stat = alterlist(uptchargeeventmodreq->objarray,0)
     CALL logmessage(curprog,"Exiting uptChargeEventModActiveInd...",log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   SET stat = alterlist(uptchargeeventmodreq->objarray,0)
   CALL logmessage(curprog,"Exiting uptChargeEventModActiveInd...",log_debug)
   RETURN(true)
 END ;Subroutine
#end_program
 CALL echorecord(reqinfo)
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
