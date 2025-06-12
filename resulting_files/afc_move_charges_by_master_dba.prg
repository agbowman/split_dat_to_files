CREATE PROGRAM afc_move_charges_by_master:dba
 DECLARE afc_move_charges_by_master_version = vc WITH private, noconstant("CHARGSRV-14536.FT.006")
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
 FREE RECORD celist
 RECORD celist(
   1 charge_events[*]
     2 charge_event_id = f8
     2 charges[*]
       3 charge_item_id = f8
 )
 FREE RECORD dropchargerequest
 RECORD dropchargerequest(
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
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_bill_type_cd = f8
     2 accession = vc
     2 report_priority_cd = f8
     2 collection_priority_cd = f8
     2 reference_nbr = vc
     2 research_acct_id = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 charge_event_id = f8
     2 encntr_type_cd = f8
     2 med_service_cd = f8
     2 encntr_org_id = f8
     2 research_org_id = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 loc_nurse_unit_cd = f8
     2 ord_loc_cd = f8
     2 ord_phys_id = f8
     2 verify_phys_id = f8
     2 perf_phys_id = f8
     2 ref_phys_id = f8
     2 cancelled_ind = i2
     2 no_charge_ind = i2
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_desc = c200
     2 user_id = f8
     2 epsdt_ind = i2
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_act_id = f8
       3 phleb_group_ind = i2
       3 cea_type_cd = f8
       3 service_resource_cd = f8
       3 service_loc_cd = f8
       3 service_dt_tm = dq8
       3 charge_dt_tm = dq8
       3 charge_type_cd = f8
       3 alpha_nomen_id = f8
       3 quantity = i4
       3 rx_quantity = f8
       3 result = vc
       3 units = f8
       3 unit_type_cd = i4
       3 reason_cd = f8
       3 accession_id = f8
       3 cea_prsnl_id = f8
       3 position_cd = f8
       3 repeat_ind = i2
       3 misc_ind = i2
       3 cea_misc1 = c200
       3 cea_misc2 = c200
       3 cea_misc3 = c200
       3 cea_misc1_id = f8
       3 cea_misc2_id = f8
       3 cea_misc3_id = f8
       3 cea_misc4_id = f8
       3 cea_misc5_id = f8
       3 cea_misc6_id = f8
       3 cea_misc7_id = f8
       3 prsnl_qual = i2
       3 prsnl[*]
         4 prsnl_id = f8
         4 prsnl_type_cd = f8
       3 charge_event_id = f8
       3 reference_range_factor_id = f8
       3 patient_loc_cd = f8
       3 in_transit_dt_tm = dq8
       3 in_lab_dt_tm = dq8
       3 cea_prsnl_type_cd = f8
       3 cea_service_resource_cd = f8
       3 ceact_dt_tm = dq8
       3 cea_field1 = vc
       3 cea_field2 = vc
       3 cea_field3 = vc
       3 cea_field4 = vc
       3 cea_field5 = vc
       3 elapsed_time = i4
       3 cea_loc_cd = f8
       3 priority_cd = f8
       3 patient_responsibility_flag = i2
       3 item_deductible_amt = f8
     2 charge_event_mod_qual = i2
     2 mods
       3 charge_mods[*]
         4 mod_id = f8
         4 charge_event_id = f8
         4 charge_event_mod_type_cd = f8
         4 charge_item_id = f8
         4 charge_mod_type_cd = f8
         4 field1 = c200
         4 field2 = c200
         4 field3 = c200
         4 field4 = c200
         4 field5 = c200
         4 field6 = c200
         4 field7 = c200
         4 field8 = c200
         4 field9 = c200
         4 field10 = c200
         4 field1_id = f8
         4 field2_id = f8
         4 field3_id = f8
         4 field4_id = f8
         4 field5_id = f8
         4 nomen_id = f8
         4 cm1_nbr = f8
     2 parent_events[*]
       3 ext_p_ref_id = f8
       3 ext_p_ref_cd = f8
       3 ext_i_ref_id = f8
       3 ext_i_ref_cd = f8
     2 charges[*]
       3 charge_item_id = f8
       3 charge_act_id = f8
       3 charge_event_id = f8
       3 bill_item_id = f8
       3 charge_description = c200
       3 price_sched_id = f8
       3 payor_id = f8
       3 item_quantity = f8
       3 item_price = f8
       3 item_extended_price = f8
       3 charge_type_cd = f8
       3 suspense_rsn_cd = f8
       3 reason_comment = c200
       3 posted_cd = f8
       3 ord_phys_id = f8
       3 perf_phys_id = f8
       3 order_id = f8
       3 beg_effective_dt_tm = dq8
       3 person_id = f8
       3 encntr_id = f8
       3 admit_type_cd = f8
       3 med_service_cd = f8
       3 institution_cd = f8
       3 department_cd = f8
       3 section_cd = f8
       3 subsection_cd = f8
       3 level5_cd = f8
       3 service_dt_tm = dq8
       3 process_flg = i2
       3 parent_charge_item_id = f8
       3 interface_id = f8
       3 tier_group_cd = f8
       3 def_bill_item_id = f8
       3 verify_phys_id = f8
       3 gross_price = f8
       3 discount_amount = f8
       3 activity_type_cd = f8
       3 research_acct_id = f8
       3 cost_center_cd = f8
       3 abn_status_cd = f8
       3 perf_loc_cd = f8
       3 inst_fin_nbr = c50
       3 ord_loc_cd = f8
       3 fin_class_cd = f8
       3 health_plan_id = f8
       3 manual_ind = i2
       3 updt_ind = i2
       3 payor_type_cd = f8
       3 item_copay = f8
       3 item_reimbursement = f8
       3 posted_dt_tm = dq8
       3 item_interval_id = f8
       3 list_price = f8
       3 list_price_sched_id = f8
       3 realtime_ind = i2
       3 epsdt_ind = i2
       3 ref_phys_id = f8
       3 alpha_nomen_id = f8
       3 server_process_flag = i2
       3 mods
         4 charge_mods[*]
           5 mod_id = f8
           5 charge_event_id = f8
           5 charge_event_mod_type_cd = f8
           5 charge_item_id = f8
           5 charge_mod_type_cd = f8
           5 field1 = c200
           5 field2 = c200
           5 field3 = c200
           5 field4 = c200
           5 field5 = c200
           5 field6 = c200
           5 field7 = c200
           5 field8 = c200
           5 field9 = c200
           5 field10 = c200
           5 field1_id = f8
           5 field2_id = f8
           5 field3_id = f8
           5 field4_id = f8
           5 field5_id = f8
           5 nomen_id = f8
           5 cm1_nbr = f8
       3 offset_charge_item_id = f8
       3 patient_responsibility_flag = i2
       3 item_deductible_amt = f8
       3 activity_sub_type_cd = f8
       3 provider_specialty_cd = f8
 )
 FREE RECORD dropchargereply
 RECORD dropchargereply(
   1 charge_qual = i4
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 charge_mod_qual = i4
     2 charge_mods[*]
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
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
     2 activity_sub_type_cd = f8
     2 provider_specialty_cd = f8
     2 item_price_adj_amt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD addcreditrequest
 RECORD addcreditrequest(
   1 charge_qual = i2
   1 charge[*]
     2 charge_item_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = vc
     2 late_charge_processing_ind = i2
 )
 FREE RECORD addcreditreply
 RECORD addcreditreply(
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
     2 activity_sub_type_cd = f8
     2 provider_speciatly_cd = f8
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
 FREE RECORD finalcharges
 RECORD finalcharges(
   1 charges[*]
     2 charge_item_id = f8
     2 interface_file_id = f8
 )
 FREE RECORD afcinterfacecharge_request
 RECORD afcinterfacecharge_request(
   1 interface_charge[*]
     2 charge_item_id = f8
 )
 FREE RECORD afcinterfacecharge_reply
 RECORD afcinterfacecharge_reply(
   1 interface_charge[*]
     2 abn_status_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_type_cd = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 admit_type_cd = f8
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 batch_num = i4
     2 bed_cd = f8
     2 beg_effective_dt_tm = dq8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 building_cd = f8
     2 charge_description = c200
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 code_revenue_cd = f8
     2 code_revenue_more_ind = i2
     2 cost_center_cd = f8
     2 department_cd = f8
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 discount_amount = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 end_effective_dt_tm = dq8
     2 facility_cd = f8
     2 fin_nbr = c50
     2 fin_nbr_type_flg = i4
     2 gross_price = f8
     2 icd9_proc_more_ind = i2
     2 institution_cd = f8
     2 interface_charge_id = f8
     2 interface_file_id = f8
     2 level5_cd = f8
     2 manual_ind = i2
     2 med_nbr = c50
     2 med_service_cd = f8
     2 net_ext_price = f8
     2 nurse_unit_cd = f8
     2 order_dept = i4
     2 order_nbr = c200
     2 ord_doc_nbr = c20
     2 ord_phys_id = f8
     2 organization_id = f8
     2 override_desc = c200
     2 payor_id = f8
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 person_id = f8
     2 person_name = c100
     2 posted_dt_tm = dq8
     2 price = f8
     2 prim_cdm = c50
     2 prim_cdm_desc = c200
     2 prim_cpt = c50
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 quantity = f8
     2 referring_phys_id = f8
     2 room_cd = f8
     2 section_cd = f8
     2 service_dt_tm = dq8
     2 subsection_cd = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 user_def_ind = i2
     2 ndc_ident = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 FREE RECORD uptchargeeventact
 RECORD uptchargeeventact(
   1 charge_event_act[*]
     2 charge_event_act_id = f8
 )
 FREE RECORD copychargerequest
 RECORD copychargerequest(
   1 charge_qual[*]
     2 chargeitemid = f8
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 DECLARE person_match = i2 WITH public, noconstant(0)
 DECLARE mcnt = i4 WITH public, noconstant(0)
 DECLARE ceacnt = i4 WITH public, noconstant(0)
 DECLARE ceapcnt = i4 WITH public, noconstant(0)
 DECLARE cecnt = i4 WITH public, noconstant(0)
 DECLARE cemcnt = i4 WITH public, noconstant(0)
 DECLARE chrgcnt = i4 WITH public, noconstant(0)
 DECLARE creditcnt = i4 WITH public, noconstant(0)
 DECLARE cntfinal = i4 WITH public, noconstant(0)
 DECLARE fromencntr = f8 WITH public, noconstant(0.0)
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE bcopycharge = i2 WITH protect, noconstant(bmanprefcheck(0))
 DECLARE chrgcnt = i4 WITH protect, noconstant(0)
 DECLARE chargeidx = i4 WITH protect, noconstant(0)
 DECLARE new_charge_item_id = f8 WITH protect, noconstant(0.0)
 DECLARE cs106_pharmacy = f8 WITH protect, constant(getcodevalue(106,"PHARMACY",0))
 DECLARE cs13028_debit = f8 WITH protect, constant(getcodevalue(13028,"DR",0))
 SET stat = alterlist(finalcharges->charges,10)
 CALL impersonatepersonnelinfo(1)
 SELECT INTO "nl:"
  FROM charge_event ce,
   charge c,
   (dummyt d  WITH seq = value(size(request->charge_event,5)))
  PLAN (d)
   JOIN (ce
   WHERE (ce.charge_event_id=request->charge_event[d.seq].charge_event_id))
   JOIN (c
   WHERE c.charge_event_id=ce.charge_event_id
    AND ((c.offset_charge_item_id+ 0)=0.0)
    AND ((c.charge_type_cd+ 0)=cs13028_debit)
    AND ((c.encntr_id+ 0) != request->to_encntr_id))
  ORDER BY ce.charge_event_id
  HEAD ce.charge_event_id
   IF (((c.manual_ind=true
    AND bcopycharge) OR (c.activity_type_cd=cs106_pharmacy)) )
    chrgcnt += 1, stat = alterlist(copychargerequest->charge_qual,chrgcnt), copychargerequest->
    charge_qual[chrgcnt].chargeitemid = c.charge_item_id
   ELSE
    mcnt += 1, ceacnt = 0, ceapcnt = 0,
    stat = alterlist(dropchargerequest->charge_event,mcnt), dropchargerequest->charge_event[mcnt].
    charge_event_id = ce.charge_event_id, dropchargerequest->charge_event[mcnt].ext_master_event_id
     = ce.ext_m_event_id,
    dropchargerequest->charge_event[mcnt].ext_master_event_cont_cd = ce.ext_m_event_cont_cd,
    dropchargerequest->charge_event[mcnt].ext_master_reference_id = ce.ext_m_reference_id,
    dropchargerequest->charge_event[mcnt].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd
   ENDIF
   fromencntr = ce.encntr_id
  FOOT REPORT
   dropchargerequest->charge_event_qual = mcnt, dropchargerequest->action_type = "SKP"
  WITH nocounter
 ;end select
 IF (size(dropchargerequest->charge_event,5) < 1
  AND size(copychargerequest->charge_qual,5) < 1)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "afc_move_charges_by_master"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid charge events qualified."
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   encounter e2
  PLAN (e
   WHERE e.encntr_id=fromencntr)
   JOIN (e2
   WHERE ((e2.person_id+ 0)=e.person_id)
    AND (e2.encntr_id=request->to_encntr_id))
  DETAIL
   person_match = 1
  WITH nocounter
 ;end select
 IF (person_match=0)
  SET reply->status_data.subeventstatus[1].operationname = "afc_move_charges_by_master"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Person_id doesn't match between both encounters."
  GO TO end_program
 ENDIF
 IF (size(dropchargerequest->charge_event,5) > 0)
  SELECT DISTINCT INTO "nl:"
   FROM charge_event ce,
    charge c,
    (dummyt d  WITH seq = value(mcnt))
   PLAN (d)
    JOIN (ce
    WHERE (ce.ext_m_event_id=dropchargerequest->charge_event[d.seq].ext_master_event_id)
     AND (ce.ext_m_event_cont_cd=dropchargerequest->charge_event[d.seq].ext_master_event_cont_cd)
     AND ((ce.charge_event_id+ 0) != 0))
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id
     AND ((c.charge_item_id+ 0) != 0)
     AND ((c.offset_charge_item_id+ 0)=0.0)
     AND ((c.charge_type_cd+ 0)=cs13028_debit))
   ORDER BY ce.charge_event_id, c.charge_item_id
   HEAD REPORT
    creditcnt = 0
   HEAD ce.charge_event_id
    chrgcnt = 0, cecnt += 1, stat = alterlist(celist->charge_events,cecnt),
    celist->charge_events[cecnt].charge_event_id = ce.charge_event_id
   DETAIL
    chrgcnt += 1, creditcnt += 1, stat = alterlist(celist->charge_events[cecnt].charges,chrgcnt),
    stat = alterlist(addcreditrequest->charge,creditcnt), celist->charge_events[cecnt].charges[
    chrgcnt].charge_item_id = c.charge_item_id, addcreditrequest->charge[creditcnt].charge_item_id =
    c.charge_item_id
   WITH nocounter
  ;end select
  SET addcreditrequest->charge_qual = creditcnt
  SELECT INTO "nl:"
   FROM charge_event ce,
    charge_event_act cea,
    charge_event_act_prsnl ceap,
    (dummyt d  WITH seq = value(size(celist->charge_events,5)))
   PLAN (d)
    JOIN (ce
    WHERE (ce.charge_event_id=celist->charge_events[d.seq].charge_event_id))
    JOIN (cea
    WHERE cea.charge_event_id=ce.charge_event_id
     AND cea.active_ind=true)
    JOIN (ceap
    WHERE (ceap.charge_event_act_id= Outerjoin(cea.charge_event_act_id)) )
   ORDER BY ce.charge_event_id, cea.charge_event_act_id
   HEAD REPORT
    mcnt = 0, stat = alterlist(dropchargerequest->charge_event,mcnt)
   HEAD ce.charge_event_id
    mcnt += 1, ceacnt = 0, ceapcnt = 0,
    stat = alterlist(dropchargerequest->charge_event,mcnt), dropchargerequest->charge_event[mcnt].
    charge_event_id = ce.charge_event_id, dropchargerequest->charge_event[mcnt].ext_master_event_id
     = ce.ext_m_event_id,
    dropchargerequest->charge_event[mcnt].ext_master_event_cont_cd = ce.ext_m_event_cont_cd,
    dropchargerequest->charge_event[mcnt].ext_master_reference_id = ce.ext_m_reference_id,
    dropchargerequest->charge_event[mcnt].ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd,
    dropchargerequest->charge_event[mcnt].ext_parent_event_id = ce.ext_p_event_id, dropchargerequest
    ->charge_event[mcnt].ext_parent_event_cont_cd = ce.ext_p_event_cont_cd, dropchargerequest->
    charge_event[mcnt].ext_parent_reference_id = ce.ext_p_reference_id,
    dropchargerequest->charge_event[mcnt].ext_parent_reference_cont_cd = ce.ext_p_reference_cont_cd,
    dropchargerequest->charge_event[mcnt].ext_item_event_id = ce.ext_i_event_id, dropchargerequest->
    charge_event[mcnt].ext_item_event_cont_cd = ce.ext_i_event_cont_cd,
    dropchargerequest->charge_event[mcnt].ext_item_reference_id = ce.ext_i_reference_id,
    dropchargerequest->charge_event[mcnt].ext_item_reference_cont_cd = ce.ext_i_reference_cont_cd,
    dropchargerequest->charge_event[mcnt].order_id = ce.order_id,
    dropchargerequest->charge_event[mcnt].person_id = ce.person_id, dropchargerequest->charge_event[
    mcnt].encntr_id = request->to_encntr_id, dropchargerequest->charge_event[mcnt].accession = ce
    .accession,
    dropchargerequest->charge_event[mcnt].report_priority_cd = ce.report_priority_cd,
    dropchargerequest->charge_event[mcnt].collection_priority_cd = ce.collection_priority_cd,
    dropchargerequest->charge_event[mcnt].reference_nbr = ce.reference_nbr,
    dropchargerequest->charge_event[mcnt].research_acct_id = ce.research_account_id,
    dropchargerequest->charge_event[mcnt].abn_status_cd = ce.abn_status_cd, dropchargerequest->
    charge_event[mcnt].perf_loc_cd = ce.perf_loc_cd,
    dropchargerequest->charge_event[mcnt].cancelled_ind = ce.cancelled_ind, dropchargerequest->
    charge_event[mcnt].epsdt_ind = ce.epsdt_ind, fromencntr = ce.encntr_id
   HEAD cea.charge_event_act_id
    idx += 1, ceacnt += 1, ceapcnt = 0,
    stat = alterlist(dropchargerequest->charge_event[mcnt].charge_event_act,ceacnt), stat = alterlist
    (uptchargeeventact->charge_event_act,idx), uptchargeeventact->charge_event_act[idx].
    charge_event_act_id = cea.charge_event_act_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_type_cd = cea.cea_type_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_prsnl_id = cea.cea_prsnl_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_dt_tm = cea.service_dt_tm,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_loc_cd = cea
    .service_loc_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_dt_tm =
    cea.charge_dt_tm, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].charge_type_cd
     = cea.charge_type_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].alpha_nomen_id = cea
    .alpha_nomen_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].quantity = cea
    .quantity, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].result = cea.result,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].units = cea.units,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].unit_type_cd = cea.unit_type_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].reason_cd = cea.reason_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].accession_id = cea.accession_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].repeat_ind = cea.repeat_ind,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].misc_ind = cea.misc_ind,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc1 = cea.cea_misc1,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc2 = cea.cea_misc2,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc3 = cea.cea_misc3,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc1_id = cea.cea_misc1_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc2_id = cea.cea_misc2_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc3_id = cea.cea_misc3_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc4_id = cea.cea_misc4_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc5_id = cea.cea_misc5_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc6_id = cea.cea_misc6_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].cea_misc7_id = cea.cea_misc7_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].patient_loc_cd = cea
    .patient_loc_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].in_lab_dt_tm =
    cea.in_lab_dt_tm,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].priority_cd = cea.priority_cd,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].service_resource_cd = cea
    .service_resource_cd, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
    patient_responsibility_flag = cea.patient_responsibility_flag,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].reference_range_factor_id = cea
    .reference_range_factor_id, dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
    item_deductible_amt = cea.item_deductible_amt
   DETAIL
    ceapcnt += 1, stat = alterlist(dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].
     prsnl,ceapcnt), dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl[ceapcnt].
    prsnl_id = ceap.prsnl_id,
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl[ceapcnt].prsnl_type_cd =
    ceap.prsnl_type_cd
   FOOT  cea.charge_event_act_id
    dropchargerequest->charge_event[mcnt].charge_event_act[ceacnt].prsnl_qual = ceapcnt
   FOOT  ce.charge_event_id
    dropchargerequest->charge_event[mcnt].charge_event_act_qual = ceacnt
   FOOT REPORT
    dropchargerequest->charge_event_qual = mcnt, dropchargerequest->action_type = "SKP"
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_mod cem,
    (dummyt d  WITH seq = value(mcnt))
   PLAN (d)
    JOIN (cem
    WHERE (cem.charge_event_id=dropchargerequest->charge_event[d.seq].charge_event_id))
   DETAIL
    cemcnt += 1, stat = alterlist(dropchargerequest->charge_event[d.seq].mods.charge_mods,cemcnt),
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].charge_event_id = cem
    .charge_event_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].charge_event_mod_type_cd = cem
    .charge_event_mod_type_cd, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field1
     = cem.field1, dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field2 = cem
    .field2,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field3 = cem.field3,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field4 = cem.field4,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field5 = cem.field5,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field6 = cem.field6,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field7 = cem.field7,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field8 = cem.field8,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field9 = cem.field9,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field10 = cem.field10,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field1_id = cem.field1_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field2_id = cem.field2_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field3_id = cem.field3_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field4_id = cem.field4_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].field5_id = cem.field5_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].nomen_id = cem.nomen_id,
    dropchargerequest->charge_event[d.seq].mods.charge_mods[cemcnt].cm1_nbr = cem.cm1_nbr
   WITH nocounter
  ;end select
 ENDIF
 IF (size(copychargerequest->charge_qual,5) > 0)
  SET creditcnt = size(addcreditrequest->charge,5)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(copychargerequest->charge_qual,5))),
    charge c
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=copychargerequest->charge_qual[d1.seq].chargeitemid))
   DETAIL
    creditcnt += 1, stat = alterlist(addcreditrequest->charge,creditcnt), addcreditrequest->charge[
    creditcnt].charge_item_id = c.charge_item_id
   FOOT REPORT
    addcreditrequest->charge_qual = creditcnt
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(dropchargerequest)
  CALL echorecord(celist)
  CALL echorecord(copychargerequest)
  CALL echorecord(addcreditrequest)
 ENDIF
 EXECUTE afc_add_credit  WITH replace("REQUEST",addcreditrequest), replace("REPLY",addcreditreply)
 IF ((addcreditreply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "afc_move_charges_by_master"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error crediting previous charge(s)."
  GO TO end_program
 ENDIF
 IF (size(addcreditreply->charge,5) >= 1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(addcreditreply->charge,5)))
   PLAN (d)
   DETAIL
    cntfinal += 1
    IF (mod(cntfinal,10)=1
     AND cntfinal != 1)
     stat = alterlist(finalcharges->charges,(cntfinal+ 10))
    ENDIF
    finalcharges->charges[cntfinal].charge_item_id = addcreditreply->charge[d.seq].charge_item_id,
    finalcharges->charges[cntfinal].interface_file_id = addcreditreply->charge[d.seq].
    interface_file_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(dropchargerequest->charge_event,5) > 0)
  EXECUTE afc_drop_charge_sync  WITH replace("REQUEST",dropchargerequest), replace("REPLY",
   dropchargereply)
  IF (validate(debug,- (1)) > 0)
   CALL echorecord(dropchargereply)
  ENDIF
  IF ((dropchargereply->status_data.status="F"))
   SET reply->status_data.subeventstatus[1].operationname = "afc_move_charges_by_master"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error creating non-pharmacy charges on new encounter."
   GO TO end_program
  ENDIF
  IF (size(dropchargereply->charges,5) >= 1)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(dropchargereply->charges,5)))
    PLAN (d)
    DETAIL
     cntfinal += 1
     IF (mod(cntfinal,10)=1
      AND cntfinal != 1)
      stat = alterlist(finalcharges->charges,(cntfinal+ 10))
     ENDIF
     finalcharges->charges[cntfinal].charge_item_id = dropchargereply->charges[d.seq].charge_item_id
    WITH nocounter
   ;end select
   UPDATE  FROM charge_event_act cea,
     (dummyt d  WITH seq = value(size(uptchargeeventact->charge_event_act,5)))
    SET cea.active_ind = false
    PLAN (d
     WHERE (uptchargeeventact->charge_event_act[d.seq].charge_event_act_id > 0))
     JOIN (cea
     WHERE (cea.charge_event_act_id=uptchargeeventact->charge_event_act[d.seq].charge_event_act_id))
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 FOR (chargeidx = 1 TO size(copychargerequest->charge_qual,5))
  SET new_charge_item_id = 0.0
  IF ( NOT (createdebitcharge(copychargerequest->charge_qual[chargeidx].chargeitemid,
   new_charge_item_id)))
   SET reply->status_data.subeventstatus[1].operationname = "afc_move_charges_by_master"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error creating pharmacy/manual charges on new encounter."
   GO TO end_program
  ELSE
   SET cntfinal = size(finalcharges->charges,5)
   SET cntfinal += 1
   SET stat = alterlist(finalcharges->charges,cntfinal)
   SET finalcharges->charges[cntfinal].charge_item_id = new_charge_item_id
  ENDIF
 ENDFOR
 SET stat = alterlist(finalcharges->charges,cntfinal)
 IF (size(finalcharges->charges,5) >= 1)
  SELECT INTO "nl:"
   FROM charge c,
    (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=finalcharges->charges[d.seq].charge_item_id))
   DETAIL
    finalcharges->charges[d.seq].interface_file_id = c.interface_file_id
   WITH nocounter
  ;end select
  SET cntfinal = 0
  SET cntfinal2 = 0
  SET stat = alterlist(afcinterfacecharge_request->interface_charge,10)
  SET stat = alterlist(afcprofit_request->charges,10)
  SELECT INTO "nl:"
   FROM interface_file i,
    (dummyt d  WITH seq = value(size(finalcharges->charges,5)))
   PLAN (d)
    JOIN (i
    WHERE (i.interface_file_id=finalcharges->charges[d.seq].interface_file_id))
   DETAIL
    IF (i.realtime_ind=1)
     cntfinal += 1
     IF (mod(cntfinal,10)=1
      AND cntfinal != 1)
      stat = alterlist(afcinterfacecharge_request->interface_charge,(cntfinal+ 10))
     ENDIF
     afcinterfacecharge_request->interface_charge[cntfinal].charge_item_id = finalcharges->charges[d
     .seq].charge_item_id
    ELSEIF (i.profit_type_cd > 0)
     cntfinal2 += 1
     IF (mod(cntfinal2,10)=1
      AND cntfinal2 != 1)
      stat = alterlist(afcprofit_request->charges,(cntfinal2+ 10))
     ENDIF
     afcprofit_request->charges[cntfinal2].charge_item_id = finalcharges->charges[d.seq].
     charge_item_id
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(afcinterfacecharge_request->interface_charge,cntfinal)
  SET stat = alterlist(afcprofit_request->charges,cntfinal2)
  IF (size(afcprofit_request->charges,5) > 0)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(afcprofit_request)
   ENDIF
   EXECUTE pft_nt_chrg_billing  WITH replace("REQUEST",afcprofit_request), replace("REPLY",
    afcprofit_reply)
  ENDIF
  IF (size(afcinterfacecharge_request->interface_charge,5) > 0)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(afcinterfacecharge_request)
   ENDIF
   EXECUTE afc_post_interface_charge  WITH replace("REQUEST",afcinterfacecharge_request), replace(
    "REPLY",afcinterfacecharge_reply)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(afcinterfacecharge_reply)
   ENDIF
   IF ((afcinterfacecharge_reply->status_data.status="F"))
    CALL echo("afc_srv_interface_charge failed")
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SUBROUTINE (createdebitcharge(oldchargeitemid=f8,newchargeitemid=f8(ref)) =i2)
   DECLARE chargemodcount = i4 WITH protect, noconstant(0)
   FREE RECORD createdebitchargereq
   RECORD createdebitchargereq(
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
   FREE RECORD createdebitchargerep
   RECORD createdebitchargerep(
     1 charges[*]
       2 charge_item_id = f8
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
   FREE RECORD addchargemodreq
   RECORD addchargemodreq(
     1 charge_mod_qual = i2
     1 charge_mod[*]
       2 action_type = c3
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
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 field1_id = f8
       2 field2_id = f8
       2 field3_id = f8
       2 field4_id = f8
       2 field5_id = f8
       2 nomen_id = f8
       2 cm1_nbr = f8
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
   SET stat = alterlist(createdebitchargereq->objarray,1)
   SET curalias c createdebitchargereq->objarray[1]
   SELECT INTO "nl:"
    FROM charge c
    PLAN (c
     WHERE c.charge_item_id=oldchargeitemid)
    DETAIL
     c->parent_charge_item_id = c.charge_item_id, c->charge_event_act_id = c.charge_event_act_id, c->
     charge_event_id = c.charge_event_id,
     c->bill_item_id = c.bill_item_id, c->order_id = c.order_id, c->encntr_id = request->to_encntr_id,
     c->person_id = c.person_id, c->payor_id = c.payor_id, c->ord_loc_cd = c.ord_loc_cd,
     c->perf_loc_cd = c.perf_loc_cd, c->ord_phys_id = c.ord_phys_id, c->perf_phys_id = c.perf_phys_id,
     c->charge_description = c.charge_description, c->price_sched_id = c.price_sched_id, c->
     item_quantity = c.item_quantity,
     c->item_price = c.item_price, c->item_extended_price = c.item_extended_price, c->item_allowable
      = c.item_allowable,
     c->item_copay = c.item_copay, c->charge_type_cd = c.charge_type_cd, c->research_acct_id = c
     .research_acct_id,
     c->suspense_rsn_cd = c.suspense_rsn_cd, c->reason_comment = c.reason_comment, c->posted_cd = c
     .posted_cd,
     c->service_dt_tm = cnvtdatetime(c.service_dt_tm), c->activity_dt_tm = cnvtdatetime(c
      .activity_dt_tm), c->interface_file_id = c.interface_file_id,
     c->tier_group_cd = c.tier_group_cd, c->def_bill_item_id = c.def_bill_item_id, c->verify_phys_id
      = c.verify_phys_id,
     c->gross_price = c.gross_price, c->discount_amount = c.discount_amount, c->manual_ind = c
     .manual_ind,
     c->combine_ind = c.combine_ind, c->activity_type_cd = c.activity_type_cd, c->
     activity_sub_type_cd = c.activity_sub_type_cd,
     c->provider_specialty_cd = c.provider_specialty_cd, c->admit_type_cd = c.admit_type_cd, c->
     bundle_id = c.bundle_id,
     c->department_cd = c.department_cd, c->institution_cd = c.institution_cd, c->level5_cd = c
     .level5_cd,
     c->med_service_cd = c.med_service_cd, c->section_cd = c.section_cd, c->subsection_cd = c
     .subsection_cd,
     c->abn_status_cd = c.abn_status_cd, c->cost_center_cd = c.cost_center_cd, c->inst_fin_nbr = c
     .inst_fin_nbr,
     c->fin_class_cd = c.fin_class_cd, c->health_plan_id = c.health_plan_id, c->item_interval_id = c
     .item_interval_id,
     c->item_list_price = c.item_list_price, c->item_reimbursement = c.item_reimbursement, c->
     list_price_sched_id = c.list_price_sched_id,
     c->payor_type_cd = c.payor_type_cd, c->epsdt_ind = c.epsdt_ind, c->ref_phys_id = c.ref_phys_id,
     c->start_dt_tm = cnvtdatetime(c.start_dt_tm), c->stop_dt_tm = cnvtdatetime(c.stop_dt_tm), c->
     alpha_nomen_id = c.alpha_nomen_id,
     c->server_process_flag = c.server_process_flag, c->item_deductible_amt = c.item_deductible_amt,
     c->patient_responsibility_flag = c.patient_responsibility_flag,
     c->item_price_adj_amt = c.item_price_adj_amt
    WITH nocounter
   ;end select
   EXECUTE afc_add_charge  WITH replace("REQUEST",createdebitchargereq), replace("REPLY",
    createdebitchargerep)
   IF ((createdebitchargerep->status_data.status="F"))
    RETURN(false)
   ENDIF
   SET newchargeitemid = createdebitchargerep->charges[1].charge_item_id
   SET chargemodcount = 0
   SET curalias cm addchargemodreq->charge_mod[chargemodcount]
   SELECT INTO "nl:"
    FROM charge_mod cm
    PLAN (cm
     WHERE cm.charge_item_id=oldchargeitemid)
    ORDER BY cm.charge_item_id
    DETAIL
     chargemodcount += 1, stat = alterlist(addchargemodreq->charge_mod,chargemodcount), cm->
     action_type = "ADD",
     cm->charge_item_id = newchargeitemid, cm->charge_mod_type_cd = cm.charge_mod_type_cd, cm->field1
      = cm.field1,
     cm->field2 = cm.field2, cm->field3 = cm.field3, cm->field4 = cm.field4,
     cm->field5 = cm.field5, cm->field6 = cm.field6, cm->field7 = cm.field7,
     cm->field8 = cm.field8, cm->field9 = cm.field9, cm->field10 = cm.field10,
     cm->field1_id = cm.field1_id, cm->field2_id = cm.field2_id, cm->field3_id = cm.field3_id,
     cm->field4_id = cm.field4_id, cm->field5_id = cm.field5_id, cm->nomen_id = cm.nomen_id,
     cm->cm1_nbr = cm.cm1_nbr, cm->activity_dt_tm = cm.activity_dt_tm, cm->active_ind = cm.active_ind
    WITH nocounter
   ;end select
   SET addchargemodreq->charge_mod_qual = chargemodcount
   SET addchargemodreq->skip_charge_event_mod_ind = true
   EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",
    addchargemodrep)
   IF (validate(debug,0)=1)
    CALL echorecord(addchargemodreq)
    CALL echorecord(addchargemodrep)
   ENDIF
   IF ((addchargemodrep->status_data.status="F"))
    RETURN(false)
   ENDIF
   FREE RECORD addchargemodreq
   FREE RECORD addchargemodrep
   RETURN(true)
 END ;Subroutine
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD dropchargerequest
 FREE RECORD dropchargereply
 FREE RECORD uptchargeeventact
 FREE RECORD copychargerequest
END GO
