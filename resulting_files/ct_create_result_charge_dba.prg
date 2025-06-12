CREATE PROGRAM ct_create_result_charge:dba
 SET ct_create_result_charge_version = "318318.MOD.014"
 CALL echo("Begin AFC_IMPERSONATE_PERSONNEL_SUB.INC, version [318318.001]")
 IF ( NOT (validate(impersonatepersonnelinfo)))
  DECLARE impersonatepersonnelinfo(dummyvar=i2) = null
  SUBROUTINE impersonatepersonnelinfo(dummyvar)
    DECLARE seccntxt = i4
    DECLARE namelen = i4
    DECLARE domainnamelen = i4
    DECLARE uar_secsetcontext(hctx=i4) = i2
    EXECUTE secrtl  WITH image_axp = "secrtl", image_aix = "libsec.a(libsec.o)", uar =
    "SecSetContext",
    persist
    SET namelen = (uar_secgetclientusernamelen()+ 1)
    SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
    SET stat = memalloc(name,1,build("C",namelen))
    SET stat = memalloc(domainname,1,build("C",domainnamelen))
    SET stat = uar_secgetclientusername(name,namelen)
    SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
    SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
  END ;Subroutine
 ENDIF
 RECORD charge_req(
   1 action_type = c3
   1 charge_event_qual = i2
   1 charge_event[*]
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 ext_parent_event_id = f8
     2 ext_parent_event_cont_cd = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_reference_cont_cd = f8
     2 ext_item_event_id = f8
     2 ext_item_event_cont_cd = f8
     2 ext_item_reference_id = f8
     2 ext_item_reference_cont_cd = f8
     2 charge_type_cd = f8
     2 charge_dt_tm = dq8
     2 quantity = i4
     2 result = vc
     2 elapsed_time = i4
     2 unit_type = i4
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 accession = vc
     2 report_priority_cd = f8
     2 collection_priority_cd = f8
     2 reference_nbr = vc
     2 contributor_system_cd = f8
     2 research_acct_id = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 order_priority_cd = f8
     2 accession_nbr = vc
     2 admit_type_cd = f8
     2 location_cd = f8
     2 research_cd = f8
     2 rpt_priority_cd = f8
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_id = f8
       3 cea_type_cd = f8
       3 service_resource_cd = f8
       3 service_dt_tm = dq8
       3 charge_dt_tm = dq8
       3 charge_type_cd = f8
       3 reference_range_factor_id = f8
       3 alpha_nomen_id = f8
       3 quantity = i4
       3 result = vc
       3 units = f8
       3 unit_type_cd = i4
       3 patient_loc_cd = f8
       3 service_loc_cd = f8
       3 reason_cd = f8
       3 in_transit_dt_tm = dq8
       3 in_lab_dt_tm = dq8
       3 accession_id = f8
       3 repeat_ind = i2
       3 cea_prsnl_type_cd = f8
       3 cea_prsnl_id = f8
       3 cea_service_resource_cd = f8
       3 ceact_dt_tm = dq8
       3 cea_field1 = vc
       3 cea_field2 = vc
       3 cea_field3 = vc
       3 cea_field4 = vc
       3 cea_field5 = vc
       3 elapsed_time = i4
       3 cea_loc_cd = f8
       3 prsnl_qual = i2
       3 prsnl[*]
         4 prsnl_id = f8
     2 charge_event_mod_qual = i2
     2 charge_event_mod[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = c200
       3 field2 = c200
       3 field3 = c200
       3 field4 = c200
       3 field5 = c200
       3 field6 = c200
       3 field7 = c200
       3 field8 = c200
       3 field9 = c200
       3 field10 = c200
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
 )
 RECORD charge_rep(
   1 charge_qual = i2
   1 charge_list[*]
     2 charge_item_id = f8
     2 description = vc
     2 price = f8
     2 process_flg = i2
     2 quantity = i4
     2 mod_qual = i2
     2 mod_list[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = c200
       3 field2 = c200
       3 field3 = c200
       3 field4 = c200
       3 field5 = c200
       3 field6 = c200
       3 field7 = c200
       3 field8 = c200
       3 field9 = c200
       3 field10 = c200
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
 )
 DECLARE ord_phys_type_cd = f8
 DECLARE perf_phys_type_cd = f8
 DECLARE verify_phys_type_cd = f8
 DECLARE ref_phys_type_cd = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13029
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ord_phys_type_cd)
 SET cdf_meaning = "PERFORMED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,perf_phys_type_cd)
 SET cdf_meaning = "VERIFIED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,verify_phys_type_cd)
 SET cdf_meaning = "REFERRED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ref_phys_type_cd)
 DECLARE new_num = f8
 SELECT INTO "nl:"
  new_seq_num = seq(batch_charge_entry_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_num = cnvtreal(new_seq_num)
  WITH format, counter
 ;end select
 CALL echo(build("new_num: ",new_num))
 SET code_set = 13016
 SET cdf_meaning = "PREPROCESSOR"
 SET cnt = 1
 DECLARE preprocessor_cd = f8
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,preprocessor_cd)
 CALL echo(build("preprocessor_cd from 13016: ",preprocessor_cd))
 DECLARE appid = i4
 DECLARE taskid = i4
 DECLARE reqid = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hstep = i4
 DECLARE iret = i4
 DECLARE hcharge = i4
 DECLARE srvstat = i4
 DECLARE hact = i4
 DECLARE hrcharges = i4
 DECLARE hrchild = i4
 DECLARE no_charges = i4
 DECLARE hprsnl = i4
 SET appid = 5000
 SET taskid = 951081
 SET stepid = 951360
 CALL impersonatepersonnelinfo(1)
 SET iret = uar_crmbeginapp(appid,happ)
 IF (iret=0)
  CALL echo("successful begin app")
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret=0)
   CALL echo("successful begin task")
   SET iret = uar_crmbeginreq(htask,"",stepid,hstep)
   IF (iret=0)
    CALL echo("successful begin req")
    SET hreq = uar_crmgetrequest(hstep)
    SET hcharge = uar_srvadditem(hreq,"charge_event")
    SET srvstat = uar_srvsetdouble(hcharge,"ext_master_event_id",cnvtreal(new_num))
    CALL echo(build("ext_master_event_id: ",new_num))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_master_event_cont_cd",preprocessor_cd)
    CALL echo(build("ext_master_event_cont_cd  ",preprocessor_cd))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_master_reference_id",ct_request->ref_id)
    CALL echo(build("ext_master_reference_id  ",ct_request->ref_id))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_master_reference_cont_cd",ct_request->ref_cont_cd)
    CALL echo(build("ext_master_reference_cont_cd  ",ct_request->ref_cont_cd))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_item_event_id",cnvtreal(new_num))
    CALL echo(build("ext_item_event_id ",new_num))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_item_event_cont_cd",preprocessor_cd)
    CALL echo(build("ext_item_event_cont_cd  ",preprocessor_cd))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_item_reference_id",ct_request->ref_id)
    CALL echo(build("ext_item_reference_id  ",ct_request->ref_id))
    SET srvstat = uar_srvsetdouble(hcharge,"ext_item_reference_cont_cd",ct_request->ref_cont_cd)
    CALL echo(build("ext_item_reference_cont_cd  ",ct_request->ref_cont_cd))
    SET srvstat = uar_srvsetdouble(hcharge,"person_id",ct_request->person_id)
    CALL echo(build("person_id  ",ct_request->person_id))
    SET srvstat = uar_srvsetdouble(hcharge,"encntr_id",ct_request->encntr_id)
    SET hevent = uar_srvadditem(hcharge,"charge_event_act")
    SET srvstat = uar_srvsetdouble(hevent,"service_resource_cd",ct_request->service_res_cd)
    SET srvstat = uar_srvsetdouble(hevent,"cea_type_cd",code_val->13029_complete)
    CALL echo(build("cea_type_cd  ",code_val->13029_complete))
    SET srvstat = uar_srvsetdouble(hevent,"charge_type_cd",code_val->13028_charge_now)
    CALL echo(build("charge_type_cd  ",code_val->13028_charge_now))
    SET srvstat = uar_srvsetdate(hevent,"service_dt_tm",cnvtdatetime(ct_request->service_dt_tm))
    CALL echo(build("service_dt_tm  ",cnvtdatetime(ct_request->service_dt_tm)))
    IF ((ct_request->quantity > 0.0))
     SET srvstat = uar_srvsetlong(hevent,"quantity",ct_request->quantity)
    ELSE
     SET srvstat = uar_srvsetlong(hevent,"quantity",1.0)
    ENDIF
    CALL echo(build("quantity ",ct_request->quantity))
    SET count = 0
    IF ((ct_request->ord_phys_id > 0))
     SET count = (count+ 1)
    ENDIF
    IF ((ct_request->perf_phys_id > 0))
     SET count = (count+ 1)
    ENDIF
    IF ((ct_request->verify_phys_id > 0))
     SET count = (count+ 1)
    ENDIF
    IF ((ct_request->ref_phys_id > 0))
     SET count = (count+ 1)
    ENDIF
    IF (count > 0)
     SET srvstat = uar_srvsetshort(hevent,"prsnl_qual",count)
     SET hprsnl = uar_srvadditem(hevent,"prsnl")
     IF ((ct_request->ord_phys_id > 0))
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ct_request->ord_phys_id)
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",ord_phys_type_cd)
     ENDIF
     IF ((ct_request->perf_phys_id > 0))
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ct_request->perf_phys_id)
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",perf_phys_type_cd)
     ENDIF
     IF ((ct_request->verify_phys_id > 0))
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ct_request->verify_phys_id)
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",verify_phys_type_cd)
     ENDIF
     IF ((ct_request->ref_phys_id > 0))
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_id",ct_request->ref_phys_id)
      SET srvstat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",ref_phys_type_cd)
     ENDIF
    ENDIF
    SET iret = uar_crmperform(hstep)
    IF (iret=0)
     CALL echo("Success, check reply")
     SET hrcharges = uar_crmgetreply(hstep)
     IF (hrcharges > 0)
      CALL echo("Reply Success")
     ELSE
      CALL echo("Reply Failure")
     ENDIF
     SET no_charges = uar_srvgetitemcount(hrcharges,"charges")
     CALL echo(build("no_charges",no_charges))
     IF (no_charges > 0)
      FOR (k = 1 TO no_charges)
        SET hrchild = uar_srvgetitem(hrcharges,"charges",(k - 1))
        SET stat = alterlist(charge_rep->charge_list,k)
        SET charge_rep->charge_list[k].charge_item_id = uar_srvgetdouble(hrchild,"charge_item_id")
        SET stat = alterlist(ct_reply->charges,k)
        SET ct_reply->charges[k].charge_item_id = charge_rep->charge_list[k].charge_item_id
        CALL echo(concat("charge_item_id: ",cnvtstring(charge_rep->charge_list[k].charge_item_id)))
        SET charge_rep->charge_list[k].process_flg = uar_srvgetshort(hrchild,"process_flg")
        SET ct_reply->charges[k].process_flg = charge_rep->charge_list[k].process_flg
        CALL echo(concat("process_flg: ",cnvtstring(charge_rep->charge_list[k].process_flg)))
      ENDFOR
     ENDIF
    ELSE
     CALL echo(concat("Fail on perform: ",cnvtstring(iret)))
    ENDIF
    CALL uar_crmendreq(hreq)
   ELSE
    CALL echo(concat("Error on begin req: ",cnvtstring(iret)))
   ENDIF
   CALL uar_crmendtask(htask)
  ELSE
   CALL echo(concat("Failure on begin task: ",cnvtstring(iret)))
  ENDIF
  CALL uar_crmendapp(happ)
 ELSE
  CALL echo(concat("Failure on uar_crm_begin_app: ",cnvtstring(iret)))
 ENDIF
END GO
