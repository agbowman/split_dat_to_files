CREATE PROGRAM cs_srv_get_charge_event:dba
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
 SET cs_srv_get_charge_event_version = "CHARGSRV-14536.050"
 CALL echo(concat("CS_SRV_GET_CHARGE_EVENT - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime,
    " - HH:MM:SS;;S")))
 DECLARE repeventloop = i4
 DECLARE repeventcnt = i4
 DECLARE repactloop = i4
 DECLARE repactcnt = i4
 DECLARE groupcnt = i4 WITH noconstant(0)
 DECLARE mpcnt = i4 WITH noconstant(0)
 DECLARE codeset_17769 = f8 WITH constant(17769)
 DECLARE cs13016_taskassay = f8 WITH noconstant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
 DECLARE cs106_radiology = f8 WITH noconstant(uar_get_code_by("MEANING",106,"RADIOLOGY"))
 DECLARE cs289_billonly = f8 WITH noconstant(uar_get_code_by("MEANING",289,"17"))
 DECLARE isradbillonly = i2 WITH noconstant(0)
 DECLARE cs13019_addon = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"ADD ON",1,cs13019_addon)
 DECLARE cs4518006_copyfromcem_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,
   "COPYFROMCEM"))
 DECLARE esuspend_unknown = i2 WITH constant(0)
 DECLARE esuspend_ok = i2 WITH constant(1)
 DECLARE esuspend_missingorder = i2 WITH constant(2)
 DECLARE esuspend_parentmissingorder = i2 WITH constant(3)
 DECLARE eflag_unknown = i2 WITH constant(0)
 DECLARE eflag_incomplete = i2 WITH constant(1)
 DECLARE eflag_complete = i2 WITH constant(2)
 DECLARE eflag_interval = i2 WITH constant(3)
 DECLARE cvs14002_afc_schedule_type = f8 WITH protect, constant(14002.0)
 IF (validate(parent_script,"TEST")="TEST")
  DECLARE parent_script = c50
  SET parent_script = "CS_SRV_GET_CHARGE_EVENT"
 ENDIF
 RECORD child(
   1 mastereventid = f8
   1 mastereventcd = f8
   1 items[*]
     2 parenteventid = f8
     2 parenteventcd = f8
   1 list[*]
     2 charge_event_id = f8
     2 indicator = i2
 )
 FREE RECORD cptmodlist
 RECORD cptmodlist(
   1 mod_list_count = i4
   1 mod_list[*]
     2 field1_id = f8
 )
 FREE SET templist
 RECORD templist(
   1 charge_count = i4
   1 charges[*]
     2 charge_item_id = f8
 )
 RECORD uptcmreq(
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
 RECORD uptcmrep(
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
 IF ((validate(chargecpt4,- (1))=- (1)))
  DECLARE chargecpt4 = f8 WITH noconstant(0.0), persist
  SET stat = uar_get_meaning_by_codeset(23549,nullterm("CHARGECPT4"),1,chargecpt4)
 ENDIF
 IF ((validate(carrier_370_cd,- (1))=- (1)))
  DECLARE carrier_370_cd = f8 WITH noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(370,nullterm("CARRIER"),1,carrier_370_cd)
 ENDIF
 IF ( NOT (validate(cs354_self_pay_cd)))
  DECLARE cs354_self_pay_cd = f8 WITH protect, constant(getcodevalue(354,"SELFPAY",1))
 ENDIF
 IF ( NOT (validate(cs24451_invalid_cd)))
  DECLARE cs24451_invalid_cd = f8 WITH protect, constant(getcodevalue(24451,"INVALID",1))
 ENDIF
 IF ( NOT (validate(cs24451_cancelled_cd)))
  DECLARE cs24451_cancelled_cd = f8 WITH protect, constant(getcodevalue(24451,"CANCELLED",1))
 ENDIF
 IF ( NOT (validate(cs222_facility_cd)))
  DECLARE cs222_facility_cd = f8 WITH protect, constant(getcodevalue(222,"FACILITY",1))
 ENDIF
 IF ( NOT (validate(cs222_building_cd)))
  DECLARE cs222_building_cd = f8 WITH protect, constant(getcodevalue(222,"BUILDING",1))
 ENDIF
 IF ( NOT (validate(cs222_nurseunit_cd)))
  DECLARE cs222_nurseunit_cd = f8 WITH protect, constant(getcodevalue(222,"NURSEUNIT",1))
 ENDIF
 IF ( NOT (validate(cs222_ambulatory_cd)))
  DECLARE cs222_ambulatory_cd = f8 WITH protect, constant(getcodevalue(222,"AMBULATORY",1))
 ENDIF
 IF ( NOT (validate(cs222_room_cd)))
  DECLARE cs222_room_cd = f8 WITH protect, constant(getcodevalue(222,"ROOM",1))
 ENDIF
 IF ( NOT (validate(cs222_bed_cd)))
  DECLARE cs222_bed_cd = f8 WITH protect, constant(getcodevalue(222,"BED",1))
 ENDIF
 IF ( NOT (validate(cs13019_billencntr_cd)))
  DECLARE cs13019_billencntr_cd = f8 WITH protect, constant(getcodevalue(13019,"BILLENCNTR",1))
 ENDIF
 SUBROUTINE checkserverprocessflag(h_event)
   CALL echo("CheckServerProcessFlag begin")
   IF ((validate(non_server_susp->suspcnt,- (1))=- (1)))
    RECORD non_server_susp(
      1 suspcnt = i2
      1 list[*]
        2 code_value = f8
    ) WITH persist
    CALL echo("Read suspense reason codes")
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=13030
      AND cv.active_ind=1
      AND  NOT (cv.cdf_meaning IN ("NOBILLITEM", "NOICD9", "NORENDPHYS", "NOPAYORSCHED", "NOPARENTBI",
     "NOPPAYORSCHE", "NOPARENTCE", "NOINTERFACE", "ADDONBILL", "ADDONPRICE",
     "NOTIER", "PAYORIDZERO", "NOENCNTRID", "NOPERSONID", "CEBIIDSZERO",
     "CEPBIIDSZERO", "ADDONPAYOR", "NOORDER", "NOPARENTORDR"))
     DETAIL
      non_server_susp->suspcnt += 1, stat = alterlist(non_server_susp->list,non_server_susp->suspcnt),
      non_server_susp->list[non_server_susp->suspcnt].code_value = cv.code_value
     WITH nocounter
    ;end select
    CALL echorecord(non_server_susp)
   ENDIF
   DECLARE expandcnt = i2
   SELECT INTO "nl:"
    cm.field1_id
    FROM (dummyt d  WITH seq = value(size(reply->charge_event[h_event].charges,5))),
     charge_mod cm
    PLAN (d
     WHERE (reply->charge_event[h_event].charges[d.seq].server_process_flag=eflag_incomplete))
     JOIN (cm
     WHERE (cm.charge_item_id=reply->charge_event[h_event].charges[d.seq].charge_item_id)
      AND (cm.charge_mod_type_cd=g_cs13019->suspense)
      AND expand(expandcnt,1,non_server_susp->suspcnt,cm.field1_id,non_server_susp->list[expandcnt].
      code_value))
    DETAIL
     CALL echo(build("Setting server_process_flag = eFlag_complete for charge_item_id:",reply->
      charge_event[h_event].charges[d.seq].charge_item_id)), reply->charge_event[h_event].charges[d
     .seq].server_process_flag = eflag_complete
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (isignoredeventmodifier(s_curevent=i4,s_field6=vc) =i2)
  IF (validate(request->process_event[s_curevent].ignored_event_mod_qual,0) > 0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(request->process_event[s_curevent].ignored_event_mod,5))
     IF (cnvtupper(trim(s_field6,3))=cnvtupper(trim(request->process_event[s_curevent].
       ignored_event_mod[idx].field6,3)))
      RETURN(true)
     ENDIF
   ENDFOR
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE (isignoredchargemodifier(s_curevent=i4,s_field6=vc) =i2)
  IF (validate(request->process_event[s_curevent].ignored_charge_mod_qual,0) > 0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(request->process_event[s_curevent].ignored_charge_mod,5))
     IF (cnvtupper(trim(s_field6,3))=cnvtupper(trim(request->process_event[s_curevent].
       ignored_charge_mod[idx].field6,3)))
      RETURN(true)
     ENDIF
   ENDFOR
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE (iscptmodifier(s_field1_id=f8) =i2)
  IF (validate(cptmodlist->mod_list_count,0) > 0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO cptmodlist->mod_list_count)
     IF ((s_field1_id=cptmodlist->mod_list[idx].field1_id))
      RETURN(true)
     ENDIF
   ENDFOR
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE (getproviderspecialty(a_repnum=i4) =null)
   RECORD lochierarchy(
     1 list[*]
       2 level_cd = f8
   ) WITH protect
   DECLARE provider_id = f8 WITH noconstant(0.00)
   DECLARE spc_loc_cd = f8 WITH noconstant(0.00)
   DECLARE cur_cd = f8 WITH noconstant(0.00)
   DECLARE cnt = i4 WITH noconstant(0)
   DECLARE found = i2 WITH noconstant(false)
   IF ((reply->charge_event[a_repnum].verify_phys_id > 0))
    SET provider_id = reply->charge_event[a_repnum].verify_phys_id
   ELSEIF ((reply->charge_event[a_repnum].perf_phys_id > 0))
    SET provider_id = reply->charge_event[a_repnum].perf_phys_id
   ELSEIF ((reply->charge_event[a_repnum].ord_phys_id > 0))
    SET provider_id = reply->charge_event[a_repnum].ord_phys_id
   ENDIF
   IF ((reply->charge_event[a_repnum].perf_loc_cd > 0))
    SET spc_loc_cd = reply->charge_event[a_repnum].perf_loc_cd
   ELSE
    SELECT INTO "nl:"
     FROM encounter e
     WHERE (e.encntr_id=reply->charge_event[a_repnum].encntr_id)
     DETAIL
      spc_loc_cd = e.location_cd
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_value=spc_loc_cd
     AND c.active_ind=true
    DETAIL
     CASE (uar_get_code_meaning(c.code_value))
      OF "FACILITY":
       cnt = 1
      OF "BUILDING":
       cnt = 2
      OF "NURSEUNIT":
      OF "AMBULATORY":
       cnt = 3
      OF "ROOM":
       cnt = 4
      OF "BED":
       cnt = 5
     ENDCASE
    WITH nocounter
   ;end select
   SET cur_cd = spc_loc_cd
   SET stat = alterlist(lochierarchy->list,cnt)
   IF (cnt > 0)
    SET lochierarchy->list[cnt].level_cd = cur_cd
   ENDIF
   WHILE (cnt > 0)
    SELECT INTO "nl:"
     l.parent_loc_cd, l.child_loc_cd, l.location_group_type_cd
     FROM location_group l
     WHERE l.child_loc_cd=cur_cd
      AND l.active_ind=1
      AND l.root_loc_cd=0
     DETAIL
      IF (((cnt=4
       AND l.location_group_type_cd=cs222_room_cd) OR (((cnt=3
       AND ((l.location_group_type_cd=cs222_nurseunit_cd) OR (l.location_group_type_cd=
      cs222_ambulatory_cd)) ) OR (((cnt=2
       AND l.location_group_type_cd=cs222_building_cd) OR (cnt=1
       AND l.location_group_type_cd=cs222_facility_cd)) )) )) )
       cur_cd = l.parent_loc_cd, lochierarchy->list[cnt].level_cd = cur_cd
      ENDIF
     WITH nocounter
    ;end select
    SET cnt -= 1
   ENDWHILE
   SET cnt = size(alterlist(lochierarchy->list,5))
   WHILE (cnt > 0)
     SET spc_loc_cd = lochierarchy->list[cnt].level_cd
     SELECT INTO "nl:"
      FROM prsnl_specialty_reltn psr,
       prsnl_specialty_loc_reltn pslr
      PLAN (psr
       WHERE psr.prsnl_id=provider_id
        AND psr.active_ind=true
        AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
       JOIN (pslr
       WHERE pslr.prsnl_specialty_reltn_id=psr.prsnl_specialty_reltn_id
        AND pslr.location_cd=spc_loc_cd
        AND pslr.active_ind=true
        AND pslr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND pslr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
      ORDER BY psr.prsnl_id, pslr.beg_effective_dt_tm
      HEAD psr.prsnl_id
       stat = assign(validate(reply->charge_event[a_repnum].provider_specialty_cd),psr.specialty_cd)
      DETAIL
       found = true
      WITH nocounter
     ;end select
     IF (found=true)
      SET cnt = 0
     ELSE
      SET cnt -= 1
     ENDIF
   ENDWHILE
   IF (found=false)
    SELECT INTO "nl:"
     FROM prsnl_specialty_reltn psr
     WHERE psr.prsnl_id=provider_id
      AND psr.primary_ind=true
      AND psr.active_ind=true
      AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
     DETAIL
      stat = assign(validate(reply->charge_event[a_repnum].provider_specialty_cd),psr.specialty_cd)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE filloutcharge(a_repnum,a_chargecnt)
   SET stat = alterlist(reply->charge_event[a_repnum].charges,a_chargecnt)
   SET reply->charge_event[a_repnum].charges[a_chargecnt].charge_item_id = c.charge_item_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].charge_act_id = c.charge_event_act_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].charge_event_id = c.charge_event_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].bill_item_id = c.bill_item_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].charge_description = c.charge_description
   SET reply->charge_event[a_repnum].charges[a_chargecnt].price_sched_id = c.price_sched_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].payor_id = c.payor_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].item_quantity = c.item_quantity
   SET reply->charge_event[a_repnum].charges[a_chargecnt].item_price = c.item_price
   SET reply->charge_event[a_repnum].charges[a_chargecnt].item_extended_price = c.item_extended_price
   SET reply->charge_event[a_repnum].charges[a_chargecnt].charge_type_cd = c.charge_type_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].suspense_rsn_cd = c.suspense_rsn_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].reason_comment = c.reason_comment
   SET reply->charge_event[a_repnum].charges[a_chargecnt].posted_cd = c.posted_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].ord_phys_id = c.ord_phys_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].perf_phys_id = c.perf_phys_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].order_id = c.order_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].beg_effective_dt_tm = c.beg_effective_dt_tm
   SET reply->charge_event[a_repnum].charges[a_chargecnt].person_id = c.person_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].encntr_id = c.encntr_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].admit_type_cd = c.admit_type_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].med_service_cd = c.med_service_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].institution_cd = c.institution_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].department_cd = c.department_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].section_cd = c.section_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].subsection_cd = c.subsection_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].level5_cd = c.level5_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].service_dt_tm = c.service_dt_tm
   SET reply->charge_event[a_repnum].charges[a_chargecnt].process_flg = c.process_flg
   SET reply->charge_event[a_repnum].charges[a_chargecnt].parent_charge_item_id = c
   .parent_charge_item_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].interface_id = c.interface_file_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].tier_group_cd = c.tier_group_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].def_bill_item_id = c.def_bill_item_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].verify_phys_id = c.verify_phys_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].gross_price = c.gross_price
   SET reply->charge_event[a_repnum].charges[a_chargecnt].discount_amount = c.discount_amount
   SET reply->charge_event[a_repnum].charges[a_chargecnt].research_acct_id = c.research_acct_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].activity_type_cd = c.activity_type_cd
   IF (validate(reply->charge_event[a_repnum].charges[a_chargecnt].activity_sub_type_cd))
    SET reply->charge_event[a_repnum].charges[a_chargecnt].activity_sub_type_cd = c
    .activity_sub_type_cd
   ENDIF
   SET reply->charge_event[a_repnum].charges[a_chargecnt].cost_center_cd = c.cost_center_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].abn_status_cd = c.abn_status_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].perf_loc_cd = c.perf_loc_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].inst_fin_nbr = c.inst_fin_nbr
   SET reply->charge_event[a_repnum].charges[a_chargecnt].ord_loc_cd = c.ord_loc_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].fin_class_cd = c.fin_class_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].health_plan_id = c.health_plan_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].manual_ind = c.manual_ind
   SET reply->charge_event[a_repnum].charges[a_chargecnt].payor_type_cd = c.payor_type_cd
   SET reply->charge_event[a_repnum].charges[a_chargecnt].item_interval_id = c.item_interval_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].list_price = c.item_list_price
   SET reply->charge_event[a_repnum].charges[a_chargecnt].list_price_sched_id = c.list_price_sched_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].epsdt_ind = c.epsdt_ind
   SET reply->charge_event[a_repnum].charges[a_chargecnt].ref_phys_id = c.ref_phys_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].alpha_nomen_id = c.alpha_nomen_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].server_process_flag = c.server_process_flag
   SET reply->charge_event[a_repnum].charges[a_chargecnt].offset_charge_item_id = c
   .offset_charge_item_id
   SET reply->charge_event[a_repnum].charges[a_chargecnt].patient_responsibility_flag = c
   .patient_responsibility_flag
   SET reply->charge_event[a_repnum].charges[a_chargecnt].item_deductible_amt = c.item_deductible_amt
   IF (validate(reply->charge_event[a_repnum].charges[a_chargecnt].provider_specialty_cd)
    AND validate(reply->charge_event[a_repnum].provider_specialty_cd))
    SET reply->charge_event[a_repnum].charges[a_chargecnt].provider_specialty_cd = reply->
    charge_event[a_repnum].provider_specialty_cd
   ENDIF
   IF (validate(reply->charge_event[a_repnum].charges[a_chargecnt].item_price_adj_amt))
    SET reply->charge_event[a_repnum].charges[a_chargecnt].item_price_adj_amt = c.item_price_adj_amt
   ENDIF
 END ;Subroutine
 SUBROUTINE filloutchargemod(b_event,b_charge,b_mod)
   SET stat = alterlist(reply->charge_event[b_event].charges[b_charge].mods.charge_mods,b_mod)
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].
   charge_event_mod_type_cd = cm.charge_mod_type_cd
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field1 = cm.field1
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field2 = cm.field2
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field3 = cm.field3
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field4 = cm.field4
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field5 = cm.field5
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field6 = cm.field6
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field7 = cm.field7
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field8 = cm.field8
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field9 = cm.field9
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field10 = cm.field10
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field1_id = cm
   .field1_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field2_id = cm
   .field2_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field3_id = cm
   .field3_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field4_id = cm
   .field4_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].field5_id = cm
   .field5_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].nomen_id = cm.nomen_id
   SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].cm1_nbr = cm.cm1_nbr
   IF (validate(reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].code1_cd))
    SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].code1_cd = cm.code1_cd
   ENDIF
   IF (validate(reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].
    charge_mod_source_cd))
    SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].charge_mod_source_cd
     = cm.charge_mod_source_cd
   ENDIF
   IF (validate(reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].activity_dt_tm
    ))
    SET reply->charge_event[b_event].charges[b_charge].mods.charge_mods[b_mod].activity_dt_tm = cm
    .activity_dt_tm
   ENDIF
 END ;Subroutine
 SUBROUTINE getchargeevent(a)
   DECLARE idx = i4 WITH protect, noconstant(0)
   CALL echo("Read charge_event table")
   SET stat = alterlist(reply->charge_event,repeventcnt)
   SELECT INTO "nl:"
    c.charge_event_id
    FROM charge_event c
    WHERE expand(idx,1,repeventcnt,c.charge_event_id,request->process_event[idx].charge_event_id)
    DETAIL
     idx = locateval(idx,1,repeventcnt,c.charge_event_id,request->process_event[idx].charge_event_id),
     reply->charge_event[idx].ext_master_event_id = c.ext_m_event_id, reply->charge_event[idx].
     ext_master_event_cont_cd = c.ext_m_event_cont_cd,
     reply->charge_event[idx].ext_master_reference_id = c.ext_m_reference_id, reply->charge_event[idx
     ].ext_master_reference_cont_cd = c.ext_m_reference_cont_cd, reply->charge_event[idx].
     ext_parent_event_id = c.ext_p_event_id,
     reply->charge_event[idx].ext_parent_event_cont_cd = c.ext_p_event_cont_cd, reply->charge_event[
     idx].ext_parent_reference_id = c.ext_p_reference_id, reply->charge_event[idx].
     ext_parent_reference_cont_cd = c.ext_p_reference_cont_cd,
     reply->charge_event[idx].ext_item_event_id = c.ext_i_event_id, reply->charge_event[idx].
     ext_item_event_cont_cd = c.ext_i_event_cont_cd, reply->charge_event[idx].ext_item_reference_id
      = c.ext_i_reference_id,
     reply->charge_event[idx].ext_item_reference_cont_cd = c.ext_i_reference_cont_cd, reply->
     charge_event[idx].order_id = c.order_id, reply->charge_event[idx].person_id = c.person_id,
     reply->charge_event[idx].encntr_id = c.encntr_id, reply->charge_event[idx].accession = c
     .accession, reply->charge_event[idx].report_priority_cd = c.report_priority_cd,
     reply->charge_event[idx].collection_priority_cd = c.collection_priority_cd, reply->charge_event[
     idx].research_acct_id = c.research_account_id, reply->charge_event[idx].abn_status_cd = c
     .abn_status_cd,
     reply->charge_event[idx].perf_loc_cd = c.perf_loc_cd, reply->charge_event[idx].charge_event_id
      = c.charge_event_id, reply->charge_event[idx].cancelled_ind = c.cancelled_ind,
     reply->charge_event[idx].health_plan_id = c.health_plan_id, reply->charge_event[idx].epsdt_ind
      = c.epsdt_ind, reply->charge_event[idx].encntr_bill_type_cd = validate(request->process_event[
      idx].encntr_bill_type_cd,0.0)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE fillchargeevent(b)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (repeventloop = 1 TO repeventcnt)
    IF ((reply->charge_event[repeventloop].charge_event_id > 0))
     SET repactcnt = size(reply->charge_event[repeventloop].charge_event_act,5)
     IF (repactcnt > 0)
      IF ((g_srvproperties->workloadind=1))
       CALL echo("Look up position_cd for cea_prsnl_id")
       SELECT INTO "nl:"
        c.cea_prsnl_id, p.physician_ind, p.position_cd
        FROM charge_event_act c,
         prsnl p,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_event_act_id=reply->charge_event[repeventloop].charge_event_act[d.seq].
         charge_event_act_id)
          AND c.active_ind=1)
         JOIN (p
         WHERE p.person_id=c.cea_prsnl_id)
        DETAIL
         reply->charge_event[repeventloop].charge_event_act[d.seq].position_cd = p.position_cd
        WITH nocounter
       ;end select
      ENDIF
      SET reply->charge_event[repeventloop].suspend_flag = esuspend_unknown
      IF ((reply->charge_event[repeventloop].ext_item_event_cont_cd=g_cs13016->ord_id))
       SET reply->charge_event[repeventloop].suspend_flag = esuspend_missingorder
      ENDIF
      CALL echo("Check charge_event_act for info on current event")
      DECLARE curceatypecd = f8
      SET curceatypecd = 0
      SELECT INTO "nl:"
       c.charge_type_cd, c.cea_type_cd, c.service_loc_cd
       FROM charge_event_act c
       WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
        AND c.active_ind=1
       ORDER BY c.cea_type_cd, c.activity_dt_tm DESC
       DETAIL
        IF (curceatypecd != c.cea_type_cd)
         curceatypecd = c.cea_type_cd
         IF ((c.charge_type_cd=g_cs13028->no_charge))
          reply->charge_event[repeventloop].no_charge_ind = 1
         ENDIF
         IF ((c.cea_type_cd=g_cs13029->ordered))
          reply->charge_event[repeventloop].suspend_flag = esuspend_ok, reply->charge_event[
          repeventloop].ord_loc_cd = c.service_loc_cd
          FOR (repactloop = 1 TO repactcnt)
           IF ((reply->charge_event[repeventloop].charge_event_act[repactloop].quantity <= 0))
            reply->charge_event[repeventloop].charge_event_act[repactloop].quantity = c.quantity
           ENDIF
           ,
           IF ((reply->charge_event[repeventloop].charge_event_act[repactloop].rx_quantity <= 0))
            reply->charge_event[repeventloop].charge_event_act[repactloop].rx_quantity = c.quantity
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM person p
       WHERE (p.person_id=reply->charge_event[repeventloop].person_id)
       DETAIL
        IF (validate(reply->charge_event[repeventloop].logical_domain_id))
         reply->charge_event[repeventloop].logical_domain_id = p.logical_domain_id
        ENDIF
       WITH nocounter
      ;end select
      IF ((reply->charge_event[repeventloop].suspend_flag=esuspend_missingorder))
       CALL pause(1)
       SELECT INTO "nl:"
        c.charge_type_cd, c.cea_type_cd, c.service_loc_cd
        FROM charge_event_act c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.active_ind=1
        ORDER BY c.cea_type_cd, c.activity_dt_tm DESC
        DETAIL
         IF (curceatypecd != c.cea_type_cd)
          curceatypecd = c.cea_type_cd
          IF ((c.charge_type_cd=g_cs13028->no_charge))
           reply->charge_event[repeventloop].no_charge_ind = 1
          ENDIF
          IF ((c.cea_type_cd=g_cs13029->ordered))
           reply->charge_event[repeventloop].suspend_flag = esuspend_ok, reply->charge_event[
           repeventloop].ord_loc_cd = c.service_loc_cd
           FOR (repactloop = 1 TO repactcnt)
            IF ((reply->charge_event[repeventloop].charge_event_act[repactloop].quantity <= 0))
             reply->charge_event[repeventloop].charge_event_act[repactloop].quantity = c.quantity
            ENDIF
            ,
            IF ((reply->charge_event[repeventloop].charge_event_act[repactloop].rx_quantity <= 0))
             reply->charge_event[repeventloop].charge_event_act[repactloop].rx_quantity = c.quantity
            ENDIF
           ENDFOR
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      CALL echo("Check for physicians on current event")
      SELECT INTO "nl:"
       FROM charge_event_act c,
        prsnl p1,
        charge_event_act_prsnl ceap,
        prsnl p2
       PLAN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.active_ind=1)
        JOIN (p1
        WHERE p1.person_id=c.cea_prsnl_id)
        JOIN (ceap
        WHERE (ceap.charge_event_act_id= Outerjoin(c.charge_event_act_id)) )
        JOIN (p2
        WHERE (p2.person_id= Outerjoin(ceap.prsnl_id))
         AND (p2.physician_ind= Outerjoin(1)) )
       ORDER BY c.insert_dt_tm, c.charge_event_act_id, c.activity_dt_tm DESC
       HEAD c.charge_event_act_id
        IF (p1.physician_ind=1)
         IF ((c.cea_type_cd=g_cs13029->ordered))
          IF ((reply->charge_event[repeventloop].ord_phys_id <= 0))
           reply->charge_event[repeventloop].ord_phys_id = p1.person_id
          ENDIF
         ELSEIF ((((c.cea_type_cd=g_cs13029->verified)) OR ((((c.cea_type_cd=g_cs13029->verifying))
          OR ((((c.cea_type_cd=g_cs13029->signout)) OR ((c.cea_type_cd=g_cs13029->complete))) )) )) )
          IF ((reply->charge_event[repeventloop].verify_phys_id <= 0))
           reply->charge_event[repeventloop].verify_phys_id = p1.person_id
          ENDIF
         ELSEIF ((((c.cea_type_cd=g_cs13029->performed)) OR ((c.cea_type_cd=g_cs13029->performing)))
         )
          IF ((reply->charge_event[repeventloop].perf_phys_id <= 0))
           reply->charge_event[repeventloop].perf_phys_id = p1.person_id
          ENDIF
         ENDIF
        ENDIF
       DETAIL
        IF ((ceap.prsnl_type_cd=g_cs13029->ordered))
         IF ((reply->charge_event[repeventloop].ord_phys_id <= 0))
          reply->charge_event[repeventloop].ord_phys_id = p2.person_id
         ENDIF
        ELSEIF ((((ceap.prsnl_type_cd=g_cs13029->verified)) OR ((((ceap.prsnl_type_cd=g_cs13029->
        signout)) OR ((ceap.prsnl_type_cd=g_cs13029->complete))) )) )
         IF ((reply->charge_event[repeventloop].verify_phys_id <= 0))
          reply->charge_event[repeventloop].verify_phys_id = p2.person_id
         ENDIF
        ELSEIF ((ceap.prsnl_type_cd=g_cs13029->performed))
         IF ((reply->charge_event[repeventloop].perf_phys_id <= 0))
          reply->charge_event[repeventloop].perf_phys_id = p2.person_id
         ENDIF
        ELSEIF ((ceap.prsnl_type_cd=g_cs13029->referred))
         IF ((reply->charge_event[repeventloop].ref_phys_id <= 0))
          reply->charge_event[repeventloop].ref_phys_id = p2.person_id
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      CALL echo("Read charge_event_mod table for current event")
      SET mod_cnt = 0
      SELECT INTO "nl:"
       cem.charge_event_id
       FROM charge_event_mod cem
       WHERE (cem.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
        AND (cem.charge_event_mod_type_cd != g_cs13019->srv_diag)
        AND cem.active_ind=1
       DETAIL
        IF ((( NOT (iscptmodifier(cem.field1_id))) OR ( NOT (isignoredeventmodifier(repeventloop,cem
         .field6)))) )
         mod_cnt += 1, stat = alterlist(reply->charge_event[repeventloop].mods.charge_mods,mod_cnt),
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].charge_event_mod_type_cd = cem
         .charge_event_mod_type_cd,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field1 = cem.field1, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field2 = cem.field2, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field3 = cem.field3,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field4 = cem.field4, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field5 = cem.field5, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field6 = cem.field6,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field7 = cem.field7, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field8 = cem.field8, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field9 = cem.field9,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field10 = cem.field10, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field1_id = cem.field1_id, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field2_id = cem.field2_id,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field3_id = cem.field3_id, reply
         ->charge_event[repeventloop].mods.charge_mods[mod_cnt].field4_id = cem.field4_id, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].field5_id = cem.field5_id,
         reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].nomen_id = cem.nomen_id, reply->
         charge_event[repeventloop].mods.charge_mods[mod_cnt].cm1_nbr = cem.cm1_nbr, stat = assign(
          validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].code1_cd),cem.code1_cd
          ),
         stat = assign(validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].
           charge_mod_source_cd),cs4518006_copyfromcem_cd)
         IF (validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].activity_dt_tm))
          reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].activity_dt_tm = cem
          .activity_dt_tm
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      CALL echo("Get list of parent events and info from ordered event")
      SET done = 0
      SET parentcnt = 0
      SET cureventid = reply->charge_event[repeventloop].charge_event_id
      SET p_event_id = reply->charge_event[repeventloop].ext_parent_event_id
      SET p_event_cd = reply->charge_event[repeventloop].ext_parent_event_cont_cd
      SET mod_cnt = size(reply->charge_event[repeventloop].mods.charge_mods,5)
      WHILE (done=0
       AND p_event_id > 0
       AND p_event_cd > 0)
        SET done = 1
        SELECT INTO "nl:"
         cea.cea_prsnl_id, p.person_id, p.physician_ind
         FROM charge_event c,
          charge_event_act cea,
          prsnl p1,
          charge_event_act_prsnl ceap,
          prsnl p2
         PLAN (c
          WHERE (c.ext_m_event_id=reply->charge_event[repeventloop].ext_master_event_id)
           AND (c.ext_m_event_cont_cd=reply->charge_event[repeventloop].ext_master_event_cont_cd)
           AND c.ext_i_event_id=p_event_id
           AND c.ext_i_event_cont_cd=p_event_cd)
          JOIN (cea
          WHERE cea.charge_event_id=c.charge_event_id
           AND cea.active_ind=1)
          JOIN (p1
          WHERE (p1.person_id= Outerjoin(cea.cea_prsnl_id)) )
          JOIN (ceap
          WHERE (ceap.charge_event_act_id= Outerjoin(cea.charge_event_act_id)) )
          JOIN (p2
          WHERE (p2.person_id= Outerjoin(ceap.prsnl_id))
           AND (p2.physician_ind= Outerjoin(1)) )
         ORDER BY cea.insert_dt_tm, cea.charge_event_act_id, cea.activity_dt_tm DESC
         HEAD cea.charge_event_act_id
          IF (p1.physician_ind=1
           AND (cea.cea_type_cd=g_cs13029->ordered)
           AND (reply->charge_event[repeventloop].ord_phys_id <= 0))
           reply->charge_event[repeventloop].ord_phys_id = p1.person_id
          ENDIF
         DETAIL
          IF ((ceap.prsnl_type_cd=g_cs13029->ordered))
           IF ((reply->charge_event[repeventloop].ord_phys_id <= 0))
            reply->charge_event[repeventloop].ord_phys_id = p2.person_id
           ENDIF
          ELSEIF ((((ceap.prsnl_type_cd=g_cs13029->verified)) OR ((((ceap.prsnl_type_cd=g_cs13029->
          signout)) OR ((ceap.prsnl_type_cd=g_cs13029->complete))) )) )
           IF ((reply->charge_event[repeventloop].verify_phys_id <= 0))
            reply->charge_event[repeventloop].verify_phys_id = p2.person_id
           ENDIF
          ELSEIF ((ceap.prsnl_type_cd=g_cs13029->performed))
           IF ((reply->charge_event[repeventloop].perf_phys_id <= 0))
            reply->charge_event[repeventloop].perf_phys_id = p2.person_id
           ENDIF
          ELSEIF ((ceap.prsnl_type_cd=g_cs13029->referred))
           IF ((reply->charge_event[repeventloop].ref_phys_id <= 0))
            reply->charge_event[repeventloop].ref_phys_id = p2.person_id
           ENDIF
          ENDIF
         WITH nocounter
        ;end select
        IF ((reply->charge_event[repeventloop].suspend_flag=esuspend_unknown)
         AND (p_event_cd=g_cs13016->ord_id))
         SET reply->charge_event[repeventloop].suspend_flag = esuspend_parentmissingorder
        ENDIF
        SET isradbillonly = 0
        IF ((reply->charge_event[repeventloop].ext_item_reference_cont_cd=cs13016_taskassay))
         SELECT INTO "nl:"
          FROM discrete_task_assay ta
          PLAN (ta
           WHERE (ta.task_assay_cd=reply->charge_event[repeventloop].ext_item_reference_id))
          DETAIL
           IF (ta.activity_type_cd=cs106_radiology
            AND ta.default_result_type_cd=cs289_billonly)
            isradbillonly = 1
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
        SET curceatypecd = 0
        SELECT INTO "nl:"
         c.ext_m_event_id, c.ext_m_event_cont_cd, c.ext_p_event_id,
         c.ext_p_event_cont_cd, c.ext_p_reference_id, c.ext_p_reference_cont_cd,
         c.ext_i_reference_id, c.ext_i_reference_cont_cd, c.research_account_id,
         c.collection_priority_cd, c.report_priority_cd, c.perf_loc_cd,
         cea.cea_type_cd, cea.charge_type_cd, cea.service_loc_cd
         FROM charge_event c,
          charge_event_act cea,
          charge_event_mod cem,
          code_value_extension cve
         PLAN (c
          WHERE (c.ext_m_event_id=reply->charge_event[repeventloop].ext_master_event_id)
           AND (c.ext_m_event_cont_cd=reply->charge_event[repeventloop].ext_master_event_cont_cd)
           AND c.ext_i_event_id=p_event_id
           AND c.ext_i_event_cont_cd=p_event_cd
           AND c.ext_p_event_id != p_event_id
           AND c.charge_event_id != cureventid)
          JOIN (cea
          WHERE (cea.charge_event_id= Outerjoin(c.charge_event_id))
           AND (cea.cea_type_cd= Outerjoin(g_cs13029->ordered))
           AND (cea.active_ind= Outerjoin(1)) )
          JOIN (cem
          WHERE (cem.charge_event_id= Outerjoin(c.charge_event_id))
           AND (cem.charge_event_mod_type_cd!= Outerjoin(g_cs13019->srv_diag))
           AND (cem.active_ind= Outerjoin(1)) )
          JOIN (cve
          WHERE (cve.code_value= Outerjoin(cem.field3_id))
           AND (cve.code_set= Outerjoin(codeset_17769))
           AND (cve.field_name= Outerjoin("Rad Bill Only Exclude")) )
         ORDER BY c.charge_event_id, cem.charge_event_mod_id, cea.charge_event_act_id,
          cea.activity_dt_tm DESC
         HEAD c.charge_event_id
          done = 0, parentcnt += 1, stat = alterlist(reply->charge_event[repeventloop].parent_events,
           parentcnt),
          reply->charge_event[repeventloop].parent_events[parentcnt].ext_p_ref_id = c
          .ext_p_reference_id, reply->charge_event[repeventloop].parent_events[parentcnt].
          ext_p_ref_cd = c.ext_p_reference_cont_cd, reply->charge_event[repeventloop].parent_events[
          parentcnt].ext_i_ref_id = c.ext_i_reference_id,
          reply->charge_event[repeventloop].parent_events[parentcnt].ext_i_ref_cd = c
          .ext_i_reference_cont_cd, cureventid = c.charge_event_id, p_event_id = c.ext_p_event_id,
          p_event_cd = c.ext_p_event_cont_cd
          IF ((reply->charge_event[repeventloop].abn_status_cd <= 0))
           reply->charge_event[repeventloop].abn_status_cd = c.abn_status_cd
          ENDIF
         HEAD cem.charge_event_mod_id
          IF (cem.charge_event_mod_id > 0)
           nfounddup = 0
           FOR (dup_cnt = 1 TO size(reply->charge_event[repeventloop].mods.charge_mods,5))
             IF ((cem.charge_event_mod_type_cd=reply->charge_event[repeventloop].mods.charge_mods[
             dup_cnt].charge_event_mod_type_cd)
              AND uar_get_code_meaning(cem.field1_id)=uar_get_code_meaning(reply->charge_event[
              repeventloop].mods.charge_mods[dup_cnt].field1_id)
              AND (cem.field2_id=reply->charge_event[repeventloop].mods.charge_mods[dup_cnt].
             field2_id)
              AND (cem.field6=reply->charge_event[repeventloop].mods.charge_mods[dup_cnt].field6))
              nfounddup = 1
             ENDIF
           ENDFOR
           IF (nfounddup=0
            AND (( NOT (iscptmodifier(cem.field1_id))) OR ( NOT (isignoredeventmodifier(repeventloop,
            cem.field6)))) )
            IF ((( NOT (isradbillonly)) OR ((( NOT (iscptmodifier(cem.field1_id))) OR ( NOT (
            cnvtupper(cve.field_value)="Y"))) )) )
             mod_cnt += 1, stat = alterlist(reply->charge_event[repeventloop].mods.charge_mods,
              mod_cnt), reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].
             charge_event_mod_type_cd = cem.charge_event_mod_type_cd,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field1 = cem.field1, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field2 = cem.field2, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field3 = cem.field3,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field4 = cem.field4, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field5 = cem.field5, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field6 = cem.field6,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field7 = cem.field7, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field8 = cem.field8, reply->
             charge_event[repeventloop].mods.charge_mods[mod_cnt].field9 = cem.field9,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field10 = cem.field10, reply
             ->charge_event[repeventloop].mods.charge_mods[mod_cnt].field1_id = cem.field1_id, reply
             ->charge_event[repeventloop].mods.charge_mods[mod_cnt].field2_id = cem.field2_id,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field3_id = cem.field3_id,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field4_id = cem.field4_id,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].field5_id = cem.field5_id,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].nomen_id = cem.nomen_id,
             reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].cm1_nbr = cem.cm1_nbr, stat
              = assign(validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].code1_cd),
              cem.code1_cd),
             stat = assign(validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].
               charge_mod_source_cd),cs4518006_copyfromcem_cd)
             IF (validate(reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].activity_dt_tm)
             )
              reply->charge_event[repeventloop].mods.charge_mods[mod_cnt].activity_dt_tm = cem
              .activity_dt_tm
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         HEAD cea.charge_event_act_id
          IF (cea.charge_event_act_id > 0)
           reply->charge_event[repeventloop].suspend_flag = esuspend_ok, reply->charge_event[
           repeventloop].cancelled_ind = c.cancelled_ind
           IF ((reply->charge_event[repeventloop].research_acct_id <= 0))
            reply->charge_event[repeventloop].research_acct_id = c.research_account_id
           ENDIF
           IF ((reply->charge_event[repeventloop].collection_priority_cd <= 0))
            reply->charge_event[repeventloop].collection_priority_cd = c.collection_priority_cd
           ENDIF
           IF ((reply->charge_event[repeventloop].report_priority_cd <= 0))
            reply->charge_event[repeventloop].report_priority_cd = c.report_priority_cd
           ENDIF
           IF ((reply->charge_event[repeventloop].perf_loc_cd <= 0))
            reply->charge_event[repeventloop].perf_loc_cd = c.perf_loc_cd
           ENDIF
           IF (curceatypecd != cea.cea_type_cd)
            curceatypecd = cea.cea_type_cd
            IF ((cea.charge_type_cd=g_cs13028->no_charge))
             reply->charge_event[repeventloop].no_charge_ind = 1
            ENDIF
            IF ((reply->charge_event[repeventloop].ord_loc_cd <= 0))
             reply->charge_event[repeventloop].ord_loc_cd = cea.service_loc_cd
            ENDIF
           ENDIF
          ENDIF
         DETAIL
          null
         WITH nocounter
        ;end select
      ENDWHILE
      IF ((reply->charge_event[repeventloop].suspend_flag=esuspend_unknown))
       SET reply->charge_event[repeventloop].suspend_flag = esuspend_ok
      ENDIF
     ENDIF
    ENDIF
    IF (validate(reply->charge_event[repeventloop].provider_specialty_cd,- (1.0)) >= 0.00)
     CALL echo("Check for provider specialty")
     CALL getproviderspecialty(repeventloop)
    ENDIF
   ENDFOR
   CALL echo("Look up research org id")
   SELECT INTO "nl:"
    r.organization_id
    FROM research_account r,
     (dummyt d  WITH seq = value(repeventcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0)
      AND (reply->charge_event[d.seq].research_acct_id > 0))
     JOIN (r
     WHERE (r.research_account_id=reply->charge_event[d.seq].research_acct_id))
    DETAIL
     reply->charge_event[d.seq].research_org_id = r.organization_id
    WITH nocounter
   ;end select
   CALL echo("Look up encounter info")
   SELECT INTO "nl:"
    e.encntr_type_cd, e.organization_id, e.financial_class_cd,
    e.loc_nurse_unit_cd, e.med_service_cd, ef.bill_type_cd,
    epr1.health_plan_id, epr.health_plan_id
    FROM encounter e,
     (dummyt d  WITH seq = value(repeventcnt)),
     encntr_financial ef,
     encntr_plan_cob epc,
     encntr_plan_cob_reltn epcr,
     encntr_plan_reltn epr1,
     encntr_plan_reltn epr
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0))
     JOIN (e
     WHERE (e.encntr_id=reply->charge_event[d.seq].encntr_id))
     JOIN (ef
     WHERE (ef.encntr_financial_id= Outerjoin(e.encntr_financial_id)) )
     JOIN (epr
     WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
      AND (epr.priority_seq= Outerjoin(1))
      AND (epr.active_ind= Outerjoin(1)) )
     JOIN (epc
     WHERE (epc.encntr_id= Outerjoin(e.encntr_id))
      AND (epc.active_ind= Outerjoin(1)) )
     JOIN (epcr
     WHERE (epcr.encntr_plan_cob_id= Outerjoin(epc.encntr_plan_cob_id))
      AND (epcr.priority_seq= Outerjoin(1))
      AND (epcr.active_ind= Outerjoin(1)) )
     JOIN (epr1
     WHERE (epr1.encntr_plan_reltn_id= Outerjoin(epcr.encntr_plan_reltn_id))
      AND (epr1.active_ind= Outerjoin(1)) )
    DETAIL
     IF (ef.encntr_financial_id > 0
      AND (reply->charge_event[d.seq].encntr_bill_type_cd < 1))
      reply->charge_event[d.seq].encntr_bill_type_cd = ef.bill_type_cd
     ENDIF
     reply->charge_event[d.seq].encntr_type_cd = e.encntr_type_cd, reply->charge_event[d.seq].
     med_service_cd = e.med_service_cd, reply->charge_event[d.seq].encntr_org_id = e.organization_id,
     reply->charge_event[d.seq].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->charge_event[d.seq].
     encntr_type_class_cd = e.encntr_type_class_cd
     IF ((reply->charge_event[d.seq].fin_class_cd <= 0))
      reply->charge_event[d.seq].fin_class_cd = e.financial_class_cd
     ENDIF
     IF (epc.encntr_plan_cob_id > 0)
      IF (epr1.encntr_plan_reltn_id > 0
       AND (reply->charge_event[d.seq].health_plan_id <= 0))
       repactcnt = size(reply->charge_event[d.seq].charge_event_act,5)
       IF (repactcnt > 0
        AND epc.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm)
        AND epc.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm)
        AND epr1.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm)
        AND epr1.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm))
        reply->charge_event[d.seq].health_plan_id = epr1.health_plan_id
       ENDIF
      ENDIF
     ELSE
      IF (epr.encntr_plan_reltn_id > 0
       AND (reply->charge_event[d.seq].health_plan_id <= 0))
       repactcnt = size(reply->charge_event[d.seq].charge_event_act,5)
       IF (repactcnt > 0
        AND epr.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm)
        AND epr.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
        service_dt_tm))
        reply->charge_event[d.seq].health_plan_id = epr.health_plan_id
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (size(reply->charge_event,5) >= 1)
    IF (validate(reply->charge_event[1].primaryhealthplancount)=1)
     CALL addprimaryhealthplans("NULL")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    o.organization_id
    FROM org_plan_reltn o,
     (dummyt d  WITH seq = value(repeventcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (reply->charge_event[d.seq].health_plan_id > 0.0))
     JOIN (o
     WHERE (o.health_plan_id=reply->charge_event[d.seq].health_plan_id)
      AND o.org_plan_reltn_cd=carrier_370_cd
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     reply->charge_event[d.seq].insurance_org_id = o.organization_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group_reltn p,
     (dummyt d  WITH seq = value(repeventcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (((reply->charge_event[d.seq].verify_phys_id > 0.0)) OR ((reply->charge_event[d.seq].
     perf_phys_id > 0.0))) )
     JOIN (p
     WHERE p.person_id IN (reply->charge_event[d.seq].verify_phys_id, reply->charge_event[d.seq].
     perf_phys_id)
      AND p.person_id != 0.0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD d.seq
     groupcnt = 0
    DETAIL
     groupcnt += 1, stat = alterlist(reply->charge_event[d.seq].renderingphysgroups,groupcnt), reply
     ->charge_event[d.seq].renderingphysgroups[groupcnt].group_id = p.prsnl_group_id
    WITH nocounter
   ;end select
   SET groupcnt = 0
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group_reltn p,
     (dummyt d  WITH seq = value(repeventcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (reply->charge_event[d.seq].ord_phys_id > 0.0))
     JOIN (p
     WHERE (p.person_id=reply->charge_event[d.seq].ord_phys_id)
      AND p.person_id != 0.0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD d.seq
     groupcnt = 0
    DETAIL
     groupcnt += 1, stat = alterlist(reply->charge_event[d.seq].orderingphysgroups,groupcnt), reply->
     charge_event[d.seq].orderingphysgroups[groupcnt].group_id = p.prsnl_group_id
    WITH nocounter
   ;end select
   CALL echo("Look up health plan")
 END ;Subroutine
 SUBROUTINE filloutworkload(c_event,c_workload)
   SET stat = alterlist(reply->charge_event[c_event].workload,c_workload)
   SET reply->charge_event[c_event].workload[c_workload].workload_id = w.workload_id
   SET reply->charge_event[c_event].workload[c_workload].charge_event_act_id = w.charge_event_act_id
   SET reply->charge_event[c_event].workload[c_workload].charge_event_id = w.charge_event_id
   SET reply->charge_event[c_event].workload[c_workload].parent_workload_id = w.parent_workload_id
   SET reply->charge_event[c_event].workload[c_workload].bill_item_id = w.bill_item_id
   SET reply->charge_event[c_event].workload[c_workload].org_id = w.org_id
   SET reply->charge_event[c_event].workload[c_workload].institution_cd = w.institution_cd
   SET reply->charge_event[c_event].workload[c_workload].dept_cd = w.dept_cd
   SET reply->charge_event[c_event].workload[c_workload].section_cd = w.section_cd
   SET reply->charge_event[c_event].workload[c_workload].subsection_cd = w.subsection_cd
   SET reply->charge_event[c_event].workload[c_workload].service_resource_cd = w.service_resource_cd
   SET reply->charge_event[c_event].workload[c_workload].workload_standard_id = w
   .workload_standard_id
   SET reply->charge_event[c_event].workload[c_workload].person_id = w.person_id
   SET reply->charge_event[c_event].workload[c_workload].encntr_id = w.encntr_id
   SET reply->charge_event[c_event].workload[c_workload].accession = w.accession
   SET reply->charge_event[c_event].workload[c_workload].projected_ind = w.projected_ind
   SET reply->charge_event[c_event].workload[c_workload].wl_code = w.wl_code
   SET reply->charge_event[c_event].workload[c_workload].wl_code_desc = w.wl_code_desc
   SET reply->charge_event[c_event].workload[c_workload].units = w.units
   SET reply->charge_event[c_event].workload[c_workload].multiplier = w.multiplier
   SET reply->charge_event[c_event].workload[c_workload].extended_units = w.extended_units
   SET reply->charge_event[c_event].workload[c_workload].pat_loc_cd = w.pat_loc_cd
   SET reply->charge_event[c_event].workload[c_workload].prsnl_id = w.prsnl_id
   SET reply->charge_event[c_event].workload[c_workload].service_dt_tm = w.service_dt_tm
   SET reply->charge_event[c_event].workload[c_workload].projected_dt_tm = w.projected_dt_tm
   SET reply->charge_event[c_event].workload[c_workload].accrued_dt_tm = w.accrued_dt_tm
   SET reply->charge_event[c_event].workload[c_workload].ord_phys_id = w.ord_phys_id
   SET reply->charge_event[c_event].workload[c_workload].def_bill_item_id = w.def_bill_item_id
   SET reply->charge_event[c_event].workload[c_workload].active_ind = w.active_ind
   SET reply->charge_event[c_event].workload[c_workload].beg_effective_dt_tm = w.beg_effective_dt_tm
   SET reply->charge_event[c_event].workload[c_workload].raw_count = w.raw_count
   SET reply->charge_event[c_event].workload[c_workload].quantity = w.qty
   SET reply->charge_event[c_event].workload[c_workload].position_cd = w.position_cd
   SET reply->charge_event[c_event].workload[c_workload].item_for_count_cd = w.item_for_count_cd
   SET reply->charge_event[c_event].workload[c_workload].activity_type_cd = w.activity_type_cd
   SET reply->charge_event[c_event].workload[c_workload].encntr_type_cd = w.encntr_type_cd
   SET reply->charge_event[c_event].workload[c_workload].wl_book_cd = w.wl_book_cd
   SET reply->charge_event[c_event].workload[c_workload].wl_chapter_cd = w.wl_chapter_cd
   SET reply->charge_event[c_event].workload[c_workload].wl_section_cd = w.wl_section_cd
   SET reply->charge_event[c_event].workload[c_workload].wl_code_sched_cd = w.wl_code_sched_cd
   SET reply->charge_event[c_event].workload[c_workload].med_service_cd = w.med_service_cd
   SET reply->charge_event[c_event].workload[c_workload].workload_type_cd = w.workload_type_cd
   SET reply->charge_event[c_event].workload[c_workload].repeat_ind = w.repeat_ind
 END ;Subroutine
 SUBROUTINE getchildevents(d_event)
   DECLARE idx = i4 WITH protect, noconstant(0)
   CALL echo("Get child events if event is cancelled")
   SET stat = alterlist(child->list,1)
   SET child->list[1].charge_event_id = reply->charge_event[d_event].charge_event_id
   SET child->list[1].indicator = 1
   SET child->mastereventid = reply->charge_event[d_event].ext_master_event_id
   SET child->mastereventcd = reply->charge_event[d_event].ext_master_event_cont_cd
   SET stat = alterlist(child->items,1)
   SET child->items[1].parenteventid = reply->charge_event[d_event].ext_item_event_id
   SET child->items[1].parenteventcd = reply->charge_event[d_event].ext_item_event_cont_cd
   SET eventcnt = 1
   SET more = 1
   WHILE (more=1)
     SET more = 0
     SELECT INTO "nl:"
      ce.charge_event_id
      FROM charge_event ce,
       (dummyt d  WITH seq = value(size(child->items,5)))
      PLAN (d)
       JOIN (ce
       WHERE (ce.ext_m_event_id=child->mastereventid)
        AND (ce.ext_m_event_cont_cd=child->mastereventcd)
        AND (ce.ext_p_event_id=child->items[d.seq].parenteventid)
        AND (ce.ext_p_event_cont_cd=child->items[d.seq].parenteventcd)
        AND (ce.ext_i_event_id != child->items[d.seq].parenteventid)
        AND ce.cancelled_ind=0)
      DETAIL
       eventcnt += 1, stat = alterlist(child->list,eventcnt), child->list[eventcnt].charge_event_id
        = ce.charge_event_id,
       child->list[eventcnt].indicator = 0
      WITH forupdatewait(ce), nocounter
     ;end select
     SET pid = 0.0
     SET childcnt = 0
     SELECT INTO "nl:"
      ce.charge_event_id
      FROM charge_event ce,
       (dummyt d  WITH seq = value(eventcnt))
      PLAN (d
       WHERE (child->list[d.seq].indicator=0))
       JOIN (ce
       WHERE (ce.charge_event_id=child->list[d.seq].charge_event_id))
      ORDER BY ce.ext_i_event_id, ce.ext_i_event_cont_cd
      DETAIL
       child->list[d.seq].indicator = 1
       IF (ce.ext_i_event_id != pid)
        more = 1, pid = ce.ext_i_event_id, childcnt += 1,
        stat = alterlist(child->items,childcnt), child->items[childcnt].parenteventid = ce
        .ext_i_event_id, child->items[childcnt].parenteventcd = ce.ext_i_event_cont_cd
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
   SET chargecnt = 0
   SET chargemodcnt = 0
   SELECT INTO "nl:"
    FROM charge c,
     (dummyt d  WITH seq = value(size(child->list,5)))
    PLAN (d)
     JOIN (c
     WHERE (c.charge_event_id=child->list[d.seq].charge_event_id)
      AND c.offset_charge_item_id=0.0
      AND c.active_ind=1
      AND  EXISTS (
     (SELECT
      ce.charge_event_id
      FROM charge_event ce
      WHERE (ce.charge_event_id=child->list[d.seq].charge_event_id)
       AND ce.cancelled_ind=0)))
    DETAIL
     templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
     templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
    WITH nocounter, forupdatewait(c)
   ;end select
   IF ((templist->charge_count > 0))
    SELECT INTO "nl:"
     FROM charge c,
      charge_mod cm,
      (dummyt d  WITH seq = value(templist->charge_count))
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
      JOIN (cm
      WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
       AND (cm.active_ind= Outerjoin(1)) )
     ORDER BY c.charge_item_id
     HEAD c.charge_item_id
      cancel_ind = 1, chargecnt += 1,
      CALL filloutcharge(d_event,chargecnt),
      chargemodcnt = 0
     DETAIL
      chargemodcnt += 1,
      CALL filloutchargemod(d_event,chargecnt,chargemodcnt)
     WITH nocounter
    ;end select
   ENDIF
   UPDATE  FROM charge_event c
    SET c.cancelled_ind = 1
    WHERE expand(idx,1,eventcnt,c.charge_event_id,child->list[idx].charge_event_id)
    WITH nocounter, expand = 1
   ;end update
 END ;Subroutine
 SUBROUTINE getcharges(c)
   FOR (repeventloop = 1 TO repeventcnt)
     IF ((reply->charge_event[repeventloop].charge_event_id > 0))
      SET repactcnt = size(reply->charge_event[repeventloop].charge_event_act,5)
      CALL echo("Look for cancelled activity and get all charges for this event and it's children")
      SET cancel_ind = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(repactcnt))
       WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->cancel
       )
        AND (reply->charge_event[repeventloop].cancelled_ind=0)
       DETAIL
        cancel_ind = 1
       WITH nocounter
      ;end select
      IF (cancel_ind > 0)
       CALL getchildevents(repeventloop)
      ENDIF
      SELECT INTO "nl:"
       FROM charge_event ce,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        reverse))
        JOIN (ce
        WHERE (ce.charge_event_id=reply->charge_event[repeventloop].charge_event_id))
       DETAIL
        null
       WITH forupdatewait(ce), nocounter
      ;end select
      CALL echo("Look for uncomplete activity and get charges for the complete activity")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        uncomplete))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.offset_charge_item_id=0.0
         AND c.active_ind=1
         AND  EXISTS (
        (SELECT
         cea.charge_event_act_id
         FROM charge_event_act cea
         WHERE cea.charge_event_id=c.charge_event_id
          AND cea.charge_event_act_id=c.charge_event_act_id
          AND (cea.cea_type_cd=g_cs13029->complete))))
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter, forupdatewait(c)
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      CALL echo("Look for reverse or bbreturn activity and get charges for this event")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd IN (g_cs13029->
        reverse, g_cs13029->bbreturn)))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND (c.person_id=reply->charge_event[repeventloop].person_id)
         AND (c.encntr_id=reply->charge_event[repeventloop].encntr_id)
         AND c.offset_charge_item_id=0
         AND c.active_ind=1)
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter, forupdatewait(c)
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      CALL echo("Look for uncoluninlab activity and get charges for the colllected/inlab activity")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        uncoluninlab))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.offset_charge_item_id=0.0
         AND c.active_ind=1
         AND  EXISTS (
        (SELECT
         cea.charge_event_id
         FROM charge_event_act cea
         WHERE cea.charge_event_id=c.charge_event_id
          AND cea.charge_event_act_id=c.charge_event_act_id
          AND (((cea.cea_type_cd=g_cs13029->collected)) OR ((cea.cea_type_cd=g_cs13029->inlab))) )))
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter, forupdatewait(c)
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      IF ((g_srvproperties->workloadind=1))
       CALL echo("Look for uncomplete activity and get workload for complete activity")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM charge_event_act cea,
         workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         uncomplete))
         JOIN (cea
         WHERE (cea.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND (cea.cea_type_cd=g_cs13029->complete))
         JOIN (w
         WHERE w.charge_event_id=cea.charge_event_id
          AND w.charge_event_act_id=cea.charge_event_act_id
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
       CALL echo("Look for reverse activity and get workload for this event")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         reverse))
         JOIN (w
         WHERE (w.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
       CALL echo("Look for uncoluninlab activity and get workload for collected/inlab activity")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM charge_event_act cea,
         workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         uncoluninlab))
         JOIN (cea
         WHERE (cea.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND (((cea.cea_type_cd=g_cs13029->collected)) OR ((cea.cea_type_cd=g_cs13029->inlab))) )
         JOIN (w
         WHERE w.charge_event_id=cea.charge_event_id
          AND w.charge_event_act_id=cea.charge_event_act_id
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getchargesnolocks(c)
   FOR (repeventloop = 1 TO repeventcnt)
     IF ((reply->charge_event[repeventloop].charge_event_id > 0))
      SET repactcnt = size(reply->charge_event[repeventloop].charge_event_act,5)
      CALL echo("Look for cancelled activity and get all charges for this event and it's children")
      SET cancel_ind = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(repactcnt))
       WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->cancel
       )
        AND (reply->charge_event[repeventloop].cancelled_ind=0)
       DETAIL
        cancel_ind = 1
       WITH nocounter
      ;end select
      IF (cancel_ind > 0)
       CALL getchildevents(repeventloop)
      ENDIF
      SELECT INTO "nl:"
       FROM charge_event ce,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        reverse))
        JOIN (ce
        WHERE (ce.charge_event_id=reply->charge_event[repeventloop].charge_event_id))
       DETAIL
        null
       WITH nocounter
      ;end select
      CALL echo("Look for uncomplete activity and get charges for the complete activity")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        uncomplete))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.offset_charge_item_id=0.0
         AND c.active_ind=1
         AND  EXISTS (
        (SELECT
         cea.charge_event_act_id
         FROM charge_event_act cea
         WHERE cea.charge_event_id=c.charge_event_id
          AND cea.charge_event_act_id=c.charge_event_act_id
          AND (cea.cea_type_cd=g_cs13029->complete))))
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      CALL echo("Look for reverse or bbreturn activity and get charges for this event")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd IN (g_cs13029->
        reverse, g_cs13029->bbreturn)))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND (c.person_id=reply->charge_event[repeventloop].person_id)
         AND (c.encntr_id=reply->charge_event[repeventloop].encntr_id)
         AND c.offset_charge_item_id=0
         AND c.active_ind=1)
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      CALL echo("Look for uncoluninlab activity and get charges for the colllected/inlab activity")
      SET chargecnt = 0
      SET chargemodcnt = 0
      FREE SET templist
      RECORD templist(
        1 charge_count = i4
        1 charges[*]
          2 charge_item_id = f8
      )
      SELECT INTO "nl:"
       FROM charge c,
        (dummyt d  WITH seq = value(repactcnt))
       PLAN (d
        WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
        uncoluninlab))
        JOIN (c
        WHERE (c.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
         AND c.offset_charge_item_id=0.0
         AND c.active_ind=1
         AND  EXISTS (
        (SELECT
         cea.charge_event_id
         FROM charge_event_act cea
         WHERE cea.charge_event_id=c.charge_event_id
          AND cea.charge_event_act_id=c.charge_event_act_id
          AND (((cea.cea_type_cd=g_cs13029->collected)) OR ((cea.cea_type_cd=g_cs13029->inlab))) )))
       DETAIL
        templist->charge_count += 1, stat = alterlist(templist->charges,templist->charge_count),
        templist->charges[templist->charge_count].charge_item_id = c.charge_item_id
       WITH nocounter
      ;end select
      IF ((templist->charge_count > 0))
       SELECT INTO "nl:"
        FROM charge c,
         charge_mod cm,
         (dummyt d  WITH seq = value(templist->charge_count))
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=templist->charges[d.seq].charge_item_id))
         JOIN (cm
         WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
          AND (cm.active_ind= Outerjoin(1)) )
        ORDER BY c.charge_item_id
        HEAD c.charge_item_id
         chargecnt += 1,
         CALL filloutcharge(repeventloop,chargecnt), chargemodcnt = 0
        DETAIL
         chargemodcnt += 1,
         CALL filloutchargemod(repeventloop,chargecnt,chargemodcnt)
        WITH nocounter
       ;end select
      ENDIF
      IF ((g_srvproperties->workloadind=1))
       CALL echo("Look for uncomplete activity and get workload for complete activity")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM charge_event_act cea,
         workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         uncomplete))
         JOIN (cea
         WHERE (cea.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND (cea.cea_type_cd=g_cs13029->complete))
         JOIN (w
         WHERE w.charge_event_id=cea.charge_event_id
          AND w.charge_event_act_id=cea.charge_event_act_id
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
       CALL echo("Look for reverse activity and get workload for this event")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         reverse))
         JOIN (w
         WHERE (w.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
       CALL echo("Look for uncoluninlab activity and get workload for collected/inlab activity")
       SET workloadcnt = 0
       SELECT INTO "nl:"
        w.workload_id
        FROM charge_event_act cea,
         workload w,
         (dummyt d  WITH seq = value(repactcnt))
        PLAN (d
         WHERE (reply->charge_event[repeventloop].charge_event_act[d.seq].cea_type_cd=g_cs13029->
         uncoluninlab))
         JOIN (cea
         WHERE (cea.charge_event_id=reply->charge_event[repeventloop].charge_event_id)
          AND (((cea.cea_type_cd=g_cs13029->collected)) OR ((cea.cea_type_cd=g_cs13029->inlab))) )
         JOIN (w
         WHERE w.charge_event_id=cea.charge_event_id
          AND w.charge_event_act_id=cea.charge_event_act_id
          AND w.active_ind=1)
        ORDER BY w.workload_id
        DETAIL
         workloadcnt += 1,
         CALL filloutworkload(repeventloop,workloadcnt)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE readreprocess(e_event)
   DECLARE idx = i4 WITH protect, noconstant(0)
   CALL echo("Read charge_event_act table")
   SET actcnt = 0
   SELECT INTO "nl:"
    c.charge_event_act_id
    FROM charge_event_act c
    WHERE expand(idx,1,size(request->process_event[e_event].charge_acts,5),c.charge_event_act_id,
     request->process_event[e_event].charge_acts[idx].charge_event_act_id)
    DETAIL
     actcnt += 1,
     CALL filloutchargeeventact(e_event,actcnt)
    WITH nocounter, expand = 1
   ;end select
   CALL echo("Check cea_prsnl_id to see if it is in the phlebotomy group")
   SELECT INTO "nl:"
    pgr.prsnl_group_id
    FROM prsnl_group_reltn pgr,
     prsnl_group pg
    PLAN (pgr
     WHERE expand(idx,1,actcnt,pgr.person_id,reply->charge_event[e_event].charge_event_act[idx].
      cea_prsnl_id)
      AND pgr.active_ind=1)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id
      AND (pg.prsnl_group_type_cd=g_cs13016->phlebcharge))
    DETAIL
     idx = locateval(idx,1,actcnt,pgr.person_id,reply->charge_event[e_event].charge_event_act[idx].
      cea_prsnl_id)
     WHILE (idx > 0)
      reply->charge_event[e_event].charge_event_act[idx].phleb_group_ind = 1,idx = locateval(idx,(idx
       + 1),actcnt,pgr.person_id,reply->charge_event[e_event].charge_event_act[idx].cea_prsnl_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   CALL echo("Read charges to offset")
   SET chargecnt = 0
   SET chargemodcnt = 0
   SELECT INTO "nl:"
    c.charge_item_id
    FROM charge c,
     charge_mod cm,
     (dummyt d  WITH seq = value(actcnt))
    PLAN (d)
     JOIN (c
     WHERE (c.charge_event_id=reply->charge_event[e_event].charge_event_id)
      AND (c.charge_event_act_id=reply->charge_event[e_event].charge_event_act[d.seq].
     charge_event_act_id)
      AND c.offset_charge_item_id=0)
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
    ORDER BY c.charge_item_id
    HEAD c.charge_item_id
     chargecnt += 1,
     CALL filloutcharge(e_event,chargecnt), chargemodcnt = 0
    DETAIL
     chargemodcnt += 1,
     CALL filloutchargemod(e_event,chargecnt,chargemodcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE readrelease(f_event)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE chrgidx = i4 WITH protect, noconstant(0)
   DECLARE reqchrgidx = i4 WITH protect, noconstant(0)
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   DECLARE cidx = i4 WITH protect, noconstant(0)
   CALL echo("Read charges to release")
   SET chargecnt = 0
   SET chargemodcnt = 0
   DECLARE suspendcnt = i2 WITH protect, noconstant(0)
   DECLARE serverprocessflagind = i2
   SET serverprocessflagind = 0
   SELECT INTO "nl:"
    c.charge_item_id
    FROM charge c,
     charge_mod cm,
     (dummyt d  WITH seq = value(size(request->process_event[f_event].charge_item,5)))
    PLAN (d)
     JOIN (c
     WHERE (c.charge_item_id=request->process_event[f_event].charge_item[d.seq].charge_item_id))
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id))
      AND (cm.active_ind= Outerjoin(1)) )
    ORDER BY c.charge_item_id
    HEAD c.charge_item_id
     chargecnt += 1,
     CALL filloutcharge(f_event,chargecnt)
     IF (((c.server_process_flag=0) OR (c.server_process_flag=null)) )
      serverprocessflagind = 1,
      CALL echo(build("Setting server_process_flag = eFlag_incomplete for charge_item_id:",reply->
       charge_event[f_event].charges[chargecnt].charge_item_id)), reply->charge_event[f_event].
      charges[chargecnt].server_process_flag = eflag_incomplete
     ENDIF
     chargemodcnt = 0
    DETAIL
     chargemodcnt += 1,
     CALL filloutchargemod(f_event,chargecnt,chargemodcnt)
    WITH nocounter
   ;end select
   IF ((request->process_type_cd != g_cs13029->nocommit))
    CALL echo("Inactivate charge and charge_mod rows")
    UPDATE  FROM charge c
     SET c.active_ind = 0
     WHERE expand(idx,1,chargecnt,c.charge_item_id,reply->charge_event[f_event].charges[idx].
      charge_item_id)
      AND c.active_ind=1
     WITH nocounter, expand = 1
    ;end update
    SET stat = alterlist(uptcmreq->objarray,0)
    FOR (cidx = 1 TO chargecnt)
      SELECT INTO "nl:"
       FROM charge_mod cm
       WHERE (cm.charge_item_id=reply->charge_event[f_event].charges[cidx].charge_item_id)
        AND cm.charge_mod_type_cd != cs13019_billencntr_cd
        AND cm.active_ind=1
       DETAIL
        billcdcnt += 1, stat = alterlist(uptcmreq->objarray,billcdcnt), uptcmreq->objarray[billcdcnt]
        .action_type = "DEL",
        uptcmreq->objarray[billcdcnt].charge_mod_id = cm.charge_mod_id, uptcmreq->objarray[billcdcnt]
        .charge_item_id = cm.charge_item_id, uptcmreq->objarray[billcdcnt].updt_cnt = cm.updt_cnt,
        uptcmreq->objarray[billcdcnt].active_ind = 0
       WITH nocounter
      ;end select
    ENDFOR
    IF (size(uptcmreq->objarray,5) <= 0)
     CALL echo("No charge_mods to update")
    ELSE
     EXECUTE afc_val_charge_mod  WITH replace("REQUEST",uptcmreq), replace("REPLY",uptcmrep)
     IF ((uptcmrep->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(uptcmreq)
       CALL echorecord(uptcmrep)
      ENDIF
     ENDIF
    ENDIF
    UPDATE  FROM nomen_entity_reltn ner,
      (dummyt d  WITH seq = value(chargecnt)),
      (dummyt d2  WITH seq = 1)
     SET ner.active_ind = 0
     PLAN (d
      WHERE maxrec(d2,size(reply->charge_event[f_event].charges[d.seq].mods.charge_mods,5)))
      JOIN (d2
      WHERE (reply->charge_event[f_event].charges[d.seq].mods.charge_mods[d2.seq].nomen_id > 0))
      JOIN (ner
      WHERE (ner.nomenclature_id=reply->charge_event[f_event].charges[d.seq].mods.charge_mods[d2.seq]
      .nomen_id)
       AND ner.parent_entity_name="CHARGE"
       AND (ner.parent_entity_id=reply->charge_event[f_event].charges[d.seq].charge_item_id)
       AND ner.child_entity_name="NOMENCLATURE"
       AND (ner.child_entity_id=reply->charge_event[f_event].charges[d.seq].mods.charge_mods[d2.seq].
      nomen_id)
       AND ner.reltn_type_cd=chargecpt4
       AND (ner.person_id=reply->charge_event[f_event].charges[d.seq].person_id)
       AND (ner.encntr_id=reply->charge_event[f_event].charges[d.seq].encntr_id)
       AND ner.active_ind=1)
     WITH nocounter
    ;end update
   ENDIF
   FREE SET templist
   RECORD templist(
     1 charges[*]
       2 charge_item_id = f8
   )
   CALL echo("Get any related interval or ADD ON charges")
   SELECT INTO "nl:"
    c.charge_item_id
    FROM charge c2,
     charge c,
     charge_mod cm,
     charge_event ce,
     (dummyt d  WITH seq = value(size(request->process_event[f_event].charge_item,5)))
    PLAN (d)
     JOIN (c2
     WHERE (c2.charge_item_id=request->process_event[f_event].charge_item[d.seq].charge_item_id)
      AND c2.item_interval_id != 0.0)
     JOIN (ce
     WHERE ce.charge_event_id=c2.charge_event_id)
     JOIN (c
     WHERE c.charge_event_id=ce.charge_event_id
      AND c.charge_item_id != c2.charge_item_id
      AND c.tier_group_cd=c2.tier_group_cd
      AND c.offset_charge_item_id=0.0)
     JOIN (cm
     WHERE (cm.charge_item_id= Outerjoin(c.charge_item_id)) )
    ORDER BY c.charge_item_id
    HEAD REPORT
     chargecnt = size(reply->charge_event[f_event].charges,5), suspendcnt = 0, chrgidx = 0
    HEAD c.charge_item_id
     chrgidx = locateval(idx,1,size(reply->charge_event[f_event].charges,5),c.charge_item_id,reply->
      charge_event[f_event].charges[idx].charge_item_id), reqchrgidx = 0
     IF (d.seq > 1)
      reqchrgidx = locateval(idx,1,(d.seq - 1),c.charge_item_id,request->process_event[f_event].
       charge_item[idx].charge_item_id)
     ENDIF
     IF (reqchrgidx=0)
      IF (chrgidx=0)
       chargecnt += 1,
       CALL filloutcharge(f_event,chargecnt), reply->charge_event[f_event].charges[chargecnt].
       server_process_flag = eflag_interval
      ELSE
       reply->charge_event[f_event].charges[chrgidx].server_process_flag = eflag_interval
       IF ((request->process_type_cd=g_cs13029->nocommit)
        AND validate(request->facility_transfer_ind,0)=false)
        reply->charge_event[f_event].charges[chrgidx].process_flg = 1
       ENDIF
      ENDIF
      IF ((request->process_type_cd != g_cs13029->nocommit))
       IF (c.process_flg=1)
        suspendcnt += 1, stat = alterlist(templist->charges,suspendcnt), templist->charges[suspendcnt
        ].charge_item_id = c.charge_item_id
       ENDIF
      ENDIF
     ENDIF
     chargemodcnt = 0
    DETAIL
     IF (chrgidx=0
      AND reqchrgidx=0)
      chargemodcnt += 1,
      CALL filloutchargemod(f_event,chargecnt,chargemodcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->process_type_cd != g_cs13029->nocommit))
    IF (suspendcnt > 0)
     CALL echo("Inactivate charge and charge_mod rows for related suspended interval charges")
     UPDATE  FROM charge c
      SET c.active_ind = 0
      WHERE expand(idx,1,suspendcnt,c.charge_item_id,templist->charges[idx].charge_item_id)
       AND c.active_ind=1
      WITH nocounter, expand = 1
     ;end update
     SET stat = alterlist(uptcmreq->objarray,0)
     FOR (cidx = 1 TO suspendcnt)
       SELECT INTO "nl:"
        FROM charge_mod cm
        WHERE (cm.charge_item_id=templist->charges[cidx].charge_item_id)
         AND cm.active_ind=1
        DETAIL
         billcdcnt += 1, stat = alterlist(uptcmreq->objarray,billcdcnt), uptcmreq->objarray[billcdcnt
         ].action_type = "DEL",
         uptcmreq->objarray[billcdcnt].charge_mod_id = cm.charge_mod_id, uptcmreq->objarray[billcdcnt
         ].charge_item_id = cm.charge_item_id, uptcmreq->objarray[billcdcnt].updt_cnt = cm.updt_cnt,
         uptcmreq->objarray[billcdcnt].active_ind = 0
        WITH nocounter
       ;end select
     ENDFOR
     IF (size(uptcmreq->objarray,5) <= 0)
      CALL echo("No charge_mods to update")
     ELSE
      EXECUTE afc_val_charge_mod  WITH replace("REQUEST",uptcmreq), replace("REPLY",uptcmrep)
      IF ((uptcmrep->status_data.status != "S"))
       CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
       IF (validate(debug,- (1)) > 0)
        CALL echorecord(uptcmreq)
        CALL echorecord(uptcmrep)
       ENDIF
      ENDIF
     ENDIF
     FOR (chrgcnt = 1 TO size(templist->charges,5))
      SET chrgidx = locateval(idx,1,suspendcnt,templist->charges[chrgcnt].charge_item_id,reply->
       charge_event[f_event].charges[idx].charge_item_id)
      IF (chrgidx > 0)
       UPDATE  FROM nomen_entity_reltn ner,
         (dummyt d  WITH seq = value(size(reply->charge_event[f_event].charges[chrgidx].mods.
           charge_mods,5)))
        SET ner.active_ind = 0
        PLAN (d
         WHERE (reply->charge_event[f_event].charges[chrgidx].mods.charge_mods[d.seq].nomen_id > 0))
         JOIN (ner
         WHERE (ner.nomenclature_id=reply->charge_event[f_event].charges[chrgidx].mods.charge_mods[d
         .seq].nomen_id)
          AND ner.parent_entity_name="CHARGE"
          AND (ner.parent_entity_id=reply->charge_event[f_event].charges[chrgidx].charge_item_id)
          AND ner.child_entity_name="NOMENCLATURE"
          AND (ner.child_entity_id=reply->charge_event[f_event].charges[chrgidx].mods.charge_mods[d
         .seq].nomen_id)
          AND ner.reltn_type_cd=chargecpt4
          AND (ner.person_id=reply->charge_event[f_event].charges[chrgidx].person_id)
          AND (ner.encntr_id=reply->charge_event[f_event].charges[chrgidx].encntr_id)
          AND ner.active_ind=1)
        WITH nocounter
       ;end update
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL echo("Read charge_event_act table")
   SET cnt = 0
   SET curactid = 0.0
   SELECT INTO "nl:"
    c.charge_event_act_id
    FROM charge_event_act c
    WHERE expand(idx,1,chargecnt,c.charge_event_act_id,reply->charge_event[f_event].charges[idx].
     charge_act_id)
    ORDER BY c.charge_event_act_id
    DETAIL
     IF (curactid != c.charge_event_act_id)
      curactid = c.charge_event_act_id, cnt += 1,
      CALL filloutchargeeventact(f_event,cnt)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (serverprocessflagind=1)
    CALL checkserverprocessflag(f_event)
   ENDIF
 END ;Subroutine
 SUBROUTINE filloutchargeeventact(g_event,g_act)
   SET stat = alterlist(reply->charge_event[g_event].charge_event_act,g_act)
   SET reply->charge_event[g_event].charge_event_act[g_act].charge_event_act_id = c
   .charge_event_act_id
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_type_cd = c.cea_type_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].service_resource_cd = c
   .service_resource_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].service_loc_cd = c.service_loc_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].service_dt_tm = c.service_dt_tm
   SET reply->charge_event[g_event].charge_event_act[g_act].charge_type_cd = c.charge_type_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].alpha_nomen_id = c.alpha_nomen_id
   SET reply->charge_event[g_event].charge_event_act[g_act].quantity = c.quantity
   SET reply->charge_event[g_event].charge_event_act[g_act].rx_quantity = c.quantity
   SET reply->charge_event[g_event].charge_event_act[g_act].result = c.result
   SET reply->charge_event[g_event].charge_event_act[g_act].units = c.units
   SET reply->charge_event[g_event].charge_event_act[g_act].unit_type_cd = c.unit_type_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].reason_cd = c.reason_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].accession_id = c.accession_id
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_prsnl_id = c.cea_prsnl_id
   SET reply->charge_event[g_event].charge_event_act[g_act].misc_ind = c.misc_ind
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc1 = c.cea_misc1
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc2 = c.cea_misc2
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc3 = c.cea_misc3
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc1_id = c.cea_misc1_id
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc2_id = c.item_ext_price
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc3_id = c.cea_misc3_id
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc4_id = c.item_price
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc5_id = c.item_copay
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc6_id = c.item_reimbursement
   SET reply->charge_event[g_event].charge_event_act[g_act].cea_misc7_id = c.discount_amount
   SET reply->charge_event[g_event].charge_event_act[g_act].priority_cd = c.priority_cd
   SET reply->charge_event[g_event].charge_event_act[g_act].item_deductible_amt = c
   .item_deductible_amt
   SET reply->charge_event[g_event].charge_event_act[g_act].patient_responsibility_flag = c
   .patient_responsibility_flag
 END ;Subroutine
 SUBROUTINE addprimaryhealthplans(d)
   CALL echo("Adding primary health plans to the reply structure")
   DECLARE hpidx = i4 WITH protect, noconstant(0)
   DECLARE curhpidx = i4 WITH protect, noconstant(0)
   FOR (repeventloop = 1 TO repeventcnt)
     IF ((reply->charge_event[repeventloop].charge_event_id > 0))
      SET repactcnt = size(reply->charge_event[repeventloop].charge_event_act,5)
      IF (repactcnt > 0)
       SET groupcnt = 0
       SET mpcnt = 0.0
       SET hpidx = 0
       SET curhpidx = 0
       SELECT INTO "nl:"
        epr.health_plan_id
        FROM encntr_plan_cob epc,
         encntr_plan_cob_reltn epcr,
         encntr_plan_reltn epr
        PLAN (epc
         WHERE (epc.encntr_id=reply->charge_event[repeventloop].encntr_id)
          AND epc.active_ind=1)
         JOIN (epcr
         WHERE epcr.encntr_plan_cob_id=epc.encntr_plan_cob_id
          AND epcr.active_ind=1
          AND epcr.priority_seq=1)
         JOIN (epr
         WHERE epr.encntr_plan_reltn_id=epcr.encntr_plan_reltn_id
          AND epr.active_ind=1
          AND epr.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[repeventloop].
          charge_event_act[1].service_dt_tm)
          AND epr.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[repeventloop].
          charge_event_act[1].service_dt_tm))
        ORDER BY epr.health_plan_id, epr.beg_effective_dt_tm
        HEAD epr.health_plan_id
         mpcnt += 1, stat = assign(validate(reply->charge_event[repeventloop].primaryhealthplancount),
          mpcnt)
        DETAIL
         hpidx = locateval(curhpidx,1,groupcnt,epr.health_plan_id,reply->charge_event[repeventloop].
          primaryhealthplans[curhpidx].health_plan_id)
         IF (hpidx=0)
          IF (epc.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[repeventloop].
           charge_event_act[1].service_dt_tm)
           AND epc.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[repeventloop].
           charge_event_act[1].service_dt_tm))
           groupcnt += 1, stat = alterlist(reply->charge_event[repeventloop].primaryhealthplans,
            groupcnt), reply->charge_event[repeventloop].primaryhealthplans[groupcnt].health_plan_id
            = epr.health_plan_id,
           reply->charge_event[repeventloop].primaryhealthplans[groupcnt].priority_sequence = 1
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SET groupcnt = 0
       SET mpcnt = 0
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 IF ((g_srvproperties->logreqrep=1)
  AND parent_script="CS_SRV_GET_CHARGE_EVENT")
  CALL echorecord(reply)
 ENDIF
 DECLARE list_count = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=cvs14002_afc_schedule_type
   AND cv.cdf_meaning="MODIFIER"
   AND cv.active_ind=1
  DETAIL
   list_count += 1, stat = alterlist(cptmodlist->mod_list,list_count), cptmodlist->mod_list[
   list_count].field1_id = cv.code_value
  WITH nocounter
 ;end select
 SET cptmodlist->mod_list_count = list_count
 IF (((parent_script="CS_SRV_ADD_CHARGE_EVENT") OR ((reply->action_type="GCE"))) )
  CALL echo("--Called From CS_SRV_ADD_CHARGE_EVENT or Action_Type is GCE")
  SET repeventcnt = size(reply->charge_event,5)
  CALL fillchargeevent("NULL")
  IF ((reply->action_type="SNC"))
   CALL getchargesnolocks("NULL")
  ELSE
   CALL getcharges("NULL")
  ENDIF
 ELSE
  SET repeventcnt = size(request->process_event,5)
  IF (repeventcnt > 0)
   CALL getchargeevent("NULL")
   FOR (repeventloop = 1 TO repeventcnt)
     IF ((reply->charge_event[repeventloop].charge_event_id > 0))
      IF ((((request->process_type_cd=g_cs13029->reprocess)) OR ((request->process_type_cd=g_cs13029
      ->dbgreprocess))) )
       CALL readreprocess(repeventloop)
      ELSE
       CALL readrelease(repeventloop)
      ENDIF
     ENDIF
   ENDFOR
   CALL fillchargeevent("NULL")
  ENDIF
 ENDIF
 IF ((g_srvproperties->logreqrep=1)
  AND parent_script="CS_SRV_GET_CHARGE_EVENT")
  CALL echorecord(reply)
 ENDIF
 FREE SET templist
 FREE SET cptmodlist
END GO
