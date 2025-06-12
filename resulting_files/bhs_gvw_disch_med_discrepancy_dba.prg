CREATE PROGRAM bhs_gvw_disch_med_discrepancy:dba
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
  SET request->visit[1].encntr_id = 36639150.00
  SET request->output_device = "MINE"
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
     2 order_dt = vc
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
 FREE RECORD problems
 RECORD problems(
   1 list[*]
     2 order_mnemonic = vc
     2 dose = vc
     2 dose_unit = f8
     2 volume_dose = vc
     2 volume_dose_unit = f8
     2 frequency = f8
     2 comment = vc
     2 prn_ind = i2
     2 prn_reason = vc
     2 order_dt = vc
 )
 DECLARE prob_cnt = i4
 SET prob_cnt = 0
 RECORD temp(
   1 row_cnt = i2
   1 row[*]
     2 col[*]
     2 data_string = vc
     2 data_double = f8
     2 data_dt_tm = dq8
 )
 SET med_recon_request->recon_type = "A"
 SET med_recon_request->encntr_id = request->visit[1].encntr_id
 DECLARE pharmacy_act_type_cd = f8
 DECLARE ordered_order_status_cd = f8
 DECLARE intermittent_type_cd = f8
 SET pharmacy_act_type_cd = uar_get_code_by("DISPLAYKEY",106,"PHARMACY")
 SET ordered_order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET intermittent_type_cd = uar_get_code_by("MEANING",18309,"INTERMITTENT")
 SET durable_equip = uar_get_code_by("DISPLAYKEY",200,"DURABLEMEDICALEQUIPMENT")
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   mltm_category_drug_xref mcdx,
   mltm_drug_categories mdc1,
   mltm_category_sub_xref mcsx1,
   mltm_drug_categories mdc2,
   mltm_category_sub_xref mcsx2,
   mltm_drug_categories mdc3
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (o
   WHERE o.person_id=e.person_id
    AND o.orig_ord_as_flag=0
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd=pharmacy_act_type_cd
    AND ((o.order_status_cd+ 0)=2550)
    AND o.iv_ind=0
    AND o.catalog_cd != durable_equip
    AND o.med_order_type_cd != intermittent_type_cd)
   JOIN (mcdx
   WHERE mcdx.drug_identifier=outerjoin(substring(9,6,o.cki)))
   JOIN (mdc1
   WHERE mdc1.multum_category_id=outerjoin(mcdx.multum_category_id))
   JOIN (mcsx1
   WHERE mcsx1.sub_category_id=outerjoin(mdc1.multum_category_id))
   JOIN (mdc2
   WHERE mdc2.multum_category_id=outerjoin(mcsx1.multum_category_id))
   JOIN (mcsx2
   WHERE mcsx2.sub_category_id=outerjoin(mdc2.multum_category_id))
   JOIN (mdc3
   WHERE mdc3.multum_category_id=outerjoin(mcsx2.multum_category_id))
  ORDER BY o.catalog_cd, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(med_recon_request->pop1,(cnt+ 9))
   ENDIF
   med_recon_request->pop1[cnt].order_id = o.order_id, med_recon_request->pop1[cnt].order_dt = format
   (o.updt_dt_tm,"mm/dd/yyyy hh:mm;;d"), med_recon_request->pop1[cnt].catalog_cd = o.catalog_cd,
   med_recon_request->pop1[cnt].cki = o.cki
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    med_recon_request->pop1[cnt].order_mnemonic = trim(o.hna_order_mnemonic)
   ELSE
    med_recon_request->pop1[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   med_recon_request->pop1[cnt].clinical_display_line = o.clinical_display_line
  DETAIL
   cur_size = (size(med_recon_request->pop1[cnt].multum,5)+ 1), stat = alterlist(med_recon_request->
    pop1[cnt].multum,cur_size)
   IF (mdc3.multum_category_id > 0)
    med_recon_request->pop1[cnt].multum[cur_size].class_1 = mdc3.category_name, med_recon_request->
    pop1[cnt].multum[cur_size].class_2 = mdc2.category_name, med_recon_request->pop1[cnt].multum[
    cur_size].class_3 = mdc1.category_name
   ELSEIF (mdc2.multum_category_id > 0)
    med_recon_request->pop1[cnt].multum[cur_size].class_1 = mdc2.category_name, med_recon_request->
    pop1[cnt].multum[cur_size].class_2 = mdc1.category_name
   ELSEIF (mdc1.multum_category_id > 0)
    med_recon_request->pop1[cnt].multum[cur_size].class_1 = mdc1.category_name
   ENDIF
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
   mltm_category_drug_xref mcdx,
   mltm_drug_categories mdc1,
   mltm_category_sub_xref mcsx1,
   mltm_drug_categories mdc2,
   mltm_category_sub_xref mcsx2,
   mltm_drug_categories mdc3
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.orig_ord_as_flag IN (1, 2)
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd=pharmacy_act_type_cd
    AND ((o.order_status_cd+ 0)=2550)
    AND o.catalog_cd != durable_equip)
   JOIN (mcdx
   WHERE mcdx.drug_identifier=outerjoin(substring(9,6,o.cki)))
   JOIN (mdc1
   WHERE mdc1.multum_category_id=outerjoin(mcdx.multum_category_id))
   JOIN (mcsx1
   WHERE mcsx1.sub_category_id=outerjoin(mdc1.multum_category_id))
   JOIN (mdc2
   WHERE mdc2.multum_category_id=outerjoin(mcsx1.multum_category_id))
   JOIN (mcsx2
   WHERE mcsx2.sub_category_id=outerjoin(mdc2.multum_category_id))
   JOIN (mdc3
   WHERE mdc3.multum_category_id=outerjoin(mcsx2.multum_category_id))
  ORDER BY o.catalog_cd, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(med_recon_request->pop2,(cnt+ 9))
   ENDIF
   med_recon_request->pop2[cnt].order_id = o.order_id, med_recon_request->pop2[cnt].catalog_cd = o
   .catalog_cd, med_recon_request->pop2[cnt].cki = o.cki
   IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
    med_recon_request->pop2[cnt].order_mnemonic = trim(o.hna_order_mnemonic)
   ELSE
    med_recon_request->pop2[cnt].order_mnemonic = concat(trim(o.hna_order_mnemonic)," (",trim(o
      .ordered_as_mnemonic),")")
   ENDIF
   med_recon_request->pop2[cnt].clinical_display_line = o.clinical_display_line
  DETAIL
   cur_size = (size(med_recon_request->pop2[cnt].multum,5)+ 1), stat = alterlist(med_recon_request->
    pop2[cnt].multum,cur_size)
   IF (mdc3.multum_category_id > 0)
    med_recon_request->pop2[cnt].multum[cur_size].class_1 = mdc3.category_name, med_recon_request->
    pop2[cnt].multum[cur_size].class_2 = mdc2.category_name, med_recon_request->pop2[cnt].multum[
    cur_size].class_3 = mdc1.category_name
   ELSEIF (mdc2.multum_category_id > 0)
    med_recon_request->pop2[cnt].multum[cur_size].class_1 = mdc2.category_name, med_recon_request->
    pop2[cnt].multum[cur_size].class_2 = mdc1.category_name
   ELSEIF (mdc1.multum_category_id > 0)
    med_recon_request->pop2[cnt].multum[cur_size].class_1 = mdc1.category_name
   ENDIF
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
   "FREETXTDOSE", "SCH/PRN", "PRNREASON"))
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
 DECLARE prob_cnt = i4
 SET prob_cnt = 0
 DECLARE column1 = vc
 FOR (i = 1 TO size(med_recon_request->pop1,5))
   DECLARE found_cat_cd = i2
   DECLARE dose_change = i2
   DECLARE freq_change = i2
   SET found_cat_cd = 0
   SET dose_change = 0
   SET freq_change = 0
   FOR (j = 1 TO size(med_recon_request->pop2,5))
     IF ((med_recon_request->pop1[i].catalog_cd=med_recon_request->pop2[j].catalog_cd))
      SET found_cat_cd = 1
      IF ((med_recon_request->pop1[i].dose != med_recon_request->pop2[j].dose))
       IF (dose_change != 2)
        SET dose_change = 1
       ENDIF
      ELSE
       SET dose_change = 2
      ENDIF
      IF ((med_recon_request->pop1[i].frequency != med_recon_request->pop2[j].frequency))
       IF (freq_change != 2)
        SET freq_change = 1
       ENDIF
      ELSE
       SET freq_change = 2
      ENDIF
      IF (found_cat_cd=1
       AND freq_change=0
       AND dose_change=0)
       SET j = (size(request->pop2,5)+ 1)
      ENDIF
     ENDIF
   ENDFOR
   IF (found_cat_cd=0)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = med_recon_request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = med_recon_request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = med_recon_request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = med_recon_request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = med_recon_request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = med_recon_request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = med_recon_request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = med_recon_request->pop1[i].frequency
    SET problems->list[prob_cnt].order_dt = med_recon_request->pop1[i].order_dt
    SET problems->list[prob_cnt].comment = "Missing"
   ELSEIF (dose_change != 2)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = med_recon_request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = med_recon_request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = med_recon_request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = med_recon_request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = med_recon_request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = med_recon_request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = med_recon_request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = med_recon_request->pop1[i].frequency
    SET problems->list[prob_cnt].comment = "Dose"
   ELSEIF (freq_change != 2)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = med_recon_request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = med_recon_request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = med_recon_request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = med_recon_request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = med_recon_request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = med_recon_request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = med_recon_request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = med_recon_request->pop1[i].frequency
    SET problems->list[prob_cnt].comment = "Frequency"
   ENDIF
 ENDFOR
 SET stat = alterlist(problems->list,prob_cnt)
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET rhead = concat(rhead,"{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
 SET rhead = concat(rhead,"{\colortbl;\red0\green0\blue0;\red0\green0\blue255;")
 SET rhead = concat(rhead,"\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;")
 SET rhead = concat(rhead,"\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;")
 SET rhead = concat(rhead,"\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green128\blue128;\red192\green192\blue192;}")
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs16 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET lock = "{\*\txfieldstart\txfieldtype0\txfieldflags3}\plain\f0\fs18"
 SET unlock = "{\*\txfieldend}"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET tblhead2 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx10500",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx12000","\pard\ql\li0\ri0\widctrl\intbl\aspalpha\aspnum\faauto",
  "\adjustright")
 SET tblhead4 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx10500",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx12000","\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET rtfeof = "}"
 SET temp_disp1 = fillstring(200,"")
 SET temp_disp2 = fillstring(200,"")
 SET temp_disp3 = fillstring(200,"")
 SET temp_disp4 = fillstring(200,"")
 SET temp_disp5 = fillstring(250,"")
 DECLARE column1 = vc
 SET max_loop = size(problems->list,5)
 SET reply->text = concat(rhead,lock)
 SET reply->text = concat(reply->text," \pard \ql ",reol,reol)
 SET reply->text = concat(reply->text,tblhead2)
 IF ((med_recon_request->recon_type="A"))
  SET reply->text = concat(reply->text,wb,"Discharge Medication Discrepancy"," \cell\par\intbl",wb,
   "Discrepancy\cell\par\intbl\row")
 ELSEIF ((med_recon_request->recon_type="T"))
  SET reply->text = concat(reply->text,wb,"Medications Not Being Given or Being Given With Changes ",
   "\cell\pard\intbl","Discrepency\cell\par\intbl\row")
 ENDIF
 SET reply->text = concat(reply->text,tblhead4)
 FOR (i = 1 TO size(problems->list,5))
   SET column1 = ""
   SET column1 = trim(problems->list[i].order_mnemonic)
   IF ((problems->list[i].dose > "")
    AND (problems->list[i].dose_unit > 0))
    SET column1 = concat(column1," ",problems->list[i].dose," ",trim(uar_get_code_display(problems->
       list[i].dose_unit)))
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ELSEIF ((problems->list[i].volume_dose > "")
    AND (problems->list[i].volume_dose_unit > 0))
    SET column1 = concat(column1," ",problems->list[i].volume_dose," ",trim(uar_get_code_display(
       problems->list[i].volume_dose_unit)))
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ELSEIF ((problems->list[i].dose > " "))
    SET column1 = concat(column1," ",problems->list[i].dose)
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ENDIF
   SET column1 = concat(column1," ",trim(uar_get_code_display(problems->list[i].frequency)))
   IF (size(trim(column1)) > 90)
    SET column1 = concat(substring(1,90,column1)," ...")
   ENDIF
   SET reply->text = concat(reply->text,lock," ",column1," \cell\pard\intbl ",
    problems->list[i].comment," \cell\par\row")
 ENDFOR
 SET reply->text = concat(reply->text,rtfeof)
 SET reply->status_data.status = "S"
#escript
END GO
