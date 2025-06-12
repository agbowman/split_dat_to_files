CREATE PROGRAM bhs_sch_pat_appt_cnfm_mat:dba
 DECLARE dprefshowfullformatted = f8 WITH public, noconstant(0.0)
 DECLARE ms_str = vc WITH protect, noconstant("")
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_buss_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE mf_buss_fax_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS"))
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
   AND sp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND sp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   dprefshowfullformatted = sp.pref_value
  WITH nocounter
 ;end select
 SELECT INTO  $1
  r.person_id, a.beg_dt_tm
  FROM person r,
   sch_appt a,
   sch_event se,
   sch_event_detail sed,
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
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pn.active_ind=1
    AND pn.name_type_cd=current_name_type_cd
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (cv
   WHERE cv.code_value=outerjoin(a.appt_location_cd))
   JOIN (ad
   WHERE ad.parent_entity_name=outerjoin("LOCATION")
    AND ad.parent_entity_id=outerjoin(cv.code_value)
    AND ad.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.parent_entity_name=outerjoin("LOCATION")
    AND p.parent_entity_id=outerjoin(cv.code_value)
    AND p.active_ind=outerjoin(1)
    AND p.phone_type_cd=outerjoin(mf_buss_phone_cd))
   JOIN (p2
   WHERE p2.parent_entity_name=outerjoin("LOCATION")
    AND p2.parent_entity_id=outerjoin(cv.code_value)
    AND p2.active_ind=outerjoin(1)
    AND p2.phone_type_cd=outerjoin(mf_buss_fax_cd))
   JOIN (se
   WHERE se.sch_event_id=a.sch_event_id
    AND se.active_ind=1)
   JOIN (sed
   WHERE sed.sch_event_id=outerjoin(a.sch_event_id)
    AND sed.oe_field_meaning=outerjoin("SURGDIAGNOSIS")
    AND sed.active_ind=outerjoin(1))
   JOIN (ad2
   WHERE ad2.parent_entity_name=outerjoin("PERSON")
    AND ad2.parent_entity_id=outerjoin(r.person_id)
    AND ad2.address_type_cd=outerjoin(mf_addr_home_cd)
    AND ad2.active_ind=outerjoin(1)
    AND ad2.address_type_seq=outerjoin(1))
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
   row + 1, col 0, "{POS/230/60}",
   ms_str = cnvtupper(trim(cv.description,3)), ms_str, row + 1,
   col 0, "{POS/230/73}", ms_str = cnvtupper(trim(ad.street_addr,3)),
   ms_str, row + 1, col 0,
   ms_str = cnvtupper(concat("{POS/230/86}",trim(ad.city,3),", ",trim(ad.state,3)," ",
     trim(ad.zipcode,3))), ms_str, row + 1,
   col 0, "{POS/70/137}", t_rec_appt_cnfm->name,
   row + 1, col 0, "{POS/70/150}",
   ms_str = cnvtupper(trim(ad2.street_addr,3)), ms_str, row + 1,
   col 0, ms_str = cnvtupper(concat("{POS/70/163}",trim(ad2.city,3),", ",trim(ad2.state,3)," ",
     trim(ad2.zipcode,3))), ms_str,
   row + 1, col 0, "{F/4}{CPI/11}{LPI/6}",
   row + 1, col 0, "{POS/50/207}Dear ",
   t_rec_appt_cnfm->name, ",", row + 1,
   col 0, "{POS/50/233}Thank you for scheduling your appointment with ", col + 1,
   ms_str = trim(cv.description,3), ms_str, col + 1,
   ".", row + 1, col 0,
   "{POS/150/259}Appointment Date & Time: ", a.beg_dt_tm"@WEEKDAYNAME", ",",
   col + 1, a.beg_dt_tm"@SHORTDATETIME", row + 1,
   col 0, "{POS/160/272}Reason for Appointment: C-Section", row + 1,
   col 0, "{POS/274/285}Arrive 90 mins early", row + 1,
   col 0, "{POS/50/311}All staff members at ", ms_str = trim(cv.description,3),
   ms_str, col + 1, "make every effort to see you as close to your appointment",
   row + 1, col 0, "{POS/50/324}time as possible.",
   row + 1, col 0,
   "{POS/50/350}To provide you with the best care, we will need you to bring health insurance information and any papers from ",
   row + 1, col 0,
   "{POS/50/363}your physician, including referral forms. Please be prepared to pay your copayment, if required.",
   row + 1, col 0,
   "{POS/50/389}We wish to remind you of the importance of maintaining your health through continuity of service. Failure ",
   row + 1, col 0,
   "{POS/50/402}to keep scheduled appointments poses risks to our ability to properly treat you and may jeopardize your health.",
   row + 1, col 0, ms_str = concat("{POS/50/428}Please call ",trim(p.phone_num,3),
    " if you will be late or cannot keep this appointment.","We will be happy to reschedule"),
   ms_str, row + 1, col 0,
   "{POS/50/441}your appointment to a more convenient date and time.", row + 1, col 0,
   "{POS/50/467}Additional procedure/service instructions:", row + 1, col 0,
   "{POS/50/480}Please complete the enclosed health questionaire. Bring this form to the hospital on the day you are admitted.",
   row + 1, col 0,
   '{POS/50/493}We would like to highlight a few pages in the "Becoming a Family Your Pregnancy and Hospital Services" booklet',
   row + 1, col 0,
   "{POS/50/506}that should have been given to you by your healthcare provider. Pages 44 & 48 provide an overview of what you",
   row + 1, col 0,
   "{POS/50/519}can expect for the cesarean delivery. If you would like a copy of this booklet or have any questions, please",
   row + 1, col 0,
   "{POS/50/532}call us at 413-794-BABY (794-2229).", row + 1, col 0,
"{POS/50/558}If you are scheduled for a postpartum tubal ligation, please bring your copy of the consent with you to the ho\
spital\
", row + 1, col 0, "{POS/50/571}if one was given to you by your provider.",
   row + 1, col 0, "{POS/50/637}Sincerely,",
   row + 1, col 0, ms_str = concat("{POS/50/650}The providers and staff at ",trim(cv.description)),
   ms_str, row + 1, col 0,
   "{POS/50/676}**For your health and safety, there is no smoking on Baystate Health grounds.**"
  WITH nocounter, dio = postscript, dontcare = pn,
   formfeed = post, maxrec = 1
 ;end select
#exit_script
END GO
