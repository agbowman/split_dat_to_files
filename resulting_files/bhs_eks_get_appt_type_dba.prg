CREATE PROGRAM bhs_eks_get_appt_type:dba
 DECLARE mf_pedipfizer511vacbooster = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER511VACBOOSTER")), protect
 DECLARE mf_pedipfizer6mo4yvacdose1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER6MO4YVACDOSE1")), protect
 DECLARE mf_pedipfizer6mo4yvacdose2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER6MO4YVACDOSE2")), protect
 DECLARE mf_pedipfizer6mo4yvacdose3 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER6MO4YVACDOSE3")), protect
 DECLARE mf_pedimoderna6mo5yvacdose1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIMODERNA6MO5YVACDOSE1")), protect
 DECLARE mf_pedimoderna6mo5yvacdose2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIMODERNA6MO5YVACDOSE2")), protect
 DECLARE mf_pfizervaccinedose1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PFIZERVACCINEDOSE1"))
 DECLARE mf_pfizervaccinedose2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PFIZERVACCINEDOSE2"))
 DECLARE mf_pfizervaccinedose3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PFIZERVACCINEDOSE3"))
 DECLARE mf_pfizervaccinebooster = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PFIZERVACCINEBOOSTER"))
 DECLARE mf_pedipfizervacdose1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER511VACDOSE1"))
 DECLARE mf_pedipfizervacdose2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "PEDIPFIZER511VACDOSE2"))
 DECLARE mf_modernavaccinedose1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "MODERNAVACCINEDOSE1"))
 DECLARE mf_modernavaccinedose2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "MODERNAVACCINEDOSE2"))
 DECLARE mf_modernavaccinedose3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "MODERNAVACCINEDOSE3"))
 DECLARE mf_modernavaccinebooster = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "MODERNAVACCINEBOOSTER"))
 DECLARE mf_johnsonandjohnsonvaccine = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "JOHNSONANDJOHNSONVACCINE"))
 DECLARE mf_johnsonandjohnsonvaccinebooster = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   14230,"JOHNSONANDJOHNSONVACCINEBOOSTER"))
 DECLARE mf_grnfdvaccinectr = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE CTR GRNFD"))
 DECLARE mf_holykvaccinectr = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE CTR HOLYK"))
 DECLARE mf_palmrvaccinectr = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE CTR PALMR"))
 DECLARE mf_spfldvaccinectr = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE CTR SPFLD"))
 DECLARE mf_wstfdvaccinectr = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE CTR WSTFD"))
 DECLARE mf_brightwood = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE BRIGHTWOOD"))
 DECLARE mf_highst = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,"BAYSTATE HIGH ST ADULT"
   ))
 DECLARE mf_masonsq = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,"BAYSTATE MASON SQUARE"
   ))
 DECLARE mf_baystatevaccineunit = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE VACCINE UNIT"))
 DECLARE mf_highstpeds = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,
   "BAYSTATE HIGH ST PEDS"))
 SET retval = 0
 SET log_message = concat("Script failed.")
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   encounter e
  PLAN (sa
   WHERE sa.encntr_id=trigger_encntrid)
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.appt_type_cd IN (mf_pfizervaccinedose1, mf_pfizervaccinedose2, mf_pfizervaccinedose3,
   mf_modernavaccinedose1, mf_modernavaccinedose2,
   mf_modernavaccinedose3, mf_johnsonandjohnsonvaccine, mf_pedipfizervacdose1, mf_pedipfizervacdose2,
   mf_pedipfizer511vacbooster,
   mf_modernavaccinebooster, mf_pfizervaccinebooster, mf_pedipfizer6mo4yvacdose1,
   mf_pedipfizer6mo4yvacdose2, mf_pedipfizer6mo4yvacdose3,
   mf_pedimoderna6mo5yvacdose1, mf_pedimoderna6mo5yvacdose2, mf_johnsonandjohnsonvaccinebooster))
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id)
  ORDER BY sa.sch_event_id
  HEAD REPORT
   retval = 100
   CASE (e.loc_facility_cd)
    OF mf_grnfdvaccinectr:
     log_misc1 = "GRNFD"
    OF mf_holykvaccinectr:
     log_misc1 = "HOLYK"
    OF mf_palmrvaccinectr:
     log_misc1 = "PALMR"
    OF mf_spfldvaccinectr:
     log_misc1 = "SPFLD"
    OF mf_wstfdvaccinectr:
     log_misc1 = "WSTFD"
    OF mf_brightwood:
     log_misc1 = "BRIGHTWWOD"
    OF mf_highst:
     log_misc1 = "HIGHST"
    OF mf_highstpeds:
     log_misc1 = "PEDSHIGHST"
    OF mf_masonsq:
     log_misc1 = "MASONSQ"
    OF mf_baystatevaccineunit:
     log_misc1 = "VCU"
    ELSE
     retval = 0,log_misc1 = "LOCATIONFAILED",log_message = concat("Location FAILED, Facility: ",build
      (uar_get_code_display(e.loc_facility_cd)))
   ENDCASE
   IF (retval=100)
    CASE (se.appt_type_cd)
     OF mf_pfizervaccinedose1:
      log_misc1 = concat(log_misc1,"PFIZERDOSE1")
     OF mf_pfizervaccinedose2:
      log_misc1 = concat(log_misc1,"PFIZERDOSE2")
     OF mf_pfizervaccinedose3:
      log_misc1 = concat(log_misc1,"PFIZERDOSE3")
     OF mf_pfizervaccinebooster:
      log_misc1 = concat(log_misc1,"PFIZERBOOSTER")
     OF mf_pedipfizervacdose1:
      log_misc1 = concat(log_misc1,"PEDPFDOSE1")
     OF mf_pedipfizervacdose2:
      log_misc1 = concat(log_misc1,"PEDPFDOSE2")
     OF mf_pedipfizer511vacbooster:
      log_misc1 = concat(log_misc1,"PEDPFBOOSTER")
     OF mf_modernavaccinedose1:
      log_misc1 = concat(log_misc1,"MODERNADOSE1")
     OF mf_modernavaccinedose2:
      log_misc1 = concat(log_misc1,"MODERNADOSE2")
     OF mf_modernavaccinedose3:
      log_misc1 = concat(log_misc1,"MODERNADOSE3")
     OF mf_modernavaccinebooster:
      log_misc1 = concat(log_misc1,"MODERNABOOSTER")
     OF mf_johnsonandjohnsonvaccine:
      log_misc1 = concat(log_misc1,"JANDJNA")
     OF mf_johnsonandjohnsonvaccinebooster:
      log_misc1 = concat(log_misc1,"JANDJBOOSTER")
     OF mf_pedipfizer6mo4yvacdose1:
      log_misc1 = concat(log_misc1,"PEDIPFIZER6MO4YDOSE1")
     OF mf_pedipfizer6mo4yvacdose2:
      log_misc1 = concat(log_misc1,"PEDIPFIZER6MO4YDOSE2")
     OF mf_pedipfizer6mo4yvacdose3:
      log_misc1 = concat(log_misc1,"PEDIPFIZER6MO4YDOSE3")
     OF mf_pedimoderna6mo5yvacdose1:
      log_misc1 = concat(log_misc1,"PEDIMODERNA6MO5YDOSE1")
     OF mf_pedimoderna6mo5yvacdose2:
      log_misc1 = concat(log_misc1,"PEDIMODERNA6MO5YDOSE2")
     ELSE
      retval = 0,log_misc1 = "APPTTYPEFAILED",log_message = concat(
       "Appointment Type FAILED, ApptType: ",build(uar_get_code_display(se.appt_type_cd)))
    ENDCASE
   ENDIF
   IF (retval=100)
    log_message = concat("A COVID vaccine related appointment type was found. (",build(log_misc1),")"
     )
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 0
  SET log_message = "No COVID vaccine related appointment type was found."
  GO TO exit_script
 ELSE
  IF (retval=0)
   IF (log_message != "Script failed.")
    SET log_message = concat(log_message," - No COVID vaccine related appointment type was found.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 CALL echo(log_misc1)
 CALL echo(log_message)
END GO
