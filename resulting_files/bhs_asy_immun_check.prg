CREATE PROGRAM bhs_asy_immun_check
 PROMPT
  "  enter immunization type: " = "",
  "enter person_id (testing): " = 0.00
  WITH prompt1, prompt2
 IF (validate(personid,0.00) <= 0.00)
  SET trigger_personid = cnvtreal( $2)
 ENDIF
 FREE RECORD work
 RECORD work(
   1 immun_date = vc
   1 immun_cnt = i4
   1 immuns[*]
     2 event_cd = f8
 )
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE active_cd = f8
 DECLARE modified_cd = f8
 DECLARE altered_cd = f8
 DECLARE auth_cd = f8
 DECLARE med_class_cd = f8
 SET active_cd = uar_get_code_by("meaning",8,"ACTIVE")
 SET modified_cd = uar_get_code_by("meaning",8,"MODIFIED")
 SET altered_cd = uar_get_code_by("meaning",8,"ALTERED")
 SET auth_cd = uar_get_code_by("meaning",8,"AUTH")
 SET med_class_cd = uar_get_code_by("meaning",53,"MED")
 DECLARE tmp_val = i4
 DECLARE mf_immun_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 SET retval = 0
 IF (cnvtupper(trim( $1,4))="I")
  SET work->immun_date = format(cnvtdatetime((curdate - 182),0),"dd-mmm-yyyy hh:mm:ss;;d")
  SET work->immun_cnt = 20
  SET stat = alterlist(work->immuns,20)
  SET work->immuns[1].event_cd = uar_get_code_by("displaykey",72,"INFLUENZAINACTIVATEDINTRAMUSCULAR")
  SET work->immuns[2].event_cd = uar_get_code_by("displaykey",72,"INFLUENZALIVEINTRANASAL")
  SET work->immuns[3].event_cd = uar_get_code_by("displaykey",72,"INFLUENZAVIRUSVACC")
  SET work->immuns[4].event_cd = uar_get_code_by("displaykey",72,"INFLUENZAVIRUSVACCINE")
  SET work->immuns[5].event_cd = uar_get_code_by("DISPLAYKEY",72,"AFLURIAOLDTERM")
  SET work->immuns[6].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUARIXOLDTERM")
  SET work->immuns[7].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLULAVALOLDTERM")
  SET work->immuns[8].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUMISTOLDTERM")
  SET work->immuns[9].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUVIRINOLDTERM")
  SET work->immuns[10].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUVIRINPRESERVATIVEFREEOLDTERM")
  SET work->immuns[11].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUZONEOLDTERM")
  SET work->immuns[12].event_cd = uar_get_code_by("DISPLAYKEY",72,"FLUZONEPRESERVATIVEFREEOLDTERM")
  SET work->immuns[13].event_cd = uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEPEDIOLDTERM")
  SET work->immuns[14].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAINACTIVEIMOLDTERM")
  SET work->immuns[15].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZALIVEINTRANASALOLDTERM")
  SET work->immuns[16].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEH1N1INACTIVE"
   )
  SET work->immuns[17].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEH1N1LIVE")
  SET work->immuns[18].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEINACTIVATED")
  SET work->immuns[19].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINELIVE")
  SET work->immuns[20].event_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEOLDTERM")
  SET log_message = "searching for influenzas within the last six months"
 ELSEIF (cnvtupper(trim( $1,4))="P")
  SET work->immun_date = format(cnvtdatetime((curdate - 1826.25),0),"dd-mmm-yyyy hh:mm:ss;;d")
  SET work->immun_cnt = 14
  SET stat = alterlist(work->immuns,14)
  SET work->immuns[1].event_cd = uar_get_code_by("displaykey",72,"PNEUMOCOCCALCONJUGATEPCV7")
  SET work->immuns[2].event_cd = uar_get_code_by("displaykey",72,"PNEUMOCOCCALPOLYSACCHARIDEPPV23")
  SET work->immuns[3].event_cd = uar_get_code_by("displaykey",72,"PNEUMOCOCCALVACC")
  SET work->immuns[4].event_cd = uar_get_code_by("displaykey",72,"PNEUMOCOCCALVACCINE")
  SET work->immuns[5].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL13VALENTVACCINE")
  SET work->immuns[6].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL23VALENTVACCINE")
  SET work->immuns[7].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL7VALENTVACCINE")
  SET work->immuns[8].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALCONJUGATEPCV7OLDTERM")
  SET work->immuns[9].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALPOLYPPV23OLDTERM")
  SET work->immuns[10].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALVACCINEOLDTERM")
  SET work->immuns[11].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALVACCOLDTERM")
  SET work->immuns[12].event_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOVAX23OLDTERM")
  SET work->immuns[13].event_cd = uar_get_code_by("DISPLAYKEY",72,"PREVNARINJOLDTERM")
  SET work->immuns[14].event_cd = uar_get_code_by("DISPLAYKEY",72,"PREVNAROLDTERM")
  SET log_message = "searching for pneumococcals within the last five years"
 ELSE
  SET retval = - (1)
  SET log_message = "no immunization type selected"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ce.event_cd
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.person_id=trigger_personid
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.event_class_cd IN (med_class_cd, mf_immun_cd)
    AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
    AND expand(tmp_val,1,work->immun_cnt,ce.event_cd,work->immuns[tmp_val].event_cd)
    AND datetimediff(ce.event_end_dt_tm,cnvtdatetime(work->immun_date)) > 0)
  DETAIL
   CALL echo(build("Immunization: ",uar_get_code_display(ce.event_cd)))
   IF (datetimediff(ce.event_end_dt_tm,cnvtdatetime(work->immun_date)) > 0)
    retval = 100, log_message = build("Immunization found:",uar_get_code_display(ce.event_cd))
   ENDIF
  WITH nocounter
 ;end select
 IF (retval <= 0)
  SET log_message = build(log_message,"- NOT FOUND")
 ENDIF
#exit_script
 CALL echorecord(work)
 CALL echo(log_message)
 CALL echo(build("retval:",retval))
END GO
