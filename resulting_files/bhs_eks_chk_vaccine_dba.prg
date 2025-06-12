CREATE PROGRAM bhs_eks_chk_vaccine:dba
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_immunizations_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "IMMUNIZATIONS"))
 DECLARE mf_person_id = f8 WITH protect, constant(trigger_personid)
 DECLARE ms_beg_dt = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt = vc WITH protect, noconstant(" ")
 DECLARE ms_current_year = vc WITH protect, noconstant(trim(cnvtstring(year(sysdate))))
 SET retval = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="BHS_FLU_SEASON"
  DETAIL
   IF (month(sysdate) IN (7, 8, 9, 10, 11,
   12))
    IF (d.info_name="BEGIN")
     ms_beg_dt = concat("01-",cnvtupper(substring(1,3,trim(d.info_char))),"-",ms_current_year,
      " 00:00:00"), ms_beg_dt = trim(ms_beg_dt,3)
    ELSEIF (d.info_name="END")
     ms_end_dt = concat(format(datetimefind(cnvtdatetime(concat("01-",cnvtupper(substring(1,3,trim(d
             .info_char))),"-",trim(cnvtstring((cnvtint(ms_current_year)+ 1))))),"M","E","E"),
       "dd-mmm-yyyy ;;d")," 23:59:59"), ms_end_dt = trim(ms_end_dt,3)
    ENDIF
   ELSE
    IF (d.info_name="BEGIN")
     ms_beg_dt = concat("01-",cnvtupper(substring(1,3,trim(d.info_char))),"-",trim(cnvtstring((
        cnvtint(ms_current_year) - 1)))," 00:00:00"), ms_beg_dt = trim(ms_beg_dt,3)
    ELSEIF (d.info_name="END")
     ms_end_dt = concat(format(datetimefind(cnvtdatetime(concat("01-",cnvtupper(substring(1,3,trim(d
             .info_char))),"-",ms_current_year)),"M","E","E"),"dd-mmm-yyyy ;;d")," 23:59:59"),
     ms_end_dt = trim(ms_end_dt,3)
    ENDIF
   ENDIF
  FOOT REPORT
   CALL echo(concat("begin date ",ms_beg_dt)),
   CALL echo(concat("end date ",ms_end_dt))
  WITH nocounter
 ;end select
 IF (cnvtupper( $1)="FLU")
  CALL echo("*****Checking Flu Logic*****")
  CALL echo(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  IF (sysdate BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
   CALL echo("*****select clin_event*****")
   SELECT INTO "nl:"
    ps_drug = cnvtupper(uar_get_code_display(ce.event_cd))
    FROM person p,
     clinical_event ce
    PLAN (p
     WHERE p.person_id=mf_person_id)
     JOIN (ce
     WHERE p.person_id=ce.person_id
      AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND ce.result_status_cd IN (mf_active_cd, mf_modified_cd, mf_altered_cd, mf_auth_cd)
      AND  EXISTS (
     (SELECT
      vese.event_cd
      FROM v500_event_set_explode vese
      WHERE vese.event_set_cd=mf_immunizations_cd
       AND vese.event_cd=ce.event_cd)))
    ORDER BY ce.event_end_dt_tm
    DETAIL
     IF (ps_drug IN ("AFLURIA", "FLUARIX", "FLULAVAL", "FLUMIST", "FLUVIRIN",
     "FLUVIRIN PRESERVATIVE-FREE", "FLUZONE", "FLUZONE PRESERVATIVE-FREE",
     "FLUZONE PRESERVATIVE-FREE PEDIATRIC", "INFLUENZA VIRUS VACCINE",
     "INFLUENZA VIRUS VACCINE (OBSOLETE)", "INFLUENZA VIRUS VACCINE (OLDTERM)",
     "INFLUENZA INACTIVATED (INTRAMUSCULAR)", "INFLUENZA LIVE (INTRANASAL)",
     "INFLUENZA VIRUS VACCINE, INACTIVATED",
     "INFLUENZA INACTIVATED (INTRAMUSCULAR)", "INFLUENZA LIVE (INTRANASAL)",
     "INFLUENZA VIRUS VACCINE", "INFLUENZA VIRUS VACCINE (OLDTERM)",
     "INFLUENZA VIRUS VACCINE, INACTIVATED",
     "INFLUENZA VIRUS VACCINE, LIVE", "AFLURIA (OLDTERM)", "FLUARIX", "FLULAVAL", "FLUMIST",
     "FLUVIRIN", "FLUVIRIN PRESERVATIVE-FREE", "FLUZONE", "FLUZONE PRESERVATIVE-FREE",
     "FLUZONE PRESERVATIVE-FREE PEDIATRIC"))
      IF (ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
       retval = 100,
       CALL echo("*****vacination WAS done in current flu season*****")
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual < 1)
    CALL echo("*****FLU vaccination WAS NOT found*****")
    SET retval = 0
   ENDIF
  ELSE
   SET retval = 100
   CALL echo("*****01 Current date NOT in flu season*****")
  ENDIF
 ELSEIF (cnvtupper( $1)="H1N1")
  CALL echo("*****checking H1N1 logic*****")
  IF (sysdate BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
   SELECT INTO "nl:"
    ps_drug = cnvtupper(uar_get_code_display(ce.event_cd))
    FROM person p,
     clinical_event ce
    PLAN (p
     WHERE p.person_id=mf_person_id)
     JOIN (ce
     WHERE p.person_id=ce.person_id
      AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND ce.result_status_cd IN (mf_active_cd, mf_modified_cd, mf_altered_cd, mf_auth_cd)
      AND  EXISTS (
     (SELECT
      vese.event_cd
      FROM v500_event_set_explode vese
      WHERE vese.event_set_cd=mf_immunizations_cd
       AND vese.event_cd=ce.event_cd)))
    ORDER BY ce.event_end_dt_tm
    DETAIL
     IF (ps_drug IN ("INFLUENZA VIRUS VACCINE, H1N1, INACTIVE", "INFLUENZA VIRUS VACCINE, H1N1, LIVE"
     ))
      CALL echo(ce.clinical_event_id),
      CALL echo(ps_drug)
      IF (ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
       retval = 100,
       CALL echo("vaccination WAS done IN the current flu season")
      ENDIF
     ENDIF
     CALL echo(retval)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    CALL echo("*****H1N1 vaccination WAS NOT found*****")
    SET retval = 0
   ENDIF
  ELSE
   SET retval = 100
   CALL echo("*****02 Current date NOT in flu season*****")
  ENDIF
 ELSEIF (cnvtupper( $1)="PNEUMO")
  CALL echo("*****checking Pneumo logic*****")
  SELECT INTO "nl:"
   ps_drug = uar_get_code_display(ce.event_cd)
   FROM person p,
    clinical_event ce
   PLAN (p
    WHERE p.person_id=mf_person_id)
    JOIN (ce
    WHERE p.person_id=ce.person_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.result_status_cd IN (mf_active_cd, mf_modified_cd, mf_altered_cd, mf_auth_cd)
     AND  EXISTS (
    (SELECT
     vese.event_cd
     FROM v500_event_set_explode vese
     WHERE vese.event_set_cd=mf_immunizations_cd
      AND vese.event_cd=ce.event_cd)))
   ORDER BY ce.event_end_dt_tm
   DETAIL
    IF (cnvtupper(ps_drug) IN ("PNEUMOCOCCAL VACCINE", "PNEUMOCOCCAL VACC (OBSOLETE)",
    "PNEUMOCOCCAL VACC (OLDTERM)", "PNEUMOCOCCAL CONJUGATE (PCV7)",
    "PNEUMOCOCCAL POLYSACCHARIDE (PPV23)",
    "PNEUMOCOCCAL 23-VALENT VACCINE", "PNEUMOCOCCAL 7-VALENT VACCINE", "PNEUMOVAX 23", "PREVNAR INJ",
    "PREVNAR",
    "PNEUMOCOCCAL 13-VALENT VACCINE", "PNEUMOCOCCAL 23-VALENT VACCINE",
    "PNEUMOCOCCAL 7-VALENT VACCINE", "PNEUMOCOCCAL CONJUGATE (PCV7)",
    "PNEUMOCOCCAL POLYSACCHARIDE (PPV23)",
    "PNEUMOCOCCAL VACC (OLDTERM)", "PNEUMOCOCCAL VACCINE", "PNEUMOVAX 23"))
     CALL echo(ce.clinical_event_id),
     CALL echo(ps_drug), retval = 100
    ENDIF
   FOOT REPORT
    ms_msg = build("Pneumo select:",retval)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(retval)
#end_script
END GO
