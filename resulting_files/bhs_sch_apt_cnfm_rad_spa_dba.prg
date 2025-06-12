CREATE PROGRAM bhs_sch_apt_cnfm_rad_spa:dba
 DECLARE dprefshowfullformatted = f8 WITH public, noconstant(0.0)
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_buss_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE mf_buss_fax_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS"))
 DECLARE ms_str = vc WITH protect, noconstant("")
 DECLARE mi_vpos = i4 WITH protect, noconstant(0)
 FREE SET t_rec_appt_cnfm
 RECORD t_rec_appt_cnfm(
   1 name = vc
   1 date = vc
   1 t_string = vc
 )
 FREE SET t_record
 RECORD t_record(
   1 t_ind = i4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 person_id = f8
 )
 SET t_record->t_ind = (findstring(" = ", $4,1)+ 3)
 SET t_record->person_id = cnvtreal(substring(t_record->t_ind,((size(trim( $4)) - t_record->t_ind)+ 1
   ), $4))
 SET t_record->t_ind = (findstring(char(34), $3,1)+ 1)
 SET t_record->beg_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $3))
 SET t_record->t_ind = (findstring(char(34), $2,1)+ 1)
 SET t_record->end_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $2))
 DECLARE current_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"CURRENT"))
 SELECT INTO "nl:"
  sp.pref_value
  FROM sch_pref sp
  WHERE sp.pref_type_meaning="SHNMFULLFRMT"
   AND sp.active_ind=1
   AND sp.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND sp.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dprefshowfullformatted = sp.pref_value
  WITH nocounter
 ;end select
 SELECT INTO  $1
  r.person_id, a.beg_dt_tm
  FROM person r,
   sch_appt a,
   sch_event se,
   person_name pn,
   code_value cv,
   address ad,
   phone p,
   phone p2,
   address ad2
  PLAN (r
   WHERE (r.person_id=t_record->person_id))
   JOIN (a
   WHERE cnvtdatetime(t_record->end_dt_tm) > a.beg_dt_tm
    AND cnvtdatetime(t_record->beg_dt_tm) < a.end_dt_tm
    AND a.person_id=r.person_id
    AND a.state_meaning IN ("CONFIRMED")
    AND a.role_meaning="PATIENT"
    AND a.active_ind=1
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pn
   WHERE pn.person_id=r.person_id
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=current_name_type_cd
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (se
   WHERE se.sch_event_id=a.sch_event_id
    AND se.active_ind=1)
   JOIN (cv
   WHERE (cv.code_value= Outerjoin(a.appt_location_cd)) )
   JOIN (ad
   WHERE (ad.parent_entity_name= Outerjoin("LOCATION"))
    AND (ad.parent_entity_id= Outerjoin(cv.code_value))
    AND (ad.active_ind= Outerjoin(1)) )
   JOIN (p
   WHERE (p.parent_entity_name= Outerjoin("LOCATION"))
    AND (p.parent_entity_id= Outerjoin(cv.code_value))
    AND (p.active_ind= Outerjoin(1))
    AND (p.phone_type_cd= Outerjoin(mf_buss_phone_cd)) )
   JOIN (p2
   WHERE (p2.parent_entity_name= Outerjoin("LOCATION"))
    AND (p2.parent_entity_id= Outerjoin(cv.code_value))
    AND (p2.active_ind= Outerjoin(1))
    AND (p2.phone_type_cd= Outerjoin(mf_buss_fax_cd)) )
   JOIN (ad2
   WHERE (ad2.parent_entity_name= Outerjoin("PERSON"))
    AND (ad2.parent_entity_id= Outerjoin(r.person_id))
    AND (ad2.address_type_cd= Outerjoin(mf_addr_home_cd))
    AND (ad2.active_ind= Outerjoin(1))
    AND (ad2.address_type_seq= Outerjoin(1)) )
  ORDER BY cnvtdatetime(a.beg_dt_tm)
  DETAIL
   IF (dprefshowfullformatted > 0.0)
    t_rec_appt_cnfm->name = trim(r.name_full_formatted)
   ELSE
    t_rec_appt_cnfm->name = trim(pn.name_prefix)
    IF (trim(r.name_first) > "")
     IF (trim(pn.name_prefix) > "")
      t_rec_appt_cnfm->name = concat(t_rec_appt_cnfm->name," ",trim(r.name_first))
     ELSE
      t_rec_appt_cnfm->name = concat(t_rec_appt_cnfm->name,trim(r.name_first))
     ENDIF
    ENDIF
    IF (trim(r.name_last) > "")
     t_rec_appt_cnfm->name = concat(t_rec_appt_cnfm->name," ",trim(r.name_last))
    ENDIF
    IF (trim(pn.name_suffix) > "")
     t_rec_appt_cnfm->name = concat(trim(t_rec_appt_cnfm->name)," ",trim(pn.name_suffix))
    ENDIF
    IF (trim(pn.name_title) > "")
     t_rec_appt_cnfm->name = concat(trim(t_rec_appt_cnfm->name)," ",trim(pn.name_title))
    ENDIF
   ENDIF
   row + 1, col 0, "{F/4}{CPI/11}{LPI/6}",
   row + 1, col 0, "{POS/230/73}",
   ms_str = cnvtupper(trim(ad.street_addr,3)), ms_str, row + 1,
   mi_vpos = 73
   IF (trim(ad.street_addr2) > " ")
    col 0, mi_vpos += 13, ms_str = concat("{POS/230/",build(mi_vpos),"}",cnvtupper(trim(ad
       .street_addr2,3))),
    ms_str, row + 1
   ENDIF
   IF (trim(ad.street_addr3) > " ")
    col 0, mi_vpos += 13, ms_str = concat("{POS/230/",build(mi_vpos),"}",cnvtupper(trim(ad
       .street_addr3,3))),
    ms_str, row + 1
   ENDIF
   col 0, mi_vpos += 13, ms_str = cnvtupper(concat("{POS/230/",build(mi_vpos),"}",trim(ad.city,3),
     ", ",
     trim(ad.state,3)," ",trim(ad.zipcode,3))),
   ms_str, row + 1, col 0,
   "{POS/50/137}", t_rec_appt_cnfm->name, row + 1,
   col 0, "{POS/50/150}", ms_str = cnvtupper(trim(ad2.street_addr,3)),
   ms_str, row + 1, col 0
   IF (size(trim(ad2.street_addr2,3)) > 0)
    "{POS/50/163}", ms_str = cnvtupper(trim(ad2.street_addr2,3)), ms_str,
    row + 1, col 0, ms_str = cnvtupper(concat("{POS/50/176}",trim(ad2.city,3),", ",trim(ad2.state,3),
      " ",
      trim(ad2.zipcode,3))),
    ms_str, row + 1, col 0
   ELSE
    ms_str = cnvtupper(concat("{POS/50/163}",trim(ad2.city,3),", ",trim(ad2.state,3)," ",
      trim(ad2.zipcode,3))), ms_str, row + 1,
    col 0
   ENDIF
   "{F/4}{CPI/11}{LPI/6}", row + 1, col 0,
   "{POS/50/207}Estimado  ", t_rec_appt_cnfm->name, ",",
   row + 1, col 0,
   "{POS/50/233}Muchas gracias por programar su cita con Baystate Radiology (Radiologa de Baystate).",
   row + 1, col 0, "{POS/50/259}Fecha y hora de la cita: ",
   a.beg_dt_tm"@WEEKDAYNAME", ",", col + 1,
   ms_str = concat(trim(format(a.beg_dt_tm,"MM/DD/YY;;d"),2),"  ",cnvtupper(format(a.beg_dt_tm,
      "hh:mm;;s"))), ms_str, row + 1,
   col 0, "{POS/50/272}Estudio: ", col + 1,
   ms_str = uar_get_code_display(se.appt_type_cd), ms_str, row + 1,
   col 0,
   "{POS/50/298}Todos los miembros del personal de Baystate Radiology se esfuerzan al mximo para que el mdico",
   row + 1,
   col 0, "{POS/50/311}lo atienda lo ms prximo posible a la hora de su cita.", row + 1,
   col 0,
   "{POS/50/337}Para brindarle la mejor atencin, necesitamos que traiga la informacin de su seguro mdico y",
   row + 1,
   col 0,
   "{POS/50/350}cualquier documentacin de sus mdicos, incluyendo formularios de referidos. Est preparado para ",
   row + 1,
   col 0, "{POS/50/363}pagar su copago, si corresponde.", row + 2,
   col 0,
   "{POS/50/389}Deseamos recordarle la importancia de mantener su salud mediante la continuidad del servicio. Si",
   row + 1,
   col 0,
   "{POS/50/402}no asiste a las citas programadas, pondr en riesgo nuestra habilidad para brindarle el tratamiento",
   row + 1,
   col 0, "{POS/50/415}adecuado y podr perjudicar su salud.", row + 1,
   col 0,
   "{POS/50/441}Llame al 413-794-2222 si llegar tarde o si no podr asistir a la cita. Con gusto programaremos su",
   row + 1,
   col 0, "{POS/50/454}cita para una fecha y hora que le resulten ms convenientes.", row + 1,
   col 0, "{POS/50/480}Atentamente,", row + 1,
   col 0, "{POS/50/506}Baystate Radiology", row + 1,
   col 0,
   "{POS/50/532}**Por su salud y seguridad, no se permite fumar en los predios de Baystate Health.**"
  WITH nocounter, dio = postscript, dontcare = pn,
   formfeed = post, maxrec = 1
 ;end select
#exit_script
END GO
