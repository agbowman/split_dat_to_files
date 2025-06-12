CREATE PROGRAM bhs_sch_pat_appt_cnfm:dba
 DECLARE dprefshowfullformatted = f8 WITH public, noconstant(0.0)
 DECLARE ms_str = vc WITH protect, noconstant("")
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_buss_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE mf_buss_fax_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS"))
 DECLARE mf_cs220_bwhendo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BWHENDOSCOPYSPECIALPROCEDURES"))
 DECLARE mf_cs220_fmcendoscopy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "FMCENDOSCOPY"))
 DECLARE mf_cs220_bmcendoscopy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BMCENDOSCOPY"))
 DECLARE mf_cs220_bnhendoscopycenter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BNHENDOSCOPYCENTER"))
 DECLARE mf_cs220_bfmcendo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BFMCENDOSCOPYMINORPROCEDURES"))
 DECLARE mf_cs220_bmlhendo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BMLHENDOSCOPYANDSPECIALPROCEDURES"))
 DECLARE mf_cs220_bmcendoscopycenter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BMCENDOSCOPYCENTER"))
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
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=current_name_type_cd
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
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
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(a.sch_event_id))
    AND (sed.oe_field_meaning= Outerjoin("SURGDIAGNOSIS"))
    AND (sed.active_ind= Outerjoin(1)) )
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
   col 0
   IF (a.appt_location_cd IN (mf_cs220_bwhendo_cd, mf_cs220_fmcendoscopy_cd, mf_cs220_bmcendoscopy_cd,
   mf_cs220_bnhendoscopycenter_cd, mf_cs220_bfmcendo_cd,
   mf_cs220_bmlhendo_cd, mf_cs220_bmcendoscopycenter_cd))
    ms_str = "{POS/282/272}Arrival 1 hour early"
   ELSE
    ms_str = "{POS/282/272}Arrival 15 min early"
   ENDIF
   ms_str, row + 1, col 0,
   "{POS/50/311}All staff members at ", ms_str = trim(cv.description,3), ms_str,
   col + 1, "make every effort to see you as close to your ", row + 1,
   col 0, "{POS/50/324}appointment time as possible.", row + 1,
   col 0,
   "{POS/50/350}To provide you with the best care, please bring a list of your medication and the dosage. Also bring results ",
   row + 1,
   col 0, ms_str = concat(
    "{POS/50/363}of any recent EKG and blood tests or have your physicians office fax them to ",trim(
     p2.phone_num,3),". We will need "), ms_str,
   row + 1, col 0,
   "{POS/50/376}you to bring health insurance information and any paperwork from your Health Care Provider, including  ",
   row + 2, col 0,
   "{POS/50/389}referral forms. Please be prepared to pay your copayment, if required.",
   row + 1, col 0,
   "{POS/50/415}We wish to remind you of the importance of maintaining your health through continuity of service. Failure ",
   row + 1, col 0,
   "{POS/50/428}to keep scheduled appointments poses risks to our ability to properly treat you and may jeopardize your health.",
   row + 1, col 0, ms_str = concat("{POS/50/455}Please call ",trim(p.phone_num,3),
    " if you will be late or cannot keep this appointment.","We will be happy to reschedule"),
   ms_str, row + 1, col 0,
   "{POS/50/468}your appointment to a more convenient date and time.", row + 1, col 0,
   "{POS/50/494}Additional procedure/service instructions:", row + 1, col 0,
   ms_str = concat("{POS/50/507}For questions regarding this appointment call ",trim(p.phone_num,3),
    ". This visit will include: ","information and "), ms_str, row + 1,
   col 0,
   "{POS/50/520}teaching with a nurse, a nurse practioner who is a member of the anesthesia team. Completion of any tests your",
   row + 1,
   col 0, "{POS/50/533}Health Care Provider ordered.", row + 1,
   col 0, ms_str = concat("{POS/50/559}The appointment lasts 1-2 hrs. Please report to the ",trim(cv
     .description)," building. "), ms_str,
   row + 1, col 0, ms_str = concat("{POS/50/572}Please call 413-794-9600 to preregister."),
   ms_str, row + 1, col 0,
   "{POS/50/598}Sincerely,", row + 1, col 0,
   ms_str = concat("{POS/50/611}The staff at ",trim(cv.description)), ms_str, row + 1,
   col 0,
   "{POS/50/637}**For your health and safety, there is no smoking on Baystate Health grounds.**"
  WITH nocounter, dio = postscript, dontcare = pn,
   formfeed = post, maxrec = 1
 ;end select
#exit_script
END GO
