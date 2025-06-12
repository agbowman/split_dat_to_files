CREATE PROGRAM bhs_rpt_cardiac_monitor_act:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility:" = 0,
  "Select location:" = 0
  WITH outdev, mf_facility, mf_location
 DECLARE mf_facility = f8 WITH protect, constant( $MF_FACILITY)
 DECLARE ms_loc_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(3,0))))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cardiacmonitor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOR"))
 DECLARE mf_cardiacmonitoredonly_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CARDIACMONITOREDONLY"))
 DECLARE mf_cardiacmonitorreasons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "CARDIACMONITORREASONS"))
 DECLARE mf_otherreason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERREASON"))
 DECLARE mf_specialinstructions_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPECIALINSTRUCTIONS"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loc2 = i4 WITH protect, noconstant(0)
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 FREE RECORD nunit
 RECORD nunit(
   1 n_cnt = i4
   1 list[*]
     2 f_unit_cd = f8
     2 s_unit_name = vc
 ) WITH protect
 FREE RECORD ord_rec
 RECORD ord_rec(
   1 ml_enc_cnt = i4
   1 enc_qual[*]
     2 ms_pname = vc
     2 ms_fin_nbr = vc
     2 ms_loc = vc
     2 ms_bed = vc
     2 ms_room = vc
     2 ms_room_bed = vc
     2 mf_admit_dt = f8
     2 ml_ord_cnt = i4
     2 ml_disp_ind = i4
     2 mf_encntr_id = f8
     2 ord_qual[*]
       3 mf_order_id = f8
       3 mf_order_dt = f8
       3 ms_order_prov = vc
       3 ms_indication_for_use = vc
       3 ms_other_reason = vc
       3 ms_special_instructions = vc
 ) WITH protect
 FREE RECORD output_rec
 RECORD output_rec(
   1 ml_cnt = i4
   1 qual[*]
     2 ms_pat_name = vc
     2 ms_fin_nbr = vc
     2 ms_pat_loc = vc
     2 ms_admit_dt = vc
     2 ms_ord_dt = vc
     2 ms_ind_use = vc
     2 ms_ord_prov = vc
     2 ms_order_id = vc
     2 ms_room_bed = vc
     2 ms_other_reason = vc
     2 ms_special_instructions = vc
 ) WITH protect
 FREE RECORD e_rec
 RECORD e_rec(
   1 ml_cnt = i4
   1 qual[*]
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 IF (ms_loc_ind="C")
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE n.loc_facility_cd=mf_facility
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND ((cv.cdf_meaning="NURSEUNIT") OR (((cv.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt].s_unit_display_key)) OR (((
    cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="BFMCONCOLOGY"
     AND n.loc_facility_cd=673937) OR (cv.cdf_meaning="AMBULATORY"
     AND cv.display_key="S15MED"
     AND n.loc_facility_cd=673936)) )) )) )
   ORDER BY cv.display
   HEAD REPORT
    nunit->n_cnt = 0
   DETAIL
    nunit->n_cnt = (nunit->n_cnt+ 1), stat = alterlist(nunit->list,nunit->n_cnt), nunit->list[nunit->
    n_cnt].f_unit_cd = cv.code_value,
    nunit->list[nunit->n_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $MF_LOCATION)
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY")
   ORDER BY cv.display
   HEAD REPORT
    nunit->n_cnt = 0
   DETAIL
    nunit->n_cnt = (nunit->n_cnt+ 1), stat = alterlist(nunit->list,nunit->n_cnt), nunit->list[nunit->
    n_cnt].f_unit_cd = cv.code_value,
    nunit->list[nunit->n_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE expand(ml_loc,1,nunit->n_cnt,ed.loc_nurse_unit_cd,nunit->list[ml_loc].f_unit_cd))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_daystay_cd, mf_observation_cd, mf_emergency_cd)
    AND e.disch_dt_tm = null)
  HEAD REPORT
   e_rec->ml_cnt = 0
  DETAIL
   e_rec->ml_cnt = (e_rec->ml_cnt+ 1), stat = alterlist(e_rec->qual,e_rec->ml_cnt), e_rec->qual[e_rec
   ->ml_cnt].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   person p
  WHERE o.catalog_cd IN (mf_cardiacmonitor_cd, mf_cardiacmonitoredonly_cd)
   AND o.order_status_cd=mf_ordered_cd
   AND expand(ml_loc,1,e_rec->ml_cnt,o.encntr_id,e_rec->qual[ml_loc].encntr_id)
   AND p.person_id=o.person_id
  ORDER BY o.encntr_id
  HEAD o.encntr_id
   ord_rec->ml_enc_cnt = (ord_rec->ml_enc_cnt+ 1), stat = alterlist(ord_rec->enc_qual,ord_rec->
    ml_enc_cnt), ord_rec->enc_qual[ord_rec->ml_enc_cnt].mf_encntr_id = o.encntr_id,
   ord_rec->enc_qual[ord_rec->ml_enc_cnt].ml_ord_cnt = 0, ord_rec->enc_qual[ord_rec->ml_enc_cnt].
   ml_disp_ind = 0, ord_rec->enc_qual[ord_rec->ml_enc_cnt].ms_pname = p.name_full_formatted
  DETAIL
   ord_rec->enc_qual[ord_rec->ml_enc_cnt].ml_ord_cnt = (ord_rec->enc_qual[ord_rec->ml_enc_cnt].
   ml_ord_cnt+ 1), stat = alterlist(ord_rec->enc_qual[ord_rec->ml_enc_cnt].ord_qual,ord_rec->
    enc_qual[ord_rec->ml_enc_cnt].ml_ord_cnt), ord_rec->enc_qual[ord_rec->ml_enc_cnt].ord_qual[
   ord_rec->enc_qual[ord_rec->ml_enc_cnt].ml_ord_cnt].mf_order_id = o.order_id,
   ord_rec->enc_qual[ord_rec->ml_enc_cnt].ord_qual[ord_rec->enc_qual[ord_rec->ml_enc_cnt].ml_ord_cnt]
   .mf_order_dt = o.orig_order_dt_tm
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_cnt = 1 TO ord_rec->ml_enc_cnt)
  SELECT INTO "nl:"
   FROM encounter e,
    encntr_alias ea
   PLAN (e
    WHERE (e.encntr_id=ord_rec->enc_qual[ml_cnt].mf_encntr_id)
     AND e.encntr_type_cd IN (mf_inpatient_cd, mf_daystay_cd, mf_observation_cd, mf_emergency_cd)
     AND expand(ml_loc,1,nunit->n_cnt,e.loc_nurse_unit_cd,nunit->list[ml_loc].f_unit_cd))
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > sysdate)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    ord_rec->enc_qual[ml_cnt].mf_admit_dt = e.reg_dt_tm, ord_rec->enc_qual[ml_cnt].ml_disp_ind = 1,
    ord_rec->enc_qual[ml_cnt].ms_loc = uar_get_code_display(e.loc_nurse_unit_cd),
    ord_rec->enc_qual[ml_cnt].ms_bed = trim(uar_get_code_display(e.loc_bed_cd),3), ord_rec->enc_qual[
    ml_cnt].ms_room = trim(uar_get_code_display(e.loc_room_cd),3)
    IF (size(trim(ord_rec->enc_qual[ml_cnt].ms_room,3)) > 0)
     ord_rec->enc_qual[ml_cnt].ms_room_bed = ord_rec->enc_qual[ml_cnt].ms_room
     IF (size(trim(ord_rec->enc_qual[ml_cnt].ms_bed,3)) > 0)
      ord_rec->enc_qual[ml_cnt].ms_room_bed = concat(ord_rec->enc_qual[ml_cnt].ms_room_bed,"/",
       ord_rec->enc_qual[ml_cnt].ms_bed)
     ENDIF
    ELSEIF (size(trim(ord_rec->enc_qual[ml_cnt].ms_bed,3)) > 0)
     ord_rec->enc_qual[ml_cnt].ms_room_bed = ord_rec->enc_qual[ml_cnt].ms_bed
    ENDIF
    ord_rec->enc_qual[ml_cnt].ms_fin_nbr = ea.alias
   WITH nocounter
  ;end select
  IF ((ord_rec->enc_qual[ml_cnt].ml_disp_ind=1))
   SELECT INTO "nl:"
    FROM order_action oa,
     person p
    WHERE expand(ml_loc2,1,ord_rec->enc_qual[ml_cnt].ml_ord_cnt,oa.order_id,ord_rec->enc_qual[ml_cnt]
     .ord_qual[ml_loc2].mf_order_id)
     AND oa.action_sequence=1
     AND p.person_id=oa.order_provider_id
    DETAIL
     ml_loc = 0, ml_loc = locateval(ml_loc2,1,ord_rec->enc_qual[ml_cnt].ml_ord_cnt,oa.order_id,
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc2].mf_order_id)
     IF (ml_loc != 0)
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc].ms_order_prov = p.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_detail od
    WHERE expand(ml_loc2,1,ord_rec->enc_qual[ml_cnt].ml_ord_cnt,od.order_id,ord_rec->enc_qual[ml_cnt]
     .ord_qual[ml_loc2].mf_order_id)
     AND od.oe_field_id IN (mf_cardiacmonitorreasons_cd, mf_otherreason_cd, mf_specialinstructions_cd
    )
    ORDER BY od.order_id, od.action_sequence
    HEAD od.order_id
     ml_loc = 0, ml_loc = locateval(ml_loc2,1,ord_rec->enc_qual[ml_cnt].ml_ord_cnt,od.order_id,
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc2].mf_order_id)
    DETAIL
     IF (od.oe_field_id=mf_cardiacmonitorreasons_cd)
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc].ms_indication_for_use = od.oe_field_display_value
     ENDIF
     IF (od.oe_field_id=mf_otherreason_cd)
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc].ms_other_reason = od.oe_field_display_value
     ENDIF
     IF (od.oe_field_id=mf_specialinstructions_cd)
      ord_rec->enc_qual[ml_cnt].ord_qual[ml_loc].ms_special_instructions = od.oe_field_display_value
     ENDIF
    WITH noconter
   ;end select
   SET ml_cnt2 = 0
   FOR (ml_cnt2 = 1 TO ord_rec->enc_qual[ml_cnt].ml_ord_cnt)
     SET output_rec->ml_cnt = (output_rec->ml_cnt+ 1)
     SET stat = alterlist(output_rec->qual,output_rec->ml_cnt)
     SET output_rec->qual[output_rec->ml_cnt].ms_pat_name = ord_rec->enc_qual[ml_cnt].ms_pname
     SET output_rec->qual[output_rec->ml_cnt].ms_fin_nbr = ord_rec->enc_qual[ml_cnt].ms_fin_nbr
     SET output_rec->qual[output_rec->ml_cnt].ms_pat_loc = ord_rec->enc_qual[ml_cnt].ms_loc
     SET output_rec->qual[output_rec->ml_cnt].ms_room_bed = ord_rec->enc_qual[ml_cnt].ms_room_bed
     SET output_rec->qual[output_rec->ml_cnt].ms_admit_dt = format(ord_rec->enc_qual[ml_cnt].
      mf_admit_dt,";;q")
     SET output_rec->qual[output_rec->ml_cnt].ms_ord_dt = format(ord_rec->enc_qual[ml_cnt].ord_qual[
      ml_cnt2].mf_order_dt,";;q")
     SET output_rec->qual[output_rec->ml_cnt].ms_ord_prov = ord_rec->enc_qual[ml_cnt].ord_qual[
     ml_cnt2].ms_order_prov
     SET output_rec->qual[output_rec->ml_cnt].ms_ind_use = ord_rec->enc_qual[ml_cnt].ord_qual[ml_cnt2
     ].ms_indication_for_use
     SET output_rec->qual[output_rec->ml_cnt].ms_order_id = cnvtstring(ord_rec->enc_qual[ml_cnt].
      ord_qual[ml_cnt2].mf_order_id,20)
     SET output_rec->qual[output_rec->ml_cnt].ms_other_reason = ord_rec->enc_qual[ml_cnt].ord_qual[
     ml_cnt2].ms_other_reason
     SET output_rec->qual[output_rec->ml_cnt].ms_special_instructions = ord_rec->enc_qual[ml_cnt].
     ord_qual[ml_cnt2].ms_special_instructions
   ENDFOR
  ENDIF
 ENDFOR
 IF ((output_rec->ml_cnt != 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,output_rec->qual[d.seq].ms_pat_name)), fin = trim(substring(1,
     100,output_rec->qual[d.seq].ms_fin_nbr)), patient_loc = trim(substring(1,100,output_rec->qual[d
     .seq].ms_pat_loc)),
   room_bed = trim(substring(1,100,output_rec->qual[d.seq].ms_room_bed)), admit_date = trim(substring
    (1,100,output_rec->qual[d.seq].ms_admit_dt)), order_date = trim(substring(1,100,output_rec->qual[
     d.seq].ms_ord_dt)),
   indication_for_use = trim(substring(1,100,output_rec->qual[d.seq].ms_ind_use)), other_reason =
   trim(substring(1,100,output_rec->qual[d.seq].ms_other_reason)), special_instructions = trim(
    substring(1,100,output_rec->qual[d.seq].ms_special_instructions)),
   ordering_provider = trim(substring(1,100,output_rec->qual[d.seq].ms_ord_prov))
   FROM (dummyt d  WITH seq = output_rec->ml_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY patient_name, patient_loc
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No patients qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, maxcol = 1000
  ;end select
 ENDIF
END GO
