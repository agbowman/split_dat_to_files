CREATE PROGRAM bhs_rw_ors_report_101508:dba
 FREE RECORD work
 RECORD work(
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 person_id = f8
     2 patient_name = vc
     2 birth_dt_tm = dq8
     2 mrn = vc
     2 fin = vc
     2 create_dt_tm = dq8
     2 admit_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 disch_ind = i2
     2 eh_cnt = i4
     2 enc_hist[*]
       3 enc_loc_hist_id = f8
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 trans_dt_tm = dq8
       3 nurse_unit_cd = f8
       3 nurse_unit = vc
       3 er_loc_ind = i2
     2 r_cnt = i4
     2 reltns[*]
       3 reltn_type_cd = f8
       3 prsnl_name = vc
     2 a_cnt = i4
     2 allergies[*]
       3 allergy_id = f8
       3 allergy_instance_id = f8
       3 substance = vc
     2 v_cnt = i4
     2 vitals[*]
       3 event_end_dt_tm = dq8
       3 r_cnt = i4
       3 results[*]
         4 type = vc
         4 value = vc
     2 ord_grps[14]
       3 o_cnt = i4
       3 orders[*]
         4 order_id = f8
         4 template_order_id = f8
         4 action_seq = i4
         4 disp = vc
         4 desc = vc
         4 catalog_cd = f8
         4 type = i4
         4 order_dt_tm = dq8
         4 dept_status = vc
         4 order_status = vc
         4 iv_slot = i4
         4 ivpb_ind = i2
         4 admin_dt_tm = dq8
         4 admin_site = vc
         4 comments = vc
         4 doc_ind = i2
         4 e_cnt = i4
         4 events[*]
           5 admin_dt_tm = dq8
           5 admin_site = vc
           5 c_cnt = i4
           5 comments[*]
             6 type = f8
             6 text = vc
         4 d_cnt = i4
         4 details[*]
           5 field = vc
           5 value = vc
         4 to_cnt = i4
         4 temp_orders[*]
           5 order_id = f8
     2 i_cnt = i4
     2 ivs[*]
       3 order_id = f8
       3 desc = vc
       3 disp = vc
       3 b_cnt = i4
       3 bags[*]
         4 substance_lot_number = vc
         4 initial_volume = f8
         4 dosage_unit = vc
         4 admin_route = vc
         4 admin_site = vc
         4 infusion_rate = f8
         4 infusion_unit = vc
         4 diluent_type = vc
         4 e_cnt = i4
         4 events[*]
           5 event_id = f8
           5 event_end_dt_tm = dq8
           5 iv_event = vc
           5 admin_site = vc
           5 admin_dosage = f8
           5 admin_start_dt_tm = dq8
           5 admin_end_dt_tm = dq8
           5 comments = vc
     2 total_r_cnt = i4
     2 l_cnt = i4
     2 labs[*]
       3 catalog_cd = f8
       3 desc = vc
       3 r_cnt = i4
       3 results[*]
         4 order_id = f8
         4 event_end_dt_tm = dq8
         4 desc = vc
         4 value = vc
         4 units = vc
         4 mod_ind = i2
         4 normalcy = vc
     2 no_data_ind = i2
     2 s_cnt = i4
     2 sections[*]
       3 desc = vc
       3 type = i4
       3 c_cnt = i4
       3 columns[*]
         4 header = vc
         4 x_pos = i4
         4 last_line = i4
       3 l_cnt = i4
       3 lines[*]
         4 y_pos = i4
         4 c_cnt = i4
         4 columns[*]
           5 text = vc
 )
 DECLARE ord_grp_meds = i4 WITH constant(01)
 DECLARE ord_grp_iv = i4 WITH constant(02)
 DECLARE ord_grp_oxygen = i4 WITH constant(03)
 DECLARE ord_grp_other = i4 WITH constant(04)
 DECLARE ord_grp_lab_comp = i4 WITH constant(05)
 DECLARE ord_grp_lab_pend = i4 WITH constant(06)
 DECLARE ord_grp_rad = i4 WITH constant(07)
 DECLARE ord_grp_micro = i4 WITH constant(08)
 DECLARE ord_grp_ecg = i4 WITH constant(09)
 DECLARE ord_grp_blood = i4 WITH constant(10)
 DECLARE ord_grp_neuro = i4 WITH constant(11)
 DECLARE ord_grp_pulm = i4 WITH constant(12)
 DECLARE ord_grp_card = i4 WITH constant(13)
 DECLARE ord_grp_scripts = i4 WITH constant(14)
 DECLARE rw_wrap(orig_str=vc,line_len=i4,indent_size=i4) = null
 SUBROUTINE rw_wrap(orig_str,line_len,indent_size)
   FREE SET temp_str
   FREE SET beg_pos
   FREE SET end_pos
   FREE RECORD wrap_return
   SET temp_str = trim(orig_str,1)
   SET beg_pos = 1
   SET end_pos = 0
   RECORD wrap_return(
     1 l_cnt = i4
     1 lines[*]
       2 text = vc
   ) WITH persist
   WHILE (beg_pos > 0
    AND beg_pos <= size(temp_str))
     IF (findstring(char(10),substring(beg_pos,line_len,temp_str),1,0) > 0)
      SET end_pos = findstring(char(10),substring(beg_pos,line_len,temp_str),1,0)
     ELSEIF (substring((beg_pos+ line_len),1,temp_str)=" ")
      SET end_pos = (line_len+ 1)
     ELSEIF (findstring(" ",substring(beg_pos,line_len,temp_str),1,1)=0)
      SET end_pos = line_len
     ELSE
      SET end_pos = findstring(" ",substring(beg_pos,line_len,temp_str),1,1)
     ENDIF
     SET wrap_return->l_cnt = (wrap_return->l_cnt+ 1)
     SET stat = alterlist(wrap_return->lines,wrap_return->l_cnt)
     IF (beg_pos=1)
      SET wrap_return->lines[wrap_return->l_cnt].text = trim(substring(beg_pos,end_pos,temp_str))
      SET line_len = (line_len - indent_size)
     ELSE
      SET wrap_return->lines[wrap_return->l_cnt].text = build2(fillstring(value(indent_size)," "),
       trim(substring(beg_pos,end_pos,temp_str)))
     ENDIF
     SET beg_pos = (beg_pos+ end_pos)
   ENDWHILE
 END ;Subroutine
 DECLARE var_output = vc
 DECLARE discern_rule_ind = i2 WITH noconstant(0)
 IF (((validate(trigger_encntrid,0.00) > 0.00) OR (validate(trigger_personid,0.00) > 0.00)) )
  SET discern_rule_ind = 1
  SET retval = 0
  SET log_message = fillstring(255," ")
 ENDIF
 IF (validate(request->output_device,"A")="A"
  AND validate(request->output_device,"Z")="Z")
  IF (reflect(parameter(1,0)) > " ")
   SET var_output = parameter(1,0)
  ELSE
   CALL echo("No output location found. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No output location found. Exiting Script")
   ENDIF
   GO TO exit_script
  ENDIF
  IF (reflect(parameter(2,0)) > " "
   AND cnvtreal(parameter(2,0)) > 0.00)
   SET work->e_cnt = 1
   SET stat = alterlist(work->encntrs,1)
   SET work->encntrs[1].encntr_id = cnvtreal(parameter(2,0))
  ELSE
   CALL echo("No ENCNTR_ID given. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No ENCNTR_ID given. Exiting Script")
   ENDIF
  ENDIF
  IF (discern_rule_ind=1)
   DECLARE beg_loop = c20 WITH constant(format(cnvtdatetime(curdate,curtime3),
     "DD-MMM-YYYY HH:MM:SS;;D"))
   DECLARE tmp_seconds = i4 WITH noconstant(0)
   DECLARE disch_ind = i2 WITH noconstant(0)
   WHILE (tmp_seconds BETWEEN 0 AND 1
    AND disch_ind=0)
     WHILE (tmp_seconds=cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(beg_loop),5)
      ))
       SET tmp_seconds = tmp_seconds
     ENDWHILE
     SET tmp_seconds = cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(beg_loop),5))
     SELECT INTO "NL:"
      FROM encounter e
      PLAN (e
       WHERE e.encntr_id=46865100.00
        AND e.disch_dt_tm != null)
      DETAIL
       disch_ind = 1
      WITH nocounter
     ;end select
   ENDWHILE
   IF (disch_ind=0)
    SET log_message = build2(trim(log_message,3)," Encounter still not discharged after ",trim(
      cnvtstring(tmp_seconds),3)," secs. Continuing program.")
   ENDIF
   FREE SET beg_loop
   FREE SET tmp_seconds
   FREE SET disch_ind
  ENDIF
 ELSE
  IF (trim(request->output_device,3) > " ")
   SET var_output = request->output_device
  ELSE
   CALL echo("No output location found. Exiting Script")
   IF (discern_rule_ind=1)
    SET log_message = build2(trim(log_message,3)," No output location found. Exiting Script")
   ENDIF
   GO TO exit_script
  ENDIF
  FOR (e = 1 TO size(request->visit,5))
    IF ((request->visit[e].encntr_id > 0.00))
     SET work->e_cnt = (work->e_cnt+ 1)
     SET stat = alterlist(work->encntrs,work->e_cnt)
     SET work->encntrs[work->e_cnt].encntr_id = request->visit[e].encntr_id
    ENDIF
  ENDFOR
 ENDIF
 IF ((work->e_cnt <= 0))
  SELECT INTO value(var_output)
   FROM dummyt
   DETAIL
    col 0, "{F/0}{CPI/18}{LPI/9}{PS/792 0 translate 90 rotate/}", row + 1,
    col 0,
    CALL print(build2(calcpos(18,8),"{B}ED Orders/Results Summary (ORS) Report{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(330,270),"{B}No encounters passed in. Exiting Program{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(18,552),'{B}Legend:{ENDB}  "*" = Med/IV not charted  "S" = Med/IV ',
     'series started  "C" = Completed  "DC" = Discontinued')), row + 1,
    col 0,
    CALL print(build2(calcpos(18,566),
     " {B}*** Report may not include all Downtime/Written Orders/Results ***{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(605,566),"{B}Printed On ",format(cnvtdatetime(curdate,curtime3),
      "MM/DD/YYYY HH:MM;;D"),"{ENDB}")), row + 1,
    col 0,
    CALL print(build2(calcpos(368,566)," {B}END OF REPORT (Page 1){ENDB}"))
   WITH nocounter, dio = 8
  ;end select
  GO TO exit_script
 ENDIF
 SET loc_fac = "BMC"
 DECLARE cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 IF (loc_fac="BFMC")
  DECLARE cs220_er_group_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ERALLBFMC"))
 ELSEIF (loc_fac="BMLH")
  DECLARE cs220_er_group_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ERALLBMLH"))
 ELSE
  DECLARE cs220_er_group_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ERALLBMC"))
 ENDIF
 SELECT INTO "NL:"
  e.encntr_id
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encounter e,
   location_group lg1,
   encntr_loc_hist elh,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (e
   WHERE (work->encntrs[d.seq].encntr_id=e.encntr_id))
   JOIN (lg1
   WHERE lg1.parent_loc_cd=outerjoin(cs220_er_group_cd)
    AND outerjoin(e.loc_nurse_unit_cd)=lg1.child_loc_cd)
   JOIN (elh
   WHERE e.encntr_id=elh.encntr_id
    AND elh.loc_nurse_unit_cd > 0.00
    AND  EXISTS (
   (SELECT
    lg2.child_loc_cd
    FROM location_group lg2
    WHERE lg2.parent_loc_cd=cs220_er_group_cd
     AND elh.loc_nurse_unit_cd=lg2.child_loc_cd)))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (ea1
   WHERE e.encntr_id=ea1.encntr_id
    AND ea1.encntr_alias_type_cd=cs319_mrn_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ea2
   WHERE e.encntr_id=ea2.encntr_id
    AND ea2.encntr_alias_type_cd=cs319_fin_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY e.encntr_id, elh.beg_effective_dt_tm
  HEAD REPORT
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD e.encntr_id
   work->encntrs[d.seq].person_id = e.person_id, work->encntrs[d.seq].patient_name = p
   .name_full_formatted, work->encntrs[d.seq].birth_dt_tm = p.birth_dt_tm,
   work->encntrs[d.seq].mrn = trim(ea1.alias), work->encntrs[d.seq].fin = trim(ea2.alias), work->
   encntrs[d.seq].create_dt_tm = e.create_dt_tm,
   eh_cnt = 0, last_nurse_unit_cd = 0.00
  HEAD elh.encntr_loc_hist_id
   IF (elh.loc_nurse_unit_cd != last_nurse_unit_cd)
    eh_cnt = (work->encntrs[d.seq].eh_cnt+ 1), stat = alterlist(work->encntrs[d.seq].enc_hist,eh_cnt),
    work->encntrs[d.seq].eh_cnt = eh_cnt,
    work->encntrs[d.seq].enc_hist[eh_cnt].enc_loc_hist_id = elh.encntr_loc_hist_id, work->encntrs[d
    .seq].enc_hist[eh_cnt].beg_dt_tm = elh.beg_effective_dt_tm, work->encntrs[d.seq].enc_hist[eh_cnt]
    .end_dt_tm = elh.end_effective_dt_tm,
    work->encntrs[d.seq].enc_hist[eh_cnt].trans_dt_tm = elh.transaction_dt_tm, work->encntrs[d.seq].
    enc_hist[eh_cnt].nurse_unit_cd = elh.loc_nurse_unit_cd, work->encntrs[d.seq].enc_hist[eh_cnt].
    nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd),
    last_nurse_unit_cd = elh.loc_nurse_unit_cd
   ELSE
    work->encntrs[d.seq].enc_hist[eh_cnt].end_dt_tm = elh.end_effective_dt_tm
   ENDIF
  FOOT  e.encntr_id
   IF ((work->encntrs[d.seq].eh_cnt > 0))
    work->encntrs[d.seq].create_dt_tm = work->encntrs[d.seq].enc_hist[1].beg_dt_tm, work->encntrs[d
    .seq].admit_dt_tm = work->encntrs[d.seq].enc_hist[1].beg_dt_tm
    IF (elh.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
     work->encntrs[d.seq].disch_dt_tm = elh.end_effective_dt_tm
    ELSE
     work->encntrs[d.seq].disch_dt_tm = cnvtdatetime(curdate,curtime3)
    ENDIF
   ELSE
    work->encntrs[d.seq].create_dt_tm = e.create_dt_tm, work->encntrs[d.seq].admit_dt_tm = e
    .reg_dt_tm
    IF (e.disch_dt_tm != null)
     work->encntrs[d.seq].disch_dt_tm = e.disch_dt_tm
    ELSE
     work->encntrs[d.seq].disch_dt_tm = cnvtdatetime(curdate,curtime3)
    ENDIF
   ENDIF
   IF (lg1.child_loc_cd <= 0.00)
    work->encntrs[d.seq].disch_ind = 2
   ENDIF
   IF (e.disch_dt_tm != null)
    work->encntrs[d.seq].disch_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (discern_rule_ind=1)
  SET log_message = build2(log_message," DISCH_DT_TM ",format(work->encntrs[1].disch_dt_tm,";;Q"),
   " DISCH_IND ",trim(cnvtstring(work->encntrs[1].disch_ind)))
 ENDIF
 FREE SET cs319_mrn_cd
 FREE SET cs319_fin_cd
 FREE SET cs220_er_group_cd
 DECLARE cs333_attenddoc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE cs333_assistant_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "EDPHYSICIANASSISTANT"))
 DECLARE cs333_physician_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDPHYSICIAN"))
 DECLARE cs333_pa_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDPHYSICIANASSISTANT"))
 DECLARE cs333_resident_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"EDRESIDENT"))
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d)
   JOIN (epr
   WHERE (work->encntrs[d.seq].encntr_id=epr.encntr_id)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND epr.encntr_prsnl_r_cd IN (cs333_attenddoc_cd, cs333_assistant_cd, cs333_physician_cd,
   cs333_pa_cd, cs333_resident_cd))
   JOIN (pr
   WHERE epr.prsnl_person_id=pr.person_id)
  ORDER BY d.seq, pr.name_full_formatted, pr.person_id
  HEAD REPORT
   r_cnt = 0
  HEAD pr.person_id
   r_cnt = (work->encntrs[d.seq].r_cnt+ 1), stat = alterlist(work->encntrs[d.seq].reltns,r_cnt), work
   ->encntrs[d.seq].r_cnt = r_cnt,
   work->encntrs[d.seq].reltns[r_cnt].reltn_type_cd = epr.encntr_prsnl_r_cd, work->encntrs[d.seq].
   reltns[r_cnt].prsnl_name = trim(pr.name_full_formatted,3)
  WITH nocounter
 ;end select
 FREE SET cs333_attenddoc_cd
 FREE SET cs333_associate_cd
 FREE SET cs333_physician_cd
 FREE SET cs333_pa_cd
 FREE SET cs333_resident_cd
 DECLARE cs12025_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (work->encntrs[d.seq].person_id=a.person_id)
    AND a.active_ind=1
    AND a.reaction_status_cd != cs12025_canceled_cd)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  ORDER BY d.seq, a.beg_effective_dt_tm, a.allergy_id,
   a.end_effective_dt_tm DESC
  HEAD REPORT
   a_cnt = 0
  HEAD a.allergy_id
   a_cnt = (work->encntrs[d.seq].a_cnt+ 1), stat = alterlist(work->encntrs[d.seq].allergies,a_cnt),
   work->encntrs[d.seq].a_cnt = a_cnt,
   work->encntrs[d.seq].allergies[a_cnt].allergy_id = a.allergy_id, work->encntrs[d.seq].allergies[
   a_cnt].allergy_instance_id = a.allergy_instance_id
   IF (n.nomenclature_id > 0.00)
    work->encntrs[d.seq].allergies[a_cnt].substance = trim(substring(1,20,n.source_string),3)
   ELSEIF (trim(a.substance_ftdesc,3) > " ")
    work->encntrs[d.seq].allergies[a_cnt].substance = trim(substring(1,20,a.substance_ftdesc),3)
   ENDIF
  WITH nocounter
 ;end select
 FREE SET cs12025_canceled_cd
 DECLARE cs72_temp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE cs72_pulse_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE cs72_resp_rate_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE"))
 DECLARE cs72_systolic_bp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE cs72_diastolic_bp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE cs72_o2_sat_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION"))
 DECLARE cs72_mode_of_delivery_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 DECLARE cs72_weight_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs53_grp_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->e_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (work->encntrs[d.seq].encntr_id=ce.encntr_id)
    AND ce.event_cd IN (cs72_temp_cd, cs72_pulse_cd, cs72_resp_rate_cd, cs72_systolic_bp_cd,
   cs72_diastolic_bp_cd,
   cs72_o2_sat_cd, cs72_mode_of_delivery_cd, cs72_weight_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(work->encntrs[d.seq].disch_dt_tm)
    AND ce.view_level=1
    AND ce.event_class_cd != cs53_grp_cd
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime(work->encntrs[d.seq].create_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(work->encntrs[d.seq].disch_dt_tm))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD REPORT
   new_group_ind = 1, v_cnt = 0, r_cnt = 0,
   w_cnt = 0
  HEAD ce.event_end_dt_tm
   new_group_ind = 1
  DETAIL
   IF (new_group_ind=1)
    IF ((((work->encntrs[d.seq].v_cnt=0)) OR ((work->encntrs[d.seq].vitals[v_cnt].r_cnt > 0))) )
     v_cnt = (work->encntrs[d.seq].v_cnt+ 1), stat = alterlist(work->encntrs[d.seq].vitals,v_cnt),
     work->encntrs[d.seq].v_cnt = v_cnt
    ENDIF
    work->encntrs[d.seq].vitals[v_cnt].event_end_dt_tm = ce.event_end_dt_tm, r_cnt = 0, new_group_ind
     = 0
   ENDIF
   r_cnt = (work->encntrs[d.seq].vitals[v_cnt].r_cnt+ 1), stat = alterlist(work->encntrs[d.seq].
    vitals[v_cnt].results,r_cnt), work->encntrs[d.seq].vitals[v_cnt].r_cnt = r_cnt
   CASE (ce.event_cd)
    OF cs72_temp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Temp"
    OF cs72_pulse_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Pulse"
    OF cs72_resp_rate_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Respiratory Rate"
    OF cs72_systolic_bp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Systolic BP"
    OF cs72_diastolic_bp_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Diastolic BP"
    OF cs72_o2_sat_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "O2 Sat"
    OF cs72_mode_of_delivery_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Mode of Delivery"
    OF cs72_weight_cd:
     work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].type = "Weight"
   ENDCASE
   work->encntrs[d.seq].vitals[v_cnt].results[r_cnt].value = trim(ce.result_val,3)
  WITH nocounter
 ;end select
 FREE SET cs72_temp_cd
 FREE SET cs72_pulse_cd
 FREE SET cs72_resp_rate_cd
 FREE SET cs72_systolic_bp_cd
 FREE SET cs72_diastolic_bp_cd
 FREE SET cs72_o2_sat_cd
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6004_pending_rev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE cs6004_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cs6004_discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE cs6000_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE cs6000_resp_therapy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE cs106_gen_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE cs106_micro_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE cs106_blood_bank_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE cs106_blood_bank_product_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE cs106_radiology_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE cs106_restraints_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE cs106_code_status_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE cs106_adt_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ADMITTRANSFERDISCHARGE"))
 DECLARE cs106_ecg_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ECG"))
 DECLARE cs106_neurotxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "NEUROTXPROCEDURES"))
 DECLARE cs106_pulmlabtxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "PULMLABTXPROCEDURES"))
 DECLARE cs106_noninvasivecardiologytxprocedures_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE cs16389_md_to_rn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"MDTORN"))
 DECLARE cs16389_consults_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"CONSULTS"))
 DECLARE cs16389_diet_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"DIET"))
 DECLARE cs16389_ivsolutions_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE cs16389_laboratory_cd = f8 WITH constant(uar_get_code_by("MEANING",16389,"LABORATORY"))
 DECLARE cs16389_card_pulm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"CARDIOPULMONARY"
   ))
 DECLARE cs18309_iv_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18309,"IV"))
 DECLARE cs18309_intermittent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"
   ))
 DECLARE cs16449_med_diluent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "MEDICATIONDILUENT"))
 DECLARE cs16449_limited_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"LIMITATIONS"))
 SELECT INTO "NL:"
  order_type =
  IF (o.orig_ord_as_flag=1) ord_grp_scripts
  ELSEIF (((o.med_order_type_cd=cs18309_iv_cd) OR (o.dcp_clin_cat_cd=cs16389_ivsolutions_cd)) )
   ord_grp_iv
  ELSEIF (o.catalog_type_cd=cs6000_pharmacy_cd
   AND ((((o.prn_ind=0
   AND o.freq_type_flag != 5) OR (o.prn_ind=1)) ) OR (o.med_order_type_cd=cs18309_intermittent_cd)) )
    ord_grp_meds
  ELSEIF (o.catalog_type_cd=cs6000_resp_therapy_cd) ord_grp_oxygen
  ELSEIF (o.dcp_clin_cat_cd=cs16389_md_to_rn_cd) ord_grp_other
  ELSEIF (o.activity_type_cd=cs106_radiology_cd) ord_grp_rad
  ELSEIF (o.activity_type_cd=cs106_micro_cd) ord_grp_micro
  ELSEIF (o.activity_type_cd=cs106_ecg_cd) ord_grp_ecg
  ELSEIF (o.activity_type_cd IN (cs106_blood_bank_cd, cs106_blood_bank_product_cd)) ord_grp_blood
  ELSEIF (o.activity_type_cd=cs106_neurotxprocedures_cd) ord_grp_neuro
  ELSEIF (o.activity_type_cd=cs106_pulmlabtxprocedures_cd) ord_grp_pulm
  ELSEIF (((o.activity_type_cd=cs106_noninvasivecardiologytxprocedures_cd) OR (o.dcp_clin_cat_cd=
  cs16389_card_pulm_cd)) ) ord_grp_card
  ELSEIF (((o.activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
   AND o.order_status_cd=cs6004_completed_cd) ord_grp_lab_comp
  ELSEIF (((o.activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
   AND o.order_status_cd != cs6004_completed_cd) ord_grp_lab_pend
  ELSE ord_grp_other
  ENDIF
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   orders o,
   order_action oa
  PLAN (d1)
   JOIN (o
   WHERE (work->encntrs[d1.seq].encntr_id=o.encntr_id)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND o.cs_flag IN (0, 2, 8, 32)
    AND ((o.catalog_type_cd IN (cs6000_pharmacy_cd, cs6000_resp_therapy_cd)) OR (((((o
   .activity_type_cd=cs106_gen_lab_cd) OR (o.dcp_clin_cat_cd=cs16389_laboratory_cd))
    AND ((o.order_status_cd != cs6004_completed_cd) OR (o.order_status_cd=cs6004_completed_cd
    AND o.order_id IN (
   (SELECT
    ce.order_id
    FROM clinical_event ce
    WHERE o.encntr_id=ce.encntr_id
     AND o.order_id=ce.order_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(work->encntrs[d1.seq].disch_dt_tm)
     AND ce.view_level=1)))) ) OR (((o.activity_type_cd IN (cs106_micro_cd, cs106_blood_bank_cd,
   cs106_radiology_cd, cs106_ecg_cd, cs106_neurotxprocedures_cd,
   cs106_pulmlabtxprocedures_cd, cs106_noninvasivecardiologytxprocedures_cd)) OR (((o.dcp_clin_cat_cd
    IN (cs16389_md_to_rn_cd, cs16389_consults_cd, cs16389_diet_cd, cs16389_card_pulm_cd)) OR (o
   .activity_type_cd IN (cs106_blood_bank_product_cd, cs106_restraints_cd, cs106_code_status_cd,
   cs106_adt_cd))) )) )) )) )
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm))
  ORDER BY d1.seq, order_type, o.order_mnemonic,
   o.orig_order_dt_tm, o.order_id, oa.action_sequence DESC
  HEAD REPORT
   o_cnt = 0, d_cnt = 0, i_cnt = 0,
   l_cnt = 0, tmp_l = 0, rec_ind = 0
  HEAD o.order_id
   IF (oa.order_status_cd IN (cs6004_ordered_cd, cs6004_inprocess_cd, cs6004_pending_cd,
   cs6004_pending_rev_cd, cs6004_completed_cd,
   cs6004_discontinued_cd))
    o_cnt = (work->encntrs[d1.seq].ord_grps[order_type].o_cnt+ 1), work->encntrs[d1.seq].ord_grps[
    order_type].o_cnt = o_cnt, stat = alterlist(work->encntrs[d1.seq].ord_grps[order_type].orders,
     o_cnt),
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].order_id = o.order_id, work->encntrs[d1
    .seq].ord_grps[order_type].orders[o_cnt].type = order_type, work->encntrs[d1.seq].ord_grps[
    order_type].orders[o_cnt].catalog_cd = o.catalog_cd,
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].order_status = trim(uar_get_code_display
     (o.order_status_cd),3), work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].dept_status =
    trim(uar_get_code_display(o.dept_status_cd),3), work->encntrs[d1.seq].ord_grps[order_type].
    orders[o_cnt].order_dt_tm = o.orig_order_dt_tm,
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].action_seq = oa.action_sequence
    IF (order_type IN (ord_grp_meds, ord_grp_scripts))
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3)
    ELSEIF (order_type=ord_grp_iv)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.ordered_as_mnemonic,3),
     i_cnt = (work->encntrs[d1.seq].i_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs,i_cnt),
     work->encntrs[d1.seq].i_cnt = i_cnt, work->encntrs[d1.seq].ivs[i_cnt].order_id = o.order_id,
     work->encntrs[d1.seq].ivs[i_cnt].desc = trim(o.ordered_as_mnemonic,3),
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].iv_slot = i_cnt
    ELSEIF (order_type IN (ord_grp_oxygen, ord_grp_other))
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc =
     IF (trim(o.order_mnemonic,3) > " ") trim(o.order_mnemonic,3)
     ELSE trim(o.hna_order_mnemonic,3)
     ENDIF
    ELSEIF (order_type=ord_grp_lab_pend)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o
       .catalog_cd),3)
    ELSEIF (order_type=ord_grp_lab_comp)
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(uar_get_code_display(o
       .catalog_cd),3), tmp_l = 0, stat = locateval(tmp_l,1,work->encntrs[d1.seq].l_cnt,o.catalog_cd,
      work->encntrs[d1.seq].labs[tmp_l].catalog_cd)
     IF ((work->encntrs[d1.seq].labs[tmp_l].catalog_cd != o.catalog_cd))
      l_cnt = (work->encntrs[d1.seq].l_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].labs,l_cnt),
      work->encntrs[d1.seq].l_cnt = l_cnt,
      work->encntrs[d1.seq].labs[l_cnt].catalog_cd = o.catalog_cd, work->encntrs[d1.seq].labs[l_cnt].
      desc = trim(work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc,3)
     ENDIF
    ELSE
     work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].desc = trim(o.hna_order_mnemonic,3)
    ENDIF
    work->encntrs[d1.seq].ord_grps[order_type].orders[o_cnt].disp = trim(work->encntrs[d1.seq].
     ord_grps[order_type].orders[o_cnt].desc,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   dummyt d3,
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,size(work->encntrs[d1.seq].ord_grps,5)))
   JOIN (d2
   WHERE maxrec(d3,work->encntrs[d1.seq].ord_grps[d2.seq].o_cnt))
   JOIN (d3)
   JOIN (od
   WHERE (work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].order_id=od.order_id)
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE", "DURATION", "DURATIONUNIT", "SCH/PRN", "DISPENSEQTY",
   "DISPENSEQTYUNIT", "SPECINX")) OR (od.oe_field_id IN (cs16449_med_diluent_cd, cs16449_limited_cd)
   )) )
  ORDER BY d1.seq, d2.seq, d3.seq,
   od.action_sequence, od.detail_sequence
  HEAD REPORT
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d2.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  HEAD d3.seq
   d_cnt = 0, strength_ind = 0, detail_ind = 0
  DETAIL
   detail_ind = 1
   IF (od.oe_field_meaning="RXROUTE"
    AND trim(od.oe_field_display_value,3)="IVPB")
    work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].ivpb_ind = 1
   ENDIF
   IF (od.oe_field_meaning="STRENGTHDOSE"
    AND d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
    strength_ind = 1
   ENDIF
   IF (((d2.seq=ord_grp_iv
    AND  NOT (od.oe_field_meaning IN ("RATE", "RATEUNIT"))) OR (d2.seq != ord_grp_iv
    AND od.oe_field_meaning IN ("RATE", "RATEUNIT"))) )
    detail_ind = 0
   ENDIF
   IF (d2.seq=ord_grp_other
    AND od.oe_field_meaning="FREQ")
    detail_ind = 0
   ENDIF
   IF (detail_ind=1)
    IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt > 0))
     d_cnt = 0, stat = locateval(d_cnt,1,work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt,
      od.oe_field_meaning,work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d_cnt].field)
    ENDIF
    IF (((d_cnt=0) OR ((od.oe_field_meaning != work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].
    details[d_cnt].field))) )
     d_cnt = (work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt+ 1), work->encntrs[d1.seq].
     ord_grps[d2.seq].orders[d3.seq].d_cnt = d_cnt, stat = alterlist(work->encntrs[d1.seq].ord_grps[
      d2.seq].orders[d3.seq].details,d_cnt)
    ENDIF
    work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d_cnt].field = od.oe_field_meaning,
    work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d_cnt].value = trim(od
     .oe_field_display_value,3)
   ENDIF
  FOOT  d3.seq
   IF (d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_oxygen, ord_grp_other, ord_grp_blood,
   ord_grp_scripts))
    FOR (d = 1 TO work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].d_cnt)
      detail_ind = 1
      IF (d2.seq IN (ord_grp_meds, ord_grp_iv, ord_grp_scripts))
       IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].field IN ("VOLUMEDOSE",
       "VOLUMEDOSEUNIT")))
        IF (strength_ind=0)
         work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
          ord_grps[d2.seq].orders[d3.seq].disp," ",trim(work->encntrs[d1.seq].ord_grps[d2.seq].
           orders[d3.seq].details[d].value,3))
        ENDIF
        detail_ind = 0
       ENDIF
      ENDIF
      IF (detail_ind=1
       AND (work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].field="SCH/PRN"))
       IF ((work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].details[d].value="Yes"))
        work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
         ord_grps[d2.seq].orders[d3.seq].disp," PRN")
       ENDIF
       detail_ind = 0
      ENDIF
      IF (detail_ind=1)
       work->encntrs[d1.seq].ord_grps[d2.seq].orders[d3.seq].disp = build2(work->encntrs[d1.seq].
        ord_grps[d2.seq].orders[d3.seq].disp," ",trim(work->encntrs[d1.seq].ord_grps[d2.seq].orders[
         d3.seq].details[d].value,3))
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 DECLARE cs24_root_cd = f8 WITH constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE cs52_normal_cd = f8 WITH constant(uar_get_code_by("MEANING",52,"NORMAL"))
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].l_cnt))
   JOIN (d2)
   JOIN (ce
   WHERE (work->encntrs[d1.seq].encntr_id=ce.encntr_id)
    AND (work->encntrs[d1.seq].labs[d2.seq].catalog_cd=ce.catalog_cd)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.view_level=1
    AND ce.event_reltn_cd != cs24_root_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ce.event_end_dt_tm
  HEAD REPORT
   r_cnt = 0
  DETAIL
   r_cnt = (work->encntrs[d1.seq].labs[d2.seq].r_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].
    labs[d2.seq].results,r_cnt), work->encntrs[d1.seq].labs[d2.seq].r_cnt = r_cnt,
   work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].order_id = ce.order_id, work->encntrs[d1.seq].
   labs[d2.seq].results[r_cnt].event_end_dt_tm = ce.event_end_dt_tm, work->encntrs[d1.seq].labs[d2
   .seq].results[r_cnt].desc = trim(uar_get_code_display(ce.event_cd)),
   work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].value = trim(ce.result_val), work->encntrs[d1
   .seq].labs[d2.seq].results[r_cnt].units = trim(uar_get_code_display(ce.result_units_cd))
   IF (ce.result_status_cd != cs8_auth_cd)
    work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].mod_ind = 1
   ENDIF
   IF ( NOT (ce.normalcy_cd IN (0.00, cs52_normal_cd)))
    work->encntrs[d1.seq].labs[d2.seq].results[r_cnt].normalcy = trim(uar_get_code_display(ce
      .normalcy_cd))
   ENDIF
   work->encntrs[d1.seq].total_r_cnt = (work->encntrs[d1.seq].total_r_cnt+ 1)
  WITH nocounter
 ;end select
 DECLARE cs53_placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE cs72_ivparent_cd = f8 WITH constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cs120_ocfcomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 SELECT INTO "NL:"
  cmr1.substance_lot_number, ce1_collating_seq = cnvtint(substring(13,3,ce1.collating_seq)),
  ce2_collating_seq = cnvtint(substring(13,3,ce2.collating_seq))
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   clinical_event ce1,
   ce_med_result cmr1,
   clinical_event ce2,
   ce_med_result cmr2,
   ce_event_note cen,
   long_blob lb
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].i_cnt))
   JOIN (d2)
   JOIN (ce1
   WHERE (work->encntrs[d1.seq].ivs[d2.seq].order_id=ce1.order_id)
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime
   (work->encntrs[d1.seq].disch_dt_tm)
    AND ce1.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce1.event_title_text="IVPARENT"
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr1
   WHERE ce1.event_id=cmr1.event_id
    AND cmr1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce1.event_id != ce2.event_id
    AND ce2.event_class_cd != cs53_placeholder_cd
    AND ce2.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime
   (work->encntrs[d1.seq].disch_dt_tm)
    AND ce2.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr2
   WHERE ce2.event_id=cmr2.event_id
    AND cmr2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cen
   WHERE outerjoin(ce1.event_id)=cen.event_id
    AND cen.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (lb
   WHERE outerjoin(cen.ce_event_note_id)=lb.parent_entity_id
    AND lb.parent_entity_name=outerjoin("CE_EVENT_NOTE"))
  ORDER BY ce1.encntr_id, ce1.order_id, cmr1.substance_lot_number,
   ce1_collating_seq, ce2_collating_seq
  HEAD REPORT
   b_cnt = 0, e_cnt = 0, tmp_o = 0
  HEAD ce1.order_id
   tmp_o = 0, stat = locateval(tmp_o,1,work->encntrs[d1.seq].ord_grps[ord_grp_iv].o_cnt,ce1.order_id,
    work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].order_id)
   IF ((work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].order_id=ce1.order_id))
    work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].doc_ind = 1
   ENDIF
   b_cnt = 0, e_cnt = 0
  HEAD cmr1.substance_lot_number
   b_cnt = (work->encntrs[d1.seq].ivs[d2.seq].b_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs[
    d2.seq].bags,b_cnt), work->encntrs[d1.seq].ivs[d2.seq].b_cnt = b_cnt,
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].substance_lot_number = cmr1.substance_lot_number,
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].initial_volume = cmr1.initial_volume, work->encntrs[
   d1.seq].ivs[d2.seq].bags[b_cnt].dosage_unit = uar_get_code_display(cmr1.dosage_unit_cd),
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].admin_route = uar_get_code_display(cmr1
    .admin_route_cd), work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].admin_site = uar_get_code_display
   (cmr1.admin_site_cd), work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].infusion_rate = cmr1
   .infusion_rate,
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].infusion_unit = uar_get_code_display(cmr1
    .infusion_unit_cd), work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].diluent_type =
   uar_get_code_display(cmr2.diluent_type_cd), work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[
   tmp_o].disp = build2(work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].disp,char(10),
    "Bag # ",trim(cmr1.substance_lot_number,3)," @ ",
    format(ce1.event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")),
   CALL echo(work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].disp), work->encntrs[d1.seq].
   ord_grps[ord_grp_iv].orders[tmp_o].disp = build2(work->encntrs[d1.seq].ord_grps[ord_grp_iv].
    orders[tmp_o].disp,char(10),"Site: ",trim(uar_get_code_display(cmr1.admin_site_cd),3)), e_cnt = 0
  DETAIL
   b_cnt = work->encntrs[d1.seq].ivs[d2.seq].b_cnt, e_cnt = (work->encntrs[d1.seq].ivs[d2.seq].bags[
   b_cnt].e_cnt+ 1), stat = alterlist(work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events,e_cnt),
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].e_cnt = e_cnt, work->encntrs[d1.seq].ivs[d2.seq].
   bags[b_cnt].events[e_cnt].event_id = ce2.event_id, work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].
   events[e_cnt].event_end_dt_tm = ce2.event_end_dt_tm,
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events[e_cnt].iv_event = uar_get_code_display(cmr2
    .iv_event_cd), work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events[e_cnt].admin_site =
   uar_get_code_display(cmr2.admin_site_cd), work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events[
   e_cnt].admin_dosage = cmr2.admin_dosage,
   work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events[e_cnt].admin_start_dt_tm = cmr2
   .admin_start_dt_tm, work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].events[e_cnt].admin_end_dt_tm =
   cmr2.admin_end_dt_tm
   IF (cmr2.admin_dosage > 0)
    work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].disp = build2(work->encntrs[d1.seq].
     ord_grps[ord_grp_iv].orders[tmp_o].disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3),
     " ",trim(cnvtstring(cmr2.admin_dosage),3),
     " ",work->encntrs[d1.seq].ivs[d2.seq].bags[b_cnt].dosage_unit," @ ",format(ce2.event_end_dt_tm,
      "MM/DD/YYYY HH:MM;;D"))
   ENDIF
   IF (cen.event_id=ce1.event_id
    AND cen.ce_event_note_id=lb.parent_entity_id)
    blob_in = fillstring(32000," "), blob_out = fillstring(32000," "), blob_out2 = fillstring(32000,
     " "),
    blob_out3 = fillstring(32000," "), blob_ret_len = 0
    IF (cen.compression_cd=cs120_ocfcomp_cd)
     blob_in = lb.long_blob,
     CALL uar_ocf_uncompress(blob_in,32000,blob_out,32000,blob_ret_len), blob_out2 = replace(blob_out,
      char(013),"",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ELSE
     blob_out2 = replace(lb.long_blob,char(013),"",0), blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ENDIF
    CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0), work->encntrs[d1.seq].ivs[d2
    .seq].bags[b_cnt].events[e_cnt].comments = trim(blob_out3,3), work->encntrs[d1.seq].ord_grps[
    ord_grp_iv].orders[tmp_o].disp = build2(work->encntrs[d1.seq].ord_grps[ord_grp_iv].orders[tmp_o].
     disp,char(10),trim(uar_get_code_display(cmr2.iv_event_cd),3)," Comments: ",trim(blob_out3,3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   clinical_event ce,
   ce_med_result cmr,
   ce_event_note cen,
   long_blob lb
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].ord_grps[ord_grp_meds].o_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id=o.order_id))
   JOIN (ce
   WHERE o.encntr_id=ce.encntr_id
    AND ce.order_id=o.order_id
    AND ce.event_class_cd != cs53_placeholder_cd
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr
   WHERE ce.event_id=cmr.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cen
   WHERE outerjoin(ce.event_id)=cen.event_id)
   JOIN (lb
   WHERE outerjoin(cen.ce_event_note_id)=lb.parent_entity_id
    AND lb.parent_entity_name=outerjoin("CE_EVENT_NOTE"))
  ORDER BY d1.seq, d2.seq, ce.event_end_dt_tm
  HEAD REPORT
   e_cnt = 0, c_cnt = 0, blob_in = fillstring(32000," "),
   blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
    " "),
   blob_ret_len = 0
  HEAD cmr.event_id
   work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].doc_ind = 1, e_cnt = (work->encntrs[d1
   .seq].ord_grps[ord_grp_meds].orders[d2.seq].e_cnt+ 1), work->encntrs[d1.seq].ord_grps[ord_grp_meds
   ].orders[d2.seq].e_cnt = e_cnt,
   stat = alterlist(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events,e_cnt), work->
   encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].admin_dt_tm = ce
   .event_end_dt_tm, work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].
   admin_site = uar_get_code_display(cmr.admin_site_cd)
   IF (trim(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].admin_site,3)
    > " ")
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].disp = build2(work->encntrs[d1.seq].
     ord_grps[ord_grp_meds].orders[d2.seq].disp,char(10),"Admin @ ",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;D"),char(10),
     "Site: ",trim(uar_get_code_display(cmr.admin_site_cd),3))
   ENDIF
  DETAIL
   IF (lb.parent_entity_id > 0.00)
    c_cnt = (work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].c_cnt+ 1),
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].c_cnt = c_cnt, stat =
    alterlist(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].comments,
     c_cnt),
    blob_in = fillstring(32000," "), blob_out = fillstring(32000," "), blob_out2 = fillstring(32000,
     " "),
    blob_out3 = fillstring(32000," "), blob_ret_len = 0
    IF (cen.compression_cd=cs120_ocfcomp_cd)
     blob_in = lb.long_blob,
     CALL uar_ocf_uncompress(blob_in,32000,blob_out,32000,blob_ret_len), blob_out2 = replace(blob_out,
      char(013),"",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ELSE
     blob_out2 = replace(lb.long_blob,char(013),"",0), blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ENDIF
    CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0), work->encntrs[d1.seq].
    ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].comments[c_cnt].type = cen.note_type_cd, work
    ->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].comments[c_cnt].text = trim
    (blob_out3,3),
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].disp = build2(work->encntrs[d1.seq].
     ord_grps[ord_grp_meds].orders[d2.seq].disp,char(10),"Comments: ",trim(blob_out3,3))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value(work->e_cnt)),
   dummyt d2,
   orders o,
   clinical_event ce,
   ce_med_result cmr,
   ce_event_note cen,
   long_blob lb
  PLAN (d1
   WHERE maxrec(d2,work->encntrs[d1.seq].ord_grps[ord_grp_meds].o_cnt))
   JOIN (d2)
   JOIN (o
   WHERE (work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].order_id=o.template_order_id))
   JOIN (ce
   WHERE o.encntr_id=ce.encntr_id
    AND ce.order_id=o.order_id
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(work->encntrs[d1.seq].create_dt_tm) AND cnvtdatetime(
    work->encntrs[d1.seq].disch_dt_tm)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cmr
   WHERE ce.event_id=cmr.event_id)
   JOIN (cen
   WHERE outerjoin(ce.event_id)=cen.event_id)
   JOIN (lb
   WHERE outerjoin(cen.ce_event_note_id)=lb.parent_entity_id
    AND lb.parent_entity_name=outerjoin("CE_EVENT_NOTE"))
  ORDER BY d1.seq, d2.seq, ce.event_end_dt_tm
  HEAD REPORT
   e_cnt = 0, c_cnt = 0, blob_in = fillstring(32000," "),
   blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
    " "),
   blob_ret_len = 0
  HEAD cmr.event_id
   work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].doc_ind = 1, e_cnt = (work->encntrs[d1
   .seq].ord_grps[ord_grp_meds].orders[d2.seq].e_cnt+ 1), work->encntrs[d1.seq].ord_grps[ord_grp_meds
   ].orders[d2.seq].e_cnt = e_cnt,
   stat = alterlist(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events,e_cnt), work->
   encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].admin_dt_tm = ce
   .event_end_dt_tm, work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].
   admin_site = uar_get_code_display(cmr.admin_site_cd)
   IF (trim(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].admin_site,3)
    > " ")
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].disp = build2(work->encntrs[d1.seq].
     ord_grps[ord_grp_meds].orders[d2.seq].disp,char(10),"Admin @ ",format(ce.event_end_dt_tm,
      "MM/DD/YY HH:MM;;D"),char(10),
     "Site: ",trim(uar_get_code_display(cmr.admin_site_cd),3))
   ENDIF
  DETAIL
   IF (lb.parent_entity_id > 0.00)
    c_cnt = (work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].c_cnt+ 1),
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].c_cnt = c_cnt, stat =
    alterlist(work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].comments,
     c_cnt),
    blob_in = fillstring(32000," "), blob_out = fillstring(32000," "), blob_out2 = fillstring(32000,
     " "),
    blob_out3 = fillstring(32000," "), blob_ret_len = 0
    IF (cen.compression_cd=cs120_ocfcomp_cd)
     blob_in = lb.long_blob,
     CALL uar_ocf_uncompress(blob_in,32000,blob_out,32000,blob_ret_len), blob_out2 = replace(blob_out,
      char(013),"",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ELSE
     blob_out2 = replace(lb.long_blob,char(013),"",0), blob_out2 = replace(blob_out2,"ocf_blob","",0)
    ENDIF
    CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0), work->encntrs[d1.seq].
    ord_grps[ord_grp_meds].orders[d2.seq].events[e_cnt].comments[c_cnt].text = trim(blob_out3,3),
    work->encntrs[d1.seq].ord_grps[ord_grp_meds].orders[d2.seq].disp = build2(work->encntrs[d1.seq].
     ord_grps[ord_grp_meds].orders[d2.seq].disp,char(10),"Comments: ",trim(blob_out3,3))
   ENDIF
  WITH nocounter
 ;end select
 DECLARE s_cnt = i4
 DECLARE c_cnt = i4
 DECLARE l_cnt = i4
 DECLARE tmp_l = i4
 DECLARE tmp_c = i4
 FOR (e = 1 TO work->e_cnt)
   SET s_cnt = 0
   SET c_cnt = 0
   SET l_cnt = 0
   SET tmp_l = 0
   SET tmp_c = 0
   CALL echo(" ")
   CALL echo(build2("Begin Patient: ",work->encntrs[e].fin," (",trim(cnvtstring(e)),")"))
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "PATDATA"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 9
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Patient{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}MRN{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 166
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Acct #{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 204
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}DOB{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 248
   SET work->encntrs[e].sections[s_cnt].columns[5].header = "{B}{U}Reg Location{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = 322
   SET work->encntrs[e].sections[s_cnt].columns[6].header = "{B}{U}Reg Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[6].x_pos = 380
   SET work->encntrs[e].sections[s_cnt].columns[7].header = "{B}{U}Disch Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[7].x_pos = 452
   SET work->encntrs[e].sections[s_cnt].columns[8].header = "{B}{U}Providers{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[8].x_pos = 524
   SET work->encntrs[e].sections[s_cnt].columns[9].header = "{B}{U}Allergies{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[9].x_pos = 650
   IF ((work->encntrs[e].person_id=0.00))
    SET l_cnt = 1
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[1].text = "Non-ED Patient"
    GO TO end_enc_loop
   ELSE
    SET l_cnt = 1
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[1].text = work->encntrs[e].patient_name
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[2].text = work->encntrs[e].mrn
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[3].text = work->encntrs[e].fin
    SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[4].text = concat(format(work->encntrs[e
      ].birth_dt_tm,"MM/DD/YYYY;;D")," (",trim(replace(cnvtage(work->encntrs[e].birth_dt_tm),
       "0123456789","0123456789",3),3),")")
    IF (maxval(work->encntrs[e].eh_cnt,work->encntrs[e].r_cnt,work->encntrs[e].a_cnt) <= 0)
     CALL echo("No History, Reltns, or Allergies")
    ELSE
     SET l_cnt = maxval(work->encntrs[e].eh_cnt,work->encntrs[e].r_cnt,work->encntrs[e].a_cnt)
     IF (l_cnt > 1)
      SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
      FOR (l = 2 TO l_cnt)
       SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
      ENDFOR
     ENDIF
     IF ((work->encntrs[e].eh_cnt <= 0))
      CALL echo("No History")
     ELSE
      FOR (eh = 1 TO work->encntrs[e].eh_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[eh].columns[5].text = substring(1,13,work->
         encntrs[e].enc_hist[eh].nurse_unit)
        IF (eh=1)
         SET work->encntrs[e].sections[s_cnt].lines[eh].columns[6].text = format(work->encntrs[e].
          admit_dt_tm,"MM/DD/YYYY HH:MM;;D")
        ELSE
         SET work->encntrs[e].sections[s_cnt].lines[eh].columns[6].text = format(work->encntrs[e].
          enc_hist[eh].trans_dt_tm,"MM/DD/YYYY HH:MM;;D")
        ENDIF
        IF ((eh=work->encntrs[e].eh_cnt))
         IF ((work->encntrs[e].disch_ind=1))
          SET work->encntrs[e].sections[s_cnt].lines[eh].columns[7].text = format(work->encntrs[e].
           disch_dt_tm,"MM/DD/YYYY HH:MM;;D")
         ELSEIF ((work->encntrs[e].disch_ind=2))
          SET work->encntrs[e].sections[s_cnt].lines[eh].columns[7].text = "Transferred"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF ((work->encntrs[e].r_cnt <= 0))
      CALL echo("No Reltns")
     ELSE
      FOR (r = 1 TO work->encntrs[e].r_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[r].columns[8].text = work->encntrs[e].reltns[r].
        prsnl_name
      ENDFOR
     ENDIF
     IF ((work->encntrs[e].a_cnt=0))
      CALL echo("No Allergies")
     ELSE
      FOR (a = 1 TO work->encntrs[e].a_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[a].columns[9].text = work->encntrs[e].allergies[a]
        .substance
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "VITALS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 7
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Date/Time{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}Temp{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 90
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Pulse{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 126
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}Resp Rate{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 162
   SET work->encntrs[e].sections[s_cnt].columns[5].header = "{B}{U}BP{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = 216
   SET work->encntrs[e].sections[s_cnt].columns[6].header = "{B}{U}O2 Sat (Mode){ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[6].x_pos = 252
   SET work->encntrs[e].sections[s_cnt].columns[7].header = "{B}{U}Weight{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[7].x_pos = 342
   IF ((work->encntrs[e].v_cnt <= 0))
    CALL echo("No Vitals")
   ELSE
    SET work->encntrs[e].sections[s_cnt].l_cnt = work->encntrs[e].v_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,work->encntrs[e].v_cnt)
    FOR (v = 1 TO work->encntrs[e].v_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[v].c_cnt = c_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[v].columns,c_cnt)
      SET work->encntrs[e].sections[s_cnt].lines[v].columns[1].text = format(work->encntrs[e].vitals[
       v].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")
      FOR (r = 1 TO work->encntrs[e].vitals[v].r_cnt)
        IF ((work->encntrs[e].vitals[v].results[r].type="Temp"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[2].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Pulse"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[3].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Respiratory Rate"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[4].text = work->encntrs[e].vitals[v].
         results[r].value
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Systolic BP"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[5].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(work->encntrs[e].
           vitals[v].results[r].value,"/x")
         ELSE
          IF (substring(1,2,work->encntrs[e].sections[s_cnt].lines[v].columns[5].text)="x/")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(work->encntrs[e].
            vitals[v].results[r].value,substring(2,(size(work->encntrs[e].sections[s_cnt].lines[v].
              columns[5].text) - 1),work->encntrs[e].sections[s_cnt].lines[v].columns[5].text))
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Diastolic BP"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[5].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat("x/",work->encntrs[e
           ].vitals[v].results[r].value)
         ELSE
          IF (substring((size(work->encntrs[e].sections[s_cnt].lines[v].columns[5].text) - 1),2,work
           ->encntrs[e].sections[s_cnt].lines[v].columns[5].text)="/x")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[5].text = concat(substring(1,(size(
              work->encntrs[e].sections[s_cnt].lines[v].columns[5].text) - 1),work->encntrs[e].
             sections[s_cnt].lines[v].columns[5].text),work->encntrs[e].vitals[v].results[r].value)
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="O2 Sat"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[6].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(work->encntrs[e].
           vitals[v].results[r].value," (x)")
         ELSE
          IF (substring(1,1,work->encntrs[e].sections[s_cnt].lines[v].columns[6].text)="x")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(work->encntrs[e].
            vitals[v].results[r].value,substring(2,(size(work->encntrs[e].sections[s_cnt].lines[v].
              columns[6].text) - 1),work->encntrs[e].sections[s_cnt].lines[v].columns[6].text))
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Mode of Delivery"))
         IF ((work->encntrs[e].sections[s_cnt].lines[v].columns[6].text <= " "))
          SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat("x (",work->encntrs[
           e].vitals[v].results[r].value,")")
         ELSE
          IF (substring((size(work->encntrs[e].sections[s_cnt].lines[v].columns[6].text) - 2),3,work
           ->encntrs[e].sections[s_cnt].lines[v].columns[6].text)="(x)")
           SET work->encntrs[e].sections[s_cnt].lines[v].columns[6].text = concat(substring(1,(size(
              work->encntrs[e].sections[s_cnt].lines[v].columns[6].text) - 2),work->encntrs[e].
             sections[s_cnt].lines[v].columns[6].text),work->encntrs[e].vitals[v].results[r].value,
            ")")
          ENDIF
         ENDIF
        ELSEIF ((work->encntrs[e].vitals[v].results[r].type="Weight"))
         SET work->encntrs[e].sections[s_cnt].lines[v].columns[7].text = work->encntrs[e].vitals[v].
         results[r].value
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "ORDERSGRP1"
   SET work->encntrs[e].sections[s_cnt].type = 2
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 5
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Med Orders{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].header = "{B}{U}IV Fluids{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 168
   SET work->encntrs[e].sections[s_cnt].columns[3].header = "{B}{U}Oxygen{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 318
   SET work->encntrs[e].sections[s_cnt].columns[4].header = "{B}{U}Other Orders{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[4].x_pos = 468
   SET l_cnt = 0
   SET tmp_c = 0
   FREE RECORD tmp
   RECORD tmp(
     1 grp[*]
       2 num = i4
   )
   SET stat = alterlist(tmp->grp,4)
   SET tmp->grp[1].num = ord_grp_meds
   SET tmp->grp[2].num = ord_grp_iv
   SET tmp->grp[3].num = ord_grp_oxygen
   SET tmp->grp[4].num = ord_grp_other
   FOR (og = 1 TO size(tmp->grp,5))
    IF ((tmp->grp[og].num=ord_grp_meds))
     SET tmp_c = 1
    ELSEIF ((tmp->grp[og].num=ord_grp_iv))
     SET tmp_c = 2
    ELSEIF ((tmp->grp[og].num=ord_grp_oxygen))
     SET tmp_c = 3
    ELSEIF ((tmp->grp[og].num=ord_grp_other))
     SET tmp_c = 4
    ENDIF
    FOR (o = 1 TO work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt)
      IF ((tmp->grp[og].num IN (ord_grp_meds, ord_grp_iv)))
       IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Discontinued"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("DC ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Completed"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("C  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].doc_ind != 1))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("*  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSE
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("S  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ENDIF
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,5)
      ELSEIF ((tmp->grp[og].num=ord_grp_other))
       IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Completed"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("C  ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSEIF ((work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_status="Discontinued"))
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("DC ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ELSE
        SET work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp = build2("   ",work->encntrs[e
         ].ord_grps[tmp->grp[og].num].orders[o].disp)
       ENDIF
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,5)
      ELSE
       CALL rw_wrap(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp,36,2)
      ENDIF
      IF (((work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line+ wrap_return->l_cnt) > l_cnt))
       SET l_cnt = (work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line+ wrap_return->l_cnt)
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
       FOR (l = work->encntrs[e].sections[s_cnt].l_cnt TO l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
       ENDFOR
       SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      ENDIF
      FOR (l = 1 TO wrap_return->l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[(l+ work->encntrs[e].sections[s_cnt].columns[tmp_c
        ].last_line)].columns[tmp_c].text = wrap_return->lines[l].text
      ENDFOR
      SET work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line = (work->encntrs[e].sections[
      s_cnt].columns[tmp_c].last_line+ wrap_return->l_cnt)
    ENDFOR
   ENDFOR
   FREE RECORD tmp
   IF ((work->encntrs[e].ord_grps[ord_grp_meds].o_cnt <= 0))
    CALL echo("No Medications")
   ENDIF
   IF ((work->encntrs[e].ord_grps[ord_grp_iv].o_cnt <= 0))
    CALL echo("No IV Fluids")
   ENDIF
   IF ((work->encntrs[e].ord_grps[ord_grp_oxygen].o_cnt <= 0))
    CALL echo("No Oxygen orders")
   ENDIF
   IF ((work->encntrs[e].ord_grps[ord_grp_other].o_cnt <= 0))
    CALL echo("No Other orders")
   ENDIF
   SET tmp_c = 0
   SET col_width = 150
   IF (maxval(work->encntrs[e].sections[s_cnt].columns[1].last_line,work->encntrs[e].sections[s_cnt].
    columns[2].last_line,work->encntrs[e].sections[s_cnt].columns[3].last_line,work->encntrs[e].
    sections[s_cnt].columns[4].last_line) > 1)
    FOR (c = 1 TO 4)
      IF (tmp_c=0
       AND (work->encntrs[e].sections[s_cnt].columns[c].last_line=maxval(work->encntrs[e].sections[
       s_cnt].columns[1].last_line,work->encntrs[e].sections[s_cnt].columns[2].last_line,work->
       encntrs[e].sections[s_cnt].columns[3].last_line,work->encntrs[e].sections[s_cnt].columns[4].
       last_line)))
       SET tmp_c = c
      ENDIF
    ENDFOR
    IF (tmp_c > 0)
     IF (mod(l_cnt,2)=0)
      SET tmp_l = (cnvtint((l_cnt/ 2))+ 1)
     ELSE
      SET tmp_l = (cnvtint((l_cnt/ 2))+ 2)
     ENDIF
     FOR (c = 1 TO 4)
       IF (c != tmp_c
        AND (tmp_l < work->encntrs[e].sections[s_cnt].columns[c].last_line))
        SET tmp_l = work->encntrs[e].sections[s_cnt].columns[c].last_line
       ENDIF
     ENDFOR
     WHILE (substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text)=" "
      AND tmp_l < l_cnt)
       SET tmp_l = (tmp_l+ 1)
     ENDWHILE
     IF (tmp_l <= l_cnt
      AND substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text) != " ")
      SET work->encntrs[e].sections[s_cnt].columns[5].x_pos = (work->encntrs[e].sections[s_cnt].
      columns[tmp_c].x_pos+ col_width)
      FOR (c = (tmp_c+ 1) TO 4)
        SET work->encntrs[e].sections[s_cnt].columns[c].x_pos = (work->encntrs[e].sections[s_cnt].
        columns[c].x_pos+ col_width)
      ENDFOR
      FOR (l = tmp_l TO l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[((l - tmp_l)+ 1)].columns[5].text = work->encntrs[
        e].sections[s_cnt].lines[l].columns[tmp_c].text
      ENDFOR
      SET l_cnt = (tmp_l - 1)
      SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
      SET work->encntrs[e].sections[s_cnt].columns[tmp_c].last_line = l_cnt
     ENDIF
    ENDIF
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "LABRESULTS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Laboratory Results{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   IF ((work->encntrs[e].total_r_cnt <= 0))
    CALL echo("No Lab Results")
   ELSE
    SET l_cnt = 0
    IF (mod((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].total_r_cnt),c_cnt)
     > 0)
     SET l_cnt = (cnvtint(((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].
      total_r_cnt)/ c_cnt))+ 1)
    ELSE
     SET l_cnt = cnvtint(((work->encntrs[e].ord_grps[ord_grp_lab_comp].o_cnt+ work->encntrs[e].
      total_r_cnt)/ c_cnt))
    ENDIF
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    FOR (l = 1 TO l_cnt)
     SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
     SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
    ENDFOR
    SET tmp_l = 0
    SET tmp_c = 1
    SET event_disp_len = 18
    FOR (l = 1 TO work->encntrs[e].l_cnt)
      IF ((work->encntrs[e].labs[l].r_cnt > 0))
       IF (tmp_l < l_cnt)
        SET tmp_l = (tmp_l+ 1)
       ELSE
        SET tmp_l = 1
        SET tmp_c = (tmp_c+ 1)
       ENDIF
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = concat("{U}",work->
        encntrs[e].labs[l].desc,"{ENDU}")
       FOR (r = 1 TO work->encntrs[e].labs[l].r_cnt)
         IF (tmp_l < l_cnt)
          SET tmp_l = (tmp_l+ 1)
         ELSE
          SET tmp_l = 1
          SET tmp_c = (tmp_c+ 1)
         ENDIF
         IF (size(work->encntrs[e].labs[l].results[r].desc) > event_disp_len)
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work
            ->encntrs[e].labs[l].results[r].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",substring(1,(
            event_disp_len - 3),work->encntrs[e].labs[l].results[r].desc),"...  ",work->encntrs[e].
           labs[l].results[r].value,
           " ",work->encntrs[e].labs[l].results[r].units," ")
         ELSE
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work
            ->encntrs[e].labs[l].results[r].event_end_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",substring(1,
            event_disp_len,work->encntrs[e].labs[l].results[r].desc),"  ",work->encntrs[e].labs[l].
           results[r].value,
           " ",work->encntrs[e].labs[l].results[r].units," ")
         ENDIF
         IF ((work->encntrs[e].labs[l].results[r].mod_ind=1))
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(work->
           encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text," (m)")
         ENDIF
         IF (size(work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text) > 60)
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(substring(1,
            57,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text),"...")
         ENDIF
         IF ((work->encntrs[e].labs[l].results[r].normalcy > " "))
          SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2("{B}",work->
           encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text," ",work->encntrs[e].labs[l].
           results[r].normalcy,"{ENDB}")
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "PENDINGLABS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Pending Labs{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET event_disp_len = 23
   IF ((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt <= 0))
    CALL echo("No Pending Labs")
   ELSE
    SET l_cnt = 0
    IF (mod(work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt,c_cnt) > 0)
     SET l_cnt = (cnvtint((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt/ c_cnt))+ 1)
    ELSE
     SET l_cnt = cnvtint((work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt/ c_cnt))
    ENDIF
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
    SET tmp_l = 0
    SET tmp_c = 1
    FOR (o = 1 TO work->encntrs[e].ord_grps[ord_grp_lab_pend].o_cnt)
      IF (tmp_l < l_cnt)
       SET tmp_l = (tmp_l+ 1)
      ELSE
       SET tmp_l = 1
       SET tmp_c = (tmp_c+ 1)
      ENDIF
      IF (tmp_c=1)
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].c_cnt = c_cnt
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[tmp_l].columns,c_cnt)
      ENDIF
      IF (size(work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp) >= event_disp_len)
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work->
         encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
        substring(1,(event_disp_len - 3),work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp),
        "...  ",substring(1,13,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].dept_status))
      ELSE
       SET work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[tmp_c].text = build2(format(work->
         encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
        substring(1,event_disp_len,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].disp),"  ",
        substring(1,13,work->encntrs[e].ord_grps[ord_grp_lab_pend].orders[o].dept_status))
      ENDIF
    ENDFOR
   ENDIF
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "ORDERSGRP2"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header =
   "{B}{U}All Other Ancillary Orders (Radiology, Micro, ECG, Blood Bank, etc.){ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET l_cnt = 0
   SET event_disp_len = 23
   FREE RECORD tmp
   RECORD tmp(
     1 grp[*]
       2 num = i4
   )
   SET stat = alterlist(tmp->grp,7)
   SET tmp->grp[1].num = ord_grp_rad
   SET tmp->grp[2].num = ord_grp_micro
   SET tmp->grp[3].num = ord_grp_ecg
   SET tmp->grp[4].num = ord_grp_blood
   SET tmp->grp[5].num = ord_grp_neuro
   SET tmp->grp[6].num = ord_grp_pulm
   SET tmp->grp[7].num = ord_grp_card
   FOR (og = 1 TO size(tmp->grp,5))
    SET tmp_c = 0
    IF ((work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt <= 0))
     IF ((tmp->grp[og].num=ord_grp_rad))
      CALL echo("No Radiology Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_micro))
      CALL echo("No Microbiology Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_ecg))
      CALL echo("No ECG Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_blood))
      CALL echo("No Blood Bank Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_neuro))
      CALL echo("No Neurology Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_pulm))
      CALL echo("No Pulmonary Orders")
     ELSEIF ((tmp->grp[og].num=ord_grp_card))
      CALL echo("No Cardiology Orders")
     ENDIF
    ELSE
     SET l_cnt = (l_cnt+ 1)
     SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
     SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
     FOR (o = 1 TO work->encntrs[e].ord_grps[tmp->grp[og].num].o_cnt)
       IF (tmp_c < c_cnt)
        SET tmp_c = (tmp_c+ 1)
       ELSE
        SET tmp_c = 1
        SET l_cnt = (l_cnt+ 1)
       ENDIF
       IF (tmp_c=1)
        SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[l_cnt].c_cnt = c_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l_cnt].columns,c_cnt)
       ENDIF
       IF (size(work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp) >= event_disp_len)
        SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
          encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
         substring(1,(event_disp_len - 3),work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp),
         "...  ",substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status))
       ELSE
        SET work->encntrs[e].sections[s_cnt].lines[l_cnt].columns[tmp_c].text = build2(format(work->
          encntrs[e].ord_grps[tmp->grp[og].num].orders[o].order_dt_tm,"MM/DD/YYYY HH:MM;;D"),"  ",
         substring(1,event_disp_len,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].disp),"  ",
         substring(1,13,work->encntrs[e].ord_grps[tmp->grp[og].num].orders[o].dept_status))
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   FREE RECORD tmp
   SET s_cnt = (work->encntrs[e].s_cnt+ 1)
   SET work->encntrs[e].s_cnt = s_cnt
   SET stat = alterlist(work->encntrs[e].sections,s_cnt)
   SET work->encntrs[e].sections[s_cnt].desc = "SCRIPTS"
   SET work->encntrs[e].sections[s_cnt].type = 1
   CALL echo(build2("Begin Section: ",work->encntrs[e].sections[s_cnt].desc))
   SET c_cnt = 3
   SET work->encntrs[e].sections[s_cnt].c_cnt = c_cnt
   SET stat = alterlist(work->encntrs[e].sections[s_cnt].columns,c_cnt)
   SET work->encntrs[e].sections[s_cnt].columns[1].header = "{B}{U}Prescriptions Written{ENDB}{ENDU}"
   SET work->encntrs[e].sections[s_cnt].columns[1].x_pos = 18
   SET work->encntrs[e].sections[s_cnt].columns[2].x_pos = 261
   SET work->encntrs[e].sections[s_cnt].columns[3].x_pos = 504
   SET l_cnt = 0
   IF ((work->encntrs[e].ord_grps[ord_grp_scripts].o_cnt <= 0))
    CALL echo("No Prescriptions")
   ELSE
    FOR (o = 1 TO work->encntrs[e].ord_grps[ord_grp_scripts].o_cnt)
      CALL rw_wrap(work->encntrs[e].ord_grps[ord_grp_scripts].orders[o].disp,55,2)
      IF (((work->encntrs[e].sections[s_cnt].columns[1].last_line+ wrap_return->l_cnt) > l_cnt))
       SET l_cnt = (work->encntrs[e].sections[s_cnt].columns[1].last_line+ wrap_return->l_cnt)
       SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
       FOR (l = work->encntrs[e].sections[s_cnt].l_cnt TO l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[l].c_cnt = c_cnt
        SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines[l].columns,c_cnt)
       ENDFOR
       SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
      ENDIF
      FOR (l = 1 TO wrap_return->l_cnt)
        SET work->encntrs[e].sections[s_cnt].lines[(l+ work->encntrs[e].sections[s_cnt].columns[1].
        last_line)].columns[1].text = wrap_return->lines[l].text
      ENDFOR
      SET work->encntrs[e].sections[s_cnt].columns[1].last_line = (work->encntrs[e].sections[s_cnt].
      columns[1].last_line+ wrap_return->l_cnt)
    ENDFOR
    FOR (c = 1 TO (c_cnt - 1))
      SET tmp_l = 0
      SET work->encntrs[e].sections[s_cnt].columns[c].last_line = l_cnt
      IF (l_cnt > 1)
       IF (mod(l_cnt,((c_cnt - c)+ 1))=0)
        SET tmp_l = (cnvtint((l_cnt/ ((c_cnt - c)+ 1)))+ 1)
       ELSE
        SET tmp_l = (cnvtint((l_cnt/ ((c_cnt - c)+ 1)))+ 2)
       ENDIF
       WHILE (substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[c].text)=" "
        AND tmp_l < l_cnt)
         SET tmp_l = (tmp_l+ 1)
       ENDWHILE
       IF (tmp_l <= l_cnt
        AND substring(1,1,work->encntrs[e].sections[s_cnt].lines[tmp_l].columns[c].text) != " ")
        FOR (l = tmp_l TO l_cnt)
         SET work->encntrs[e].sections[s_cnt].lines[((l - tmp_l)+ 1)].columns[(c+ 1)].text = work->
         encntrs[e].sections[s_cnt].lines[l].columns[c].text
         SET work->encntrs[e].sections[s_cnt].lines[l].columns[c].text = ""
        ENDFOR
        SET work->encntrs[e].sections[s_cnt].columns[c].last_line = (tmp_l - 1)
        SET l_cnt = ((l_cnt - tmp_l)+ 1)
       ENDIF
      ENDIF
    ENDFOR
    SET l_cnt = maxval(work->encntrs[e].sections[s_cnt].columns[1].last_line,work->encntrs[e].
     sections[s_cnt].columns[2].last_line,work->encntrs[e].sections[s_cnt].columns[3].last_line)
    SET work->encntrs[e].sections[s_cnt].l_cnt = l_cnt
    SET stat = alterlist(work->encntrs[e].sections[s_cnt].lines,l_cnt)
   ENDIF
   CALL echo(" ")
