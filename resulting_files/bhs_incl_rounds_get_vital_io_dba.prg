CREATE PROGRAM bhs_incl_rounds_get_vital_io:dba
 DECLARE get_vitals(status=i2) = i2 WITH copy
 DECLARE get_io(status=i2) = i2 WITH copy
 DECLARE declarevariables(status=i2) = i2 WITH copy
 DECLARE temp_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE pulse_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE resp_rate_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPIRATORYRATE"))
 DECLARE o2_sat_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "OXYGENSATURATION"))
 DECLARE mode_of_delivery_o2_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 DECLARE liters_per_min = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,
   "LITERSPERMINUTE"))
 DECLARE weight_cd = f8 WITH persistscript, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 IF (validate(inerror_cd)=0)
  DECLARE inerror_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"INERROR"))
  DECLARE notdone_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
  DECLARE pending_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
  DECLARE save_ycol = i2 WITH persistscript
  DECLARE placeholder_event_class_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",53,
    "PLACEHOLDER"))
 ENDIF
 SUBROUTINE get_vitals(status)
   SET weight_found = 0
   SELECT INTO "nl:"
    FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
     clinical_event ce
    PLAN (dd)
     JOIN (ce
     WHERE (ce.person_id=dlrec->seq[dd.seq].person_id)
      AND ce.event_cd IN (temp_cd, pulse_cd, resp_rate_cd, systolic_bp_cd, diastolic_bp_cd,
     o2_sat_cd, mode_of_delivery_o2_cd, weight_cd, liters_per_min)
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
      AND ((ce.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
      AND ce.view_level=1
      AND ce.event_class_cd != placeholder_event_class_cd
      AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd, pending_cd)))
    ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
    HEAD ce.encntr_id
     first_weight = 000.00, last_weight = 000.00, total_weight = 00.00,
     saved_units = "   ", stat = alterlist(dlrec->seq[dd.seq].vitals,10), vit_cnt = 0,
     vit_cnt = (vit_cnt+ 1)
     IF (mod(vit_cnt,10)=1)
      stat = alterlist(dlrec->seq[dd.seq].vitals,(vit_cnt+ 10))
     ENDIF
     low_temp_result = fillstring(10," "), high_temp_result = fillstring(10," "), low_pulse_result =
     fillstring(10," "),
     high_pulse_result = fillstring(10," "), low_sbp_result = fillstring(10," "), high_sbp_result =
     fillstring(10," "),
     low_dbp_result = fillstring(10," "), high_dbp_result = fillstring(10," "), low_rr_result =
     fillstring(10," "),
     high_rr_result = fillstring(10," "), low_o2sat_result = fillstring(10," "), high_o2sat_result =
     fillstring(10," ")
    HEAD ce.event_cd
     IF (ce.event_cd=temp_cd)
      cnt_temp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].temp_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=pulse_cd)
      cnt_pulse = 0, dlrec->seq[dd.seq].vitals[vit_cnt].pulse_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=systolic_bp_cd)
      cnt_sbp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].systolic_bp_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=diastolic_bp_cd)
      cnt_dbp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].diastolic_bp_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=resp_rate_cd)
      cnt_rr = 0, dlrec->seq[dd.seq].vitals[vit_cnt].resp_rate_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=o2_sat_cd)
      cnt_o2sat = 0, dlrec->seq[dd.seq].vitals[vit_cnt].o2_sat_result = trim(ce.result_val)
     ELSEIF (ce.event_cd=mode_of_delivery_o2_cd)
      dlrec->seq[dd.seq].vitals[vit_cnt].mode_of_delivery = trim(ce.result_val)
     ELSEIF (ce.event_cd=liters_per_min)
      dlrec->seq[dd.seq].vitals[vit_cnt].liters_per_min = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=weight_cd)
      weight_cnt = 0
     ENDIF
    DETAIL
     IF (ce.event_cd=temp_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_temp = (cnt_temp+ 1)
      IF (cnt_temp=1)
       low_temp_result = trim(ce.result_val), high_temp_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_temp_result) > cnvtreal(trim(ce.result_val)))
        low_temp_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_temp_result) < cnvtreal(trim(ce.result_val)))
        high_temp_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=pulse_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_pulse = (cnt_pulse+ 1)
      IF (cnt_pulse=1)
       low_pulse_result = trim(ce.result_val), high_pulse_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_pulse_result) > cnvtreal(trim(ce.result_val))
        AND cnvtreal(trim(ce.result_val)) > 0)
        low_pulse_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_pulse_result) < cnvtreal(trim(ce.result_val)))
        high_pulse_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=systolic_bp_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_sbp = (cnt_sbp+ 1)
      IF (cnt_sbp=1)
       low_sbp_result = trim(ce.result_val), high_sbp_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_sbp_result) > cnvtreal(trim(ce.result_val)))
        low_sbp_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_sbp_result) < cnvtreal(trim(ce.result_val)))
        high_sbp_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=diastolic_bp_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_dbp = (cnt_dbp+ 1)
      IF (cnt_dbp=1)
       low_dbp_result = trim(ce.result_val), high_dbp_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_dbp_result) > cnvtreal(trim(ce.result_val)))
        low_dbp_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_dbp_result) < cnvtreal(trim(ce.result_val)))
        high_dbp_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=resp_rate_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_rr = (cnt_rr+ 1)
      IF (cnt_rr=1)
       low_rr_result = trim(ce.result_val), high_rr_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_rr_result) > cnvtreal(trim(ce.result_val)))
        low_rr_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_rr_result) < cnvtreal(trim(ce.result_val)))
        high_rr_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=o2_sat_cd
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      cnt_o2sat = (cnt_o2sat+ 1),
      CALL echo(build(cnt_o2sat,":",ce.result_val,":",low_o2sat_result,
       ":",high_o2sat_result))
      IF (cnt_o2sat=1)
       low_o2sat_result = trim(ce.result_val), high_o2sat_result = trim(ce.result_val)
      ELSE
       IF (cnvtreal(low_o2sat_result) > cnvtreal(trim(ce.result_val)))
        low_o2sat_result = trim(ce.result_val)
       ELSEIF (cnvtreal(high_o2sat_result) < cnvtreal(trim(ce.result_val)))
        high_o2sat_result = trim(ce.result_val)
       ENDIF
      ENDIF
     ELSEIF (ce.event_cd=weight_cd)
      weight_cnt = (weight_cnt+ 1)
      IF (weight_cnt <= 3)
       stat = alterlist(dlrec->seq[dd.seq].weights,weight_cnt), dlrec->seq[dd.seq].weights[weight_cnt
       ].weight_unit = trim(uar_get_code_display(ce.result_units_cd)), dlrec->seq[dd.seq].weights[
       weight_cnt].weight_value = trim(format(cnvtreal(ce.result_val),"###.##")),
       dlrec->seq[dd.seq].weights[weight_cnt].weight_dt_tm = trim(format(ce.event_end_dt_tm,
         "MM/DD HH:MM;;D")), saved_units = trim(uar_get_code_display(ce.result_units_cd))
      ENDIF
      IF (weight_cnt=1)
       last_weight = cnvtreal(ce.result_val)
      ENDIF
      first_weight = cnvtreal(ce.result_val)
     ENDIF
    FOOT  ce.encntr_id
     dlrec->seq[dd.seq].vitals[vit_cnt].temp_range = concat(trim(low_temp_result),"-",trim(
       high_temp_result)), dlrec->seq[dd.seq].vitals[vit_cnt].pulse_range = concat(trim(
       low_pulse_result),"-",trim(high_pulse_result)), dlrec->seq[dd.seq].vitals[vit_cnt].
     systolic_bp_range = concat(trim(low_sbp_result),"-",trim(high_sbp_result)),
     dlrec->seq[dd.seq].vitals[vit_cnt].diastolic_bp_range = concat(trim(low_dbp_result),"-",trim(
       high_dbp_result)), dlrec->seq[dd.seq].vitals[vit_cnt].resp_rate_range = concat(trim(
       low_rr_result),"-",trim(high_rr_result)), dlrec->seq[dd.seq].vitals[vit_cnt].o2_sat_range =
     concat(trim(low_o2sat_result),"-",trim(high_o2sat_result)),
     dlrec->seq[dd.seq].total_vitals = vit_cnt, stat = alterlist(dlrec->seq[dd.seq].vitals,vit_cnt)
     IF (weight_cnt > 0)
      IF (first_weight > last_weight)
       total_weight = (first_weight - last_weight), total_delta = "LOSS "
      ENDIF
      IF (first_weight < last_weight)
       total_weight = (last_weight - first_weight), total_delta = "GAIN "
      ENDIF
      IF (first_weight=last_weight)
       total_weight = 00.00, total_delta = "SAME "
      ENDIF
      dlrec->seq[dd.seq].weight_change = total_weight, dlrec->seq[dd.seq].weight_up_down =
      total_delta, dlrec->seq[dd.seq].weight_tot_unit = saved_units
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET status = 1
   ELSE
    SET status = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE get_io(status)
   SELECT INTO "nl:"
    encntr_id = dlrec->seq[dd.seq].encntr_id, io_type = "Intake", 12hr_ind =
    IF (ceo.event_end_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),- ((720/ 1440.0)))) 1
    ELSE 0
    ENDIF
    ,
    event_cd = ceo.event_cd, event_end_dt_tm = ceo.event_end_dt_tm, result_val = ceo.result_val,
    event_display = trim(o.ordered_as_mnemonic,3), result_status = ceo.result_status_cd
    FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
     clinical_event ceo,
     orders o
    PLAN (dd)
     JOIN (ceo
     WHERE (ceo.person_id=dlrec->seq[dd.seq].person_id)
      AND ceo.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
      AND ceo.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
      AND ((ceo.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
      AND ceo.result_val > " "
      AND ceo.result_val != "0.*"
      AND ceo.view_level=1
      AND  NOT (ceo.result_status_cd IN (inerror_cd, notdone_cd))
      AND ceo.event_title_text="IVPARENT")
     JOIN (o
     WHERE o.order_id=ceo.order_id)
    ORDER BY encntr_id, event_cd, io_type,
     event_end_dt_tm DESC
    HEAD encntr_id
     stat = alterlist(dlrec->seq[dd.seq].titrate,1), io_cnt = 0, 12_hour_i_total = 0,
     12_hour_i_comp_total = 0, 12_hour_i_comp_line = "", 24_hour_i_total = 0,
     24_hour_i_comp_total = 0, 24_hour_i_comp_line = ""
    HEAD event_cd
     12_hour_i_comp_total = 0, 24_hour_i_comp_total = 0
    DETAIL
     IF (12hr_ind=1)
      12_hour_i_total = (12_hour_i_total+ cnvtreal(result_val))
     ELSE
      24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val))
     ENDIF
     IF (12hr_ind=1)
      12_hour_i_comp_total = (12_hour_i_comp_total+ cnvtreal(result_val))
     ELSE
      24_hour_i_comp_total = (24_hour_i_comp_total+ cnvtreal(result_val))
     ENDIF
    FOOT  event_cd
     24_hour_i_comp_total = (24_hour_i_comp_total+ 12_hour_i_comp_total)
     IF (12_hour_i_comp_total > 0
      AND (dlrec->seq[dd.seq].titrate[1].12_io_line > " "))
      dlrec->seq[dd.seq].titrate[1].12_io_line = concat(dlrec->seq[dd.seq].titrate[1].12_io_line,",",
       trim(cnvtstring(12_hour_i_comp_total))," ",trim(event_display))
     ELSEIF (12_hour_i_comp_total > 0)
      dlrec->seq[dd.seq].titrate[1].12_io_line = concat(trim(cnvtstring(12_hour_i_comp_total))," ",
       trim(event_display))
     ENDIF
     IF (24_hour_i_comp_total > 0
      AND (dlrec->seq[dd.seq].titrate[1].24_io_line > " "))
      dlrec->seq[dd.seq].titrate[1].24_io_line = concat(dlrec->seq[dd.seq].titrate[1].24_io_line,",",
       trim(cnvtstring(24_hour_i_comp_total))," ",trim(event_display))
     ELSEIF (24_hour_i_comp_total > 0)
      dlrec->seq[dd.seq].titrate[1].24_io_line = concat(trim(cnvtstring(24_hour_i_comp_total))," ",
       trim(event_display))
     ENDIF
    FOOT  encntr_id
     IF (12_hour_i_total > 0)
      dlrec->seq[dd.seq].titrate[1].12_io_total = trim(cnvtstring(12_hour_i_total),3)
     ENDIF
     IF (((24_hour_i_total+ 12_hour_i_total) > 0))
      dlrec->seq[dd.seq].titrate[1].24_io_total = trim(cnvtstring((24_hour_i_total+ 12_hour_i_total)),
       3)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    encntr_id = dlrec->seq[dd.seq].encntr_id, io_type =
    IF (vesc.event_set_name_key IN ("MISCOUTPUTSECTION", "INSENSIBLELOSSVOL", "IRRIGANTOUTPUTSECTION",
    "CBIOUTPUTSECTION", "DIALYSISOUTPUTSECTION",
    "DRAINS", "GIOUTPUTSECTION", "STOOLOUTPUTSECTION", "URINEOUTPUTSECTION")) "Output"
    ELSEIF (vesc.event_set_name_key IN ("DIALYSISINTAKESECTION", "CBIINPUTSECTION",
    "MISCINTAKESECTION", "IRRIGANTINTAKESECTION", "DILUENTS",
    "PARENTERALNUTRITIONSECTION", "BLOODPRODUCTSSECTION", "IVS", "FEEDINGSSECTION",
    "ORALINTAKESECTION")) "Intake"
    ENDIF
    , 12hr_ind =
    IF (ce.event_end_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),- ((720/ 1440.0)))) 1
    ELSE 0
    ENDIF
    ,
    event_cd = ce.event_cd, event_end_dt_tm = ce.event_end_dt_tm, result_val = ce.result_val,
    event_display = trim(uar_get_code_display(ce.event_cd),3), result_status = ce.result_status_cd
    FROM v500_event_set_code vesc,
     v500_event_set_explode vese,
     (dummyt dd  WITH seq = value(dlrec->encntr_total)),
     clinical_event ce
    PLAN (dd)
     JOIN (ce
     WHERE (ce.person_id=dlrec->seq[dd.seq].person_id)
      AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
      AND ((ce.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
      AND ce.result_val > " "
      AND ce.result_val != "0.*"
      AND ce.view_level=1
      AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
      AND  NOT ( EXISTS (
     (SELECT
      ce1.parent_event_id
      FROM clinical_event ce1
      WHERE ce1.parent_event_id=ce.parent_event_id
       AND ce1.event_title_text="IVPARENT"))))
     JOIN (vese
     WHERE vese.event_cd=ce.event_cd)
     JOIN (vesc
     WHERE vesc.event_set_cd=vese.event_set_cd
      AND cnvtupper(vesc.event_set_name_key) IN ("MISCOUTPUTSECTION", "INSENSIBLELOSSVOL",
     "IRRIGANTOUTPUTSECTION", "CBIOUTPUTSECTION", "DIALYSISOUTPUTSECTION",
     "DRAINS", "GIOUTPUTSECTION", "STOOLOUTPUTSECTION", "URINEOUTPUTSECTION", "DIALYSISINTAKESECTION",
     "CBIINPUTSECTION", "MISCINTAKESECTION", "IRRIGANTINTAKESECTION", "DILUENTS",
     "PARENTERALNUTRITIONSECTION",
     "BLOODPRODUCTSSECTION", "IVS", "FEEDINGSSECTION", "ORALINTAKESECTION"))
    ORDER BY encntr_id, vesc.event_set_name_key, event_cd,
     io_type, event_end_dt_tm DESC
    HEAD encntr_id
     dlrec->seq[dd.seq].total_io = 4, stat = alterlist(dlrec->seq[dd.seq].io,4), io_cnt = 0,
     12_hour_i_total = 0, 12_hour_o_total = 0, 12_hour_i_comp_total = 0,
     12_hour_i_comp_line = "", 12_hour_o_comp_total = 0, 12_hour_o_comp_line = "",
     24_hour_i_total = 0, 24_hour_o_total = 0, 24_hour_i_comp_total = 0,
     24_hour_i_comp_line = "", 24_hour_o_comp_total = 0, 24_hour_o_comp_line = ""
    HEAD event_cd
     12_hour_i_comp_total = 0, 12_hour_o_comp_total = 0, 24_hour_i_comp_total = 0,
     24_hour_o_comp_total = 0
    DETAIL
     IF (trim(uar_get_code_display(event_cd)) != "*Frequency"
      AND trim(uar_get_code_display(event_cd)) != "*Count")
      IF (12hr_ind=1)
       IF (io_type="Intake")
        12_hour_i_total = (12_hour_i_total+ cnvtreal(result_val))
       ELSEIF (io_type="Output")
        12_hour_o_total = (12_hour_o_total+ cnvtreal(result_val))
       ENDIF
      ELSE
       IF (io_type="Intake")
        24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val))
       ELSEIF (io_type="Output")
        24_hour_o_total = (24_hour_o_total+ cnvtreal(result_val))
       ENDIF
      ENDIF
     ENDIF
     IF (12hr_ind=1)
      IF (io_type="Intake")
       12_hour_i_comp_total = (12_hour_i_comp_total+ cnvtreal(result_val))
      ELSEIF (io_type="Output")
       12_hour_o_comp_total = (12_hour_o_comp_total+ cnvtreal(result_val))
      ENDIF
     ELSE
      IF (io_type="Intake")
       24_hour_i_comp_total = (24_hour_i_comp_total+ cnvtreal(result_val))
      ELSEIF (io_type="Output")
       24_hour_o_comp_total = (24_hour_o_comp_total+ cnvtreal(result_val))
      ENDIF
     ENDIF
    FOOT  event_cd
     24_hour_i_comp_total = (24_hour_i_comp_total+ 12_hour_i_comp_total), 24_hour_o_comp_total = (
     24_hour_o_comp_total+ 12_hour_o_comp_total)
     IF (12_hour_i_comp_total > 0
      AND (dlrec->seq[dd.seq].io[1].io_line > " ")
      AND (dlrec->seq[dd.seq].io[1].type="I")
      AND (dlrec->seq[dd.seq].io[1].hour_range="12"))
      dlrec->seq[dd.seq].io[1].io_line = concat(dlrec->seq[dd.seq].io[1].io_line,",",trim(cnvtstring(
         12_hour_i_comp_total))," ",trim(event_display))
     ELSEIF (12_hour_i_comp_total > 0)
      dlrec->seq[dd.seq].io[1].type = "I", dlrec->seq[dd.seq].io[1].hour_range = "12", dlrec->seq[dd
      .seq].io[1].io_line = concat(trim(cnvtstring(12_hour_i_comp_total))," ",trim(event_display))
     ENDIF
     IF (24_hour_i_comp_total > 0
      AND (dlrec->seq[dd.seq].io[2].io_line > " ")
      AND (dlrec->seq[dd.seq].io[2].type="I")
      AND (dlrec->seq[dd.seq].io[2].hour_range="24"))
      dlrec->seq[dd.seq].io[2].io_line = concat(dlrec->seq[dd.seq].io[2].io_line,",",trim(cnvtstring(
         24_hour_i_comp_total))," ",trim(event_display))
     ELSEIF (24_hour_i_comp_total > 0)
      dlrec->seq[dd.seq].io[2].type = "I", dlrec->seq[dd.seq].io[2].hour_range = "24", dlrec->seq[dd
      .seq].io[2].io_line = concat(trim(cnvtstring(24_hour_i_comp_total))," ",trim(event_display))
     ENDIF
     IF (12_hour_o_comp_total > 0
      AND (dlrec->seq[dd.seq].io[3].io_line > " ")
      AND (dlrec->seq[dd.seq].io[3].type="O")
      AND (dlrec->seq[dd.seq].io[3].hour_range="12"))
      dlrec->seq[dd.seq].io[3].io_line = concat(dlrec->seq[dd.seq].io[3].io_line,",",trim(cnvtstring(
         12_hour_o_comp_total))," ",trim(event_display))
     ELSEIF (12_hour_o_comp_total > 0)
      dlrec->seq[dd.seq].io[3].type = "O", dlrec->seq[dd.seq].io[3].hour_range = "12", dlrec->seq[dd
      .seq].io[3].io_line = concat(trim(cnvtstring(12_hour_o_comp_total))," ",trim(event_display))
     ENDIF
     IF (24_hour_o_comp_total > 0
      AND (dlrec->seq[dd.seq].io[4].io_line > " ")
      AND (dlrec->seq[dd.seq].io[4].type="O")
      AND (dlrec->seq[dd.seq].io[4].hour_range="24"))
      dlrec->seq[dd.seq].io[4].io_line = concat(dlrec->seq[dd.seq].io[4].io_line,",",trim(cnvtstring(
         24_hour_o_comp_total))," ",trim(event_display))
     ELSEIF (24_hour_o_comp_total > 0)
      dlrec->seq[dd.seq].io[4].type = "O", dlrec->seq[dd.seq].io[4].hour_range = "24", dlrec->seq[dd
      .seq].io[4].io_line = concat(trim(cnvtstring(24_hour_o_comp_total))," ",trim(event_display))
     ENDIF
    FOOT  encntr_id
     IF (((12_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[1].io_line > " ")))
      AND (dlrec->seq[dd.seq].titrate[1].12_io_total > " "))
      dlrec->seq[dd.seq].io[1].io_line = concat(trim(cnvtstring((12_hour_i_total+ cnvtreal(dlrec->
          seq[dd.seq].titrate[1].12_io_total))),3)," ","(",dlrec->seq[dd.seq].titrate[1].12_io_line,
       ",",
       " ",dlrec->seq[dd.seq].io[1].io_line,")")
     ELSEIF (((12_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[1].io_line > " "))) )
      dlrec->seq[dd.seq].io[1].io_line = concat(trim(cnvtstring(12_hour_i_total),3)," ","(",dlrec->
       seq[dd.seq].io[1].io_line,")")
     ELSEIF ((dlrec->seq[dd.seq].titrate[1].12_io_total > " "))
      dlrec->seq[dd.seq].io[1].io_line = concat(trim(dlrec->seq[dd.seq].titrate[1].12_io_total,3)," ",
       "(",dlrec->seq[dd.seq].titrate[1].12_io_line,")"), dlrec->seq[dd.seq].io[1].type = "I", dlrec
      ->seq[dd.seq].io[1].hour_range = "12"
     ENDIF
     IF (((((24_hour_i_total+ 12_hour_i_total) > 0)) OR ((dlrec->seq[dd.seq].io[2].io_line > " ")))
      AND (dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
      dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring(((24_hour_i_total+ 12_hour_i_total)+
         cnvtreal(dlrec->seq[dd.seq].titrate[1].24_io_total))),3)," ","(",dlrec->seq[dd.seq].titrate[
       1].24_io_line,",",
       " ",dlrec->seq[dd.seq].io[2].io_line,")")
     ELSEIF (((24_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[2].io_line > " "))) )
      dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring((24_hour_i_total+ 12_hour_i_total)),3
        )," ","(",dlrec->seq[dd.seq].io[2].io_line,")")
     ELSEIF ((dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
      dlrec->seq[dd.seq].io[2].io_line = concat(trim(dlrec->seq[dd.seq].titrate[1].24_io_total,3)," ",
       "(",dlrec->seq[dd.seq].titrate[1].24_io_line,")"), dlrec->seq[dd.seq].io[2].type = "I", dlrec
      ->seq[dd.seq].io[2].hour_range = "24"
     ENDIF
     IF (((12_hour_o_total > 0) OR ((dlrec->seq[dd.seq].io[3].io_line > " "))) )
      dlrec->seq[dd.seq].io[3].io_line = concat(trim(cnvtstring(12_hour_o_total),3)," ","(",dlrec->
       seq[dd.seq].io[3].io_line,")")
     ENDIF
     IF (((((24_hour_o_total+ 12_hour_o_total) > 0)) OR ((dlrec->seq[dd.seq].io[4].io_line > " "))) )
      dlrec->seq[dd.seq].io[4].io_line = concat(trim(cnvtstring((24_hour_o_total+ 12_hour_o_total)),3
        )," ","(",dlrec->seq[dd.seq].io[4].io_line,")")
     ENDIF
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(dlrec->seq,5))
     IF (size(dlrec->seq[x].titrate,5) > 0
      AND size(dlrec->seq[x].io,5)=0)
      SET dlrec->seq[x].total_io = 4
      SET stat = alterlist(dlrec->seq[x].io,4)
      IF (trim(dlrec->seq[x].titrate[1].12_io_total,3) > "0")
       SET dlrec->seq[x].io[1].io_line = concat(trim(dlrec->seq[x].titrate[1].12_io_total,3)," ","(",
        trim(dlrec->seq[x].titrate[1].12_io_line,3),")")
       SET dlrec->seq[x].io[1].type = "I"
       SET dlrec->seq[x].io[1].hour_range = "12"
      ENDIF
      IF (trim(dlrec->seq[x].titrate[1].24_io_total,3) > "0")
       SET dlrec->seq[x].io[2].io_line = concat(trim(dlrec->seq[x].titrate[1].24_io_total,3)," ","(",
        trim(dlrec->seq[x].titrate[1].24_io_line,3),")")
       SET dlrec->seq[x].io[2].type = "I"
       SET dlrec->seq[x].io[2].hour_range = "24"
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    encntr_id = dlrec->seq[d1.seq].encntr_id
    FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
    WHERE (dlrec->seq[d1.seq].total_io > 0)
    ORDER BY encntr_id
    HEAD REPORT
     MACRO (line_wrap_indent)
      limit = 0, maxlen = wrapcol, cr = char(10)
      WHILE (tempstring > " "
       AND limit < 1000)
        ii = 0, limit = (limit+ 1), pos = 0
        WHILE (pos=0)
         ii = (ii+ 1),
         IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
          pos = (maxlen - ii)
         ELSEIF (ii=maxlen)
          pos = maxlen
         ENDIF
        ENDWHILE
        IF (limit != 1)
         printstring = substring(1,pos,tempstring)
         IF ((dlrec->seq[d1.seq].io[x].type="I"))
          i_total_rows = (i_total_rows+ 1)
          IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
           stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
           intake_line_cnt = (i_total_rows+ 10)
          ENDIF
          IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
           dlrec->seq[d1.seq].intake_line[i_total_rows].column1 = concat(" ",printstring)
          ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
           dlrec->seq[d1.seq].intake_line[i_total_rows].column2 = concat(" ",printstring)
          ENDIF
         ENDIF
         IF ((dlrec->seq[d1.seq].io[x].type="O"))
          o_total_rows = (o_total_rows+ 1)
          IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
           stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
           output_line_cnt = (o_total_rows+ 10)
          ENDIF
          IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
           dlrec->seq[d1.seq].output_line[o_total_rows].column1 = concat(" ",printstring)
          ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
           dlrec->seq[d1.seq].output_line[o_total_rows].column2 = concat(" ",printstring)
          ENDIF
         ENDIF
        ELSEIF (limit=1)
         maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring)
         IF ((dlrec->seq[d1.seq].io[x].type="I"))
          i_total_rows = (i_total_rows+ 1)
          IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
           stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
           intake_line_cnt = (i_total_rows+ 10)
          ENDIF
          IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
           dlrec->seq[d1.seq].intake_line[o_total_rows].column1 = printstring
          ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
           dlrec->seq[d1.seq].intake_line[total_rows].column2 = printstring
          ENDIF
         ENDIF
         IF ((dlrec->seq[d1.seq].io[x].type="O"))
          o_total_rows = (o_total_rows+ 1)
          IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
           stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
           output_line_cnt = (o_total_rows+ 10)
          ENDIF
          IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
           dlrec->seq[d1.seq].output_line[total_rows].column1 = printstring
          ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
           AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
           dlrec->seq[d1.seq].output_line[total_rows].column2 = printstring
          ENDIF
         ENDIF
        ENDIF
        tempstring = substring((pos+ 1),eol,tempstring)
      ENDWHILE
     ENDMACRO
    HEAD encntr_id
     i_max_total_rows = 0, i_total_rows = 0, o_max_total_rows = 0,
     o_total_rows = 0, total_rows = 0, stat = alterlist(dlrec->seq[d1.seq].intake_line,10),
     dlrec->seq[d1.seq].intake_line_cnt = 10, stat = alterlist(dlrec->seq[d1.seq].output_line,10),
     dlrec->seq[d1.seq].output_line_cnt = 10
    DETAIL
     FOR (x = 1 TO 2)
       IF ((dlrec->seq[d1.seq].io[x].type="I"))
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND size(dlrec->seq[d1.seq].io[x].io_line) <= 56
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         i_total_rows = (i_total_rows+ 1)
         IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
          stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
          intake_line_cnt = (i_total_rows+ 10)
         ENDIF
         dlrec->seq[d1.seq].intake_line[i_total_rows].column1 = dlrec->seq[d1.seq].io[x].io_line
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 56, eol = size(trim(tempstring)),
         xcol = 60, line_wrap_indent
        ENDIF
        i_max_total_rows = i_total_rows, i_total_rows = 0
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND size(dlrec->seq[d1.seq].io[x].io_line) <= 56
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         i_total_rows = (i_total_rows+ 1)
         IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
          stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
          intake_line_cnt = (i_total_rows+ 10)
         ENDIF
         dlrec->seq[d1.seq].intake_line[i_total_rows].column2 = dlrec->seq[d1.seq].io[x].io_line
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 56, eol = size(trim(tempstring)),
         xcol = 350, ycol = save_ycol, line_wrap_indent
        ENDIF
       ENDIF
     ENDFOR
     IF (i_total_rows > i_max_total_rows)
      i_max_total_rows = i_total_rows
     ENDIF
     i_total_rows = 0
     FOR (x = 3 TO 4)
       IF ((dlrec->seq[d1.seq].io[x].type="O"))
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND size(dlrec->seq[d1.seq].io[x].io_line) <= 56
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         o_total_rows = (o_total_rows+ 1)
         IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
          stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
          output_line_cnt = (o_total_rows+ 10)
         ENDIF
         dlrec->seq[d1.seq].output_line[o_total_rows].column1 = dlrec->seq[d1.seq].io[x].io_line
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 56, eol = size(trim(tempstring)),
         xcol = 60, ycol = save_ycol, line_wrap_indent
        ENDIF
        o_max_total_rows = o_total_rows, o_total_rows = 0
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND size(dlrec->seq[d1.seq].io[x].io_line) <= 56
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         o_total_rows = (o_total_rows+ 1)
         IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
          stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
          output_line_cnt = (o_total_rows+ 10)
         ENDIF
         dlrec->seq[d1.seq].output_line[o_total_rows].column2 = dlrec->seq[d1.seq].io[x].io_line
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 56, eol = size(trim(tempstring)),
         xcol = 350, ycol = save_ycol, line_wrap_indent
        ENDIF
       ENDIF
     ENDFOR
     IF (o_total_rows > o_max_total_rows)
      o_max_total_rows = o_total_rows
     ENDIF
     o_total_rows = 0
    FOOT  encntr_id
     stat = alterlist(dlrec->seq[d1.seq].intake_line,i_max_total_rows), dlrec->seq[d1.seq].
     intake_line_cnt = i_max_total_rows, stat = alterlist(dlrec->seq[d1.seq].output_line,
      o_max_total_rows),
     dlrec->seq[d1.seq].output_line_cnt = o_max_total_rows
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
