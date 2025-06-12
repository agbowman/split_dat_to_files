CREATE PROGRAM bhs_disch_ace_arb_rule:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, encntrid
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE encounterid = f8 WITH private, noconstant(0.0)
 IF (( $ENCNTRID <= 0))
  SET enconterid = trigger_encntrid
 ELSE
  SET enconterid = value( $ENCNTRID)
 ENDIF
 IF (cnvtreal(enconterid) <= 0)
  SET retval = - (1)
  SET log_message = "no encounterId entered. exiting script"
  GO TO exit_script
 ENDIF
 SET retval = 0
 DECLARE temploc = i2 WITH protect, noconstant(0)
 DECLARE tempdiagval = vc WITH protect, noconstant(" ")
 DECLARE diagcnt = i2 WITH protect, noconstant(0)
 DECLARE act = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE snmct = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE admit = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"ADMIT"))
 DECLARE working = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"WORKING"))
 DECLARE billing = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"BILLING"))
 DECLARE final = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"FINAL"))
 DECLARE discharge = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"DISCHARGE"))
 DECLARE msg2 = vc WITH protect, noconstant(" ")
 DECLARE num = i4 WITH private, noconstant(0)
 DECLARE start = i4 WITH private, noconstant(1)
 CALL echo(build("SNMCT CD:",snmct))
 FREE RECORD allcki
 RECORD allcki(
   1 qual[*]
     2 sourcestring = vc
     2 cki = vc
     2 nomenid = f8
     2 sourcecd = f8
     2 level = i4
 )
 SET log_message = "Entering script bhs_admit_diagnosis_rule"
 SET action1 = 0
 SET action2 = 0
 SET action3 = 0
 SELECT INTO "NL:"
  FROM eks_module_audit_det em,
   eks_module_audit e
  PLAN (em
   WHERE em.encntr_id=value(enconterid))
   JOIN (e
   WHERE e.rec_id=em.module_audit_id
    AND e.module_name="BHS_SYN_DISCH_ACE_ARB"
    AND e.conclude=2)
  DETAIL
   IF (substring(1,3,trim(e.action_return,3))="100")
    action1 = 1
   ENDIF
   IF (substring(4,3,e.action_return)="100")
    action2 = 1
   ENDIF
   IF (substring(7,3,e.action_return)="100")
    action3 = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET log_message = build("Rule has been previously fired for encounter:",enconterid)
 ENDIF
 SET log_misc1 = "0"
 SELECT INTO "NL:"
  FROM diagnosis d,
   nomenclature n,
   bhs_nomen_list b
  PLAN (d
   WHERE d.encntr_id=value(enconterid)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND d.active_status_cd=act
    AND d.diag_type_cd IN (admit, working, billing, final, discharge))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id)
    AND n.active_ind=outerjoin(1)
    AND n.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND n.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND n.source_vocabulary_cd=outerjoin(snmct))
   JOIN (b
   WHERE ((b.nomenclature_id=n.nomenclature_id
    AND b.nomen_list_key IN ("ADMITDIAGNOSIS-ACUTEMYOCARDIAL/CORONARY", "ADMITDIAGNOSIS-HEARTFAILURE"
   )) OR (b.nomenclature_id=0
    AND b.nomen_list_key=" ")) )
  ORDER BY b.nomen_list_key
  HEAD REPORT
   log_misc1 = " "
  HEAD b.nomen_list_key
   CALL echo(build("head b.nomen_list_key:",b.nomen_list_key))
   IF (b.nomen_list_key="ADMITDIAGNOSIS-HEARTFAILURE")
    IF (action2=0)
     log_misc1 = cnvtstring((cnvtint(log_misc1)+ 2)), msg2 = build2(msg2,":HEARTFAILURE")
    ELSE
     msg2 = build2(msg2,":AlreadyFiredForHEARTFAILURE")
    ENDIF
   ELSEIF (b.nomen_list_key="ADMITDIAGNOSIS-ACUTEMYOCARDIAL/CORONARY")
    IF (action3=0)
     log_misc1 = cnvtstring((cnvtint(log_misc1)+ 4)), msg2 = build2(msg2,":ACUTEMYOCARDIAL/CORONARY")
    ELSE
     msg2 = build2(msg2,":AlreadyFiredForACUTEMYOCARDIAL/CORONARY")
    ENDIF
   ENDIF
  FOOT REPORT
   IF (cnvtreal(log_misc1) <= 0)
    log_misc1 = "30"
   ENDIF
   CALL echo(build("foot report log_misc1:",log_misc1))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (log_misc1="30")
   SET log_message = build2("diagnosis found: But not a qualifying dx ",trim(cnvtstring( $ENCNTRID),3
     ),":",cnvtstring(enconterid),msg2)
   SET retval = 0
  ELSE
   SET log_message = build2("Qualifying diagnosis found for enctr",trim(cnvtstring( $ENCNTRID),3),":",
    cnvtstring(enconterid),msg2)
   SET retval = 100
  ENDIF
 ELSE
  SET log_message = build2("Diagnosis not found for enctr ",trim(cnvtstring( $ENCNTRID),3),":",
   cnvtstring(enconterid),msg2)
  SET log_misc1 = "50"
  SET retval = 0
 ENDIF
#exit_script
 CALL echo(log_message)
 CALL echo(log_misc1)
 CALL echo(build("retval:",retval))
END GO
