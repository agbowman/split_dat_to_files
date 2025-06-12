CREATE PROGRAM bhs_health_maint_find_probtst:dba
 PROMPT
  "HealthMaintList" = ""
  WITH hmlist
 SET log_message = "inside bhs_health_maint_find_prob"
 SET retval = 0
 DECLARE diagcnt = i2 WITH protect, noconstant(0)
 DECLARE canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"CANCELED"))
 DECLARE resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
 DECLARE tempval = vc WITH noconstant(" ")
 DECLARE listvals = vc WITH noconstant(" ")
 FREE RECORD allcki
 RECORD allcki(
   1 qual[*]
     2 sourcestring = vc
     2 cki = vc
     2 nomenid = f8
     2 sourcecd = f8
 )
 SET opt_list_type = build("HM_DIABETESSCREENING|REGISTRY-CHF|REGISTRY-INTERNALCARDIACDEVICE|",
  "ADMITDIAGNOSIS-HEARTFAILURE|DMITDIAGNOSIS-ACUTEMYOCARDIAL/CORONARY")
 SET x = 0
 SET listvals = "b.nomen_list_key in ("
 WHILE (x < 100
  AND x != 100)
   SET x = (x+ 1)
   SET tempval = piece(opt_list_type,"|",x,"1",0)
   IF (tempval="1"
    AND x=1)
    SET listvals = build(listvals,"'",trim(opt_list_type,3),"'")
   ELSEIF (tempval != "1")
    IF (x > 1)
     SET listvals = build(listvals,",")
    ENDIF
    SET listvals = build(listvals,"'",trim(tempval,3),"'")
   ELSE
    SET x = 100
   ENDIF
 ENDWHILE
 SET listvals = replace(listvals,"''","'")
 SET listvals = build(listvals,")")
 CALL echo(listvals)
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE p.person_id=1344038
    AND p.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
    AND  NOT (p.life_cycle_status_cd IN (canceled, resolved, inactive)))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm)
  DETAIL
   diagcnt = (diagcnt+ 1), stat = alterlist(allcki->qual,diagcnt), allcki->qual[diagcnt].cki = n
   .concept_cki,
   allcki->qual[diagcnt].sourcestring = n.source_string, allcki->qual[diagcnt].sourcecd = n
   .source_vocabulary_cd, allcki->qual[diagcnt].nomenid = n.nomenclature_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET log_message = build2("No problems found for the personid: ",1344038)
  GO TO exit_script
 ENDIF
 CALL echorecord(allcki)
 CALL echo("comparing projects against problem list")
 SELECT INTO "nl:"
  FROM bhs_nomen_list b,
   nomenclature n,
   (dummyt d  WITH seq = diagcnt)
  PLAN (d)
   JOIN (b
   WHERE (b.nomenclature_id=allcki->qual[d.seq].nomenid)
    AND parser(listvals)
    AND b.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=b.nomenclature_id)
  HEAD b.nomen_list_key
   log_message = trim(n.source_string,3), retval = 100
  WITH nocounter
 ;end select
 IF (retval=100)
  SET log_message = build2("Qualifying problem found:",log_message,"; for PersonId:",1344038)
 ELSE
  SET log_message = build2("Qualifying problem not found for PersonId:",personid,listvals,"D",diagcnt,
   "A")
 ENDIF
#exit_script
 FREE RECORD allcki
 CALL echo(log_message)
END GO
