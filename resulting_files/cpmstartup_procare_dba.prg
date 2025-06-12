CREATE PROGRAM cpmstartup_procare:dba
 SET trace = callecho
 EXECUTE cpmstartup
 SET trace = server
 SET trace progcachesize 350
 CALL echo("ProgCache:100 ProgCacheSize:350")
 SET c_omf_procare = "OMF_PROCARE.INC 001"
 SET trace = recpersist
 FREE SET action
 RECORD action(
   1 row[*]
     2 app_action = i2
 )
 FREE SET omf_date
 RECORD omf_date(
   1 row[*]
     2 dt_nbr = i4
     2 date = c11
     2 date_str = vc
     2 exist_ind = i2
     2 date_str = vc
     2 year = i4
     2 quarter = i2
     2 month = i2
     2 day_of_month = i2
     2 day_of_week = i2
     2 weekday_ind = i2
     2 last_day_of_month_ind = i2
     2 nbr_days_in_month = i2
     2 month_str = vc
     2 day_str = vc
     2 month_year_str = vc
 )
 SET omf_date_ndx = 0
 SET trace = norecpersist
 SET cdf_meaning = fillstring(12," ")
 SET active_ind = 1
 SET encntr_id = 0.0
 IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
  CALL echo("omf_functions.inc: declaring omfsql_def")
  DECLARE omfsql_def = i2 WITH persist
  SET omfsql_def = 1
  IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
   SET trace = recpersist
   DECLARE v_omfcnt = i4 WITH protect
   SET v_omfcnt = 0
   FREE SET omf_function
   RECORD omf_function(
     1 v_func[*]
       2 v_func_name = c40
       2 v_dtype = c10
   )
   SELECT INTO "nl:"
    function_name = function_name, dtype = return_dtype
    FROM omf_function
    WHERE function_name != "uar*"
     AND function_name != "cclsql*"
    ORDER BY function_name
    DETAIL
     v_omfcnt += 1
     IF (mod(v_omfcnt,100)=1)
      stat = alterlist(omf_function->v_func,(v_omfcnt+ 99))
     ENDIF
     omf_function->v_func[v_omfcnt].v_func_name = trim(function_name)
     IF (trim(dtype)="q8")
      omf_function->v_func[v_omfcnt].v_dtype = "dq8"
     ELSE
      omf_function->v_func[v_omfcnt].v_dtype = trim(dtype)
     ENDIF
    FOOT REPORT
     stat = alterlist(omf_function->v_func,v_omfcnt)
    WITH nocounter
   ;end select
   SET trace = norecpersist
  ENDIF
  DECLARE _omfcnt = i4 WITH protect
  IF (size(omf_function->v_func,5) > 0)
   FOR (_omfcnt = 1 TO size(omf_function->v_func,5))
     IF ((omf_function->v_func[_omfcnt].v_func_name > " "))
      SET v_declare = fillstring(100," ")
      SET v_declare = concat("declare ",trim(omf_function->v_func[_omfcnt].v_func_name),"() = ",trim(
        omf_function->v_func[_omfcnt].v_dtype)," WITH PERSIST GO")
      CALL parser(trim(v_declare))
     ENDIF
   ENDFOR
  ENDIF
  CALL echo("omf_functions: defined")
 ELSE
  CALL echo("omf_functions: already defined")
 ENDIF
 DECLARE acvlist[100] = f8 WITH private
 DECLARE iindex = i2 WITH noconstant(1)
 DECLARE iremaining = i4 WITH private, noconstant(1)
 DECLARE istartindex = i4 WITH private, noconstant(1)
 DECLARE ioccurances = i4 WITH private, constant(100)
 DECLARE icnt = i4 WITH private, noconstant(0)
 DECLARE smeaning = c12 WITH private, noconstant(fillstring(12," "))
 SET c_omf_prologue_cv = "OMF_PROLOGUE_CV.INC 028"
 IF ((- (1)=validate(c_omf_prologue_mod,- (1))))
  DECLARE c_omf_prologue_mod = i4 WITH constant(28)
 ENDIF
 IF ( NOT ("Y"=validate(omf_prologue_cv,"Y")
  AND "Z"=validate(omf_prologue_cv,"Z")))
  IF ((omf_prologue_cv->test < c_omf_prologue_mod))
   FREE RECORD omf_prologue_cv
  ENDIF
 ENDIF
 IF ((- (1)=validate(omf_prologue_cv->test,- (1))))
  CALL echo("DECLARE OMF_PROLOGUE_CV")
  SET trace = recpersist
  FREE RECORD omf_prologue_cv
  RECORD omf_prologue_cv(
    1 test = i2
    1 19_data[*]
      2 19_deceased = f8
    1 48_inactive = f8
    1 52_paniclow = f8
    1 52_abnormal = f8
    1 52_critical = f8
    1 52_panichigh = f8
    1 52_vabnormal = f8
    1 52_extremelow = f8
    1 52_extremehigh = f8
    1 53_date = f8
    1 53_numeric = f8
    1 53_text = f8
    1 69_inpatient = f8
    1 69_observation = f8
    1 69_emergency = f8
    1 69_hospice = f8
    1 69_privateduty = f8
    1 69_skilled = f8
    1 69_waitlist = f8
    1 106_gl = f8
    1 212_home = f8
    1 331_pcp = f8
    1 333_admitdoc = f8
    1 333_attenddoc = f8
    1 333_consultdoc = f8
    1 333_referdoc = f8
    1 338_insurance_co = f8
    1 338_employer = f8
    1 382_ft_brief = f8
    1 388_surgeon = f8
    1 388_anes = f8
    1 400_cpt4 = f8
    1 400_icd9 = f8
    1 400_icd10 = f8
    1 400_aprdrg = f8
    1 400_hcfa = f8
    1 400_apc = f8
    1 401_drg_prin = f8
    1 401_cmg_prin = f8
    1 401_dpg_prin = f8
    1 401_diag = f8
    1 401_finding = f8
    1 401_anatstruct = f8
    1 401_other = f8
    1 401_procedure = f8
    1 6003_cancel = f8
    1 6003_complete = f8
    1 6003_discontinue = f8
    1 6003_order = f8
    1 13003_cap_event = f8
    1 13003_cap_phys = f8
    1 13003_cap_diag = f8
    1 13003_cap_drg = f8
    1 13003_cap_drg2 = f8
    1 13003_cap_age = f8
    1 13003_cap_age_days = f8
    1 13003_cap_medserv = f8
    1 13003_cap_medspec = f8
    1 13003_cap_fac = f8
    1 13003_cap_nu = f8
    1 13003_cap_nu2 = f8
    1 13003_cap_proc = f8
    1 13003_cap_ins_co = f8
    1 13003_cap_hlthpl = f8
    1 13003_cap_zipcode = f8
    1 13003_cap_shift = f8
    1 13003_rev_cat = f8
    1 13003_rev_cat_grp = f8
    1 13003_cost_center = f8
    1 13003_cap_role = f8
    1 13016_task_assay = f8
    1 13016_billed_in = f8
    1 13016_ord_cat = f8
    1 13019_bill_code = f8
    1 14002_cdm_sched = f8
    1 14002_cpt4 = f8
    1 14002_icd9 = f8
    1 14002_revenue = f8
    1 14135_pm_adt = f8
    1 14135_profile_abs = f8
    1 14135_profile_save = f8
    1 14135_charge_svc = f8
    1 14135_order_svc = f8
    1 14135_clin_event = f8
    1 14135_esi_trans = f8
    1 14135_downtime = f8
    1 14170_raw = f8
    1 14194_none = f8
    1 14194_sum = f8
    1 14268_bool = f8
    1 14268_c = f8
    1 14268_dq8 = f8
    1 14268_f8 = f8
    1 14268_i2 = f8
    1 14268_i4 = f8
    1 14268_provider = f8
    1 14268_vc = f8
    1 apc_ind = i2
    1 service_cat_ind = i2
    1 oe_cancel_reason = f8
    1 oe_discontinue_reason = f8
    1 oe_icd9 = f8
    1 oe_reason_for_exam = f8
    1 14002_data[*]
      2 14002_cpt4 = f8
  )
  SET trace = norecpersist
 ENDIF
 IF ((c_omf_prologue_mod > omf_prologue_cv->test))
  SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,omf_prologue_cv->48_inactive)
  SET stat = uar_get_meaning_by_codeset(52,"PANICLOW",1,omf_prologue_cv->52_paniclow)
  SET stat = uar_get_meaning_by_codeset(52,"ABNORMAL",1,omf_prologue_cv->52_abnormal)
  SET stat = uar_get_meaning_by_codeset(52,"CRITICAL",1,omf_prologue_cv->52_critical)
  SET stat = uar_get_meaning_by_codeset(52,"PANICHIGH",1,omf_prologue_cv->52_panichigh)
  SET stat = uar_get_meaning_by_codeset(52,"VABNORMAL",1,omf_prologue_cv->52_vabnormal)
  SET stat = uar_get_meaning_by_codeset(52,"EXTREMELOW",1,omf_prologue_cv->52_extremelow)
  SET stat = uar_get_meaning_by_codeset(52,"EXTREMEHIGH",1,omf_prologue_cv->52_extremehigh)
  SET stat = uar_get_meaning_by_codeset(53,"DATE",1,omf_prologue_cv->53_date)
  SET stat = uar_get_meaning_by_codeset(53,"NUM",1,omf_prologue_cv->53_numeric)
  SET stat = uar_get_meaning_by_codeset(53,"TXT",1,omf_prologue_cv->53_text)
  SET stat = uar_get_meaning_by_codeset(69,"INPATIENT",1,omf_prologue_cv->69_inpatient)
  SET stat = uar_get_meaning_by_codeset(69,"OBSERVATION",1,omf_prologue_cv->69_observation)
  SET stat = uar_get_meaning_by_codeset(69,"HOSPICE",1,omf_prologue_cv->69_hospice)
  SET stat = uar_get_meaning_by_codeset(69,"PRIVATEDUTY",1,omf_prologue_cv->69_privateduty)
  SET stat = uar_get_meaning_by_codeset(69,"SKILLED",1,omf_prologue_cv->69_skilled)
  SET stat = uar_get_meaning_by_codeset(69,"WAITLIST",1,omf_prologue_cv->69_waitlist)
  SET stat = uar_get_meaning_by_codeset(69,"EMERGENCY",1,omf_prologue_cv->69_emergency)
  SET stat = uar_get_meaning_by_codeset(106,"GLB",1,omf_prologue_cv->106_gl)
  SET stat = uar_get_meaning_by_codeset(212,"HOME",1,omf_prologue_cv->212_home)
  SET stat = uar_get_meaning_by_codeset(331,"PCP",1,omf_prologue_cv->331_pcp)
  SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,omf_prologue_cv->333_admitdoc)
  SET stat = uar_get_meaning_by_codeset(333,"ATTENDDOC",1,omf_prologue_cv->333_attenddoc)
  SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,omf_prologue_cv->333_consultdoc)
  SET stat = uar_get_meaning_by_codeset(333,"REFERDOC",1,omf_prologue_cv->333_referdoc)
  SET stat = uar_get_meaning_by_codeset(338,"INSURANCE CO",1,omf_prologue_cv->338_insurance_co)
  SET stat = uar_get_meaning_by_codeset(338,"EMPLOYER",1,omf_prologue_cv->338_employer)
  SET stat = uar_get_meaning_by_codeset(382,"FTBRIEF",1,omf_prologue_cv->382_ft_brief)
  SET stat = uar_get_meaning_by_codeset(388,"SURGEON",1,omf_prologue_cv->388_surgeon)
  SET stat = uar_get_meaning_by_codeset(388,"ANES",1,omf_prologue_cv->388_anes)
  SET stat = uar_get_meaning_by_codeset(400,"CPT4",1,omf_prologue_cv->400_cpt4)
  SET stat = uar_get_meaning_by_codeset(400,"ICD9",1,omf_prologue_cv->400_icd9)
  SET stat = uar_get_meaning_by_codeset(400,"ICD10",1,omf_prologue_cv->400_icd10)
  SET stat = uar_get_meaning_by_codeset(400,"APRDRG",1,omf_prologue_cv->400_aprdrg)
  SET stat = uar_get_meaning_by_codeset(400,"HCFA",1,omf_prologue_cv->400_hcfa)
  SET stat = uar_get_meaning_by_codeset(400,"APC",1,omf_prologue_cv->400_apc)
  SET stat = uar_get_meaning_by_codeset(401,"DIAG",1,omf_prologue_cv->401_diag)
  SET stat = uar_get_meaning_by_codeset(401,"FINDING",1,omf_prologue_cv->401_finding)
  SET stat = uar_get_meaning_by_codeset(401,"OTHER",1,omf_prologue_cv->401_other)
  SET stat = uar_get_meaning_by_codeset(401,"ANATSTRUCT",1,omf_prologue_cv->401_anatstruct)
  SET stat = uar_get_meaning_by_codeset(401,"PROCEDURE",1,omf_prologue_cv->401_procedure)
  SET stat = uar_get_meaning_by_codeset(401,"DRG",1,omf_prologue_cv->401_drg_prin)
  SET stat = uar_get_meaning_by_codeset(401,"CMG",1,omf_prologue_cv->401_cmg_prin)
  SET stat = uar_get_meaning_by_codeset(401,"DPG",1,omf_prologue_cv->401_dpg_prin)
  SET stat = uar_get_meaning_by_codeset(6003,"CANCEL",1,omf_prologue_cv->6003_cancel)
  SET stat = uar_get_meaning_by_codeset(6003,"COMPLETE",1,omf_prologue_cv->6003_complete)
  SET stat = uar_get_meaning_by_codeset(6003,"DISCONTINUE",1,omf_prologue_cv->6003_discontinue)
  SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,omf_prologue_cv->6003_order)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP EVENT",1,omf_prologue_cv->13003_cap_event)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP PHYS",1,omf_prologue_cv->13003_cap_phys)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP MEDSERV",1,omf_prologue_cv->13003_cap_medserv)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP MEDSPEC",1,omf_prologue_cv->13003_cap_medspec)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP AGE",1,omf_prologue_cv->13003_cap_age)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP AGE DAYS",1,omf_prologue_cv->13003_cap_age_days)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP FAC",1,omf_prologue_cv->13003_cap_fac)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP NU",1,omf_prologue_cv->13003_cap_nu)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP NU2",1,omf_prologue_cv->13003_cap_nu2)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP INS CO",1,omf_prologue_cv->13003_cap_ins_co)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP HLTHPL",1,omf_prologue_cv->13003_cap_hlthpl)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP ZIPCODE",1,omf_prologue_cv->13003_cap_zipcode)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP SHIFT",1,omf_prologue_cv->13003_cap_shift)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP DIAG",1,omf_prologue_cv->13003_cap_diag)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP DRG",1,omf_prologue_cv->13003_cap_drg)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP DRG2",1,omf_prologue_cv->13003_cap_drg2)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP PROC",1,omf_prologue_cv->13003_cap_proc)
  SET stat = uar_get_meaning_by_codeset(13003,"REV CAT",1,omf_prologue_cv->13003_rev_cat)
  SET stat = uar_get_meaning_by_codeset(13003,"REV CAT GRP",1,omf_prologue_cv->13003_rev_cat_grp)
  SET stat = uar_get_meaning_by_codeset(13003,"COST CENTER",1,omf_prologue_cv->13003_cost_center)
  SET stat = uar_get_meaning_by_codeset(13003,"REV CAT",1,omf_prologue_cv->13003_rev_cat)
  SET stat = uar_get_meaning_by_codeset(13003,"CAP ROLE",1,omf_prologue_cv->13003_cap_role)
  SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,omf_prologue_cv->13016_ord_cat)
  SET stat = uar_get_meaning_by_codeset(13016,"TASK ASSAY",1,omf_prologue_cv->13016_task_assay)
  SET stat = uar_get_meaning_by_codeset(13016,"BILLED_IN",1,omf_prologue_cv->13016_billed_in)
  SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,omf_prologue_cv->13019_bill_code)
  SET stat = uar_get_meaning_by_codeset(14002,"CDM_SCHED",1,omf_prologue_cv->14002_cdm_sched)
  SET stat = uar_get_meaning_by_codeset(14002,"REVENUE",1,omf_prologue_cv->14002_revenue)
  SET stat = uar_get_meaning_by_codeset(14002,"CPT4",1,omf_prologue_cv->14002_cpt4)
  SET stat = uar_get_meaning_by_codeset(14002,"ICD9",1,omf_prologue_cv->14002_icd9)
  SET stat = uar_get_meaning_by_codeset(14135,"PM ADT",1,omf_prologue_cv->14135_pm_adt)
  SET stat = uar_get_meaning_by_codeset(14135,"ESI TRANS",1,omf_prologue_cv->14135_esi_trans)
  SET stat = uar_get_meaning_by_codeset(14135,"PROFILE ABS",1,omf_prologue_cv->14135_profile_abs)
  SET stat = uar_get_meaning_by_codeset(14135,"PROFILE SAVE",1,omf_prologue_cv->14135_profile_save)
  SET stat = uar_get_meaning_by_codeset(14135,"CHARGE SVC",1,omf_prologue_cv->14135_charge_svc)
  SET stat = uar_get_meaning_by_codeset(14135,"ORDER SVC",1,omf_prologue_cv->14135_order_svc)
  SET stat = uar_get_meaning_by_codeset(14135,"CLIN EVENT",1,omf_prologue_cv->14135_clin_event)
  SET stat = uar_get_meaning_by_codeset(14135,"DOWNTIME",1,omf_prologue_cv->14135_downtime)
  SET stat = uar_get_meaning_by_codeset(14170,"RAW",1,omf_prologue_cv->14170_raw)
  SET stat = uar_get_meaning_by_codeset(14194,"NONE",1,omf_prologue_cv->14194_none)
  SET stat = uar_get_meaning_by_codeset(14194,"SUM",1,omf_prologue_cv->14194_sum)
  SET stat = uar_get_meaning_by_codeset(14268,"BOOL",1,omf_prologue_cv->14268_bool)
  SET stat = uar_get_meaning_by_codeset(14268,"C",1,omf_prologue_cv->14268_c)
  SET stat = uar_get_meaning_by_codeset(14268,"DQ8",1,omf_prologue_cv->14268_dq8)
  SET stat = uar_get_meaning_by_codeset(14268,"I2",1,omf_prologue_cv->14268_i2)
  SET stat = uar_get_meaning_by_codeset(14268,"I4",1,omf_prologue_cv->14268_i4)
  SET stat = uar_get_meaning_by_codeset(14268,"PROVIDER",1,omf_prologue_cv->14268_provider)
  SET stat = uar_get_meaning_by_codeset(14268,"VC",1,omf_prologue_cv->14268_vc)
  DECLARE opc_code_list[20] = f8 WITH private
  DECLARE opc_total_remaining = i4 WITH private, noconstant(0)
  DECLARE opc_start_index = i4 WITH private, noconstant(1)
  DECLARE opc_occurances = i4 WITH private, noconstant(20)
  DECLARE opc_dispkey_val = c40 WITH private, constant("CODESET")
  DECLARE opc_aaa = i4 WITH private, noconstant(1)
  CALL uar_get_code_list_by_dispkey(14268,nullterm(opc_dispkey_val),opc_start_index,opc_occurances,
   opc_total_remaining,
   opc_code_list)
  IF (opc_occurances > 0)
   FOR (opc_aaa = 1 TO opc_occurances)
     IF (uar_get_code_meaning(opc_code_list[opc_aaa])="F8")
      SET omf_prologue_cv->14268_f8 = opc_code_list[opc_aaa]
      SET opc_aaa = opc_occurances
     ENDIF
   ENDFOR
  ENDIF
  FREE SET opc_code_list
  FREE SET opc_total_remaining
  FREE SET opc_start_index
  FREE SET opc_occurances
  FREE SET opc_dispkey_val
  FREE SET opc_aaa
  DECLARE itableexists = i4 WITH protect, noconstant(0)
  SET itableexists = checkdic("APC_EXTENSION","T",0)
  IF (itableexists > 0)
   SET omf_prologue_cv->apc_ind = 1
  ENDIF
  SELECT INTO "nl"
   cp.service_cat_ind
   FROM coding_params cp
   WHERE cp.encoder_type_cd > 0
   DETAIL
    omf_prologue_cv->service_cat_ind = cp.service_cat_ind
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   oefm.oe_field_meaning_id
   FROM oe_field_meaning oefm
   WHERE oefm.oe_field_meaning IN ("CANCELREASON", "DCREASON", "ICD9", "REASONFOREXAM")
   DETAIL
    CASE (oefm.oe_field_meaning)
     OF "CANCELREASON":
      omf_prologue_cv->oe_cancel_reason = oefm.oe_field_meaning_id
     OF "DCREASON":
      omf_prologue_cv->oe_discontinue_reason = oefm.oe_field_meaning_id
     OF "ICD9":
      omf_prologue_cv->oe_icd9 = oefm.oe_field_meaning_id
     OF "REASONFOREXAM":
      omf_prologue_cv->oe_reason_for_exam = oefm.oe_field_meaning_id
    ENDCASE
   WITH nocounter
  ;end select
  DECLARE opc_deceased_list[20] = f8 WITH private
  DECLARE opc_total_remaining = i4 WITH private, noconstant(0)
  DECLARE opc_start_index = i4 WITH private, noconstant(1)
  DECLARE opc_occurances = i4 WITH private, noconstant(20)
  DECLARE opc_meaning_val = c12 WITH private, constant("DECEASED")
  DECLARE opc_aaa = i4 WITH private, noconstant(1)
  DECLARE opc_deceased_ndx = i4 WITH private, noconstant(0)
  DECLARE opc_loop = i4 WITH private, noconstant(1)
  WHILE (opc_occurances=20
   AND opc_loop < 5)
    CALL uar_get_code_list_by_meaning(19,nullterm(opc_meaning_val),opc_start_index,opc_occurances,
     opc_total_remaining,
     opc_deceased_list)
    IF (opc_occurances > 0)
     SET stat = alterlist(omf_prologue_cv->19_data,(opc_deceased_ndx+ opc_occurances))
     FOR (opc_aaa = 1 TO opc_occurances)
       SET omf_prologue_cv->19_data[(opc_deceased_ndx+ opc_aaa)].19_deceased = opc_deceased_list[
       opc_aaa]
     ENDFOR
     SET opc_deceased_ndx += opc_occurances
    ENDIF
    SET opc_loop += 1
  ENDWHILE
  FREE SET opc_deceased_list
  FREE SET opc_total_remaining
  FREE SET opc_start_index
  FREE SET opc_occurances
  FREE SET opc_meaning_val
  FREE SET opc_aaa
  FREE SET opc_deceased_ndx
  FREE SET opc_loop
  FOR (icnt = 1 TO size(acvlist,5))
    SET acvlist[icnt] = 0.0
  ENDFOR
  SET smeaning = "CPT4"
  SET istartindex = 1
  SET iremaining = 1
  SET icnt = 1
  WHILE (ioccurances=100
   AND iremaining > 0)
    CALL uar_get_code_list_by_meaning(14002,nullterm(smeaning),istartindex,ioccurances,iremaining,
     acvlist)
    SET stat = alterlist(omf_prologue_cv->14002_data,(icnt+ ioccurances))
    FOR (x = 1 TO ioccurances)
     SET icnt += 1
     SET omf_prologue_cv->14002_data[icnt].14002_cpt4 = acvlist[x]
    ENDFOR
    SET istartindex += ioccurances
  ENDWHILE
  SET omf_prologue_cv->test = c_omf_prologue_mod
 ENDIF
 SET c_omf_extract_type = "OMF_EXTRACT_TYPE.INC 005"
 CALL echo("DECLARE OMF_EXTRACT_TYPE")
 SET trace = recpersist
 FREE SET omf_extract_type
 RECORD omf_extract_type(
   1 test = i2
   1 114001_ind = i2
   1 114600_ind = i2
   1 orders_ind = i2
   1 950100_ind = i2
   1 native_charges_ind = i2
   1 profile_save_ind = i2
   1 profile_abs_ind = i2
   1 3091000_ind = i2
   1 950174_ind = i2
   1 downtime_ind = i2
 )
 SET trace = norecpersist
 SELECT INTO "NL"
  oet.extract_type_cd, oet.active_ind
  FROM omf_extract_type oet
  DETAIL
   CASE (oet.extract_type_cd)
    OF omf_prologue_cv->14135_esi_trans:
     omf_extract_type->950100_ind = oet.active_ind
    OF omf_prologue_cv->14135_pm_adt:
     omf_extract_type->114001_ind = oet.active_ind,omf_extract_type->114600_ind = oet.active_ind,
     omf_extract_type->950174_ind = oet.active_ind
    OF omf_prologue_cv->14135_profile_abs:
     omf_extract_type->profile_abs_ind = oet.active_ind
    OF omf_prologue_cv->14135_profile_save:
     omf_extract_type->profile_save_ind = oet.active_ind
    OF omf_prologue_cv->14135_charge_svc:
     omf_extract_type->native_charges_ind = oet.active_ind
    OF omf_prologue_cv->14135_order_svc:
     omf_extract_type->orders_ind = oet.active_ind
    OF omf_prologue_cv->14135_clin_event:
     omf_extract_type->3091000_ind = oet.active_ind
    OF omf_prologue_cv->14135_downtime:
     omf_extract_type->downtime_ind = oet.active_ind
   ENDCASE
  WITH nocounter
 ;end select
 SET c_omf_encntr_st = "OMF_ENCNTR_ST.INC 017"
 IF ((- (1)=validate(omf_encntr_st->test,- (1))))
  CALL echo("DECLARE OMF_ENCNTR_ST")
  SET trace = recpersist
  FREE SET omf_encntr_st
  RECORD omf_encntr_st(
    1 test = i2
    1 max_svc_cat_cnt = i4
    1 max_inst_cnt = i4
    1 max_encntr_reltn_cnt = i4
    1 data[*]
      2 status = i4
      2 errnum = i4
      2 errmsg = vc
      2 encntr_id = f8
      2 prev_inp_encntr_id = f8
      2 prev_encntr_id = f8
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
      2 person_id = f8
      2 last_transaction = c4
      2 visit_ind = i2
      2 admit_ind = i2
      2 admit_cancel_ind = i2
      2 visit_dt_tm = c25
      2 visit_tz = i4
      2 visit_dt_nbr = i4
      2 visit_min_nbr = i4
      2 admit_dt_tm = c25
      2 admit_tz = i4
      2 admit_dt_nbr = i4
      2 admit_min_nbr = i4
      2 icd9_admit_diag_nomen_id = f8
      2 icd9_prin_proc_dt_tm = c25
      2 icd9_prin_proc_tz = i4
      2 death_ind = i2
      2 death_dt_tm = c25
      2 death_tz = i4
      2 death_dt_nbr = i4
      2 death_min_nbr = i4
      2 last_ip_disch_dt_tm = c25
      2 last_ip_disch_dt_nbr = i4
      2 last_ip_disch_tz = i4
      2 last_ip_disch_min_nbr = i4
      2 disch_ind = i2
      2 disch_cancel_ind = i2
      2 disch_dt_tm = c25
      2 disch_dt_nbr = i4
      2 disch_min_nbr = i4
      2 exp_pm_disch_dt_tm = c25
      2 exp_pm_disch_tz = i4
      2 exp_pm_disch_dt_nbr = i4
      2 exp_pm_disch_min_nbr = i4
      2 disch_disposition_cd = f8
      2 disch_to_loc_cd = f8
      2 admit_src_cd = f8
      2 admit_type_cd = f8
      2 admit_phys_id = f8
      2 admit_phys_key = c255
      2 admit_phys_ft_name = c255
      2 admit_phys_grp_cd = f8
      2 admit_phys_med_spec_cd = f8
      2 admit_phys_position_cd = f8
      2 ambulatory_cond_cd = f8
      2 att_phys_id = f8
      2 att_phys_key = c255
      2 att_phys_ft_name = c255
      2 att_phys_grp_cd = f8
      2 att_phys_med_spec_cd = f8
      2 attend_phys_position_cd = f8
      2 ethnic_grp_cd = f8
      2 sex_cd = f8
      2 fin_class_cd = f8
      2 race_cd = f8
      2 language_cd = f8
      2 religion_cd = f8
      2 vip_cd = f8
      2 encntr_type_cd = f8
      2 encntr_type_class_cd = f8
      2 birth_dt_tm = c25
      2 birth_dt_nbr = i4
      2 birth_min_nbr = i4
      2 birth_tz = i4
      2 birth_date = c25
      2 marital_status_cd = f8
      2 ref_phys_id = f8
      2 ref_phys_key = c255
      2 ref_phys_ft_name = c255
      2 ref_phys_med_spec_cd = f8
      2 ref_phys_position_cd = f8
      2 med_serv_cd = f8
      2 med_serv_grp_cd = f8
      2 accommodation_cd = f8
      2 transfer_reason_cd = f8
      2 prev_pat_loc_nu_cd = f8
      2 curr_pat_loc_arrive_dt_tm = c25
      2 curr_pat_loc_arrive_dt_nbr = i4
      2 curr_pat_loc_arrive_min_nbr = i4
      2 curr_pat_loc_arrive_tz = i4
      2 curr_pat_loc_bed_cd = f8
      2 curr_pat_loc_bdg_cd = f8
      2 curr_pat_loc_fac_cd = f8
      2 curr_pat_loc_fac_grp_cd = f8
      2 curr_pat_loc_nu_cd = f8
      2 curr_pat_loc_nu_grp_cd = f8
      2 curr_pat_loc_nu_grp2_cd = f8
      2 curr_pat_loc_room_cd = f8
      2 admit_pat_loc_bed_cd = f8
      2 admit_pat_loc_bdg_cd = f8
      2 admit_pat_loc_fac_cd = f8
      2 admit_pat_loc_nu_cd = f8
      2 admit_pat_loc_room_cd = f8
      2 admit_72h_ladmit_ind = i2
      2 age_days = f8
      2 age_years = f8
      2 age_days_grp_cd = f8
      2 age_years_grp_cd = f8
      2 admit_7d_ladmit_ind = i2
      2 admit_15d_ladmit_ind = i2
      2 admit_24h_ladmit_ind = i2
      2 admit_30d_ladmit_ind = i2
      2 admit_48h_ladmit_ind = i2
      2 admit_48d_ladmit_ind = i2
      2 readmit_24h_48h_ind = i2
      2 readmit_gt_48h_ind = i2
      2 readmit_7d_15d_ind = i2
      2 readmit_15d_30d_ind = i2
      2 readmit_30d_48d_ind = i2
      2 readmit_gt_48d_ind = i2
      2 readmit_48h_72h_ind = i2
      2 readmit_gt_72h_ind = i2
      2 return_ed_24h_ind = i2
      2 return_ed_48h_ind = i2
      2 return_ed_72h_ind = i2
      2 return_ed_24h_48h_ind = i2
      2 return_ed_49h_72h_ind = i2
      2 return_ed_gt_72h_ind = i2
      2 days_next_ed_visit = i2
      2 death_24h_admit_ind = i2
      2 death_24h_visit_ind = i2
      2 death_24h_prin_proc_ind = i2
      2 coordination_of_benefits_cd = f8
      2 prim_ins_assign_benefits_cd = f8
      2 prim_ins_organization_id = f8
      2 prim_emp_organization_id = f8
      2 prim_ins_person_id = f8
      2 prim_health_plan_id = f8
      2 prim_ins_birth_dt_tm = c25
      2 prim_ins_birth_dt_nbr = i4
      2 prim_ins_birth_min_nbr = i4
      2 prim_ins_birth_tz = i4
      2 prim_ins_person_reltn_cd = f8
      2 prim_ins_beg_effective_dt_tm = c25
      2 prim_ins_beg_effective_tz = i4
      2 prim_ins_beg_effective_dt_nbr = i4
      2 prim_ins_beg_effective_min_nbr = i4
      2 prim_ins_end_effective_dt_tm = c25
      2 prim_ins_end_effective_tz = i4
      2 prim_ins_end_effective_dt_nbr = i4
      2 prim_ins_end_effective_min_nbr = i4
      2 prim_ins_plan_type_cd = f8
      2 prim_health_plan_group_cd = f8
      2 prim_ins_group_cd = f8
      2 prim_org_plan_reltn_id = f8
      2 sec_health_plan_group_cd = f8
      2 sec_ins_group_cd = f8
      2 sec_ins_assign_benefits_cd = f8
      2 sec_ins_organization_id = f8
      2 sec_emp_organization_id = f8
      2 sec_ins_person_id = f8
      2 sec_health_plan_id = f8
      2 sec_ins_birth_dt_tm = c25
      2 sec_ins_birth_dt_nbr = i4
      2 sec_ins_birth_min_nbr = i4
      2 sec_ins_birth_tz = i4
      2 sec_ins_person_reltn_cd = f8
      2 sec_ins_beg_effective_dt_tm = c25
      2 sec_ins_beg_effective_tz = i4
      2 sec_ins_beg_effective_dt_nbr = i4
      2 sec_ins_beg_effective_min_nbr = i4
      2 sec_ins_end_effective_dt_tm = c25
      2 sec_ins_end_effective_tz = i4
      2 sec_ins_end_effective_dt_nbr = i4
      2 sec_ins_end_effective_min_nbr = i4
      2 sec_ins_plan_type_cd = f8
      2 sec_org_plan_reltn_id = f8
      2 other_health_plan_group_cd = f8
      2 other_ins_group_cd = f8
      2 other_ins_assign_benefits_cd = f8
      2 other_ins_organization_id = f8
      2 other_emp_organization_id = f8
      2 other_ins_person_id = f8
      2 other_health_plan_id = f8
      2 other_ins_birth_dt_tm = c25
      2 other_ins_birth_dt_nbr = i4
      2 other_ins_birth_min_nbr = i4
      2 other_ins_birth_tz = i4
      2 other_ins_person_reltn_cd = f8
      2 other_ins_beg_effective_dt_tm = c25
      2 other_ins_beg_effective_tz = i4
      2 other_ins_beg_effective_dt_nbr = i4
      2 other_ins_beg_effective_min_nbr = i4
      2 other_ins_end_effective_dt_tm = c25
      2 other_ins_end_effective_tz = i4
      2 other_ins_end_effective_dt_nbr = i4
      2 other_ins_end_effective_min_nbr = i4
      2 other_ins_plan_type_cd = f8
      2 other_org_plan_reltn_id = f8
      2 reason_for_visit = c255
      2 patient_status_cd = f8
      2 triage_cd = f8
      2 encntr_class_cd = f8
      2 person_home_zipcode_grp_cd = f8
      2 pcp_phys_id = f8
      2 pcp_phys_key = c255
      2 pcp_phys_ft_name = c255
      2 pcp_phys_grp_cd = f8
      2 pcp_phys_med_spec_cd = f8
      2 pcp_phys_position_cd = f8
      2 disch_shift_grp_cd = f8
      2 admit_shift_grp_cd = f8
      2 organization_id = f8
      2 emp_organization_id = f8
      2 service_category_cd = f8
      2 hist_list[3]
        3 hist_type = vc
        3 inst_cnt = i4
        3 dirty_ind = i2
        3 instance[*]
          4 beg_transaction_dt_tm = c25
          4 beg_transaction_dt_nbr = i4
          4 beg_transaction_min_nbr = i4
          4 encntr_id = f8
          4 encntr_loc_hist_id = f8
          4 end_transaction_dt_tm = c25
          4 end_transaction_dt_nbr = i4
          4 end_transaction_min_nbr = i4
          4 num_val1 = f8
          4 num_val2 = f8
          4 num_val3 = f8
          4 num_val4 = f8
          4 num_val5 = f8
          4 num_val6 = f8
          4 num_val7 = f8
          4 loc_nurse_unit_grp_cd = f8
          4 loc_nurse_unit_grp2_cd = f8
      2 aprdrg_nomen_id = f8
      2 aprdrg_severity = i2
      2 aprdrg_los = f8
      2 total_accum_charges = f8
      2 total_accum_chargesf = f8
      2 total_std_cost = f8
      2 total_std_direct_fix_cost = f8
      2 total_std_direct_var_cost = f8
      2 total_std_indirect_fix_cost = f8
      2 total_std_indirect_var_cost = f8
      2 total_act_cost = f8
      2 total_act_direct_fix_cost = f8
      2 total_act_direct_var_cost = f8
      2 total_act_indirect_fix_cost = f8
      2 total_act_indirect_var_cost = f8
      2 cost_ratio_ind = i2
      2 nbr_consults = i4
      2 encntr_reltn_cnt = i4
      2 encntr_reltn[*]
        3 encntr_prsnl_reltn_id = f8
        3 prsnl_person_id = f8
        3 encntr_prsnl_r_cd = f8
        3 prsnl_person_key = vc
        3 prsnl_person_ft_name = vc
        3 prsnl_person_position_cd = f8
        3 priority_seq = i4
        3 prsnl_person_grp_cd = f8
        3 prsnl_person_med_spec_cd = f8
        3 beg_effective_dt_tm = vc
        3 beg_effective_dt_nbr = i4
        3 beg_effective_min_nbr = i4
        3 end_effective_dt_tm = vc
        3 end_effective_dt_nbr = i4
        3 end_effective_min_nbr = i4
        3 status = i4
        3 errnum = i4
        3 errmsg = vc
      2 isolation_cd = f8
      2 svc_cat_cnt = i4
      2 svc_cat[*]
        3 status = i4
        3 errnum = i4
        3 errmsg = vc
        3 svc_cat_hist_id = f8
        3 med_service_cd = f8
        3 service_category_cd = f8
        3 prev_service_category_cd = f8
        3 att_prsnl_id = f8
        3 att_prsnl_grp_cd = f8
        3 att_prsnl_med_spec_cd = f8
        3 attend_phys_position_cd = f8
        3 beg_transaction_dt_nbr = i4
        3 beg_transaction_min_nbr = i4
        3 beg_transaction_dt_tm = vc
        3 end_transaction_dt_nbr = i4
        3 end_transaction_min_nbr = i4
        3 end_transaction_dt_tm = vc
        3 updt_cnt = i4
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_inpatient_list = "OMF_INPATIENT_LIST.INC 001"
 IF ((- (1)=validate(omf_inpatient_list->test,- (1))))
  CALL echo("DECLARE OMF_INPATIENT_LIST")
  SET trace = recpersist
  FREE SET omf_inpatient_list
  RECORD omf_inpatient_list(
    1 test = i2
    1 v_inpatient[*]
      2 v_inpatient_cd = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_etc_list = "OMF_ETC_LIST.INC D002"
 IF ((- (1)=validate(omf_etc_list->test,- (1))))
  CALL echo("DECLARE OMF_ETC_LIST")
  SET trace = recpersist
  FREE SET omf_etc_list
  RECORD omf_etc_list(
    1 test = i2
    1 max_encntr_type_cnt = i4
    1 data[*]
      2 encntr_type_class_cd = f8
      2 encntr_type_cnt = i4
      2 encntr_type[*]
        3 encntr_type_cd = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_coding_st = "OMF_CODING_ST.INC 336978"
 IF ((- (1)=validate(omf_coding_st->test,- (1))))
  CALL echo("DECLARE OMF_CODING_ST")
  SET trace = recpersist
  FREE SET omf_coding_st
  RECORD omf_coding_st(
    1 test = i2
    1 max_coding_cnt = i4
    1 max_apc_cnt = i4
    1 max_service_cat_cnt = i4
    1 data[*]
      2 status = i4
      2 errnum = i4
      2 errmsg = vc
      2 encntr_id = f8
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
      2 person_id = f8
      2 icd9_admit_diag_nomen_id = f8
      2 icd9_prin_proc_nomen_id = f8
      2 icd9_first_sec_diag_nomen_id = f8
      2 icd9_prin_proc_dt_tm = c25
      2 icd9_prin_proc_tz = i4
      2 icd9_prin_proc_dt_nbr = i4
      2 icd9_prin_proc_min_nbr = i4
      2 icd9_prin_proc_minutes = f8
      2 icd9_prin_proc_grp_cd = f8
      2 icd9_prin_diag_nomen_id = f8
      2 icd9_prin_diag_grp_cd = f8
      2 icd9_sec_diag_str = c255
      2 icd9_sec_proc_str = c255
      2 cpt4_proc_str = c255
      2 drg_nomen_id = f8
      2 drg_weight = f8
      2 drg_amlos = f8
      2 drg_grp_cd = f8
      2 drg_grp2_cd = f8
      2 drg_gmlos = f8
      2 drg_elos = f8
      2 aprdrg_nomen_id = f8
      2 aprdrg_soi_cd = f8
      2 aprdrg_rom_cd = f8
      2 aprdrg_mdc_cd = f8
      2 mdc_cd = f8
      2 death_24h_prin_proc_ind = i2
      2 cmg_nomen_id = f8
      2 dpg_nomen_id = f8
      2 ontario_case_wt = f8
      2 relative_index_wt = f8
      2 mcc_number = i4
      2 mcc_text = c255
      2 most_responsible_diagnosis = f8
      2 patient_status_cd = f8
      2 surgeon_id = f8
      2 surgeon_key = c255
      2 surgeon_ft_name = c255
      2 surgeon_grp_cd = f8
      2 surgeon_med_spec_cd = f8
      2 surgeon_position_cd = f8
      2 anesthesiologist_id = f8
      2 anesthesiologist_key = c255
      2 anesthesiologist_ft_name = c255
      2 anesth_position_cd = f8
      2 coding_cnt = i4
      2 apc_cnt = i4
      2 coding[*]
        3 procedure_id = f8
        3 nomenclature_id = f8
        3 source_vocabulary_cd = f8
        3 principle_type_cd = f8
        3 priority = i2
        3 procedure_minutes = i4
        3 procedure_dt_tm = c25
        3 procedure_tz = i4
        3 procedure_dt_nbr = i4
        3 procedure_min_nbr = i4
        3 anesthesia_cd = f8
        3 anesthesia_minutes = i4
        3 tissue_type_cd = f8
        3 anesthesiologist_id = f8
        3 anesthesiologist_key = c255
        3 anesthesiologist_ft_name = c255
        3 anesth_position_cd = f8
        3 svc_cat_hist_id = f8
        3 service_category_cd = f8
      2 apc_data[*]
        3 nomenclature_id = f8
        3 source_identifier = c50
        3 relative_weight = f8
        3 status_indicator = c1
        3 related_identifier_str = c255
        3 total_est_reimb_value = f8
        3 svc_cat_hist_id = f8
        3 service_category_cd = f8
      2 service_cat_cnt = i4
      2 service_cat[*]
        3 status = i4
        3 errnum = i4
        3 errmsg = vc
        3 drg_nomenclature_id = f8
        3 drg_grp_cd = f8
        3 drg_grp2_cd = f8
        3 mdc_cd = f8
        3 drg_weight = f8
        3 drg_amlos = f8
        3 drg_gmlos = f8
        3 icd_pd_nomenclature_id = f8
        3 icd_pd_grp_cd = f8
        3 icd_pp_nomenclature_id = f8
        3 icd_pp_grp_cd = f8
        3 icd_pp_dt_nbr = f8
        3 icd_pp_min_nbr = f8
        3 icd_pp_dt_tm = vc
        3 icd_pp_dt_tz = i4
        3 icd_pp_minutes = f8
        3 icd_sd_str = vc
        3 icd_sp_str = vc
        3 icd_fsd_nomenclature_id = f8
        3 cpt_p_str = vc
        3 anesthesiologist_id = f8
        3 anesth_position_cd = f8
        3 svc_cat_hist_id = f8
        3 service_category_cd = f8
        3 death_24h_prin_proc_ind = i2
        3 surgeon_id = f8
        3 surgeon_grp_cd = f8
        3 surgeon_med_spec_cd = f8
        3 surgeon_position_cd = f8
        3 med_service_cd = f8
        3 prev_service_category_cd = f8
        3 att_prsnl_id = f8
        3 att_prsnl_grp_cd = f8
        3 att_prsnl_med_spec_cd = f8
        3 attend_phys_position_cd = f8
        3 beg_transaction_dt_nbr = i4
        3 beg_transaction_min_nbr = i4
        3 beg_transaction_dt_tm = vc
        3 end_transaction_dt_nbr = i4
        3 end_transaction_min_nbr = i4
        3 end_transaction_dt_tm = vc
        3 updt_cnt = i4
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_order_svc = "OMF_ORDER_SVC.INC D005"
 IF ((- (1)=validate(omf_order_st->test,- (1))))
  CALL echo("DECLARE OMF_ORDER_ST")
  SET trace = recpersist
  FREE SET omf_order_st
  RECORD omf_order_st(
    1 test = i2
    1 data[*]
      2 status = i4
      2 errnum = i4
      2 errmsg = vc
      2 order_id = f8
      2 encntr_id = f8
      2 cancel_dt_tm = c25
      2 cancel_tz = i4
      2 cancel_dt_nbr = i4
      2 cancel_min_nbr = i4
      2 cki = c255
      2 complete_dt_nbr = i4
      2 complete_min_nbr = i4
      2 complete_dt_tm = c25
      2 complete_tz = i4
      2 need_doctor_cosign_ind = i2
      2 discontinue_dt_nbr = i4
      2 discontinue_min_nbr = i4
      2 discontinue_dt_tm = c25
      2 discontinue_tz = i4
      2 status_dt_nbr = i4
      2 status_min_nbr = i4
      2 status_dt_tm = c25
      2 status_tz = i4
      2 orig_order_dt_nbr = i4
      2 orig_order_min_nbr = i4
      2 orig_order_dt_tm = c25
      2 orig_order_tz = i4
      2 catalog_cd = f8
      2 priority_cd = f8
      2 activity_type_cd = f8
      2 order_facility_cd = f8
      2 order_facility_grp_cd = f8
      2 order_nurse_unit_cd = f8
      2 order_nurse_unit_grp_cd = f8
      2 action_personnel_id = f8
      2 action_prsnl_position_cd = f8
      2 order_provider_id = f8
      2 order_provider_position_cd = f8
      2 person_id = f8
      2 review_complete_ind = i2
      2 review_required_ind = i2
      2 current_start_dt_nbr = i4
      2 current_start_min_nbr = i4
      2 current_start_dt_tm = c25
      2 current_start_tz = i4
      2 order_ind = i2
      2 cancel_ind = i2
      2 complete_ind = i2
      2 visit_dt_tm = c25
      2 visit_tz = i4
      2 visit_dt_nbr = i4
      2 visit_min_nbr = i4
      2 icd9_prin_proc_dt_tm = c25
      2 icd9_prin_proc_tz = i4
      2 icd9_prin_proc_dt_nbr = i4
      2 icd9_prin_proc_min_nbr = i4
      2 cancel_reason_cd = f8
      2 discontinue_reason_cd = f8
      2 icd9_proc_nomenclature_id = f8
      2 catalog_type_cd = f8
      2 icd9_diag_nomenclature_id = f8
      2 cpt4_proc_nomenclature_id = f8
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
  )
  SET trace = norecpersist
 ENDIF
 IF ((- (1)=validate(omf_abstract_data_st->test,- (1))))
  CALL echo("DECLARE OMF_ABSTRACT_DATA_ST")
  SET trace = recpersist
  FREE SET omf_abstract_data_st
  RECORD omf_abstract_data_st(
    1 test = i2
    1 data[*]
      2 person_id = f8
      2 encntr_id = f8
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
      2 abstract_data[*]
        3 abstract_data_id = f8
        3 abstract_def_cd = f8
        3 abstract_field_type_cd = f8
        3 value_free_text = vc
        3 value_cd = f8
        3 value_dt_tm = c25
        3 value_tz = i4
        3 value_number = i4
        3 beg_effective_dt_tm = c25
        3 beg_effective_tz = i4
        3 end_effective_dt_tm = c25
        3 end_effective_tz = i4
        3 active_ind = i2
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_charge_st = "OMF_CHARGE_ST.INC 006"
 IF ((- (1)=validate(omf_charge_st->test,- (1))))
  CALL echo("DECLARE OMF_CHARGE_ST")
  SET trace = recpersist
  FREE SET omf_charge_st
  RECORD omf_charge_st(
    1 test = i2
    1 data[*]
      2 status = i4
      2 errnum = i4
      2 errmsg = vc
      2 charge_item_id = f8
      2 encntr_id = f8
      2 activity_type_cd = f8
      2 admit_type_cd = f8
      2 nomenclature_id = f8
      2 service_dt_tm = c25
      2 service_tz = i4
      2 tier_group_cd = f8
      2 cost_center_cd = f8
      2 ord_phys_id = f8
      2 order_phys_grp_cd = f8
      2 perf_phys_id = f8
      2 perf_phys_grp_cd = f8
      2 institution_cd = f8
      2 department_cd = f8
      2 section_cd = f8
      2 subsection_cd = f8
      2 item_quantity = f8
      2 item_price = f8
      2 item_extended_price = f8
      2 discount_amount = f8
      2 service_dt_nbr = i4
      2 service_min_nbr = i4
      2 charge_dt_nbr = i4
      2 charge_min_nbr = i4
      2 charge_dt_tm = c25
      2 charge_tz = i4
      2 payor_id = f8
      2 updt_id = f8
      2 process_flg = i4
      2 interfaced_dt_nbr = i4
      2 interfaced_min_nbr = i4
      2 interfaced_dt_tm = c25
      2 interfaced_tz = i4
      2 manual_ind = i2
      2 person_id = f8
      2 cpt4_id = f8
      2 icd9_id = f8
      2 bill_code_id = f8
      2 order_id = f8
      2 task_assay_cd = f8
      2 order_dt_tm = c25
      2 order_tz = i4
      2 order_dt_nbr = i4
      2 order_min_nbr = i4
      2 transaction_ind = i2
      2 catalog_cd = f8
      2 act_service_to_charge = i4
      2 loc_facility_cd = f8
      2 total_accum_charges = f8
      2 loc_nurse_unit_cd = f8
      2 bill_item_id = f8
      2 total_std_cost = f8
      2 std_direct_fix_cost = f8
      2 std_direct_var_cost = f8
      2 std_indirect_fix_cost = f8
      2 std_indirect_var_cost = f8
      2 total_act_cost = f8
      2 act_direct_fix_cost = f8
      2 act_direct_var_cost = f8
      2 act_indirect_fix_cost = f8
      2 act_indirect_var_cost = f8
      2 charge_description = c200
      2 charge_type_cd = f8
      2 cdm_desc = c200
      2 cdm_nbr = c200
      2 icd9_desc = c200
      2 icd9_nbr = c200
      2 cpt4_desc = c200
      2 cpt4_nbr = c200
      2 accession = c20
      2 rev_code_cd = f8
      2 rev_cat_cd = f8
      2 rev_cat_grp_cd = f8
      2 cost_center_grp_cd = f8
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
  )
  FREE RECORD omf_bill_item
  RECORD omf_bill_item(
    1 data[*]
      2 bill_item_id = f8
      2 catalog_cd = f8
      2 task_assay_cd = f8
      2 total_std_cost = f8
      2 std_direct_fix_cost = f8
      2 std_direct_var_cost = f8
      2 std_indirect_fix_cost = f8
      2 std_indirect_var_cost = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_std_cost = "OMF_STD_COST.INC 002"
 IF ((- (1)=validate(omf_std_cost->test,- (1))))
  CALL echo("DECLARE OMF_STD_COST")
  SET trace = recpersist
  FREE SET omf_std_cost
  RECORD omf_std_cost(
    1 test = i2
    1 data[*]
      2 bill_item_id = f8
      2 std_direct_var_cost = f8
      2 std_direct_fix_cost = f8
      2 std_indirect_var_cost = f8
      2 std_indirect_fix_cost = f8
      2 organization_id = f8
  )
  SET v_ndx = 0
  SELECT INTO "nl:"
   oc.bill_item_id, oc.std_ind, oc.direct_var_cost,
   oc.direct_fix_cost, oc.indirect_var_cost, oc.indirect_fix_cost,
   oc.organization_id
   FROM omf_cost oc
   WHERE oc.std_ind=1
    AND oc.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN oc.beg_effective_dt_tm AND oc.end_effective_dt_tm
   DETAIL
    v_ndx += 1, stat = alterlist(omf_std_cost->data,v_ndx), omf_std_cost->data[v_ndx].bill_item_id =
    oc.bill_item_id,
    omf_std_cost->data[v_ndx].std_direct_var_cost = oc.direct_var_cost, omf_std_cost->data[v_ndx].
    std_direct_fix_cost = oc.direct_fix_cost, omf_std_cost->data[v_ndx].std_indirect_var_cost = oc
    .indirect_var_cost,
    omf_std_cost->data[v_ndx].std_indirect_fix_cost = oc.indirect_fix_cost, omf_std_cost->data[v_ndx]
    .organization_id = oc.organization_id
   WITH nocounter
  ;end select
  SET trace = norecpersist
 ENDIF
 SET c_omf_health_plan_smry = "OMF_HEALTH_PLAN_SMRY_ST.INC 001"
 IF ((- (1)=validate(omf_health_plan_smry_st->test,- (1))))
  CALL echo("DECLARE OMF_HEALTH_PLAN_SMRY_ST")
  SET trace = recpersist
  FREE SET omf_health_plan_smry_st
  RECORD omf_health_plan_smry_st(
    1 test = i2
    1 data[*]
      2 health_plan_id = f8
      2 health_plan_dt_nbr = i4
      2 health_plan_dt_tm = vc
      2 nbr_members = f8
      2 nbr_member_years = f8
      2 nbr_admits = f8
      2 nbr_er_visits = f8
      2 nbr_inp_bed_days = f8
      2 nbr_readmits_30d = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_member_smry_st = "OMF_MEMBER_SMRY_ST.INC 001"
 IF ((- (1)=validate(omf_member_smry_st->test,- (1))))
  CALL echo("DECLARE OMF_MEMBER_SMRY_ST")
  SET trace = recpersist
  FREE SET omf_member_smry_st
  RECORD omf_member_smry_st(
    1 test = i2
    1 data[*]
      2 person_id = f8
      2 prim_health_plan_id = f8
      2 sec_health_plan_id = f8
      2 health_plan_dt_nbr = i4
      2 health_plan_dt_tm = vc
      2 encntr_type_cd = f8
      2 encntr_type_class_cd = f8
      2 pcp_phys_id = f8
      2 pcp_phys_key = vc
      2 pcp_phys_ft_name = vc
      2 pcp_phys_grp_cd = f8
      2 pcp_phys_med_spec_cd = f8
      2 nbr_admits = f8
      2 nbr_er_visits = f8
      2 nbr_inp_bed_days = f8
      2 nbr_readmits_30d = f8
      2 admits_per_1000 = f8
      2 inp_days_per_1000 = f8
      2 er_visits_per_1000 = f8
      2 readmits_per_1000 = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_census_smry = "OMF_CENSUS_SMRY.INC D006"
 IF ((- (1)=validate(omf_census_smry_st->test,- (1))))
  SET trace = recpersist
  FREE SET omf_census_smry_st
  RECORD omf_census_smry_st(
    1 test = i2
    1 data[*]
      2 census_dt_tm = c25
      2 census_tz = i4
      2 census_dt_nbr = i4
      2 occupied_bed_cnt = i4
      2 inpatient_cnt = i4
      2 occupied_bed_pd = i4
      2 inpatient_pd = i4
      2 encntr_type_cd = f8
      2 fin_class_cd = f8
      2 med_service_cd = f8
      2 loc_nurse_unit_cd = f8
      2 loc_building_cd = f8
      2 loc_facility_cd = f8
      2 curr_mth_disch_pd = i4
      2 isolation_cd = f8
      2 loa_cnt = i4
      2 ext_loa_cnt = i4
      2 ext_loa_return_cnt = i4
      2 new_ext_loa_cnt = i4
      2 new_pend_arr_cnt = i4
      2 pend_arr_cnt = i4
      2 pend_arr_admt_cnt = i4
      2 pend_arr_admt_wd = i4
      2 new_pend_dsch_cnt = i4
      2 pend_dsch_cnt = i4
      2 pend_dsch_dsch_cnt = i4
      2 pend_dsch_dsch_wd = i4
      2 tot_admt_cnt = i4
      2 one_day_stay_cnt = i4
      2 transfer_out_cnt = i4
      2 transfer_in_cnt = i4
      2 disch_cnt = i4
      2 deceased_cnt = i4
      2 alc_cnt = i4
      2 alc_disch_cnt = i4
      2 alc_disch_wd = i4
  )
  FREE SET omf_census_detail
  RECORD omf_census_detail(
    1 test = i2
    1 data[*]
      2 encntr_id = f8
      2 census_dt_tm = c25
      2 census_dt_nbr = i4
      2 occupied_bed_cnt = i4
      2 inpatient_cnt = i4
      2 occupied_bed_pd = i4
      2 inpatient_pd = i4
      2 encntr_type_cd = f8
      2 fin_class_cd = f8
      2 med_service_cd = f8
      2 loc_nurse_unit_cd = f8
      2 loc_building_cd = f8
      2 loc_facility_cd = f8
      2 curr_mth_disch_pd = i4
      2 isolation_cd = f8
      2 visit_dt_tm = vc
      2 inp_obs_ind = i2
      2 loa_flag = i2
      2 ext_loa_flag = i2
      2 ext_loa_return_flag = i2
      2 new_ext_loa_flag = i2
      2 new_pend_arr_flag = i2
      2 pend_arr_flag = i2
      2 pend_arr_admt_flag = i2
      2 pend_arr_admt_wd = i4
      2 new_pend_dsch_flag = i2
      2 pend_dsch_flag = i2
      2 pend_dsch_dsch_flag = i2
      2 pend_dsch_dsch_wd = i4
      2 tot_admt_flag = i2
      2 one_day_stay_flag = i2
      2 transfer_out_flag = i2
      2 transfer_in_flag = i2
      2 disch_flag = i2
      2 deceased_flag = i2
      2 alc_flag = i2
      2 alc_disch_flag = i2
      2 alc_disch_wd = i4
  )
  FREE SET pm_census_ids
  RECORD pm_census_ids(
    1 data[*]
      2 encntr_id = f8
      2 disch_ind = i2
      2 deceased_ind = i2
  )
  SET trace = norecpersist
 ENDIF
 IF ((- (1)=validate(omf_abst_coding_reltn_st->test,- (1))))
  CALL echo("DECLARE OMF_ABST_CODING_RELTN_ST")
  SET trace = recpersist
  FREE SET omf_abst_coding_reltn_st
  RECORD omf_abst_coding_reltn_st(
    1 test = i2
    1 data[*]
      2 nomenclature_id = f8
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_clinical_event_st = "OMF_CLINICAL_EVENT_ST.INC D008"
 IF ((- (1)=validate(omf_clinical_event_st->test,- (1))))
  CALL echo("DECLARE OMF_CLINICAL_EVENT_ST")
  SET trace = recpersist
  FREE SET omf_clinical_event_st
  RECORD omf_clinical_event_st(
    1 test = i2
    1 max_micro_cnt = i4
    1 max_susc_cnt = i4
    1 data[*]
      2 status = i4
      2 errnum = i4
      2 errmsg = vc
      2 qual_ind = i2
      2 encntr_id = f8
      2 event_id = f8
      2 parent_event_id = f8
      2 event_title_text = vc
      2 event_cd = f8
      2 person_id = f8
      2 order_id = f8
      2 catalog_cd = f8
      2 task_assay_cd = f8
      2 perform_prsnl_id = f8
      2 perform_prsnl_position_cd = f8
      2 service_dt_tm = c25
      2 service_tz = i4
      2 event_start_dt_nbr = i4
      2 event_start_min_nbr = i4
      2 service_dt_nbr = i4
      2 service_min_nbr = i4
      2 normalcy_cd = f8
      2 normal_ind = i2
      2 normal_low = c20
      2 normal_high = c20
      2 result_val = c255
      2 source_type_cd = f8
      2 specimen_id = f8
      2 body_site_cd = f8
      2 result_units_cd = f8
      2 event_start_dt_tm = c25
      2 event_start_tz = i4
      2 ce_result_dt_nbr = i4
      2 ce_result_min_nbr = i4
      2 ce_result_dt_tm = c25
      2 ce_result_tz = i4
      2 ce_result_dt_ind = i2
      2 ce_result_nbr_value = f8
      2 ce_result_nbr_ind = i2
      2 time_zone = vc
      2 time_zone_indx = i4
      2 time_zone_status = i2
      2 micro_cnt = i4
      2 micro[*]
        3 status = i4
        3 errnum = i4
        3 errmsg = vc
        3 event_id = f8
        3 micro_seq_nbr = i4
        3 organism_cd = f8
        3 susc_cnt = i4
        3 susc[*]
          4 status = i4
          4 errnum = i4
          4 errmsg = vc
          4 event_id = f8
          4 micro_seq_nbr = i4
          4 suscep_seq_nbr = i4
          4 antibiotic_cd = f8
          4 susceptibility_test_cd = f8
          4 detail_susceptibility_cd = f8
          4 result_cd = f8
          4 result_tz = i4
          4 result_dt_tm = c25
          4 result_dt_nbr = i4
          4 result_min_nbr = i4
          4 result_numeric_value = f8
          4 result_text_value = c100
          4 result_unit_cd = f8
          4 result_text_key = c255
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_charge_st = "OMF_POSTED_CHARGE_ST.INC 003"
 IF ((- (1)=validate(omf_posted_charge_st->test,- (1))))
  CALL echo("DECLARE OMF_POSTED_CHARGE_ST")
  SET trace = recpersist
  FREE SET omf_posted_charge_st
  RECORD omf_posted_charge_st(
    1 test = i2
    1 data[*]
      2 charge_item_id = f8
      2 encntr_id = f8
      2 activity_type_cd = f8
      2 admit_type_cd = f8
      2 nomenclature_id = f8
      2 service_dt_tm = c25
      2 service_tz = i4
      2 tier_group_cd = f8
      2 cost_center_cd = f8
      2 ord_phys_id = f8
      2 order_phys_grp_cd = f8
      2 perf_phys_id = f8
      2 perf_phys_grp_cd = f8
      2 institution_cd = f8
      2 department_cd = f8
      2 section_cd = f8
      2 subsection_cd = f8
      2 item_quantity = f8
      2 item_price = f8
      2 item_extended_price = f8
      2 discount_amount = f8
      2 service_dt_nbr = i4
      2 service_min_nbr = i4
      2 charge_dt_nbr = i4
      2 charge_min_nbr = i4
      2 charge_dt_tm = c25
      2 charge_tz = i4
      2 payor_id = f8
      2 updt_id = f8
      2 process_flg = i4
      2 interfaced_dt_nbr = i4
      2 interfaced_min_nbr = i4
      2 interfaced_dt_tm = c25
      2 interfaced_tz = i4
      2 manual_ind = i2
      2 person_id = f8
      2 cpt4_id = f8
      2 icd9_id = f8
      2 bill_code_id = f8
      2 order_id = f8
      2 task_assay_cd = f8
      2 order_dt_tm = c25
      2 order_tz = i4
      2 order_dt_nbr = i4
      2 order_min_nbr = i4
      2 transaction_ind = i2
      2 catalog_cd = f8
      2 act_service_to_charge = i4
      2 loc_facility_cd = f8
      2 total_accum_charges = f8
      2 loc_nurse_unit_cd = f8
      2 bill_item_id = f8
      2 total_std_cost = f8
      2 std_direct_fix_cost = f8
      2 std_direct_var_cost = f8
      2 std_indirect_fix_cost = f8
      2 std_indirect_var_cost = f8
      2 total_act_cost = f8
      2 act_direct_fix_cost = f8
      2 act_direct_var_cost = f8
      2 act_indirect_fix_cost = f8
      2 act_indirect_var_cost = f8
      2 charge_description = c200
      2 charge_type_cd = f8
      2 cdm_desc = c200
      2 cdm_nbr = c200
      2 icd9_desc = c200
      2 icd9_nbr = c200
      2 cpt4_desc = c200
      2 cpt4_nbr = c200
      2 accession = c20
      2 rev_code_cd = f8
      2 rev_cat_cd = f8
      2 rev_cat_grp_cd = f8
      2 cost_center_grp_cd = f8
      2 org_id = f8
      2 cost_ratio_ind = i2
      2 cost_basis_cd = i4
      2 total_only_ind = i2
  )
  SET trace = norecpersist
 ENDIF
 SET c_omf_groupings_cache = "OMF_GROUPINGS_CACHE.INC 005"
 IF ((- (1)=validate(omf_groupings->test,- (1))))
  SET trace = recpersist
  CALL echo("CACHE FOR OMF_GROUPINGS")
  FREE RECORD omf_groupings
  RECORD omf_groupings(
    1 test = i2
    1 cap_phys[*]
      2 grp_cd = f8
      2 phys_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cost_center[*]
      2 grp_cd = f8
      2 cost_center_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 rev_cat[*]
      2 grp_cd = f8
      2 rev_code_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 rev_cat_grp[*]
      2 grp_cd = f8
      2 rev_cat_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_fac[*]
      2 grp_cd = f8
      2 facility_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_nu[*]
      2 grp_cd = f8
      2 nurse_unit_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_nu2[*]
      2 grp_cd = f8
      2 nurse_unit_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_medspec[*]
      2 grp_cd = f8
      2 phys_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_diag[*]
      2 grp_cd = f8
      2 nomenclature_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_drg[*]
      2 grp_cd = f8
      2 nomenclature_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_drg2[*]
      2 grp_cd = f8
      2 nomenclature_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_age[*]
      2 grp_cd = f8
      2 num1 = i4
      2 num2 = i4
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_age_days[*]
      2 grp_cd = f8
      2 num1 = i4
      2 num2 = i4
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_medserv[*]
      2 grp_cd = f8
      2 med_serv_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_proc[*]
      2 grp_cd = f8
      2 nomenclature_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_ins_co[*]
      2 grp_cd = f8
      2 organization_id = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_hlthpl[*]
      2 grp_cd = f8
      2 health_plan_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_zipcode[*]
      2 grp_cd = f8
      2 zipcode = vc
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_shift[*]
      2 grp_cd = f8
      2 num1 = i4
      2 num2 = i4
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
    1 cap_role[*]
      2 grp_cd = f8
      2 role_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
  )
  SELECT INTO "nl:"
   grp_cd = og.grouping_cd, key1 = og.key1, key2 = og.key2,
   beg_date = og.valid_from_dt_tm, end_date = og.valid_until_dt_tm
   FROM omf_groupings og
   WHERE (og.grouping_status_cd != omf_prologue_cv->48_inactive)
    AND og.grouping_cd IN (omf_prologue_cv->13003_cap_phys, omf_prologue_cv->13003_cost_center,
   omf_prologue_cv->13003_rev_cat, omf_prologue_cv->13003_rev_cat_grp, omf_prologue_cv->13003_cap_fac,
   omf_prologue_cv->13003_cap_nu, omf_prologue_cv->13003_cap_nu2, omf_prologue_cv->13003_cap_medspec,
   omf_prologue_cv->13003_cap_diag, omf_prologue_cv->13003_cap_drg,
   omf_prologue_cv->13003_cap_drg2, omf_prologue_cv->13003_cap_age, omf_prologue_cv->
   13003_cap_age_days, omf_prologue_cv->13003_cap_medserv, omf_prologue_cv->13003_cap_proc,
   omf_prologue_cv->13003_cap_ins_co, omf_prologue_cv->13003_cap_hlthpl, omf_prologue_cv->
   13003_cap_zipcode, omf_prologue_cv->13003_cap_shift, omf_prologue_cv->13003_cap_role)
   ORDER BY grp_cd
   HEAD grp_cd
    ndx = 0
   DETAIL
    IF ((grp_cd=omf_prologue_cv->13003_cap_phys))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_phys,5))
      stat = alterlist(omf_groupings->cap_phys,(ndx+ 9))
     ENDIF
     omf_groupings->cap_phys[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_phys[ndx].phys_id =
     cnvtreal(og.key1), omf_groupings->cap_phys[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_phys[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cost_center))
     ndx += 1
     IF (ndx > size(omf_groupings->cost_center,5))
      stat = alterlist(omf_groupings->cost_center,(ndx+ 9))
     ENDIF
     omf_groupings->cost_center[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cost_center[ndx].
     cost_center_cd = cnvtreal(og.key1), omf_groupings->cost_center[ndx].beg_effective_dt_tm = format
     (og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cost_center[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_rev_cat))
     ndx += 1
     IF (ndx > size(omf_groupings->rev_cat,5))
      stat = alterlist(omf_groupings->rev_cat,(ndx+ 9))
     ENDIF
     omf_groupings->rev_cat[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->rev_cat[ndx].rev_code_cd
      = cnvtreal(og.key1), omf_groupings->rev_cat[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->rev_cat[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_rev_cat_grp))
     ndx += 1
     IF (ndx > size(omf_groupings->rev_cat_grp,5))
      stat = alterlist(omf_groupings->rev_cat_grp,(ndx+ 9))
     ENDIF
     omf_groupings->rev_cat_grp[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->rev_cat_grp[ndx].
     rev_cat_cd = cnvtreal(og.key1), omf_groupings->rev_cat_grp[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->rev_cat_grp[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_fac))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_fac,5))
      stat = alterlist(omf_groupings->cap_fac,(ndx+ 9))
     ENDIF
     omf_groupings->cap_fac[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_fac[ndx].facility_cd
      = cnvtreal(og.key1), omf_groupings->cap_fac[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_fac[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_nu))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_nu,5))
      stat = alterlist(omf_groupings->cap_nu,(ndx+ 9))
     ENDIF
     omf_groupings->cap_nu[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_nu[ndx].nurse_unit_cd
      = cnvtreal(og.key1), omf_groupings->cap_nu[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_nu[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_nu2))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_nu2,5))
      stat = alterlist(omf_groupings->cap_nu2,(ndx+ 9))
     ENDIF
     omf_groupings->cap_nu2[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_nu2[ndx].
     nurse_unit_cd = cnvtreal(og.key1), omf_groupings->cap_nu2[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_nu2[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_medspec))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_medspec,5))
      stat = alterlist(omf_groupings->cap_medspec,(ndx+ 9))
     ENDIF
     omf_groupings->cap_medspec[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_medspec[ndx].
     phys_id = cnvtreal(og.key1), omf_groupings->cap_medspec[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_medspec[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_diag))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_diag,5))
      stat = alterlist(omf_groupings->cap_diag,(ndx+ 9))
     ENDIF
     omf_groupings->cap_diag[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_diag[ndx].
     nomenclature_id = cnvtreal(og.key1), omf_groupings->cap_diag[ndx].beg_effective_dt_tm = format(
      og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_diag[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_drg))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_drg,5))
      stat = alterlist(omf_groupings->cap_drg,(ndx+ 9))
     ENDIF
     omf_groupings->cap_drg[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_drg[ndx].
     nomenclature_id = cnvtreal(og.key1), omf_groupings->cap_drg[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_drg[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_drg2))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_drg2,5))
      stat = alterlist(omf_groupings->cap_drg2,(ndx+ 9))
     ENDIF
     omf_groupings->cap_drg2[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_drg2[ndx].
     nomenclature_id = cnvtreal(og.key1), omf_groupings->cap_drg2[ndx].beg_effective_dt_tm = format(
      og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_drg2[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_age))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_age,5))
      stat = alterlist(omf_groupings->cap_age,(ndx+ 9))
     ENDIF
     omf_groupings->cap_age[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_age[ndx].num1 = og
     .num1, omf_groupings->cap_age[ndx].num2 = og.num2,
     omf_groupings->cap_age[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"), omf_groupings->cap_age[ndx].end_effective_dt_tm = format(og
      .valid_until_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_age_days))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_age_days,5))
      stat = alterlist(omf_groupings->cap_age_days,(ndx+ 9))
     ENDIF
     omf_groupings->cap_age_days[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_age_days[ndx].
     num1 = og.num1, omf_groupings->cap_age_days[ndx].num2 = og.num2,
     omf_groupings->cap_age_days[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"), omf_groupings->cap_age_days[ndx].end_effective_dt_tm = format(og
      .valid_until_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_medserv))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_medserv,5))
      stat = alterlist(omf_groupings->cap_medserv,(ndx+ 9))
     ENDIF
     omf_groupings->cap_medserv[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_medserv[ndx].
     med_serv_cd = cnvtreal(og.key1), omf_groupings->cap_medserv[ndx].beg_effective_dt_tm = format(og
      .valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_medserv[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_proc))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_proc,5))
      stat = alterlist(omf_groupings->cap_proc,(ndx+ 9))
     ENDIF
     omf_groupings->cap_proc[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_proc[ndx].
     nomenclature_id = cnvtreal(og.key1), omf_groupings->cap_proc[ndx].beg_effective_dt_tm = format(
      og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_proc[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_ins_co))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_ins_co,5))
      stat = alterlist(omf_groupings->cap_ins_co,(ndx+ 9))
     ENDIF
     omf_groupings->cap_ins_co[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_ins_co[ndx].
     organization_id = cnvtreal(og.key1), omf_groupings->cap_ins_co[ndx].beg_effective_dt_tm = format
     (og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_ins_co[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_hlthpl))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_hlthpl,5))
      stat = alterlist(omf_groupings->cap_hlthpl,(ndx+ 9))
     ENDIF
     omf_groupings->cap_hlthpl[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_hlthpl[ndx].
     health_plan_cd = cnvtreal(og.key1), omf_groupings->cap_hlthpl[ndx].beg_effective_dt_tm = format(
      og.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_hlthpl[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_zipcode))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_zipcode,5))
      stat = alterlist(omf_groupings->cap_zipcode,(ndx+ 9))
     ENDIF
     omf_groupings->cap_zipcode[ndx].grp_cd = cnvtreal(og.key2)
     IF (substring(1,1,trim(og.key1,3))="'"
      AND substring(size(trim(og.key1,3)),1,og.key1)="'")
      omf_groupings->cap_zipcode[ndx].zipcode = trim(substring(2,(size(trim(og.key1)) - 2),og.key1),3
       )
     ELSE
      omf_groupings->cap_zipcode[ndx].zipcode = trim(og.key1,3)
     ENDIF
     omf_groupings->cap_zipcode[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"), omf_groupings->cap_zipcode[ndx].end_effective_dt_tm = format(og
      .valid_until_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_shift))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_shift,5))
      stat = alterlist(omf_groupings->cap_shift,(ndx+ 9))
     ENDIF
     omf_groupings->cap_shift[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_shift[ndx].num1 =
     og.num1, omf_groupings->cap_shift[ndx].num2 = og.num2,
     omf_groupings->cap_shift[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"), omf_groupings->cap_shift[ndx].end_effective_dt_tm = format(og
      .valid_until_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_role))
     ndx += 1
     IF (ndx > size(omf_groupings->cap_role,5))
      stat = alterlist(omf_groupings->cap_role,(ndx+ 9))
     ENDIF
     omf_groupings->cap_role[ndx].grp_cd = cnvtreal(og.key2), omf_groupings->cap_role[ndx].role_cd =
     cnvtreal(og.key1), omf_groupings->cap_role[ndx].beg_effective_dt_tm = format(og.valid_from_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d"),
     omf_groupings->cap_role[ndx].end_effective_dt_tm = format(og.valid_until_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")
    ENDIF
   FOOT  grp_cd
    IF ((grp_cd=omf_prologue_cv->13003_cap_phys))
     stat = alterlist(omf_groupings->cap_phys,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cost_center))
     stat = alterlist(omf_groupings->cost_center,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_rev_cat))
     stat = alterlist(omf_groupings->rev_cat,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_rev_cat_grp))
     stat = alterlist(omf_groupings->rev_cat_grp,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_fac))
     stat = alterlist(omf_groupings->cap_fac,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_nu))
     stat = alterlist(omf_groupings->cap_nu,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_nu2))
     stat = alterlist(omf_groupings->cap_nu2,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_medspec))
     stat = alterlist(omf_groupings->cap_medspec,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_diag))
     stat = alterlist(omf_groupings->cap_diag,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_drg))
     stat = alterlist(omf_groupings->cap_drg,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_drg2))
     stat = alterlist(omf_groupings->cap_drg2,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_age))
     stat = alterlist(omf_groupings->cap_age,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_age_days))
     stat = alterlist(omf_groupings->cap_age_days,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_medserv))
     stat = alterlist(omf_groupings->cap_medserv,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_proc))
     stat = alterlist(omf_groupings->cap_proc,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_ins_co))
     stat = alterlist(omf_groupings->cap_ins_co,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_hlthpl))
     stat = alterlist(omf_groupings->cap_hlthpl,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_zipcode))
     stat = alterlist(omf_groupings->cap_zipcode,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_shift))
     stat = alterlist(omf_groupings->cap_shift,ndx)
    ELSEIF ((grp_cd=omf_prologue_cv->13003_cap_role))
     stat = alterlist(omf_groupings->cap_role,ndx)
    ENDIF
   WITH nocounter
  ;end select
  SET trace = norecpersist
 ENDIF
 SET c_omf_groupings_cache = "OMF_DATE_CACHE.INC 002"
 IF ((- (1)=validate(omf_date_cache->test,- (1))))
  SET trace = recpersist
  CALL echo("CACHE FOR OMF_DATE")
  FREE RECORD omf_date_cache
  RECORD omf_date_cache(
    1 test = i2
    1 data[*]
      2 dt_nbr = i4
  )
  SELECT INTO "nl:"
   dt_nbr = od.dt_nbr
   FROM omf_date od
   WHERE od.dt_nbr > 0
   HEAD REPORT
    ndx = 0
   DETAIL
    ndx += 1
    IF (ndx > size(omf_date_cache->data,5))
     stat = alterlist(omf_date_cache->data,(ndx+ 999))
    ENDIF
    omf_date_cache->data[ndx].dt_nbr = dt_nbr
   FOOT REPORT
    stat = alterlist(omf_date_cache->data,ndx)
   WITH nocounter
  ;end select
  SET trace = norecpersist
 ENDIF
 CALL echo("Overriding logging --- Full Logging turned on for testing...")
 SET trace = norecpersist
END GO
