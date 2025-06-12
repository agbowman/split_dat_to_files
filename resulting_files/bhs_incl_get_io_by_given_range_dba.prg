CREATE PROGRAM bhs_incl_get_io_by_given_range:dba
 DECLARE get_vitals(status=i2) = i2 WITH copy
 DECLARE get_io(status=i2) = i2 WITH copy
 DECLARE declarevariables(status=i2) = i2 WITH copy
 IF (validate(inerror_cd)=0)
  DECLARE inerror_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"INERROR"))
  DECLARE notdone_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
  DECLARE pending_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
  DECLARE save_ycol = i2 WITH persistscript
  DECLARE placeholder_event_class_cd = f8 WITH persistscript, constant(uar_get_code_by("MEANING",53,
    "PLACEHOLDER"))
 ENDIF
 SUBROUTINE get_io(status)
   SET 12hr_ind = 0
   SELECT INTO "nl:"
    encntr_id = dlrec->seq[dd.seq].encntr_id, io_type = "Intake", event_cd = ceo.event_cd,
    event_end_dt_tm = ceo.event_end_dt_tm, result_val = ceo.result_val, event_display = trim(o
     .ordered_as_mnemonic,3),
    result_status = ceo.result_status_cd
    FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
     clinical_event ceo,
     orders o
    PLAN (dd)
     JOIN (ceo
     WHERE (ceo.person_id=dlrec->seq[dd.seq].person_id)
      AND ceo.event_end_dt_tm BETWEEN cnvtdatetime(dlrec->seq[dd.seq].start_date) AND cnvtdatetime(
      dlrec->seq[dd.seq].end_date)
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
     stat = alterlist(dlrec->seq[dd.seq].titrate,1), io_cnt = 0, 24_hour_i_total = 0,
     24_hour_i_comp_total = 0, 24_hour_i_comp_line = ""
    HEAD event_cd
     24_hour_i_comp_total = 0
    DETAIL
     24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val)), 24_hour_i_comp_total = (
     24_hour_i_comp_total+ cnvtreal(result_val))
    FOOT  event_cd
     IF (24_hour_i_comp_total > 0
      AND (dlrec->seq[dd.seq].titrate[1].24_io_line > " "))
      dlrec->seq[dd.seq].titrate[1].24_io_line = concat(dlrec->seq[dd.seq].titrate[1].24_io_line,",",
       trim(cnvtstring(24_hour_i_comp_total))," ",trim(event_display))
     ELSEIF (24_hour_i_comp_total > 0)
      dlrec->seq[dd.seq].titrate[1].24_io_line = concat(trim(cnvtstring(24_hour_i_comp_total))," ",
       trim(event_display))
     ENDIF
    FOOT  encntr_id
     IF (24_hour_i_total > 0)
      dlrec->seq[dd.seq].titrate[1].24_io_total = trim(cnvtstring(24_hour_i_total),3)
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
    , event_cd = ce.event_cd,
    event_end_dt_tm = ce.event_end_dt_tm, result_val = ce.result_val, event_display = trim(
     uar_get_code_display(ce.event_cd),3),
    result_status = ce.result_status_cd
    FROM v500_event_set_code vesc,
     v500_event_set_explode vese,
     (dummyt dd  WITH seq = value(dlrec->encntr_total)),
     clinical_event ce,
     discrete_task_assay dta
    PLAN (dd)
     JOIN (ce
     WHERE (ce.person_id=dlrec->seq[dd.seq].person_id)
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(dlrec->seq[dd.seq].start_date) AND cnvtdatetime(
      dlrec->seq[dd.seq].end_date)
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
     JOIN (dta
     WHERE dta.event_cd=ce.event_cd
      AND dta.io_flag > 0)
     JOIN (vese
     WHERE vese.event_cd=dta.event_cd)
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
     24_hour_i_total = 0, 24_hour_o_total = 0, 24_hour_i_comp_total = 0,
     24_hour_i_comp_line = "", 24_hour_o_comp_total = 0, 24_hour_o_comp_line = ""
    HEAD event_cd
     24_hour_i_comp_total = 0, 24_hour_o_comp_total = 0
    DETAIL
     IF (trim(uar_get_code_display(event_cd)) != "*Frequency"
      AND trim(uar_get_code_display(event_cd)) != "*Count")
      IF (io_type="Intake")
       24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val))
      ELSEIF (io_type="Output")
       24_hour_o_total = (24_hour_o_total+ cnvtreal(result_val))
      ENDIF
     ENDIF
     IF (io_type="Intake")
      24_hour_i_comp_total = (24_hour_i_comp_total+ cnvtreal(result_val))
     ELSEIF (io_type="Output")
      24_hour_o_comp_total = (24_hour_o_comp_total+ cnvtreal(result_val))
     ENDIF
    FOOT  event_cd
     24_hour_i_comp_total = 24_hour_i_comp_total, 24_hour_o_comp_total = 24_hour_o_comp_total
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
     IF (size(dlrec->seq[dd.seq].titrate,5) > 0)
      IF (((24_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[2].io_line > " ")))
       AND (dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
       dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring((24_hour_i_total+ cnvtreal(dlrec->
           seq[dd.seq].titrate[1].24_io_total))),3)," ","(",dlrec->seq[dd.seq].titrate[1].24_io_line,
        ",",
        " ",dlrec->seq[dd.seq].io[2].io_line,")")
      ENDIF
     ELSEIF (((24_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[2].io_line > " "))) )
      dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring(24_hour_i_total),3)," ","(",dlrec->
       seq[dd.seq].io[2].io_line,")")
     ELSEIF (size(dlrec->seq[dd.seq].titrate,5) > 0)
      IF ((dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
       dlrec->seq[dd.seq].io[2].io_line = concat(trim(dlrec->seq[dd.seq].titrate[1].24_io_total,3),
        " ","(",dlrec->seq[dd.seq].titrate[1].24_io_line,")"), dlrec->seq[dd.seq].io[2].type = "I",
       dlrec->seq[dd.seq].io[2].hour_range = "24"
      ENDIF
     ENDIF
     IF (((24_hour_o_total > 0) OR ((dlrec->seq[dd.seq].io[4].io_line > " "))) )
      dlrec->seq[dd.seq].io[4].io_line = concat(trim(cnvtstring(24_hour_o_total),3)," ","(",dlrec->
       seq[dd.seq].io[4].io_line,")")
     ENDIF
     dlrec->seq[1].total_intake = 24_hour_i_total, dlrec->seq[1].total_output = 24_hour_o_total,
     dlrec->seq[1].balance = (24_hour_i_total - 24_hour_o_total)
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
