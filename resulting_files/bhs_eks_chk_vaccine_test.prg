CREATE PROGRAM bhs_eks_chk_vaccine_test
 SET eid = trigger_encntrid
 SET pid = trigger_personid
 SET flumode = 0
 SET pneumo = 0
 SET fluseasonind = 0
 SET retval = 0
 DECLARE active_cd = f8
 DECLARE modified_cd = f8
 DECLARE altered_cd = f8
 DECLARE auth_cd = f8
 DECLARE med_class_cd = f8
 DECLARE reply_ind = i2
 DECLARE immunizations_cd = f8
 DECLARE code_display = vc
 DECLARE msg = vc
 SET active_cd = uar_get_code_by("MEANING",8,"ACTIVE")
 SET modified_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET altered_cd = uar_get_code_by("MEANING",8,"ALTERED")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET med_class_cd = uar_get_code_by("MEANING",53,"MED")
 SET immunizations_cd = uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS")
 SET testdate = cnvtdatetime(cnvtdate(09102009),150000)
 SET 5yrslookback = cnvtlookbehind("5,Y")
 SET fluseasonin = 0
 IF (( $2="TEST"))
  SET currentyear = datetimepart(cnvtdatetime(testdate),1)
  SET currentmonth = datetimepart(cnvtdatetime(testdate),2)
 ELSE
  SET currentyear = datetimepart(cnvtdatetime(curdate,curtime3),1)
  SET currentmonth = datetimepart(cnvtdatetime(curdate,curtime3),2)
 ENDIF
 SET fluyear = 0
 SET flumonth = 0
 IF (( $1="Flu"))
  SET fluemode = 1
  SET msg = build(msg,"Checking Flu Logic")
  IF (currentmonth IN (9, 10, 11, 12, 1,
  2, 3, 4, 5))
   SET fluseasonind = 1
   SET msg = build(msg,"_","Month:",currentmonth,"Fluseason:",
    fluseasonind)
   SET retval = 0
   CALL echo(build("FluSeasonIn:",fluseasonin))
   CALL echo(build("msg:",msg))
   CALL echo(build("retval:",retval))
  ELSE
   SET msg = build(msg,"_","Month:",currentmonth,"Fluseason:",
    fluseasonind)
   SET retval = 100
   CALL echo(build("FluSeasonIn:",fluseasonin))
   CALL echo(build("msg:",msg))
   CALL echo(build("retval:",retval))
   GO TO end_script
  ENDIF
  CALL echo(build("FluSeasonIn:",fluseasonin))
  CALL echo(build("msg:",msg))
  CALL echo(build("retval:",retval))
  IF (fluseasonind=1)
   SELECT INTO "nl:"
    admindate = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"), drug = cnvtupper(
     uar_get_code_display(ce.event_cd))
    FROM person p,
     clinical_event ce
    PLAN (p
     WHERE p.person_id=pid)
     JOIN (ce
     WHERE p.person_id=ce.person_id
      AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
      AND  EXISTS (
     (SELECT
      vese.event_cd
      FROM v500_event_set_explode vese
      WHERE vese.event_set_cd=immunizations_cd
       AND vese.event_cd=ce.event_cd)))
    ORDER BY ce.event_end_dt_tm
    DETAIL
     IF (drug IN ("AFLURIA", "FLUARIX", "FLULAVAL", "FLUMIST", "FLUVIRIN",
     "FLUVIRIN PRESERVATIVE-FREE", "FLUZONE", "FLUZONE PRESERVATIVE-FREE",
     "FLUZONE PRESERVATIVE-FREE PEDIATRIC", "INFLUENZA VIRUS VACCINE",
     "INFLUENZA VIRUS VACCINE (OBSOLETE)", "INFLUENZA VIRUS VACCINE (OLDTERM)",
     "INFLUENZA INACTIVATED (INTRAMUSCULAR)", "INFLUENZA LIVE (INTRANASAL)",
     "INFLUENZA VIRUS VACCINE, INACTIVATED",
     "INFLUENZA VIRUS VACCINE, LIVE, TRIVALENT", "INFLUENZA INACTIVATED (INTRAMUSCULAR)",
     "INFLUENZA LIVE (INTRANASAL)", "INFLUENZA VIRUS VACCINE", "INFLUENZA VIRUS VACCINE (OLDTERM)",
     "INFLUENZA VIRUS VACCINE, INACTIVATED", "INFLUENZA VIRUS VACCINE, LIVE, TRIVALENT",
     "AFLURIA (OLDTERM)", "FLUARIX", "FLULAVAL",
     "FLUMIST", "FLUVIRIN", "FLUVIRIN PRESERVATIVE-FREE", "FLUZONE", "FLUZONE PRESERVATIVE-FREE",
     "FLUZONE PRESERVATIVE-FREE PEDIATRIC"))
      CALL echo(ce.clinical_event_id),
      CALL echo(drug),
      CALL echo(admindate),
      fluyear = datetimepart(ce.event_end_dt_tm,1), flumonth = datetimepart(ce.event_end_dt_tm,2)
      IF (((fluyear=currentyear
       AND flumonth IN (9, 10, 11, 12)) OR (flumonth IN (1, 2, 3)
       AND (fluyear=(currentyear - 1)))) )
       retval = 100
      ELSE
       retval = 0
      ENDIF
     ENDIF
     CALL echo(retval)
    FOOT REPORT
     msg = build(msg,"_Year:",currentyear,"_Month:",currentmonth,
      "_flu year:",fluyear,"_flu month:",flumonth)
    WITH nocounter
   ;end select
   CALL echo(msg)
   CALL echo(build("retval:",retval))
  ENDIF
 ELSEIF (( $1="H1N1"))
  SELECT INTO "nl:"
   admindate = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"), drug = cnvtupper(
    uar_get_code_display(ce.event_cd))
   FROM person p,
    clinical_event ce
   PLAN (p
    WHERE p.person_id=pid)
    JOIN (ce
    WHERE p.person_id=ce.person_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
     AND  EXISTS (
    (SELECT
     vese.event_cd
     FROM v500_event_set_explode vese
     WHERE vese.event_set_cd=immunizations_cd
      AND vese.event_cd=ce.event_cd)))
   ORDER BY ce.event_end_dt_tm
   DETAIL
    IF (drug IN ("INFLUENZA VIRUS VACCINE, H1N1, INACTIVE", "INFLUENZA VIRUS VACCINE, H1N1, LIVE"))
     CALL echo(ce.clinical_event_id),
     CALL echo(drug),
     CALL echo(admindate),
     fluyear = datetimepart(ce.event_end_dt_tm,1), flumonth = datetimepart(ce.event_end_dt_tm,2)
     IF (((fluyear=currentyear
      AND flumonth IN (9, 10, 11, 12)) OR (flumonth IN (1, 2, 3, 4, 5,
     6)
      AND (fluyear=(currentyear - 1)))) )
      retval = 100
     ELSE
      retval = 0
     ENDIF
    ENDIF
    CALL echo(retval)
   FOOT REPORT
    msg = build(msg,"_Year:",currentyear,"_Month:",currentmonth,
     "_flu year:",fluyear,"_flu month:",flumonth)
   WITH nocounter
  ;end select
 ENDIF
