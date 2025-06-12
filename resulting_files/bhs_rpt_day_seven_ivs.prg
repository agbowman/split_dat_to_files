CREATE PROGRAM bhs_rpt_day_seven_ivs
 PROMPT
  "Email List:" = ""
  WITH s_email_list
 FREE RECORD central_iv_order_cd
 RECORD central_iv_order_cd(
   1 l_ord_cnt = i4
   1 orders[*]
     2 f_code_value = f8
     2 s_display = vc
 ) WITH protect
 FREE RECORD picc_iv_order_cd
 RECORD picc_iv_order_cd(
   1 l_ord_cnt = i4
   1 orders[*]
     2 f_code_value = f8
     2 s_display = vc
 ) WITH protect
 FREE RECORD m_info
 RECORD m_info(
   1 l_enc_cnt = i4
   1 enc_list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 s_account_nbr = vc
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_fieldiv = vc
     2 s_admit_dt_tm = vc
     2 s_present_on_arrival = vc
     2 s_field_iv_inserted_by = vc
     2 s_periph_iv_dc_dt = vc
     2 s_periph_insert_charge = vc
     2 s_periph_insert_dt_tm = vc
     2 s_peripheral_field_iv_inserted_by = vc
     2 s_present_on_arrival_inserted_by = vc
     2 s_central_insert_dt_tm = vc
     2 s_picc_eval_dt_tm = vc
     2 s_centrallinelastdressingchanged_dt = vc
     2 s_centrallineactivity = vc
     2 s_centrallinecathetertype = vc
     2 s_central_iv_dc_dt = vc
     2 n_periph_ind = i2
     2 n_central_ind = i2
     2 n_picc_ind = i2
     2 l_enc_c_ord_cnt = i4
     2 central_order_list[*]
       3 f_c_order_id = f8
       3 s_c_order_dt_tm = vc
       3 s_c_order_mnemonic = vc
     2 l_enc_p_ord_cnt = i4
     2 picc_order_list[*]
       3 f_p_order_id = f8
       3 s_p_order_dt_tm = vc
       3 s_p_order_mnemonic = vc
     2 l_enc_tpa_ord_cnt = i4
     2 tpa_order_list[*]
       3 f_tpa_order_id = f8
       3 s_tpa_order_dt_tm = vc
       3 s_tpa_order_mnemonic = vc
 ) WITH protect
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_indx = i4 WITH protect, noconstant(0)
 DECLARE ml_exp_indx = i4 WITH protect, noconstant(0)
 DECLARE ms_rpt_line = vc WITH protect, noconstant(" ")
 DECLARE ms_rpt_line_base = vc WITH protect, noconstant(" ")
 DECLARE ms_output1 = vc WITH protect, noconstant("central.csv")
 DECLARE ms_output2 = vc WITH protect, noconstant("periph.csv")
 DECLARE ms_output3 = vc WITH protect, noconstant("picc.csv")
 DECLARE mf_cs319_fin_nbr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_inprogress = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_cs6004_inprocess = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cs6004_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE mf_cs220_bmc = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,"BAYSTATE MEDICAL CENTER")
  )
 DECLARE mf_cs72_periph_iv_insert_dt_tm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVINSERTIONDATETIME"))
 DECLARE mf_cs72_piccindication = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PICCINDICATION"))
 DECLARE mf_cs72_peripheralivinsertioncharge = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PERIPHERALIVINSERTIONCHARGE"))
 DECLARE mf_cs72_periph_iv_dc_dt_tm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVDCDATETIME"))
 DECLARE mf_cs72_centrallineinsert_dt_tm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEINSERTIONDATETIME"))
 DECLARE mf_cs72_catheter_type = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Central Line Catheter Type:"))
 DECLARE mf_cs72_centrallineactivity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEACTIVITY"))
 DECLARE mf_cs72_centrallinelastdressingchanged_dt = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CENTRALLINELASTDRESSINGCHANGED"))
 DECLARE mf_cs72_piccdatetimeevaluationcompleted_dt_tm = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"PICCDATETIMEEVALUATIONCOMPLETED"))
 DECLARE mf_cs72_centralline_dc_dt = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEDISCONTINUEDATE"))
 DECLARE mf_cs72_peripheralivactivity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVACTIVITY"))
 DECLARE mf_cs72_alteplase = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALTEPLASE"))
 DECLARE mf_cs72_peripheralfieldivinsertedby = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PERIPHERALFIELDIVINSERTEDBY"))
 DECLARE mf_cs72_presentonarrivalinsertedby = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PRESENTONARRIVALINSERTEDBY"))
 DECLARE mf_cs200_alteplase1mgmlsyringeinjection = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"ALTEPLASE1MGMLSYRINGEINJECTION"))
 DECLARE mf_cs200_alteplase = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALTEPLASE")
  )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND ((cv.display_key="*CENTRAL*") OR (cv.display_key IN ("INSERTIONCATHETERCENTRALLINEPERCUTAN",
   "INSERTIONCATHETERHICKMAN", "INSERTIONPORTACATHETER", "INSERTIONCATHETERTUNNELEDLINEPERMCAT",
   "INSERTIONHEMODIALYSISCATHETER",
   "INSERTIONCATHETERTESIO", "INSERTIONCATHETERNONTUNNELLED", "REMOVALHEMODIALYSISCATHETER",
   "REMOVALHICKMANCATHETER", "REPLACEMENTOFHEMODIALYSISCATHETER",
   "DIALYSISCATHETERSITECARE", "IVFLUSHTUNNELEDVALVECATHETER")))
    AND  NOT (cv.display_key IN ("CENTRALVENOUSPRESSURE", "PANCREATECTOMYCENTRALOPEN",
   "DISSECTIONNECKCENTRALWITHTHYROIDECTO", "EXCISIONLYMPHNODESCENTRALCOMPARTMENT",
   "THYROIDECTOMYDISSECTIONCENTRALNODE"))
    AND cv.active_ind=1)
  HEAD REPORT
   central_iv_order_cd->l_ord_cnt = 0
  DETAIL
   central_iv_order_cd->l_ord_cnt += 1, stat = alterlist(central_iv_order_cd->orders,
    central_iv_order_cd->l_ord_cnt), central_iv_order_cd->orders[central_iv_order_cd->l_ord_cnt].
   f_code_value = cv.code_value,
   central_iv_order_cd->orders[central_iv_order_cd->l_ord_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND cnvtupper(cv.display)="*PICC*"
    AND cv.active_ind=1)
  HEAD REPORT
   picc_iv_order_cd->l_ord_cnt = 0
  DETAIL
   picc_iv_order_cd->l_ord_cnt += 1, stat = alterlist(picc_iv_order_cd->orders,picc_iv_order_cd->
    l_ord_cnt), picc_iv_order_cd->orders[picc_iv_order_cd->l_ord_cnt].f_code_value = cv.code_value,
   picc_iv_order_cd->orders[picc_iv_order_cd->l_ord_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cdr,
   encounter e,
   encntr_alias ea
  PLAN (e
   WHERE e.reg_dt_tm < sysdate
    AND e.disch_dt_tm=null
    AND e.loc_facility_cd=mf_cs220_bmc
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.valid_until_dt_tm > sysdate
    AND ((ce.event_end_dt_tm >= cnvtdatetime((curdate - 7),curtime3)) OR (ce.event_end_dt_tm=null))
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_modified, mf_cs8_altered, mf_cs8_inprogress)
    AND ce.publish_flag=1
    AND ce.event_cd IN (mf_cs72_periph_iv_insert_dt_tm, mf_cs72_peripheralivinsertioncharge,
   mf_cs72_periph_iv_dc_dt_tm, mf_cs72_piccdatetimeevaluationcompleted_dt_tm,
   mf_cs72_centrallineinsert_dt_tm,
   mf_cs72_centrallineactivity, mf_cs72_centrallinelastdressingchanged_dt, mf_cs72_centralline_dc_dt,
   mf_cs72_peripheralivactivity, mf_cs72_alteplase,
   mf_cs72_catheter_type, mf_cs72_piccindication, mf_cs72_peripheralfieldivinsertedby,
   mf_cs72_presentonarrivalinsertedby))
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_nbr)
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   m_info->l_enc_cnt = 0
  HEAD ce.encntr_id
   m_info->l_enc_cnt += 1
   IF (((mod(m_info->l_enc_cnt,10)=1) OR ((m_info->l_enc_cnt=1))) )
    CALL alterlist(m_info->enc_list,(m_info->l_enc_cnt+ 9))
   ENDIF
   m_info->enc_list[m_info->l_enc_cnt].encntr_id = e.encntr_id, m_info->enc_list[m_info->l_enc_cnt].
   person_id = e.person_id, m_info->enc_list[m_info->l_enc_cnt].s_account_nbr = ea.alias,
   m_info->enc_list[m_info->l_enc_cnt].s_facility = uar_get_code_display(e.loc_facility_cd), m_info->
   enc_list[m_info->l_enc_cnt].s_nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), m_info->
   enc_list[m_info->l_enc_cnt].s_room = uar_get_code_display(e.loc_room_cd),
   m_info->enc_list[m_info->l_enc_cnt].s_admit_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;d")
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_cs72_peripheralivinsertioncharge:
     m_info->enc_list[m_info->l_enc_cnt].s_periph_insert_charge = trim(ce.result_val,3),m_info->
     enc_list[m_info->l_enc_cnt].n_periph_ind = 1
    OF mf_cs72_periph_iv_dc_dt_tm:
     m_info->enc_list[m_info->l_enc_cnt].s_periph_iv_dc_dt = format(cdr.result_dt_tm,"MM/DD/YYYY;;d"),
     m_info->enc_list[m_info->l_enc_cnt].n_periph_ind = 1
    OF mf_cs72_periph_iv_insert_dt_tm:
     m_info->enc_list[m_info->l_enc_cnt].s_periph_insert_dt_tm = format(cdr.result_dt_tm,
      "MM/DD/YYYY HH:MM;;d"),m_info->enc_list[m_info->l_enc_cnt].n_periph_ind = 1
    OF mf_cs72_peripheralivactivity:
     IF (ce.result_val="Present on arrival")
      m_info->enc_list[m_info->l_enc_cnt].s_present_on_arrival = concat(trim(ce.result_val,3)," ",
       format(cdr.result_dt_tm,"MM/DD/YYYY HH:MM;;d"))
     ENDIF
     ,
     IF (ce.result_val="Field IV")
      m_info->enc_list[m_info->l_enc_cnt].s_fieldiv = concat(trim(ce.result_val,3)," ",format(cdr
        .result_dt_tm,"MM/DD/YYYY HH:MM;;d"))
     ENDIF
     ,m_info->enc_list[m_info->l_enc_cnt].n_periph_ind = 1
    OF mf_cs72_centrallineinsert_dt_tm:
     m_info->enc_list[m_info->l_enc_cnt].s_central_insert_dt_tm = format(cdr.result_dt_tm,
      "MM/DD/YYYY HH:MM;;d"),m_info->enc_list[m_info->l_enc_cnt].n_central_ind = 1
    OF mf_cs72_piccdatetimeevaluationcompleted_dt_tm:
     m_info->enc_list[m_info->l_enc_cnt].s_picc_eval_dt_tm = format(cdr.result_dt_tm,
      "MM/DD/YYYY HH:MM;;d"),m_info->enc_list[m_info->l_enc_cnt].n_picc_ind = 1
    OF mf_cs72_piccindication:
     m_info->enc_list[m_info->l_enc_cnt].n_picc_ind = 1
    OF mf_cs72_centrallinelastdressingchanged_dt:
     m_info->enc_list[m_info->l_enc_cnt].s_centrallinelastdressingchanged_dt = format(cdr
      .result_dt_tm,"MM/DD/YYYY;;d"),m_info->enc_list[m_info->l_enc_cnt].n_central_ind = 1
    OF mf_cs72_centrallineactivity:
     m_info->enc_list[m_info->l_enc_cnt].s_centrallineactivity = trim(ce.result_val,3),m_info->
     enc_list[m_info->l_enc_cnt].n_central_ind = 1
    OF mf_cs72_catheter_type:
     IF (cnvtupper(ce.result_val)="*PICC*")
      m_info->enc_list[m_info->l_enc_cnt].n_picc_ind = 1
     ENDIF
     ,m_info->enc_list[m_info->l_enc_cnt].n_central_ind = 1,m_info->enc_list[m_info->l_enc_cnt].
     s_centrallinecathetertype = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_centralline_dc_dt:
     m_info->enc_list[m_info->l_enc_cnt].s_central_iv_dc_dt = format(cdr.result_dt_tm,"MM/DD/YYYY;;d"
      ),m_info->enc_list[m_info->l_enc_cnt].n_central_ind = 1
    OF mf_cs72_peripheralfieldivinsertedby:
     m_info->enc_list[m_info->l_enc_cnt].s_peripheral_field_iv_inserted_by = trim(ce.result_val,3),
     m_info->enc_list[m_info->l_enc_cnt].n_periph_ind = 1
    OF mf_cs72_presentonarrivalinsertedby:
     m_info->enc_list[m_info->l_enc_cnt].s_present_on_arrival_inserted_by = trim(ce.result_val,3),
     m_info->enc_list[m_info->l_enc_cnt].n_periph_ind = 1
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_exp_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_exp_indx].encntr_id)
    AND ((expand(ml_exp_indx,1,central_iv_order_cd->l_ord_cnt,o.catalog_cd,central_iv_order_cd->
    orders[ml_exp_indx].f_code_value)) OR (expand(ml_exp_indx,1,picc_iv_order_cd->l_ord_cnt,o
    .catalog_cd,picc_iv_order_cd->orders[ml_exp_indx].f_code_value)))
    AND o.active_ind=1
    AND o.order_status_cd IN (mf_cs6004_inprocess, mf_cs6004_ordered, mf_cs6004_completed)
    AND o.orig_order_dt_tm BETWEEN (sysdate - 7) AND sysdate)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_pos = 0, ml_pos = locateval(ml_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_indx].
    encntr_id), ml_ord_cnt = 0
  DETAIL
   IF (ml_pos > 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,10)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_info->enc_list[ml_pos].central_order_list,(ml_ord_cnt+ 9))
    ENDIF
    m_info->enc_list[ml_pos].n_central_ind = 1, m_info->enc_list[ml_pos].central_order_list[
    ml_ord_cnt].f_c_order_id = o.order_id, m_info->enc_list[ml_pos].central_order_list[ml_ord_cnt].
    s_c_order_dt_tm = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"),
    m_info->enc_list[ml_pos].central_order_list[ml_ord_cnt].s_c_order_mnemonic = o.order_mnemonic
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(m_info->enc_list[ml_pos].central_order_list,ml_ord_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_exp_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_exp_indx].encntr_id)
    AND expand(ml_exp_indx,1,picc_iv_order_cd->l_ord_cnt,o.catalog_cd,picc_iv_order_cd->orders[
    ml_exp_indx].f_code_value)
    AND o.active_ind=1
    AND o.order_status_cd IN (mf_cs6004_inprocess, mf_cs6004_ordered, mf_cs6004_completed))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_pos = 0, ml_pos = locateval(ml_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_indx].
    encntr_id), ml_ord_cnt = 0
  DETAIL
   IF (ml_pos > 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,10)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_info->enc_list[ml_pos].picc_order_list,(ml_ord_cnt+ 9))
    ENDIF
    m_info->enc_list[ml_pos].n_picc_ind = 1, m_info->enc_list[ml_pos].picc_order_list[ml_ord_cnt].
    f_p_order_id = o.order_id, m_info->enc_list[ml_pos].picc_order_list[ml_ord_cnt].s_p_order_dt_tm
     = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"),
    m_info->enc_list[ml_pos].picc_order_list[ml_ord_cnt].s_p_order_mnemonic = o.order_mnemonic
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(m_info->enc_list[ml_pos].picc_order_list,ml_ord_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_exp_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_exp_indx].encntr_id)
    AND o.catalog_cd IN (mf_cs200_alteplase, mf_cs200_alteplase1mgmlsyringeinjection)
    AND cnvtupper(o.order_mnemonic)="ALTEPLASE 1 MG*"
    AND o.active_ind=1
    AND o.order_status_cd IN (mf_cs6004_inprocess, mf_cs6004_ordered, mf_cs6004_completed)
    AND o.orig_order_dt_tm BETWEEN (sysdate - 7) AND sysdate)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_pos = 0, ml_pos = locateval(ml_indx,1,m_info->l_enc_cnt,o.encntr_id,m_info->enc_list[ml_indx].
    encntr_id), ml_ord_cnt = 0
  DETAIL
   IF (ml_pos > 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,10)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_info->enc_list[ml_pos].tpa_order_list,(ml_ord_cnt+ 9))
    ENDIF
    m_info->enc_list[ml_pos].tpa_order_list[ml_ord_cnt].f_tpa_order_id = o.order_id, m_info->
    enc_list[ml_pos].tpa_order_list[ml_ord_cnt].s_tpa_order_dt_tm = format(o.orig_order_dt_tm,
     "MM/DD/YYYY HH:MM;;d"), m_info->enc_list[ml_pos].tpa_order_list[ml_ord_cnt].s_tpa_order_mnemonic
     = o.order_mnemonic
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(m_info->enc_list[ml_pos].tpa_order_list,ml_ord_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value(ms_output1)
  FROM (dummyt d  WITH seq = size(m_info->enc_list,5)),
   code_value cv,
   encounter e
  PLAN (d
   WHERE (m_info->enc_list[d.seq].n_central_ind=1))
   JOIN (e
   WHERE (e.encntr_id=m_info->enc_list[d.seq].encntr_id))
   JOIN (cv
   WHERE cv.code_value=e.loc_nurse_unit_cd
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND  NOT (cv.display_key IN ("MEDSTAYMOBINF", "SPFLDPEDIHEMONC", "CHESTNUTSURGIC", "CHSTB",
   "BAYSTWESTINF",
   "BAYSTPALMINF", "BMCRAD")))
  ORDER BY e.loc_nurse_unit_cd, e.person_id
  HEAD REPORT
   ms_rpt_line = build2("Facility",",","Patient Account #",",","Nurse Unit",
    ",","Room Number",",","Admission Date/Time",",",
    "Central Line Order Date/Time",",","Central Line Insertion Date/Time",",",
    "Central Line Cath Type",
    ",","Central Line Activity",",","Central Line Last Dressing Changed Date",",",
    "Central Line Discontinued Date/Time",",","TPA Order",","), col 0, ms_rpt_line,
   row + 1
  HEAD d.seq
   ms_rpt_line_base = build2(m_info->enc_list[d.seq].s_facility,",",m_info->enc_list[d.seq].
    s_account_nbr,",",m_info->enc_list[d.seq].s_nurse_unit,
    ",",m_info->enc_list[d.seq].s_room,",",m_info->enc_list[d.seq].s_admit_dt_tm,","),
   central_order_count = size(m_info->enc_list[d.seq].central_order_list,5), tpa_order_count = size(
    m_info->enc_list[d.seq].tpa_order_list,5)
   IF (central_order_count > 0)
    FOR (c_order_seq = 1 TO central_order_count)
      ms_rpt_line = build2(ms_rpt_line_base,build2(m_info->enc_list[d.seq].central_order_list[
        c_order_seq].s_c_order_dt_tm," - ",m_info->enc_list[d.seq].central_order_list[c_order_seq].
        s_c_order_mnemonic),",",m_info->enc_list[d.seq].s_central_insert_dt_tm,",",
       m_info->enc_list[d.seq].s_centrallinecathetertype,",",m_info->enc_list[d.seq].
       s_centrallineactivity,",",m_info->enc_list[d.seq].s_centrallinelastdressingchanged_dt,
       ",",m_info->enc_list[d.seq].s_central_iv_dc_dt,",")
      IF (tpa_order_count=0)
       ms_rpt_line = build2(ms_rpt_line,"",",")
      ENDIF
      col 0, ms_rpt_line, row + 1
    ENDFOR
   ENDIF
   IF (tpa_order_count > 0)
    FOR (tpa_seq = 1 TO tpa_order_count)
      ms_rpt_line = build2(ms_rpt_line_base,"",",",m_info->enc_list[d.seq].s_central_insert_dt_tm,",",
       m_info->enc_list[d.seq].s_centrallinecathetertype,",",m_info->enc_list[d.seq].
       s_centrallineactivity,",",m_info->enc_list[d.seq].s_centrallinelastdressingchanged_dt,
       ",",m_info->enc_list[d.seq].s_central_iv_dc_dt,",",build2(m_info->enc_list[d.seq].
        tpa_order_list[tpa_seq].s_tpa_order_dt_tm," - ",m_info->enc_list[d.seq].tpa_order_list[
        tpa_seq].s_tpa_order_mnemonic),","), col 0, ms_rpt_line,
      row + 1
    ENDFOR
   ENDIF
   IF (central_order_count=0
    AND tpa_order_count=0)
    ms_rpt_line = build2(ms_rpt_line_base,"",",",m_info->enc_list[d.seq].s_central_insert_dt_tm,",",
     m_info->enc_list[d.seq].s_centrallinecathetertype,",",m_info->enc_list[d.seq].
     s_centrallineactivity,",",m_info->enc_list[d.seq].s_centrallinelastdressingchanged_dt,
     ",",m_info->enc_list[d.seq].s_central_iv_dc_dt,",","",","), col 0, ms_rpt_line,
    row + 1
   ENDIF
  WITH nocounter, maxcol = 3000, format,
   formfeed = none
 ;end select
 SELECT INTO value(ms_output2)
  FROM (dummyt d  WITH seq = size(m_info->enc_list,5)),
   code_value cv,
   encounter e
  PLAN (d
   WHERE (m_info->enc_list[d.seq].n_periph_ind=1))
   JOIN (e
   WHERE (e.encntr_id=m_info->enc_list[d.seq].encntr_id))
   JOIN (cv
   WHERE cv.code_value=e.loc_nurse_unit_cd
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND  NOT (cv.display_key IN ("MEDSTAYMOBINF", "SPFLDPEDIHEMONC", "CHESTNUTSURGIC", "CHSTB",
   "BAYSTWESTINF",
   "BAYSTPALMINF", "BMCRAD", "DAYSTAYWING", "DIAGNOSTICSERV", "ENDO",
   "ESA", "ESB", "ESC", "ESD", "ESE",
   "ESHLD", "ESHP", "ESP", "ESW", "OBHLD",
   "PANU", "PPU", "MEDICALSTAYPPU", "WETU1", "WIN2",
   "WWG759IVF")))
  ORDER BY e.loc_nurse_unit_cd, e.person_id
  HEAD REPORT
   ms_rpt_line = build2("Facility",",","Patient Account #",",","Nurse Unit",
    ",","Room Number",",","Admission Date/Time",",",
    "Insertion Date/Time",",","Discontinued Date/Time",",","Field IV",
    ",","Field IV Inserted By",",","Present on Arrival",",",
    "Present on Arrival Inserted By",",","Peripheral IV Insertion Charge",","), col 0, ms_rpt_line,
   row + 1
  HEAD d.seq
   ms_rpt_line = build2(m_info->enc_list[d.seq].s_facility,",",m_info->enc_list[d.seq].s_account_nbr,
    ",",m_info->enc_list[d.seq].s_nurse_unit,
    ",",m_info->enc_list[d.seq].s_room,",",m_info->enc_list[d.seq].s_admit_dt_tm,",",
    m_info->enc_list[d.seq].s_periph_insert_dt_tm,",",m_info->enc_list[d.seq].s_periph_iv_dc_dt,",",
    m_info->enc_list[d.seq].s_fieldiv,
    ",",m_info->enc_list[d.seq].s_peripheral_field_iv_inserted_by,",",m_info->enc_list[d.seq].
    s_present_on_arrival,",",
    m_info->enc_list[d.seq].s_present_on_arrival_inserted_by,",",m_info->enc_list[d.seq].
    s_periph_insert_charge,","), col 0, ms_rpt_line,
   row + 1
  WITH nocounter, maxcol = 3000, format,
   formfeed = none
 ;end select
 SELECT INTO value(ms_output3)
  FROM (dummyt d  WITH seq = size(m_info->enc_list,5)),
   code_value cv,
   encounter e
  PLAN (d
   WHERE (m_info->enc_list[d.seq].n_picc_ind=1))
   JOIN (e
   WHERE (e.encntr_id=m_info->enc_list[d.seq].encntr_id))
   JOIN (cv
   WHERE cv.code_value=e.loc_nurse_unit_cd
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
    AND  NOT (cv.display_key IN ("MEDSTAYMOBINF", "BAYSTWESTINF")))
  ORDER BY e.loc_nurse_unit_cd, e.person_id
  HEAD REPORT
   ms_rpt_line = build2("Facility",",","Nurse Unit",",","Room Number",
    ",","Patient Account #",",","Admission Date/Time",",",
    "PICC Order Date/Time",",","PICC Eval Completed",",","PICC Line Insertion Date/Time",
    ",","Last Dressing Changed",",","TPA Order",","), col 0, ms_rpt_line,
   row + 1
  HEAD d.seq
   ms_rpt_line_base = build2(m_info->enc_list[d.seq].s_facility,",",m_info->enc_list[d.seq].
    s_nurse_unit,",",m_info->enc_list[d.seq].s_room,
    ",",m_info->enc_list[d.seq].s_account_nbr,",",m_info->enc_list[d.seq].s_admit_dt_tm,","),
   picc_order_count = size(m_info->enc_list[d.seq].picc_order_list,5), tpa_order_count = size(m_info
    ->enc_list[d.seq].tpa_order_list,5)
   IF (picc_order_count > 0)
    FOR (p_order_seq = 1 TO picc_order_count)
      ms_rpt_line = build2(ms_rpt_line_base,build2(m_info->enc_list[d.seq].picc_order_list[
        p_order_seq].s_p_order_dt_tm," - ",m_info->enc_list[d.seq].picc_order_list[p_order_seq].
        s_p_order_mnemonic),",",m_info->enc_list[d.seq].s_picc_eval_dt_tm,",",
       m_info->enc_list[d.seq].s_central_insert_dt_tm,",",m_info->enc_list[d.seq].
       s_centrallinelastdressingchanged_dt,",","",
       ","), col 0, ms_rpt_line,
      row + 1
    ENDFOR
   ENDIF
   IF (tpa_order_count > 0)
    FOR (tpa_seq = 1 TO tpa_order_count)
      ms_rpt_line = build2(ms_rpt_line_base,"",",",m_info->enc_list[d.seq].s_picc_eval_dt_tm,",",
       m_info->enc_list[d.seq].s_central_insert_dt_tm,",",m_info->enc_list[d.seq].
       s_centrallinelastdressingchanged_dt,",",build2(m_info->enc_list[d.seq].tpa_order_list[tpa_seq]
        .s_tpa_order_dt_tm," - ",m_info->enc_list[d.seq].tpa_order_list[tpa_seq].s_tpa_order_mnemonic
        ),
       ","), col 0, ms_rpt_line,
      row + 1
    ENDFOR
   ENDIF
   IF (picc_order_count=0
    AND tpa_order_count=0)
    ms_rpt_line = build2(ms_rpt_line_base,"",",",m_info->enc_list[d.seq].s_picc_eval_dt_tm,",",
     m_info->enc_list[d.seq].s_central_insert_dt_tm,",",m_info->enc_list[d.seq].
     s_centrallinelastdressingchanged_dt,",","",
     ","), col 0, ms_rpt_line,
    row + 1
   ENDIF
  WITH nocounter, maxcol = 3000, format,
   formfeed = none
 ;end select
 IF (validate(request->batch_selection)
  AND ( $S_EMAIL_LIST > ""))
  EXECUTE bhs_sys_stand_subroutine
  CALL emailfile(ms_output1,ms_output1, $S_EMAIL_LIST,concat(curprog," Central Line"),1)
  CALL emailfile(ms_output2,ms_output2, $S_EMAIL_LIST,concat(curprog," Peripheral Line"),1)
  CALL emailfile(ms_output3,ms_output3, $S_EMAIL_LIST,concat(curprog," PICC Line"),1)
 ENDIF
 FREE RECORD m_info
END GO
