CREATE PROGRAM ade_calc_creat:dba
 DECLARE iuseservice = i2 WITH protect, noconstant(0)
 DECLARE inerror_cd = f8 WITH protect
 DECLARE nprefresult = i4 WITH protect, noconstant(0)
 DECLARE hattribute = i4 WITH protect, noconstant(0)
 DECLARE weight_attribute = i2 WITH protect
 DECLARE wt_in_kg = f8 WITH protect
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE temp_weight_disp = vc WITH protect
 DECLARE code_value = f8 WITH protect
 DECLARE ht_in_cm = f8 WITH protect
 DECLARE heightprefstr = vc WITH protect, constant("clinicalheightvaliddays")
 DECLARE weightprefstr = vc WITH protect, constant("clinicalweightvaliddays")
 DECLARE creatinineprefstr = vc WITH protect, constant("serumcreatininevaliddays")
 DECLARE usekdmoservice(null) = null WITH protect
 DECLARE usemanualcalc(null) = null WITH protect
 IF (validate(formulaservicescriptrep)=0)
  RECORD formulaservicescriptrep(
    1 contentexists = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE pha_formula_service_active  WITH replace("REPLY",formulaservicescriptrep)
 SET iuseservice = formulaservicescriptrep->contentexists
 IF (iuseservice=1)
  CALL usekdmoservice(null)
 ELSE
  CALL usemanualcalc(null)
 ENDIF
 SUBROUTINE usekdmoservice(null)
   CALL echo("In useKDMOService")
   DECLARE log_misc2 = f8
   DECLARE temp_message = vc
   DECLARE height_input = i2 WITH protect, constant(1)
   DECLARE weight_input = i2 WITH protect, constant(2)
   DECLARE sercr_input = i2 WITH protect, constant(3)
   DECLARE crcl = f8 WITH protect, noconstant(0.0)
   DECLARE racecd = f8 WITH protect, noconstant(0.0)
   DECLARE ethnicitycd = f8 WITH protect, noconstant(0.0)
   DECLARE sercr = f8 WITH protect, noconstant(0.0)
   DECLARE sercr_unit_cd = f8 WITH protect, noconstant(0.0)
   DECLARE crclcdmeaning = vc WITH protect, noconstant("")
   DECLARE birth_dt_tm = dq8
   DECLARE weight = f8
   DECLARE weight_unit_cd = f8 WITH protect, noconstant(0.0)
   DECLARE height = f8
   DECLARE height_unit_cd = f8
   DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE sex_cd = f8 WITH protect, noconstant(0.0)
   DECLARE convert_weight(null) = i2 WITH protect
   DECLARE convert_height(null) = i2 WITH protect
   DECLARE get_serum_creatinine(null) = i2 WITH protect
   DECLARE getdefaultmethod(methodtype=vc) = f8
   DECLARE calculatedemographic(methodcd=f8) = i2 WITH protect
   DECLARE get_demographic_groups(null) = i2 WITH protect
   DECLARE perform_calc(null) = i2 WITH protect
   DECLARE getfacilitycd(trigger_encntrid=f8) = i2 WITH protect
   DECLARE getprefmgrpref(prefstr=vc) = i2 WITH protect
   DECLARE formatprecisiondisplay(value=f8,precision=i2) = vc
   CALL convert_weight(0)
   CALL convert_height(0)
   CALL get_serum_creatinine(0)
   IF (weight > 0.0
    AND height > 0.0
    AND sercr > 0.0)
    CALL perform_calc(null)
   ELSE
    SET retval = 0
    SET temp_message = "Patient is missing "
    IF (weight=0.0)
     SET temp_message = concat(temp_message,"weight ")
    ENDIF
    IF (height=0.0)
     SET temp_message = concat(temp_message,"height ")
    ENDIF
    IF (sercr=0.0)
     SET temp_message = concat(temp_message,"serum creatinine")
    ENDIF
    SET log_message = concat(temp_message,"Formula Builder Formulas Used")
   ENDIF
   SUBROUTINE perform_calc(null)
     CALL echo("in perform_calc")
     SELECT INTO "nl:"
      sex_mean = uar_get_code_meaning(p.sex_cd)
      FROM person p
      WHERE p.person_id=trigger_personid
      DETAIL
       sex_cd = p.sex_cd
      WITH nocounter
     ;end select
     CALL getfacilitycd(trigger_encntrid)
     CALL get_demographic_groups(0)
     SET hattribute = uar_srvadditem(hrequest,"attributes")
     SET stat = uar_srvsetshort(hattribute,"attribute_type",weight_attribute)
     SET stat = uar_srvsetdouble(hattribute,"value",wt_in_kg)
     SET stat = uar_srvsetstring(hattribute,"unit_cki","CKI.CODEVALUE!2751")
     SET crclcd = getdefaultmethod(nullterm("CRCL"))
     SET crclcdmeaning = uar_get_code_meaning(crclcd)
     SET crcl = calculatedemographic(crclcd)
     CALL echo(build("CrCl:",crcl))
     SET log_misc2 = crcl
     IF (log_misc2 > 0)
      IF (log_misc2 < 10)
       SET log_misc1 = cnvtstring(log_misc2,4,2,r)
      ELSEIF (log_misc2 < 100)
       SET log_misc1 = cnvtstring(log_misc2,5,2,r)
      ELSE
       SET log_misc1 = cnvtstring(log_misc2,6,2,r)
      ENDIF
     ENDIF
     SET log_message = concat("Calculation successful with a result of ",log_misc1,"."," ",
      "Formula Builder Formulas Used",
      ".")
     SET retval = 100
   END ;Subroutine
   SUBROUTINE getdefaultmethod(methodtype)
     CALL echo("in GetDefaultMethod")
     DECLARE ltransaction = i4 WITH protect, constant(302505)
     DECLARE hmessage = i4 WITH protect, noconstant(0)
     DECLARE hrequest = i4 WITH protect, noconstant(0)
     DECLARE hreply = i4 WITH protect, noconstant(0)
     DECLARE htransactionstatusstruct = i4 WITH protect, noconstant(0)
     DECLARE hformulainputlist = i4 WITH protect, noconstant(0)
     DECLARE hmethodsequencelist = i4 WITH protect, noconstant(0)
     DECLARE nstatus = i2 WITH protect, noconstant(0)
     DECLARE ncnt = i2 WITH protect, noconstant(0)
     IF (methodtype != "")
      SET hmessage = uar_srvselectmessage(ltransaction)
      SET hrequest = uar_srvcreaterequest(hmessage)
      SET hreply = uar_srvcreatereply(hmessage)
      SET nstatus = uar_srvsetstring(hrequest,"methodType",nullterm(methodtype))
      CALL echo(build("methodType:",methodtype))
      SET nstatus = uar_srvsetdouble(hrequest,"facilityCd",facility_cd)
      CALL echo(build("facilityCd:",facility_cd))
      SET nstatus = uar_srvsetdouble(hrequest,"genderCd",sex_cd)
      CALL echo(build("genderCd:",sex_cd))
      SET nstatus = uar_srvsetdouble(hrequest,"ethnicityCd",ethnicitycd)
      CALL echo(build("ethnicityCd:",ethnicitycd))
      SET nstatus = uar_srvsetdouble(hrequest,"raceCd",racecd)
      CALL echo(build("raceCd:",racecd))
      CALL echo(birth_dt_tm)
      CALL echo(cnvtdatetime(birth_dt_tm))
      SET nstatus = uar_srvsetdate(hrequest,"birthDate",cnvtdatetime(birth_dt_tm))
      CALL echo(nstatus)
      CALL echo(build("Birthdate:",format(birth_dt_tm,";;q")))
      IF (height > 0
       AND height_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",height_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",height)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",height_unit_cd)
      ENDIF
      CALL echo(build("height:",height))
      CALL echo(build("heightUnit:",height_unit_cd))
      IF (weight > 0
       AND weight_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",weight_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",weight)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",weight_unit_cd)
      ENDIF
      CALL echo(build("weight:",weight))
      CALL echo(build("weightUnit:",weight_unit_cd))
      IF (sercr > 0
       AND sercr_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",sercr_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",sercr)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",sercr_unit_cd)
      ENDIF
      CALL echo(build("sercr:",sercr))
      CALL echo(build("sercrUnit:",sercr_unit_cd))
      SET nstatus = uar_srvexecute(hmessage,hrequest,hreply)
      CALL echo(nstatus)
      IF (nstatus=0)
       SET htransactionstatusstruct = uar_srvgetstruct(hreply,"transaction_status")
       SET nstatus = uar_srvgetshort(htransactionstatusstruct,"success_ind")
       IF (nstatus=1)
        SET ncnt = uar_srvgetitemcount(hreply,"methodSequence")
        CALL echo(build("methodSequence count:",ncnt))
        IF (ncnt > 0)
         SET hmethodsequencelist = uar_srvgetitem(hreply,"methodSequence",0)
         CALL echo(build("methodCd:",uar_srvgetdouble(hmethodsequencelist,"methodCd")))
         RETURN(uar_srvgetdouble(hmethodsequencelist,"methodCd"))
        ENDIF
       ENDIF
      ENDIF
      CALL uar_srvdestroyinstance(hrequest)
      CALL uar_srvdestroyinstance(hreply)
      CALL uar_srvdestroymessage(hmessage)
     ENDIF
     RETURN(0.0)
   END ;Subroutine
   SUBROUTINE calculatedemographic(methodcd)
     CALL echo("in CalculateDemographic")
     DECLARE ltransaction = i4 WITH protect, constant(302502)
     DECLARE hmessage = i4 WITH protect, noconstant(0)
     DECLARE hrequest = i4 WITH protect, noconstant(0)
     DECLARE hreply = i4 WITH protect, noconstant(0)
     DECLARE htransactionstatusstruct = i4 WITH protect, noconstant(0)
     DECLARE hformulainputlist = i4 WITH protect, noconstant(0)
     DECLARE nstatus = i2 WITH protect, noconstant(0)
     DECLARE nevalstatus = i2 WITH protect, noconstant(0)
     IF (methodcd > 0)
      SET hmessage = uar_srvselectmessage(ltransaction)
      SET hrequest = uar_srvcreaterequest(hmessage)
      SET hreply = uar_srvcreatereply(hmessage)
      SET nstatus = uar_srvsetdouble(hrequest,"methodCd",methodcd)
      CALL echo(build("methodCd:",methodcd))
      SET nstatus = uar_srvsetdouble(hrequest,"facilityCd",facility_cd)
      CALL echo(build("facilityCd:",facility_cd))
      SET nstatus = uar_srvsetdouble(hrequest,"genderCd",sex_cd)
      CALL echo(build("genderCd:",sex_cd))
      SET nstatus = uar_srvsetdouble(hrequest,"ethnicityCd",ethnicitycd)
      CALL echo(build("ethnicityCd:",ethnicitycd))
      SET nstatus = uar_srvsetdouble(hrequest,"raceCd",racecd)
      CALL echo(build("raceCd:",racecd))
      SET nstatus = uar_srvsetdate(hrequest,"birthDate",cnvtdatetime(birth_dt_tm))
      CALL echo(build("Birthdate:",format(birth_dt_tm,";;q")))
      IF (height > 0
       AND height_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",height_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",height)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",height_unit_cd)
      ENDIF
      CALL echo(build("height:",height))
      CALL echo(build("heightUnit:",height_unit_cd))
      IF (weight > 0
       AND weight_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",weight_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",weight)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",weight_unit_cd)
      ENDIF
      CALL echo(build("weight:",weight))
      CALL echo(build("weightUnit:",weight_unit_cd))
      IF (sercr > 0
       AND sercr_unit_cd > 0)
       SET hformulainputlist = uar_srvadditem(hrequest,"formulaInputs")
       SET nstatus = uar_srvsetshort(hformulainputlist,"inputType",sercr_input)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"value",sercr)
       SET nstatus = uar_srvsetdouble(hformulainputlist,"unitCd",sercr_unit_cd)
      ENDIF
      CALL echo(build("sercr:",sercr))
      CALL echo(build("sercrUnit:",sercr_unit_cd))
      SET nstatus = uar_srvexecute(hmessage,hrequest,hreply)
      CALL echo(nstatus)
      IF (nstatus=0)
       SET htransactionstatusstruct = uar_srvgetstruct(hreply,"transaction_status")
       SET nstatus = uar_srvgetshort(htransactionstatusstruct,"success_ind")
       CALL echo(nstatus)
       IF (nstatus=1)
        CALL echo(hreply)
        SET nevalstatus = uar_srvgetshort(hreply,"evaluationStatus")
        CALL echo(nevalstatus)
        CALL echo(build("status:",nevalstatus))
        IF (((nevalstatus < 3) OR (nevalstatus > 5)) )
         RETURN(uar_srvgetdouble(hreply,"result"))
        ENDIF
       ENDIF
      ENDIF
      CALL uar_srvdestroyinstance(hrequest)
      CALL uar_srvdestroyinstance(hreply)
      CALL uar_srvdestroymessage(hmessage)
     ENDIF
     RETURN(0.0)
   END ;Subroutine
   SUBROUTINE convert_weight(null)
     CALL echo("in convert_weight")
     DECLARE weight_passed = i2 WITH protect
     CALL echo(getprefmgrpref(weightprefstr))
     SET nprefresult = (0 - getprefmgrpref(weightprefstr))
     SET comparedate = datetimeadd(cnvtdatetime(curdate,curtime3),nprefresult)
     CALL echo(build("Weight pref result = ",nprefresult))
     CALL echo(build("Compare Date = ",comparedate))
     SELECT INTO "nl:"
      FROM v500_event_set_code vesc,
       v500_event_set_explode vese,
       clinical_event ce
      PLAN (vesc
       WHERE vesc.event_set_name_key="CLINICALWEIGHT")
       JOIN (vese
       WHERE vese.event_set_cd=vesc.event_set_cd)
       JOIN (ce
       WHERE ce.person_id=trigger_personid
        AND ce.event_cd=vese.event_cd
        AND ce.publish_flag=1
        AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
        AND ce.result_status_cd != inerror_cd)
      ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
      HEAD REPORT
       wt_found = "N", isnum = 0
      DETAIL
       IF (wt_found="N")
        isnum = isnumeric(ce.result_val)
        IF (isnum > 0
         AND ce.result_units_cd > 0)
         wt_found = "Y", weight_passed = 1, weight = cnvtreal(ce.result_val),
         weight_unit_cd = ce.result_units_cd, weight_event_disp = trim(uar_get_code_display(ce
           .event_cd)), weight_dt_tm_disp = concat(format(ce.event_end_dt_tm,"@SHORTDATE4YR")," ",
          format(ce.event_end_dt_tm,"@TIMENOSECONDS")),
         CALL echo(build("value of weight (from CE) is",weight)),
         CALL echo(build("value of weight unit cd (from CE) is",weight_unit_cd))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (weight_passed=1
      AND wt_in_kg=0.0)
      SET kg_cd = 0.0
      SET kg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2751")
      IF (kg_cd=0.0)
       CALL echo("KG code not found using cki 2751.")
      ENDIF
      SET g_cd = uar_get_code_by_cki("CKI.CODEVALUE!6123")
      IF (g_cd=0.0)
       CALL echo("G code not found using cki 6123.")
      ENDIF
      IF (weight_unit_cd=kg_cd)
       SET wt_in_kg = weight
       CALL echo(concat("Weight already in kg, no conversion. Weight: ",cnvtstring(wt_in_kg,5,2,r)))
      ELSEIF (weight_unit_cd=g_cd)
       SET wt_in_kg = (weight/ 1000)
       CALL echo(concat("Weight in g(",cnvtstring(weight,8,2,r),"), divide by 1000 to get kg wt(",
         cnvtstring(wt_in_kg,5,2,r),")"))
      ELSE
       SET lb_cd = 0.0
       SET lb_cd = uar_get_code_by_cki("CKI.CODEVALUE!2746")
       IF (lb_cd=0.0)
        CALL echo("LB code not found using cki 2746.")
       ENDIF
       IF (weight_unit_cd=lb_cd)
        SET wt_in_kg = (weight * 0.4545)
        CALL echo(concat("Weight in lb(",cnvtstring(weight,5,2,r),
          "), multiply by 0.4536 to get kg wt(",cnvtstring(wt_in_kg,5,2,r),")"))
       ELSE
        SET oz_cd = 0.0
        SET oz_cd = uar_get_code_by_cki("CKI.CODEVALUE!2745")
        IF (oz_cd=0.0)
         CALL echo("Ounce code not found using cki 2745.")
        ENDIF
        IF (weight_unit_cd=oz_cd)
         SET wt_in_kg = ((weight/ 16) * 0.4545)
         CALL echo(concat("Weight in oz(",cnvtstring(weight,5,2,r),
           "), divide by 16 and multiply by 0.4536 to get kg wt(",cnvtstring(wt_in_kg,5,2,r),")"))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (wt_in_kg > 0)
      CALL echo(build("weight is: ",wt_in_kg))
      SET temp_weight_disp = formatprecisiondisplay(wt_in_kg,2)
      CALL echo(build("Temp_Weight is: ",temp_weight_disp))
      SET weight_disp = build("(",temp_weight_disp,"kg)")
      CALL echo(build("weight disp:",weight_disp))
      SET wt_found = 1
     ENDIF
   END ;Subroutine
   SUBROUTINE convert_height(null)
     CALL echo("convert_height")
     DECLARE height_passed = i2 WITH protect
     IF (height_passed=0)
      IF (inerror_cd=0)
       SET code_set = 8
       SET cdf_meaning = "INERROR"
       EXECUTE cpm_get_cd_for_cdf
       SET inerror_cd = code_value
      ENDIF
      SET nprefresult = (0 - getprefmgrpref(heightprefstr))
      SET comparedate = datetimeadd(cnvtdatetime(curdate,curtime3),nprefresult)
      CALL echo(build("Height pref result = ",nprefresult))
      CALL echo(build("Compare Date = ",comparedate))
      SELECT INTO "nl:"
       FROM v500_event_set_code vesc,
        v500_event_set_explode vese,
        clinical_event ce
       PLAN (vesc
        WHERE vesc.event_set_name_key="CLINICALHEIGHT")
        JOIN (vese
        WHERE vese.event_set_cd=vesc.event_set_cd)
        JOIN (ce
        WHERE ce.person_id=trigger_personid
         AND ce.event_cd=vese.event_cd
         AND ce.publish_flag=1
         AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
         AND ce.result_status_cd != inerror_cd)
       ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
       HEAD REPORT
        ht_found = "N", isnum = 0
       DETAIL
        IF (ht_found="N")
         isnum = isnumeric(ce.result_val)
         IF (isnum > 0
          AND ce.result_units_cd > 0)
          ht_found = "Y", height_passed = 1, height = cnvtreal(ce.result_val),
          height_unit_cd = ce.result_units_cd,
          CALL echo(build("value of height (from CE) is",height)),
          CALL echo(build("value of height unit cd (from CE) is",height_unit_cd))
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     IF (height_passed=1
      AND ht_in_cm=0.0)
      SET cm_cd = 0.0
      SET cm_cd = uar_get_code_by_cki("CKI.CODEVALUE!3714")
      IF (cm_cd=0.0)
       CALL echo("CM code not found using cki 3714.")
      ENDIF
      IF (height_unit_cd=cm_cd)
       SET ht_in_cm = height
       CALL echo(concat("Height already in cm, no conversion. Height: ",cnvtstring(ht_in_cm,6,2,r)))
      ELSE
       SET in_cd = 0.0
       SET in_cd = uar_get_code_by_cki("CKI.CODEVALUE!2754")
       IF (in_cd=0.0)
        CALL echo("Inches code not found using cki 2754.")
       ENDIF
       IF (height_unit_cd=in_cd)
        SET ht_in_cm = (height * 2.54)
        CALL echo(concat("Height in inches(",cnvtstring(height,4,2,r),
          "), multiply by 2.54 to get cm ht(",cnvtstring(ht_in_cm,6,2,r),")"))
       ELSE
        SET ft_cd = 0.0
        SET ft_cd = uar_get_code_by_cki("CKI.CODEVALUE!2753")
        IF (ft_cd=0.0)
         CALL echo("Foot code not found using cki 2753.")
        ENDIF
        IF (height_unit_cd=ft_cd)
         SET ht_in_cm = (height * 30.48)
         CALL echo(concat("Height in feet(",cnvtstring(height,4,2,r),
           "), multiply by 30.48 to get cm ht(",cnvtstring(ht_in_cm,6,2,r),")"))
        ELSE
         SET m_cd = 0.0
         SET m_cd = uar_get_code_by_cki("CKI.CODEVALUE!2757")
         IF (m_cd=0.0)
          CALL echo("Meter code not found using cki 2757.")
         ENDIF
         IF (height_unit_cd=m_cd)
          SET ht_in_cm = (height * 1000)
          CALL echo(concat("Height in meters(",cnvtstring(height,4,3,r),
            "), multiply by 1000 to get cm ht(",cnvtstring(ht_in_cm,6,2,r),")"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   END ;Subroutine
   SUBROUTINE get_serum_creatinine(null)
     CALL echo("get_serum_creatinine")
     IF (inerror_cd=0)
      SET code_set = 8
      SET cdf_meaning = "INERROR"
      EXECUTE cpm_get_cd_for_cdf
      SET inerror_cd = code_value
     ENDIF
     SET sercr_found = "N"
     SET sercr_unit_cd = 0.0
     SET sercr = 0.0
     SET sercr_in_mgpdl = 0.0
     CALL echo("Searching clinical events for CREATININE...")
     CALL echo(getprefmgrpref(creatinineprefstr))
     SET nprefresult = (0 - getprefmgrpref(creatinineprefstr))
     SET comparedate = datetimeadd(cnvtdatetime(curdate,curtime3),nprefresult)
     CALL echo(build("Serum Creatinine pref result = ",nprefresult))
     CALL echo(build("Compare Date = ",comparedate))
     CALL echo(sercr)
     SELECT INTO "nl:"
      FROM v500_event_set_code vesc,
       v500_event_set_explode vese,
       clinical_event ce
      PLAN (vesc
       WHERE vesc.event_set_name_key="CREATININE")
       JOIN (vese
       WHERE vese.event_set_cd=vesc.event_set_cd)
       JOIN (ce
       WHERE ce.person_id=trigger_personid
        AND ce.event_cd=vese.event_cd
        AND ce.publish_flag=1
        AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
        AND ce.result_status_cd != inerror_cd)
      ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
      HEAD REPORT
       sercr_found = "N", isnum = 0, latest_event_dt_tm = null,
       dupfound = 0
      DETAIL
       IF (sercr_found="N")
        CALL echo(isnum), isnum = isnumeric(ce.result_val),
        CALL echo(isnum)
        IF (isnum > 0
         AND ce.result_units_cd > 0)
         sercr_found = "Y", sercr = cnvtreal(ce.result_val), sercr_unit_cd = ce.result_units_cd,
         latest_event_dt_tm = ce.event_end_dt_tm,
         CALL echo(build("value of sercr is",sercr)),
         CALL echo(build("value of sercr unit is",sercr_unit_cd))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   END ;Subroutine
   SUBROUTINE get_demographic_groups(null)
    CALL echo("in get_demographic_groups")
    SELECT INTO "nl:"
     FROM person p
     WHERE p.person_id=trigger_personid
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     DETAIL
      ethnicitycd = p.ethnic_grp_cd, racecd = p.race_cd, birth_dt_tm = p.birth_dt_tm
     WITH nocounter
    ;end select
   END ;Subroutine
   SUBROUTINE getfacilitycd(trigger_encntrid)
    CALL echo("in GetFacilityCd")
    SELECT INTO "nl:"
     e.loc_facility_cd
     FROM encounter e
     WHERE e.encntr_id=trigger_encntrid
     DETAIL
      facility_cd = e.loc_facility_cd
     WITH nocounter
    ;end select
   END ;Subroutine
   SUBROUTINE getprefmgrpref(prefstr)
     SET nprefresult = 0
     IF (facility_cd=0)
      CALL getfacilitycd(trigger_encntrid)
     ENDIF
     EXECUTE rx_get_config_prefs_request
     EXECUTE rx_get_config_prefs_reply
     SET rx_gcp_request->facility_cd = facility_cd
     SET stat = alterlist(rx_gcp_request->groups,1)
     SET rx_gcp_request->groups[1].groupname = "system"
     SET stat = alterlist(rx_gcp_request->groups[1].entries,1)
     SET rx_gcp_request->groups[1].entries[1].entryname = prefstr
     SET rx_gcp_request->debugind = 1
     EXECUTE rx_get_config_prefs  WITH replace("REQUEST","RX_GCP_REQUEST"), replace("REPLY",
      "RX_GCP_REPLY")
     SET modify = nopredeclare
     FREE RECORD rx_gcp_request
     IF ((rx_gcp_reply->status_data.status="S"))
      IF (size(rx_gcp_reply->qual,5) >= 1)
       SET nprefresult = cnvtint(trim(rx_gcp_reply->qual[1].entries[1].values[1].value,3))
      ENDIF
     ENDIF
     CALL echo(build("facility=",facility_cd))
     CALL echorecord(rx_gcp_reply)
     FREE RECORD rx_gcp_reply
     CALL echo(build("KDMO Pref result for ",prefstr," = ",nprefresult))
     RETURN(nprefresult)
   END ;Subroutine
   SUBROUTINE formatprecisiondisplay(dvalue,precision)
     DECLARE sfinal = c14 WITH protect, noconstant("")
     DECLARE stempstring = c14 WITH protect, noconstant("")
     DECLARE ndecimalloc = i2 WITH protect, noconstant(0)
     DECLARE nstart = i2 WITH protect, noconstant(0)
     DECLARE nstop = i2 WITH protect, noconstant(0)
     DECLARE n_size = i2 WITH protect, constant(14)
     CALL echo("Entering Format Precision Display")
     CALL echo(build("Initial value: ",dvalue))
     SET sfinal = fillstring(value(n_size)," ")
     SET stempstring = fillstring(value(n_size)," ")
     SET stempstring = cnvtstring(dvalue,value(n_size),value(precision),r)
     FOR (idx = 1 TO value(n_size))
       IF (((substring(idx,1,stempstring)=".") OR (substring(idx,1,stempstring)=",")) )
        SET ndecimalloc = idx
        SET idx = value(n_size)
       ENDIF
     ENDFOR
     IF (ndecimalloc=0)
      SET sfinal = trim(cnvtstring(dvalue))
     ELSE
      FOR (idx = 1 TO (ndecimalloc - 2))
        IF (substring(idx,1,stempstring)="0")
         SET nstart = (idx+ 1)
        ELSE
         SET idx = (ndecimalloc - 1)
        ENDIF
      ENDFOR
      IF (nstart=0)
       SET nstart = 1
      ENDIF
      SET nstop = (ndecimalloc - nstart)
      FOR (idx = (ndecimalloc+ 1) TO value(n_size))
        IF (substring(idx,1,stempstring) != "0")
         SET nstop = ((idx - nstart)+ 1)
        ENDIF
      ENDFOR
      SET sfinal = substring(nstart,nstop,stempstring)
     ENDIF
     CALL echo(build("The final result is: ",sfinal))
     RETURN(sfinal)
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE usemanualcalc(null)
   CALL echo("In useManualCalc")
   IF (validate(cd_lookup)=0)
    RECORD cd_lookup(
      1 statuscdcnt = i4
      1 statuscds[*]
        2 cd_set = i4
        2 cd_value = f8
        2 cd_desc = vc
        2 cd_disp = vc
        2 cd_misc = vc
      1 sexcdcnt = i4
      1 sexcds[*]
        2 cd_set = i4
        2 cd_value = f8
        2 cd_desc = vc
        2 cd_disp = vc
        2 cd_misc = vc
      1 unitcdcnt = i4
      1 unitcds[*]
        2 cd_set = i4
        2 cd_value = f8
        2 cd_desc = vc
        2 cd_disp = vc
        2 cd_misc = vc
      1 eventcdcnt = i4
      1 eventcds[*]
        2 cd_set = i4
        2 cd_value = f8
        2 cd_desc = vc
        2 cd_disp = vc
        2 cd_misc = vc
    )
   ENDIF
   DECLARE hdx = i4
   DECLARE idx = i4
   DECLARE jdx = i4
   DECLARE num = i4
   DECLARE modified = vc WITH constant("CERNER!AfxL7AEMY9rGt4ALCr0MCQ")
   DECLARE altered = vc WITH constant("ALTERED")
   DECLARE auth = vc WITH constant("CERNER!AfxL7AEMY9rGt4AhCr0MCQ")
   DECLARE script_version = vc WITH constant("001 02/18/2009  CC9905")
   DECLARE weight_meas = vc WITH constant("CERNER!E9A8D345-C87A-4034-938A-BA2349967398"), protect
   DECLARE kilogram = vc WITH constant("CERNER!ABfQJgD4st77Y4sSn4waeg"), protect
   DECLARE pound = vc WITH constant("CERNER!ABfQJgD4st77Y4vYn4waeg"), protect
   DECLARE heightlen = vc WITH constant("CERNER!EE30384E-7757-41E9-8DB6-A89980F9BA4A"), protect
   DECLARE height = vc WITH constant("CERNER!AHi9DQD6D9YGkYA0n4waeg"), protect
   DECLARE centimeter = vc WITH constant("CERNER!ABfQJgD4st77Y4TYn4waeg"), protect
   DECLARE inches = vc WITH constant("CERNER!ABfQJgD4st77Y4mQn4waeg"), protect
   DECLARE creatinine = vc WITH constant("CERNER!AHi9DQD6D9YGkYBUn4waeg"), protect
   DECLARE female = vc WITH constant("CERNER!AWGwvAEOhQ/+zYCqCqIGfQ"), protect
   DECLARE male = vc WITH constant("CERNER!AWGwvAEOhQ/+zYChCqIGfQ"), protect
   DECLARE log_misc2 = f8
   DECLARE peds_len = f8
   DECLARE data_msg = vc
   DECLARE creatinine_calc = f8
   DECLARE ht_cntr = i4
   DECLARE wt_cntr = i4
   DECLARE ibw = f8
   DECLARE abw = f8
   DECLARE cbw = f8
   DECLARE gender = vc
   DECLARE age2 = f8
   DECLARE adult_year = i4 WITH noconstant(0)
   DECLARE errormsg = vc WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   DECLARE dminfo_age = i2 WITH noconstant(0)
   SELECT INTO "NL:"
    cv1.code_set, cv1.code_value, cv1.description,
    cv1.display, cv1.concept_cki
    FROM code_value cv1
    PLAN (cv1
     WHERE cv1.concept_cki IN (male, female, weight_meas, heightlen, height,
     creatinine, centimeter, inches, pound, kilogram)
      AND ((cv1.code_set+ 0) IN (54, 57, 72)))
    ORDER BY cv1.code_set
    HEAD REPORT
     cntr = 0, cntx = 0, cnty = 0
    DETAIL
     IF (cv1.code_set=57)
      cntr = (cntr+ 1)
      IF (mod(cntr,10)=1)
       now = alterlist(cd_lookup->sexcds,(cntr+ 9))
      ENDIF
      cd_lookup->sexcds[cntr].cd_set = cv1.code_set, cd_lookup->sexcds[cntr].cd_value = cv1
      .code_value, cd_lookup->sexcds[cntr].cd_desc = cv1.description,
      cd_lookup->sexcds[cntr].cd_disp = cv1.display, cd_lookup->sexcds[cntr].cd_misc = cv1
      .concept_cki
     ELSEIF (cv1.code_set=54)
      cntx = (cntx+ 1)
      IF (mod(cntx,10)=1)
       now = alterlist(cd_lookup->unitcds,(cntx+ 9))
      ENDIF
      cd_lookup->unitcds[cntx].cd_set = cv1.code_set, cd_lookup->unitcds[cntx].cd_value = cv1
      .code_value, cd_lookup->unitcds[cntx].cd_desc = cv1.description,
      cd_lookup->unitcds[cntx].cd_disp = cv1.display, cd_lookup->unitcds[cntx].cd_misc = cv1
      .concept_cki
     ELSEIF (cv1.code_set=72)
      cnty = (cnty+ 1)
      IF (mod(cnty,10)=1)
       now = alterlist(cd_lookup->eventcds,(cnty+ 9))
      ENDIF
      cd_lookup->eventcds[cnty].cd_set = cv1.code_set, cd_lookup->eventcds[cnty].cd_value = cv1
      .code_value, cd_lookup->eventcds[cnty].cd_desc = cv1.description,
      cd_lookup->eventcds[cnty].cd_disp = cv1.display, cd_lookup->eventcds[cnty].cd_misc = cv1
      .concept_cki
     ENDIF
    FOOT REPORT
     now = alterlist(cd_lookup->eventcds,cnty), now = alterlist(cd_lookup->unitcds,cntx), now =
     alterlist(cd_lookup->sexcds,cntr),
     cd_lookup->sexcdcnt = cntr, cd_lookup->unitcdcnt = cntx, cd_lookup->eventcdcnt = cnty
    WITH nocounter, separator = " ", format
   ;end select
   CALL echorecord(cd_lookup)
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="LIGHTHOUSE CONTENT"
      AND di.info_name="ADE_CALC_CREAT")
    DETAIL
     adult_year = di.info_number
    WITH nocounter
   ;end select
   IF (adult_year=0)
    SET adult_year = 18
    INSERT  FROM dm_info di
     SET di.info_domain = "LIGHTHOUSE CONTENT", di.info_name = "ADE_CALC_CREAT", di.info_number = 18
     WITH nocounter
    ;end insert
    SET errorcode = error(errormsg,0)
    IF (errorcode != 0)
     ROLLBACK
     CALL echo(concat("DM_INFO_ERR: ",errormsg))
    ELSE
     CALL echo("COMMIT ADE_CALC_CREAT DM_INFO")
     COMMIT
    ENDIF
   ELSE
    IF (adult_year <= 0)
     SET adult_year = 18
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    age = cnvtage(p.birth_dt_tm), p.sex_cd, p.end_effective_dt_tm,
    p.beg_effective_dt_tm, p.active_ind
    FROM person p
    PLAN (p
     WHERE p.person_id=trigger_personid
      AND p.birth_dt_tm != null
      AND expand(num,1,cd_lookup->sexcdcnt,p.sex_cd,cd_lookup->sexcds[num].cd_value)
      AND p.active_ind=1
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
    DETAIL
     hdx = locateval(num,1,cd_lookup->sexcdcnt,p.sex_cd,cd_lookup->sexcds[num].cd_value), gender =
     cd_lookup->sexcds[hdx].cd_misc, dminfo_age = ((adult_year * 365)+ (adult_year/ 4))
     IF (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,1) <= 371)
      age2 = 0.45
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,1) <= 4749)
      age2 = 0.55
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,1) <= dminfo_age
      AND gender=male)
      age2 = 0.70
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,1) <= dminfo_age
      AND gender=female)
      age2 = 0.55
     ELSE
      age2 = cnvtreal(cnvtalphanum(age,1))
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
   IF (curqual=0)
    SET data_msg = "no birthdate or gender found"
   ENDIF
   SELECT INTO "nl:"
    c.result_val, c_result_units_disp = uar_get_code_display(c.result_units_cd)
    FROM clinical_event c
    PLAN (c
     WHERE c.person_id=trigger_personid
      AND expand(num,1,cd_lookup->eventcdcnt,c.event_cd,cd_lookup->eventcds[num].cd_value)
      AND c.event_end_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND c.encntr_id=trigger_encntrid
      AND ((c.result_status_cd+ 0)=
     (SELECT
      ce.code_value
      FROM code_value ce
      WHERE ((ce.concept_cki IN (modified, auth)) OR (ce.cdf_meaning=auth)) ))
      AND c.result_val > " ")
    ORDER BY c.event_end_dt_tm DESC, c.clinical_event_id DESC, 0
    HEAD REPORT
     row + 0
    HEAD c.event_end_dt_tm
     row + 0
    DETAIL
     idx = locateval(num,1,cd_lookup->eventcdcnt,c.event_cd,cd_lookup->eventcds[num].cd_value), jdx
      = locateval(num,1,cd_lookup->unitcdcnt,c.result_units_cd,cd_lookup->unitcds[num].cd_value)
     IF ((cd_lookup->eventcds[idx].cd_misc IN (height, heightlen))
      AND ht_cntr=0
      AND (cd_lookup->unitcds[jdx].cd_misc=centimeter))
      ht_cntr = 1
      IF (age2 < 1)
       peds_len = cnvtreal(c.result_val)
      ELSEIF (age2 > 1)
       IF (gender=male)
        ibw = ((((cnvtreal(c.result_val) * 0.393700787) - 60) * 2.3)+ 50)
       ELSE
        ibw = ((((cnvtreal(c.result_val) * 0.393700787) - 60) * 2.3)+ 45.5)
       ENDIF
      ENDIF
     ENDIF
     IF ((cd_lookup->eventcds[idx].cd_misc IN (height, heightlen))
      AND ht_cntr=0
      AND (cd_lookup->unitcds[jdx].cd_misc=inches))
      ht_cntr = 1
      IF (age2 < 1)
       peds_len = (cnvtreal(c.result_val) * 2.54)
      ELSEIF (age2 > 1)
       IF (gender=male)
        ibw = (((cnvtreal(c.result_val) - 60) * 2.3)+ 50)
       ELSE
        ibw = (((cnvtreal(c.result_val) - 60) * 2.3)+ 45.5)
       ENDIF
      ENDIF
     ENDIF
     IF ((cd_lookup->eventcds[idx].cd_misc=weight_meas)
      AND wt_cntr=0
      AND age2 > 1)
      wt_cntr = 1
      IF ((cd_lookup->unitcds[jdx].cd_misc=pound))
       abw = (cnvtreal(c.result_val)/ 2.2)
      ELSEIF ((cd_lookup->unitcds[jdx].cd_misc=kilogram))
       abw = cnvtreal(c.result_val)
      ENDIF
     ENDIF
     IF (ibw > 0
      AND abw > 0)
      IF (ibw > abw)
       cbw = abw
      ELSE
       cbw = ibw
      ENDIF
     ELSEIF (ibw > 0)
      cbw = ibw
     ELSE
      cbw = abw
     ENDIF
     IF ((cd_lookup->eventcds[idx].cd_misc=creatinine)
      AND creatinine_calc=0)
      creatinine_calc = cnvtreal(c.result_val)
     ENDIF
    FOOT  c.event_end_dt_tm
     row + 0
    FOOT REPORT
     IF (creatinine_calc > 0)
      IF (((ht_cntr=1) OR (wt_cntr=1)) )
       IF (age2 < 1)
        log_misc2 = ((age2 * peds_len)/ creatinine_calc)
       ENDIF
       IF (cbw > 0)
        IF (gender=male)
         log_misc2 = (((140 - age2) * cbw)/ (72 * creatinine_calc))
        ELSEIF (gender=female)
         log_misc2 = ((((140 - age2) * cbw)/ (72 * creatinine_calc)) * 0.85)
        ENDIF
       ENDIF
       IF (log_misc2 > 0)
        IF (log_misc2 < 10)
         log_misc1 = cnvtstring(log_misc2,4,2,r)
        ELSEIF (log_misc2 < 100)
         log_misc1 = cnvtstring(log_misc2,5,2,r)
        ELSE
         log_misc1 = cnvtstring(log_misc2,6,2,r)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (ht_cntr=0
      AND creatinine_calc=0)
      data_msg = "height missing and no serum creatinine"
     ELSEIF (creatinine_calc=0)
      data_msg = "no serum creatinine"
     ENDIF
     IF (wt_cntr=0
      AND data_msg > " ")
      data_msg = concat(data_msg," and weight missing")
     ELSEIF (wt_cntr=0)
      data_msg = "weight missing"
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
   IF (curqual=0)
    SET data_msg = "no height, weight, or creatinine documented"
   ENDIF
   IF (log_misc1 > " ")
    SET log_message = concat("Calculation successful with a result of ",log_misc1,"."," ",
     "Script Formulas Used",
     ".")
    SET retval = 100
   ELSE
    SET retval = 0
    SET log_message = concat("Calculation failed ",data_msg,"."," ","Script Formulas Used",
     ".")
   ENDIF
   CALL echo(script_version)
   CALL echo(ibw)
   CALL echo(abw)
   CALL echo(cbw)
   CALL echo(creatinine_calc)
   CALL echo(log_misc1)
   CALL echo(age2)
   CALL echo(peds_len)
   CALL echo(log_message)
   CALL echo(link_template)
 END ;Subroutine
END GO