#check_pneumococcal
 CALL echo(build("flu:",retval))
 IF (( $1="Pneumo"))
  SET pneumo = 1
  SELECT INTO "nl:"
   admindate = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"), drug = uar_get_code_display(ce
    .event_cd)
   FROM person p,
    clinical_event ce
   PLAN (p
    WHERE p.person_id=pid)
    JOIN (ce
    WHERE p.person_id=ce.person_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
     AND ce.event_end_dt_tm > cnvtdatetime(5yrslookback)
     AND  EXISTS (
    (SELECT
     vese.event_cd
     FROM v500_event_set_explode vese
     WHERE vese.event_set_cd=immunizations_cd
      AND vese.event_cd=ce.event_cd)))
   ORDER BY ce.event_end_dt_tm
   DETAIL
    IF (cnvtupper(drug) IN ("PNEUMOCOCCAL VACCINE", "PNEUMOCOCCAL VACC (OBSOLETE)",
    "PNEUMOCOCCAL VACC (OLDTERM)", "PNEUMOCOCCAL CONJUGATE (PCV7)",
    "PNEUMOCOCCAL POLYSACCHARIDE (PPV23)",
    "PNEUMOCOCCAL 23-VALENT VACCINE", "PNEUMOCOCCAL 7-VALENT VACCINE", "PNEUMOVAX 23", "PREVNAR INJ",
    "PREVNAR",
    "PNEUMOCOCCAL 13-VALENT VACCINE", "PNEUMOCOCCAL 23-VALENT VACCINE",
    "PNEUMOCOCCAL 7-VALENT VACCINE", "PNEUMOCOCCAL CONJUGATE (PCV7)",
    "PNEUMOCOCCAL POLYSACCHARIDE (PPV23)",
    "PNEUMOCOCCAL VACC (OLDTERM)", "PNEUMOCOCCAL VACCINE", "PNEUMOVAX 23"))
     CALL echo(ce.clinical_event_id),
     CALL echo(drug),
     CALL echo(admindate),
     retval = 100
    ENDIF
   FOOT REPORT
    msg = build("Pneumo select:",retval)
   WITH nocounter
  ;end select
  CALL echo(msg)
  CALL echo(build("retval:",retval))
  CALL echo(format(cnvtdatetime(5yrslookback),";;q"))
 ENDIF
 CALL echo(retval)
#end_script
END GO
