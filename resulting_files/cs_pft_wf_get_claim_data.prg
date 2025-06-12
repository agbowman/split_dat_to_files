CREATE PROGRAM cs_pft_wf_get_claim_data
 SET pft_wf_get_claim_data_vrsn = "107606.FT.034"
 IF (validate(getcodevalue,char(128))=char(128))
  DECLARE getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 SUBROUTINE getcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", table_name, 0
      GO TO exit_script
     OF 1:
      SET table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
     OF 2:
      SET table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      EXECUTE pft_log "getcodevalue", table_name, 3
     OF 3:
      SET table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      CALL err_add_message(table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 RECORD reply(
   1 rows[*]
     2 identifiers[*]
       3 name = vc
       3 value = vc
     2 columns[*]
       3 value = vc
   1 headers[*]
     2 name = vc
     2 type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 rows[*]
     2 identifiers[*]
       3 name = vc
       3 value = f8
 )
 DECLARE getdata(_null) = null
 DECLARE addcolumns(_null) = null
 DECLARE getadddata(_null) = null
 DECLARE pm_inp_admit_dt_tm() = c20
 DECLARE mn_deny = i2 WITH protect, noconstant(0)
 CALL addcolumns(0)
 CALL getdata(0)
 CALL getadddata(0)
 GO TO exit_script
 SUBROUTINE addcolumns(_null)
   SET stat = alterlist(reply->headers,67)
   SET reply->headers[1].name = "Patient Name"
   SET reply->headers[1].type = "STRING"
   SET reply->headers[2].name = "Patient Address"
   SET reply->headers[2].type = "STRING"
   SET reply->headers[3].name = "Patient City"
   SET reply->headers[3].type = "STRING"
   SET reply->headers[4].name = "Patient State"
   SET reply->headers[4].type = "STRING"
   SET reply->headers[5].name = "Patient Zipcode"
   SET reply->headers[5].type = "STRING"
   SET reply->headers[6].name = "Patient Phone Number"
   SET reply->headers[6].type = "STRING"
   SET reply->headers[7].name = "Claim Number"
   SET reply->headers[7].type = "STRING"
   SET reply->headers[8].name = "Claim Status"
   SET reply->headers[8].type = "STRING"
   SET reply->headers[9].name = "Media Type"
   SET reply->headers[9].type = "STRING"
   SET reply->headers[10].name = "Claim Balance"
   SET reply->headers[10].type = "CURRENCY"
   SET reply->headers[11].name = "Ext Account #"
   SET reply->headers[11].type = "STRING"
   SET reply->headers[12].name = "Account Balance"
   SET reply->headers[12].type = "CURRENCY"
   SET reply->headers[13].name = "Guarantor Name"
   SET reply->headers[13].type = "STRING"
   SET reply->headers[14].name = "Guarantor Address"
   SET reply->headers[14].type = "STRING"
   SET reply->headers[15].name = "Guarantor City"
   SET reply->headers[15].type = "STRING"
   SET reply->headers[16].name = "Guarantor State"
   SET reply->headers[16].type = "STRING"
   SET reply->headers[17].name = "Guarantor Zip Code"
   SET reply->headers[17].type = "STRING"
   SET reply->headers[18].name = "Guarantor Phone Number"
   SET reply->headers[18].type = "STRING"
   SET reply->headers[19].name = "Health Plan"
   SET reply->headers[19].type = "STRING"
   SET reply->headers[20].name = "Bill Type"
   SET reply->headers[20].type = "STRING"
   SET reply->headers[21].name = "Benefit Order Status"
   SET reply->headers[21].type = "STRING"
   SET reply->headers[22].name = "Days Since Submitted"
   SET reply->headers[22].type = "SHORT"
   SET reply->headers[23].name = "Discharge Date"
   SET reply->headers[23].type = "STRING"
   SET reply->headers[24].name = "Registration Date"
   SET reply->headers[24].type = "STRING"
   SET reply->headers[25].name = "Bill Status Reason"
   SET reply->headers[25].type = "STRING"
   SET reply->headers[26].name = "Bill Template"
   SET reply->headers[26].type = "STRING"
   SET reply->headers[27].name = "Generation Date"
   SET reply->headers[27].type = "STRING"
   SET reply->headers[28].name = "Financial Class"
   SET reply->headers[28].type = "STRING"
   SET reply->headers[29].name = "Med Service"
   SET reply->headers[29].type = "STRING"
   SET reply->headers[30].name = "Days Since Discharge"
   SET reply->headers[30].type = "SHORT"
   SET reply->headers[31].name = "Media Sub Type"
   SET reply->headers[31].type = "STRING"
   SET reply->headers[32].name = "Priority Sequence"
   SET reply->headers[32].type = "STRING"
   SET reply->headers[33].name = "pft_entity_status_disp"
   SET reply->headers[33].type = "STRING"
   SET reply->headers[34].name = "GRID_TOTAL"
   SET reply->headers[34].type = "STRING"
   SET reply->headers[35].name = "Preview_1"
   SET reply->headers[35].type = "STRING"
   SET reply->headers[36].name = "Heading_1"
   SET reply->headers[36].type = "STRING"
   SET reply->headers[37].name = "Heading_2"
   SET reply->headers[37].type = "STRING"
   SET reply->headers[38].name = "Heading_3"
   SET reply->headers[38].type = "STRING"
   SET reply->headers[39].name = "Heading_4"
   SET reply->headers[39].type = "STRING"
   SET reply->headers[40].name = "Value_1"
   SET reply->headers[40].type = "STRING"
   SET reply->headers[41].name = "Value_2"
   SET reply->headers[41].type = "STRING"
   SET reply->headers[42].name = "Value_3"
   SET reply->headers[42].type = "STRING"
   SET reply->headers[43].name = "Value_4"
   SET reply->headers[43].type = "STRING"
   SET reply->headers[44].name = "Preview_Pane"
   SET reply->headers[44].type = "STRING"
   SET reply->headers[45].name = "HP Phone Number"
   SET reply->headers[45].type = "STRING"
   SET reply->headers[46].name = "Health Plan Contact"
   SET reply->headers[46].type = "STRING"
   SET reply->headers[47].name = "HP Contact Phone Number"
   SET reply->headers[47].type = "STRING"
   SET reply->headers[48].name = "Group Name"
   SET reply->headers[48].type = "STRING"
   SET reply->headers[49].name = "Group Number"
   SET reply->headers[49].type = "STRING"
   SET reply->headers[50].name = "Member Number"
   SET reply->headers[50].type = "STRING"
   SET reply->headers[51].name = "Policy Number"
   SET reply->headers[51].type = "STRING"
   SET reply->headers[52].name = "Authorization Number"
   SET reply->headers[52].type = "STRING"
   SET reply->headers[53].name = "Corsp_Activity_Id"
   SET reply->headers[53].type = "STRING"
   SET reply->headers[54].name = "Item Status"
   SET reply->headers[54].type = "STRING"
   SET reply->headers[55].name = "Transmission Date"
   SET reply->headers[55].type = "STRING"
   SET reply->headers[56].name = "Remark Description"
   SET reply->headers[56].type = "STRING"
   SET reply->headers[57].name = "Payor Control Number"
   SET reply->headers[57].type = "STRING"
   SET reply->headers[58].name = "PFT_QUEUE_ITEM_ID"
   SET reply->headers[58].type = "STRING"
   SET reply->headers[59].name = "Facility"
   SET reply->headers[59].type = "STRING"
   SET reply->headers[60].name = "Building"
   SET reply->headers[60].type = "STRING"
   SET reply->headers[61].name = "Nurse Unit"
   SET reply->headers[61].type = "STRING"
   SET reply->headers[62].name = "Encounter Balance"
   SET reply->headers[62].type = "CURRENCY"
   SET reply->headers[63].name = "BILL_VRSN_NBR"
   SET reply->headers[63].type = "STRING"
   SET reply->headers[64].name = "Financial Number"
   SET reply->headers[64].type = "STRING"
   SET reply->headers[65].name = "Expected Contractual Adjustment"
   SET reply->headers[65].type = "CURRENCY"
   SET reply->headers[66].name = "Actual Contractual Adjustment"
   SET reply->headers[66].type = "CURRENCY"
   SET reply->headers[67].name = "Calculated Variance"
   SET reply->headers[67].type = "CURRENCY"
   RETURN
 END ;Subroutine
 SUBROUTINE getdata(_null)
   DECLARE x = i2 WITH noconstant(0)
   DECLARE dpatientcd = f8 WITH noconstant(0.0)
   DECLARE priority_seq = i4 WITH noconstant(0)
   DECLARE lrowcnt = i4 WITH noconstant(0)
   DECLARE type_cd = f8 WITH public, constant(getcodevalue(24689,"PATIENT",0))
   DECLARE guar_cd = f8 WITH public, constant(getcodevalue(351,"DEFGUAR",0))
   DECLARE ssn_type = f8 WITH public, constant(getcodevalue(4,"SSN",0))
   DECLARE comment_code = f8 WITH public, constant(getcodevalue(18669,"COMMENT",0))
   DECLARE billing_code = f8 WITH public, constant(getcodevalue(43,"BILLING",0))
   DECLARE auth_code = f8 WITH public, constant(getcodevalue(14949,"AUTH",0))
   DECLARE home_address_cd = f8 WITH public, constant(getcodevalue(212,"HOME",0))
   DECLARE home_phone_cd = f8 WITH public, constant(getcodevalue(43,"HOME",0))
   DECLARE business_phone_cd = f8 WITH public, constant(getcodevalue(43,"BUSINESS",0))
   DECLARE dtechdenialcd = f8 WITH public, constant(getcodevalue(29321,"TECHDENIAL",0))
   DECLARE dfinnbrcd = f8 WITH public, constant(getcodevalue(319,"FIN NBR",0))
   DECLARE dexpected = f8 WITH public, noconstant(0.0)
   DECLARE dactual = f8 WITH public, noconstant(0.0)
   DECLARE dvariance = f8 WITH public, noconstant(0.0)
   DECLARE dexpctdreimburse = f8 WITH public, constant(getcodevalue(20549,"EXP REIM ADJ",0))
   DECLARE dreversal = f8 WITH public, constant(getcodevalue(18937,"REVERSAL",0))
   DECLARE dadjust = f8 WITH public, constant(getcodevalue(18649,"ADJUST",0))
   DECLARE dcontract = f8 WITH public, constant(getcodevalue(20549,"CONTALLOWADJ",0))
   SET reply->status_data.status = "F"
   SELECT INTO "nl:"
    person_name = substring(1,25,p.name_full_formatted), bill_number = substring(1,10,br
     .bill_nbr_disp), bill_status = uar_get_code_display(br.bill_status_cd),
    media_type = uar_get_code_display(br.media_type_cd), bill_type = uar_get_code_display(br
     .bill_type_cd), bill_balance = format((abs(bohp.total_billed_amount) - abs(bohp
      .total_paid_amount)),"########.##"),
    account_id = substring(1,15,a.ext_acct_id_txt), account_bal = format(abs(a.acct_balance),
     "########.##"), health_plan = substring(1,50,hp.plan_name),
    encntr_discharge_date = format(e.disch_dt_tm,cclfmt->shortdate4yr), encntr_reg_date = format(
     cnvtdatetimeutc(pm_inp_admit_dt_tm(e.encntr_id,1,sysdate)),cclfmt->shortdate4yr),
    encntr_med_service = uar_get_code_display(e.med_service_cd),
    encntr_fin_class = uar_get_code_display(e.financial_class_cd), bill_status_reason =
    uar_get_code_display(br.bill_status_reason_cd), bill_templ_name = substring(1,25,bt
     .bill_templ_name),
    gen_date = br.gen_dt_tm, media_sub_type = uar_get_code_display(br.media_sub_type_cd),
    priority_seq = bohp.priority_seq,
    bo_status = uar_get_code_display(bo.bo_status_cd), group_name = substring(1,25,epr.group_name),
    group_nbr = substring(1,10,epr.group_nbr),
    member_nbr = substring(1,10,epr.member_nbr), item_status = uar_get_code_display(pqi
     .item_status_cd), transmission_date = br.gen_dt_tm,
    policy_number = substring(1,25,epr.policy_nbr), locfacility = uar_get_code_display(e
     .loc_facility_cd), locbuilding = uar_get_code_display(e.loc_building_cd),
    locnurseunit = uar_get_code_display(e.loc_nurse_unit_cd), finnbralias = substring(1,200,ea.alias)
    FROM pft_queue_item pqi,
     bill_rec br,
     bill_templ bt,
     bill_reltn bre,
     bo_hp_reltn bohp,
     health_plan hp,
     benefit_order bo,
     pft_encntr pe,
     encounter e,
     person p,
     account a,
     encntr_plan_reltn epr,
     encntr_alias ea,
     (dummyt d1  WITH seq = size(request->objarray,5))
    PLAN (d1)
     JOIN (pqi
     WHERE (pqi.pft_queue_item_id=request->objarray[d1.seq].queue_item_id))
     JOIN (br
     WHERE br.corsp_activity_id=pqi.corsp_activity_id
      AND (br.bill_vrsn_nbr=
     (SELECT
      max(br2.bill_vrsn_nbr)
      FROM bill_rec br2
      WHERE br2.corsp_activity_id=br.corsp_activity_id)))
     JOIN (bt
     WHERE bt.bill_templ_id=br.bill_templ_id)
     JOIN (bre
     WHERE bre.corsp_activity_id=br.corsp_activity_id
      AND bre.parent_entity_name="BO_HP_RELTN"
      AND bre.active_ind=1
      AND bre.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bre.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bohp
     WHERE bohp.bo_hp_reltn_id=bre.parent_entity_id
      AND bohp.active_ind=1
      AND bohp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bohp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (hp
     WHERE hp.health_plan_id=bohp.health_plan_id)
     JOIN (bo
     WHERE bo.benefit_order_id=bohp.benefit_order_id)
     JOIN (pe
     WHERE pe.pft_encntr_id=bo.pft_encntr_id)
     JOIN (e
     WHERE e.encntr_id=pe.encntr_id)
     JOIN (p
     WHERE p.person_id=e.person_id)
     JOIN (a
     WHERE a.acct_id=pe.acct_id)
     JOIN (epr
     WHERE epr.encntr_plan_reltn_id=bohp.encntr_plan_reltn_id)
     JOIN (ea
     WHERE ea.encntr_id=outerjoin(epr.encntr_id)
      AND ea.encntr_alias_type_cd=outerjoin(dfinnbrcd))
    ORDER BY pqi.pft_queue_item_id
    HEAD REPORT
     x = 0
     IF (pqi.pft_entity_status_cd=dtechdenialcd)
      mn_deny = 1
     ENDIF
    HEAD pqi.pft_queue_item_id
     x = (x+ 1)
     IF (mod(x,100)=1)
      stat = alterlist(reply->rows,(x+ 99)), stat = alterlist(temp->rows,(x+ 99))
     ENDIF
     stat = alterlist(temp->rows[x].identifiers,12), stat = alterlist(reply->rows[x].identifiers,12),
     temp->rows[x].identifiers[1].name = "epr_id",
     temp->rows[x].identifiers[1].value = epr.encntr_plan_reltn_id, temp->rows[x].identifiers[2].name
      = "HEALTHPLAN_ID", temp->rows[x].identifiers[2].value = hp.health_plan_id,
     reply->rows[x].identifiers[1].name = "ACCT_ID", reply->rows[x].identifiers[1].value = cnvtstring
     (pe.acct_id), reply->rows[x].identifiers[2].name = "PFT_ENCNTR_ID",
     reply->rows[x].identifiers[2].value = cnvtstring(pe.pft_encntr_id), reply->rows[x].identifiers[3
     ].name = "ENCNTR_ID", reply->rows[x].identifiers[3].value = cnvtstring(pe.encntr_id),
     reply->rows[x].identifiers[4].name = "PFT_QUEUE_ITEM_ID", reply->rows[x].identifiers[4].value =
     cnvtstring(pqi.pft_queue_item_id), reply->rows[x].identifiers[5].name = "CORSP_ACTIVITY_ID",
     reply->rows[x].identifiers[5].value = cnvtstring(br.corsp_activity_id), reply->rows[x].
     identifiers[6].name = "BILL_VRSN_NBR", reply->rows[x].identifiers[6].value = cnvtstring(br
      .bill_vrsn_nbr),
     reply->rows[x].identifiers[7].name = "BILL_TYPE_CD", reply->rows[x].identifiers[7].value =
     cnvtstring(br.bill_type_cd), reply->rows[x].identifiers[8].name = "BILL_TYPE_CDF",
     reply->rows[x].identifiers[8].value = uar_get_code_meaning(br.bill_type_cd), reply->rows[x].
     identifiers[9].name = "CONTRIBUTOR_SYSTEM_CD", reply->rows[x].identifiers[9].value = cnvtstring(
      pqi.contributor_system_cd),
     reply->rows[x].identifiers[10].name = "CONTRIBUTOR_SYSTEM_DISPLAY", reply->rows[x].identifiers[
     10].value = uar_get_code_meaning(pqi.contributor_system_cd), reply->rows[x].identifiers[11].name
      = "PFT_ENTITY_STATUS_DISPLAY",
     reply->rows[x].identifiers[11].value = uar_get_code_meaning(pqi.pft_entity_status_cd), reply->
     rows[x].identifiers[12].name = "PERSON_ID", reply->rows[x].identifiers[12].value = cnvtstring(p
      .person_id),
     stat = alterlist(reply->rows[x].columns,64), reply->rows[x].columns[63].value = cnvtstring(br
      .bill_vrsn_nbr), reply->rows[x].columns[64].value = finnbralias,
     reply->rows[x].columns[1].value = person_name, reply->rows[x].columns[7].value = bill_number,
     reply->rows[x].columns[8].value = bill_status,
     reply->rows[x].columns[9].value = media_type, reply->rows[x].columns[10].value = bill_balance,
     reply->rows[x].columns[11].value = account_id
     IF (a.dr_cr_flag=2)
      reply->rows[x].columns[12].value = build("-",account_bal)
     ELSE
      reply->rows[x].columns[12].value = account_bal
     ENDIF
     reply->rows[x].columns[19].value = health_plan, reply->rows[x].columns[20].value = bill_type,
     reply->rows[x].columns[21].value = bo_status,
     reply->rows[x].columns[22].value = cnvtstring(datetimediff(cnvtdatetime(curdate,curtime3),br
       .submit_dt_tm,1)), reply->rows[x].columns[23].value = encntr_discharge_date, reply->rows[x].
     columns[24].value = encntr_reg_date,
     reply->rows[x].columns[25].value = bill_status_reason, reply->rows[x].columns[26].value =
     bill_templ_name, reply->rows[x].columns[27].value = format(gen_date,cclfmt->shortdate4yr),
     reply->rows[x].columns[28].value = encntr_fin_class, reply->rows[x].columns[29].value =
     encntr_med_service, reply->rows[x].columns[30].value = cnvtstring(datetimediff(cnvtdatetime(
        curdate,curtime3),e.disch_dt_tm,1)),
     reply->rows[x].columns[31].value = media_sub_type
     CASE (priority_seq)
      OF 1:
       reply->rows[x].columns[32].value = "Primary"
      OF 2:
       reply->rows[x].columns[32].value = "Secondary"
      OF 3:
       reply->rows[x].columns[32].value = "Tertiary"
      ELSE
       reply->rows[x].columns[32].value = cnvtstring(priority_seq)
     ENDCASE
     reply->rows[x].columns[33].value = trim(uar_get_code_display(pqi.pft_entity_status_cd),3), reply
     ->rows[x].columns[34].value = reply->rows[x].columns[10].value, reply->rows[x].columns[36].value
      = "Claim Number:",
     reply->rows[x].columns[37].value = "Claim Status:", reply->rows[x].columns[38].value =
     "Information:", reply->rows[x].columns[39].value = "Claim Balance:",
     reply->rows[x].columns[40].value = trim(bill_number,3), reply->rows[x].columns[41].value = trim(
      bill_status,3), reply->rows[x].columns[42].value = "Claim Comments",
     reply->rows[x].columns[43].value = format((abs(bohp.total_billed_amount) - abs(bohp
       .total_paid_amount)),"########.##;$,"), reply->rows[x].columns[48].value = group_name, reply->
     rows[x].columns[49].value = group_nbr,
     reply->rows[x].columns[50].value = member_nbr, reply->rows[x].columns[52].value = policy_number,
     reply->rows[x].columns[53].value = cnvtstring(br.corsp_activity_id),
     reply->rows[x].columns[54].value = item_status, reply->rows[x].columns[55].value = format(
      transmission_date,cclfmt->shortdate4yr), reply->rows[x].columns[58].value = cnvtstring(pqi
      .pft_queue_item_id),
     reply->rows[x].columns[59].value = locfacility, reply->rows[x].columns[60].value = locbuilding,
     reply->rows[x].columns[61].value = locnurseunit,
     reply->rows[x].columns[62].value = cnvtstring(pe.balance)
    DETAIL
     oof = 0
    FOOT REPORT
     IF (mod(x,100) != 0)
      stat = alterlist(reply->rows,x)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "Z"
   ELSE
    SELECT INTO "nl:"
     contact_phone_number = cnvtphone(ph3.phone_num,ph3.phone_format_cd,0), contact = substring(1,25,
      ph3.contact), ph3_null = nullind(ph3.parent_entity_id)
     FROM phone ph3,
      (dummyt d1  WITH seq = size(temp->rows,5))
     PLAN (d1)
      JOIN (ph3
      WHERE (ph3.parent_entity_id=temp->rows[d1.seq].identifiers[2].value)
       AND ph3.parent_entity_name="HEALTH_PLAN"
       AND ph3.phone_type_cd=business_phone_cd
       AND ph3.active_ind=1
       AND ph3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     DETAIL
      reply->rows[d1.seq].columns[46].value = contact, reply->rows[d1.seq].columns[47].value =
      contact_phone_number
     WITH nocounter
    ;end select
    CALL echo("query for ph/p2/pp")
    SELECT INTO "nl:"
     guar_name = substring(1,25,p2.name_full_formatted), person_address = substring(1,30,ad
      .street_addr), guar_address = substring(1,30,ad.street_addr),
     guar_city = substring(1,15,ad.city), guar_state = substring(1,2,ad.state), guar_state2 =
     uar_get_code_display(ad.state_cd),
     guar_zipcode = substring(1,5,ad.zipcode), guar_phone = cnvtphone(ph.phone_num,ph.phone_format_cd,
      0), ph_null = nullind(ph.parent_entity_id),
     ad_null = nullind(ad.parent_entity_id), p2_null = nullind(p2.person_id), pp_null = nullind(pp
      .person_id)
     FROM person_person_reltn pp,
      person p2,
      address ad,
      phone ph,
      (dummyt d1  WITH seq = size(reply->rows,5))
     PLAN (d1)
      JOIN (pp
      WHERE pp.person_id=cnvtreal(reply->rows[d1.seq].identifiers[12].value)
       AND pp.person_reltn_type_cd=outerjoin(guar_cd)
       AND pp.active_ind=outerjoin(1)
       AND pp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND pp.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (p2
      WHERE p2.person_id=outerjoin(pp.related_person_id))
      JOIN (ad
      WHERE ad.parent_entity_id=outerjoin(p2.person_id)
       AND ad.parent_entity_name=outerjoin("PERSON")
       AND ad.address_type_cd=outerjoin(home_address_cd)
       AND ad.active_ind=outerjoin(1)
       AND ad.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ad.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
      JOIN (ph
      WHERE ph.parent_entity_id=outerjoin(p2.person_id)
       AND ph.parent_entity_name=outerjoin("PERSON")
       AND ph.phone_type_cd=outerjoin(home_phone_cd)
       AND ph.active_ind=outerjoin(1)
       AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ph.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     DETAIL
      IF (ad_null=0)
       reply->rows[d1.seq].columns[2].value = person_address, reply->rows[d1.seq].columns[14].value
        = guar_address, reply->rows[d1.seq].columns[15].value = guar_city,
       reply->rows[d1.seq].columns[17].value = guar_zipcode
      ENDIF
      IF (size(guar_state2,1) > 0)
       IF (ad_null=0)
        reply->rows[d1.seq].columns[16].value = guar_state2
       ENDIF
      ELSE
       IF (ad_null=0)
        reply->rows[d1.seq].columns[16].value = guar_state
       ENDIF
      ENDIF
      IF (ph_null=0)
       reply->rows[d1.seq].columns[18].value = guar_phone
      ENDIF
      IF (p2_null=0)
       reply->rows[d1.seq].columns[13].value = guar_name
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("query for ad1/ph1/ph2")
    SELECT INTO "nl:"
     person_city = substring(1,15,ad1.city), person_state = substring(1,2,ad1.state), person_state2
      = uar_get_code_display(ad1.state_cd),
     person_zipcode = substring(1,5,ad1.zipcode), person_phone = cnvtphone(ph1.phone_num,ph1
      .phone_format_cd,0), ad1_null = nullind(ad1.parent_entity_id),
     ph1_null = nullind(ph1.parent_entity_id)
     FROM address ad1,
      phone ph1,
      (dummyt d1  WITH seq = size(reply->rows,5))
     PLAN (d1)
      JOIN (ad1
      WHERE ad1.parent_entity_id=cnvtreal(reply->rows[d1.seq].identifiers[12].value)
       AND ad1.parent_entity_name="PERSON"
       AND ad1.address_type_cd=home_address_cd
       AND ad1.active_ind=1
       AND ad1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ad1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ph1
      WHERE ph1.parent_entity_id=outerjoin(ad1.parent_entity_id)
       AND ph1.parent_entity_name=outerjoin("PERSON")
       AND ph1.phone_type_cd=outerjoin(home_phone_cd)
       AND ph1.active_ind=outerjoin(1)
       AND ph1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ph1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     DETAIL
      IF (ad1_null=0)
       reply->rows[d1.seq].columns[3].value = person_city, reply->rows[d1.seq].columns[4].value =
       person_state
       IF (size(person_state2,1) > 0)
        reply->rows[d1.seq].columns[4].value = person_state2
       ELSE
        reply->rows[d1.seq].columns[4].value = person_state
       ENDIF
       reply->rows[d1.seq].columns[5].value = person_zipcode
      ENDIF
      IF (ph1_null=0)
       reply->rows[d1.seq].columns[6].value = person_phone
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("query for epa/au")
    SELECT INTO "nl:"
     auth_nbr = substring(1,20,au.auth_nbr), hp_phone_nbr = cnvtphone(ph2.phone_num,ph2
      .phone_format_cd,0), epa_null = nullind(epa.encntr_plan_reltn_id),
     au_null = nullind(au.authorization_id), ph2_null = nullind(ph2.parent_entity_id)
     FROM encntr_plan_auth_r epa,
      authorization au,
      phone ph2,
      (dummyt d1  WITH seq = size(reply->rows,5))
     PLAN (d1)
      JOIN (epa
      WHERE (epa.encntr_plan_reltn_id=temp->rows[d1.seq].identifiers[1].value)
       AND epa.authorization_id > 0
       AND epa.active_ind=1
       AND epa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND epa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ph2
      WHERE ph2.parent_entity_id=epa.encntr_plan_reltn_id
       AND ph2.parent_entity_name="ENCNTR_PLAN_RELTN"
       AND ph2.phone_type_cd=business_phone_cd
       AND ph2.active_ind=1
       AND ph2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (au
      WHERE au.authorization_id=outerjoin(epa.authorization_id)
       AND au.auth_type_cd=outerjoin(auth_code)
       AND au.auth_nbr > outerjoin(" ")
       AND au.active_ind=outerjoin(1))
     DETAIL
      reply->rows[d1.seq].columns[51].value = auth_nbr
      IF (ph2_null=0)
       reply->rows[d1.seq].columns[45].value = hp_phone_nbr
      ENDIF
     WITH nocounter
    ;end select
    SET reply->status_data.status = "S"
    DECLARE line = c80
    DECLARE priority = vc WITH noconstant("")
    SET x = 0
    SET lrowcnt = size(reply->rows,5)
    SET line = fillstring(80,"-")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(lrowcnt)),
      corsp_log_reltn clr,
      corsp_log cl,
      long_text lt,
      person p
     PLAN (d)
      JOIN (clr
      WHERE clr.parent_entity_id=cnvtreal(reply->rows[d.seq].identifiers[5].value)
       AND clr.parent_entity_name="BILL_RECORD"
       AND clr.bill_vrsn_nbr=cnvtint(reply->rows[d.seq].identifiers[6].value)
       AND clr.active_ind=1
       AND clr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND clr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND (clr.activity_id=
      (SELECT
       max(clr2.activity_id)
       FROM corsp_log_reltn clr2
       WHERE clr2.parent_entity_id=clr.parent_entity_id
        AND clr2.bill_vrsn_nbr=clr.bill_vrsn_nbr)))
      JOIN (cl
      WHERE cl.activity_id=clr.activity_id
       AND cl.corsp_type_cd=comment_code
       AND cl.active_ind=1)
      JOIN (lt
      WHERE lt.long_text_id=outerjoin(cl.long_text_id)
       AND lt.active_ind=outerjoin(1))
      JOIN (p
      WHERE p.person_id=cl.created_prsnl_id)
     ORDER BY clr.parent_entity_id, cnvtdatetime(cl.updt_dt_tm) DESC
     HEAD clr.parent_entity_id
      x = 0
     DETAIL
      x = (x+ 1)
      IF (cl.importance_flag=2)
       priority = " (Priority: HIGH)"
      ELSEIF (cl.importance_flag=0)
       priority = " (Priority: LOW)"
      ELSE
       priority = " (Priority: NORMAL)"
      ENDIF
      IF (x > 1)
       IF (cl.long_text_id > 0.0)
        reply->rows[d.seq].columns[35].value = concat(reply->rows[d.seq].columns[35].value,char(13),
         char(10),trim(format(cl.updt_dt_tm,";;q"))," ",
         trim(p.name_full_formatted),priority,char(13),char(10),lt.long_text,
         char(13),char(10),line), reply->rows[d.seq].columns[44].value = concat(reply->rows[d.seq].
         columns[44].value,char(13),char(10),trim(format(cl.updt_dt_tm,";;q"))," ",
         trim(p.name_full_formatted),priority,char(13),char(10),lt.long_text,
         char(13),char(10),line)
       ELSE
        reply->rows[d.seq].columns[35].value = concat(reply->rows[d.seq].columns[35].value,char(13),
         char(10),trim(format(cl.updt_dt_tm,";;q"))," ",
         trim(p.name_full_formatted),priority,char(13),char(10),cl.corsp_desc,
         char(13),char(10),line), reply->rows[d.seq].columns[44].value = concat(reply->rows[d.seq].
         columns[44].value,char(13),char(10),trim(format(cl.updt_dt_tm,";;q"))," ",
         trim(p.name_full_formatted),priority,char(13),char(10),cl.corsp_desc,
         char(13),char(10),line)
       ENDIF
      ELSE
       IF (cl.long_text_id > 0.0)
        reply->rows[d.seq].columns[35].value = concat(trim(format(cl.updt_dt_tm,";;q"))," ",trim(p
          .name_full_formatted),priority,char(13),
         char(10),lt.long_text,char(13),char(10),line), reply->rows[d.seq].columns[44].value = concat
        (trim(format(cl.updt_dt_tm,";;q"))," ",trim(p.name_full_formatted),priority,char(13),
         char(10),lt.long_text,char(13),char(10),line)
       ELSE
        reply->rows[d.seq].columns[35].value = concat(trim(format(cl.updt_dt_tm,";;q"))," ",trim(p
          .name_full_formatted),priority,char(13),
         char(10),cl.corsp_desc,char(13),char(10),line), reply->rows[d.seq].columns[44].value =
        concat(trim(format(cl.updt_dt_tm,";;q"))," ",trim(p.name_full_formatted),priority,char(13),
         char(10),cl.corsp_desc,char(13),char(10),line)
       ENDIF
      ENDIF
     WITH nocounter, maxqual(clr,1)
    ;end select
    SELECT INTO "nl:"
     expected = sum(evaluate(ptr1.dr_cr_flag,2,(ptr1.amount * - (1)),ptr1.amount)), ptr1
     .parent_entity_id
     FROM pft_trans_reltn ptr1,
      (dummyt d1  WITH seq = size(reply->rows,5))
     PLAN (d1)
      JOIN (ptr1
      WHERE ptr1.parent_entity_id=cnvtreal(reply->rows[d1.seq].columns[53].value)
       AND ptr1.pft_trans_reltn_id IN (
      (SELECT
       max(ptr.pft_trans_reltn_id)
       FROM pft_trans_reltn ptr,
        trans_log tl
       WHERE ptr1.parent_entity_id=ptr.parent_entity_id
        AND ptr.parent_entity_name="BILL"
        AND ptr.trans_type_cd=dadjust
        AND ptr.active_ind=1
        AND ptr.activity_id=tl.activity_id
        AND tl.trans_sub_type_cd=dexpctdreimburse
        AND tl.trans_reason_cd != dreversal)))
     HEAD REPORT
      mn_size = size(reply->rows,5)
     DETAIL
      stat = alterlist(reply->rows[d1.seq].columns,65), reply->rows[d1.seq].columns[65].value =
      cnvtstring(expected)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     actual = sum(evaluate(ptr1.dr_cr_flag,2,(ptr1.amount * - (1)),ptr1.amount))
     FROM pft_trans_reltn ptr1,
      (dummyt d1  WITH seq = size(reply->rows,5))
     PLAN (d1)
      JOIN (ptr1
      WHERE ptr1.parent_entity_id=cnvtreal(reply->rows[d1.seq].columns[53].value)
       AND ptr1.pft_trans_reltn_id IN (
      (SELECT
       ptr.pft_trans_reltn_id
       FROM pft_trans_reltn ptr,
        trans_log tl
       WHERE ptr.parent_entity_id=ptr1.parent_entity_id
        AND ptr.parent_entity_name="BILL"
        AND ptr.activity_id=tl.activity_id
        AND tl.trans_sub_type_cd=dcontract)))
     HEAD REPORT
      row + 0
     DETAIL
      row + 0, stat = alterlist(reply->rows[d1.seq].columns,67), reply->rows[d1.seq].columns[66].
      value = cnvtstring(actual)
      IF (cnvtreal(reply->rows[d1.seq].columns[65].value) <= 0
       AND cnvtreal(reply->rows[d1.seq].columns[66].value) >= 0)
       reply->rows[d1.seq].columns[67].value = cnvtstring((cnvtreal(reply->rows[d1.seq].columns[66].
         value)+ (cnvtreal(reply->rows[d1.seq].columns[65].value) * - (1))))
      ELSEIF (cnvtreal(reply->rows[d1.seq].columns[65].value) >= 0
       AND cnvtreal(reply->rows[d1.seq].columns[66].value) <= 0)
       reply->rows[d1.seq].columns[67].value = cnvtstring(((cnvtreal(reply->rows[d1.seq].columns[66].
         value) * - (1))+ cnvtreal(reply->rows[d1.seq].columns[65].value)))
      ELSE
       reply->rows[d1.seq].columns[67].value = cnvtstring(abs((cnvtreal(reply->rows[d1.seq].columns[
          66].value) - cnvtreal(reply->rows[d1.seq].columns[65].value))))
      ENDIF
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
   ENDIF
   CALL echorecord(reply)
   RETURN
 END ;Subroutine
 SUBROUTINE getadddata(_null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE lcheck = i4 WITH noconstant(0)
   DECLARE dtechdenialtype = f8 WITH public, constant(getcodevalue(29904,"TECHNICAL",0))
   IF (mn_deny=1)
    SELECT INTO "nl:"
     btr_null = nullind(btr.corsp_activity_id)
     FROM (dummyt d  WITH seq = size(reply->rows,5)),
      denial de,
      pft_denial_code_ref pdc,
      batch_trans_file btr
     PLAN (d)
      JOIN (de
      WHERE de.corsp_activity_id=cnvtreal(reply->rows[d.seq].identifiers[5].value)
       AND de.bill_vrsn_nbr=cnvtreal(reply->rows[d.seq].identifiers[6].value)
       AND de.active_ind=1)
      JOIN (pdc
      WHERE pdc.denial_cd=de.denial_reason_cd
       AND pdc.denial_type_cd=dtechdenialtype)
      JOIN (btr
      WHERE btr.corsp_activity_id=outerjoin(de.corsp_activity_id)
       AND btr.bill_vrsn_nbr=outerjoin(de.bill_vrsn_nbr)
       AND btr.active_ind=outerjoin(1))
     ORDER BY d.seq
     HEAD d.seq
      CALL echo("qualified in detail")
      IF (lcheck=0)
       lcheck = 1, reply->rows[d.seq].columns[56].value = uar_get_code_display(de.denial_reason_cd)
       IF (btr_null=0)
        reply->rows[d.seq].columns[57].value = btr.payor_cntrl_nbr_txt
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN
 END ;Subroutine
#exit_script
END GO
