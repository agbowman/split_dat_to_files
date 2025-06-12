CREATE PROGRAM bhs_med_recon_discharge
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
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
  SET request->visit[1].encntr_id = 29788168
  SET request->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 FREE RECORD med_recon_request
 RECORD med_recon_request(
   1 recon_type = c1
   1 encntr_id = f8
   1 pop1[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 cki = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 clinical_display_line = vc
     2 multum[*]
       3 class_1 = vc
       3 class_2 = vc
       3 class_3 = vc
     2 dose = vc
     2 dose_unit = f8
     2 volume_dose = vc
     2 volume_dose_unit = f8
     2 frequency = f8
     2 prn_ind = i2
     2 prn_reason = vc
   1 pop2[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 cki = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 clinical_display_line = vc
     2 multum[*]
       3 class_1 = vc
       3 class_2 = vc
       3 class_3 = vc
     2 dose = vc
     2 dose_unit = f8
     2 volume_dose = vc
     2 volume_dose_unit = f8
     2 frequency = f8
     2 prn_ind = i2
     2 prn_reason = vc
 )
 SET med_recon_request->recon_type = "D"
 SET med_recon_request->encntr_id = request->visit[1].encntr_id
 DECLARE pharmacy_act_type_cd = f8
 DECLARE ordered_order_status_cd = f8
 SET pharmacy_act_type_cd = uar_get_code_by("DISPLAYKEY",106,"PHARMACY")
 SET ordered_order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 DECLARE date_to_check = dq8
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
  DETAIL
   date_to_check = cnvtlookahead("1D",e.reg_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   order_action oa
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (o
   WHERE o.person_id=e.person_id
    AND o.orig_ord_as_flag IN (1, 2)
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd=pharmacy_act_type_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm < cnvtdatetime(date_to_check)
    AND oa.order_status_cd=ordered_order_status_cd
    AND  NOT ( EXISTS (
   (SELECT
    oa2.order_id
    FROM order_action oa2
    WHERE oa2.order_id=oa.order_id
     AND oa2.action_dt_tm > oa.action_dt_tm
     AND oa2.action_dt_tm < cnvtdatetime(date_to_check)))))
  ORDER BY o.catalog_cd, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(med_recon_request->pop1,(cnt+ 9))
   ENDIF
   med_recon_request->pop1[cnt].order_id = o.order_id, med_recon_request->pop1[cnt].catalog_cd = o
   .catalog_cd, med_recon_request->pop1[cnt].cki = o.cki
   IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
    med_recon_request->pop1[cnt].order_mnemonic = trim(o.hna_order_mnemonic,3)
   ELSE
    med_recon_request->pop1[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   med_recon_request->pop1[cnt].clinical_display_line = o.clinical_display_line
  FOOT REPORT
   stat = alterlist(med_recon_request->pop1,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(med_recon_request->pop1,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=med_recon_request->pop1[d.seq].order_id)
    AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT",
   "FREETXTDOSE", "SPECINX", "SCH/PRN", "PRNREASON"))
  DETAIL
   IF (od.oe_field_meaning="VOLUMEDOSE")
    med_recon_request->pop1[d.seq].volume_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="FREETXTDOSE"
    AND od.oe_field_display_value != "See Instructions")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="SPECINX")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    med_recon_request->pop1[d.seq].volume_dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    med_recon_request->pop1[d.seq].dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="FREQ")
    med_recon_request->pop1[d.seq].frequency = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="SCH/PRN"
    AND trim(od.oe_field_display_value)="Yes")
    med_recon_request->pop1[d.seq].prn_ind = 1
   ELSEIF (od.oe_field_meaning="PRNREASON")
    med_recon_request->pop1[d.seq].prn_reason = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE cnt = i4
 SELECT INTO "nl:"
  FROM orders o,
   encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (o
   WHERE o.person_id=e.person_id
    AND o.orig_ord_as_flag IN (1, 2)
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd=pharmacy_act_type_cd
    AND ((o.order_status_cd+ 0)=2550))
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(med_recon_request->pop2,(cnt+ 9))
   ENDIF
   med_recon_request->pop2[cnt].order_id = o.order_id, med_recon_request->pop2[cnt].catalog_cd = o
   .catalog_cd, med_recon_request->pop2[cnt].cki = o.cki
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    med_recon_request->pop2[cnt].order_mnemonic = o.order_mnemonic
   ELSE
    med_recon_request->pop2[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic)," (",trim(o
      .hna_order_mnemonic),")")
   ENDIF
   med_recon_request->pop2[cnt].clinical_display_line = o.clinical_display_line
  FOOT REPORT
   stat = alterlist(med_recon_request->pop2,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(med_recon_request->pop2,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=med_recon_request->pop2[d.seq].order_id)
    AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT",
   "FREETXTDOSE", "SPECINX", "SCH/PRN", "PRNREASON"))
  DETAIL
   IF (od.oe_field_meaning="VOLUMEDOSE")
    med_recon_request->pop2[d.seq].volume_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    med_recon_request->pop2[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    med_recon_request->pop2[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    med_recon_request->pop2[d.seq].volume_dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    med_recon_request->pop2[d.seq].dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="FREQ")
    med_recon_request->pop2[d.seq].frequency = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="SCH/PRN"
    AND trim(od.oe_field_display_value)="Yes")
    med_recon_request->pop2[d.seq].prn_ind = 1
   ELSEIF (od.oe_field_meaning="PRNREASON")
    med_recon_request->pop2[d.seq].prn_reason = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE bhs_med_recon_smart_temp  WITH replace(request,med_recon_request)
END GO
