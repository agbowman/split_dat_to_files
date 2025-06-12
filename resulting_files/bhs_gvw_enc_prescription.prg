CREATE PROGRAM bhs_gvw_enc_prescription
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE mf_pharm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD pharmrequest
 RECORD pharmrequest(
   1 active_status_flag = i2
   1 transmit_capability_flag = i2
   1 ids[*]
     2 id = vc
 )
 FREE RECORD pharmreply
 RECORD pharmreply(
   1 pharmacies[*]
     2 id = vc
     2 version_dt_tm = dq8
     2 pharmacy_name = vc
     2 pharmacy_number = vc
     2 active_begin_dt_tm = dq8
     2 active_end_dt_tm = dq8
     2 pharmacy_contributions[*]
       3 contributor_system_cd = f8
       3 version_dt_tm = dq8
       3 contribution_id = vc
       3 pharmacy_name = vc
       3 pharmacy_number = vc
       3 active_begin_dt_tm = dq8
       3 active_end_dt_tm = dq8
       3 addresses[*]
         4 type_cd = f8
         4 type_seq = i2
         4 street_address_lines[*]
           5 street_address_line = vc
         4 city = vc
         4 state = vc
         4 postal_code = vc
         4 country = vc
         4 cross_street = vc
       3 telecom_addresses[*]
         4 type_cd = f8
         4 type_seq = i2
         4 contact_method_cd = f8
         4 value = vc
         4 extension = vc
       3 service_level = vc
       3 partner_account = vc
       3 service_levels[1]
         4 new_rx_ind = i2
         4 ref_req_ind = i2
         4 epcs_ind = i2
       3 specialties[1]
         4 mail_order_ind = i2
         4 retail_ind = i2
         4 specialty_ind = i2
         4 twenty_four_hour_ind = i2
         4 long_term_ind = i2
     2 primary_business_address
       3 type_cd = f8
       3 type_seq = i2
       3 street_address_lines[*]
         4 street_address_line = vc
       3 city = vc
       3 state = vc
       3 postal_code = vc
       3 country = vc
       3 cross_street = vc
     2 primary_business_telephone
       3 type_cd = f8
       3 type_seq = f8
       3 contact_method_cd = f8
       3 value = vc
       3 extension = vc
     2 primary_business_fax
       3 type_cd = f8
       3 type_seq = f8
       3 contact_method_cd = f8
       3 value = vc
       3 extension = vc
     2 primary_business_email
       3 type_cd = f8
       3 type_seq = f8
       3 contact_method_cd = f8
       3 value = vc
       3 extension = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pharmrequest->active_status_flag = 1
 SET pharmrequest->transmit_capability_flag = 1
 SET stat = alterlist(pharmrequest->ids,1)
 FREE RECORD prsn_orders
 RECORD prsn_orders(
   1 l_cnt = i4
   1 list[*]
     2 f_order_id = f8
     2 s_order_name = vc
     2 s_order_disp_line = vc
     2 s_volume_dose = vc
     2 s_volume_dose_unit = vc
     2 s_str_dose = vc
     2 s_str_dose_unit = vc
     2 s_rxroute = vc
     2 s_freq = vc
     2 s_disp_quantity = vc
     2 s_disp_quantity_unit = vc
     2 s_refill_nbr = vc
     2 s_spec_instr = vc
     2 s_routing_pharm_name = vc
     2 s_routing_pharm_id = vc
     2 s_pharm_addr1 = vc
     2 s_pharm_addr2 = vc
     2 s_pharm_city = vc
     2 s_pharm_state = vc
     2 s_pharm_zip = vc
     2 s_pharm_phone = vc
     2 s_gen_order_disp_line = vc
 ) WITH protect
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=request->person[1].person_id)
   AND (o.encntr_id=request->visit[1].encntr_id)
   AND o.active_ind=1
   AND o.order_status_cd IN (mf_ordered_cd, mf_inprocess_cd, mf_pending_cd)
   AND o.catalog_type_cd=mf_pharm_cd
   AND o.orig_ord_as_flag=1
   AND o.template_order_flag IN (0, 1)
  ORDER BY uar_get_code_display(o.catalog_cd), o.orig_order_dt_tm DESC
  HEAD REPORT
   prsn_orders->l_cnt = 0
  DETAIL
   prsn_orders->l_cnt += 1, stat = alterlist(prsn_orders->list,prsn_orders->l_cnt)
   IF (cnvtupper(trim(o.order_mnemonic)) != cnvtupper(trim(o.ordered_as_mnemonic))
    AND size(trim(o.ordered_as_mnemonic)) != 0)
    prsn_orders->list[prsn_orders->l_cnt].s_order_name = concat(trim(o.order_mnemonic)," (",trim(o
      .ordered_as_mnemonic),")")
   ELSE
    prsn_orders->list[prsn_orders->l_cnt].s_order_name = o.order_mnemonic
   ENDIF
   prsn_orders->list[prsn_orders->l_cnt].f_order_id = o.order_id, prsn_orders->list[prsn_orders->
   l_cnt].s_order_disp_line = o.clinical_display_line
  WITH nocounter
 ;end select
 IF ((prsn_orders->l_cnt > 0))
  FOR (l_idx = 1 TO prsn_orders->l_cnt)
    SELECT INTO "nl:"
     FROM order_detail od
     PLAN (od
      WHERE (od.order_id=prsn_orders->list[l_idx].f_order_id)
       AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE", "STRENGTHDOSEUNIT",
      "RXROUTE",
      "FREQ", "DISPENSEQTY", "DISPENSEQTYUNIT", "NBRREFILLS", "SPECINX",
      "ROUTINGPHARMACYNAME", "ROUTINGPHARMACYID"))
     ORDER BY od.oe_field_meaning, od.action_sequence DESC
     HEAD od.oe_field_meaning
      IF (od.oe_field_meaning="VOLUMEDOSE")
       prsn_orders->list[l_idx].s_volume_dose = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
       prsn_orders->list[l_idx].s_volume_dose_unit = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
       prsn_orders->list[l_idx].s_str_dose = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
       prsn_orders->list[l_idx].s_str_dose_unit = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="RXROUTE")
       prsn_orders->list[l_idx].s_rxroute = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="FREQ")
       prsn_orders->list[l_idx].s_freq = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="DISPENSEQTY")
       prsn_orders->list[l_idx].s_disp_quantity = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="DISPENSEQTYUNIT")
       prsn_orders->list[l_idx].s_disp_quantity_unit = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="NBRREFILLS")
       prsn_orders->list[l_idx].s_refill_nbr = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="SPECINX")
       prsn_orders->list[l_idx].s_spec_instr = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="ROUTINGPHARMACYNAME")
       prsn_orders->list[l_idx].s_routing_pharm_name = trim(od.oe_field_display_value,3)
      ELSEIF (od.oe_field_meaning="ROUTINGPHARMACYID")
       prsn_orders->list[l_idx].s_routing_pharm_id = trim(od.oe_field_display_value,3), ml_idx1 =
       locateval(ml_idx2,1,size(pharmrequest->ids,5),trim(od.oe_field_display_value,3),pharmrequest->
        ids[ml_idx2].id)
       IF (ml_idx1=0)
        ml_idx1 = (size(pharmrequest->ids,5)+ 1), stat = alterlist(pharmrequest->ids,ml_idx1),
        pharmrequest->ids[ml_idx1].id = trim(od.oe_field_display_value)
       ENDIF
      ENDIF
     FOOT REPORT
      IF (size(trim(prsn_orders->list[l_idx].s_volume_dose,3)) > 0
       AND size(trim(prsn_orders->list[l_idx].s_volume_dose_unit,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].s_volume_dose,
        " ",prsn_orders->list[l_idx].s_volume_dose_unit)
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_str_dose,3)) > 0
       AND size(trim(prsn_orders->list[l_idx].s_str_dose_unit,3)) > 0)
       IF (size(trim(prsn_orders->list[l_idx].s_gen_order_disp_line,3)) > 0)
        prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
         s_gen_order_disp_line," = ",prsn_orders->list[l_idx].s_str_dose," ",prsn_orders->list[l_idx]
         .s_str_dose_unit)
       ELSE
        prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].s_str_dose,
         " ",prsn_orders->list[l_idx].s_str_dose_unit)
       ENDIF
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_rxroute,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
        s_gen_order_disp_line,", ",prsn_orders->list[l_idx].s_rxroute)
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_freq,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
        s_gen_order_disp_line,", ",prsn_orders->list[l_idx].s_freq)
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_disp_quantity,3)) > 0
       AND size(trim(prsn_orders->list[l_idx].s_disp_quantity_unit,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
        s_gen_order_disp_line,", # ",prsn_orders->list[l_idx].s_disp_quantity," ",prsn_orders->list[
        l_idx].s_disp_quantity_unit)
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_refill_nbr,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
        s_gen_order_disp_line,", ",prsn_orders->list[l_idx].s_refill_nbr," Refills")
      ENDIF
      IF (size(trim(prsn_orders->list[l_idx].s_spec_instr,3)) > 0)
       prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
        s_gen_order_disp_line,", ",prsn_orders->list[l_idx].s_spec_instr)
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF (size(pharmrequest->ids,5) > 0)
  SET stat = tdbexecute(3202004,3202004,3202501,"REC",pharmrequest,
   "REC",pharmreply)
  FOR (l_idx = 1 TO prsn_orders->l_cnt)
    IF (size(trim(prsn_orders->list[l_idx].s_routing_pharm_id,3)) > 0)
     SET ml_idx1 = locateval(ml_idx2,1,size(pharmreply->pharmacies,5),trim(prsn_orders->list[l_idx].
       s_routing_pharm_id,3),trim(pharmreply->pharmacies[ml_idx2].id,3))
     IF (ml_idx1 > 0)
      SET prsn_orders->list[l_idx].s_pharm_phone = trim(pharmreply->pharmacies[ml_idx1].
       primary_business_telephone.value,3)
      SET prsn_orders->list[l_idx].s_pharm_city = trim(pharmreply->pharmacies[ml_idx1].
       primary_business_address.city,3)
      SET prsn_orders->list[l_idx].s_pharm_state = trim(pharmreply->pharmacies[ml_idx1].
       primary_business_address.state,3)
      SET prsn_orders->list[l_idx].s_pharm_zip = trim(substring(1,5,trim(pharmreply->pharmacies[
         ml_idx1].primary_business_address.postal_code,3)),3)
      IF (size(pharmreply->pharmacies[ml_idx1].primary_business_address.street_address_lines,5) > 0)
       SET prsn_orders->list[l_idx].s_pharm_addr1 = trim(pharmreply->pharmacies[ml_idx1].
        primary_business_address.street_address_lines[1].street_address_line,3)
      ENDIF
      IF (size(pharmreply->pharmacies[ml_idx1].primary_business_address.street_address_lines,5) > 1)
       SET prsn_orders->list[l_idx].s_pharm_addr1 = trim(pharmreply->pharmacies[ml_idx1].
        primary_business_address.street_address_lines[2].street_address_line,3)
      ENDIF
     ENDIF
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_routing_pharm_name,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line,", ",trim(prsn_orders->list[l_idx].s_routing_pharm_name,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_addr1,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line,", ",trim(prsn_orders->list[l_idx].s_pharm_addr1,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_addr2,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line," ",trim(prsn_orders->list[l_idx].s_pharm_addr2,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_city,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line," ",trim(prsn_orders->list[l_idx].s_pharm_city,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_state,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line,", ",trim(prsn_orders->list[l_idx].s_pharm_state,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_zip,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line," ",trim(prsn_orders->list[l_idx].s_pharm_zip,3))
    ENDIF
    IF (size(trim(prsn_orders->list[l_idx].s_pharm_phone,3)) > 0)
     SET prsn_orders->list[l_idx].s_gen_order_disp_line = concat(prsn_orders->list[l_idx].
      s_gen_order_disp_line," ",trim(prsn_orders->list[l_idx].s_pharm_phone,3))
    ENDIF
  ENDFOR
 ENDIF
 SET s_text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18"
 IF ((prsn_orders->l_cnt > 0))
  FOR (l_idx = 1 TO prsn_orders->l_cnt)
    SET s_text = concat(s_text," ",prsn_orders->list[l_idx].s_order_name," - ",prsn_orders->list[
     l_idx].s_gen_order_disp_line,
     " \par ")
  ENDFOR
 ELSE
  SET s_text = concat(s_text," No new medications prescribed at time of discharge. \par ")
 ENDIF
 SET s_text = concat(s_text,"}")
 SET reply->text = s_text
 CALL echorecord(reply)
END GO