#end_enc_loop
 ENDFOR
 FREE SET s_cnt
 FREE SET l_cnt
 FREE SET c_cnt
 FREE SET tmp_l
 FREE SET tmp_c
 SELECT INTO value(var_output)
  FROM dummyt d
  HEAD REPORT
   tmp_x = 0, tmp_y = 0, rotate_ind = 0,
   new_rpt = 0, tmp_pg_cnt = 0, col 0,
   "{F/0}{CPI/18}{LPI/9}{PS/792 0 translate 90 rotate/}", row + 1
  HEAD PAGE
   IF (rotate_ind=1)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   tmp_y = 8, col 0,
   CALL print(build2(calcpos(18,tmp_y),"{B}ED Orders/Results Summary (ORS) Report{ENDB}")),
   row + 1, tmp_y = (tmp_y+ 8)
   IF ((e <= work->e_cnt))
    col 0,
    CALL print(build2(calcpos(504,8),"{B}All Orders/Results from ",format(work->encntrs[e].
      create_dt_tm,"MM/DD/YYYY HH:MM;;D")," to ",format(work->encntrs[e].disch_dt_tm,
      "MM/DD/YYYY HH:MM;;D"),
     "{ENDB}")), row + 1
   ENDIF
   IF (new_rpt=0
    AND (e <= work->e_cnt))
    FOR (tmp_s = 1 TO work->encntrs[e].s_cnt)
      IF ((work->encntrs[e].sections[tmp_s].desc="PATDATA"))
       tmp_y = (tmp_y+ 8)
       FOR (tmp_c = 1 TO work->encntrs[e].sections[tmp_s].c_cnt)
         IF ((work->encntrs[e].sections[tmp_s].columns[tmp_c].header > " "))
          tmp_x = work->encntrs[e].sections[tmp_s].columns[tmp_c].x_pos, col 0,
          CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[tmp_s].columns[tmp_c].
           header)),
          row + 1
         ENDIF
       ENDFOR
       tmp_y = (tmp_y+ 8)
       FOR (tmp_l = 1 TO work->encntrs[e].sections[tmp_s].l_cnt)
        FOR (tmp_c = 1 TO work->encntrs[e].sections[tmp_s].c_cnt)
          IF ((work->encntrs[e].sections[tmp_s].lines[tmp_l].columns[tmp_c].text > " "))
           tmp_x = work->encntrs[e].sections[tmp_s].columns[tmp_c].x_pos, col 0,
           CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[tmp_s].lines[tmp_l].
            columns[tmp_c].text)),
           row + 1
          ENDIF
        ENDFOR
        ,tmp_y = (tmp_y+ 8)
       ENDFOR
      ENDIF
    ENDFOR
    tmp_y = (tmp_y+ 8)
   ENDIF
   rotate_ind = 1
  DETAIL
   FOR (e = 1 TO work->e_cnt)
     IF (e > 1)
      BREAK, new_rpt = 0
     ENDIF
     tmp_pg_cnt = 0, col 0,
     CALL print(build2(calcpos(504,8),"{B}All Orders/Results from ",format(work->encntrs[e].
       create_dt_tm,"MM/DD/YYYY HH:MM;;D")," to ",format(work->encntrs[e].disch_dt_tm,
       "MM/DD/YYYY HH:MM;;D"),
      "{ENDB}")),
     row + 1
     FOR (s = 1 TO work->encntrs[e].s_cnt)
       IF (tmp_y < 526)
        tmp_y = (tmp_y+ 8)
       ELSE
        BREAK
       ENDIF
       FOR (c = 1 TO work->encntrs[e].sections[s].c_cnt)
         IF ((work->encntrs[e].sections[s].columns[c].header > " "))
          tmp_x = work->encntrs[e].sections[s].columns[c].x_pos, col 0,
          CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].columns[c].header)),
          row + 1
         ENDIF
       ENDFOR
       IF (tmp_y < 534)
        tmp_y = (tmp_y+ 8)
       ELSE
        BREAK
       ENDIF
       FOR (l = 1 TO work->encntrs[e].sections[s].l_cnt)
        FOR (c = 1 TO work->encntrs[e].sections[s].c_cnt)
          IF ((work->encntrs[e].sections[s].lines[l].columns[c].text > " "))
           tmp_x = work->encntrs[e].sections[s].columns[c].x_pos, col 0,
           CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].lines[l].columns[c].
            text)),
           row + 1
          ENDIF
        ENDFOR
        ,
        IF (tmp_y < 534)
         tmp_y = (tmp_y+ 8)
        ELSE
         BREAK
         FOR (c2 = 1 TO work->encntrs[e].sections[s].c_cnt)
           IF ((work->encntrs[e].sections[s].columns[c2].header > " "))
            tmp_x = work->encntrs[e].sections[s].columns[c2].x_pos, col 0,
            CALL print(build2(calcpos(tmp_x,tmp_y),work->encntrs[e].sections[s].columns[c2].header)),
            row + 1
           ENDIF
         ENDFOR
         tmp_y = (tmp_y+ 8)
        ENDIF
       ENDFOR
     ENDFOR
     new_rpt = 1
   ENDFOR
  FOOT PAGE
   tmp_pg_cnt = (tmp_pg_cnt+ 1), col 0,
   CALL print(build2(calcpos(18,552),'{B}Legend:{ENDB}  "*" = Med/IV not charted  "S" = Med/IV ',
    'series started  "C" = Completed  "DC" = Discontinued')),
   row + 1, col 0,
   CALL print(build2(calcpos(18,566),
    " {B}*** Report may not include all Downtime/Written Orders/Results ***{ENDB}")),
   row + 1, col 0,
   CALL print(build2(calcpos(605,566),"{B}Printed On ",format(cnvtdatetime(curdate,curtime3),
     "MM/DD/YYYY HH:MM;;D"),"{ENDB}")),
   row + 1
   IF (new_rpt=1)
    col 0,
    CALL print(build2(calcpos(368,566)," {B}END OF REPORT (Page ",trim(cnvtstring(tmp_pg_cnt),3),
     "){ENDB}"))
   ELSE
    col 0,
    CALL print(build2(calcpos(380,566)," {B}Page ",trim(cnvtstring(tmp_pg_cnt),3),"{ENDB}")), row + 1
   ENDIF
  WITH nocounter, maxcol = 1000, maxrow = 10000,
   format = variable, dio = 08
 ;end select
 IF (discern_rule_ind=1)
  SET retval = 100
  SET log_message = build2(trim(log_message,3)," Report printed successfully")
  CALL echo(build2("LOG_MESSAGE: ",log_message))
 ENDIF
 CALL echorecord(work,"ryan_ors_report.rs")
#exit_script
 FREE RECORD wrap_return
 FREE RECORD work
END GO
