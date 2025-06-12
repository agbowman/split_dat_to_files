CREATE PROGRAM afc_transfer_charges:dba
 DECLARE afc_transfer_charges_version = vc WITH private, noconstant("CHARGSRV-14536.009")
 CALL echo("Begin AFC_IMPERSONATE_PERSONNEL_SUB.INC, version [318318.001]")
 IF ( NOT (validate(impersonatepersonnelinfo)))
  SUBROUTINE (impersonatepersonnelinfo(dummyvar=i2) =null)
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD manualchargelist
 RECORD manualchargelist(
   1 process_event[*]
     2 charge_event_id = f8
     2 codes[*]
       3 nomenclature_id = f8
       3 charge_event_mod_id = f8
       3 icd9_code = vc
       3 icd9_desc = vc
     2 charges[*]
       3 charge_item_id = f8
       3 process_flg = i4
       3 manual_ind = i2
 )
 FREE RECORD reprocess_request
 RECORD reprocess_request(
   1 charge_event_qual = i2
   1 process_event[*]
     2 charge_event_id = f8
     2 codes[*]
       3 nomenclature_id = f8
       3 charge_event_mod_id = f8
       3 icd9_code = vc
       3 icd9_desc = vc
     2 rollback_codes[*]
       3 charge_event_mod_id = f8
     2 charge_acts[*]
       3 charge_event_act_id = f8
     2 charge_item_qual = i2
     2 charge_item[*]
       3 charge_item_id = f8
 )
 FREE RECORD addchargemodreq
 RECORD addchargemodreq(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c200
     2 field4 = c200
     2 field5 = c200
     2 field6 = c200
     2 field7 = c200
     2 field8 = c200
     2 field9 = c200
     2 field10 = c200
     2 activity_dt_tm = dq8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 cm1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 action_type = c3
   1 skip_charge_event_mod_ind = i2
 )
 FREE RECORD addchargemodrep
 RECORD addchargemodrep(
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
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 RECORD delchargeeventmodreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 active_status_cd = f8
     2 updt_cnt = i4
 ) WITH protect
 RECORD delchargeeventmodrep(
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
 FREE RECORD new_charge_list
 RECORD new_charge_list(
   1 charges[*]
     2 charge_item_id = f8
     2 process_flg = i2
 )
 FREE RECORD afcprofit_request
 RECORD afcprofit_request(
   1 remove_commit_ind = i2
   1 follow_combined_parent_ind = i2
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE RECORD afcprofit_reply
 RECORD afcprofit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
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
   1 objarray[*]
     2 service_cd = f8
     2 updt_id = f8
     2 event_key = vc
     2 category_key = vc
     2 published_ind = i2
     2 pe_status_reason_cd = f8
     2 acct_id = f8
     2 activity_id = f8
     2 batch_denial_file_r_id = f8
     2 batch_trans_ext_id = f8
     2 batch_trans_file_id = f8
     2 batch_trans_id = f8
     2 benefit_order_id = f8
     2 bill_item_id = f8
     2 bill_templ_id = f8
     2 bill_vrsn_nbr = i4
     2 billing_entity_id = f8
     2 bo_hp_reltn_id = f8
     2 charge_item_id = f8
     2 chrg_activity_id = f8
     2 claim_status_id = f8
     2 client_org_id = f8
     2 corsp_activity_id = f8
     2 corsp_log_reltn_id = f8
     2 denial_id = f8
     2 dirty_flag = i4
     2 encntr_id = f8
     2 guar_acct_id = f8
     2 guarantor_id = f8
     2 health_plan_id = f8
     2 long_text_id = f8
     2 organization_id = f8
     2 payor_org_id = f8
     2 pe_status_reason_id = f8
     2 person_id = f8
     2 pft_balance_id = f8
     2 pft_bill_activity_id = f8
     2 pft_charge_id = f8
     2 pft_encntr_fact_id = f8
     2 pft_encntr_id = f8
     2 pft_line_item_id = f8
     2 trans_alias_id = f8
     2 pft_payment_plan_id = f8
     2 daily_encntr_bal_id = f8
     2 daily_acct_bal_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_disp = vc
     2 active_status_desc = vc
     2 active_status_mean = vc
     2 active_status_code_set = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = f8
     2 benefit_status_cd = f8
     2 financial_class_cd = f8
     2 payment_plan_flag = i2
     2 payment_location_id = f8
     2 encntr_plan_cob_id = f8
     2 guarantor_account_id = f8
     2 guarantor_id1 = f8
     2 guarantor_id2 = f8
     2 cbos_pe_reltn_id = f8
     2 post_dt_tm = dq8
     2 posting_category_type_flag = i2
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE ichargecount = i4 WITH protect, noconstant(0)
 DECLARE lmanchargecount = i4 WITH protect, noconstant(0)
 DECLARE ichargeloop = i4 WITH protect, noconstant(0)
 DECLARE ichargeeventcount = i4 WITH protect, noconstant(0)
 DECLARE lchargeeventloop = i4 WITH protect, noconstant(0)
 DECLARE lmanchargeeventcount = i4 WITH protect, noconstant(0)
 DECLARE lmanchargeeventloop = i4 WITH protect, noconstant(0)
 DECLARE ichargeeventactcount = i4 WITH protect, noconstant(0)
 DECLARE ichargeeventactloop = i4 WITH protect, noconstant(0)
 DECLARE ichargecodesloop = i4 WITH protect, noconstant(0)
 DECLARE dicd9_cs14002 = f8 WITH protect, noconstant(0.0)
 DECLARE dbillcode_cs13019 = f8 WITH protect, noconstant(0.0)
 DECLARE dreprocess_cs13029 = f8 WITH protect, noconstant(0.0)
 DECLARE dmodrsn_cs13019 = f8 WITH protect, noconstant(0.0)
 DECLARE dclient_cs22569 = f8 WITH protect, noconstant(0.0)
 DECLARE dpatient_cs22569 = f8 WITH protect, noconstant(0.0)
 DECLARE dtransfer_cs4001989 = f8 WITH protect, noconstant(0.0)
 DECLARE itransferappid = i4 WITH protect, noconstant(951020)
 DECLARE itransfertaskid = i4 WITH protect, noconstant(951020)
 DECLARE itransferreqid = i4 WITH protect, noconstant(951359)
 DECLARE happtransfer = i4 WITH protect, noconstant(0)
 DECLARE htasktransfer = i4 WITH protect, noconstant(0)
 DECLARE hstepreprocess = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hlist = i4 WITH protect, noconstant(0)
 DECLARE hlist2 = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE dnewid = f8 WITH protect, noconstant(0.0)
 DECLARE lpostingcnt = i4 WITH protect, noconstant(0)
 DECLARE lchargeeventactloop = i4 WITH protect, noconstant(0)
 DECLARE lmanualcount = i4 WITH protect, noconstant(0)
 DECLARE bcopycharge = i2 WITH protect, noconstant(false)
 DECLARE lnewchargecount = i4 WITH protect, noconstant(0)
 DECLARE lchargemodcount = i4 WITH protect, noconstant(0)
 DECLARE lrollbackcodecount = i4 WITH protect, noconstant(0)
 DECLARE rollbackchargeeventmod(_null_) = null
 SET stat = uar_get_meaning_by_codeset(14002,"ICD9",1,dicd9_cs14002)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,dbillcode_cs13019)
 SET stat = uar_get_meaning_by_codeset(13029,"REPROCESS",1,dreprocess_cs13029)
 SET stat = uar_get_meaning_by_codeset(13019,"MOD RSN",1,dmodrsn_cs13019)
 SET stat = uar_get_meaning_by_codeset(22569,"CLIENT",1,dclient_cs22569)
 SET stat = uar_get_meaning_by_codeset(22569,"PATIENT",1,dpatient_cs22569)
 SET stat = uar_get_meaning_by_codeset(4001989,"TRANSFER",1,dtransfer_cs4001989)
 SET addchargemodreq->skip_charge_event_mod_ind = true
 CALL echo(build("Including AFC_PREFERENCE_MANAGER_ACCESS.INC, version [",nullterm("191119.000"),"]")
  )
 SUBROUTINE (bmanprefcheck(_null_=i2) =i2)
   EXECUTE prefrtl
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE lprefstat = i4 WITH protect, noconstant(0)
   DECLARE hgroupin = i4 WITH protect, noconstant(0)
   DECLARE hsubgroupin = i4 WITH protect, noconstant(0)
   DECLARE hgroupout = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE entryindex = i4 WITH protect, noconstant(0)
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrindex = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valindex = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE namelength = i4 WITH protect, noconstant(50)
   DECLARE entryname = c50 WITH protect, noconstant("")
   DECLARE attrname = c50 WITH protect, noconstant("")
   DECLARE sreturn = c50 WITH protect, noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL echo("Failed to create preference instance")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefaddcontext(hpref,"default","system")
   IF (lprefstat != 1)
    CALL echo("Failed to add preference context")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefsetsection(hpref,"config")
   IF (lprefstat != 1)
    CALL echo("Failed to set preference section")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hgroupin = uar_prefcreategroup()
   IF (hgroupin=0)
    CALL echo("Failed to create preference group")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefsetgroupname(hgroupin,"charge services")
   IF (lprefstat != 1)
    CALL echo("Failed to set preference group name")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefaddgroup(hpref,hgroupin)
   IF (lprefstat != 1)
    CALL echo("Failed to add preference group")
    CALL preferencecleanup(0)
    RETURN(true)
   ENDIF
   SET lprefstat = uar_prefperform(hpref)
   IF (lprefstat != 1)
    CALL echo(build("Preference perform failed. lPrefStat:",lprefstat))
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"config")
   IF (hsection=0)
    CALL echo("Failed to get preference section")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hgroupout = uar_prefgetgroupbyname(hsection,"charge services")
   IF (hgroupout=0)
    CALL echo("Failed to get preference group")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefgetgroupentrycount(hgroupout,entrycount)
   IF (lprefstat != 1)
    CALL echo("Failed to get preference entry count")
    CALL preferencecleanup(0)
    RETURN(true)
   ENDIF
   FOR (entryindex = 0 TO (entrycount - 1))
     SET namelength = 50
     SET entryname = fillstring(50," ")
     SET hentry = uar_prefgetgroupentry(hgroupout,entryindex)
     IF (hentry=0)
      CALL echo("Failed to get preference group entry")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     SET lprefstat = uar_prefgetentryname(hentry,entryname,namelength)
     IF (lprefstat != 1)
      CALL echo("Failed to get preference entry name")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     SET lprefstat = uar_prefgetentryattrcount(hentry,attrcount)
     IF (lprefstat != 1)
      CALL echo("Failed to get preference entry attribute count")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     FOR (attrindex = 0 TO (attrcount - 1))
       SET namelength = 50
       SET attrname = fillstring(50," ")
       SET hattr = uar_prefgetentryattr(hentry,attrindex)
       IF (hattr=0)
        CALL echo("Failed to get preference entry attribute")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       SET lprefstat = uar_prefgetattrname(hattr,attrname,namelength)
       IF (lprefstat != 1)
        CALL echo("Failed to get preference entry attribute name")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       SET lprefstat = uar_prefgetattrvalcount(hattr,valcount)
       IF (lprefstat != 1)
        CALL echo("Failed to get preference entry attribute value count")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       FOR (valindex = 0 TO (valcount - 1))
        SET namelength = 50
        CASE (trim(entryname))
         OF "manual charge copy":
          SET hval = uar_prefgetattrval(hattr,sreturn,namelength,valindex)
        ENDCASE
       ENDFOR
     ENDFOR
   ENDFOR
   CALL preferencecleanup(0)
   IF (sreturn="1")
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (preferencecleanup(_null_=i2) =null)
   CALL uar_prefdestroyinstance(hpref)
   CALL uar_prefdestroygroup(hgroupin)
   CALL uar_prefdestroygroup(hgroupout)
   CALL uar_prefdestroygroup(hsubgroupin)
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyentry(hentry)
   CALL uar_prefdestroyattr(hattr)
 END ;Subroutine
 SET bcopycharge = bmanprefcheck(0)
 SELECT INTO "nl:"
  FROM charge c1,
   charge c2,
   (dummyt d  WITH seq = value(size(request->charges,5)))
  PLAN (d)
   JOIN (c1
   WHERE (c1.charge_item_id=request->charges[d.seq].charge_item_id)
    AND c1.active_ind=1)
   JOIN (c2
   WHERE c2.charge_event_id=c1.charge_event_id
    AND c2.encntr_id=c1.encntr_id
    AND c2.offset_charge_item_id=0.0
    AND c2.active_ind=1)
  ORDER BY c2.charge_event_id, c2.charge_item_id
  HEAD c2.charge_event_id
   ichargeeventcount += 1, stat = alterlist(reprocess_request->process_event,ichargeeventcount),
   reprocess_request->process_event[ichargeeventcount].charge_event_id = c2.charge_event_id,
   ichargecount = 0, lmanchargeeventcount += 1, stat = alterlist(manualchargelist->process_event,
    lmanchargeeventcount),
   manualchargelist->process_event[lmanchargeeventcount].charge_event_id = c2.charge_event_id,
   lmanchargecount = 0
  DETAIL
   IF (bcopycharge
    AND c2.manual_ind=1
    AND c2.process_flg != 4)
    lmanchargecount += 1, stat = alterlist(manualchargelist->process_event[lmanchargeeventcount].
     charges,lmanchargecount), manualchargelist->process_event[lmanchargeeventcount].charges[
    lmanchargecount].charge_item_id = c2.charge_item_id,
    manualchargelist->process_event[lmanchargeeventcount].charges[lmanchargecount].process_flg = c2
    .process_flg, manualchargelist->process_event[lmanchargeeventcount].charges[lmanchargecount].
    manual_ind = c2.manual_ind
    FOR (ichargecodesloop = 1 TO size(request->charges[d.seq].codes,5))
     stat = alterlist(manualchargelist->process_event[lmanchargeeventcount].codes,ichargecodesloop),
     manualchargelist->process_event[lmanchargeeventcount].codes[ichargecodesloop].nomenclature_id =
     request->charges[d.seq].codes[ichargecodesloop].nomenclature_id
    ENDFOR
   ELSE
    ichargecount += 1, stat = alterlist(reprocess_request->process_event[ichargeeventcount].
     charge_item,ichargecount), reprocess_request->process_event[ichargeeventcount].charge_item[
    ichargecount].charge_item_id = c2.charge_item_id
    FOR (ichargecodesloop = 1 TO size(request->charges[d.seq].codes,5))
     stat = alterlist(reprocess_request->process_event[ichargeeventcount].codes,ichargecodesloop),
     reprocess_request->process_event[ichargeeventcount].codes[ichargecodesloop].nomenclature_id =
     request->charges[d.seq].codes[ichargecodesloop].nomenclature_id
    ENDFOR
   ENDIF
  FOOT  c2.charge_event_id
   IF (lmanchargecount=0)
    lmanchargeeventcount -= 1, stat = alterlist(manualchargelist->process_event,lmanchargeeventcount)
   ENDIF
   IF (ichargecount=0)
    ichargeeventcount -= 1, stat = alterlist(reprocess_request->process_event,ichargeeventcount)
   ELSE
    reprocess_request->process_event[ichargeeventcount].charge_item_qual = ichargecount
   ENDIF
  WITH nocounter
 ;end select
 SET reprocess_request->charge_event_qual = ichargeeventcount
 IF (lmanchargeeventcount=0
  AND ichargeeventcount=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to get charge event/charge info"
  GO TO end_program
 ENDIF
 CALL echorecord(reprocess_request)
 CALL echorecord(manualchargelist)
 IF (size(reprocess_request->process_event,5) > 0)
  IF ( NOT (performreprocess(0)))
   GO TO end_program
  ENDIF
 ENDIF
 IF (size(manualchargelist->process_event,5) > 0)
  IF ( NOT (performmanualcopy(0)))
   GO TO end_program
  ENDIF
 ENDIF
 CALL echorecord(new_charge_list)
 IF (size(new_charge_list->charges,5) > 0)
  SELECT INTO "nl:"
   FROM charge c,
    interface_file i,
    (dummyt d  WITH seq = value(size(new_charge_list->charges,5)))
   PLAN (d
    WHERE (new_charge_list->charges[d.seq].process_flg=0))
    JOIN (c
    WHERE (c.charge_item_id=new_charge_list->charges[d.seq].charge_item_id))
    JOIN (i
    WHERE i.interface_file_id=c.interface_file_id)
   DETAIL
    IF (i.realtime_ind=0
     AND i.profit_type_cd > 0)
     lpostingcnt += 1, stat = alterlist(afcprofit_request->charges,lpostingcnt), afcprofit_request->
     charges[lpostingcnt].charge_item_id = new_charge_list->charges[d.seq].charge_item_id
    ENDIF
   WITH nocounter
  ;end select
  IF (size(afcprofit_request->charges,5) > 0)
   EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
    afcprofit_reply)
  ENDIF
 ENDIF
 IF (size(request->charges,5) > 0)
  UPDATE  FROM charge c,
    (dummyt d  WITH seq = value(size(request->charges,5)))
   SET c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
    updt_applctx,
    c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request->charges[d.seq].charge_item_id))
   WITH nocounter
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SUBROUTINE rollbackchargeeventmod(_null_)
   DECLARE lceloop = i4 WITH protect, noconstant(0)
   DECLARE lcemloop = i4 WITH protect, noconstant(0)
   DECLARE cemcnt = i4 WITH protect, noconstant(0)
   FOR (lceloop = 1 TO size(reprocess_request->process_event,5))
     SET cemcnt = 0
     SET stat = alterlist(uptchargeeventmodreq->objarray,0)
     FOR (lcemloop = 1 TO size(reprocess_request->process_event[lceloop].rollback_codes,5))
       SELECT INTO "nl:"
        FROM charge_event_mod cem
        WHERE (cem.charge_event_mod_id=reprocess_request->process_event[lceloop].rollback_codes[
        lcemloop].charge_event_mod_id)
        DETAIL
         cemcnt += 1, stat = alterlist(uptchargeeventmodreq->objarray,cemcnt), uptchargeeventmodreq->
         objarray[cemcnt].action_type = "UPT",
         uptchargeeventmodreq->objarray[cemcnt].charge_event_mod_id = cem.charge_event_mod_id,
         uptchargeeventmodreq->objarray[cemcnt].charge_event_id = cem.charge_event_id,
         uptchargeeventmodreq->objarray[cemcnt].active_ind = 1,
         uptchargeeventmodreq->objarray[cemcnt].active_status_cd = reqdata->active_status_cd,
         uptchargeeventmodreq->objarray[cemcnt].active_status_dt_tm = cnvtdatetime(sysdate),
         uptchargeeventmodreq->objarray[cemcnt].beg_effective_dt_tm = cem.beg_effective_dt_tm,
         uptchargeeventmodreq->objarray[cemcnt].end_effective_dt_tm = cnvtdatetime(cnvtdate(
           "31-dec-2100"),curtime3), uptchargeeventmodreq->objarray[cemcnt].charge_event_mod_type_cd
          = cem.charge_event_mod_type_cd, uptchargeeventmodreq->objarray[cemcnt].field1 = cem.field1,
         uptchargeeventmodreq->objarray[cemcnt].field2 = cem.field2, uptchargeeventmodreq->objarray[
         cemcnt].field3 = cem.field3, uptchargeeventmodreq->objarray[cemcnt].field4 = cem.field4,
         uptchargeeventmodreq->objarray[cemcnt].field5 = cem.field5, uptchargeeventmodreq->objarray[
         cemcnt].field6 = cem.field6, uptchargeeventmodreq->objarray[cemcnt].field7 = cem.field7,
         uptchargeeventmodreq->objarray[cemcnt].field8 = cem.field8, uptchargeeventmodreq->objarray[
         cemcnt].field9 = cem.field9, uptchargeeventmodreq->objarray[cemcnt].field10 = cem.field10,
         uptchargeeventmodreq->objarray[cemcnt].updt_cnt = cem.updt_cnt, uptchargeeventmodreq->
         objarray[cemcnt].code1_cd = cem.code1_cd, uptchargeeventmodreq->objarray[cemcnt].nomen_id =
         cem.nomen_id,
         uptchargeeventmodreq->objarray[cemcnt].field1_id = cem.field1_id, uptchargeeventmodreq->
         objarray[cemcnt].field2_id = cem.field2_id, uptchargeeventmodreq->objarray[cemcnt].field3_id
          = cem.field3_id,
         uptchargeeventmodreq->objarray[cemcnt].field4_id = cem.field4_id, uptchargeeventmodreq->
         objarray[cemcnt].field5_id = cem.field5_id, uptchargeeventmodreq->objarray[cemcnt].cm1_nbr
          = cem.cm1_nbr,
         uptchargeeventmodreq->objarray[cemcnt].activity_dt_tm = cem.activity_dt_tm
        WITH nocounter
       ;end select
     ENDFOR
     IF (size(uptchargeeventmodreq->objarray,5) <= 0)
      IF (validate(debug,- (1)) > 0)
       CALL echo("No charge_event_mods to reactivate")
      ENDIF
     ELSE
      EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargeeventmodreq), replace("REPLY",
       uptchargeeventmodrep)
      IF ((uptchargeeventmodrep->status_data.status != "S"))
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Failed to reactivate old CEM rows"
       IF (validate(debug,- (1)) > 0)
        CALL echorecord(uptchargeeventmodreq)
        CALL echorecord(uptchargeeventmodrep)
       ENDIF
       GO TO end_program
      ENDIF
     ENDIF
     SET cemcnt = 0
     SET stat = alterlist(delchargeeventmodreq->objarray,0)
     FOR (lcemloop = 1 TO size(reprocess_request->process_event[lceloop].codes,5))
       SELECT INTO "nl:"
        FROM charge_event_mod cem
        WHERE (cem.charge_event_mod_id=reprocess_request->process_event[lceloop].codes[lcemloop].
        charge_event_mod_id)
        DETAIL
         cemcnt += 1, stat = alterlist(delchargeeventmodreq->objarray,cemcnt), delchargeeventmodreq->
         objarray[cemcnt].action_type = "DEL",
         delchargeeventmodreq->objarray[cemcnt].charge_event_mod_id = cem.charge_event_mod_id,
         delchargeeventmodreq->objarray[cemcnt].charge_event_id = cem.charge_event_id,
         delchargeeventmodreq->objarray[cemcnt].active_status_cd = reqdata->inactive_status_cd,
         delchargeeventmodreq->objarray[cemcnt].updt_cnt = cem.updt_cnt
        WITH nocounter
       ;end select
     ENDFOR
     IF (size(delchargeeventmodreq->objarray,5) <= 0)
      IF (validate(debug,- (1)) > 0)
       CALL echo("No charge_event_mods to inactivate")
      ENDIF
     ELSE
      EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",delchargeeventmodreq), replace("REPLY",
       delchargeeventmodrep)
      IF ((delchargeeventmodrep->status_data.status != "S"))
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Failed to inactivate new CEM rows"
       IF (validate(debug,- (1)) > 0)
        CALL echorecord(delchargeeventmodreq)
        CALL echorecord(delchargeeventmodrep)
       ENDIF
       GO TO end_program
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (performreprocess(_null_=i2) =i2)
   CALL impersonatepersonnelinfo(1)
   DECLARE licdcodes = i4 WITH protect, noconstant(0)
   DECLARE icdcodecnt = i4 WITH protect, noconstant(0)
   FOR (lchargeeventloop = 1 TO size(reprocess_request->process_event,5))
     IF (size(reprocess_request->process_event[lchargeeventloop].codes,5) > 0)
      SET lrollbackcodecount = 0
      SET stat = alterlist(delchargeeventmodreq->objarray,0)
      SELECT INTO "nl:"
       FROM charge_event_mod c
       WHERE (c.charge_event_id=reprocess_request->process_event[lchargeeventloop].charge_event_id)
        AND c.field1_id=dicd9_cs14002
        AND c.active_ind=1
       DETAIL
        lrollbackcodecount += 1, stat = alterlist(reprocess_request->process_event[lchargeeventloop].
         rollback_codes,lrollbackcodecount), reprocess_request->process_event[lchargeeventloop].
        rollback_codes[lrollbackcodecount].charge_event_mod_id = c.charge_event_mod_id,
        stat = alterlist(delchargeeventmodreq->objarray,lrollbackcodecount), delchargeeventmodreq->
        objarray[lrollbackcodecount].action_type = "DEL", delchargeeventmodreq->objarray[
        lrollbackcodecount].charge_event_mod_id = c.charge_event_mod_id,
        delchargeeventmodreq->objarray[lrollbackcodecount].charge_event_id = c.charge_event_id,
        delchargeeventmodreq->objarray[lrollbackcodecount].active_status_cd = reqdata->
        inactive_status_cd, delchargeeventmodreq->objarray[lrollbackcodecount].updt_cnt = c.updt_cnt
       WITH nocounter
      ;end select
      IF (size(delchargeeventmodreq->objarray,5) <= 0)
       IF (validate(debug,- (1)) > 0)
        CALL echo("No charge_event_mods to inactivate")
       ENDIF
      ELSE
       EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",delchargeeventmodreq), replace(
        "REPLY",delchargeeventmodrep)
       IF ((delchargeeventmodrep->status_data.status != "S"))
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Failed to inactivate old icd9 codes"
        IF (validate(debug,- (1)) > 0)
         CALL echorecord(delchargeeventmodreq)
         CALL echorecord(delchargeeventmodrep)
        ENDIF
        GO TO end_program
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       snewid = seq(charge_event_seq,nextval)"##################;rp0"
       FROM (dummyt d  WITH seq = value(size(reprocess_request->process_event[lchargeeventloop].codes,
          5))),
        nomenclature n
       PLAN (d)
        JOIN (n
        WHERE (n.nomenclature_id=reprocess_request->process_event[lchargeeventloop].codes[d.seq].
        nomenclature_id)
         AND n.active_ind=1)
       DETAIL
        reprocess_request->process_event[lchargeeventloop].codes[d.seq].charge_event_mod_id =
        cnvtreal(snewid), reprocess_request->process_event[lchargeeventloop].codes[d.seq].icd9_code
         = trim(n.source_identifier), reprocess_request->process_event[lchargeeventloop].codes[d.seq]
        .icd9_desc = trim(n.source_string)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Failed to get new ids and nomenclature info"
       GO TO end_program
      ENDIF
      FOR (licdcodes = 1 TO size(reprocess_request->process_event[lchargeeventloop].codes,5))
        SET icdcodecnt += 1
        SET stat = alterlist(addchargeeventmodreq->objarray,icdcodecnt)
        SET addchargeeventmodreq->objarray[icdcodecnt].action_type = "ADD"
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_mod_id = reprocess_request->
        process_event[lchargeeventloop].codes[licdcodes].charge_event_mod_id
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_id = reprocess_request->
        process_event[lchargeeventloop].charge_event_id
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_mod_type_cd = dbillcode_cs13019
        SET addchargeeventmodreq->objarray[icdcodecnt].field6 = reprocess_request->process_event[
        lchargeeventloop].codes[licdcodes].icd9_code
        SET addchargeeventmodreq->objarray[icdcodecnt].field7 = reprocess_request->process_event[
        lchargeeventloop].codes[licdcodes].icd9_desc
        SET addchargeeventmodreq->objarray[icdcodecnt].field1_id = dicd9_cs14002
        SET addchargeeventmodreq->objarray[icdcodecnt].field2_id = licdcodes
        SET addchargeeventmodreq->objarray[icdcodecnt].nomen_id = reprocess_request->process_event[
        lchargeeventloop].codes[licdcodes].nomenclature_id
        SET addchargeeventmodreq->objarray[icdcodecnt].active_ind = 1
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_cd = reqdata->active_status_cd
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_dt_tm = cnvtdatetime(sysdate)
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_prsnl_id = reqinfo->updt_id
        SET addchargeeventmodreq->objarray[icdcodecnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
        SET addchargeeventmodreq->objarray[icdcodecnt].end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 23:59:59")
      ENDFOR
     ENDIF
   ENDFOR
   IF (size(addchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to add")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",addchargeeventmodreq), replace("REPLY",
     addchargeeventmodrep)
    IF ((addchargeeventmodrep->status_data.status="F"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert new icd9 codes"
     GO TO end_program
    ENDIF
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM charge_event_act c,
     (dummyt d  WITH seq = value(size(reprocess_request->process_event,5)))
    PLAN (d)
     JOIN (c
     WHERE (c.charge_event_id=reprocess_request->process_event[d.seq].charge_event_id)
      AND c.active_ind=1)
    DETAIL
     ichargeeventactcount += 1, stat = alterlist(reprocess_request->process_event[d.seq].charge_acts,
      ichargeeventactcount), reprocess_request->process_event[d.seq].charge_acts[ichargeeventactcount
     ].charge_event_act_id = c.charge_event_act_id
    WITH nocounter
   ;end select
   SET iret = uar_crmbeginapp(itransferappid,happtransfer)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to begin app"
    GO TO end_program
   ENDIF
   SET iret = uar_crmbegintask(happtransfer,itransfertaskid,htasktransfer)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to begin task"
    GO TO end_program
   ENDIF
   SET iret = uar_crmbeginreq(htasktransfer,"",itransferreqid,hstepreprocess)
   IF (iret != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to begin step"
    RETURN(false)
   ENDIF
   SET hreq = uar_crmgetrequest(hstepreprocess)
   IF (hreq=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get request handle"
    RETURN(false)
   ENDIF
   SET stat = uar_srvsetshort(hreq,"charge_event_qual",reprocess_request->charge_event_qual)
   SET stat = uar_srvsetdouble(hreq,"process_type_cd",dreprocess_cs13029)
   FOR (lchargeeventloop = 1 TO size(reprocess_request->process_event,5))
     SET hlist = uar_srvadditem(hreq,"process_event")
     IF (hlist=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get event list handle"
      RETURN(false)
     ENDIF
     SET stat = uar_srvsetdouble(hlist,"charge_event_id",reprocess_request->process_event[
      lchargeeventloop].charge_event_id)
     SET stat = uar_srvsetdouble(hlist,"encntr_bill_type_cd",request->bill_type_cd)
     SET stat = uar_srvsetshort(hlist,"charge_item_qual",reprocess_request->process_event[
      lchargeeventloop].charge_item_qual)
     FOR (ichargeloop = 1 TO reprocess_request->process_event[lchargeeventloop].charge_item_qual)
       SET hlist2 = uar_srvadditem(hlist,"charge_item")
       IF (hlist2=0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Failed to get charge list handle"
        RETURN(false)
       ENDIF
       SET stat = uar_srvsetdouble(hlist2,"charge_item_id",reprocess_request->process_event[
        lchargeeventloop].charge_item[ichargeloop].charge_item_id)
     ENDFOR
     FOR (ichargeeventactloop = 1 TO size(reprocess_request->process_event[lchargeeventloop].
      charge_acts,5))
       SET hlist2 = uar_srvadditem(hlist,"charge_acts")
       IF (hlist2=0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Failed to get charge act list handle"
        RETURN(false)
       ENDIF
       SET stat = uar_srvsetdouble(hlist2,"charge_event_act_id",reprocess_request->process_event[
        lchargeeventloop].charge_acts[ichargeeventactloop].charge_event_act_id)
     ENDFOR
   ENDFOR
   SET iret = uar_crmperform(hstepreprocess)
   IF (iret != 0)
    CALL echo("failed")
    CALL echo(build("iRet=",iret))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to perform reprocess step"
    ROLLBACK
    CALL rollbackchargeeventmod(0)
    COMMIT
    RETURN(false)
   ENDIF
   SET hreply = uar_crmgetreply(hstepreprocess)
   IF (hreply=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get reply"
    RETURN(false)
   ENDIF
   SET ichargecount = uar_srvgetitemcount(hreply,"charges")
   IF (ichargecount=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Reply contained no charges"
    RETURN(false)
   ENDIF
   FOR (ichargeloop = 1 TO ichargecount)
     SET hlist = uar_srvgetitem(hreply,"charges",(ichargeloop - 1))
     IF (hlist=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Failed to get list handle from reprocess reply"
      RETURN(false)
     ENDIF
     SET lnewchargecount += 1
     SET stat = alterlist(new_charge_list->charges,lnewchargecount)
     SET new_charge_list->charges[lnewchargecount].charge_item_id = uar_srvgetdouble(hlist,
      "charge_item_id")
     SET new_charge_list->charges[lnewchargecount].process_flg = uar_srvgetshort(hlist,"process_flg")
     SET lchargemodcount += 1
     SET stat = alterlist(addchargemodreq->charge_mod,lchargemodcount)
     SET addchargemodreq->charge_mod[lchargemodcount].charge_item_id = new_charge_list->charges[
     lnewchargecount].charge_item_id
     SET addchargemodreq->charge_mod[lchargemodcount].charge_mod_type_cd = dmodrsn_cs13019
     IF ((request->bill_type_cd=dclient_cs22569))
      SET addchargemodreq->charge_mod[lchargemodcount].field6 =
      "The charge was transferred to client"
     ELSEIF ((request->bill_type_cd=dpatient_cs22569))
      SET addchargemodreq->charge_mod[lchargemodcount].field6 =
      "The charge was transferred to patient"
     ENDIF
     SET addchargemodreq->charge_mod[lchargemodcount].field7 = request->comment_freetext
     SET addchargemodreq->charge_mod[lchargemodcount].field1_id = dtransfer_cs4001989
     SET addchargemodreq->charge_mod[lchargemodcount].field2_id = request->comment_cd
     SET addchargemodreq->charge_mod[lchargemodcount].action_type = "ADD"
     SET addchargemodreq->charge_mod_qual = lchargemodcount
   ENDFOR
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",
    addchargemodrep)
   IF ((addchargemodrep->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to add charge mods"
    RETURN(false)
   ENDIF
   COMMIT
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (performmanualcopy(_null_=i2) =i2)
   FREE RECORD addcredit_request
   RECORD addcredit_request(
     1 charge_qual = i2
     1 charge[*]
       2 charge_item_id = f8
       2 suspense_rsn_cd = f8
       2 reason_comment = vc
       2 late_charge_processing_ind = i2
   )
   FREE RECORD addcredit_reply
   RECORD addcredit_reply(
     1 charge_qual = i2
     1 dequeued_ind = i2
     1 charge[*]
       2 charge_item_id = f8
       2 parent_charge_item_id = f8
       2 charge_event_act_id = f8
       2 charge_event_id = f8
       2 bill_item_id = f8
       2 order_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 person_name = vc
       2 payor_id = f8
       2 perf_loc_cd = f8
       2 perf_loc_disp = c40
       2 perf_loc_desc = c60
       2 perf_loc_mean = c12
       2 ord_loc_cd = f8
       2 ord_phys_id = f8
       2 perf_phys_id = f8
       2 charge_description = vc
       2 price_sched_id = f8
       2 item_quantity = f8
       2 item_price = f8
       2 item_extended_price = f8
       2 item_allowable = f8
       2 item_copay = f8
       2 charge_type_cd = f8
       2 charge_type_disp = c40
       2 charge_type_desc = c60
       2 charge_type_mean = c12
       2 research_acct_id = f8
       2 suspense_rsn_cd = f8
       2 suspense_rsn_disp = c40
       2 suspense_rsn_desc = c60
       2 suspense_rsn_mean = c12
       2 reason_comment = vc
       2 posted_cd = f8
       2 posted_dt_tm = dq8
       2 process_flg = i4
       2 service_dt_tm = dq8
       2 price_sched_id = f8
       2 activity_dt_tm = dq8
       2 updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 username = vc
       2 updt_task = i4
       2 updt_applctx = i4
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 credited_dt_tm = dq8
       2 adjusted_dt_tm = dq8
       2 interface_file_id = f8
       2 tier_group_cd = f8
       2 tier_group_disp = c40
       2 tier_group_desc = c60
       2 tier_group_mean = c12
       2 def_bill_item_id = f8
       2 verify_phys_id = f8
       2 gross_price = f8
       2 discount_amount = f8
       2 manual_ind = i2
       2 combine_ind = i2
       2 bundle_id = f8
       2 institution_cd = f8
       2 department_cd = f8
       2 section_cd = f8
       2 subsection_cd = f8
       2 level5_cd = f8
       2 admit_type_cd = f8
       2 med_service_cd = f8
       2 activity_type_cd = f8
       2 activity_type_disp = c40
       2 activity_type_desc = c60
       2 activity_type_mean = c12
       2 inst_fin_nbr = c50
       2 cost_center_cd = f8
       2 cost_center_disp = c40
       2 cost_center_desc = c60
       2 cost_center_mean = c12
       2 abn_status_cd = f8
       2 health_plan_id = f8
       2 fin_class_cd = f8
       2 payor_type_cd = f8
       2 item_reimbursement = f8
       2 item_interval_id = f8
       2 item_list_price = f8
       2 list_price_sched_id = f8
       2 start_dt_tm = dq8
       2 stop_dt_tm = dq8
       2 epsdt_ind = i2
       2 ref_phys_id = f8
       2 item_deductible_amt = f8
       2 patient_responsibility_flag = i2
       2 interface_flag = i2
       2 activity_sub_type_cd = f8
       2 provider_specialty_cd = f8
       2 charge_mod_qual = i2
       2 charge_mod[*]
         3 charge_mod_id = f8
         3 charge_mod_type_cd = f8
         3 field1_id = f8
         3 field2_id = f8
         3 field3_id = f8
         3 field4_id = f8
         3 field5_id = f8
         3 field1 = vc
         3 field2 = vc
         3 field3 = vc
         3 field4 = vc
         3 field5 = vc
         3 field6 = vc
         3 field7 = vc
         3 field8 = vc
         3 field9 = vc
         3 field10 = vc
         3 nomen_id = f8
         3 cm1_nbr = f8
         3 activity_dt_tm = dq8
         3 active_ind = i2
     1 original_charge_qual = i2
     1 original_charge[*]
       2 charge_item_id = f8
       2 process_flg = f8
       2 updt_id = f8
       2 updt_task = i4
       2 updt_applctx = f8
       2 updt_dt_tm = dq8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD findchargerequest
   RECORD findchargerequest(
     1 charge_item_id = f8
   )
   FREE RECORD findchargereply
   RECORD findchargereply(
     1 charge_item_count = i4
     1 charge_items[*]
       2 charge_item_id = f8
       2 parent_charge_item_id = f8
       2 charge_event_act_id = f8
       2 charge_event_id = f8
       2 bill_item_id = f8
       2 order_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 person_name = vc
       2 username = vc
       2 payor_id = f8
       2 ord_loc_cd = f8
       2 perf_loc_cd = f8
       2 ord_phys_id = f8
       2 perf_phys_id = f8
       2 charge_description = vc
       2 price_sched_id = f8
       2 item_quantity = f8
       2 item_price = f8
       2 item_extended_price = f8
       2 item_allowable = f8
       2 item_copay = f8
       2 charge_type_cd = f8
       2 research_acct_id = f8
       2 suspense_rsn_cd = f8
       2 reason_comment = vc
       2 posted_cd = f8
       2 posted_dt_tm = dq8
       2 process_flg = i4
       2 service_dt_tm = dq8
       2 activity_dt_tm = dq8
       2 updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_task = i4
       2 updt_applctx = i4
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 active_ind = i2
       2 active_status_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 credited_dt_tm = dq8
       2 adjusted_dt_tm = dq8
       2 interface_file_id = f8
       2 tier_group_cd = f8
       2 def_bill_item_id = f8
       2 verify_phys_id = f8
       2 gross_price = f8
       2 discount_amount = f8
       2 manual_ind = i2
       2 combine_ind = i2
       2 activity_type_cd = f8
       2 admit_type_cd = f8
       2 bundle_id = f8
       2 department_cd = f8
       2 institution_cd = f8
       2 level5_cd = f8
       2 med_service_cd = f8
       2 section_cd = f8
       2 subsection_cd = f8
       2 abn_status_cd = f8
       2 cost_center_cd = f8
       2 inst_fin_nbr = vc
       2 fin_class_cd = f8
       2 health_plan_id = f8
       2 item_interval_id = f8
       2 item_list_price = f8
       2 item_reimbursement = f8
       2 list_price_sched_id = f8
       2 payor_type_cd = f8
       2 epsdt_ind = i2
       2 ref_phys_id = f8
       2 start_dt_tm = dq8
       2 stop_dt_tm = dq8
       2 alpha_nomen_id = f8
       2 server_process_flag = i2
       2 offset_charge_item_id = f8
       2 item_deductible_amt = f8
       2 patient_responsibility_flag = i2
       2 activity_sub_type_cd = f8
       2 provider_specialty_cd = f8
       2 item_price_adj_amt = f8
       2 charge_mod_count = i4
       2 charge_mods[*]
         3 charge_mod_id = f8
         3 charge_mod_type_cd = f8
         3 field1 = vc
         3 field2 = vc
         3 field3 = vc
         3 field4 = vc
         3 field5 = vc
         3 field6 = vc
         3 field7 = vc
         3 field8 = vc
         3 field9 = vc
         3 field10 = vc
         3 field1_id = f8
         3 field2_id = f8
         3 field3_id = f8
         3 field4_id = f8
         3 field5_id = f8
         3 nomen_id = f8
         3 cm1_nbr = f8
         3 activity_dt_tm = dq8
         3 active_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD addcharge_request
   RECORD addcharge_request(
     1 objarray[*]
       2 charge_item_id = f8
       2 parent_charge_item_id = f8
       2 charge_event_act_id = f8
       2 charge_event_id = f8
       2 bill_item_id = f8
       2 order_id = f8
       2 encntr_id = f8
       2 person_id = f8
       2 payor_id = f8
       2 ord_loc_cd = f8
       2 perf_loc_cd = f8
       2 ord_phys_id = f8
       2 perf_phys_id = f8
       2 charge_description = vc
       2 price_sched_id = f8
       2 item_quantity = f8
       2 item_price = f8
       2 item_extended_price = f8
       2 item_allowable = f8
       2 item_copay = f8
       2 charge_type_cd = f8
       2 research_acct_id = f8
       2 suspense_rsn_cd = f8
       2 reason_comment = vc
       2 posted_cd = f8
       2 posted_dt_tm = dq8
       2 posted_dt_tm_null = i2
       2 process_flg = i4
       2 service_dt_tm = dq8
       2 service_dt_tm_null = i2
       2 activity_dt_tm = dq8
       2 activity_dt_tm_null = i2
       2 updt_cnt = i4
       2 active_ind = i2
       2 active_status_cd = f8
       2 beg_effective_dt_tm = dq8
       2 beg_effective_dt_tm_null = i2
       2 end_effective_dt_tm = dq8
       2 end_effective_dt_tm_null = i2
       2 credited_dt_tm = dq8
       2 credited_dt_tm_null = i2
       2 adjusted_dt_tm = dq8
       2 adjusted_dt_tm_null = i2
       2 interface_file_id = f8
       2 tier_group_cd = f8
       2 def_bill_item_id = f8
       2 verify_phys_id = f8
       2 gross_price = f8
       2 discount_amount = f8
       2 manual_ind = i2
       2 combine_ind = i2
       2 activity_type_cd = f8
       2 admit_type_cd = f8
       2 bundle_id = f8
       2 department_cd = f8
       2 institution_cd = f8
       2 level5_cd = f8
       2 med_service_cd = f8
       2 section_cd = f8
       2 subsection_cd = f8
       2 abn_status_cd = f8
       2 cost_center_cd = f8
       2 inst_fin_nbr = vc
       2 fin_class_cd = f8
       2 health_plan_id = f8
       2 item_interval_id = f8
       2 item_list_price = f8
       2 item_reimbursement = f8
       2 list_price_sched_id = f8
       2 payor_type_cd = f8
       2 epsdt_ind = i2
       2 ref_phys_id = f8
       2 start_dt_tm = dq8
       2 start_dt_tm_null = i2
       2 stop_dt_tm = dq8
       2 stop_dt_tm_null = i2
       2 alpha_nomen_id = f8
       2 server_process_flag = i2
       2 offset_charge_item_id = f8
       2 item_deductible_amt = f8
       2 patient_responsibility_flag = i2
       2 activity_sub_type_cd = f8
       2 provider_specialty_cd = f8
       2 item_price_adj_amt = f8
   )
   RECORD addcharge_reply(
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
   )
   DECLARE dpatientinterfacefileid = f8 WITH protect, noconstant(0.0)
   DECLARE dclientinterfacefileid = f8 WITH protect, noconstant(0.0)
   DECLARE dpftptacct_cs22449 = f8 WITH protect, noconstant(0.0)
   DECLARE dpftcltbill_cs22449 = f8 WITH protect, noconstant(0.0)
   DECLARE dpftcltacct_cs22449 = f8 WITH protect, noconstant(0.0)
   DECLARE lchargeeventloop = i4 WITH protect, noconstant(0)
   DECLARE lchargeloop = i4 WITH protect, noconstant(0)
   DECLARE licdcodes = i4 WITH protect, noconstant(0)
   DECLARE icdcodecnt = i4 WITH protect, noconstant(0)
   SET stat = uar_get_meaning_by_codeset(22449,"PFTPTACCT",1,dpftptacct_cs22449)
   SET stat = uar_get_meaning_by_codeset(22449,"PFTCLTBILL",1,dpftcltbill_cs22449)
   SET stat = uar_get_meaning_by_codeset(22449,"PFTCLTACCT",1,dpftcltacct_cs22449)
   SELECT INTO "nl:"
    FROM interface_file i
    WHERE i.profit_type_cd > 0.0
     AND i.active_ind=1
    DETAIL
     IF (i.profit_type_cd=dpftptacct_cs22449)
      dpatientinterfacefileid = i.interface_file_id
     ELSE
      dclientinterfacefileid = i.interface_file_id
     ENDIF
    WITH nocounter
   ;end select
   IF (((dpatientinterfacefileid=0.0) OR (dclientinterfacefileid=0.0)) )
    CALL echo("Failed to populate interface file ids")
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to populate interface file ids"
    RETURN(false)
   ENDIF
   DECLARE cemcnt = i4 WITH protect, noconstant(0)
   FOR (lchargeeventloop = 1 TO size(manualchargelist->process_event,5))
     IF (size(manualchargelist->process_event[lchargeeventloop].codes,5) > 0)
      SET cemcnt = 0
      SET stat = alterlist(delchargeeventmodreq->objarray,0)
      SELECT INTO "nl:"
       FROM charge_event_mod cem
       WHERE (cem.charge_event_id=manualchargelist->process_event[lchargeeventloop].charge_event_id)
        AND cem.field1_id=dicd9_cs14002
        AND cem.active_ind=1
       DETAIL
        cemcnt += 1, stat = alterlist(delchargeeventmodreq->objarray,cemcnt), delchargeeventmodreq->
        objarray[cemcnt].action_type = "DEL",
        delchargeeventmodreq->objarray[cemcnt].charge_event_mod_id = cem.charge_event_mod_id,
        delchargeeventmodreq->objarray[cemcnt].charge_event_id = cem.charge_event_id,
        delchargeeventmodreq->objarray[cemcnt].active_status_cd = reqdata->inactive_status_cd,
        delchargeeventmodreq->objarray[cemcnt].updt_cnt = cem.updt_cnt
       WITH nocounter
      ;end select
      IF (size(delchargeeventmodreq->objarray,5) <= 0)
       IF (validate(debug,- (1)) > 0)
        CALL echo("No charge_event_mods to inactivate")
       ENDIF
      ELSE
       EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",delchargeeventmodreq), replace(
        "REPLY",delchargeeventmodrep)
       IF ((delchargeeventmodrep->status_data.status != "S"))
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "Failed to inactivate old icd9 codes"
        IF (validate(debug,- (1)) > 0)
         CALL echorecord(delchargeeventmodreq)
         CALL echorecord(delchargeeventmodrep)
        ENDIF
        RETURN(false)
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       snewid = seq(charge_event_seq,nextval)"##################;rp0"
       FROM (dummyt d  WITH seq = value(size(manualchargelist->process_event[lchargeeventloop].codes,
          5))),
        nomenclature n
       PLAN (d)
        JOIN (n
        WHERE (n.nomenclature_id=manualchargelist->process_event[lchargeeventloop].codes[d.seq].
        nomenclature_id)
         AND n.active_ind=1)
       DETAIL
        manualchargelist->process_event[lchargeeventloop].codes[d.seq].charge_event_mod_id = cnvtreal
        (snewid), manualchargelist->process_event[lchargeeventloop].codes[d.seq].icd9_code = trim(n
         .source_identifier), manualchargelist->process_event[lchargeeventloop].codes[d.seq].
        icd9_desc = trim(n.source_string)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Failed to get new ids and nomenclature info"
       RETURN(false)
      ENDIF
      FOR (licdcodes = 1 TO size(manualchargelist->process_event[lchargeeventloop].codes,5))
        SET icdcodecnt += 1
        SET stat = alterlist(addchargeeventmodreq->objarray,icdcodecnt)
        SET addchargeeventmodreq->objarray[icdcodecnt].action_type = "ADD"
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_mod_id = manualchargelist->
        process_event[lchargeeventloop].codes[licdcodes].charge_event_mod_id
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_id = manualchargelist->
        process_event[lchargeeventloop].charge_event_id
        SET addchargeeventmodreq->objarray[icdcodecnt].charge_event_mod_type_cd = dbillcode_cs13019
        SET addchargeeventmodreq->objarray[icdcodecnt].field6 = manualchargelist->process_event[
        lchargeeventloop].codes[licdcodes].icd9_code
        SET addchargeeventmodreq->objarray[icdcodecnt].field7 = manualchargelist->process_event[
        lchargeeventloop].codes[licdcodes].icd9_desc
        SET addchargeeventmodreq->objarray[icdcodecnt].field1_id = dicd9_cs14002
        SET addchargeeventmodreq->objarray[icdcodecnt].field2_id = licdcodes
        SET addchargeeventmodreq->objarray[icdcodecnt].nomen_id = manualchargelist->process_event[
        lchargeeventloop].codes[licdcodes].nomenclature_id
        SET addchargeeventmodreq->objarray[icdcodecnt].active_ind = 1
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_cd = reqdata->active_status_cd
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_dt_tm = cnvtdatetime(sysdate)
        SET addchargeeventmodreq->objarray[icdcodecnt].active_status_prsnl_id = reqinfo->updt_id
        SET addchargeeventmodreq->objarray[icdcodecnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
        SET addchargeeventmodreq->objarray[icdcodecnt].end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 23:59:59")
      ENDFOR
     ENDIF
   ENDFOR
   IF (size(addchargeeventmodreq->objarray,5) <= 0)
    CALL echo("No charge_event_mods to add")
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",addchargeeventmodreq), replace("REPLY",
     addchargeeventmodrep)
    IF ((addchargeeventmodrep->status_data.status="F"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to get insert new icd9 codes"
     RETURN(false)
    ENDIF
   ENDIF
   FOR (lchargeeventloop = 1 TO size(manualchargelist->process_event,5))
     FOR (lchargeloop = 1 TO size(manualchargelist->process_event[lchargeeventloop].charges,5))
       SET findchargerequest->charge_item_id = manualchargelist->process_event[lchargeeventloop].
       charges[lchargeloop].charge_item_id
       EXECUTE afc_charge_find  WITH replace("REQUEST",findchargerequest), replace("REPLY",
        findchargereply)
       IF ((((findchargereply->charge_item_count < 1)) OR ((findchargereply->status_data.status="F")
       )) )
        CALL echo(build("Charge Find Reply Status is ",findchargereply->status_data.status,
          " Ending Program"))
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to find charge"
        RETURN(false)
       ENDIF
       SET stat = alterlist(addcharge_request->objarray,1)
       SET addcharge_request->objarray[1].parent_charge_item_id = findchargereply->charge_items[1].
       parent_charge_item_id
       SET addcharge_request->objarray[1].charge_event_act_id = findchargereply->charge_items[1].
       charge_event_act_id
       SET addcharge_request->objarray[1].charge_event_id = findchargereply->charge_items[1].
       charge_event_id
       SET addcharge_request->objarray[1].bill_item_id = findchargereply->charge_items[1].
       bill_item_id
       SET addcharge_request->objarray[1].order_id = findchargereply->charge_items[1].order_id
       SET addcharge_request->objarray[1].encntr_id = findchargereply->charge_items[1].encntr_id
       SET addcharge_request->objarray[1].person_id = findchargereply->charge_items[1].person_id
       SET addcharge_request->objarray[1].payor_id = findchargereply->charge_items[1].payor_id
       SET addcharge_request->objarray[1].ord_loc_cd = findchargereply->charge_items[1].ord_loc_cd
       SET addcharge_request->objarray[1].perf_loc_cd = findchargereply->charge_items[1].perf_loc_cd
       SET addcharge_request->objarray[1].ord_phys_id = findchargereply->charge_items[1].ord_phys_id
       SET addcharge_request->objarray[1].perf_phys_id = findchargereply->charge_items[1].
       perf_phys_id
       SET addcharge_request->objarray[1].charge_description = findchargereply->charge_items[1].
       charge_description
       SET addcharge_request->objarray[1].price_sched_id = findchargereply->charge_items[1].
       price_sched_id
       SET addcharge_request->objarray[1].item_quantity = findchargereply->charge_items[1].
       item_quantity
       SET addcharge_request->objarray[1].item_price = findchargereply->charge_items[1].item_price
       SET addcharge_request->objarray[1].item_extended_price = findchargereply->charge_items[1].
       item_extended_price
       SET addcharge_request->objarray[1].item_allowable = findchargereply->charge_items[1].
       item_allowable
       SET addcharge_request->objarray[1].item_copay = findchargereply->charge_items[1].item_copay
       SET addcharge_request->objarray[1].charge_type_cd = findchargereply->charge_items[1].
       charge_type_cd
       SET addcharge_request->objarray[1].research_acct_id = findchargereply->charge_items[1].
       research_acct_id
       SET addcharge_request->objarray[1].suspense_rsn_cd = findchargereply->charge_items[1].
       suspense_rsn_cd
       SET addcharge_request->objarray[1].reason_comment = findchargereply->charge_items[1].
       reason_comment
       SET addcharge_request->objarray[1].posted_cd = findchargereply->charge_items[1].posted_cd
       SET addcharge_request->objarray[1].posted_dt_tm = findchargereply->charge_items[1].
       posted_dt_tm
       SET addcharge_request->objarray[1].service_dt_tm = findchargereply->charge_items[1].
       service_dt_tm
       SET addcharge_request->objarray[1].activity_dt_tm = findchargereply->charge_items[1].
       activity_dt_tm
       SET addcharge_request->objarray[1].active_ind = findchargereply->charge_items[1].active_ind
       SET addcharge_request->objarray[1].active_status_cd = findchargereply->charge_items[1].
       active_status_cd
       SET addcharge_request->objarray[1].beg_effective_dt_tm = findchargereply->charge_items[1].
       beg_effective_dt_tm
       SET addcharge_request->objarray[1].end_effective_dt_tm = findchargereply->charge_items[1].
       end_effective_dt_tm
       SET addcharge_request->objarray[1].credited_dt_tm = findchargereply->charge_items[1].
       credited_dt_tm
       SET addcharge_request->objarray[1].adjusted_dt_tm = findchargereply->charge_items[1].
       adjusted_dt_tm
       SET addcharge_request->objarray[1].tier_group_cd = findchargereply->charge_items[1].
       tier_group_cd
       SET addcharge_request->objarray[1].def_bill_item_id = findchargereply->charge_items[1].
       def_bill_item_id
       SET addcharge_request->objarray[1].verify_phys_id = findchargereply->charge_items[1].
       verify_phys_id
       SET addcharge_request->objarray[1].gross_price = findchargereply->charge_items[1].gross_price
       SET addcharge_request->objarray[1].discount_amount = findchargereply->charge_items[1].
       discount_amount
       SET addcharge_request->objarray[1].manual_ind = findchargereply->charge_items[1].manual_ind
       SET addcharge_request->objarray[1].combine_ind = findchargereply->charge_items[1].combine_ind
       SET addcharge_request->objarray[1].activity_type_cd = findchargereply->charge_items[1].
       activity_type_cd
       SET addcharge_request->objarray[1].activity_sub_type_cd = findchargereply->charge_items[1].
       activity_sub_type_cd
       SET addcharge_request->objarray[1].provider_specialty_cd = findchargereply->charge_items[1].
       provider_specialty_cd
       SET addcharge_request->objarray[1].admit_type_cd = findchargereply->charge_items[1].
       admit_type_cd
       SET addcharge_request->objarray[1].bundle_id = findchargereply->charge_items[1].bundle_id
       SET addcharge_request->objarray[1].department_cd = findchargereply->charge_items[1].
       department_cd
       SET addcharge_request->objarray[1].institution_cd = findchargereply->charge_items[1].
       institution_cd
       SET addcharge_request->objarray[1].level5_cd = findchargereply->charge_items[1].level5_cd
       SET addcharge_request->objarray[1].med_service_cd = findchargereply->charge_items[1].
       med_service_cd
       SET addcharge_request->objarray[1].section_cd = findchargereply->charge_items[1].section_cd
       SET addcharge_request->objarray[1].subsection_cd = findchargereply->charge_items[1].
       subsection_cd
       SET addcharge_request->objarray[1].abn_status_cd = findchargereply->charge_items[1].
       abn_status_cd
       SET addcharge_request->objarray[1].cost_center_cd = findchargereply->charge_items[1].
       cost_center_cd
       SET addcharge_request->objarray[1].inst_fin_nbr = findchargereply->charge_items[1].
       inst_fin_nbr
       SET addcharge_request->objarray[1].fin_class_cd = findchargereply->charge_items[1].
       fin_class_cd
       SET addcharge_request->objarray[1].health_plan_id = findchargereply->charge_items[1].
       health_plan_id
       SET addcharge_request->objarray[1].item_interval_id = findchargereply->charge_items[1].
       item_interval_id
       SET addcharge_request->objarray[1].item_list_price = findchargereply->charge_items[1].
       item_list_price
       SET addcharge_request->objarray[1].item_reimbursement = findchargereply->charge_items[1].
       item_reimbursement
       SET addcharge_request->objarray[1].list_price_sched_id = findchargereply->charge_items[1].
       list_price_sched_id
       SET addcharge_request->objarray[1].payor_type_cd = findchargereply->charge_items[1].
       payor_type_cd
       SET addcharge_request->objarray[1].epsdt_ind = findchargereply->charge_items[1].epsdt_ind
       SET addcharge_request->objarray[1].ref_phys_id = findchargereply->charge_items[1].ref_phys_id
       SET addcharge_request->objarray[1].start_dt_tm = findchargereply->charge_items[1].start_dt_tm
       SET addcharge_request->objarray[1].stop_dt_tm = findchargereply->charge_items[1].stop_dt_tm
       SET addcharge_request->objarray[1].alpha_nomen_id = findchargereply->charge_items[1].
       alpha_nomen_id
       SET addcharge_request->objarray[1].server_process_flag = findchargereply->charge_items[1].
       server_process_flag
       SET addcharge_request->objarray[1].offset_charge_item_id = findchargereply->charge_items[1].
       offset_charge_item_id
       SET addcharge_request->objarray[1].item_deductible_amt = findchargereply->charge_items[1].
       item_deductible_amt
       SET addcharge_request->objarray[1].patient_responsibility_flag = findchargereply->
       charge_items[1].patient_responsibility_flag
       SET addcharge_request->objarray[1].item_price_adj_amt = findchargereply->charge_items[1].
       item_price_adj_amt
       SET addcharge_request->objarray[1].process_flg = 0
       SELECT INTO "nl:"
        FROM interface_file i
        WHERE (i.interface_file_id=findchargereply->charge_items[1].interface_file_id)
         AND i.active_ind=1
        DETAIL
         IF (i.profit_type_cd=dpftptacct_cs22449)
          addcharge_request->objarray[1].interface_file_id = dclientinterfacefileid
         ELSEIF (i.profit_type_cd IN (dpftcltbill_cs22449, dpftcltacct_cs22449))
          addcharge_request->objarray[1].interface_file_id = dpatientinterfacefileid
         ELSE
          addcharge_request->objarray[1].interface_file_id = findchargereply->charge_items[1].
          interface_file_id
         ENDIF
        WITH nocounter
       ;end select
       EXECUTE afc_add_charge  WITH replace("REQUEST",addcharge_request), replace("REPLY",
        addcharge_reply)
       IF ((addcharge_reply->status_data.status="F"))
        CALL echo(build("Charge add Reply Status is ",addcharge_reply->status_data.status,
          " Ending Program"))
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to add charge"
        RETURN(false)
       ENDIF
       SET lnewchargecount += 1
       SET stat = alterlist(new_charge_list->charges,lnewchargecount)
       SET new_charge_list->charges[lnewchargecount].charge_item_id = cnvtreal(addcharge_reply->
        mod_objs[1].mod_recs[1].pk_values)
       SET new_charge_list->charges[lnewchargecount].process_flg = addcharge_request->objarray[1].
       process_flg
       FOR (lchargemodloop = 1 TO size(findchargereply->charge_items[1].charge_mods,5))
         IF ((findchargereply->charge_items[1].charge_mods[lchargemodloop].field1_id != dicd9_cs14002
         ))
          SET lchargemodcount += 1
          SET stat = alterlist(addchargemodreq->charge_mod,lchargemodcount)
          SET addchargemodreq->charge_mod[lchargemodcount].charge_item_id = cnvtreal(addcharge_reply
           ->mod_objs[1].mod_recs[1].pk_values)
          SET addchargemodreq->charge_mod[lchargemodcount].charge_mod_type_cd = findchargereply->
          charge_items[1].charge_mods[lchargemodloop].charge_mod_type_cd
          SET addchargemodreq->charge_mod[lchargemodcount].field1 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field1
          SET addchargemodreq->charge_mod[lchargemodcount].field2 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field2
          SET addchargemodreq->charge_mod[lchargemodcount].field3 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field3
          SET addchargemodreq->charge_mod[lchargemodcount].field4 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field4
          SET addchargemodreq->charge_mod[lchargemodcount].field5 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field5
          SET addchargemodreq->charge_mod[lchargemodcount].field6 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field6
          SET addchargemodreq->charge_mod[lchargemodcount].field7 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field7
          SET addchargemodreq->charge_mod[lchargemodcount].field8 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field8
          SET addchargemodreq->charge_mod[lchargemodcount].field9 = findchargereply->charge_items[1].
          charge_mods[lchargemodloop].field9
          SET addchargemodreq->charge_mod[lchargemodcount].field10 = findchargereply->charge_items[1]
          .charge_mods[lchargemodloop].field10
          SET addchargemodreq->charge_mod[lchargemodcount].activity_dt_tm = findchargereply->
          charge_items[1].charge_mods[lchargemodloop].activity_dt_tm
          SET addchargemodreq->charge_mod[lchargemodcount].field1_id = findchargereply->charge_items[
          1].charge_mods[lchargemodloop].field1_id
          SET addchargemodreq->charge_mod[lchargemodcount].field2_id = findchargereply->charge_items[
          1].charge_mods[lchargemodloop].field2_id
          SET addchargemodreq->charge_mod[lchargemodcount].field3_id = findchargereply->charge_items[
          1].charge_mods[lchargemodloop].field3_id
          SET addchargemodreq->charge_mod[lchargemodcount].field4_id = findchargereply->charge_items[
          1].charge_mods[lchargemodloop].field4_id
          SET addchargemodreq->charge_mod[lchargemodcount].field5_id = findchargereply->charge_items[
          1].charge_mods[lchargemodloop].field5_id
          SET addchargemodreq->charge_mod[lchargemodcount].nomen_id = findchargereply->charge_items[1
          ].charge_mods[lchargemodloop].nomen_id
          SET addchargemodreq->charge_mod[lchargemodcount].cm1_nbr = findchargereply->charge_items[1]
          .charge_mods[lchargemodloop].cm1_nbr
          SET addchargemodreq->charge_mod[lchargemodcount].action_type = "ADD"
          SET addchargemodreq->charge_mod_qual = lchargemodcount
         ENDIF
       ENDFOR
       FOR (lchargemodloop = 1 TO size(manualchargelist->process_event[lchargeeventloop].codes,5))
         SET lchargemodcount += 1
         SET stat = alterlist(addchargemodreq->charge_mod,lchargemodcount)
         SET addchargemodreq->charge_mod[lchargemodcount].charge_item_id = cnvtreal(addcharge_reply->
          mod_objs[1].mod_recs[1].pk_values)
         SET addchargemodreq->charge_mod[lchargemodcount].charge_mod_type_cd = dbillcode_cs13019
         SET addchargemodreq->charge_mod[lchargemodcount].field6 = manualchargelist->process_event[
         lchargeeventloop].codes[lchargemodloop].icd9_code
         SET addchargemodreq->charge_mod[lchargemodcount].field7 = manualchargelist->process_event[
         lchargeeventloop].codes[lchargemodloop].icd9_desc
         SET addchargemodreq->charge_mod[lchargemodcount].field1_id = dicd9_cs14002
         SET addchargemodreq->charge_mod[lchargemodcount].field2_id = lchargemodloop
         SET addchargemodreq->charge_mod[lchargemodcount].nomen_id = manualchargelist->process_event[
         lchargeeventloop].codes[lchargemodloop].nomenclature_id
         SET addchargemodreq->charge_mod[lchargemodcount].action_type = "ADD"
         SET addchargemodreq->charge_mod_qual = lchargemodcount
       ENDFOR
       SET lchargemodcount += 1
       SET stat = alterlist(addchargemodreq->charge_mod,lchargemodcount)
       SET addchargemodreq->charge_mod[lchargemodcount].charge_item_id = cnvtreal(addcharge_reply->
        mod_objs[1].mod_recs[1].pk_values)
       SET addchargemodreq->charge_mod[lchargemodcount].charge_mod_type_cd = dmodrsn_cs13019
       IF ((request->bill_type_cd=dclient_cs22569))
        SET addchargemodreq->charge_mod[lchargemodcount].field6 =
        "The charge was transferred to client"
       ELSEIF ((request->bill_type_cd=dpatient_cs22569))
        SET addchargemodreq->charge_mod[lchargemodcount].field6 =
        "The charge was transferred to patient"
       ENDIF
       SET addchargemodreq->charge_mod[lchargemodcount].field7 = request->comment_freetext
       SET addchargemodreq->charge_mod[lchargemodcount].field1_id = dtransfer_cs4001989
       SET addchargemodreq->charge_mod[lchargemodcount].field2_id = request->comment_cd
       SET addchargemodreq->charge_mod[lchargemodcount].action_type = "ADD"
       SET addchargemodreq->charge_mod_qual = lchargemodcount
       SET addcredit_request->charge_qual += 1
       SET stat = alterlist(addcredit_request->charge,addcredit_request->charge_qual)
       SET addcredit_request->charge[addcredit_request->charge_qual].charge_item_id =
       manualchargelist->process_event[lchargeeventloop].charges[lchargeloop].charge_item_id
     ENDFOR
   ENDFOR
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",
    addchargemodrep)
   IF ((addchargemodrep->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to add charge mods"
    RETURN(false)
   ENDIF
   EXECUTE afc_add_credit  WITH replace("REQUEST",addcredit_request), replace("REPLY",addcredit_reply
    )
   IF ((addcredit_reply->status_data.status="F"))
    CALL echo(build("Add Credit Reply Status is ",addcredit_reply->status_data.status,
      " Ending Program"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "afc_transfer_charges"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to credit charges"
    RETURN(false)
   ELSE
    FOR (lchargeloop = 1 TO size(addcredit_reply->charge,5))
      SET lnewchargecount += 1
      SET stat = alterlist(new_charge_list->charges,lnewchargecount)
      SET new_charge_list->charges[lnewchargecount].charge_item_id = addcredit_reply->charge[
      lchargeloop].charge_item_id
      SET new_charge_list->charges[lnewchargecount].process_flg = addcredit_reply->charge[lchargeloop
      ].process_flg
    ENDFOR
   ENDIF
   COMMIT
   RETURN(true)
 END ;Subroutine
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
 CALL uar_crmendreq(hstepreprocess)
 CALL uar_crmendtask(htasktransfer)
 CALL uar_crmendapp(happtransfer)
 FREE RECORD manualchargelist
 FREE RECORD reprocess_request
 FREE RECORD addchargemodreq
 FREE RECORD addchargemodrep
 FREE RECORD new_charge_list
 FREE RECORD afcprofit_request
 FREE RECORD afcprofit_reply
END GO
