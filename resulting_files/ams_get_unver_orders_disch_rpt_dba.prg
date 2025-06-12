CREATE PROGRAM ams_get_unver_orders_disch_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter username your user name: " = "",
  "Enter a Facility (blank for all): " = "",
  "Enter from discharge date MMDDYYYY: " = "",
  "Enter to discharge date MMDDYYYY: " = ""
  WITH outdev, username, facility,
  from_date, to_date
 CALL echo("-")
 CALL echo("<----- BEGIN rxa_ams_get_unver_orders_disch_rptarged ----->")
 CALL echo("-")
 CALL echo("====================")
 CALL echo(build("ams_get_unver_orders_disch_rpt - Begin Dt/Tm :",format(cnvtdatetime(curdate,
     curtime3),";;Q")))
 CALL echo("====================")
 CALL echo(build("username = ", $USERNAME))
 CALL echo(build("Facility = ", $FACILITY))
 CALL echo(build("From date = ", $FROM_DATE))
 CALL echo(build("To Date = ", $TO_DATE))
 DECLARE qtimerbegindttm1 = dq8 WITH protect, noconstant(0.0)
 SET qtimerbegindttm1 = cnvtdatetime(curdate,curtime3)
 EXECUTE rx_get_alert_hx_summ_request
 EXECUTE rx_get_alert_hx_summ_reply
 FREE RECORD request
 FREE RECORD request_uvom
 RECORD request_uvom(
   1 comm_type_list[*]
     2 communication_type_cd = f8
   1 rx_order_priority_list[*]
     2 rx_order_priority_cd = f8
   1 role_list[*]
     2 position_cd = f8
   1 nurse_unit_list[*]
     2 nurse_unit_cd = f8
     2 nurse_unit_type = vc
   1 med_service_cd_list[*]
     2 med_service_cd = f8
   1 need_rx_prod_assign_flag = i2
   1 need_rx_clin_review_flag = i2
   1 future_order_ind = i2
 )
 FREE RECORD reply_uvom
 RECORD reply_uvom(
   1 get_encntr_time_in_sec = f8
   1 ord_disp_sel_time_in_sec = f8
   1 retr_encntr_info_time_in_sec = f8
   1 get_alert_time_in_sec = f8
   1 entire_script_time_in_sec = f8
   1 order_list[*]
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 action_type_cd = f8
     2 communication_type_cd = f8
     2 route_cd = f8
     2 rx_order_priority_cd = f8
     2 order_provider_id = f8
     2 last_updt_user_id = f8
     2 last_user_position_cd = f8
     2 facility_cd = f8
     2 building_cd = f8
     2 nurse_unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 med_service_cd = f8
     2 need_rx_verify_ind = i2
     2 last_verified_action_seq = i4
     2 current_start_tz = i4
     2 current_start_dt_tm = dq8
     2 action_type_display = c40
     2 communication_type_display = c40
     2 route_display = c40
     2 rx_order_priority_display = c40
     2 order_provider_name = vc
     2 patient_name_full_formatted = vc
     2 facility_disp = c40
     2 building_disp = c40
     2 nurse_unit_disp = c40
     2 room_disp = c40
     2 bed_disp = c40
     2 med_service_disp = c40
     2 fin_nbr = vc
     2 mrn_nbr = vc
     2 dept_misc_line = vc
     2 last_updt_user_name = vc
     2 last_user_role_description = c40
     2 drug_allergy_alert_ind = i2
     2 drug_drug_alert_ind = i2
     2 drug_drug_max_severity = f8
     2 drug_food_alert_ind = i2
     2 drug_food_max_severity = f8
     2 drug_dup_alert_ind = i2
     2 discern_alert_ind = i2
     2 power_plan_order_ind = i2
     2 power_plan_desc = vc
     2 pathway_id = f8
     2 link_nbr = f8
     2 link_type_flag = i2
     2 updt_dt_tm = dq8
     2 order_comment_ind = i2
     2 rx_comment_ind = i2
     2 order_conversation_id = f8
     2 order_convs_seq = i4
     2 order_status_cd = f8
     2 need_rx_prod_assign_flag = i2
     2 need_rx_clin_review_flag = i2
     2 patient_med_ind = i2
     2 start_dispense_dt_tm = dq8
     2 thera_sub_flag = i4
     2 iv_compat_alert_ind = i2
     2 iv_compat_alert_type = f8
     2 order_schedule_precision_bit = i4
     2 future_location_facility_cd = f8
     2 future_location_nurse_unit_cd = f8
     2 protocol_order_id = f8
     2 template_order_flag = i2
     2 formulary_status_cd = f8
     2 dosing_method_flag = i2
     2 warning_level_bit = i4
     2 plan_warning_level_bit = i4
     2 protocol_person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encounters(
   1 encntr_list[*]
     2 encntr_id = f8
 ) WITH protect
 RECORD protocols(
   1 list[*]
     2 order_id = f8
 ) WITH protect
 RECORD facilities(
   1 facilities_list[*]
     2 facility_cd = f8
 )
 IF ( NOT (validate(errors_unv,0)))
  RECORD errors_unv(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE norders_nrvi_no_verify_needed = i2 WITH protect, constant(0)
 DECLARE norders_nrvi_needs_verify = i2 WITH protect, constant(1)
 DECLARE norders_nrvi_rejected = i2 WITH protect, constant(2)
 DECLARE nnormal_order = i2 WITH protect, constant(0)
 DECLARE npharm_charge_order = i2 WITH protect, constant(4)
 DECLARE ncare_set_parent = i2 WITH protect, constant(1)
 DECLARE ctheraaccept = i4 WITH protect, constant(1)
 DECLARE ctherareject = i4 WITH protect, constant(2)
 DECLARE ctheraaltreg = i4 WITH protect, constant(3)
 DECLARE cprotocol_order_flag = i2 WITH protect, constant(7)
 DECLARE lplan_person_mismatch_bit = i4 WITH protect, constant(1)
 DECLARE lnurseunitcnt = i4 WITH protect, noconstant(0)
 DECLARE lenccnt = i4 WITH protect, noconstant(0)
 DECLARE lencntrcnt = i4 WITH protect, noconstant(0)
 DECLARE lordercnt = i4 WITH protect, noconstant(0)
 DECLARE cfin = f8 WITH protect, noconstant(0.0)
 DECLARE cmrn = f8 WITH protect, noconstant(0.0)
 DECLARE ccensus = f8 WITH protect, noconstant(0.0)
 DECLARE cdiscontinued = f8 WITH protect, noconstant(0.0)
 DECLARE cpending = f8 WITH protect, noconstant(0.0)
 DECLARE ccompleted = f8 WITH protect, noconstant(0.0)
 DECLARE ctranscancel = f8 WITH protect, noconstant(0.0)
 DECLARE ccanceled = f8 WITH protect, noconstant(0.0)
 DECLARE cfuture = f8 WITH protect, noconstant(0.0)
 DECLARE cvoidwithresult = f8 WITH protect, noconstant(0.0)
 DECLARE cvoid = f8 WITH protect, noconstant(0.0)
 DECLARE cinpatient = f8 WITH protect, noconstant(0.0)
 DECLARE cactive = f8 WITH protect, noconstant(0.0)
 DECLARE cdischarged = f8 WITH protect, noconstant(0.0)
 DECLARE corder_comment = f8 WITH protect, noconstant(0.0)
 DECLARE cpharm_comment = f8 WITH protect, noconstant(0.0)
 DECLARE msinputusername = vc WITH protect, noconstant("")
 DECLARE msinputusernamefullformat = vc WITH protect, noconstant("")
 DECLARE mdfromdttm = f8 WITH protect, noconstant(0.0)
 DECLARE mdtodttm = f8 WITH protect, noconstant(0.0)
 DECLARE mduserprsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE msinputfacname = vc WITH protect, noconstant("")
 DECLARE mdfaccd = f8 WITH protect, noconstant(0.0)
 DECLARE nuserinputreturn = i2 WITH protect, noconstant(0)
 DECLARE nfacforprsnlreturn = i2 WITH protect, noconstant(0)
 DECLARE nfilloutrequestreturn = i2 WITH protect, noconstant(0)
 DECLARE nallfacilities = i2 WITH protect, noconstant(0)
 DECLARE qtimerbegindttm = dq8 WITH protect, noconstant(0.0)
 DECLARE dgetencntrdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE dorddispseldiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE dretrencntrinfodiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE dgetalertdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE x1 = i4 WITH protect, noconstant(0)
 DECLARE x2 = i4 WITH protect, noconstant(0)
 DECLARE x3 = i4 WITH protect, noconstant(0)
 DECLARE x4 = i4 WITH protect, noconstant(0)
 DECLARE x5 = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE nsize = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE protocolidx = i4 WITH protect, noconstant(0)
 DECLARE protlistidx = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE auditcnt = i4 WITH protect, noconstant(0)
 DECLARE auditsize = i2 WITH protect, noconstant(0)
 DECLARE auditmode = i2 WITH protect, noconstant(0)
 DECLARE ntotalordcount = i4 WITH protect, noconstant(0)
 DECLARE ltherasubsort = i4 WITH protect, noconstant(0)
 DECLARE npagenumber = i2 WITH protect, noconstant(0)
 DECLARE stmppatname = vc WITH protect, noconstant("")
 DECLARE stmpordersent = vc WITH protect, noconstant("")
 DECLARE stmporderstartdate = vc WITH protect, noconstant("")
 DECLARE stmppatfin = vc WITH protect, noconstant("")
 DECLARE stmppatmrn = vc WITH protect, noconstant("")
 DECLARE stmpnurseunit = vc WITH protect, noconstant("")
 DECLARE nnum_of_hours = i2 WITH protect, constant(3)
 DECLARE nhour_part = i2 WITH protect, constant(4)
 DECLARE nmax_rows_per_page = i2 WITH protect, constant(59)
 DECLARE nmax_filter_display = i2 WITH protect, constant(45)
 DECLARE ncol_padding = i2 WITH protect, constant(20)
 DECLARE ncol1 = i2 WITH protect, constant(2)
 DECLARE ncol2 = i2 WITH protect, constant(24)
 DECLARE ncol3 = i2 WITH protect, constant(56)
 DECLARE ncol4 = i2 WITH protect, constant(74)
 DECLARE ncol5 = i2 WITH protect, constant(89)
 DECLARE ncol6 = i2 WITH protect, constant(104)
 DECLARE ncol1_width = i2 WITH protect, constant(20)
 DECLARE ncol2_width = i2 WITH protect, constant(30)
 DECLARE ncol3_width = i2 WITH protect, constant(16)
 DECLARE ncol4_width = i2 WITH protect, constant(13)
 DECLARE ncol5_width = i2 WITH protect, constant(13)
 DECLARE ncol6_width = i2 WITH protect, constant(20)
 DECLARE nfilter_col1 = i2 WITH protect, constant(5)
 DECLARE nfilter_col2 = i2 WITH protect, constant(31)
 DECLARE nfilter_col3 = i2 WITH protect, constant(62)
 DECLARE nfilter_col4 = i2 WITH protect, constant(93)
 DECLARE nfilter_col_width = i2 WITH protect, constant(30)
 DECLARE sscript_name = c24 WITH protect, constant("ams_get_unver_orders_disch_rpt")
 DECLARE stitle = vc WITH protect, constant("UVOM Discharged Orders Report")
 DECLARE npage_width = i2 WITH protect, constant(128)
 DECLARE ncol_page_num = i2 WITH protect, constant(114)
 DECLARE spage = vc WITH protect, constant("Page")
 DECLARE sdate_range = vc WITH protect, constant("Report Date Range:")
 DECLARE srun_dt_tm = vc WITH protect, constant(format(cnvtdatetime(curdate,curtime3),
   "MM/DD/YYYY HH:MM;;D"))
 DECLARE srun_date = vc WITH protect, constant("Run Date:")
 DECLARE sran_by = vc WITH protect, constant("Ran By:")
 DECLARE sfac = vc WITH protect, constant("Facility:")
 DECLARE send_of_report = vc WITH protect, constant("End of Report")
 DECLARE sname = vc WITH protecct, constant("Patient Name")
 DECLARE sorder_sent = vc WITH protecct, constant("Order Sentence")
 DECLARE sstart_date = vc WITH protecct, constant("Start Date")
 DECLARE sfin = vc WITH protecct, constant("FIN")
 DECLARE smrn = vc WITH protecct, constant("MRN")
 DECLARE snurse = vc WITH protecct, constant("Nurse Unit")
 DECLARE nsuccess_uvom = i2 WITH protect, constant(0)
 DECLARE nfailed_ccl_error_uvom = i2 WITH protect, constant(1)
 DECLARE nzero_nurse_units = i2 WITH protect, constant(2)
 DECLARE nzero_encounters = i2 WITH protect, constant(3)
 DECLARE nzero_orders = i2 WITH protect, constant(4)
 DECLARE ninvalid_username_input = i2 WITH protect, constant(5)
 DECLARE ninvlaid_username = i2 WITH protect, constant(6)
 DECLARE ninvalid_date_input = i2 WITH protect, constant(7)
 DECLARE ninvalid_from_date = i2 WITH protect, constant(8)
 DECLARE ninvalid_to_date = i2 WITH protect, constant(9)
 DECLARE ninvalid_facility_input = i2 WITH protect, constant(10)
 DECLARE ninvalid_facility = i2 WITH protect, constant(11)
 DECLARE nverify_facility_fail = i2 WITH protect, constant(12)
 DECLARE nfacs_for_prsnl_fail = i2 WITH protect, constant(13)
 DECLARE nzero_nurse_unit_found = i2 WITH protect, constant(14)
 DECLARE brxcommentfound = i2 WITH private, noconstant(false)
 DECLARE bordercommentfound = i2 WITH private, noconstant(false)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nfailed_ccl_error_uvom)
 DECLARE nqualstatus = i2 WITH private, noconstant(nsuccess_uvom)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cexpandsize = i4 WITH protect, constant(20)
 DECLARE lexpandidx = i4 WITH protect, noconstant(0)
 DECLARE lexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE lexpandactualsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandloopcnt = i4 WITH protect, noconstant(0)
 DECLARE lexpandstart = i4 WITH protect, noconstant(0)
 DECLARE llocateidx = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE handleuserinput(susername=vc,sfacility=vc,sfromdate=vc,stodate=vc) = i2 WITH protect
 DECLARE lookupprsnlid(susername=vc) = f8 WITH protect
 DECLARE lookupfacid(sfacility=vc) = f8 WITH protect
 DECLARE verifyfacforuser(dfacilitycd=f8,susername=vc,sprsnlid=f8) = i2 WITH protect
 DECLARE filloutrequest(dfacilitycd=f8) = i2 WITH protect
 SET dstat = uar_get_meaning_by_codeset(319,"FIN NBR",1,cfin)
 SET dstat = uar_get_meaning_by_codeset(319,"MRN",1,cmrn)
 SET dstat = uar_get_meaning_by_codeset(339,"CENSUS",1,ccensus)
 SET dstat = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,cdiscontinued)
 SET dstat = uar_get_meaning_by_codeset(6004,"PENDING",1,cpending)
 SET dstat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,ccompleted)
 SET dstat = uar_get_meaning_by_codeset(6004,"TRANSCANCEL",1,ctranscancel)
 SET dstat = uar_get_meaning_by_codeset(6004,"CANCELED",1,ccanceled)
 SET dstat = uar_get_meaning_by_codeset(6004,"FUTURE",1,cfuture)
 SET dstat = uar_get_meaning_by_codeset(6004,"DELETED",1,cvoid)
 SET dstat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,cvoidwithresult)
 SET dstat = uar_get_meaning_by_codeset(4500,"INPATIENT",1,cinpatient)
 SET dstat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 SET dstat = uar_get_meaning_by_codeset(261,"DISCHARGED",1,cdischarged)
 SET dstat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,corder_comment)
 SET dstat = uar_get_meaning_by_codeset(14,"PHARM COMMEN",1,cpharm_comment)
 SET nuserinputreturn = handleuserinput( $USERNAME, $FACILITY, $FROM_DATE, $TO_DATE)
 IF (nuserinputreturn != nsuccess_uvom)
  SET nscriptstatus = nuserinputreturn
  CALL echo("Error: Cannot validate user input. Exiting Script")
  GO TO exit_script
 ENDIF
 SET nfacforprsnlreturn = verifyfacforuser(mdfaccd,msinputusername,mduserprsnlid)
 IF (nfacforprsnlreturn != nsuccess_uvom)
  SET nscriptstatus = nfacforprsnlreturn
  CALL echo("Error: User doesn't have access for the input facility. Exiting Script")
  GO TO exit_script
 ENDIF
 SET nfilloutrequestreturn = filloutrequest(mdfaccd)
 IF (nfilloutrequestreturn != nsuccess_uvom)
  SET nscriptstatus = nfilloutrequestreturn
  CALL echo("Error: request not filled out.  No nurse units for facility")
  GO TO exit_script
 ENDIF
 SET lnurseunitcnt = size(request_uvom->nurse_unit_list,5)
 IF (lnurseunitcnt <= 0)
  SET nqualstatus = nzero_nurse_units
  CALL echo("No NurseUnits passed in, exiting script")
  GO TO exit_script
 ENDIF
 SET qtimerbegindttm = cnvtdatetime(curdate,curtime3)
 SET dgetencntrdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 CALL echo("******************************")
 CALL echo("Retrieving List of Unverified Orders...")
 CALL echo("******************************")
 SET qtimerbegindttm = cnvtdatetime(curdate,curtime3)
 SET lexpandactualsize = size(request_uvom->nurse_unit_list,5)
 SET lexpandloopcnt = ceil((cnvtreal(lexpandactualsize)/ cexpandsize))
 SET lexpandtotal = (lexpandloopcnt * cexpandsize)
 SET lexpandstart = 1
 SET dstat = alterlist(request_uvom->nurse_unit_list,lexpandtotal)
 FOR (lidx = (lexpandactualsize+ 1) TO lexpandtotal)
   SET request_uvom->nurse_unit_list[lidx].nurse_unit_cd = request_uvom->nurse_unit_list[
   lexpandactualsize].nurse_unit_cd
 ENDFOR
 SELECT INTO "nl:"
  FROM encounter e,
   order_dispense od,
   orders o,
   person p,
   order_action oa,
   prsnl pr,
   person p2,
   person p3,
   prsnl pr2,
   (dummyt d1  WITH seq = value(lexpandloopcnt))
  PLAN (d1
   WHERE assign(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
   JOIN (e
   WHERE expand(lidx,lexpandstart,(lexpandstart+ (cexpandsize - 1)),(e.loc_nurse_unit_cd+ 0),
    request_uvom->nurse_unit_list[lidx].nurse_unit_cd)
    AND e.disch_dt_tm BETWEEN cnvtdatetime(mdfromdttm) AND cnvtdatetime(mdtodttm)
    AND ((e.med_service_cd+ 0) >= 0)
    AND ((e.encntr_id+ 0) > 0))
   JOIN (od
   WHERE od.encntr_id=e.encntr_id
    AND ((od.need_rx_verify_ind=norders_nrvi_needs_verify) OR (od.need_rx_verify_ind=
   norders_nrvi_rejected
    AND (request_uvom->need_rx_prod_assign_flag != 1)))
    AND od.need_rx_verify_ind IN (norders_nrvi_needs_verify, norders_nrvi_rejected)
    AND od.unverified_comm_type_cd >= 0
    AND od.unverified_rx_ord_priority_cd >= 0
    AND od.need_rx_prod_assign_flag >= 0
    AND od.pharm_type_cd IN (cinpatient, 0))
   JOIN (o
   WHERE o.order_id=od.order_id
    AND ((o.orig_ord_as_flag=nnormal_order) OR (o.orig_ord_as_flag=npharm_charge_order))
    AND o.cs_flag != ncare_set_parent
    AND o.need_rx_clin_review_flag >= 0)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (pr
   WHERE (pr.person_id=(oa.action_personnel_id+ 0))
    AND pr.position_cd > 0)
   JOIN (pr2
   WHERE pr2.person_id=o.last_update_provider_id)
   JOIN (p2
   WHERE p2.person_id=pr.person_id)
   JOIN (p3
   WHERE p3.person_id=pr2.person_id)
  ORDER BY p.name_full_formatted, o.protocol_order_id, o.current_start_dt_tm,
   od.order_id
  HEAD REPORT
   nordcnt = 0
  HEAD od.order_id
   index = 0, index = locateval(idx,1,size(request_uvom->nurse_unit_list,5),e.loc_nurse_unit_cd,
    request_uvom->nurse_unit_list[idx].nurse_unit_cd)
   IF (index > 0)
    nordcnt = (nordcnt+ 1)
    IF (nordcnt > size(reply_uvom->order_list,5))
     dstat = alterlist(reply_uvom->order_list,(nordcnt+ 10))
    ENDIF
    CALL echo("-"),
    CALL echo(build("order_id :",od.order_id)), reply_uvom->order_list[nordcnt].
    last_verified_action_seq = od.last_ver_act_seq,
    reply_uvom->order_list[nordcnt].person_id = o.person_id, reply_uvom->order_list[nordcnt].
    patient_name_full_formatted = trim(p.name_full_formatted), reply_uvom->order_list[nordcnt].
    encntr_id = od.encntr_id,
    reply_uvom->order_list[nordcnt].order_id = od.order_id, reply_uvom->order_list[nordcnt].
    dept_misc_line = trim(o.dept_misc_line), reply_uvom->order_list[nordcnt].link_nbr = o.link_nbr,
    reply_uvom->order_list[nordcnt].link_type_flag = o.link_type_flag, reply_uvom->order_list[nordcnt
    ].updt_dt_tm = o.updt_dt_tm
    IF (validate(o.current_start_tz,0))
     reply_uvom->order_list[nordcnt].current_start_tz = o.current_start_tz
    ENDIF
    IF (validate(o.protocol_order_id,0))
     reply_uvom->order_list[nordcnt].protocol_order_id = o.protocol_order_id
    ENDIF
    reply_uvom->order_list[nordcnt].template_order_flag = o.template_order_flag, dstat = assign(
     validate(reply_uvom->order_list[nordcnt].formulary_status_cd),validate(o.formulary_status_cd,0)),
    reply_uvom->order_list[nordcnt].current_start_dt_tm = o.current_start_dt_tm,
    reply_uvom->order_list[nordcnt].need_rx_verify_ind = od.need_rx_verify_ind, reply_uvom->
    order_list[nordcnt].action_type_cd = od.unverified_action_type_cd, reply_uvom->order_list[nordcnt
    ].action_type_display = uar_get_code_display(od.unverified_action_type_cd),
    reply_uvom->order_list[nordcnt].last_updt_user_id = pr.person_id, reply_uvom->order_list[nordcnt]
    .last_updt_user_name = trim(p2.name_full_formatted), reply_uvom->order_list[nordcnt].
    last_user_position_cd = pr.position_cd,
    reply_uvom->order_list[nordcnt].last_user_role_description = uar_get_code_display(pr.position_cd),
    reply_uvom->order_list[nordcnt].communication_type_cd = od.unverified_comm_type_cd, reply_uvom->
    order_list[nordcnt].communication_type_display = uar_get_code_display(od.unverified_comm_type_cd),
    reply_uvom->order_list[nordcnt].route_cd = od.unverified_route_cd, reply_uvom->order_list[nordcnt
    ].route_display = uar_get_code_display(od.unverified_route_cd), reply_uvom->order_list[nordcnt].
    rx_order_priority_cd = od.unverified_rx_ord_priority_cd,
    reply_uvom->order_list[nordcnt].rx_order_priority_display = uar_get_code_display(od
     .unverified_rx_ord_priority_cd), reply_uvom->order_list[nordcnt].order_provider_id = o
    .last_update_provider_id, reply_uvom->order_list[nordcnt].order_provider_name = trim(p3
     .name_full_formatted),
    reply_uvom->order_list[nordcnt].order_conversation_id = oa.order_conversation_id, reply_uvom->
    order_list[nordcnt].order_convs_seq = oa.order_convs_seq, reply_uvom->order_list[nordcnt].
    order_status_cd = o.order_status_cd,
    reply_uvom->order_list[nordcnt].need_rx_prod_assign_flag = od.need_rx_prod_assign_flag,
    reply_uvom->order_list[nordcnt].need_rx_clin_review_flag = o.need_rx_clin_review_flag, reply_uvom
    ->order_list[nordcnt].patient_med_ind = od.patient_med_ind,
    reply_uvom->order_list[nordcnt].start_dispense_dt_tm = od.start_dispense_dt_tm, reply_uvom->
    order_list[nordcnt].facility_cd = e.loc_facility_cd, reply_uvom->order_list[nordcnt].building_cd
     = e.loc_building_cd,
    reply_uvom->order_list[nordcnt].nurse_unit_cd = e.loc_nurse_unit_cd, reply_uvom->order_list[
    nordcnt].room_cd = e.loc_room_cd, reply_uvom->order_list[nordcnt].bed_cd = e.loc_bed_cd,
    reply_uvom->order_list[nordcnt].med_service_cd = e.med_service_cd, reply_uvom->order_list[nordcnt
    ].facility_disp = trim(uar_get_code_display(e.loc_facility_cd)), reply_uvom->order_list[nordcnt].
    building_disp = trim(uar_get_code_display(e.loc_building_cd)),
    reply_uvom->order_list[nordcnt].nurse_unit_disp = trim(uar_get_code_display(e.loc_nurse_unit_cd)),
    reply_uvom->order_list[nordcnt].room_disp = trim(uar_get_code_display(e.loc_room_cd)), reply_uvom
    ->order_list[nordcnt].bed_disp = trim(uar_get_code_display(e.loc_bed_cd)),
    reply_uvom->order_list[nordcnt].med_service_disp = trim(uar_get_code_display(e.med_service_cd)),
    dstat = assign(validate(reply_uvom->order_list[nordcnt].order_schedule_precision_bit),o
     .order_schedule_precision_bit), dstat = assign(validate(reply_uvom->order_list[nordcnt].
      future_location_facility_cd),o.future_location_facility_cd),
    dstat = assign(validate(reply_uvom->order_list[nordcnt].future_location_nurse_unit_cd),o
     .future_location_nurse_unit_cd), dstat = assign(validate(reply_uvom->order_list[nordcnt].
      dosing_method_flag),validate(o.dosing_method_flag,0)), dstat = assign(validate(reply_uvom->
      order_list[nordcnt].warning_level_bit),validate(o.warning_level_bit,0))
   ENDIF
  FOOT REPORT
   dstat = alterlist(reply_uvom->order_list,nordcnt),
   CALL echo("-"),
   CALL echo(build("Number of qualifying orders :",nordcnt)),
   CALL echo("-"), ntotalordcount = nordcnt
  WITH nocounter
 ;end select
 FREE RECORD encounters
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE loop_cnt2 = i4 WITH noconstant(0)
 DECLARE nstart2 = i4
 DECLARE expand_list_size = i4 WITH noconstant(0)
 SET cur_list_size = size(reply_uvom->order_list,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET nstart = 1
 SET expand_list_size = (cur_list_size+ (batch_size - mod(cur_list_size,batch_size)))
 SET dstat = alterlist(reply_uvom->order_list,expand_list_size)
 FOR (idx = (cur_list_size+ 1) TO expand_list_size)
   SET reply_uvom->order_list[idx].order_id = reply_uvom->order_list[cur_list_size].order_id
 ENDFOR
 SET idx = 0
 SET idx2 = 0
 SELECT INTO "nl:"
  FROM order_comment oc,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (oc
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),oc.order_id,reply_uvom->order_list[idx].
    order_id))
  DETAIL
   index = 0, index = locateval(idx2,1,size(reply_uvom->order_list,5),oc.order_id,reply_uvom->
    order_list[idx2].order_id)
   IF (index > 0)
    IF (oc.comment_type_cd=corder_comment)
     reply_uvom->order_list[index].order_comment_ind = 1
    ENDIF
    IF (oc.comment_type_cd=cpharm_comment)
     reply_uvom->order_list[index].rx_comment_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET idx = 0
 SET idx2 = 0
 SET idx3 = 0
 IF (ntotalordcount > 0)
  SELECT INTO "nl:"
   FROM orders o,
    (dummyt d  WITH seq = value(loop_cnt)),
    act_pw_comp apc,
    pathway pw
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (o
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),o.order_id,reply_uvom->order_list[idx].
     order_id))
    JOIN (apc
    WHERE apc.parent_entity_id=o.order_id
     AND apc.parent_entity_name="ORDERS")
    JOIN (pw
    WHERE pw.pathway_id=apc.pathway_id)
   ORDER BY o.protocol_order_id
   DETAIL
    index = locateval(idx,assign(nstart2,(((d.seq - 1) * batch_size)+ 1)),cur_list_size,apc
     .parent_entity_id,reply_uvom->order_list[idx].order_id)
    WHILE (index != 0)
      reply_uvom->order_list[index].power_plan_order_ind = 1, reply_uvom->order_list[index].
      pathway_id = pw.pathway_id
      IF (validate(pw.pw_group_desc,0))
       reply_uvom->order_list[index].power_plan_desc = pw.pw_group_desc
      ENDIF
      IF (o.protocol_order_id=0
       AND o.template_order_flag=cprotocol_order_flag)
       IF (o.person_id != pw.person_id
        AND  NOT (o.order_status_cd IN (cvoid, cvoidwithresult)))
        dstat = assign(validate(reply_uvom->order_list[index].plan_warning_level_bit),bor(validate(pw
           .warning_level_bit,0),lplan_person_mismatch_bit))
       ELSE
        dstat = assign(validate(reply_uvom->order_list[index].plan_warning_level_bit),validate(pw
          .warning_level_bit,0))
       ENDIF
      ELSEIF (o.protocol_order_id > 0)
       IF ((request_uvom->future_order_ind=1))
        protocolidx = locateval(idx3,1,cur_list_size,o.protocol_order_id,reply_uvom->order_list[idx3]
         .order_id)
        IF (protocolidx > 0)
         dstat = assign(validate(reply_uvom->order_list[index].warning_level_bit),bor(validate(o
            .warning_level_bit,0),validate(reply_uvom->order_list[protocolidx].warning_level_bit,0))),
         dstat = assign(validate(reply_uvom->order_list[index].plan_warning_level_bit),bor(validate(
            pw.warning_level_bit,0),validate(reply_uvom->order_list[protocolidx].
            plan_warning_level_bit,0))), dstat = assign(validate(reply_uvom->order_list[index].
           protocol_person_id),validate(reply_uvom->order_list[protocolidx].person_id,0))
        ELSE
         dstat = assign(validate(reply_uvom->order_list[index].warning_level_bit),validate(o
           .warning_level_bit,0)), dstat = assign(validate(reply_uvom->order_list[index].
           plan_warning_level_bit),validate(pw.warning_level_bit,0))
        ENDIF
       ELSE
        dstat = assign(validate(reply_uvom->order_list[index].warning_level_bit),validate(o
          .warning_level_bit,0)), dstat = assign(validate(reply_uvom->order_list[index].
          plan_warning_level_bit),validate(pw.warning_level_bit,0))
       ENDIF
      ENDIF
      index = locateval(idx2,(index+ 1),cur_list_size,apc.parent_entity_id,reply_uvom->order_list[
       idx2].order_id)
    ENDWHILE
   FOOT  o.protocol_order_id
    IF ((request_uvom->future_order_ind=0)
     AND o.protocol_order_id != 0.0)
     protlistidx = (protlistidx+ 1)
     IF (protlistidx > size(protocols->list,5))
      dstat = alterlist(protocols->list,(protlistidx+ 10))
     ENDIF
     protocols->list[protlistidx].order_id = o.protocol_order_id,
     CALL echo(build("adding this protocol_order_id to new rec: ",protocols->list[protlistidx].
      order_id))
    ENDIF
   WITH nocounter
  ;end select
  SET dstat = alterlist(protocols->list,protlistidx)
  IF ((request_uvom->future_order_ind=0)
   AND size(protocols->list,5) > 0)
   DECLARE protocol_bit = i4 WITH noconstant(0)
   DECLARE protocol_plan_bit = i4 WITH noconstant(0)
   DECLARE protocol_list_size = i4 WITH noconstant(size(protocols->list,5))
   SET loop_cnt2 = ceil((cnvtreal(protocol_list_size)/ batch_size))
   SET nstart = 1
   SET expand_list_size = (protocol_list_size+ (batch_size - mod(protocol_list_size,batch_size)))
   SET dstat = alterlist(protocols->list,expand_list_size)
   FOR (idx = (protocol_list_size+ 1) TO expand_list_size)
     SET protocols->list[idx].order_id = protocols->list[protocol_list_size].order_id
   ENDFOR
   SET idx = 0
   SET idx2 = 0
   SELECT INTO "nl:"
    FROM orders o,
     (dummyt d  WITH seq = value(loop_cnt2)),
     act_pw_comp apc,
     pathway pw
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (o
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),o.order_id,protocols->list[idx].order_id))
     JOIN (apc
     WHERE apc.parent_entity_id=o.order_id
      AND apc.parent_entity_name="ORDERS")
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
    DETAIL
     IF (o.protocol_order_id=0
      AND o.template_order_flag=cprotocol_order_flag)
      dstat = assign(protocol_bit,validate(o.warning_level_bit,0)), dstat = assign(protocol_plan_bit,
       validate(pw.warning_level_bit,0))
      IF (o.person_id != pw.person_id
       AND  NOT (o.order_status_cd IN (cvoid, cvoidwithresult)))
       dstat = assign(protocol_plan_bit,bor(validate(pw.warning_level_bit,0),
         lplan_person_mismatch_bit))
      ENDIF
     ENDIF
     index = locateval(idx,1,cur_list_size,o.order_id,reply_uvom->order_list[idx].protocol_order_id)
     WHILE (index != 0)
       dstat = assign(validate(reply_uvom->order_list[index].warning_level_bit),bor(protocol_bit,
         validate(reply_uvom->order_list[index].warning_level_bit,0))), dstat = assign(validate(
         reply_uvom->order_list[index].plan_warning_level_bit),bor(protocol_plan_bit,validate(
          reply_uvom->order_list[index].plan_warning_level_bit,0))), dstat = assign(validate(
         reply_uvom->order_list[index].protocol_person_id),validate(o.person_id,0)),
       index = locateval(idx2,(index+ 1),cur_list_size,o.order_id,reply_uvom->order_list[idx2].
        protocol_order_id)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
  FREE RECORD protocols
  SET dorddispseldiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
  CALL echo("******************************")
  CALL echo("Retrieving Thera Sub Info For List of Unverified Orders...")
  CALL echo("******************************")
  SET nstart = 1
  SET idx = 0
  SET idx2 = 0
  SELECT INTO "nl:"
   ltherasubsort =
   IF (ots.substitution_accept_flag=ctheraaccept) 3
   ELSEIF (ots.substitution_accept_flag=ctheraaltreg) 2
   ELSEIF (ots.substitution_accept_flag=ctherareject) 1
   ELSE 0
   ENDIF
   FROM order_therap_sbsttn ots,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ots
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ots.order_id,reply_uvom->order_list[idx].
     order_id))
   ORDER BY ots.order_id, ltherasubsort DESC
   HEAD ots.order_id
    index = locateval(idx,assign(nstart2,(((d.seq - 1) * batch_size)+ 1)),cur_list_size,ots.order_id,
     reply_uvom->order_list[idx].order_id)
    WHILE (index != 0)
     reply_uvom->order_list[index].thera_sub_flag = ots.substitution_accept_flag,index = locateval(
      idx2,(index+ 1),cur_list_size,ots.order_id,reply_uvom->order_list[idx2].order_id)
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("******************************")
 CALL echo("Retrieving Encounter Info For List of Unverified Orders...")
 CALL echo("******************************")
 IF (size(reply_uvom->order_list,5) <= 0)
  SET nqualstatus = nzero_orders
  CALL echo("No orders qualified, exiting script")
  GO TO exit_script
 ENDIF
 SET qtimerbegindttm = cnvtdatetime(curdate,curtime3)
 SET nstart = 1
 SET nstart2 = 0
 SET idx = 0
 SET idx2 = 0
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (ea
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ea.encntr_id,reply_uvom->order_list[idx].
    encntr_id)
    AND ea.encntr_alias_type_cd IN (cfin, cmrn))
  DETAIL
   index = locateval(idx,assign(nstart2,(((d.seq - 1) * batch_size)+ 1)),cur_list_size,ea.encntr_id,
    reply_uvom->order_list[idx].encntr_id)
   WHILE (index != 0)
     IF (ea.encntr_alias_type_cd=cfin)
      reply_uvom->order_list[index].fin_nbr = trim(ea.alias,3)
     ENDIF
     IF (ea.encntr_alias_type_cd=cmrn)
      reply_uvom->order_list[index].mrn_nbr = trim(ea.alias,3)
     ENDIF
     index = locateval(idx2,(index+ 1),cur_list_size,ea.encntr_id,reply_uvom->order_list[idx2].
      encntr_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET dstat = alterlist(reply_uvom->order_list,cur_list_size)
 SET dretrencntrinfodiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 CALL echo("******************************")
 CALL echo("Retrieving alert information for orders...")
 CALL echo("******************************")
 SET modify = nopredeclare
 SET lordercnt = size(reply_uvom->order_list,5)
 SET idx = 0
 FOR (i = 1 TO ntotalordcount)
   IF ((reply_uvom->order_list[i].protocol_order_id > 0))
    SET index = locateval(idx,1,lordercnt,reply_uvom->order_list[i].protocol_order_id,reply_uvom->
     order_list[idx].order_id)
    IF (index=0)
     SET lordercnt = (lordercnt+ 1)
     IF (lordercnt > size(reply_uvom->order_list,5))
      SET dstat = alterlist(reply_uvom->order_list,(lordercnt+ 10))
     ENDIF
     SET reply_uvom->order_list[lordercnt].order_id = reply_uvom->order_list[i].protocol_order_id
     SET reply_uvom->order_list[lordercnt].template_order_flag = cprotocol_order_flag
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(build("lOrderCnt: ",lordercnt))
 CALL echo(build("nTotalOrdCount: ",ntotalordcount))
 CALL echo(build("size reply_uvom: ",size(reply_uvom->order_list,5)))
 IF (lordercnt > ntotalordcount)
  SET lexpandactualsize = lordercnt
  SET lexpandtotal = (ntotalordcount+ (ceil((cnvtreal((lordercnt - ntotalordcount))/ cexpandsize)) *
  cexpandsize))
  SET lexpandstart = ntotalordcount
  SET dstat = alterlist(reply_uvom->order_list,lexpandtotal)
  CALL echo(build("size of req: ",value(size(reply_uvom->order_list,5))))
  CALL echo(build("expand total: ",lexpandtotal))
  FOR (lexpandidx = (lexpandactualsize+ 1) TO lexpandtotal)
    SET reply_uvom->order_list[lexpandidx].order_id = reply_uvom->order_list[lexpandactualsize].
    order_id
  ENDFOR
  SELECT INTO "NL:"
   FROM order_dispense od,
    (dummyt d1  WITH seq = value((1+ (((lexpandtotal - ntotalordcount) - 1)/ cexpandsize))))
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,lexpandstart,(lexpandstart+ cexpandsize))))
    JOIN (od
    WHERE expand(lexpandidx,lexpandstart,((lexpandstart+ cexpandsize) - 1),od.order_id,reply_uvom->
     order_list[lexpandidx].order_id))
   DETAIL
    CALL echo(build("lExpandStart: ",lexpandstart)),
    CALL echo(build("expand end: ",((lexpandstart+ cexpandsize) - 1))),
    CALL echo(build("order_id:  ",od.order_id)),
    index = locateval(idx,ntotalordcount,lordercnt,od.order_id,reply_uvom->order_list[idx].order_id),
    CALL echo(build("index: ",index))
    IF (index > 0)
     reply_uvom->order_list[index].last_verified_action_seq = od.last_ver_act_seq
    ENDIF
   WITH nocounter
  ;end select
  SET dstat = alterlist(reply_uvom->order_list,lordercnt)
 ENDIF
 SET dstat = alterlist(rx_gahs_request->qual,lordercnt)
 FOR (i = 1 TO lordercnt)
  SET rx_gahs_request->qual[i].order_id = reply_uvom->order_list[i].order_id
  SET rx_gahs_request->qual[i].action_sequence = (reply_uvom->order_list[i].last_verified_action_seq
  + 1)
 ENDFOR
 FREE RECORD orders
 SET qtimerbegindttm = cnvtdatetime(curdate,curtime3)
 EXECUTE rx_get_alert_hx_summary  WITH replace("REQUEST","RX_GAHS_REQUEST"), replace("REPLY",
  "RX_GAHS_REPLY")
 SET dgetalertdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 FREE RECORD rx_gahs_request
 SET modify = predeclare
 FOR (i = 1 TO lordercnt)
   SET reply_uvom->order_list[i].drug_allergy_alert_ind = rx_gahs_reply->qual[i].
   drug_allergy_alert_ind
   SET reply_uvom->order_list[i].drug_drug_alert_ind = rx_gahs_reply->qual[i].drug_drug_alert_ind
   SET reply_uvom->order_list[i].drug_drug_max_severity = rx_gahs_reply->qual[i].
   drug_drug_max_severity
   SET reply_uvom->order_list[i].drug_food_alert_ind = rx_gahs_reply->qual[i].drug_food_alert_ind
   SET reply_uvom->order_list[i].drug_food_max_severity = rx_gahs_reply->qual[i].
   drug_food_max_severity
   SET reply_uvom->order_list[i].drug_dup_alert_ind = rx_gahs_reply->qual[i].drug_dup_alert_ind
   SET reply_uvom->order_list[i].discern_alert_ind = rx_gahs_reply->qual[i].discern_alert_ind
   SET reply_uvom->order_list[i].iv_compat_alert_ind = rx_gahs_reply->qual[i].iv_compat_alert_ind
   SET reply_uvom->order_list[i].iv_compat_alert_type = rx_gahs_reply->qual[i].iv_compat_alert_type
 ENDFOR
 FREE RECORD rx_gahs_reply
 SET reply_uvom->get_encntr_time_in_sec = dgetencntrdiffinsec
 SET reply_uvom->ord_disp_sel_time_in_sec = dorddispseldiffinsec
 SET reply_uvom->retr_encntr_info_time_in_sec = dretrencntrinfodiffinsec
 SET reply_uvom->get_alert_time_in_sec = dgetalertdiffinsec
 FREE SET audit_person_qual
 RECORD audit_person_qual(
   1 person_list[*]
     2 person_id = f8
 )
 SELECT DISTINCT INTO "nl:"
  personid = reply_uvom->order_list[d.seq].person_id
  FROM (dummyt d  WITH seq = value(size(reply_uvom->order_list,5)))
  PLAN (d
   WHERE (reply_uvom->order_list[d.seq].person_id > 0))
  ORDER BY personid
  HEAD REPORT
   auditcnt = 0
  HEAD personid
   auditcnt = (auditcnt+ 1)
   IF (auditcnt > size(audit_person_qual->person_list,5))
    dstat = alterlist(audit_person_qual->person_list,(auditcnt+ 10))
   ENDIF
   audit_person_qual->person_list[auditcnt].person_id = reply_uvom->order_list[d.seq].person_id
  FOOT REPORT
   dstat = alterlist(audit_person_qual->person_list,auditcnt)
  WITH nocounter
 ;end select
 SET auditsize = size(audit_person_qual->person_list,5)
 IF (auditsize=1)
  EXECUTE cclaudit 0, "Query List", "Unverified Medication Order Monitor",
  "Person", "Patient", "Patient",
  "Access/Use", audit_person_qual->person_list[1].person_id, " "
 ELSE
  CALL echo(build("***Auditing x number of items: ",auditsize))
  FOR (auditcnt = 1 TO auditsize)
   IF (auditcnt=1)
    SET auditmode = 1
   ELSEIF (auditcnt < auditsize)
    SET auditmode = 2
   ELSEIF (auditcnt=auditsize)
    SET auditmode = 3
   ENDIF
   EXECUTE cclaudit auditmode, "Query List", "Unverified Medication Order Monitor",
   "Person", "Patient", "Patient",
   "Access/Use", audit_person_qual->person_list[auditcnt].person_id, " "
  ENDFOR
 ENDIF
 GO TO exit_script
 SUBROUTINE handleuserinput(susername,sfacility,sfromdate,stodate)
   DECLARE npass = i2 WITH private, constant(0)
   SET msinputusername = susername
   IF (trim(msinputusername,3)="")
    CALL echo("No user ID was entered.  Exiting Script")
    RETURN(ninvalid_username_input)
   ELSE
    SET mduserprsnlid = lookupprsnlid(msinputusername)
    IF (mduserprsnlid <= 0.0)
     CALL echo(concat("PersonId lookup failed for user:",msinputusername))
     RETURN(ninvlaid_username)
    ENDIF
   ENDIF
   SET msinputfacname = sfacility
   IF (trim(msinputfacname,3)="")
    CALL echo("Using all facilities")
    SET nallfacilities = 1
   ELSE
    SET mdfaccd = lookupfacid(msinputfacname)
    IF (mdfaccd <= 0.0)
     CALL echo(concat("Facility lookup failed for: ",msinputfacname))
     RETURN(ninvalid_facility)
    ENDIF
   ENDIF
   IF (trim(sfromdate)=""
    AND trim(stodate)="")
    CALL echo("Blank From Date or To Date was entered.  Exiting Script")
    RETURN(ninvalid_date_input)
   ELSEIF (size(trim(sfromdate)) > 0
    AND cnvtint(stodate)=999)
    SET mdfromdttm = cnvtdatetime((curdate - cnvtint(sfromdate)),0000)
    SET mdtodttm = cnvtdatetime(curdate,2359)
   ELSE
    SET mdfromdttm = cnvtdatetime(cnvtdate(sfromdate),0000)
    SET mdtodttm = cnvtdatetime(cnvtdate(stodate),2359)
   ENDIF
   IF (mdfromdttm=0)
    CALL echo("From Date input invalid")
    RETURN(ninvalid_from_date)
   ENDIF
   IF (mdtodttm=0)
    CALL echo("To Date input invalid")
    RETURN(ninvalid_to_date)
   ENDIF
   CALL echo(build("Checking content for user: ",msinputusername))
   CALL echo(build("facility: ",msinputfacname))
   CALL echo(build2("and between the dates: ",format(mdfromdttm,";;q")," and ",format(mdtodttm,";;q")
     ))
   RETURN(npass)
 END ;Subroutine
 SUBROUTINE lookupprsnlid(susername)
   DECLARE dprsnlid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username=cnvtupper(trim(susername,3))
     AND ((p.active_ind+ 0)=1)
    DETAIL
     dprsnlid = p.person_id, msinputusernamefullformat = p.name_full_formatted
    WITH nocounter
   ;end select
   RETURN(dprsnlid)
 END ;Subroutine
 SUBROUTINE lookupfacid(sfacility)
   DECLARE dfaccddisp = f8 WITH protect, noconstant(0.0)
   DECLARE dfaccddesc = f8 WITH protect, noconstant(0.0)
   DECLARE nfacwght = i2 WITH protect, noconstant(0)
   SET dfaccddisp = uar_get_code_by("DISPLAY",220,sfacility)
   SET dfaccddesc = uar_get_code_by("DESCRIPTION",220,sfacility)
   IF (dfaccddisp > 0.0)
    SET nfacwght = 1
   ENDIF
   IF (dfaccddesc > 0.0)
    SET nfacwght = (nfacwght+ 3)
   ENDIF
   CASE (nfacwght)
    OF 1:
     RETURN(dfaccddisp)
    OF 3:
     RETURN(dfaccddesc)
    ELSE
     RETURN(0.0)
   ENDCASE
 END ;Subroutine
 SUBROUTINE verifyfacforuser(dfacilitycd,susername,sprsnlid)
   DECLARE nprsnlindex = i4 WITH private, noconstant(0)
   DECLARE nfacindex = i4 WITH private, noconstant(0)
   DECLARE nnum1 = i4 WITH private, noconstant(0)
   DECLARE nnum2 = i4 WITH private, noconstant(0)
   RECORD fac_prsnl_request_uvom(
     1 inc_outpt_fac_ind = i2
     1 inc_inact_fac_ind = i2
     1 qual[*]
       2 username = vc
       2 person_id = f8
   ) WITH protect
   RECORD fac_prsnl_reply_uvom(
     1 qual[*]
       2 status = c1
       2 username = vc
       2 person_id = f8
       2 facility_list[*]
         3 organization_id = f8
         3 facility_cd = f8
         3 cdf_meaning = c12
         3 description = vc
         3 child_ind = i2
         3 active_ind = i2
     1 elapsed_time = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET fac_prsnl_request_uvom->inc_outpt_fac_ind = 0
   SET fac_prsnl_request_uvom->inc_inact_fac_ind = 0
   SET dstat = alterlist(fac_prsnl_request_uvom->qual,1)
   SET fac_prsnl_request_uvom->qual[1].username = susername
   SET fac_prsnl_request_uvom->qual[1].person_id = sprsnlid
   EXECUTE rx_get_facs_for_prsnl  WITH replace("REQUEST","FAC_PRSNL_REQUEST_UVOM"), replace("REPLY",
    "FAC_PRSNL_REPLY_UVOM")
   IF ((fac_prsnl_reply_uvom->status_data.status != "S"))
    FREE RECORD fac_prsnl_reply_uvom
    RETURN(nfacs_for_prsnl_fail)
   ENDIF
   IF (nallfacilities=0
    AND dfacilitycd > 0.0)
    SET nprsnlindex = locateval(nnum1,1,size(fac_prsnl_reply_uvom->qual,5),sprsnlid,
     fac_prsnl_reply_uvom->qual[nnum1].person_id)
    IF (nprsnlindex > 0)
     SET nfacindex = locateval(nnum2,1,size(fac_prsnl_reply_uvom->qual[nprsnlindex].facility_list,5),
      dfacilitycd,fac_prsnl_reply_uvom->qual[nprsnlindex].facility_list[nnum2].facility_cd)
     SET dstat = alterlist(facilities->facilities_list,1)
     SET facilities->facilities_list[1].facility_cd = fac_prsnl_reply_uvom->qual[nprsnlindex].
     facility_list[nfacindex].facility_cd
    ENDIF
   ELSEIF (nallfacilities=1)
    SET nprsnlindex = locateval(nnum1,1,size(fac_prsnl_reply_uvom->qual,5),sprsnlid,
     fac_prsnl_reply_uvom->qual[nnum1].person_id)
    FOR (nnum1 = 1 TO size(fac_prsnl_reply_uvom->qual[nprsnlindex].facility_list,5))
     SET dstat = alterlist(facilities->facilities_list,nnum1)
     SET facilities->facilities_list[nnum1].facility_cd = fac_prsnl_reply_uvom->qual[nprsnlindex].
     facility_list[nnum1].facility_cd
    ENDFOR
   ENDIF
   FREE RECORD fac_prsnl_reply_uvom
   IF (size(facilities->facilities_list,5) > 0)
    RETURN(nsuccess_uvom)
   ENDIF
   RETURN(nverify_facility_fail)
 END ;Subroutine
 SUBROUTINE filloutrequest(dfacilitycd)
   DECLARE dfacility = f8 WITH protect, noconstant(uar_get_code_by("MEANING",222,"FACILITY"))
   DECLARE dbuilding = f8 WITH protect, noconstant(uar_get_code_by("MEANING",222,"BUILDING"))
   DECLARE dnurseunit = f8 WITH protect, noconstant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
   DECLARE dambulatory = f8 WITH protect, noconstant(uar_get_code_by("MEANING",222,"AMBULATORY"))
   DECLARE dactive = f8 WITH protect, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE nidx = i2 WITH protect, noconstant(0)
   SELECT
    lg3.*, cv.*
    FROM location_group lg1,
     location_group lg2,
     location_group lg3,
     code_value cv,
     (dummyt d  WITH seq = value(size(facilities->facilities_list,5)))
    PLAN (d)
     JOIN (lg1
     WHERE (lg1.parent_loc_cd=facilities->facilities_list[d.seq].facility_cd)
      AND lg1.active_status_cd=dactive
      AND lg1.active_ind=1
      AND lg1.location_group_type_cd=dfacility)
     JOIN (lg2
     WHERE lg2.parent_loc_cd=lg1.child_loc_cd
      AND lg2.location_group_type_cd=dbuilding
      AND lg2.active_ind=1
      AND lg2.active_status_cd=dactive)
     JOIN (lg3
     WHERE lg3.parent_loc_cd=outerjoin(lg2.child_loc_cd)
      AND lg3.location_group_type_cd=outerjoin(dnurseunit)
      AND lg3.active_ind=outerjoin(1)
      AND lg3.active_status_cd=outerjoin(dactive))
     JOIN (cv
     WHERE cv.code_value=outerjoin(lg2.child_loc_cd)
      AND cv.code_set=outerjoin(220.0)
      AND cv.cdf_meaning=outerjoin("AMBULATORY"))
    ORDER BY lg3.parent_loc_cd
    HEAD REPORT
     nidx = 0
    DETAIL
     IF (lg3.parent_loc_cd > 0)
      nidx = (nidx+ 1)
      IF (nidx > size(request_uvom->nurse_unit_list,5))
       dstat = alterlist(request_uvom->nurse_unit_list,(nidx+ 10))
      ENDIF
      request_uvom->nurse_unit_list[nidx].nurse_unit_cd = lg3.parent_loc_cd, request_uvom->
      nurse_unit_list[nidx].nurse_unit_type = "Nurse Unit"
     ELSEIF (cv.code_value > 0)
      nidx = (nidx+ 1)
      IF (nidx > size(request_uvom->nurse_unit_list,5))
       dstat = alterlist(request_uvom->nurse_unit_list,(nidx+ 10))
      ENDIF
      request_uvom->nurse_unit_list[nidx].nurse_unit_cd = cv.code_value, request_uvom->
      nurse_unit_list[nidx].nurse_unit_type = "Ambulatory"
     ENDIF
    FOOT REPORT
     dstat = alterlist(request_uvom->nurse_unit_list,nidx),
     CALL echo(build("Total Nurse Units Found: ",nidx))
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("No Nurse Units found for Facility")
    RETURN(nzero_nurse_unit_found)
   ENDIF
   SET request_uvom->need_rx_prod_assign_flag = 0
   SET request_uvom->need_rx_clin_review_flag = 0
   SET request_uvom->future_order_ind = 0
   CALL echorecord(request_uvom)
   RETURN(nsuccess_uvom)
 END ;Subroutine
#exit_script
 CALL echo("******************************")
 CALL echo("Checking for errors...")
 CALL echo("******************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors_unv->err,5))
    SET dstat = alterlist(errors_unv->err,(errcnt+ 9))
   ENDIF
   SET errors_unv->err[errcnt].err_code = errcode
   SET errors_unv->err[errcnt].err_msg = errmsg
   SET errors_unv->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET dstat = alterlist(errors_unv->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error_uvom
  CALL echorecord(errors_unv)
 ELSEIF (errcnt <= 0
  AND nscriptstatus=nfailed_ccl_error_uvom)
  SET nscriptstatus = nsuccess_uvom
 ENDIF
 IF (nscriptstatus != nsuccess_uvom)
  SET reply_uvom->status_data.status = "F"
  SET reply_uvom->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error_uvom:
    SET reply_uvom->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectname = "RX_GET_UNVERIFIED_ORDERS_MM"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue = errors_unv->err[1].err_msg
   OF ninvalid_username_input:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue = "No user ID was entered."
   OF ninvlaid_username:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "PersonId lookup failed for user"
   OF ninvalid_date_input:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "Blank From Date or To Date was entered"
   OF ninvalid_from_date:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue = "From Date input invalid"
   OF ninvalid_to_date:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue = "To Date input invalid"
   OF ninvalid_facility:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "Facility lookup failed for user."
   OF nverify_facility_fail:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to lookup facility for user."
   OF nfacs_for_prsnl_fail:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to lookup facility for user, script rx_get_facs_for_prsnl Failed."
   OF nzero_nurse_unit_found:
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "No Nurse Units found for Facility"
  ENDCASE
 ELSEIF (size(reply_uvom->order_list,5)=0)
  SET reply_uvom->status_data.status = "Z"
  SET reply_uvom->status_data.subeventstatus[1].operationstatus = "Z"
  CASE (nqualstatus)
   OF nzero_nurse_units:
    SET reply_uvom->status_data.subeventstatus[1].operationname = "request_uvom"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectname = "nurse_unit_list"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "No nurse units in request_uvom"
   OF nzero_encounters:
    SET reply_uvom->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "No records found on encntr_domain"
   OF nzero_orders:
    SET reply_uvom->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply_uvom->status_data.subeventstatus[1].targetobjectvalue =
    "No records on order_dispense or org-security issue"
  ENDCASE
 ELSE
  SET reply_uvom->status_data.status = "S"
 ENDIF
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   row 0, "{f/0/1}{lpi/8}{cpi/12}",
   MACRO (buildnumberdisplay)
    snumberdisplay = format(dnumber,"#########;,IRT(1);F")
   ENDMACRO
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", npagenumber = (npagenumber+ 1), row + 1,
   CALL center(stitle,0,npage_width), col ncol_page_num, spage,
   npagenumber"####;R", row + 2, sstartdate = format(mdfromdttm,"MM/DD/YYYY HH:MM;;D"),
   senddate = format(mdtodttm,"MM/DD/YYYY HH:MM;;D"), col ncol1, sran_by,
   " ", msinputusernamefullformat, row + 1,
   col ncol1, srun_date, " ",
   srun_dt_tm, row + 1, col ncol1,
   sdate_range, " ", sstartdate,
   " - ", senddate, row + 1
   IF (size(msinputfacname) > 0
    AND nallfacilities=0)
    col ncol1, sfac, " ",
    msinputfacname
   ELSE
    col ncol1, sfac, " ",
    "ALL Facilities"
   ENDIF
   row + 2
   IF (size(reply_uvom->order_list,5) > 0
    AND (reply_uvom->status_data.status="S"))
    call reportmove('COL',(ncol1 - 1),0),
    "{box/20/1}{box/30/1}{box/16/1}{box/13/1}{box/13/1}{box/20/1}", row + 1,
    CALL center(sname,ncol1,(ncol1+ ncol1_width)),
    CALL center(sorder_sent,ncol2,(ncol2+ ncol2_width)),
    CALL center(sstart_date,ncol3,(ncol3+ ncol3_width)),
    CALL center(sfin,ncol4,(ncol4+ ncol4_width)),
    CALL center(smrn,ncol5,(ncol5+ ncol5_width)),
    CALL center(snurse,ncol6,(ncol6+ ncol6_width))
   ELSEIF ((reply_uvom->status_data.status != "S"))
    CALL center(build2("* * * ",reply_uvom->status_data.subeventstatus[1].targetobjectvalue," * * *"),
    0,npage_width)
   ELSE
    CALL center("* * * No Orders found * * *",0,npage_width)
   ENDIF
   row + 2
  DETAIL
   FOR (i = 1 TO size(reply_uvom->order_list,5))
     IF (row > nmax_rows_per_page)
      BREAK
     ENDIF
     call reportmove('COL',(ncol1 - 1),0),
     "{box/20/1}{box/30/1}{box/16/1}{box/13/1}{box/13/1}{box/20/1}", row + 1,
     stmppatname = substring(1,20,trim(reply_uvom->order_list[i].patient_name_full_formatted,3)),
     CALL center(stmppatname,ncol1,(ncol1+ ncol1_width)), stmpordersent = substring(1,30,trim(
       reply_uvom->order_list[i].dept_misc_line,3)),
     CALL center(stmpordersent,ncol2,(ncol2+ ncol2_width)), stmporderstartdate = format(reply_uvom->
      order_list[i].current_start_dt_tm,"MM/DD/YYYY hh:mm;;D"),
     CALL center(stmporderstartdate,ncol3,(ncol3+ ncol3_width)),
     stmppatfin = substring(1,13,trim(reply_uvom->order_list[i].fin_nbr,3)),
     CALL center(stmppatfin,ncol4,(ncol4+ ncol4_width)), stmppatmrn = substring(1,13,trim(reply_uvom
       ->order_list[i].mrn_nbr,3)),
     CALL center(stmppatmrn,ncol5,(ncol5+ ncol5_width)), stmpnurseunit = substring(1,20,trim(
       reply_uvom->order_list[i].nurse_unit_disp,3)),
     CALL center(stmpnurseunit,ncol6,(ncol6+ ncol6_width)),
     row + 1
   ENDFOR
  FOOT PAGE
   dstat = 0
  FOOT REPORT
   row + 2,
   CALL center(build2("* * * ",send_of_report," * * *"),0,npage_width)
  WITH dio = "POSTSCRIPT", maxcol = 200, maxrow = 100
 ;end select
 CALL echo("******************************")
 CALL echo("Freeing internal record structures...")
 CALL echo("******************************")
 FREE RECORD errors_unv
 CALL echo("====================")
 CALL echo("Script Section Times - In Seconds")
 CALL echo("====================")
 CALL echo(build(dgetencntrdiffinsec," - encntr_domain - select"))
 CALL echo("====================")
 CALL echo(build(dorddispseldiffinsec," - order_dispense - select"))
 CALL echo("====================")
 CALL echo(build(dretrencntrinfodiffinsec," - encntr_domain, encntr_alias  - select"))
 CALL echo("====================")
 CALL echo(build(dgetalertdiffinsec," - rx_get_alert_hx_summary"))
 CALL echo("====================")
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm1,5)
 CALL echo(build(dentirescriptdiffinsec," - rx_get_unverified_orders_mm - Elapsed Script Time"))
 CALL echo("====================")
 SET reply_uvom->entire_script_time_in_sec = dentirescriptdiffinsec
 CALL echo("LastMod = 000")
 CALL echo("ModDate = 12/30/2010")
 CALL echo("====================")
 CALL echo(build("ams_get_unver_orders_disch_rpt - End Dt/Tm :",format(cnvtdatetime(curdate,curtime3),
    ";;Q")))
 CALL echo("====================")
 CALL echo("-")
 CALL echo("<----- ams_get_unver_orders_disch_rpt ----->")
 CALL echo("-")
END GO
