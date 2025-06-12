CREATE PROGRAM batch_pm_to_procare:dba
 DECLARE fextracttypecd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",14135,"PM ADT"))
 DECLARE iencounteridx = i4 WITH protect, noconstant(0)
 DECLARE iitems2process = i4 WITH protect, noconstant(0)
 DECLARE itemsleft = i4 WITH protect, noconstant(0)
 DECLARE iiterationidx = i4 WITH protect, noconstant(0)
 DECLARE log_filename = vc WITH constant("PROCARE_BATCH_ADT")
 DECLARE log_text = vc WITH protect, noconstant(" ")
 DECLARE stempstr = vc WITH protect
 SUBROUTINE (omflogprint(text=vc) =null WITH public)
   IF (validate(log_filename))
    SELECT INTO value(log_filename)
     FROM dummyt
     DETAIL
      IF (size(text,1) < 35000)
       CALL print(text)
      ENDIF
     WITH noheading, nocounter, format = lfstream,
      maxcol = 35000, maxrow = 1, append
    ;end select
   ELSE
    CALL echo(text)
   ENDIF
 END ;Subroutine
 CALL echo("ENTERING batch_procare_start <include file>..")
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
 SET c_omf_profile_save = "OMF_TIME_ZONE_HEADER.INC 000"
 DECLARE v_utc_on_ind = i2 WITH noconstant(0)
 FREE SET tz
 RECORD tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 )
 SET v_utc_on_ind = 0
 IF (validate(curutc,999)=999)
  SET v_utc_on_ind = 0
 ELSE
  IF (curutc)
   SET v_utc_on_ind = 1
   DECLARE v_time_zone = vc
   DECLARE c_tmzn_cd = f8
   DECLARE code_set = f8
   DECLARE code_value = f8
   DECLARE cdf_meaning = c12
   SET code_value = 0
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 13003
   SET cdf_meaning = "TIME ZONE"
   EXECUTE cpm_get_cd_for_cdf
   SET c_tmzn_cd = code_value
   DECLARE uar_datesettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateSetTimeZone"
   DECLARE uar_dategettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateGetTimeZone"
   DECLARE uar_dategetsystemtimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateGetSystemTimeZone"
  ENDIF
 ENDIF
 IF (v_utc_on_ind=1)
  CALL echo("... OMF_TIME_ZONE_HEADER: UTC is turned ON.")
 ELSE
  CALL echo("... OMF_TIME_ZONE_HEADER: UTC is turned OFF or not present.")
 ENDIF
 DECLARE idebugind = i4 WITH protect, noconstant(0)
 DECLARE iqual = i4 WITH protect, noconstant(0)
 DECLARE i_incrementalactiveind = i4 WITH protect, noconstant(0)
 DECLARE i_historicalactiveind = i4 WITH protect, noconstant(0)
 DECLARE i_feedactiveind = i4 WITH protect, noconstant(0)
 DECLARE v_utc_on_ind = i4 WITH protect, noconstant(curutc)
 DECLARE d_incrementalfrom = dq8 WITH protect
 DECLARE d_incrementalto = dq8 WITH protect
 DECLARE dhistoricalfrom = dq8 WITH protect
 DECLARE dhistoricalto = dq8 WITH protect
 DECLARE s_activefeedmsg = vc WITH protect
 DECLARE s_currentoperation = vc WITH protect
 DECLARE c_process_inserted = i2 WITH constant(0)
 DECLARE c_process_inprocess = i2 WITH constant(1)
 DECLARE c_process_complete = i2 WITH constant(2)
 DECLARE c_dml_block_small = i2 WITH constant(256)
 DECLARE c_dml_block_medium = i2 WITH constant(512)
 DECLARE c_dml_block_large = i2 WITH constant(1024)
 DECLARE c_ccl_block_small = i2 WITH constant(8)
 DECLARE c_ccl_block_medium = i2 WITH constant(128)
 DECLARE c_ccl_block_large = i2 WITH constant(512)
 CALL echo("Entering OMF_PASSIVE_ROUTINES.inc...")
 SUBROUTINE (field_exists(stable=vc,sfield=vc) =i2)
   DECLARE sexpr = c256 WITH protect
   DECLARE iexists = i2 WITH protect
   RANGE OF rng1 IS value(stable)
   SET sexpr = concat("cnvtstring(validate(rng1.",sfield,', 999)) = "999"')
   IF (parser(sexpr))
    SET iexists = 0
   ELSE
    SET iexists = 1
   ENDIF
   FREE RANGE rng1
   RETURN(iexists)
 END ;Subroutine
 SUBROUTINE (usediscernadmin(sdummy=vc) =i2)
   DECLARE idiscernadminind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain="POWERVISION"
     AND info_name="USE DISCERNANALYTICSADMINISTRATOR"
     AND info_char="Y"
    DETAIL
     idiscernadminind = 1
    WITH nocounter
   ;end select
   RETURN(idiscernadminind)
 END ;Subroutine
 CALL echo("Exiting OMF_PASSIVE_ROUTINES.inc...")
 IF (( $1="LOG"))
  SET idebugind = 1
 ENDIF
 SELECT INTO "nl:"
  nullind_t_last_extract_dt_tm = nullind(t.last_extract_dt_tm)
  FROM omf_extract_type t
  WHERE t.extract_type_cd=fextracttypecd
  HEAD REPORT
   d_incrementalfrom = 0, d_incrementalto = 0, i_feedactiveind = 0
  DETAIL
   i_feedactiveind = t.active_ind, d_incrementalto = cnvtdatetimeutc(cnvtdatetime(sysdate))
   IF (nullind_t_last_extract_dt_tm)
    d_incrementalfrom = cnvtdatetimeutc(cnvtdatetime(curdate,0))
   ELSE
    d_incrementalfrom = t.last_extract_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (i_feedactiveind=1)
  SET s_currentoperation = uar_get_code_meaning(fextracttypecd)
  SET reply->subeventstatus[1].operationname = s_currentoperation
  SET s_activefeedmsg = concat(build(uar_get_code_display(fextracttypecd))," still active.")
  SET reply->subeventstatus[1].targetobjectvalue = s_activefeedmsg
  GO TO end_batch
 ENDIF
 CALL echo("..EXITING batch_procare_start")
 IF (idebugind=1)
  CALL omflogprint(" ")
  SET stempstr = concat("Ops Date: ",format(request->ops_date,"@SHORTDATETIME"))
  CALL omflogprint(concat("============ ",stempstr," ============"))
  SET stempstr = build2(format(d_incrementalfrom,"@SHORTDATETIME")," AND ",format(d_incrementalto,
    "@SHORTDATETIME"))
  CALL omflogprint(concat("Processing Encounters updated between: ",stempstr))
  CALL omflogprint(" ")
 ENDIF
 INSERT  FROM omf_extract_batch b
  (b.omf_extract_batch_id, b.extract_type_cd, b.parent_entity_name,
  b.parent_entity_id, b.addl_parent_entity_name, b.addl_parent_entity_id,
  b.active_ind, b.process_flag)(SELECT
   seq(omf_seq,nextval), fextracttypecd, "ENCOUNTER",
   e.encntr_id, "PERSON", e.person_id,
   e.active_ind, value(c_process_inserted)
   FROM encounter e
   WHERE e.updt_dt_tm BETWEEN cnvtdatetime(d_incrementalfrom) AND cnvtdatetime(d_incrementalto))
  WITH nocounter
 ;end insert
 IF (idebugind=1)
  SET iitems2process = curqual
  SET stempstr = build2("Total Encounters to process: ",build(iitems2process))
  CALL omflogprint(stempstr)
 ENDIF
 SET iqual = 1
 WHILE (iqual > 0)
   SET iiterationidx += 1
   UPDATE  FROM omf_extract_batch b
    SET b.process_flag = c_process_inprocess
    WHERE b.extract_type_cd=fextracttypecd
     AND b.process_flag=c_process_inserted
     AND b.active_ind=0
    WITH maxqual(b,value(c_ccl_block_large))
   ;end update
   SET iqual = curqual
   IF (iqual > 0)
    SELECT INTO "nl:"
     FROM omf_extract_batch b
     WHERE b.extract_type_cd=fextracttypecd
      AND b.active_ind=0
      AND b.process_flag=c_process_inprocess
     HEAD REPORT
      iencntridx = 0, stat = initrec(omf_encntr_st), stat = alterlist(omf_encntr_st->data,
       c_ccl_block_large)
     DETAIL
      iencntridx += 1, omf_encntr_st->data[iencntridx].encntr_id = cnvtreal(b.parent_entity_id),
      omf_encntr_st->data[iencntridx].person_id = cnvtreal(b.addl_parent_entity_id)
     FOOT REPORT
      stat = alterlist(omf_encntr_st->data,iencntridx)
     WITH nocounter
    ;end select
    IF (idebugind=1)
     SET stempstr = concat("   Iteration #",build(iiterationidx)," - Processing ",build(size(
        omf_encntr_st->data,5)," inactive encounters."))
     CALL omflogprint(stempstr)
    ENDIF
    FOR (iidx = 1 TO size(omf_encntr_st->data,5))
      SET encntr_id = omf_encntr_st->data[iidx].encntr_id
      SET c_omf_check_active = "OMF_CHECK_ACTIVE.INC 001"
      SET active_ind = 1
      SELECT INTO "nl:"
       e.encntr_id, e.active_ind
       FROM encounter e
       WHERE e.encntr_id=encntr_id
       DETAIL
        active_ind = e.active_ind
       WITH nocounter
      ;end select
      IF (active_ind=0)
       FREE SET omf_event
       RECORD omf_event(
         1 data[*]
           2 event_id = f8
       )
       SET v_evtcnt = 0
       SELECT INTO "nl:"
        oces.event_id
        FROM omf_clinical_event_st oces
        WHERE oces.encntr_id=encntr_id
        DETAIL
         v_evtcnt += 1, stat = alterlist(omf_event->data,v_evtcnt), omf_event->data[v_evtcnt].
         event_id = oces.event_id
        WITH nocounter
       ;end select
       FOR (v_evtcnt = 1 TO size(omf_event->data,5))
        DELETE  FROM omf_ce_microbiology_st
         WHERE (event_id=omf_event->data[v_evtcnt].event_id)
        ;end delete
        DELETE  FROM omf_ce_susceptibility_st
         WHERE (event_id=omf_event->data[v_evtcnt].event_id)
        ;end delete
       ENDFOR
       DELETE  FROM omf_coding_st ocs
        WHERE ocs.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_charge_st ocs
        WHERE ocs.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_posted_charge_st ops
        WHERE ops.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_order_st oos
        WHERE oos.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_abstract_data_st oas
        WHERE oas.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_clinical_event_st oces
        WHERE oces.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_encntr_st oes
        WHERE oes.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_location_hist_st olhs
        WHERE olhs.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_encntr_type_hist_st oehs
        WHERE oehs.encntr_id=encntr_id
       ;end delete
       DELETE  FROM omf_med_service_hist_st omhs
        WHERE omhs.encntr_id=encntr_id
       ;end delete
      ENDIF
      IF (iidx=c_ccl_block_large)
       COMMIT
      ENDIF
    ENDFOR
    UPDATE  FROM omf_extract_batch b
     SET b.process_flag = c_process_complete
     WHERE b.extract_type_cd=fextracttypecd
      AND b.process_flag=c_process_inprocess
      AND b.active_ind=0
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 ENDWHILE
 SET iiterationidx = 0
 SET iqual = 1
 WHILE (iqual > 0)
   SET iiterationidx += 1
   UPDATE  FROM omf_extract_batch b
    SET b.process_flag = value(c_process_inprocess)
    WHERE b.extract_type_cd=fextracttypecd
     AND b.process_flag=value(c_process_inserted)
     AND b.active_ind=1
    WITH maxqual(b,value(c_ccl_block_large))
   ;end update
   SET iqual = curqual
   IF (iqual > 0)
    SELECT INTO "nl:"
     FROM omf_extract_batch b
     WHERE b.extract_type_cd=fextracttypecd
      AND b.process_flag=c_process_inprocess
      AND b.active_ind=1
     HEAD REPORT
      iencntridx = 0, stat = initrec(omf_encntr_st), stat = alterlist(omf_encntr_st->data,
       c_ccl_block_large)
     DETAIL
      iencntridx += 1, omf_encntr_st->data[iencntridx].encntr_id = cnvtreal(b.parent_entity_id),
      omf_encntr_st->data[iencntridx].person_id = cnvtreal(b.addl_parent_entity_id)
     FOOT REPORT
      stat = alterlist(omf_encntr_st->data,iencntridx)
     WITH nocounter
    ;end select
    IF (size(omf_encntr_st->data,5) > 0)
     IF (idebugind=1)
      SET stempstr = concat("   Iteration #",build(iiterationidx)," - Processing ",build(size(
         omf_encntr_st->data,5)," active encounters."))
      CALL omflogprint(stempstr)
     ENDIF
     CALL echo("Entering OMF_PM_ADT <include file mod 045>.....")
     SET c_omf_pm_adt = "OMF_PM_ADT.INC 045"
     SET v_encntr_ndx = size(omf_encntr_st->data,5)
     DECLARE v_deceased_chk = i4 WITH noconstant(0)
     DECLARE v_deceased_cnt = i4 WITH noconstant(0)
     DECLARE v_etc_cnt = i4 WITH noconstant(0)
     DECLARE ft_prsnl_name = c100
     FREE SET omf_temp
     RECORD omf_temp(
       1 data[*]
         2 month = i4
         2 zipcode = vc
         2 prim_person_org_reltn_id = f8
         2 sec_person_org_reltn_id = f8
         2 other_person_org_reltn_id = f8
         2 previous_nurse_unit_cd = f8
         2 visit_hour = i2
         2 disch_hour = i2
         2 array[*]
           3 updt_cnt = i2
     )
     SET stat = alterlist(omf_temp->data,v_encntr_ndx)
     FREE RECORD omf_ins_interface_error_request
     RECORD omf_ins_interface_error_request(
       1 segment = vc
       1 contributor_source_cd = f8
       1 contributor_system_str = vc
       1 contributor_system_cd = f8
       1 interface_dt_tm = vc
       1 total_rows = i4
       1 successful_rows = i4
       1 failed_rows = i4
       1 data[*]
         2 interface_seq = vc
         2 interface_col_desc = vc
         2 parent_entity_name = vc
         2 parent_entity_id = f8
         2 parent_entity_alias = vc
         2 parent_entity_alias_type = vc
         2 error_msg = vc
         2 data_str = vc
     )
     SET omf_ins_interface_error_request->segment = "OCF"
     SET omf_ins_interface_error_request->contributor_system_str = "ADT"
     SET omf_ins_interface_error_request->interface_dt_tm = format(cnvtdatetime(sysdate),
      "dd-mmm-yyyy hh:mm:ss;;d")
     IF (v_utc_on_ind=1)
      FREE SET tz_request
      RECORD tz_request(
        1 test = i2
        1 encntrs[*]
          2 encntr_id = f8
          2 transaction_dt_tm = q8
        1 facilities[*]
          2 loc_facility_cd = f8
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      FREE SET tz_reply
      RECORD tz_reply(
        1 encntrs_qual_cnt = i4
        1 encntrs[*]
          2 encntr_id = f8
          2 time_zone_indx = i4
          2 time_zone = vc
          2 transaction_dt_tm = q8
          2 check = i2
          2 status = i2
          2 loc_fac_cd = f8
        1 facilities_qual_cnt = i4
        1 facilities[*]
          2 loc_facility_cd = f8
          2 time_zone_indx = i4
          2 time_zone = vc
          2 status = i2
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      SELECT DISTINCT INTO "nl:"
       encntr_id = omf_encntr_st->data[d1.seq].encntr_id
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1)
       ORDER BY encntr_id
       HEAD REPORT
        ndx = 0
       DETAIL
        ndx += 1
        IF (mod(ndx,10)=1)
         stat = alterlist(tz_request->encntrs,(ndx+ 9))
        ENDIF
        tz_request->encntrs[ndx].encntr_id = omf_encntr_st->data[d1.seq].encntr_id
       FOOT REPORT
        stat = alterlist(tz_request->encntrs,ndx)
       WITH nocounter
      ;end select
      EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST","TZ_REQUEST"), replace("REPLY","TZ_REPLY")
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(size(tz_reply->encntrs,5))),
        (dummyt d2  WITH seq = value(v_encntr_ndx))
       PLAN (d1)
        JOIN (d2
        WHERE (tz_reply->encntrs[d1.seq].encntr_id=omf_encntr_st->data[d2.seq].encntr_id))
       DETAIL
        omf_encntr_st->data[d2.seq].time_zone = tz_reply->encntrs[d1.seq].time_zone, omf_encntr_st->
        data[d2.seq].time_zone_indx = tz_reply->encntrs[d1.seq].time_zone_indx, omf_encntr_st->data[
        d2.seq].time_zone_status = tz_reply->encntrs[d1.seq].status
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status=0))
       HEAD REPORT
        ndx = 0
       DETAIL
        ndx += 1
        IF (mod(ndx,10)=1)
         stat = alterlist(omf_ins_interface_error_request->data,(ndx+ 9))
        ENDIF
        omf_ins_interface_error_request->data[ndx].error_msg = concat("Encntr_ID: ",trim(cnvtstring(
           omf_encntr_st->data[d1.seq].encntr_id)),".  Time zone does not exist for the encounter's ",
         "facility.")
       FOOT REPORT
        stat = alterlist(omf_ins_interface_error_request->data,ndx)
       WITH nocounter
      ;end select
      IF (size(omf_ins_interface_error_request->data,5) > 0)
       EXECUTE omf_ins_interface_error  WITH replace("REQUEST","OMF_INS_INTERFACE_ERROR_REQUEST")
      ENDIF
     ELSE
      FOR (ndx = 1 TO v_encntr_ndx)
        SET omf_encntr_st->data[ndx].time_zone_status = 1
      ENDFOR
     ENDIF
     SELECT INTO "nl:"
      nomen_id = diag.nomenclature_id
      FROM diagnosis diag,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (diag
       WHERE (diag.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND ((diag.diag_type_cd=omf_get_cvl_for_dk(17,"ADMITTING")) OR (diag.diag_type_cd=
       omf_get_cvl_for_dk(17,"ADMIT")))
        AND diag.active_ind=1
        AND ((diag.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((diag.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
      DETAIL
       omf_encntr_st->data[d1.seq].icd9_admit_diag_nomen_id = nomen_id
      WITH nocounter
     ;end select
     IF ((reqinfo->updt_req=114001))
      IF (v_utc_on_ind=1)
       SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
       CALL uar_datesettimezone(tz)
      ENDIF
      SET omf_encntr_st->data[1].visit_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(request
         ->request.n_reg_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(request->request.n_reg_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d"))
      SET omf_encntr_st->data[1].admit_ind = 0
      SET omf_encntr_st->data[1].visit_ind = 0
      SET omf_encntr_st->data[1].disch_ind = 0
      SET omf_encntr_st->data[1].death_ind = 0
      IF (size(trim(omf_encntr_st->data[1].visit_dt_tm))=0)
       SET omf_encntr_st->data[1].visit_dt_nbr = - (1)
       SET omf_encntr_st->data[1].visit_min_nbr = - (1)
       SET omf_encntr_st->data[1].visit_ind = 0
      ELSE
       SET omf_encntr_st->data[1].visit_dt_nbr = cnvtdate(request->request.n_reg_dt_tm)
       SET omf_encntr_st->data[1].visit_min_nbr = (cnvtmin(request->request.n_reg_dt_tm,5)+ 1)
       SET omf_encntr_st->data[1].visit_ind = 1
       IF ((((request->request.n_encntr_type_class_cd=omf_prologue_cv->69_inpatient)) OR ((((request
       ->request.n_encntr_type_class_cd=omf_prologue_cv->69_skilled)) OR ((request->request.
       n_encntr_type_class_cd=omf_prologue_cv->69_observation))) )) )
        SET omf_encntr_st->data[1].admit_ind = 1
       ENDIF
      ENDIF
      SET omf_encntr_st->data[1].admit_src_cd = request->request.n_admit_src_cd
      SET omf_encntr_st->data[1].admit_type_cd = request->request.n_admit_type_cd
      SET omf_encntr_st->data[1].accommodation_cd = request->request.n_accom_cd
      SET omf_encntr_st->data[1].curr_pat_loc_bed_cd = request->request.n_loc_bed_cd
      SET omf_encntr_st->data[1].curr_pat_loc_room_cd = request->request.n_loc_room_cd
      SET omf_encntr_st->data[1].curr_pat_loc_nu_cd = request->request.n_loc_nurse_unit_cd
      SET omf_encntr_st->data[1].curr_pat_loc_bdg_cd = request->request.n_loc_building_cd
      SET omf_encntr_st->data[1].curr_pat_loc_fac_cd = request->request.n_loc_facility_cd
      SET omf_encntr_st->data[1].disch_disposition_cd = request->request.n_disch_disp_cd
      SET omf_encntr_st->data[1].disch_to_loc_cd = request->request.n_disch_to_loctn_cd
      SET omf_encntr_st->data[1].disch_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(request
         ->request.n_disch_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(request->request.n_disch_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d"))
      IF (size(trim(omf_encntr_st->data[1].disch_dt_tm))=0)
       SET omf_encntr_st->data[1].disch_dt_nbr = - (1)
       SET omf_encntr_st->data[1].disch_min_nbr = - (1)
      ELSE
       SET omf_encntr_st->data[1].disch_dt_nbr = cnvtdate(request->request.n_disch_dt_tm)
       SET omf_encntr_st->data[1].disch_min_nbr = (cnvtmin(request->request.n_disch_dt_tm,5)+ 1)
       SET omf_encntr_st->data[1].disch_ind = 1
      ENDIF
      SET omf_encntr_st->data[1].exp_pm_disch_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(
         request->request.n_est_depart_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(request->request.
        n_est_depart_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
      IF (size(trim(omf_encntr_st->data[1].exp_pm_disch_dt_tm))=0)
       SET omf_encntr_st->data[1].exp_pm_disch_dt_nbr = - (1)
       SET omf_encntr_st->data[1].exp_pm_disch_min_nbr = - (1)
      ELSE
       SET omf_encntr_st->data[1].exp_pm_disch_dt_nbr = cnvtdate(request->request.n_est_depart_dt_tm)
       SET omf_encntr_st->data[1].exp_pm_disch_min_nbr = (cnvtmin(request->request.n_est_depart_dt_tm,
        5)+ 1)
      ENDIF
      SET omf_encntr_st->data[1].encntr_type_cd = request->request.n_encntr_type_cd
      SET omf_encntr_st->data[1].encntr_type_class_cd = request->request.n_encntr_type_class_cd
      SET omf_encntr_st->data[1].fin_class_cd = request->request.n_fin_class_cd
      SET omf_encntr_st->data[1].med_serv_cd = request->request.n_med_service_cd
      SET omf_encntr_st->data[1].ambulatory_cond_cd = request->request.n_amb_cond_cd
      SET omf_encntr_st->data[1].reason_for_visit = request->request.n_reason_for_visit
      SET omf_encntr_st->data[1].birth_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(request
         ->request.n_birth_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(request->request.n_birth_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d"))
      IF (size(trim(omf_encntr_st->data[1].birth_dt_tm))=0)
       SET omf_encntr_st->data[1].birth_dt_nbr = - (1)
       SET omf_encntr_st->data[1].birth_min_nbr = - (1)
      ELSE
       SET omf_encntr_st->data[1].birth_dt_nbr = cnvtdate(request->request.n_birth_dt_tm)
       SET omf_encntr_st->data[1].birth_min_nbr = (cnvtmin(request->request.n_birth_dt_tm,5)+ 1)
      ENDIF
      SET omf_encntr_st->data[1].death_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(request
         ->request.n_deceased_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(request->request.
        n_deceased_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
      IF (size(trim(omf_encntr_st->data[1].death_dt_tm))=0)
       SET omf_encntr_st->data[1].death_dt_nbr = - (1)
       SET omf_encntr_st->data[1].death_min_nbr = - (1)
      ELSE
       SET omf_encntr_st->data[1].death_dt_nbr = cnvtdate(request->request.n_deceased_dt_tm)
       SET omf_encntr_st->data[1].death_min_nbr = (cnvtmin(request->request.n_deceased_dt_tm,5)+ 1)
      ENDIF
      SET omf_encntr_st->data[1].sex_cd = request->request.n_person_sex_cd
      SET omf_encntr_st->data[1].vip_cd = request->request.n_person_vip_cd
      SET omf_encntr_st->data[1].organization_id = request->request.n_organization_id
      SET omf_encntr_st->data[1].isolation_cd = request->request.n_isolation_cd
      SET omf_encntr_st->data[1].admit_7d_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_15d_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_30d_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_48d_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_48h_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_24h_ladmit_ind = 0
      SET omf_encntr_st->data[1].admit_72h_ladmit_ind = 0
      IF (size(trim(omf_encntr_st->data[1].birth_dt_tm,3)) > 0)
       SET omf_encntr_st->data[1].birth_date = concat(trim(cnvtstring(year(request->request.
           n_birth_dt_tm))),"-",format(cnvtstring(month(request->request.n_birth_dt_tm)),"##;p0"),"-",
        format(cnvtstring(day(request->request.n_birth_dt_tm)),"##;p0"))
      ELSE
       SET omf_encntr_st->data[1].birth_date = "-"
      ENDIF
      IF ((omf_encntr_st->data[1].visit_dt_nbr > 0))
       SET omf_temp->data[1].visit_hour = hour(request->request.n_reg_dt_tm)
      ENDIF
      IF ((omf_encntr_st->data[1].disch_dt_nbr > 0))
       SET omf_temp->data[1].disch_hour = hour(request->request.n_disch_dt_tm)
      ENDIF
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = value(size(omf_prologue_cv->19_data,5))),
        (dummyt d2  WITH seq = value(size(omf_encntr_st->data,5)))
       PLAN (d1)
        JOIN (d2
        WHERE (omf_encntr_st->data[1].disch_disposition_cd != 0)
         AND (omf_encntr_st->data[1].disch_disposition_cd=omf_prologue_cv->19_data[d1.seq].
        19_deceased)
         AND (omf_encntr_st->data[1].time_zone_status > 0))
       DETAIL
        omf_encntr_st->data[1].death_ind = 1
       WITH nocounter
      ;end select
      IF (curqual=0)
       IF ((omf_encntr_st->data[1].death_dt_nbr > 0))
        IF ((omf_encntr_st->data[1].disch_dt_nbr > 0))
         IF (cnvtdatetime(omf_encntr_st->data[1].death_dt_tm) BETWEEN cnvtdatetime(omf_encntr_st->
          data[1].visit_dt_tm) AND cnvtdatetime(omf_encntr_st->data[1].disch_dt_tm))
          SET omf_encntr_st->data[1].death_ind = 1
         ENDIF
        ELSE
         IF (cnvtdatetime(omf_encntr_st->data[1].death_dt_tm) BETWEEN cnvtdatetime(omf_encntr_st->
          data[1].visit_dt_tm) AND cnvtdatetime(sysdate))
          SET omf_encntr_st->data[1].death_ind = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF ((((omf_encntr_st->data[1].death_dt_nbr > 0)) OR (curqual > 0)) )
       IF ((omf_encntr_st->data[1].death_ind=1)
        AND (omf_encntr_st->data[1].death_dt_nbr > 0))
        SET death_24h_visit = (datetimediff(cnvtdatetime(omf_encntr_st->data[1].death_dt_tm),
         cnvtdatetime(omf_encntr_st->data[1].visit_dt_tm)) * 24)
        IF (death_24h_visit < 24)
         SET omf_encntr_st->data[1].death_24h_visit_ind = 1
        ELSE
         SET omf_encntr_st->data[1].death_24h_visit_ind = 0
        ENDIF
       ELSEIF ((omf_encntr_st->data[1].death_ind=1)
        AND (omf_encntr_st->data[1].death_dt_nbr IN (0, - (1))))
        SET omf_encntr_st->data[1].death_ind = 1
       ELSE
        SET omf_encntr_st->data[1].death_ind = 0
       ENDIF
      ELSE
       SET omf_encntr_st->data[1].death_ind = 0
      ENDIF
      IF (size(trim(omf_encntr_st->data[1].birth_dt_tm)) > 0
       AND (omf_encntr_st->data[1].visit_dt_nbr > 0))
       SET omf_encntr_st->data[1].age_days = floor(datetimediff(cnvtdatetime(omf_encntr_st->data[1].
          visit_dt_tm),cnvtdatetime(omf_encntr_st->data[1].birth_dt_tm)))
       SET omf_encntr_st->data[1].age_years = floor((datetimediff(cnvtdatetime(omf_encntr_st->data[1]
          .visit_dt_tm),cnvtdatetime(omf_encntr_st->data[1].birth_dt_tm))/ 365.25))
      ELSE
       SET omf_encntr_st->data[1].age_years = - (1)
      ENDIF
      SELECT INTO "nl:"
       e.triage_cd, e.service_category_cd, e.encntr_class_cd
       FROM encounter e,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (e
        WHERE (e.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
       DETAIL
        omf_encntr_st->data[d1.seq].triage_cd = e.triage_cd, omf_encntr_st->data[d1.seq].
        service_category_cd = e.service_category_cd, omf_encntr_st->data[d1.seq].encntr_class_cd = e
        .encntr_class_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       race_cd = p.race_cd, ethnic_cd = p.ethnic_grp_cd, lang_cd = p.language_cd,
       marital_type_cd = p.marital_type_cd, religion_cd = p.religion_cd
       FROM person p,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (p
        WHERE (p.person_id=omf_encntr_st->data[d1.seq].person_id)
         AND p.active_ind=1)
       DETAIL
        omf_encntr_st->data[d1.seq].race_cd = race_cd, omf_encntr_st->data[d1.seq].ethnic_grp_cd =
        ethnic_cd, omf_encntr_st->data[d1.seq].language_cd = lang_cd,
        omf_encntr_st->data[d1.seq].marital_status_cd = marital_type_cd, omf_encntr_st->data[d1.seq].
        religion_cd = religion_cd
       WITH nocounter
      ;end select
     ELSE
      IF (v_utc_on_ind=1)
       SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
       CALL uar_datesettimezone(tz)
      ENDIF
      SELECT INTO "nl:"
       visit_dt_tm = e.reg_dt_tm, admit_src_cd = e.admit_src_cd, admit_type_cd = e.admit_type_cd,
       bed_cd = e.loc_bed_cd, room_cd = e.loc_room_cd, nu_cd = e.loc_nurse_unit_cd,
       bldg_cd = e.loc_building_cd, fac_cd = e.loc_facility_cd, disch_disp_cd = e
       .disch_disposition_cd,
       disch_to_loc_cd = e.disch_to_loctn_cd, disch_dt_tm = e.disch_dt_tm, exp_pm_disch_dt_tm = e
       .est_depart_dt_tm,
       encntr_type_cd = e.encntr_type_cd, encntr_type_class_cd = e.encntr_type_class_cd, fin_class_cd
        = e.financial_class_cd,
       med_service_cd = e.med_service_cd, ambulatory_cond_cd = e.ambulatory_cond_cd, encntr_class_cd
        = e.encntr_class_cd,
       accommodation_cd = e.accommodation_cd, reason_for_visit = e.reason_for_visit, triage_cd = e
       .triage_cd,
       serv_cat_cd = e.service_category_cd, isolation_cd = e.isolation_cd, organization_id = e
       .organization_id
       FROM encounter e,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (e
        WHERE (e.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
         AND e.active_ind=1)
       DETAIL
        omf_encntr_st->data[d1.seq].visit_ind = 0, omf_encntr_st->data[d1.seq].admit_ind = 0,
        omf_encntr_st->data[d1.seq].disch_ind = 0,
        omf_encntr_st->data[d1.seq].visit_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(
           visit_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(visit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].visit_dt_tm)="")
         omf_encntr_st->data[d1.seq].visit_dt_nbr = - (1), omf_encntr_st->data[d1.seq].visit_min_nbr
          = - (1), omf_encntr_st->data[d1.seq].visit_ind = 0
        ELSE
         omf_encntr_st->data[d1.seq].visit_dt_nbr = cnvtdate(visit_dt_tm), omf_encntr_st->data[d1.seq
         ].visit_min_nbr = (cnvtmin(visit_dt_tm,5)+ 1), omf_encntr_st->data[d1.seq].visit_ind = 1
         IF ((((encntr_type_class_cd=omf_prologue_cv->69_inpatient)) OR ((((encntr_type_class_cd=
         omf_prologue_cv->69_skilled)) OR ((encntr_type_class_cd=omf_prologue_cv->69_observation)))
         )) )
          omf_encntr_st->data[d1.seq].admit_ind = 1
         ENDIF
        ENDIF
        omf_encntr_st->data[d1.seq].admit_src_cd = admit_src_cd, omf_encntr_st->data[d1.seq].
        admit_type_cd = admit_type_cd, omf_encntr_st->data[d1.seq].curr_pat_loc_bed_cd = bed_cd,
        omf_encntr_st->data[d1.seq].curr_pat_loc_room_cd = room_cd, omf_encntr_st->data[d1.seq].
        curr_pat_loc_nu_cd = nu_cd, omf_encntr_st->data[d1.seq].curr_pat_loc_bdg_cd = bldg_cd,
        omf_encntr_st->data[d1.seq].curr_pat_loc_fac_cd = fac_cd, omf_encntr_st->data[d1.seq].
        disch_disposition_cd = disch_disp_cd, omf_encntr_st->data[d1.seq].disch_to_loc_cd =
        disch_to_loc_cd,
        omf_encntr_st->data[d1.seq].disch_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(
           disch_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].disch_dt_tm)="")
         omf_encntr_st->data[d1.seq].disch_dt_nbr = - (1), omf_encntr_st->data[d1.seq].disch_min_nbr
          = - (1), omf_encntr_st->data[d1.seq].disch_ind = 0
        ELSE
         omf_encntr_st->data[d1.seq].disch_dt_nbr = cnvtdate(disch_dt_tm), omf_encntr_st->data[d1.seq
         ].disch_min_nbr = (cnvtmin(disch_dt_tm,5)+ 1), omf_encntr_st->data[d1.seq].disch_ind = 1
        ENDIF
        omf_encntr_st->data[d1.seq].exp_pm_disch_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(exp_pm_disch_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(exp_pm_disch_dt_tm,
          "dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].exp_pm_disch_dt_tm)="")
         omf_encntr_st->data[d1.seq].exp_pm_disch_dt_nbr = - (1), omf_encntr_st->data[d1.seq].
         exp_pm_disch_min_nbr = - (1)
        ELSE
         omf_encntr_st->data[d1.seq].exp_pm_disch_dt_nbr = cnvtdate(exp_pm_disch_dt_tm),
         omf_encntr_st->data[d1.seq].exp_pm_disch_min_nbr = (cnvtmin(exp_pm_disch_dt_tm,5)+ 1)
        ENDIF
        omf_encntr_st->data[d1.seq].encntr_type_cd = encntr_type_cd, omf_encntr_st->data[d1.seq].
        encntr_type_class_cd = encntr_type_class_cd, omf_encntr_st->data[d1.seq].fin_class_cd =
        fin_class_cd,
        omf_encntr_st->data[d1.seq].med_serv_cd = med_service_cd, omf_encntr_st->data[d1.seq].
        ambulatory_cond_cd = ambulatory_cond_cd, omf_encntr_st->data[d1.seq].encntr_class_cd =
        encntr_class_cd,
        omf_encntr_st->data[d1.seq].reason_for_visit = reason_for_visit, omf_encntr_st->data[d1.seq].
        accommodation_cd = accommodation_cd, omf_encntr_st->data[d1.seq].triage_cd = triage_cd,
        omf_encntr_st->data[d1.seq].service_category_cd = serv_cat_cd, omf_encntr_st->data[d1.seq].
        organization_id = organization_id, omf_encntr_st->data[d1.seq].isolation_cd = isolation_cd,
        omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
        admit_15d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_30d_ladmit_ind = 0,
        omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
        admit_48h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_24h_ladmit_ind = 0,
        omf_encntr_st->data[1].admit_72h_ladmit_ind = 0
        IF ((omf_encntr_st->data[d1.seq].visit_dt_nbr > 0))
         omf_temp->data[d1.seq].visit_hour = hour(visit_dt_tm)
        ENDIF
        IF ((omf_encntr_st->data[d1.seq].disch_dt_nbr > 0))
         omf_temp->data[d1.seq].disch_hour = hour(disch_dt_tm)
        ENDIF
        IF (v_utc_on_ind=1
         AND ((d1.seq+ 1) <= v_encntr_ndx))
         v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone
           ),char(0)), stat = uar_datesettimezone(tz)
        ENDIF
       WITH nocounter
      ;end select
      IF (v_utc_on_ind=1)
       SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
       CALL uar_datesettimezone(tz)
      ENDIF
      SELECT INTO "nl:"
       birth_dt_tm = p.birth_dt_tm, null_ind = nullind(p.birth_dt_tm), death_dt_tm = p.deceased_dt_tm,
       race_cd = p.race_cd, ethnic_cd = p.ethnic_grp_cd, sex_cd = p.sex_cd,
       lang_cd = p.language_cd, marital_type_cd = p.marital_type_cd, vip_cd = p.vip_cd,
       religion_cd = p.religion_cd
       FROM person p,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (p
        WHERE (p.person_id=omf_encntr_st->data[d1.seq].person_id)
         AND p.active_ind=1)
       DETAIL
        omf_encntr_st->data[d1.seq].death_ind = 0, omf_encntr_st->data[d1.seq].birth_dt_tm = evaluate
        (v_utc_on_ind,1,format(cnvtdatetimeutc(birth_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(
          birth_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].birth_dt_tm)="")
         omf_encntr_st->data[d1.seq].birth_dt_nbr = - (1), omf_encntr_st->data[d1.seq].birth_min_nbr
          = - (1)
        ELSE
         omf_encntr_st->data[d1.seq].birth_dt_nbr = cnvtdate(birth_dt_tm), omf_encntr_st->data[d1.seq
         ].birth_min_nbr = (cnvtmin(birth_dt_tm,5)+ 1)
        ENDIF
        omf_encntr_st->data[d1.seq].death_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(
           death_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(death_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].death_dt_tm)="")
         omf_encntr_st->data[d1.seq].death_dt_nbr = - (1), omf_encntr_st->data[d1.seq].death_min_nbr
          = - (1)
        ELSE
         omf_encntr_st->data[d1.seq].death_dt_nbr = cnvtdate(death_dt_tm), omf_encntr_st->data[d1.seq
         ].death_min_nbr = (cnvtmin(death_dt_tm,5)+ 1)
        ENDIF
        omf_encntr_st->data[d1.seq].race_cd = race_cd, omf_encntr_st->data[d1.seq].ethnic_grp_cd =
        ethnic_cd, omf_encntr_st->data[d1.seq].sex_cd = sex_cd,
        omf_encntr_st->data[d1.seq].language_cd = lang_cd, omf_encntr_st->data[d1.seq].
        marital_status_cd = marital_type_cd, omf_encntr_st->data[d1.seq].vip_cd = vip_cd,
        omf_encntr_st->data[d1.seq].religion_cd = religion_cd, omf_encntr_st->data[d1.seq].birth_date
         = concat(trim(cnvtstring(year(birth_dt_tm))),"-",format(cnvtstring(month(birth_dt_tm)),
          "##;p0"),"-",format(cnvtstring(day(birth_dt_tm)),"##;p0")), v_deceased_chk = 0
        IF ((omf_encntr_st->data[d1.seq].disch_disposition_cd != 0))
         FOR (v_deceased_cnt = 1 TO size(omf_prologue_cv->19_data,5))
           IF ((omf_encntr_st->data[d1.seq].disch_disposition_cd=omf_prologue_cv->19_data[
           v_deceased_cnt].19_deceased))
            v_deceased_chk = 1
           ENDIF
         ENDFOR
        ENDIF
        IF (v_deceased_chk=1)
         omf_encntr_st->data[d1.seq].death_ind = 1
        ELSE
         IF ((omf_encntr_st->data[d1.seq].death_dt_nbr > 0))
          IF ((omf_encntr_st->data[d1.seq].disch_dt_nbr > 0))
           IF (death_dt_tm BETWEEN cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) AND
           cnvtdatetime(omf_encntr_st->data[d1.seq].disch_dt_tm))
            omf_encntr_st->data[d1.seq].death_ind = 1
           ENDIF
          ELSE
           IF (death_dt_tm BETWEEN cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) AND
           cnvtdatetime(sysdate))
            omf_encntr_st->data[d1.seq].death_ind = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF ((((omf_encntr_st->data[d1.seq].death_dt_nbr > 0)) OR (v_deceased_chk=1)) )
         IF ((omf_encntr_st->data[d1.seq].death_ind=1)
          AND (omf_encntr_st->data[d1.seq].death_dt_nbr > 0))
          death_24h_visit = (datetimediff(cnvtdatetime(omf_encntr_st->data[d1.seq].death_dt_tm),
           cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm)) * 24)
          IF (death_24h_visit < 24)
           omf_encntr_st->data[d1.seq].death_24h_visit_ind = 1
          ELSE
           omf_encntr_st->data[d1.seq].death_24h_visit_ind = 0
          ENDIF
         ELSEIF ((omf_encntr_st->data[d1.seq].death_ind=1)
          AND (omf_encntr_st->data[d1.seq].death_dt_nbr IN (0, - (1))))
          omf_encntr_st->data[d1.seq].death_ind = 1
         ELSE
          omf_encntr_st->data[d1.seq].death_ind = 0
         ENDIF
        ELSE
         omf_encntr_st->data[d1.seq].death_ind = 0
        ENDIF
        IF (null_ind=0
         AND (omf_encntr_st->data[d1.seq].visit_dt_nbr > 0))
         omf_encntr_st->data[d1.seq].age_days = floor(datetimediff(cnvtdatetime(omf_encntr_st->data[
            d1.seq].visit_dt_tm),birth_dt_tm)), omf_encntr_st->data[d1.seq].age_years = floor((
          datetimediff(cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm),birth_dt_tm)/ 365.25))
        ELSE
         omf_encntr_st->data[d1.seq].age_years = - (1)
        ENDIF
        IF (v_utc_on_ind=1
         AND ((d1.seq+ 1) <= v_encntr_ndx))
         v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone
           ),char(0)), stat = uar_datesettimezone(tz)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl:"
      e.encntr_id
      FROM encounter e,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (e
       WHERE (omf_encntr_st->data[d1.seq].visit_dt_nbr > 0)
        AND (e.person_id=omf_encntr_st->data[d1.seq].person_id)
        AND ((e.active_ind+ 0)=1)
        AND ((e.disch_dt_tm+ 0)=
       (SELECT
        max(e2.disch_dt_tm)
        FROM encounter e2
        WHERE (e2.person_id=omf_encntr_st->data[d1.seq].person_id)
         AND e2.reg_dt_tm < cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm)
         AND e2.active_ind=1)))
      DETAIL
       omf_encntr_st->data[d1.seq].prev_encntr_id = e.encntr_id
      WITH nocounter
     ;end select
     IF (size(omf_etc_list->data,5)=0)
      SET v_etccnt = 0
      SELECT INTO "nl:"
       cv = cv.code_value
       FROM code_value cv
       WHERE cv.code_set=69
        AND cv.active_ind=1
        AND cv.cdf_meaning > " "
       DETAIL
        v_etccnt += 1
        IF (mod(v_etccnt,10)=1)
         stat = alterlist(omf_etc_list->data,(v_etccnt+ 9))
        ENDIF
        omf_etc_list->data[v_etccnt].encntr_type_class_cd = cv
       FOOT REPORT
        stat = alterlist(omf_etc_list->data,v_etccnt)
       WITH nocounter
      ;end select
      SET v_etcnt = 0
      SELECT INTO "nl:"
       pcv = cv.parent_code_value, cv = cv.child_code_value
       FROM code_value_group cv,
        (dummyt d1  WITH seq = value(size(omf_etc_list->data,5)))
       PLAN (d1)
        JOIN (cv
        WHERE (cv.parent_code_value=omf_etc_list->data[d1.seq].encntr_type_class_cd))
       ORDER BY pcv
       HEAD pcv
        v_etcnt = 0
       DETAIL
        v_etcnt += 1, stat = alterlist(omf_etc_list->data[d1.seq].encntr_type,v_etcnt), omf_etc_list
        ->data[d1.seq].encntr_type[v_etcnt].encntr_type_cd = cv
       FOOT  pcv
        IF ((v_etcnt > omf_etc_list->max_encntr_type_cnt))
         omf_etc_list->max_encntr_type_cnt = v_etcnt
        ENDIF
        omf_etc_list->data[d1.seq].encntr_type_cnt = v_etcnt
       WITH nocounter
      ;end select
     ENDIF
     SET v_etccnt = size(omf_etc_list->data,5)
     SELECT INTO "nl:"
      readmit_tm = datetimediff(elh.transaction_dt_tm,e.disch_dt_tm), readmit_cmp = datetimecmp(elh
       .transaction_dt_tm,e.disch_dt_tm)
      FROM encntr_loc_hist elh,
       encounter e,
       (dummyt d1  WITH seq = value(v_etccnt)),
       (dummyt d2  WITH seq = value(omf_etc_list->max_encntr_type_cnt)),
       (dummyt d3  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_etc_list->data[d1.seq].encntr_type_class_cd=omf_prologue_cv->69_emergency))
       JOIN (d2
       WHERE (d2.seq <= omf_etc_list->data[d1.seq].encntr_type_cnt))
       JOIN (d3
       WHERE (omf_encntr_st->data[d3.seq].time_zone_status > 0))
       JOIN (elh
       WHERE ((elh.encntr_type_cd+ 0)=omf_etc_list->data[d1.seq].encntr_type[d2.seq].encntr_type_cd)
        AND (elh.transaction_dt_tm=
       (SELECT
        min(elh2.transaction_dt_tm)
        FROM encntr_loc_hist elh2
        WHERE elh.encntr_id=elh2.encntr_id))
        AND (elh.encntr_id=omf_encntr_st->data[d3.seq].encntr_id))
       JOIN (e
       WHERE (e.encntr_id=(elh.encntr_id+ 0))
        AND ((e.encntr_type_class_cd+ 0)=omf_prologue_cv->69_emergency)
        AND (e.disch_dt_tm=
       (SELECT
        max(e2.disch_dt_tm)
        FROM encounter e2
        WHERE (e2.person_id=omf_encntr_st->data[d3.seq].person_id)
         AND ((e2.encntr_type_class_cd+ 0)=omf_prologue_cv->69_emergency)
         AND e2.reg_dt_tm < cnvtdatetime(omf_encntr_st->data[d3.seq].visit_dt_tm))))
      DETAIL
       IF (readmit_tm <= 1.0)
        omf_encntr_st->data[d3.seq].return_ed_24h_ind = 1, omf_encntr_st->data[d3.seq].
        return_ed_48h_ind = 1, omf_encntr_st->data[d3.seq].return_ed_72h_ind = 1,
        omf_encntr_st->data[d3.seq].return_ed_24h_48h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_49h_72h_ind = 0, omf_encntr_st->data[d3.seq].return_ed_gt_72h_ind = 0
       ELSEIF (readmit_tm <= 2.0)
        omf_encntr_st->data[d3.seq].return_ed_24h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_48h_ind = 1, omf_encntr_st->data[d3.seq].return_ed_72h_ind = 1,
        omf_encntr_st->data[d3.seq].return_ed_24h_48h_ind = 1, omf_encntr_st->data[d3.seq].
        return_ed_49h_72h_ind = 0, omf_encntr_st->data[d3.seq].return_ed_gt_72h_ind = 0
       ELSEIF (readmit_tm <= 3.0)
        omf_encntr_st->data[d3.seq].return_ed_24h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_48h_ind = 0, omf_encntr_st->data[d3.seq].return_ed_72h_ind = 1,
        omf_encntr_st->data[d3.seq].return_ed_24h_48h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_49h_72h_ind = 1, omf_encntr_st->data[d3.seq].return_ed_gt_72h_ind = 0
       ELSE
        omf_encntr_st->data[d3.seq].return_ed_24h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_48h_ind = 0, omf_encntr_st->data[d3.seq].return_ed_72h_ind = 0,
        omf_encntr_st->data[d3.seq].return_ed_24h_48h_ind = 0, omf_encntr_st->data[d3.seq].
        return_ed_49h_72h_ind = 0, omf_encntr_st->data[d3.seq].return_ed_gt_72h_ind = 1
       ENDIF
       omf_encntr_st->data[d3.seq].days_next_ed_visit = readmit_cmp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      prsnl_id = epr.prsnl_person_id, free_text_cd = epr.free_text_cd, ft_prsnl_name = epr
      .ft_prsnl_name,
      prsnl_key = concat(trim(cnvtstring(epr.prsnl_person_id),3),trim(epr.ft_prsnl_name,3)), epr_cd
       = epr.encntr_prsnl_r_cd
      FROM encntr_prsnl_reltn epr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (epr
       WHERE (epr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND epr.encntr_prsnl_r_cd IN (omf_prologue_cv->333_admitdoc, omf_prologue_cv->333_attenddoc,
       omf_prologue_cv->333_referdoc)
        AND epr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00")
        AND epr.active_ind=1)
      DETAIL
       IF ((epr_cd=omf_prologue_cv->333_admitdoc))
        IF ((free_text_cd=omf_prologue_cv->382_ft_brief))
         omf_encntr_st->data[d1.seq].admit_phys_ft_name = ft_prsnl_name
        ELSE
         omf_encntr_st->data[d1.seq].admit_phys_id = prsnl_id
        ENDIF
        omf_encntr_st->data[d1.seq].admit_phys_key = prsnl_key
       ELSEIF ((epr_cd=omf_prologue_cv->333_attenddoc))
        IF ((free_text_cd=omf_prologue_cv->382_ft_brief))
         omf_encntr_st->data[d1.seq].att_phys_ft_name = ft_prsnl_name
        ELSE
         omf_encntr_st->data[d1.seq].att_phys_id = prsnl_id
        ENDIF
        omf_encntr_st->data[d1.seq].att_phys_key = prsnl_key
       ELSEIF ((epr_cd=omf_prologue_cv->333_referdoc))
        IF ((free_text_cd=omf_prologue_cv->382_ft_brief))
         omf_encntr_st->data[d1.seq].ref_phys_ft_name = ft_prsnl_name
        ELSE
         omf_encntr_st->data[d1.seq].ref_phys_id = prsnl_id
        ENDIF
        omf_encntr_st->data[d1.seq].ref_phys_key = prsnl_key
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      prsnl_id = ppr.prsnl_person_id, free_text_cd = ppr.free_text_cd, ft_prsnl_name = ppr
      .ft_prsnl_name,
      prsnl_key = concat(trim(cnvtstring(ppr.prsnl_person_id),3),trim(ppr.ft_prsnl_name,3))
      FROM person_prsnl_reltn ppr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (ppr
       WHERE (ppr.person_id=omf_encntr_st->data[d1.seq].person_id)
        AND (ppr.person_prsnl_r_cd=omf_prologue_cv->331_pcp)
        AND ppr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00")
        AND ppr.active_ind=1)
      DETAIL
       IF ((free_text_cd=omf_prologue_cv->382_ft_brief))
        omf_encntr_st->data[d1.seq].pcp_phys_ft_name = ft_prsnl_name
       ELSE
        omf_encntr_st->data[d1.seq].pcp_phys_id = prsnl_id
       ENDIF
       omf_encntr_st->data[d1.seq].pcp_phys_key = prsnl_key
      WITH nocounter
     ;end select
     SELECT INTO "nl"
      p.position_cd
      FROM prsnl p,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (p
       WHERE (((p.person_id=omf_encntr_st->data[d1.seq].admit_phys_id)) OR ((((p.person_id=
       omf_encntr_st->data[d1.seq].att_phys_id)) OR ((((p.person_id=omf_encntr_st->data[d1.seq].
       ref_phys_id)) OR ((p.person_id=omf_encntr_st->data[d1.seq].pcp_phys_id))) )) ))
        AND p.person_id > 0.0
        AND p.active_ind=1)
      DETAIL
       IF ((p.person_id=omf_encntr_st->data[d1.seq].admit_phys_id))
        omf_encntr_st->data[d1.seq].admit_phys_position_cd = p.position_cd
       ELSEIF ((p.person_id=omf_encntr_st->data[d1.seq].att_phys_id))
        omf_encntr_st->data[d1.seq].attend_phys_position_cd = p.position_cd
       ELSEIF ((p.person_id=omf_encntr_st->data[d1.seq].ref_phys_id))
        omf_encntr_st->data[d1.seq].ref_phys_position_cd = p.position_cd
       ELSEIF ((p.person_id=omf_encntr_st->data[d1.seq].pcp_phys_id))
        omf_encntr_st->data[d1.seq].pcp_phys_position_cd = p.position_cd
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      encntr = epr.encntr_id, person = epr.person_id, assignben = epr.assign_benefits_cd,
      memnum = epr.member_nbr, priority = epr.priority_seq, h_plan = epr.health_plan_id,
      coord = epr.coord_benefits_cd, person_org_reltn_id = epr.person_org_reltn_id
      FROM encntr_plan_reltn epr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (epr
       WHERE (epr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND epr.priority_seq IN (1, 2, 3)
        AND epr.active_ind=1
        AND ((epr.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((epr.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate)))
      DETAIL
       omf_encntr_st->data[d1.seq].coordination_of_benefits_cd = coord
       IF (epr.priority_seq=1)
        omf_encntr_st->data[d1.seq].prim_ins_assign_benefits_cd = assignben, omf_encntr_st->data[d1
        .seq].prim_ins_person_id = person, omf_encntr_st->data[d1.seq].prim_health_plan_id = h_plan,
        omf_temp->data[d1.seq].prim_person_org_reltn_id = person_org_reltn_id
       ENDIF
       IF (epr.priority_seq=2)
        omf_encntr_st->data[d1.seq].sec_ins_assign_benefits_cd = assignben, omf_encntr_st->data[d1
        .seq].sec_ins_person_id = person, omf_encntr_st->data[d1.seq].sec_health_plan_id = h_plan,
        omf_temp->data[d1.seq].sec_person_org_reltn_id = person_org_reltn_id
       ENDIF
       IF (epr.priority_seq=3)
        omf_encntr_st->data[d1.seq].other_ins_assign_benefits_cd = assignben, omf_encntr_st->data[d1
        .seq].other_ins_person_id = person, omf_encntr_st->data[d1.seq].other_health_plan_id = h_plan,
        omf_temp->data[d1.seq].other_person_org_reltn_id = person_org_reltn_id
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      org = por.organization_id, reltn_id = por.person_org_reltn_id
      FROM person_org_reltn por,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (por
       WHERE por.person_org_reltn_id IN (omf_temp->data[d1.seq].prim_person_org_reltn_id, omf_temp->
       data[d1.seq].sec_person_org_reltn_id, omf_temp->data[d1.seq].other_person_org_reltn_id)
        AND (por.person_org_reltn_cd=omf_prologue_cv->338_insurance_co)
        AND por.active_ind=1)
      DETAIL
       CASE (reltn_id)
        OF omf_temp->data[d1.seq].prim_person_org_reltn_id:
         omf_encntr_st->data[d1.seq].prim_ins_organization_id = org
        OF omf_temp->data[d1.seq].sec_person_org_reltn_id:
         omf_encntr_st->data[d1.seq].sec_ins_organization_id = org
        OF omf_temp->data[d1.seq].other_person_org_reltn_id:
         omf_encntr_st->data[d1.seq].other_ins_organization_id = org
       ENDCASE
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      opri = opr.org_plan_reltn_id, org = opr.organization_id, hp = opr.health_plan_id
      FROM org_plan_reltn opr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (opr
       WHERE opr.organization_id IN (omf_encntr_st->data[d1.seq].other_ins_organization_id,
       omf_encntr_st->data[d1.seq].prim_ins_organization_id, omf_encntr_st->data[d1.seq].
       sec_ins_organization_id)
        AND ((opr.health_plan_id+ 0) IN (omf_encntr_st->data[d1.seq].other_health_plan_id,
       omf_encntr_st->data[d1.seq].prim_health_plan_id, omf_encntr_st->data[d1.seq].
       sec_health_plan_id))
        AND opr.active_ind=1)
      DETAIL
       IF ((org=omf_encntr_st->data[d1.seq].prim_ins_organization_id)
        AND (hp=omf_encntr_st->data[d1.seq].prim_health_plan_id))
        omf_encntr_st->data[d1.seq].prim_org_plan_reltn_id = opri
       ELSEIF ((org=omf_encntr_st->data[d1.seq].sec_ins_organization_id)
        AND (hp=omf_encntr_st->data[d1.seq].sec_health_plan_id))
        omf_encntr_st->data[d1.seq].sec_org_plan_reltn_id = opri
       ELSEIF ((org=omf_encntr_st->data[d1.seq].other_ins_organization_id)
        AND (hp=omf_encntr_st->data[d1.seq].other_health_plan_id))
        omf_encntr_st->data[d1.seq].other_org_plan_reltn_id = opri
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      org = por.organization_id, pid = por.person_id
      FROM person_org_reltn por,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (por
       WHERE por.person_id IN (omf_encntr_st->data[d1.seq].other_ins_person_id, omf_encntr_st->data[
       d1.seq].prim_ins_person_id, omf_encntr_st->data[d1.seq].sec_ins_person_id)
        AND (por.person_org_reltn_cd=omf_prologue_cv->338_employer)
        AND por.active_ind=1
        AND por.priority_seq=1)
      DETAIL
       CASE (pid)
        OF omf_encntr_st->data[d1.seq].prim_ins_person_id:
         omf_encntr_st->data[d1.seq].prim_emp_organization_id = org
        OF omf_encntr_st->data[d1.seq].sec_ins_person_id:
         omf_encntr_st->data[d1.seq].sec_emp_organization_id = org
        OF omf_encntr_st->data[d1.seq].other_ins_person_id:
         omf_encntr_st->data[d1.seq].other_emp_organization_id = org
       ENDCASE
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      org = por.organization_id
      FROM person_org_reltn por,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (por
       WHERE (por.person_id=omf_encntr_st->data[d1.seq].person_id)
        AND (por.person_org_reltn_cd=omf_prologue_cv->338_employer)
        AND por.active_ind=1
        AND por.priority_seq=1)
      DETAIL
       omf_encntr_st->data[d1.seq].emp_organization_id = org
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      birth = p.birth_dt_tm, birth_tz = p.birth_tz, pid = p.person_id
      FROM person p,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (p
       WHERE p.person_id IN (omf_encntr_st->data[d1.seq].other_ins_person_id, omf_encntr_st->data[d1
       .seq].prim_ins_person_id, omf_encntr_st->data[d1.seq].sec_ins_person_id)
        AND p.active_ind=1)
      DETAIL
       CASE (pid)
        OF omf_encntr_st->data[d1.seq].prim_ins_person_id:
         omf_encntr_st->data[d1.seq].prim_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,format(
           cnvtdatetimeutc(birth,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(birth,"dd-mmm-yyyy hh:mm:ss;;d"
           )),
         IF (trim(omf_encntr_st->data[d1.seq].prim_ins_birth_dt_tm)="")
          omf_encntr_st->data[d1.seq].prim_ins_birth_tz = 0, omf_encntr_st->data[d1.seq].
          prim_ins_birth_dt_nbr = - (1), omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr = - (1)
         ELSE
          omf_encntr_st->data[d1.seq].prim_ins_birth_tz = birth_tz, omf_encntr_st->data[d1.seq].
          prim_ins_birth_dt_nbr = cnvtdate(birth), omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr
           = (cnvtmin(birth,5)+ 1)
         ENDIF
        OF omf_encntr_st->data[d1.seq].sec_ins_person_id:
         omf_encntr_st->data[d1.seq].sec_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,format(
           cnvtdatetimeutc(birth,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(birth,"dd-mmm-yyyy hh:mm:ss;;d"
           )),
         IF (trim(omf_encntr_st->data[d1.seq].sec_ins_birth_dt_tm)="")
          omf_encntr_st->data[d1.seq].sec_ins_birth_tz = 0, omf_encntr_st->data[d1.seq].
          sec_ins_birth_dt_nbr = - (1), omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr = - (1)
         ELSE
          omf_encntr_st->data[d1.seq].sec_ins_birth_tz = birth_tz, omf_encntr_st->data[d1.seq].
          sec_ins_birth_dt_nbr = cnvtdate(birth), omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr
           = (cnvtmin(birth,5)+ 1)
         ENDIF
        OF omf_encntr_st->data[d1.seq].other_ins_person_id:
         omf_encntr_st->data[d1.seq].other_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,format(
           cnvtdatetimeutc(birth,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(birth,"dd-mmm-yyyy hh:mm:ss;;d"
           )),
         IF (trim(omf_encntr_st->data[d1.seq].other_ins_birth_dt_tm)="")
          omf_encntr_st->data[d1.seq].other_ins_birth_tz = 0, omf_encntr_st->data[d1.seq].
          other_ins_birth_dt_nbr = - (1), omf_encntr_st->data[d1.seq].other_ins_birth_min_nbr = - (1)
         ELSE
          omf_encntr_st->data[d1.seq].other_ins_birth_tz = birth_tz, omf_encntr_st->data[d1.seq].
          other_ins_birth_dt_nbr = cnvtdate(birth), omf_encntr_st->data[d1.seq].
          other_ins_birth_min_nbr = (cnvtmin(birth,5)+ 1)
         ENDIF
       ENDCASE
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      reltn = eppr.person_reltn_cd, pid = eppr.related_person_id
      FROM encntr_person_reltn eppr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (eppr
       WHERE (eppr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND eppr.active_ind=1)
      DETAIL
       IF ((omf_encntr_st->data[d1.seq].prim_ins_person_id > 0)
        AND (omf_encntr_st->data[d1.seq].prim_ins_person_id=pid))
        omf_encntr_st->data[d1.seq].prim_ins_person_reltn_cd = reltn
       ENDIF
       IF ((omf_encntr_st->data[d1.seq].sec_ins_person_id > 0)
        AND (omf_encntr_st->data[d1.seq].sec_ins_person_id=pid))
        omf_encntr_st->data[d1.seq].sec_ins_person_reltn_cd = reltn
       ENDIF
       IF ((omf_encntr_st->data[d1.seq].other_ins_person_id > 0)
        AND (omf_encntr_st->data[d1.seq].other_ins_person_id=pid))
        omf_encntr_st->data[d1.seq].other_ins_person_reltn_cd = reltn
       ENDIF
      WITH nocounter
     ;end select
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     SELECT INTO "nl:"
      begeff = ppr.beg_effective_dt_tm, endeff = ppr.end_effective_dt_tm, pid = ppr.person_id,
      hp = ppr.health_plan_id
      FROM person_plan_reltn ppr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (ppr
       WHERE ppr.person_id IN (omf_encntr_st->data[d1.seq].other_ins_person_id, omf_encntr_st->data[
       d1.seq].prim_ins_person_id, omf_encntr_st->data[d1.seq].sec_ins_person_id)
        AND ((ppr.health_plan_id+ 0) IN (omf_encntr_st->data[d1.seq].other_health_plan_id,
       omf_encntr_st->data[d1.seq].prim_health_plan_id, omf_encntr_st->data[d1.seq].
       sec_health_plan_id))
        AND ppr.active_ind=1)
      DETAIL
       IF ((pid=omf_encntr_st->data[d1.seq].prim_ins_person_id)
        AND (hp=omf_encntr_st->data[d1.seq].prim_health_plan_id))
        omf_encntr_st->data[d1.seq].prim_ins_beg_effective_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(begeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(begeff,
          "dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_tm =
        evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(endeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(
          endeff,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].
        prim_ins_beg_effective_dt_nbr = cnvtdate(begeff),
        omf_encntr_st->data[d1.seq].prim_ins_beg_effective_min_nbr = (cnvtmin(begeff,5)+ 1),
        omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_nbr = cnvtdate(endeff), omf_encntr_st->
        data[d1.seq].prim_ins_end_effective_min_nbr = (cnvtmin(endeff,5)+ 1)
        IF (trim(omf_encntr_st->data[d1.seq].prim_ins_beg_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].prim_ins_beg_effective_dt_nbr = - (1), omf_encntr_st->data[d1
         .seq].prim_ins_beg_effective_min_nbr = - (1)
        ENDIF
        IF (trim(omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_nbr = - (1), omf_encntr_st->data[d1
         .seq].prim_ins_end_effective_min_nbr = - (1)
        ENDIF
       ELSEIF ((pid=omf_encntr_st->data[d1.seq].sec_ins_person_id)
        AND (hp=omf_encntr_st->data[d1.seq].sec_health_plan_id))
        omf_encntr_st->data[d1.seq].sec_ins_beg_effective_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(begeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(begeff,
          "dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_tm =
        evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(endeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(
          endeff,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].
        sec_ins_beg_effective_dt_nbr = cnvtdate(begeff),
        omf_encntr_st->data[d1.seq].sec_ins_beg_effective_min_nbr = (cnvtmin(begeff,5)+ 1),
        omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_nbr = cnvtdate(endeff), omf_encntr_st->
        data[d1.seq].sec_ins_end_effective_min_nbr = (cnvtmin(endeff,5)+ 1)
        IF (trim(omf_encntr_st->data[d1.seq].sec_ins_beg_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].sec_ins_beg_effective_dt_nbr = - (1), omf_encntr_st->data[d1.seq
         ].sec_ins_beg_effective_min_nbr = - (1)
        ENDIF
        IF (trim(omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_nbr = - (1), omf_encntr_st->data[d1.seq
         ].sec_ins_end_effective_min_nbr = - (1)
        ENDIF
       ELSEIF ((pid=omf_encntr_st->data[d1.seq].other_ins_person_id)
        AND (hp=omf_encntr_st->data[d1.seq].other_health_plan_id))
        omf_encntr_st->data[d1.seq].other_ins_beg_effective_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(begeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(begeff,
          "dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].other_ins_end_effective_dt_tm =
        evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(endeff,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(
          endeff,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].
        other_ins_beg_effective_dt_nbr = cnvtdate(begeff),
        omf_encntr_st->data[d1.seq].other_ins_beg_effective_min_nbr = (cnvtmin(begeff,5)+ 1),
        omf_encntr_st->data[d1.seq].other_ins_end_effective_dt_nbr = cnvtdate(endeff), omf_encntr_st
        ->data[d1.seq].other_ins_end_effective_min_nbr = (cnvtmin(endeff,5)+ 1)
        IF (trim(omf_encntr_st->data[d1.seq].other_ins_beg_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].other_ins_beg_effective_dt_nbr = - (1), omf_encntr_st->data[d1
         .seq].other_ins_beg_effective_min_nbr = - (1)
        ENDIF
        IF (trim(omf_encntr_st->data[d1.seq].other_ins_end_effective_dt_tm)="")
         omf_encntr_st->data[d1.seq].other_ins_end_effective_dt_nbr = - (1), omf_encntr_st->data[d1
         .seq].other_ins_end_effective_min_nbr = - (1)
        ENDIF
       ENDIF
       IF (v_utc_on_ind=1
        AND ((d1.seq+ 1) <= v_encntr_ndx))
        v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone),
         char(0)), stat = uar_datesettimezone(tz)
       ENDIF
      WITH nocounter, orahintcbo("INDEX (PPR XIE1PERSON_PLAN_RELTN)")
     ;end select
     SELECT INTO "nl:"
      h_plan = hp.plan_type_cd, hp = hp.health_plan_id
      FROM health_plan hp,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (hp
       WHERE hp.health_plan_id IN (omf_encntr_st->data[d1.seq].other_health_plan_id, omf_encntr_st->
       data[d1.seq].prim_health_plan_id, omf_encntr_st->data[d1.seq].sec_health_plan_id)
        AND hp.active_ind=1)
      DETAIL
       CASE (hp)
        OF omf_encntr_st->data[d1.seq].prim_health_plan_id:
         omf_encntr_st->data[d1.seq].prim_ins_plan_type_cd = h_plan
        OF omf_encntr_st->data[d1.seq].sec_health_plan_id:
         omf_encntr_st->data[d1.seq].sec_ins_plan_type_cd = h_plan
        OF omf_encntr_st->data[d1.seq].other_health_plan_id:
         omf_encntr_st->data[d1.seq].other_ins_plan_type_cd = h_plan
       ENDCASE
      WITH nocounter
     ;end select
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     SELECT INTO "nl:"
      nomen_id = proc.nomenclature_id, dt_tm = proc.proc_dt_tm, null_ind = nullind(proc.proc_dt_tm),
      minutes = proc.proc_minutes, prior = proc.proc_priority, nomen_ident = nom.source_identifier
      FROM procedure proc,
       nomenclature nom,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (proc
       WHERE (proc.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND proc.active_ind=1)
       JOIN (nom
       WHERE nom.nomenclature_id=proc.nomenclature_id
        AND (nom.source_vocabulary_cd=omf_prologue_cv->400_icd9))
      DETAIL
       IF (prior=1)
        omf_encntr_st->data[d1.seq].icd9_prin_proc_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
         )
        IF ((omf_encntr_st->data[d1.seq].death_dt_nbr > 0)
         AND (omf_encntr_st->data[d1.seq].death_ind=1)
         AND null_ind=0)
         death_24h_proc = (datetimediff(cnvtdatetime(omf_encntr_st->data[d1.seq].death_dt_tm),
          cnvtdatetime(omf_encntr_st->data[d1.seq].icd9_prin_proc_dt_tm)) * 24)
         IF (death_24h_proc < 24)
          omf_encntr_st->data[d1.seq].death_24h_prin_proc_ind = 1
         ELSE
          omf_encntr_st->data[d1.seq].death_24h_prin_proc_ind = 0
         ENDIF
        ENDIF
       ENDIF
       IF (v_utc_on_ind=1
        AND ((d1.seq+ 1) <= v_encntr_ndx))
        v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone),
         char(0)), stat = uar_datesettimezone(tz)
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      bed_cd = elh.loc_bed_cd, room_cd = elh.loc_room_cd, nu_cd = elh.loc_nurse_unit_cd,
      bldg_cd = elh.loc_building_cd, fac_cd = elh.loc_facility_cd
      FROM encntr_loc_hist elh,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (elh
       WHERE (elh.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND trim(omf_encntr_st->data[d1.seq].visit_dt_tm) != ""
        AND elh.active_ind=1
        AND (elh.transaction_dt_tm=
       (SELECT
        min(elh2.transaction_dt_tm)
        FROM encntr_loc_hist elh2
        WHERE elh2.encntr_id=elh.encntr_id
         AND elh2.active_ind=1)))
      DETAIL
       omf_encntr_st->data[d1.seq].admit_pat_loc_bed_cd = bed_cd, omf_encntr_st->data[d1.seq].
       admit_pat_loc_room_cd = room_cd, omf_encntr_st->data[d1.seq].admit_pat_loc_nu_cd = nu_cd,
       omf_encntr_st->data[d1.seq].admit_pat_loc_bdg_cd = bldg_cd, omf_encntr_st->data[d1.seq].
       admit_pat_loc_fac_cd = fac_cd
      WITH nocounter
     ;end select
     IF ((omf_inpatient_list->test=0))
      SET omf_inpatient_list->test = 1
      SET v_encntr_esi_ndx = 0
      SELECT INTO "nl:"
       cv = cvg.child_code_value
       FROM code_value_group cvg
       WHERE (cvg.parent_code_value=omf_prologue_cv->69_inpatient)
       DETAIL
        v_encntr_esi_ndx += 1, stat = alterlist(omf_inpatient_list->v_inpatient,v_encntr_esi_ndx),
        omf_inpatient_list->v_inpatient[v_encntr_esi_ndx].v_inpatient_cd = cv
       WITH nocounter
      ;end select
     ENDIF
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     IF ((omf_prologue_cv->69_inpatient > 0))
      SELECT INTO "nl:"
       disch_dt_tm = e.disch_dt_tm, readmit_tm = datetimediff(cnvtdatetime(omf_encntr_st->data[d1.seq
         ].visit_dt_tm),e.disch_dt_tm), readmit_cmp = datetimecmp(cnvtdatetime(omf_encntr_st->data[d1
         .seq].visit_dt_tm),e.disch_dt_tm)
       FROM encounter e,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1
        WHERE ((omf_encntr_st->data[d1.seq].encntr_type_class_cd+ 0)=omf_prologue_cv->69_inpatient)
         AND (omf_encntr_st->data[d1.seq].visit_dt_nbr > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (e
        WHERE (e.person_id=omf_encntr_st->data[d1.seq].person_id)
         AND ((e.encntr_type_class_cd+ 0)=omf_prologue_cv->69_inpatient)
         AND ((e.active_ind+ 0)=1)
         AND ((e.disch_dt_tm+ 0)=
        (SELECT
         max(e2.disch_dt_tm)
         FROM encounter e2
         WHERE (e2.person_id=omf_encntr_st->data[d1.seq].person_id)
          AND ((e2.encntr_type_class_cd+ 0)=omf_prologue_cv->69_inpatient)
          AND e2.reg_dt_tm < cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm)
          AND e2.active_ind=1)))
       DETAIL
        omf_encntr_st->data[d1.seq].prev_inp_encntr_id = e.encntr_id, omf_encntr_st->data[d1.seq].
        last_ip_disch_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(disch_dt_tm,3),
          "dd-mmm-yyyy hh:mm:ss;;d"),format(disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (readmit_tm <= 1.0)
         omf_encntr_st->data[d1.seq].admit_48h_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_24h_ladmit_ind = 1, omf_encntr_st->data[d1.seq].admit_72h_ladmit_ind = 1,
         omf_encntr_st->data[d1.seq].readmit_24h_48h_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_48h_72h_ind = 0, omf_encntr_st->data[d1.seq].readmit_gt_72h_ind = 0
        ELSEIF (readmit_tm <= 2.0)
         omf_encntr_st->data[d1.seq].admit_48h_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_24h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_72h_ladmit_ind = 1,
         omf_encntr_st->data[d1.seq].readmit_24h_48h_ind = 1, omf_encntr_st->data[d1.seq].
         readmit_48h_72h_ind = 0, omf_encntr_st->data[d1.seq].readmit_gt_72h_ind = 0
        ELSEIF (readmit_tm <= 3.0)
         omf_encntr_st->data[d1.seq].admit_24h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         admit_48h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_72h_ladmit_ind = 1,
         omf_encntr_st->data[d1.seq].readmit_24h_48h_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_48h_72h_ind = 1, omf_encntr_st->data[d1.seq].readmit_gt_72h_ind = 0
        ELSE
         omf_encntr_st->data[d1.seq].admit_48h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         admit_24h_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_72h_ladmit_ind = 0,
         omf_encntr_st->data[d1.seq].readmit_24h_48h_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_48h_72h_ind = 0, omf_encntr_st->data[d1.seq].readmit_gt_72h_ind = 1
        ENDIF
        IF (readmit_cmp <= 7)
         omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_30d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].admit_15d_ladmit_ind = 1,
         omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         readmit_7d_15d_ind = 0, omf_encntr_st->data[d1.seq].readmit_15d_30d_ind = 0,
         omf_encntr_st->data[d1.seq].readmit_30d_48d_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_gt_48d_ind = 0
        ELSEIF (readmit_cmp <= 15)
         omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_30d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].admit_15d_ladmit_ind = 1,
         omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_7d_15d_ind = 1, omf_encntr_st->data[d1.seq].readmit_15d_30d_ind = 0,
         omf_encntr_st->data[d1.seq].readmit_30d_48d_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_gt_48d_ind = 0
        ELSEIF (readmit_cmp <= 30)
         omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_30d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].admit_15d_ladmit_ind = 0,
         omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_7d_15d_ind = 0, omf_encntr_st->data[d1.seq].readmit_15d_30d_ind = 1,
         omf_encntr_st->data[d1.seq].readmit_30d_48d_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_gt_48d_ind = 0
        ELSEIF (readmit_cmp <= 48)
         omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 1, omf_encntr_st->data[d1.seq].
         admit_30d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_15d_ladmit_ind = 0,
         omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_7d_15d_ind = 0, omf_encntr_st->data[d1.seq].readmit_15d_30d_ind = 0,
         omf_encntr_st->data[d1.seq].readmit_30d_48d_ind = 1, omf_encntr_st->data[d1.seq].
         readmit_gt_48d_ind = 0
        ELSE
         omf_encntr_st->data[d1.seq].admit_48d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         admit_30d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].admit_15d_ladmit_ind = 0,
         omf_encntr_st->data[d1.seq].admit_7d_ladmit_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_7d_15d_ind = 0, omf_encntr_st->data[d1.seq].readmit_15d_30d_ind = 0,
         omf_encntr_st->data[d1.seq].readmit_30d_48d_ind = 0, omf_encntr_st->data[d1.seq].
         readmit_gt_48d_ind = 1
        ENDIF
        IF (v_utc_on_ind=1
         AND ((d1.seq+ 1) <= v_encntr_ndx))
         v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone
           ),char(0)), stat = uar_datesettimezone(tz)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     SELECT INTO "nl:"
      epr.encntr_prsnl_reltn_id, prsnl_key = concat(trim(cnvtstring(epr.prsnl_person_id),3),trim(epr
        .ft_prsnl_name,3))
      FROM encntr_prsnl_reltn epr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (epr
       WHERE (epr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
        AND epr.active_ind=1
        AND epr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
      ORDER BY epr.encntr_id
      HEAD epr.encntr_id
       nbr_consults = 0, ndx = 0
      DETAIL
       IF ((epr.encntr_prsnl_r_cd=omf_prologue_cv->333_consultdoc))
        nbr_consults += 1
       ENDIF
       ndx += 1, stat = alterlist(omf_encntr_st->data[d1.seq].encntr_reltn,ndx), omf_encntr_st->data[
       d1.seq].encntr_reltn[ndx].encntr_prsnl_reltn_id = epr.encntr_prsnl_reltn_id
       IF ((epr.free_text_cd=omf_prologue_cv->382_ft_brief))
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].prsnl_person_ft_name = epr.ft_prsnl_name
       ELSE
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].prsnl_person_id = epr.prsnl_person_id
       ENDIF
       omf_encntr_st->data[d1.seq].encntr_reltn[ndx].prsnl_person_key = prsnl_key, omf_encntr_st->
       data[d1.seq].encntr_reltn[ndx].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, omf_encntr_st->data[
       d1.seq].encntr_reltn[ndx].priority_seq = epr.priority_seq,
       omf_encntr_st->data[d1.seq].encntr_reltn[ndx].beg_effective_dt_tm = evaluate(v_utc_on_ind,1,
        format(cnvtdatetimeutc(epr.beg_effective_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(epr
         .beg_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq].encntr_reltn[
       ndx].end_effective_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(epr
          .end_effective_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(epr.end_effective_dt_tm,
         "dd-mmm-yyyy hh:mm:ss;;d"))
       IF (size(trim(omf_encntr_st->data[d1.seq].encntr_reltn[ndx].beg_effective_dt_tm))=0)
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].beg_effective_dt_nbr = - (1), omf_encntr_st->
        data[d1.seq].encntr_reltn[ndx].beg_effective_min_nbr = - (1)
       ELSE
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].beg_effective_dt_nbr = cnvtdate(epr
         .beg_effective_dt_tm), omf_encntr_st->data[d1.seq].encntr_reltn[ndx].beg_effective_min_nbr
         = (cnvtmin(epr.beg_effective_dt_tm,5)+ 1)
       ENDIF
       IF (size(trim(omf_encntr_st->data[d1.seq].encntr_reltn[ndx].end_effective_dt_tm))=0)
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].end_effective_dt_nbr = - (1), omf_encntr_st->
        data[d1.seq].encntr_reltn[ndx].end_effective_min_nbr = - (1)
       ELSE
        omf_encntr_st->data[d1.seq].encntr_reltn[ndx].end_effective_dt_nbr = cnvtdate(epr
         .end_effective_dt_tm), omf_encntr_st->data[d1.seq].encntr_reltn[ndx].end_effective_min_nbr
         = (cnvtmin(epr.end_effective_dt_tm,5)+ 1)
       ENDIF
      FOOT  epr.encntr_id
       omf_encntr_st->data[d1.seq].nbr_consults = nbr_consults
       IF ((ndx > omf_encntr_st->max_encntr_reltn_cnt))
        omf_encntr_st->max_encntr_reltn_cnt = ndx
       ENDIF
       omf_encntr_st->data[d1.seq].encntr_reltn_cnt = ndx
       IF (v_utc_on_ind=1
        AND ((d1.seq+ 1) <= v_encntr_ndx))
        v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone),
         char(0)), stat = uar_datesettimezone(tz)
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl"
      p.position_cd
      FROM prsnl p,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_encntr_reltn_cnt))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].encntr_reltn_cnt)
        AND (omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].prsnl_person_id > 0))
       JOIN (p
       WHERE (p.person_id=omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].prsnl_person_id))
      DETAIL
       omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].prsnl_person_position_cd = p.position_cd
      WITH nocounter
     ;end select
     SET v_grp_ndx = size(omf_groupings->cap_shift,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_temp->data[d1.seq].disch_hour >= 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_temp->data[d1.seq].disch_hour BETWEEN omf_groupings->cap_shift[d2.seq].num1 AND
        omf_groupings->cap_shift[d2.seq].num2)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_shift[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_shift[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_shift[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_shift[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].disch_shift_grp_cd = omf_groupings->cap_shift[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_temp->data[d1.seq].visit_hour >= 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_temp->data[d1.seq].visit_hour BETWEEN omf_groupings->cap_shift[d2.seq].num1 AND
        omf_groupings->cap_shift[d2.seq].num2)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_shift[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_shift[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_shift[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_shift[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].admit_shift_grp_cd = omf_groupings->cap_shift[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_age,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].age_years >= 0)
         AND (omf_encntr_st->data[d1.seq].birth_dt_tm != null)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].age_years BETWEEN omf_groupings->cap_age[d2.seq].num1 AND
        omf_groupings->cap_age[d2.seq].num2)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_age[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_age[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_age[d2.seq]
         .beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_age[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].age_years_grp_cd = omf_groupings->cap_age[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_age_days,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].age_days > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].age_days BETWEEN omf_groupings->cap_age_days[d2.seq].num1
         AND omf_groupings->cap_age_days[d2.seq].num2)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_age_days[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_age_days[d2.seq].end_effective_dt_tm,3))=0) OR (
        cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->
         cap_age_days[d2.seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_age_days[d2
         .seq].end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].age_days_grp_cd = omf_groupings->cap_age_days[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_medserv,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].med_serv_cd > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].med_serv_cd=omf_groupings->cap_medserv[d2.seq].med_serv_cd
        )
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medserv[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medserv[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medserv[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medserv[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].med_serv_grp_cd = omf_groupings->cap_medserv[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_fac,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_fac_cd > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_fac_cd=omf_groupings->cap_fac[d2.seq].
        facility_cd)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_fac[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_fac[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_fac[d2.seq]
         .beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_fac[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].curr_pat_loc_fac_grp_cd = omf_groupings->cap_fac[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_nu,5)
     IF (v_grp_ndx > 0)
      CALL echo("*_*_* cap_nu *_*_*")
      CALL echo(build2("*_*_* size: ",v_grp_ndx))
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_nu_cd > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_nu_cd=omf_groupings->cap_nu[d2.seq].
        nurse_unit_cd)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_nu[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_nu[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_nu[d2.seq].
         beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_nu[d2.seq].end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].curr_pat_loc_nu_grp_cd = omf_groupings->cap_nu[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_nu2,5)
     IF (v_grp_ndx > 0)
      CALL echo("*_*_* cap_nu2 *_*_*")
      CALL echo(build2("*_*_* size: ",v_grp_ndx))
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_nu_cd > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].curr_pat_loc_nu_cd=omf_groupings->cap_nu2[d2.seq].
        nurse_unit_cd)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_nu2[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_nu2[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_nu2[d2.seq]
         .beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_nu2[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].curr_pat_loc_nu_grp2_cd = omf_groupings->cap_nu2[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_ins_co,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].prim_ins_organization_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].prim_ins_organization_id=omf_groupings->cap_ins_co[d2.seq]
        .organization_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_ins_co[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_ins_co[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_ins_co[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_ins_co[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].prim_ins_group_cd = omf_groupings->cap_ins_co[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].sec_ins_organization_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].sec_ins_organization_id=omf_groupings->cap_ins_co[d2.seq].
        organization_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_ins_co[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_ins_co[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_ins_co[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_ins_co[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].sec_ins_group_cd = omf_groupings->cap_ins_co[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_hlthpl,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].prim_health_plan_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].prim_health_plan_id=omf_groupings->cap_hlthpl[d2.seq].
        health_plan_cd)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_hlthpl[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_hlthpl[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_hlthpl[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_hlthpl[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].prim_health_plan_group_cd = omf_groupings->cap_hlthpl[d2.seq].
        grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].sec_health_plan_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].sec_health_plan_id=omf_groupings->cap_hlthpl[d2.seq].
        health_plan_cd)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_hlthpl[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_hlthpl[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_hlthpl[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_hlthpl[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].sec_health_plan_group_cd = omf_groupings->cap_hlthpl[d2.seq].
        grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_phys,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].admit_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].admit_phys_id=omf_groupings->cap_phys[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_phys[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_phys[d2.seq
         ].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].admit_phys_grp_cd = omf_groupings->cap_phys[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].att_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].att_phys_id=omf_groupings->cap_phys[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_phys[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_phys[d2.seq
         ].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].att_phys_grp_cd = omf_groupings->cap_phys[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].pcp_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].pcp_phys_id=omf_groupings->cap_phys[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_phys[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_phys[d2.seq
         ].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].pcp_phys_grp_cd = omf_groupings->cap_phys[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_medspec,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].admit_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].admit_phys_id=omf_groupings->cap_medspec[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].admit_phys_med_spec_cd = omf_groupings->cap_medspec[d2.seq].
        grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].att_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].att_phys_id=omf_groupings->cap_medspec[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].att_phys_med_spec_cd = omf_groupings->cap_medspec[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].ref_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].ref_phys_id=omf_groupings->cap_medspec[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].ref_phys_med_spec_cd = omf_groupings->cap_medspec[d2.seq].grp_cd
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].pcp_phys_id > 0)
         AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].pcp_phys_id=omf_groupings->cap_medspec[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].pcp_phys_med_spec_cd = omf_groupings->cap_medspec[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_zipcode,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       a.zipcode
       FROM address a,
        (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d2
        WHERE ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_zipcode[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_zipcode[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_zipcode[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_zipcode[d2.seq].
         end_effective_dt_tm))) )
        JOIN (a
        WHERE a.parent_entity_name="PERSON"
         AND (a.parent_entity_id=omf_encntr_st->data[d1.seq].person_id)
         AND (a.address_type_cd=omf_prologue_cv->212_home)
         AND cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN a.beg_effective_dt_tm AND
        a.end_effective_dt_tm
         AND (a.zipcode=omf_groupings->cap_zipcode[d2.seq].zipcode))
       DETAIL
        omf_encntr_st->data[d1.seq].person_home_zipcode_grp_cd = omf_groupings->cap_zipcode[d2.seq].
        grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_phys,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d3  WITH seq = value(omf_encntr_st->max_encntr_reltn_cnt)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d3
        WHERE (d3.seq <= omf_encntr_st->data[d1.seq].encntr_reltn_cnt)
         AND (omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_id > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_id=omf_groupings->
        cap_phys[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_phys[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_phys[d2.seq
         ].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_grp_cd = omf_groupings->
        cap_phys[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_medspec,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d3  WITH seq = value(omf_encntr_st->max_encntr_reltn_cnt)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d3
        WHERE (d3.seq <= omf_encntr_st->data[d1.seq].encntr_reltn_cnt)
         AND (omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_id > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_id=omf_groupings->
        cap_medspec[d2.seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].encntr_reltn[d3.seq].prsnl_person_med_spec_cd = omf_groupings->
        cap_medspec[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl:"
      1
      FROM (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
      DETAIL
       FOR (x = 1 TO 8)
         CASE (x)
          OF 1:
           v_dt_nbr = omf_encntr_st->data[d1.seq].visit_dt_nbr,v_date = substring(1,11,omf_encntr_st
            ->data[d1.seq].visit_dt_tm)
          OF 2:
           v_dt_nbr = omf_encntr_st->data[d1.seq].disch_dt_nbr,v_date = substring(1,11,omf_encntr_st
            ->data[d1.seq].disch_dt_tm)
          OF 3:
           v_dt_nbr = omf_encntr_st->data[d1.seq].death_dt_nbr,v_date = substring(1,11,omf_encntr_st
            ->data[d1.seq].death_dt_tm)
          OF 4:
           v_dt_nbr = omf_encntr_st->data[d1.seq].exp_pm_disch_dt_nbr,v_date = substring(1,11,
            omf_encntr_st->data[d1.seq].exp_pm_disch_dt_tm)
          OF 5:
           v_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_beg_effective_dt_nbr,v_date = substring(1,
            11,omf_encntr_st->data[d1.seq].prim_ins_beg_effective_dt_tm)
          OF 6:
           v_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_nbr,v_date = substring(1,
            11,omf_encntr_st->data[d1.seq].prim_ins_end_effective_dt_tm)
          OF 7:
           v_dt_nbr = omf_encntr_st->data[d1.seq].sec_ins_beg_effective_dt_nbr,v_date = substring(1,
            11,omf_encntr_st->data[d1.seq].sec_ins_beg_effective_dt_tm)
          OF 8:
           v_dt_nbr = omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_nbr,v_date = substring(1,
            11,omf_encntr_st->data[d1.seq].sec_ins_end_effective_dt_tm)
         ENDCASE
         omf_date_ndx = 1
         WHILE (omf_date_ndx <= size(omf_date->row,5)
          AND (omf_date->row[omf_date_ndx].dt_nbr != v_dt_nbr))
           omf_date_ndx += 1
         ENDWHILE
         IF (omf_date_ndx > size(omf_date->row,5))
          stat = alterlist(omf_date->row,omf_date_ndx), omf_date->row[omf_date_ndx].dt_nbr = v_dt_nbr,
          omf_date->row[omf_date_ndx].date = v_date,
          omf_date->row[omf_date_ndx].exist_ind = 1
         ENDIF
       ENDFOR
      WITH nocounter
     ;end select
     CALL echo("Entering OMF_PM_ADT_HIST <include file>...")
     SET c_omf_pm_adt_hist = "OMF_PM_ADT_HIST.INC 009"
     SELECT INTO "nl:"
      1
      FROM (dummyt d1  WITH seq = value(size(omf_encntr_st->data,5)))
      PLAN (d1)
      DETAIL
       omf_encntr_st->data[d1.seq].hist_list[1].hist_type = "LOCATION", omf_encntr_st->data[d1.seq].
       hist_list[1].dirty_ind = 0, omf_encntr_st->data[d1.seq].hist_list[1].inst_cnt = 0,
       stat = alterlist(omf_encntr_st->data[d1.seq].hist_list[1].instance,0), omf_encntr_st->data[d1
       .seq].hist_list[2].hist_type = "ENCNTR_TYPE", omf_encntr_st->data[d1.seq].hist_list[2].
       dirty_ind = 0,
       omf_encntr_st->data[d1.seq].hist_list[2].inst_cnt = 0, stat = alterlist(omf_encntr_st->data[d1
        .seq].hist_list[2].instance,0), omf_encntr_st->data[d1.seq].hist_list[3].hist_type =
       "MED_SERVICE",
       omf_encntr_st->data[d1.seq].hist_list[3].dirty_ind = 0, omf_encntr_st->data[d1.seq].hist_list[
       3].inst_cnt = 0, stat = alterlist(omf_encntr_st->data[d1.seq].hist_list[3].instance,0)
      WITH nocounter
     ;end select
     IF ((reqinfo->updt_req=114001))
      IF (v_utc_on_ind=1)
       SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
       CALL uar_datesettimezone(tz)
      ENDIF
      SELECT INTO "nl:"
       elh.encntr_id, e.person_id
       FROM encntr_loc_hist elh,
        encounter e,
        (dummyt d1  WITH seq = value(v_encntr_ndx))
       PLAN (d1)
        JOIN (elh
        WHERE (elh.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
         AND elh.active_ind=1)
        JOIN (e
        WHERE e.encntr_id=elh.encntr_id)
       ORDER BY elh.transaction_dt_tm
       DETAIL
        FOR (j = 1 TO 3)
          dirty = 0, prev = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt
          IF ((omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt < 1))
           dirty = 1, omf_temp->data[d1.seq].previous_nurse_unit_cd = 0.0
          ELSE
           CASE (j)
            OF 1:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh
             .loc_building_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val2=elh
             .loc_facility_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val3=elh
             .loc_nurse_unit_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val5=elh.loc_room_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val6=elh.loc_bed_cd))
              dirty = 0
             ELSE
              IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val3 != elh
              .loc_nurse_unit_cd))
               omf_temp->data[d1.seq].previous_nurse_unit_cd = omf_encntr_st->data[d1.seq].hist_list[
               j].instance[prev].num_val3
              ENDIF
              dirty = 1
             ENDIF
            OF 2:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh.encntr_type_cd
             ))
              dirty = 0
             ELSE
              dirty = 1
             ENDIF
            OF 3:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh.med_service_cd
             ))
              dirty = 0
             ELSE
              dirty = 1
             ENDIF
           ENDCASE
          ENDIF
          IF (dirty)
           omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt += 1
           IF ((omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt > omf_encntr_st->max_inst_cnt))
            omf_encntr_st->max_inst_cnt = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt
           ENDIF
           new_pos = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt, stat = alterlist(
            omf_encntr_st->data[d1.seq].hist_list[j].instance,new_pos), omf_encntr_st->data[d1.seq].
           hist_list[j].instance[new_pos].beg_transaction_dt_tm = evaluate(v_utc_on_ind,1,format(
             cnvtdatetimeutc(elh.transaction_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(elh
             .transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].beg_transaction_dt_nbr =
           cnvtdate(elh.transaction_dt_tm), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos
           ].beg_transaction_min_nbr = (cnvtmin(elh.transaction_dt_tm,5)+ 1)
           IF (prev >= 1)
            omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].end_transaction_dt_tm = evaluate(
             v_utc_on_ind,1,format(cnvtdatetimeutc(elh.transaction_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"
              ),format(elh.transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq]
            .hist_list[j].instance[prev].end_transaction_dt_nbr = cnvtdate(elh.transaction_dt_tm),
            omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].end_transaction_min_nbr = (
            cnvtmin(elh.transaction_dt_tm,5)+ 1)
           ENDIF
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_dt_tm = " ",
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_dt_nbr = - (1),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_min_nbr = - (1),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].encntr_id = elh.encntr_id,
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].encntr_loc_hist_id = elh
           .encntr_loc_hist_id, omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val1
            = evaluate(j,1,elh.loc_building_cd,2,elh.encntr_type_cd,
            3,elh.med_service_cd),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val2 = evaluate(j,1,elh
            .loc_facility_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].
           num_val3 = evaluate(j,1,elh.loc_nurse_unit_cd,2,e.person_id,
            null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val4 = evaluate(j,1,
            elh.transfer_reason_cd,null),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val5 = evaluate(j,1,elh
            .loc_room_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val6
            = evaluate(j,1,elh.loc_bed_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[
           new_pos].num_val7 = omf_temp->data[d1.seq].previous_nurse_unit_cd
          ENDIF
        ENDFOR
        IF (v_utc_on_ind=1
         AND ((d1.seq+ 1) <= v_encntr_ndx))
         v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone
           ),char(0)), stat = uar_datesettimezone(tz)
        ENDIF
       WITH nocounter
      ;end select
     ELSE
      IF (v_utc_on_ind=1)
       SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
       CALL uar_datesettimezone(tz)
      ENDIF
      SELECT INTO "nl:"
       elh.encntr_id, e.person_id
       FROM encntr_loc_hist elh,
        encounter e,
        (dummyt d1  WITH seq = value(size(omf_encntr_st->data,5)))
       PLAN (d1)
        JOIN (elh
        WHERE (elh.encntr_id=omf_encntr_st->data[d1.seq].encntr_id)
         AND elh.active_ind=1)
        JOIN (e
        WHERE e.encntr_id=elh.encntr_id)
       ORDER BY elh.transaction_dt_tm
       DETAIL
        x = d1.seq
        FOR (j = 1 TO 3)
          dirty = 0, prev = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt
          IF ((omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt < 1))
           dirty = 1
          ELSE
           CASE (j)
            OF 1:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh
             .loc_building_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val2=elh
             .loc_facility_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val3=elh
             .loc_nurse_unit_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val5=elh.loc_room_cd)
              AND (omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val6=elh.loc_bed_cd))
              dirty = 0
             ELSE
              IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val3 != elh
              .loc_nurse_unit_cd))
               v_previous_nurse_unit_cd = omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].
               num_val3
              ENDIF
              dirty = 1
             ENDIF
            OF 2:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh.encntr_type_cd
             ))
              dirty = 0
             ELSE
              dirty = 1
             ENDIF
            OF 3:
             IF ((omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].num_val1=elh.med_service_cd
             ))
              dirty = 0
             ELSE
              dirty = 1
             ENDIF
           ENDCASE
          ENDIF
          IF ((omf_encntr_st->data[d1.seq].hist_list[j].dirty_ind=0))
           omf_encntr_st->data[d1.seq].hist_list[j].dirty_ind = dirty
          ENDIF
          IF (dirty)
           omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt += 1
           IF ((omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt > omf_encntr_st->max_inst_cnt))
            omf_encntr_st->max_inst_cnt = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt
           ENDIF
           new_pos = omf_encntr_st->data[d1.seq].hist_list[j].inst_cnt, stat = alterlist(
            omf_encntr_st->data[d1.seq].hist_list[j].instance,new_pos), omf_encntr_st->data[d1.seq].
           hist_list[j].instance[new_pos].beg_transaction_dt_tm = evaluate(v_utc_on_ind,1,format(
             cnvtdatetimeutc(elh.transaction_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(elh
             .transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].beg_transaction_dt_nbr =
           cnvtdate(elh.transaction_dt_tm), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos
           ].beg_transaction_min_nbr = (cnvtmin(elh.transaction_dt_tm,5)+ 1)
           IF (prev >= 1)
            omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].end_transaction_dt_tm = evaluate(
             v_utc_on_ind,1,format(cnvtdatetimeutc(elh.transaction_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"
              ),format(elh.transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), omf_encntr_st->data[d1.seq]
            .hist_list[j].instance[prev].end_transaction_dt_nbr = cnvtdate(elh.transaction_dt_tm),
            omf_encntr_st->data[d1.seq].hist_list[j].instance[prev].end_transaction_min_nbr = (
            cnvtmin(elh.transaction_dt_tm)+ 1)
           ENDIF
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_dt_tm = " ",
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_dt_nbr = - (1),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].end_transaction_min_nbr = - (1),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].encntr_id = elh.encntr_id,
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].encntr_loc_hist_id = elh
           .encntr_loc_hist_id, omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val1
            = evaluate(j,1,elh.loc_building_cd,2,elh.encntr_type_cd,
            3,elh.med_service_cd),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val2 = evaluate(j,1,elh
            .loc_facility_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].
           num_val3 = evaluate(j,1,elh.loc_nurse_unit_cd,2,e.person_id,
            null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val4 = evaluate(j,1,
            elh.transfer_reason_cd,null),
           omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val5 = evaluate(j,1,elh
            .loc_room_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[new_pos].num_val6
            = evaluate(j,1,elh.loc_bed_cd,null), omf_encntr_st->data[d1.seq].hist_list[j].instance[
           new_pos].num_val7 = v_previous_nurse_unit_cd
          ENDIF
        ENDFOR
        IF (v_utc_on_ind=1
         AND ((d1.seq+ 1) <= v_encntr_ndx))
         v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone
           ),char(0)), stat = uar_datesettimezone(tz)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl:"
      1
      FROM (dummyt d1  WITH seq = value(size(omf_encntr_st->data,5)))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].disch_ind=1))
      DETAIL
       FOR (k = 1 TO 3)
        temp_cnt = omf_encntr_st->data[d1.seq].hist_list[k].inst_cnt,
        IF (temp_cnt > 0)
         omf_encntr_st->data[d1.seq].hist_list[k].instance[temp_cnt].end_transaction_dt_tm =
         omf_encntr_st->data[d1.seq].disch_dt_tm, omf_encntr_st->data[d1.seq].hist_list[k].instance[
         temp_cnt].end_transaction_dt_nbr = cnvtdate(cnvtdatetime(omf_encntr_st->data[d1.seq].
           disch_dt_tm))
         IF (v_utc_on_ind=1)
          omf_encntr_st->data[d1.seq].hist_list[k].instance[temp_cnt].end_transaction_min_nbr = (
          cnvtmin(cnvtint(format(cnvtdatetimeutc(omf_encntr_st->data[d1.seq].disch_dt_tm,4),
             "HHMM;1;M")))+ 1)
         ELSE
          omf_encntr_st->data[d1.seq].hist_list[k].instance[temp_cnt].end_transaction_min_nbr = (
          cnvtmin(cnvtint(format(cnvtdatetime(omf_encntr_st->data[d1.seq].disch_dt_tm),"HHMM;1;M")))
          + 1)
         ENDIF
        ENDIF
       ENDFOR
      WITH nocounter
     ;end select
     IF (size(omf_etc_list->data,5)=0)
      SET v_etccnt = 0
      SELECT INTO "nl:"
       cv = cv.code_value
       FROM code_value cv
       WHERE cv.code_set=69
        AND cv.active_ind=1
        AND cv.cdf_meaning > " "
       DETAIL
        v_etccnt += 1
        IF (mod(v_etccnt,10)=1)
         stat = alterlist(omf_etc_list->data,(v_etccnt+ 9))
        ENDIF
        omf_etc_list->data[v_etccnt].encntr_type_class_cd = cv
       FOOT REPORT
        stat = alterlist(omf_etc_list->data,v_etccnt)
       WITH nocounter
      ;end select
      SET v_etcnt = 0
      SELECT INTO "nl:"
       pcv = cv.parent_code_value, cv = cv.child_code_value
       FROM code_value_group cv,
        (dummyt d1  WITH seq = value(size(omf_etc_list->data,5)))
       PLAN (d1)
        JOIN (cv
        WHERE (cv.parent_code_value=omf_etc_list->data[d1.seq].encntr_type_class_cd))
       ORDER BY pcv
       HEAD pcv
        v_etcnt = 0
       DETAIL
        v_etcnt += 1, stat = alterlist(omf_etc_list->data[d1.seq].encntr_type,v_etcnt), omf_etc_list
        ->data[d1.seq].encntr_type[v_etcnt].encntr_type_cd = cv
       FOOT  pcv
        IF ((v_etcnt > omf_etc_list->max_encntr_type_cnt))
         omf_etc_list->max_encntr_type_cnt = v_etcnt
        ENDIF
        omf_etc_list->data[d1.seq].encntr_type_cnt = v_etcnt
       WITH nocounter
      ;end select
     ENDIF
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     SELECT INTO "nl:"
      curr_pat_loc_arrive_dt_tm = oes.curr_pat_loc_arrive_dt_tm, oes.transfer_reason_cd, oes
      .prev_pat_loc_nu_cd
      FROM omf_encntr_st oes,
       (dummyt d1  WITH seq = value(size(omf_encntr_st->data,5)))
      PLAN (d1)
       JOIN (oes
       WHERE (oes.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
      DETAIL
       temp_cnt = omf_encntr_st->data[d1.seq].hist_list[1].inst_cnt
       IF (temp_cnt > 0)
        omf_encntr_st->data[d1.seq].transfer_reason_cd = omf_encntr_st->data[d1.seq].hist_list[1].
        instance[temp_cnt].num_val4
        IF ((((omf_temp->data[d1.seq].previous_nurse_unit_cd=0)) OR ((omf_temp->data[d1.seq].
        previous_nurse_unit_cd=omf_encntr_st->data[d1.seq].prev_pat_loc_nu_cd))) )
         omf_encntr_st->data[d1.seq].prev_pat_loc_nu_cd = oes.prev_pat_loc_nu_cd, omf_encntr_st->
         data[d1.seq].curr_pat_loc_arrive_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(
            curr_pat_loc_arrive_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(curr_pat_loc_arrive_dt_tm,
           "dd-mmm-yyyy hh:mm:ss;;d"))
         IF (trim(omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm)="")
          omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = - (1), omf_encntr_st->data[d1.seq]
          .curr_pat_loc_arrive_min_nbr = - (1)
         ELSE
          omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = cnvtdate(curr_pat_loc_arrive_dt_tm
           ), omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr = (cnvtmin(cnvtint(format(
             cnvtdatetimeutc(omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm,4),"HHMM;1;M")))+
          1)
         ENDIF
        ELSE
         omf_encntr_st->data[d1.seq].prev_pat_loc_nu_cd = omf_temp->data[d1.seq].
         previous_nurse_unit_cd, omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm =
         omf_encntr_st->data[d1.seq].hist_list[1].instance[temp_cnt].beg_transaction_dt_tm
         IF (trim(omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm)="")
          omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = - (1), omf_encntr_st->data[d1.seq]
          .curr_pat_loc_arrive_min_nbr = - (1)
         ELSE
          omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = cnvtdate(omf_encntr_st->data[d1
           .seq].curr_pat_loc_arrive_dt_tm), omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr
           = (cnvtmin(cnvtint(format(cnvtdatetimeutc(omf_encntr_st->data[d1.seq].
              curr_pat_loc_arrive_dt_tm,4),"HHMM;1;M")))+ 1)
         ENDIF
        ENDIF
       ELSE
        omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm = evaluate(v_utc_on_ind,1,format(
          cnvtdatetimeutc(curr_pat_loc_arrive_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(
          curr_pat_loc_arrive_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (trim(omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm)="")
         omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = - (1), omf_encntr_st->data[d1.seq].
         curr_pat_loc_arrive_min_nbr = - (1)
        ELSE
         omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr = cnvtdate(curr_pat_loc_arrive_dt_tm),
         omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr = (cnvtmin(cnvtint(format(
            cnvtdatetimeutc(omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm,4),"HHMM;1;M")))+ 1
         )
        ENDIF
        omf_encntr_st->data[d1.seq].transfer_reason_cd = oes.transfer_reason_cd, omf_encntr_st->data[
        d1.seq].prev_pat_loc_nu_cd = oes.prev_pat_loc_nu_cd
       ENDIF
       IF (v_utc_on_ind=1
        AND ((d1.seq+ 1) <= v_encntr_ndx))
        v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone),
         char(0)), stat = uar_datesettimezone(tz)
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(size(omf_encntr_st->data,5)))
       PLAN (d1)
       DETAIL
        temp_cnt = omf_encntr_st->data[d1.seq].hist_list[1].inst_cnt
        IF (temp_cnt > 0)
         omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_tm = omf_encntr_st->data[d1.seq].
         hist_list[1].instance[temp_cnt].beg_transaction_dt_tm
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     FOR (x = 1 TO 3)
       SELECT INTO "nl:"
        1
        FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
         (dummyt d2  WITH seq = value(omf_encntr_st->max_inst_cnt))
        PLAN (d1
         WHERE (omf_encntr_st->data[d1.seq].hist_list[x].dirty_ind=1)
          AND (omf_encntr_st->data[d1.seq].disch_ind=1)
          AND (omf_encntr_st->data[d1.seq].hist_list[x].inst_cnt > 0))
         JOIN (d2
         WHERE (d2.seq <= omf_encntr_st->data[d1.seq].hist_list[x].inst_cnt))
        DETAIL
         FOR (y = 1 TO 2)
           CASE (y)
            OF 1:
             v_dt_nbr = omf_encntr_st->data[d1.seq].hist_list[x].instance[d2.seq].
             beg_transaction_dt_nbr,v_date = substring(1,11,omf_encntr_st->data[d1.seq].hist_list[x].
              instance[d2.seq].beg_transaction_dt_tm)
            OF 2:
             v_dt_nbr = omf_encntr_st->data[d1.seq].hist_list[x].instance[d2.seq].
             end_transaction_dt_nbr,v_date = substring(1,11,omf_encntr_st->data[d1.seq].hist_list[x].
              instance[d2.seq].end_transaction_dt_tm)
           ENDCASE
           omf_date_ndx = 1
           WHILE (omf_date_ndx <= size(omf_date->row,5)
            AND (omf_date->row[omf_date_ndx].dt_nbr != v_dt_nbr))
             omf_date_ndx += 1
           ENDWHILE
           IF (omf_date_ndx > size(omf_date->row,5))
            stat = alterlist(omf_date->row,omf_date_ndx), omf_date->row[omf_date_ndx].dt_nbr =
            v_dt_nbr, omf_date->row[omf_date_ndx].date = v_date,
            omf_date->row[omf_date_ndx].exist_ind = 1
           ENDIF
         ENDFOR
        WITH nocounter
       ;end select
       SET v_etc_cnt = size(omf_etc_list->data,5)
       SELECT INTO "nl"
        1
        FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
         (dummyt d2  WITH seq = value(omf_encntr_st->max_inst_cnt)),
         (dummyt d3  WITH seq = value(v_etc_cnt)),
         (dummyt d4  WITH seq = value(omf_etc_list->max_encntr_type_cnt))
        PLAN (d1
         WHERE x=2)
         JOIN (d2
         WHERE (d2.seq <= omf_encntr_st->data[d1.seq].hist_list[x].inst_cnt))
         JOIN (d3)
         JOIN (d4
         WHERE (d4.seq <= omf_etc_list->data[d3.seq].encntr_type_cnt)
          AND (omf_etc_list->data[d3.seq].encntr_type[d4.seq].encntr_type_cd=omf_encntr_st->data[d1
         .seq].hist_list[2].instance[d2.seq].num_val1))
        DETAIL
         omf_encntr_st->data[d1.seq].hist_list[2].instance[d2.seq].num_val2 = omf_etc_list->data[d3
         .seq].encntr_type_class_cd
        WITH nocounter
       ;end select
     ENDFOR
     SET v_grp_ndx = size(omf_groupings->cap_nu,5)
     SELECT INTO "nl:"
      1
      FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d3  WITH seq = value(omf_encntr_st->max_inst_cnt)),
       (dummyt d2  WITH seq = value(v_grp_ndx))
      PLAN (d1)
       JOIN (d3
       WHERE (d3.seq <= omf_encntr_st->data[d1.seq].hist_list[1].inst_cnt)
        AND (omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].num_val3 > 0))
       JOIN (d2
       WHERE (omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].num_val3=omf_groupings->
       cap_nu[d2.seq].nurse_unit_cd)
        AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].
        beg_transaction_dt_tm) >= cnvtdatetime(omf_groupings->cap_nu[d2.seq].beg_effective_dt_tm)
        AND size(trim(omf_groupings->cap_nu[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
        omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].beg_transaction_dt_tm) BETWEEN
       cnvtdatetime(omf_groupings->cap_nu[d2.seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings
        ->cap_nu[d2.seq].end_effective_dt_tm))) )
      DETAIL
       omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].loc_nurse_unit_grp_cd =
       omf_groupings->cap_nu[d2.seq].grp_cd
      WITH nocounter
     ;end select
     SET v_grp_ndx = size(omf_groupings->cap_nu2,5)
     SELECT INTO "nl:"
      1
      FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d3  WITH seq = value(omf_encntr_st->max_inst_cnt)),
       (dummyt d2  WITH seq = value(v_grp_ndx))
      PLAN (d1)
       JOIN (d3
       WHERE (d3.seq <= omf_encntr_st->data[d1.seq].hist_list[1].inst_cnt)
        AND (omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].num_val3 > 0))
       JOIN (d2
       WHERE (omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].num_val3=omf_groupings->
       cap_nu2[d2.seq].nurse_unit_cd)
        AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].
        beg_transaction_dt_tm) >= cnvtdatetime(omf_groupings->cap_nu2[d2.seq].beg_effective_dt_tm)
        AND size(trim(omf_groupings->cap_nu2[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
        omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].beg_transaction_dt_tm) BETWEEN
       cnvtdatetime(omf_groupings->cap_nu2[d2.seq].beg_effective_dt_tm) AND cnvtdatetime(
        omf_groupings->cap_nu2[d2.seq].end_effective_dt_tm))) )
      DETAIL
       omf_encntr_st->data[d1.seq].hist_list[1].instance[d3.seq].loc_nurse_unit_grp2_cd =
       omf_groupings->cap_nu2[d2.seq].grp_cd
      WITH nocounter
     ;end select
     CALL echo("...exiting OMF_PM_ADT_HIST <include file>")
     IF (v_utc_on_ind=1)
      SET tz->m_id = concat(trim(omf_encntr_st->data[1].time_zone),char(0))
      CALL uar_datesettimezone(tz)
     ENDIF
     SELECT INTO "nl"
      svc.svc_cat_hist_id, svc.encntr_id, svc.transaction_dt_tm
      FROM service_category_hist svc,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (svc
       WHERE (svc.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
      ORDER BY svc.encntr_id, svc.transaction_dt_tm
      HEAD REPORT
       ndx = 0
      HEAD svc.encntr_id
       ndx = 0
      DETAIL
       ndx += 1
       IF (mod(ndx,10)=1)
        stat = alterlist(omf_encntr_st->data[d1.seq].svc_cat,(ndx+ 9))
       ENDIF
       omf_encntr_st->data[d1.seq].svc_cat[ndx].svc_cat_hist_id = svc.svc_cat_hist_id, omf_encntr_st
       ->data[d1.seq].svc_cat[ndx].med_service_cd = svc.med_service_cd, omf_encntr_st->data[d1.seq].
       svc_cat[ndx].service_category_cd = svc.service_category_cd,
       omf_encntr_st->data[d1.seq].svc_cat[ndx].att_prsnl_id = svc.attend_prsnl_id, omf_encntr_st->
       data[d1.seq].svc_cat[ndx].beg_transaction_dt_tm = evaluate(v_utc_on_ind,1,format(
         cnvtdatetimeutc(svc.transaction_dt_tm,3),"dd-mmm-yyyy hh:mm:ss;;d"),format(svc
         .transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
       IF (size(trim(omf_encntr_st->data[d1.seq].svc_cat[ndx].beg_transaction_dt_tm))=0)
        omf_encntr_st->data[d1.seq].svc_cat[ndx].beg_transaction_dt_nbr = - (1), omf_encntr_st->data[
        d1.seq].svc_cat[ndx].beg_transaction_min_nbr = - (1)
       ELSE
        omf_encntr_st->data[d1.seq].svc_cat[ndx].beg_transaction_dt_nbr = cnvtdate(svc
         .transaction_dt_tm), omf_encntr_st->data[d1.seq].svc_cat[ndx].beg_transaction_min_nbr = (
        cnvtmin(svc.transaction_dt_tm,5)+ 1)
       ENDIF
       omf_encntr_st->data[d1.seq].svc_cat[ndx].end_transaction_dt_nbr = - (1), omf_encntr_st->data[
       d1.seq].svc_cat[ndx].end_transaction_min_nbr = - (1)
       IF (ndx > 1)
        omf_encntr_st->data[d1.seq].svc_cat[ndx].prev_service_category_cd = omf_encntr_st->data[d1
        .seq].svc_cat[(ndx - 1)].service_category_cd, omf_encntr_st->data[d1.seq].svc_cat[(ndx - 1)].
        end_transaction_dt_tm = evaluate(v_utc_on_ind,1,format(cnvtdatetimeutc(svc.transaction_dt_tm,
           3),"dd-mmm-yyyy hh:mm:ss;;d"),format(svc.transaction_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
        IF (size(trim(omf_encntr_st->data[d1.seq].svc_cat[(ndx - 1)].end_transaction_dt_tm)) > 0)
         omf_encntr_st->data[d1.seq].svc_cat[(ndx - 1)].end_transaction_dt_nbr = cnvtdate(svc
          .transaction_dt_tm), omf_encntr_st->data[d1.seq].svc_cat[(ndx - 1)].end_transaction_min_nbr
          = (cnvtmin(svc.transaction_dt_tm,5)+ 1)
        ENDIF
       ENDIF
      FOOT  svc.encntr_id
       stat = alterlist(omf_encntr_st->data[d1.seq].svc_cat,ndx)
       IF ((ndx > omf_encntr_st->max_svc_cat_cnt))
        omf_encntr_st->max_svc_cat_cnt = ndx
       ENDIF
       omf_encntr_st->data[d1.seq].svc_cat_cnt = ndx
       IF (v_utc_on_ind=1
        AND ((d1.seq+ 1) <= v_encntr_ndx))
        v_time_zone = omf_encntr_st->data[(d1.seq+ 1)].time_zone, tz->m_id = concat(trim(v_time_zone),
         char(0)), stat = uar_datesettimezone(tz)
       ENDIF
      WITH nocounter
     ;end select
     SET v_grp_ndx = size(omf_groupings->cap_phys,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d3  WITH seq = value(omf_encntr_st->max_svc_cat_cnt)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d3
        WHERE (d3.seq <= omf_encntr_st->data[d1.seq].svc_cat_cnt)
         AND (omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_id > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_id=omf_groupings->cap_phys[d2
        .seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_phys[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime(
         omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_phys[d2.seq
         ].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_phys[d2.seq].end_effective_dt_tm)
        )) )
       DETAIL
        omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_grp_cd = omf_groupings->cap_phys[d2.seq
        ].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SET v_grp_ndx = size(omf_groupings->cap_medspec,5)
     IF (v_grp_ndx > 0)
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(v_encntr_ndx)),
        (dummyt d3  WITH seq = value(omf_encntr_st->max_svc_cat_cnt)),
        (dummyt d2  WITH seq = value(v_grp_ndx))
       PLAN (d1
        WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
        JOIN (d3
        WHERE (d3.seq <= omf_encntr_st->data[d1.seq].svc_cat_cnt)
         AND (omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_id > 0))
        JOIN (d2
        WHERE (omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_id=omf_groupings->cap_medspec[d2
        .seq].phys_id)
         AND ((cnvtdatetime(omf_encntr_st->data[d1.seq].visit_dt_tm) >= cnvtdatetime(omf_groupings->
         cap_medspec[d2.seq].beg_effective_dt_tm)
         AND size(trim(omf_groupings->cap_medspec[d2.seq].end_effective_dt_tm,3))=0) OR (cnvtdatetime
        (omf_encntr_st->data[d1.seq].visit_dt_tm) BETWEEN cnvtdatetime(omf_groupings->cap_medspec[d2
         .seq].beg_effective_dt_tm) AND cnvtdatetime(omf_groupings->cap_medspec[d2.seq].
         end_effective_dt_tm))) )
       DETAIL
        omf_encntr_st->data[d1.seq].svc_cat[d3.seq].att_prsnl_med_spec_cd = omf_groupings->
        cap_medspec[d2.seq].grp_cd
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl"
      oschs.updt_cnt
      FROM omf_svc_cat_hist_st oschs,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_svc_cat_cnt))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].svc_cat_cnt))
       JOIN (oschs
       WHERE (oschs.svc_cat_hist_id=omf_encntr_st->data[d1.seq].svc_cat[d2.seq].svc_cat_hist_id)
        AND oschs.svc_cat_hist_id > 0)
      DETAIL
       omf_encntr_st->data[d1.seq].svc_cat[d2.seq].updt_cnt = (oschs.updt_cnt+ 1)
      WITH nocounter
     ;end select
     DELETE  FROM omf_svc_cat_hist_st oschs,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_svc_cat_cnt))
      SET oschs.encntr_id = 1
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].svc_cat_cnt))
       JOIN (oschs
       WHERE (oschs.svc_cat_hist_id=omf_encntr_st->data[d1.seq].svc_cat[d2.seq].svc_cat_hist_id)
        AND oschs.svc_cat_hist_id > 0)
     ;end delete
     INSERT  FROM omf_svc_cat_hist_st oschs,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_svc_cat_cnt))
      SET oschs.svc_cat_hist_id = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].svc_cat_hist_id, oschs
       .encntr_id = omf_encntr_st->data[d1.seq].encntr_id, oschs.med_service_cd = omf_encntr_st->
       data[d1.seq].svc_cat[d2.seq].med_service_cd,
       oschs.service_category_cd = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].service_category_cd,
       oschs.prev_service_category_cd = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].
       prev_service_category_cd, oschs.att_prsnl_id = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].
       att_prsnl_id,
       oschs.att_prsnl_grp_cd = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].att_prsnl_grp_cd, oschs
       .att_prsnl_med_spec_cd = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].att_prsnl_med_spec_cd,
       oschs.attend_phys_position_cd = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].
       attend_phys_position_cd,
       oschs.beg_transaction_dt_nbr = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].
       beg_transaction_dt_nbr, oschs.beg_transaction_min_nbr = omf_encntr_st->data[d1.seq].svc_cat[d2
       .seq].beg_transaction_min_nbr, oschs.beg_transaction_dt_tm = evaluate(v_utc_on_ind,1,
        cnvtdatetimeutc(omf_encntr_st->data[d1.seq].svc_cat[d2.seq].beg_transaction_dt_tm,0),
        cnvtdatetime(omf_encntr_st->data[d1.seq].svc_cat[d2.seq].beg_transaction_dt_tm)),
       oschs.beg_transaction_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oschs
       .end_transaction_dt_nbr = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].end_transaction_dt_nbr,
       oschs.end_transaction_min_nbr = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].
       end_transaction_min_nbr,
       oschs.end_transaction_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d1
         .seq].svc_cat[d2.seq].end_transaction_dt_tm,0),cnvtdatetime(omf_encntr_st->data[d1.seq].
         svc_cat[d2.seq].end_transaction_dt_tm)), oschs.end_transaction_tz = omf_encntr_st->data[d1
       .seq].time_zone_indx, oschs.updt_id = reqinfo->updt_id,
       oschs.updt_cnt = omf_encntr_st->data[d1.seq].svc_cat[d2.seq].updt_cnt, oschs.updt_applctx =
       reqinfo->updt_applctx, oschs.updt_task = reqinfo->updt_task,
       oschs.updt_dt_tm = cnvtdatetime(sysdate)
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].svc_cat_cnt))
       JOIN (oschs)
     ;end insert
     CALL echo("Entering OMF_ENCNTR_ST_MERGE <include file mod 003.....")
     RECORD chk_reply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     EXECUTE omf_chk_temp_def  WITH replace("REPLY","CHK_REPLY")
     SELECT INTO TABLE cust_oes_temp
      t_encntr_id = type("f8"), t_person_id = type("f8"), t_visit_ind = type("i2"),
      t_admit_ind = type("i2"), t_visit_dt_tm = type("dq8"), t_visit_dt_nbr = type("i4"),
      t_visit_min_nbr = type("i4"), t_icd9_admit_diag_nomen_id = type("f8"), t_death_ind = type("i2"),
      t_death_dt_tm = type("dq8"), t_death_dt_nbr = type("i4"), t_death_min_nbr = type("i4"),
      t_last_ip_disch_dt_tm = type("dq8"), t_disch_ind = type("i4"), t_disch_dt_tm = type("dq8"),
      t_disch_dt_nbr = type("i4"), t_disch_min_nbr = type("i4"), t_exp_pm_disch_dt_tm = type("dq8"),
      t_exp_pm_disch_dt_nbr = type("i4"), t_exp_pm_disch_min_nbr = type("i4"), t_disch_disposition_cd
       = type("f8"),
      t_disch_to_loctn_cd = type("f8"), t_admit_src_cd = type("f8"), t_admit_type_cd = type("f8"),
      t_admit_phys_id = type("f8"), t_admit_phys_key = type("vc255"), t_admit_phys_ft_name = type(
       "vc255"),
      t_admit_phys_grp_cd = type("f8"), t_admit_phys_med_spec_cd = type("f8"), t_ambulatory_cond_cd
       = type("f8"),
      t_att_phys_id = type("f8"), t_att_phys_key = type("vc255"), t_att_phys_ft_name = type("vc255"),
      t_att_phys_grp_cd = type("f8"), t_att_phys_med_spec_cd = type("f8"), t_ethnic_grp_cd = type(
       "f8"),
      t_sex_cd = type("f8"), t_fin_class_cd = type("f8"), t_race_cd = type("f8"),
      t_language_cd = type("f8"), t_religion_cd = type("f8"), t_vip_cd = type("f8"),
      t_encntr_type_cd = type("f8"), t_encntr_type_class_cd = type("f8"), t_birth_dt_tm = type("dq8"),
      t_birth_date = type("vc25"), t_marital_status_cd = type("f8"), t_ref_phys_id = type("f8"),
      t_ref_phys_key = type("vc255"), t_ref_phys_ft_name = type("vc255"), t_ref_phys_med_spec_cd =
      type("f8"),
      t_pcp_phys_id = type("f8"), t_pcp_phys_key = type("vc255"), t_pcp_phys_ft_name = type("vc255"),
      t_pcp_phys_grp_cd = type("f8"), t_pcp_phys_med_spec_cd = type("f8"), t_med_serv_cd = type("f8"),
      t_med_serv_grp_cd = type("f8"), t_accommodation_cd = type("f8"), t_transfer_reason_cd = type(
       "f8"),
      t_prev_pat_loc_nu_cd = type("f8"), t_prev_encntr_id = type("f8"), t_prev_inp_encntr_id = type(
       "f8"),
      t_curr_pat_loc_arrive_dt_tm = type("dq8"), t_curr_pat_loc_bed_cd = type("f8"),
      t_curr_pat_loc_bdg_cd = type("f8"),
      t_curr_pat_loc_fac_cd = type("f8"), t_curr_pat_loc_fac_grp_cd = type("f8"),
      t_curr_pat_loc_nu_cd = type("f8"),
      t_curr_pat_loc_nu_grp_cd = type("f8"), t_curr_pat_loc_nu_grp2_cd = type("f8"),
      t_curr_pat_loc_room_cd = type("f8"),
      t_admit_pat_loc_bed_cd = type("f8"), t_admit_pat_loc_bdg_cd = type("f8"),
      t_admit_pat_loc_fac_cd = type("f8"),
      t_admit_pat_loc_nu_cd = type("f8"), t_admit_pat_loc_room_cd = type("f8"), t_age_days = type(
       "i4"),
      t_age_years = type("i4"), t_age_years_grp_cd = type("f8"), t_age_days_grp_cd = type("f8"),
      t_admit_7d_ladmit_ind = type("i2"), t_admit_15d_ladmit_ind = type("i2"), t_admit_24h_ladmit_ind
       = type("i2"),
      t_admit_30d_ladmit_ind = type("i2"), t_admit_48d_ladmit_ind = type("i2"),
      t_admit_48h_ladmit_ind = type("i2"),
      t_readmit_24h_48h_ind = type("i2"), t_readmit_7d_15d_ind = type("i2"), t_readmit_15d_30d_ind =
      type("i2"),
      t_readmit_30d_48d_ind = type("i2"), t_readmit_gt_48d_ind = type("i2"), t_readmit_gt_72h_ind =
      type("i2"),
      t_readmit_48h_72h_ind = type("i2"), t_return_ed_24h_ind = type("i2"), t_return_ed_48h_ind =
      type("i2"),
      t_return_ed_72h_ind = type("i2"), t_return_ed_24h_48h_ind = type("i2"), t_return_ed_49h_72h_ind
       = type("i2"),
      t_death_24h_admit_ind = type("i2"), t_death_24h_visit_ind = type("i2"),
      t_coordination_of_benefits_cd = type("f8"),
      t_prim_ins_assign_benefits_cd = type("f8"), t_prim_ins_organization_id = type("f8"),
      t_prim_emp_organization_id = type("f8"),
      t_emp_organization_id = type("f8"), t_prim_ins_person_id = type("f8"), t_prim_health_plan_id =
      type("f8"),
      t_prim_ins_birth_dt_tm = type("dq8"), t_prim_ins_person_reltn_cd = type("f8"),
      t_prim_ins_beg_eff_dt_tm = type("dq8"),
      t_prim_ins_beg_eff_dt_nbr = type("i4"), t_prim_ins_beg_eff_min_nbr = type("i4"),
      t_prim_ins_end_eff_dt_tm = type("dq8"),
      t_prim_ins_end_eff_dt_nbr = type("i4"), t_prim_ins_end_eff_min_nbr = type("i4"),
      t_prim_ins_plan_type_cd = type("f8"),
      t_prim_health_plan_group_cd = type("f8"), t_prim_ins_group_cd = type("f8"),
      t_prim_org_plan_reltn_id = type("f8"),
      t_sec_health_plan_group_cd = type("f8"), t_sec_ins_group_cd = type("f8"),
      t_sec_ins_assign_benefits_cd = type("f8"),
      t_sec_ins_organization_id = type("f8"), t_sec_emp_organization_id = type("f8"),
      t_sec_ins_person_id = type("f8"),
      t_sec_health_plan_id = type("f8"), t_sec_ins_birth_dt_tm = type("dq8"),
      t_sec_ins_person_reltn_cd = type("f8"),
      t_sec_ins_beg_eff_dt_tm = type("dq8"), t_sec_ins_beg_eff_dt_nbr = type("i4"),
      t_sec_ins_beg_eff_min_nbr = type("i4"),
      t_sec_ins_end_eff_dt_tm = type("dq8"), t_sec_ins_end_eff_dt_nbr = type("i4"),
      t_sec_ins_end_eff_min_nbr = type("i4"),
      t_sec_ins_plan_type_cd = type("f8"), t_sec_org_plan_reltn_id = type("f8"),
      t_other_health_plan_group_cd = type("f8"),
      t_other_ins_group_cd = type("f8"), t_other_ins_assign_benefits_cd = type("f8"),
      t_other_ins_organization_id = type("f8"),
      t_other_emp_organization_id = type("f8"), t_other_ins_person_id = type("f8"),
      t_other_health_plan_id = type("f8"),
      t_other_ins_birth_dt_tm = type("dq8"), t_other_ins_person_reltn_cd = type("f8"),
      t_other_ins_beg_eff_dt_tm = type("dq8"),
      t_other_ins_beg_eff_dt_nbr = type("i4"), t_other_ins_beg_eff_mn_nbr = type("i4"),
      t_other_ins_end_eff_dt_tm = type("dq8"),
      t_other_ins_end_eff_dt_nbr = type("i4"), t_other_ins_end_eff_mn_nbr = type("i4"),
      t_other_ins_plan_type_cd = type("f8"),
      t_other_org_plan_reltn_id = type("f8"), t_triage_cd = type("f8"), t_service_category_cd = type(
       "f8"),
      t_encntr_class_cd = type("f8"), t_reason_for_visit = type("vc255"),
      t_person_home_zipcode_grp_cd = type("f8"),
      t_disch_shift_grp_cd = type("f8"), t_admit_shift_grp_cd = type("f8"), t_organization_id = type(
       "f8"),
      t_nbr_consults = type("i4"), t_isolation_cd = type("f8"), t_admit_phys_position_cd = type("f8"),
      t_attend_phys_position_cd = type("f8"), t_ref_phys_position_cd = type("f8"),
      t_pcp_phys_position_cd = type("f8"),
      t_updt_dt_tm = type("dq8"), t_updt_cnt = type("i4"), t_updt_id = type("f8"),
      t_updt_task = type("i4"), t_updt_applctx = type("f8")
      WITH organization = t, synonym = "CUST_OES_TEMP"
     ;end select
     INSERT  FROM cust_oes_temp c,
       (dummyt d  WITH seq = size(omf_encntr_st->data,5))
      SET c.t_encntr_id = omf_encntr_st->data[d.seq].encntr_id, c.t_person_id = omf_encntr_st->data[d
       .seq].person_id, c.t_visit_ind = omf_encntr_st->data[d.seq].visit_ind,
       c.t_admit_ind = omf_encntr_st->data[d.seq].admit_ind, c.t_visit_dt_tm = evaluate(v_utc_on_ind,
        1,cnvtdatetimeutc(omf_encntr_st->data[d.seq].visit_dt_tm,0),0,cnvtdatetime(omf_encntr_st->
         data[d.seq].visit_dt_tm)), c.t_visit_dt_nbr = omf_encntr_st->data[d.seq].visit_dt_nbr,
       c.t_visit_min_nbr = omf_encntr_st->data[d.seq].visit_min_nbr, c.t_icd9_admit_diag_nomen_id =
       omf_encntr_st->data[d.seq].icd9_admit_diag_nomen_id, c.t_death_ind = omf_encntr_st->data[d.seq
       ].death_ind,
       c.t_death_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq].
         death_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].death_dt_tm)), c.t_death_dt_nbr =
       omf_encntr_st->data[d.seq].death_dt_nbr, c.t_death_min_nbr = omf_encntr_st->data[d.seq].
       death_min_nbr,
       c.t_last_ip_disch_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq].
         last_ip_disch_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].last_ip_disch_dt_tm)), c
       .t_disch_ind = omf_encntr_st->data[d.seq].disch_ind, c.t_disch_dt_tm = evaluate(v_utc_on_ind,1,
        cnvtdatetimeutc(omf_encntr_st->data[d.seq].disch_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[
         d.seq].disch_dt_tm)),
       c.t_disch_dt_nbr = omf_encntr_st->data[d.seq].disch_dt_nbr, c.t_disch_min_nbr = omf_encntr_st
       ->data[d.seq].disch_min_nbr, c.t_exp_pm_disch_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(
         omf_encntr_st->data[d.seq].exp_pm_disch_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         exp_pm_disch_dt_tm)),
       c.t_exp_pm_disch_dt_nbr = omf_encntr_st->data[d.seq].exp_pm_disch_dt_nbr, c
       .t_exp_pm_disch_min_nbr = omf_encntr_st->data[d.seq].exp_pm_disch_min_nbr, c
       .t_disch_disposition_cd = omf_encntr_st->data[d.seq].disch_disposition_cd,
       c.t_disch_to_loctn_cd = omf_encntr_st->data[d.seq].disch_to_loc_cd, c.t_admit_src_cd =
       omf_encntr_st->data[d.seq].admit_src_cd, c.t_admit_type_cd = omf_encntr_st->data[d.seq].
       admit_type_cd,
       c.t_admit_phys_id = omf_encntr_st->data[d.seq].admit_phys_id, c.t_admit_phys_key =
       omf_encntr_st->data[d.seq].admit_phys_key, c.t_admit_phys_ft_name = omf_encntr_st->data[d.seq]
       .admit_phys_ft_name,
       c.t_admit_phys_grp_cd = omf_encntr_st->data[d.seq].admit_phys_grp_cd, c
       .t_admit_phys_med_spec_cd = omf_encntr_st->data[d.seq].admit_phys_med_spec_cd, c
       .t_ambulatory_cond_cd = omf_encntr_st->data[d.seq].ambulatory_cond_cd,
       c.t_att_phys_id = omf_encntr_st->data[d.seq].att_phys_id, c.t_att_phys_key = omf_encntr_st->
       data[d.seq].att_phys_key, c.t_att_phys_ft_name = omf_encntr_st->data[d.seq].att_phys_ft_name,
       c.t_att_phys_grp_cd = omf_encntr_st->data[d.seq].att_phys_grp_cd, c.t_att_phys_med_spec_cd =
       omf_encntr_st->data[d.seq].att_phys_med_spec_cd, c.t_ethnic_grp_cd = omf_encntr_st->data[d.seq
       ].ethnic_grp_cd,
       c.t_sex_cd = omf_encntr_st->data[d.seq].sex_cd, c.t_fin_class_cd = omf_encntr_st->data[d.seq].
       fin_class_cd, c.t_race_cd = omf_encntr_st->data[d.seq].race_cd,
       c.t_language_cd = omf_encntr_st->data[d.seq].language_cd, c.t_religion_cd = omf_encntr_st->
       data[d.seq].religion_cd, c.t_vip_cd = omf_encntr_st->data[d.seq].vip_cd,
       c.t_encntr_type_cd = omf_encntr_st->data[d.seq].encntr_type_cd, c.t_encntr_type_class_cd =
       omf_encntr_st->data[d.seq].encntr_type_class_cd, c.t_birth_dt_tm = evaluate(v_utc_on_ind,1,
        cnvtdatetimeutc(omf_encntr_st->data[d.seq].birth_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[
         d.seq].birth_dt_tm)),
       c.t_birth_date = omf_encntr_st->data[d.seq].birth_date, c.t_marital_status_cd = omf_encntr_st
       ->data[d.seq].marital_status_cd, c.t_ref_phys_id = omf_encntr_st->data[d.seq].ref_phys_id,
       c.t_ref_phys_key = omf_encntr_st->data[d.seq].ref_phys_key, c.t_ref_phys_ft_name =
       omf_encntr_st->data[d.seq].ref_phys_ft_name, c.t_ref_phys_med_spec_cd = omf_encntr_st->data[d
       .seq].ref_phys_med_spec_cd,
       c.t_pcp_phys_id = omf_encntr_st->data[d.seq].pcp_phys_id, c.t_pcp_phys_key = omf_encntr_st->
       data[d.seq].pcp_phys_key, c.t_pcp_phys_ft_name = omf_encntr_st->data[d.seq].pcp_phys_ft_name,
       c.t_pcp_phys_grp_cd = omf_encntr_st->data[d.seq].pcp_phys_grp_cd, c.t_pcp_phys_med_spec_cd =
       omf_encntr_st->data[d.seq].pcp_phys_med_spec_cd, c.t_med_serv_cd = omf_encntr_st->data[d.seq].
       med_serv_cd,
       c.t_med_serv_grp_cd = omf_encntr_st->data[d.seq].med_serv_grp_cd, c.t_accommodation_cd =
       omf_encntr_st->data[d.seq].accommodation_cd, c.t_transfer_reason_cd = omf_encntr_st->data[d
       .seq].transfer_reason_cd,
       c.t_prev_pat_loc_nu_cd = omf_encntr_st->data[d.seq].prev_pat_loc_nu_cd, c.t_prev_encntr_id =
       omf_encntr_st->data[d.seq].prev_encntr_id, c.t_prev_inp_encntr_id = omf_encntr_st->data[d.seq]
       .prev_inp_encntr_id,
       c.t_curr_pat_loc_arrive_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d
         .seq].curr_pat_loc_arrive_dt_tm,0),cnvtdatetime(omf_encntr_st->data[d.seq].
         curr_pat_loc_arrive_dt_tm)), c.t_curr_pat_loc_bed_cd = omf_encntr_st->data[d.seq].
       curr_pat_loc_bed_cd, c.t_curr_pat_loc_bdg_cd = omf_encntr_st->data[d.seq].curr_pat_loc_bdg_cd,
       c.t_curr_pat_loc_fac_cd = omf_encntr_st->data[d.seq].curr_pat_loc_fac_cd, c
       .t_curr_pat_loc_fac_grp_cd = omf_encntr_st->data[d.seq].curr_pat_loc_fac_grp_cd, c
       .t_curr_pat_loc_nu_cd = omf_encntr_st->data[d.seq].curr_pat_loc_nu_cd,
       c.t_curr_pat_loc_nu_grp_cd = omf_encntr_st->data[d.seq].curr_pat_loc_nu_grp_cd, c
       .t_curr_pat_loc_nu_grp2_cd = omf_encntr_st->data[d.seq].curr_pat_loc_nu_grp2_cd, c
       .t_curr_pat_loc_room_cd = omf_encntr_st->data[d.seq].curr_pat_loc_room_cd,
       c.t_admit_pat_loc_bed_cd = omf_encntr_st->data[d.seq].admit_pat_loc_bed_cd, c
       .t_admit_pat_loc_bdg_cd = omf_encntr_st->data[d.seq].admit_pat_loc_bdg_cd, c
       .t_admit_pat_loc_fac_cd = omf_encntr_st->data[d.seq].admit_pat_loc_fac_cd,
       c.t_admit_pat_loc_nu_cd = omf_encntr_st->data[d.seq].admit_pat_loc_nu_cd, c
       .t_admit_pat_loc_room_cd = omf_encntr_st->data[d.seq].admit_pat_loc_room_cd, c.t_age_days =
       omf_encntr_st->data[d.seq].age_days,
       c.t_age_years = omf_encntr_st->data[d.seq].age_years, c.t_age_years_grp_cd = omf_encntr_st->
       data[d.seq].age_years_grp_cd, c.t_age_days_grp_cd = omf_encntr_st->data[d.seq].age_days_grp_cd,
       c.t_admit_7d_ladmit_ind = omf_encntr_st->data[d.seq].admit_7d_ladmit_ind, c
       .t_admit_15d_ladmit_ind = omf_encntr_st->data[d.seq].admit_15d_ladmit_ind, c
       .t_admit_24h_ladmit_ind = omf_encntr_st->data[d.seq].admit_24h_ladmit_ind,
       c.t_admit_30d_ladmit_ind = omf_encntr_st->data[d.seq].admit_30d_ladmit_ind, c
       .t_admit_48d_ladmit_ind = omf_encntr_st->data[d.seq].admit_48d_ladmit_ind, c
       .t_admit_48h_ladmit_ind = omf_encntr_st->data[d.seq].admit_48h_ladmit_ind,
       c.t_readmit_24h_48h_ind = omf_encntr_st->data[d.seq].readmit_24h_48h_ind, c
       .t_readmit_7d_15d_ind = omf_encntr_st->data[d.seq].readmit_7d_15d_ind, c.t_readmit_15d_30d_ind
        = omf_encntr_st->data[d.seq].readmit_15d_30d_ind,
       c.t_readmit_30d_48d_ind = omf_encntr_st->data[d.seq].readmit_30d_48d_ind, c
       .t_readmit_gt_48d_ind = omf_encntr_st->data[d.seq].readmit_gt_48d_ind, c.t_readmit_gt_72h_ind
        = omf_encntr_st->data[d.seq].readmit_gt_72h_ind,
       c.t_readmit_48h_72h_ind = omf_encntr_st->data[d.seq].readmit_48h_72h_ind, c
       .t_return_ed_24h_ind = omf_encntr_st->data[d.seq].return_ed_24h_ind, c.t_return_ed_48h_ind =
       omf_encntr_st->data[d.seq].return_ed_48h_ind,
       c.t_return_ed_72h_ind = omf_encntr_st->data[d.seq].return_ed_72h_ind, c
       .t_return_ed_24h_48h_ind = omf_encntr_st->data[d.seq].return_ed_24h_48h_ind, c
       .t_return_ed_49h_72h_ind = omf_encntr_st->data[d.seq].return_ed_49h_72h_ind,
       c.t_death_24h_admit_ind = omf_encntr_st->data[d.seq].death_24h_admit_ind, c
       .t_death_24h_visit_ind = omf_encntr_st->data[d.seq].death_24h_visit_ind, c
       .t_coordination_of_benefits_cd = omf_encntr_st->data[d.seq].coordination_of_benefits_cd,
       c.t_prim_ins_assign_benefits_cd = omf_encntr_st->data[d.seq].prim_ins_assign_benefits_cd, c
       .t_prim_ins_organization_id = omf_encntr_st->data[d.seq].prim_ins_organization_id, c
       .t_prim_emp_organization_id = omf_encntr_st->data[d.seq].prim_emp_organization_id,
       c.t_emp_organization_id = omf_encntr_st->data[d.seq].emp_organization_id, c
       .t_prim_ins_person_id = omf_encntr_st->data[d.seq].prim_ins_person_id, c.t_prim_health_plan_id
        = omf_encntr_st->data[d.seq].prim_health_plan_id,
       c.t_prim_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq].
         prim_ins_birth_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].prim_ins_birth_dt_tm)), c
       .t_prim_ins_person_reltn_cd = omf_encntr_st->data[d.seq].prim_ins_person_reltn_cd, c
       .t_prim_ins_beg_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq]
         .prim_ins_beg_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         prim_ins_beg_effective_dt_tm)),
       c.t_prim_ins_beg_eff_dt_nbr = omf_encntr_st->data[d.seq].prim_ins_beg_effective_dt_nbr, c
       .t_prim_ins_beg_eff_min_nbr = omf_encntr_st->data[d.seq].prim_ins_beg_effective_min_nbr, c
       .t_prim_ins_end_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq]
         .prim_ins_end_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         prim_ins_end_effective_dt_tm)),
       c.t_prim_ins_end_eff_dt_nbr = omf_encntr_st->data[d.seq].prim_ins_end_effective_dt_nbr, c
       .t_prim_ins_end_eff_min_nbr = omf_encntr_st->data[d.seq].prim_ins_end_effective_min_nbr, c
       .t_prim_ins_plan_type_cd = omf_encntr_st->data[d.seq].prim_ins_plan_type_cd,
       c.t_prim_health_plan_group_cd = omf_encntr_st->data[d.seq].prim_health_plan_group_cd, c
       .t_prim_ins_group_cd = omf_encntr_st->data[d.seq].prim_ins_group_cd, c
       .t_prim_org_plan_reltn_id = omf_encntr_st->data[d.seq].prim_org_plan_reltn_id,
       c.t_sec_health_plan_group_cd = omf_encntr_st->data[d.seq].sec_health_plan_group_cd, c
       .t_sec_ins_group_cd = omf_encntr_st->data[d.seq].sec_ins_group_cd, c
       .t_sec_ins_assign_benefits_cd = omf_encntr_st->data[d.seq].sec_ins_assign_benefits_cd,
       c.t_sec_ins_organization_id = omf_encntr_st->data[d.seq].sec_ins_organization_id, c
       .t_sec_emp_organization_id = omf_encntr_st->data[d.seq].sec_emp_organization_id, c
       .t_sec_ins_person_id = omf_encntr_st->data[d.seq].sec_ins_person_id,
       c.t_sec_health_plan_id = omf_encntr_st->data[d.seq].sec_health_plan_id, c
       .t_sec_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq].
         sec_ins_birth_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].sec_ins_birth_dt_tm)), c
       .t_sec_ins_person_reltn_cd = omf_encntr_st->data[d.seq].sec_ins_person_reltn_cd,
       c.t_sec_ins_beg_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq]
         .sec_ins_beg_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         sec_ins_beg_effective_dt_tm)), c.t_sec_ins_beg_eff_dt_nbr = omf_encntr_st->data[d.seq].
       sec_ins_beg_effective_dt_nbr, c.t_sec_ins_beg_eff_min_nbr = omf_encntr_st->data[d.seq].
       sec_ins_beg_effective_min_nbr,
       c.t_sec_ins_end_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq]
         .sec_ins_end_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         sec_ins_end_effective_dt_tm)), c.t_sec_ins_end_eff_dt_nbr = omf_encntr_st->data[d.seq].
       sec_ins_end_effective_dt_nbr, c.t_sec_ins_end_eff_min_nbr = omf_encntr_st->data[d.seq].
       sec_ins_end_effective_min_nbr,
       c.t_sec_ins_plan_type_cd = omf_encntr_st->data[d.seq].sec_ins_plan_type_cd, c
       .t_sec_org_plan_reltn_id = omf_encntr_st->data[d.seq].sec_org_plan_reltn_id, c
       .t_other_health_plan_group_cd = omf_encntr_st->data[d.seq].other_health_plan_group_cd,
       c.t_other_ins_group_cd = omf_encntr_st->data[d.seq].other_ins_group_cd, c
       .t_other_ins_assign_benefits_cd = omf_encntr_st->data[d.seq].other_ins_assign_benefits_cd, c
       .t_other_ins_organization_id = omf_encntr_st->data[d.seq].other_ins_organization_id,
       c.t_other_emp_organization_id = omf_encntr_st->data[d.seq].other_emp_organization_id, c
       .t_other_ins_person_id = omf_encntr_st->data[d.seq].other_ins_person_id, c
       .t_other_health_plan_id = omf_encntr_st->data[d.seq].other_health_plan_id,
       c.t_other_ins_birth_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq]
         .other_ins_birth_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].other_ins_birth_dt_tm)),
       c.t_other_ins_person_reltn_cd = omf_encntr_st->data[d.seq].other_ins_person_reltn_cd, c
       .t_other_ins_beg_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq
         ].other_ins_beg_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         other_ins_beg_effective_dt_tm)),
       c.t_other_ins_beg_eff_dt_nbr = omf_encntr_st->data[d.seq].other_ins_beg_effective_dt_nbr, c
       .t_other_ins_beg_eff_mn_nbr = omf_encntr_st->data[d.seq].other_ins_beg_effective_min_nbr, c
       .t_other_ins_end_eff_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(omf_encntr_st->data[d.seq
         ].other_ins_end_effective_dt_tm,0),0,cnvtdatetime(omf_encntr_st->data[d.seq].
         other_ins_end_effective_dt_tm)),
       c.t_other_ins_end_eff_dt_nbr = omf_encntr_st->data[d.seq].other_ins_end_effective_dt_nbr, c
       .t_other_ins_end_eff_mn_nbr = omf_encntr_st->data[d.seq].other_ins_end_effective_min_nbr, c
       .t_other_ins_plan_type_cd = omf_encntr_st->data[d.seq].other_ins_plan_type_cd,
       c.t_other_org_plan_reltn_id = omf_encntr_st->data[d.seq].other_org_plan_reltn_id, c
       .t_triage_cd = omf_encntr_st->data[d.seq].triage_cd, c.t_service_category_cd = omf_encntr_st->
       data[d.seq].service_category_cd,
       c.t_encntr_class_cd = omf_encntr_st->data[d.seq].encntr_class_cd, c.t_reason_for_visit =
       omf_encntr_st->data[d.seq].reason_for_visit, c.t_person_home_zipcode_grp_cd = omf_encntr_st->
       data[d.seq].person_home_zipcode_grp_cd,
       c.t_disch_shift_grp_cd = omf_encntr_st->data[d.seq].disch_shift_grp_cd, c.t_admit_shift_grp_cd
        = omf_encntr_st->data[d.seq].admit_shift_grp_cd, c.t_organization_id = omf_encntr_st->data[d
       .seq].organization_id,
       c.t_nbr_consults = omf_encntr_st->data[d.seq].nbr_consults, c.t_isolation_cd = omf_encntr_st->
       data[d.seq].isolation_cd, c.t_admit_phys_position_cd = omf_encntr_st->data[d.seq].
       admit_phys_position_cd,
       c.t_attend_phys_position_cd = omf_encntr_st->data[d.seq].attend_phys_position_cd, c
       .t_ref_phys_position_cd = omf_encntr_st->data[d.seq].ref_phys_position_cd, c
       .t_pcp_phys_position_cd = omf_encntr_st->data[d.seq].pcp_phys_position_cd,
       c.t_updt_dt_tm = cnvtdatetime(curdate,curtime), c.t_updt_cnt = 1, c.t_updt_id = reqinfo->
       updt_id,
       c.t_updt_task = reqinfo->updt_task, c.t_updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (c)
      WITH nocounter
     ;end insert
     MERGE INTO omf_encntr_st oes
     USING (SELECT
      t.*
      FROM cust_oes_temp t
      WHERE t.t_encntr_id > 0.0)
     C ON (c.t_encntr_id=oes.encntr_id)
     WHEN MATCHED THEN
     (UPDATE
      SET oes.person_id = c.t_person_id, oes.visit_ind = c.t_visit_ind, oes.admit_ind = c.t_admit_ind,
       oes.visit_dt_tm = c.t_visit_dt_tm, oes.visit_dt_nbr = c.t_visit_dt_nbr, oes.visit_min_nbr = c
       .t_visit_min_nbr,
       oes.icd9_admit_diag_nomen_id = c.t_icd9_admit_diag_nomen_id, oes.death_ind = c.t_death_ind,
       oes.death_dt_tm = c.t_death_dt_tm,
       oes.death_dt_nbr = c.t_death_dt_nbr, oes.death_min_nbr = c.t_death_min_nbr, oes
       .last_ip_disch_dt_tm = c.t_last_ip_disch_dt_tm,
       oes.disch_ind = c.t_disch_ind, oes.disch_dt_tm = c.t_disch_dt_tm, oes.disch_dt_nbr = c
       .t_disch_dt_nbr,
       oes.disch_min_nbr = c.t_disch_min_nbr, oes.exp_pm_disch_dt_tm = c.t_exp_pm_disch_dt_tm, oes
       .exp_pm_disch_dt_nbr = c.t_exp_pm_disch_dt_nbr,
       oes.exp_pm_disch_min_nbr = c.t_exp_pm_disch_min_nbr, oes.disch_disposition_cd = c
       .t_disch_disposition_cd, oes.disch_to_loctn_cd = c.t_disch_to_loctn_cd,
       oes.admit_src_cd = c.t_admit_src_cd, oes.admit_type_cd = c.t_admit_type_cd, oes.admit_phys_id
        = c.t_admit_phys_id,
       oes.admit_phys_key = c.t_admit_phys_key, oes.admit_phys_ft_name = c.t_admit_phys_ft_name, oes
       .admit_phys_grp_cd = c.t_admit_phys_grp_cd,
       oes.admit_phys_med_spec_cd = c.t_admit_phys_med_spec_cd, oes.ambulatory_cond_cd = c
       .t_ambulatory_cond_cd, oes.att_phys_id = c.t_att_phys_id,
       oes.att_phys_key = c.t_att_phys_key, oes.att_phys_ft_name = c.t_att_phys_ft_name, oes
       .att_phys_grp_cd = c.t_att_phys_grp_cd,
       oes.att_phys_med_spec_cd = c.t_att_phys_med_spec_cd, oes.ethnic_grp_cd = c.t_ethnic_grp_cd,
       oes.sex_cd = c.t_sex_cd,
       oes.fin_class_cd = c.t_fin_class_cd, oes.race_cd = c.t_race_cd, oes.language_cd = c
       .t_language_cd,
       oes.religion_cd = c.t_religion_cd, oes.vip_cd = c.t_vip_cd, oes.encntr_type_cd = c
       .t_encntr_type_cd,
       oes.encntr_type_class_cd = c.t_encntr_type_class_cd, oes.birth_dt_tm = c.t_birth_dt_tm, oes
       .birth_date = c.t_birth_date,
       oes.marital_status_cd = c.t_marital_status_cd, oes.ref_phys_id = c.t_ref_phys_id, oes
       .ref_phys_key = c.t_ref_phys_key,
       oes.ref_phys_ft_name = c.t_ref_phys_ft_name, oes.ref_phys_med_spec_cd = c
       .t_ref_phys_med_spec_cd, oes.pcp_phys_id = c.t_pcp_phys_id,
       oes.pcp_phys_key = c.t_pcp_phys_key, oes.pcp_phys_ft_name = c.t_pcp_phys_ft_name, oes
       .pcp_phys_grp_cd = c.t_pcp_phys_grp_cd,
       oes.pcp_phys_med_spec_cd = c.t_pcp_phys_med_spec_cd, oes.med_serv_cd = c.t_med_serv_cd, oes
       .med_serv_grp_cd = c.t_med_serv_grp_cd,
       oes.accommodation_cd = c.t_accommodation_cd, oes.transfer_reason_cd = c.t_transfer_reason_cd,
       oes.prev_pat_loc_nu_cd = c.t_prev_pat_loc_nu_cd,
       oes.prev_encntr_id = c.t_prev_encntr_id, oes.prev_inp_encntr_id = c.t_prev_inp_encntr_id, oes
       .curr_pat_loc_arrive_dt_tm = c.t_curr_pat_loc_arrive_dt_tm,
       oes.curr_pat_loc_bed_cd = c.t_curr_pat_loc_bed_cd, oes.curr_pat_loc_bdg_cd = c
       .t_curr_pat_loc_bdg_cd, oes.curr_pat_loc_fac_cd = c.t_curr_pat_loc_fac_cd,
       oes.curr_pat_loc_fac_grp_cd = c.t_curr_pat_loc_fac_grp_cd, oes.curr_pat_loc_nu_cd = c
       .t_curr_pat_loc_nu_cd, oes.curr_pat_loc_nu_grp_cd = c.t_curr_pat_loc_nu_grp_cd,
       oes.curr_pat_loc_nu_grp2_cd = c.t_curr_pat_loc_nu_grp2_cd, oes.curr_pat_loc_room_cd = c
       .t_curr_pat_loc_room_cd, oes.admit_pat_loc_bed_cd = c.t_admit_pat_loc_bed_cd,
       oes.admit_pat_loc_bdg_cd = c.t_admit_pat_loc_bdg_cd, oes.admit_pat_loc_fac_cd = c
       .t_admit_pat_loc_fac_cd, oes.admit_pat_loc_nu_cd = c.t_admit_pat_loc_nu_cd,
       oes.admit_pat_loc_room_cd = c.t_admit_pat_loc_room_cd, oes.age_days = c.t_age_days, oes
       .age_years = c.t_age_years,
       oes.age_years_grp_cd = c.t_age_years_grp_cd, oes.age_days_grp_cd = c.t_age_days_grp_cd, oes
       .admit_7d_ladmit_ind = c.t_admit_7d_ladmit_ind,
       oes.admit_15d_ladmit_ind = c.t_admit_15d_ladmit_ind, oes.admit_24h_ladmit_ind = c
       .t_admit_24h_ladmit_ind, oes.admit_30d_ladmit_ind = c.t_admit_30d_ladmit_ind,
       oes.admit_48d_ladmit_ind = c.t_admit_48d_ladmit_ind, oes.admit_48h_ladmit_ind = c
       .t_admit_48h_ladmit_ind, oes.readmit_24h_48h_ind = c.t_readmit_24h_48h_ind,
       oes.readmit_7d_15d_ind = c.t_readmit_7d_15d_ind, oes.readmit_15d_30d_ind = c
       .t_readmit_15d_30d_ind, oes.readmit_30d_48d_ind = c.t_readmit_30d_48d_ind,
       oes.readmit_gt_48d_ind = c.t_readmit_gt_48d_ind, oes.readmit_gt_72h_ind = c
       .t_readmit_gt_72h_ind, oes.readmit_48h_72h_ind = c.t_readmit_48h_72h_ind,
       oes.return_ed_24h_ind = c.t_return_ed_24h_ind, oes.return_ed_48h_ind = c.t_return_ed_48h_ind,
       oes.return_ed_72h_ind = c.t_return_ed_72h_ind,
       oes.return_ed_24h_48h_ind = c.t_return_ed_24h_48h_ind, oes.return_ed_49h_72h_ind = c
       .t_return_ed_49h_72h_ind, oes.death_24h_admit_ind = c.t_death_24h_admit_ind,
       oes.death_24h_visit_ind = c.t_death_24h_visit_ind, oes.coordination_of_benefits_cd = c
       .t_coordination_of_benefits_cd, oes.prim_ins_assign_benefits_cd = c
       .t_prim_ins_assign_benefits_cd,
       oes.prim_ins_organization_id = c.t_prim_ins_organization_id, oes.prim_emp_organization_id = c
       .t_prim_emp_organization_id, oes.emp_organization_id = c.t_emp_organization_id,
       oes.prim_ins_person_id = c.t_prim_ins_person_id, oes.prim_health_plan_id = c
       .t_prim_health_plan_id, oes.prim_ins_birth_dt_tm = c.t_prim_ins_birth_dt_tm,
       oes.prim_ins_person_reltn_cd = c.t_prim_ins_person_reltn_cd, oes.prim_ins_beg_effective_dt_tm
        = c.t_prim_ins_beg_eff_dt_tm, oes.prim_ins_beg_effective_dt_nbr = c.t_prim_ins_beg_eff_dt_nbr,
       oes.prim_ins_beg_effective_min_nbr = c.t_prim_ins_beg_eff_min_nbr, oes
       .prim_ins_end_effective_dt_tm = c.t_prim_ins_end_eff_dt_tm, oes.prim_ins_end_effective_dt_nbr
        = c.t_prim_ins_end_eff_dt_nbr,
       oes.prim_ins_end_effective_min_nbr = c.t_prim_ins_end_eff_min_nbr, oes.prim_ins_plan_type_cd
        = c.t_prim_ins_plan_type_cd, oes.prim_health_plan_group_cd = c.t_prim_health_plan_group_cd,
       oes.prim_ins_group_cd = c.t_prim_ins_group_cd, oes.prim_org_plan_reltn_id = c
       .t_prim_org_plan_reltn_id, oes.sec_health_plan_group_cd = c.t_sec_health_plan_group_cd,
       oes.sec_ins_group_cd = c.t_sec_ins_group_cd, oes.sec_ins_assign_benefits_cd = c
       .t_sec_ins_assign_benefits_cd, oes.sec_ins_organization_id = c.t_sec_ins_organization_id,
       oes.sec_emp_organization_id = c.t_sec_emp_organization_id, oes.sec_ins_person_id = c
       .t_sec_ins_person_id, oes.sec_health_plan_id = c.t_sec_health_plan_id,
       oes.sec_ins_birth_dt_tm = c.t_sec_ins_birth_dt_tm, oes.sec_ins_person_reltn_cd = c
       .t_sec_ins_person_reltn_cd, oes.sec_ins_beg_effective_dt_tm = c.t_sec_ins_beg_eff_dt_tm,
       oes.sec_ins_beg_effective_dt_nbr = c.t_sec_ins_beg_eff_dt_nbr, oes
       .sec_ins_beg_effective_min_nbr = c.t_sec_ins_beg_eff_min_nbr, oes.sec_ins_end_effective_dt_tm
        = c.t_sec_ins_end_eff_dt_tm,
       oes.sec_ins_end_effective_dt_nbr = c.t_sec_ins_end_eff_dt_nbr, oes
       .sec_ins_end_effective_min_nbr = c.t_sec_ins_end_eff_min_nbr, oes.sec_ins_plan_type_cd = c
       .t_sec_ins_plan_type_cd,
       oes.sec_org_plan_reltn_id = c.t_sec_org_plan_reltn_id, oes.other_health_plan_group_cd = c
       .t_other_health_plan_group_cd, oes.other_ins_group_cd = c.t_other_ins_group_cd,
       oes.other_ins_assign_benefits_cd = c.t_other_ins_assign_benefits_cd, oes
       .other_ins_organization_id = c.t_other_ins_organization_id, oes.other_emp_organization_id = c
       .t_other_emp_organization_id,
       oes.other_ins_person_id = c.t_other_ins_person_id, oes.other_health_plan_id = c
       .t_other_health_plan_id, oes.other_ins_birth_dt_tm = c.t_other_ins_birth_dt_tm,
       oes.other_ins_person_reltn_cd = c.t_other_ins_person_reltn_cd, oes
       .other_ins_beg_effective_dt_tm = c.t_other_ins_beg_eff_dt_tm, oes
       .other_ins_beg_effective_dt_nbr = c.t_other_ins_beg_eff_dt_nbr,
       oes.other_ins_beg_effective_mn_nbr = c.t_other_ins_beg_eff_mn_nbr, oes
       .other_ins_end_effective_dt_tm = c.t_other_ins_end_eff_dt_tm, oes
       .other_ins_end_effective_dt_nbr = c.t_other_ins_end_eff_dt_nbr,
       oes.other_ins_end_effective_mn_nbr = c.t_other_ins_end_eff_mn_nbr, oes.other_ins_plan_type_cd
        = c.t_other_ins_plan_type_cd, oes.other_org_plan_reltn_id = c.t_other_org_plan_reltn_id,
       oes.triage_cd = c.t_triage_cd, oes.service_category_cd = c.t_service_category_cd, oes
       .encntr_class_cd = c.t_encntr_class_cd,
       oes.reason_for_visit = c.t_reason_for_visit, oes.person_home_zipcode_grp_cd = c
       .t_person_home_zipcode_grp_cd, oes.disch_shift_grp_cd = c.t_disch_shift_grp_cd,
       oes.admit_shift_grp_cd = c.t_admit_shift_grp_cd, oes.organization_id = c.t_organization_id,
       oes.nbr_consults = c.t_nbr_consults,
       oes.isolation_cd = c.t_isolation_cd, oes.admit_phys_position_cd = c.t_admit_phys_position_cd,
       oes.attend_phys_position_cd = c.t_attend_phys_position_cd,
       oes.ref_phys_position_cd = c.t_ref_phys_position_cd, oes.pcp_phys_position_cd = c
       .t_pcp_phys_position_cd, oes.updt_dt_tm = c.t_updt_dt_tm,
       oes.updt_cnt = (oes.updt_cnt+ 1), oes.updt_id = c.t_updt_id, oes.updt_task = c.t_updt_task,
       oes.updt_applctx = c.t_updt_applctx
      WHERE oes.encntr_id=c.t_encntr_id
     ;end update
     )
     WHEN NOT MATCHED THEN
     (INSERT  FROM oes
      (oes.encntr_id, oes.person_id, oes.visit_ind,
      oes.admit_ind, oes.visit_dt_tm, oes.visit_dt_nbr,
      oes.visit_min_nbr, oes.icd9_admit_diag_nomen_id, oes.death_ind,
      oes.death_dt_tm, oes.death_dt_nbr, oes.death_min_nbr,
      oes.last_ip_disch_dt_tm, oes.disch_ind, oes.disch_dt_tm,
      oes.disch_dt_nbr, oes.disch_min_nbr, oes.exp_pm_disch_dt_tm,
      oes.exp_pm_disch_dt_nbr, oes.exp_pm_disch_min_nbr, oes.disch_disposition_cd,
      oes.disch_to_loctn_cd, oes.admit_src_cd, oes.admit_type_cd,
      oes.admit_phys_id, oes.admit_phys_key, oes.admit_phys_ft_name,
      oes.admit_phys_grp_cd, oes.admit_phys_med_spec_cd, oes.ambulatory_cond_cd,
      oes.att_phys_id, oes.att_phys_key, oes.att_phys_ft_name,
      oes.att_phys_grp_cd, oes.att_phys_med_spec_cd, oes.ethnic_grp_cd,
      oes.sex_cd, oes.fin_class_cd, oes.race_cd,
      oes.language_cd, oes.religion_cd, oes.vip_cd,
      oes.encntr_type_cd, oes.encntr_type_class_cd, oes.birth_dt_tm,
      oes.birth_date, oes.marital_status_cd, oes.ref_phys_id,
      oes.ref_phys_key, oes.ref_phys_ft_name, oes.ref_phys_med_spec_cd,
      oes.pcp_phys_id, oes.pcp_phys_key, oes.pcp_phys_ft_name,
      oes.pcp_phys_grp_cd, oes.pcp_phys_med_spec_cd, oes.med_serv_cd,
      oes.med_serv_grp_cd, oes.accommodation_cd, oes.transfer_reason_cd,
      oes.prev_pat_loc_nu_cd, oes.prev_encntr_id, oes.prev_inp_encntr_id,
      oes.curr_pat_loc_arrive_dt_tm, oes.curr_pat_loc_bed_cd, oes.curr_pat_loc_bdg_cd,
      oes.curr_pat_loc_fac_cd, oes.curr_pat_loc_fac_grp_cd, oes.curr_pat_loc_nu_cd,
      oes.curr_pat_loc_nu_grp_cd, oes.curr_pat_loc_nu_grp2_cd, oes.curr_pat_loc_room_cd,
      oes.admit_pat_loc_bed_cd, oes.admit_pat_loc_bdg_cd, oes.admit_pat_loc_fac_cd,
      oes.admit_pat_loc_nu_cd, oes.admit_pat_loc_room_cd, oes.age_days,
      oes.age_years, oes.age_years_grp_cd, oes.age_days_grp_cd,
      oes.admit_7d_ladmit_ind, oes.admit_15d_ladmit_ind, oes.admit_24h_ladmit_ind,
      oes.admit_30d_ladmit_ind, oes.admit_48d_ladmit_ind, oes.admit_48h_ladmit_ind,
      oes.readmit_24h_48h_ind, oes.readmit_7d_15d_ind, oes.readmit_15d_30d_ind,
      oes.readmit_30d_48d_ind, oes.readmit_gt_48d_ind, oes.readmit_gt_72h_ind,
      oes.readmit_48h_72h_ind, oes.return_ed_24h_ind, oes.return_ed_48h_ind,
      oes.return_ed_72h_ind, oes.return_ed_24h_48h_ind, oes.return_ed_49h_72h_ind,
      oes.death_24h_admit_ind, oes.death_24h_visit_ind, oes.coordination_of_benefits_cd,
      oes.prim_ins_assign_benefits_cd, oes.prim_ins_organization_id, oes.prim_emp_organization_id,
      oes.emp_organization_id, oes.prim_ins_person_id, oes.prim_health_plan_id,
      oes.prim_ins_birth_dt_tm, oes.prim_ins_person_reltn_cd, oes.prim_ins_beg_effective_dt_tm,
      oes.prim_ins_beg_effective_dt_nbr, oes.prim_ins_beg_effective_min_nbr, oes
      .prim_ins_end_effective_dt_tm,
      oes.prim_ins_end_effective_dt_nbr, oes.prim_ins_end_effective_min_nbr, oes
      .prim_ins_plan_type_cd,
      oes.prim_health_plan_group_cd, oes.prim_ins_group_cd, oes.prim_org_plan_reltn_id,
      oes.sec_health_plan_group_cd, oes.sec_ins_group_cd, oes.sec_ins_assign_benefits_cd,
      oes.sec_ins_organization_id, oes.sec_emp_organization_id, oes.sec_ins_person_id,
      oes.sec_health_plan_id, oes.sec_ins_birth_dt_tm, oes.sec_ins_person_reltn_cd,
      oes.sec_ins_beg_effective_dt_tm, oes.sec_ins_beg_effective_dt_nbr, oes
      .sec_ins_beg_effective_min_nbr,
      oes.sec_ins_end_effective_dt_tm, oes.sec_ins_end_effective_dt_nbr, oes
      .sec_ins_end_effective_min_nbr,
      oes.sec_ins_plan_type_cd, oes.sec_org_plan_reltn_id, oes.other_health_plan_group_cd,
      oes.other_ins_group_cd, oes.other_ins_assign_benefits_cd, oes.other_ins_organization_id,
      oes.other_emp_organization_id, oes.other_ins_person_id, oes.other_health_plan_id,
      oes.other_ins_birth_dt_tm, oes.other_ins_person_reltn_cd, oes.other_ins_beg_effective_dt_tm,
      oes.other_ins_beg_effective_dt_nbr, oes.other_ins_beg_effective_mn_nbr, oes
      .other_ins_end_effective_dt_tm,
      oes.other_ins_end_effective_dt_nbr, oes.other_ins_end_effective_mn_nbr, oes
      .other_ins_plan_type_cd,
      oes.other_org_plan_reltn_id, oes.triage_cd, oes.service_category_cd,
      oes.encntr_class_cd, oes.reason_for_visit, oes.person_home_zipcode_grp_cd,
      oes.disch_shift_grp_cd, oes.admit_shift_grp_cd, oes.organization_id,
      oes.nbr_consults, oes.isolation_cd, oes.admit_phys_position_cd,
      oes.attend_phys_position_cd, oes.ref_phys_position_cd, oes.pcp_phys_position_cd,
      oes.updt_dt_tm, oes.updt_cnt, oes.updt_id,
      oes.updt_task, oes.updt_applctx)
      VALUES(c.t_encntr_id, c.t_person_id, c.t_visit_ind,
      c.t_admit_ind, c.t_visit_dt_tm, c.t_visit_dt_nbr,
      c.t_visit_min_nbr, c.t_icd9_admit_diag_nomen_id, c.t_death_ind,
      c.t_death_dt_tm, c.t_death_dt_nbr, c.t_death_min_nbr,
      c.t_last_ip_disch_dt_tm, c.t_disch_ind, c.t_disch_dt_tm,
      c.t_disch_dt_nbr, c.t_disch_min_nbr, c.t_exp_pm_disch_dt_tm,
      c.t_exp_pm_disch_dt_nbr, c.t_exp_pm_disch_min_nbr, c.t_disch_disposition_cd,
      c.t_disch_to_loctn_cd, c.t_admit_src_cd, c.t_admit_type_cd,
      c.t_admit_phys_id, c.t_admit_phys_key, c.t_admit_phys_ft_name,
      c.t_admit_phys_grp_cd, c.t_admit_phys_med_spec_cd, c.t_ambulatory_cond_cd,
      c.t_att_phys_id, c.t_att_phys_key, c.t_att_phys_ft_name,
      c.t_att_phys_grp_cd, c.t_att_phys_med_spec_cd, c.t_ethnic_grp_cd,
      c.t_sex_cd, c.t_fin_class_cd, c.t_race_cd,
      c.t_language_cd, c.t_religion_cd, c.t_vip_cd,
      c.t_encntr_type_cd, c.t_encntr_type_class_cd, c.t_birth_dt_tm,
      c.t_birth_date, c.t_marital_status_cd, c.t_ref_phys_id,
      c.t_ref_phys_key, c.t_ref_phys_ft_name, c.t_ref_phys_med_spec_cd,
      c.t_pcp_phys_id, c.t_pcp_phys_key, c.t_pcp_phys_ft_name,
      c.t_pcp_phys_grp_cd, c.t_pcp_phys_med_spec_cd, c.t_med_serv_cd,
      c.t_med_serv_grp_cd, c.t_accommodation_cd, c.t_transfer_reason_cd,
      c.t_prev_pat_loc_nu_cd, c.t_prev_encntr_id, c.t_prev_inp_encntr_id,
      c.t_curr_pat_loc_arrive_dt_tm, c.t_curr_pat_loc_bed_cd, c.t_curr_pat_loc_bdg_cd,
      c.t_curr_pat_loc_fac_cd, c.t_curr_pat_loc_fac_grp_cd, c.t_curr_pat_loc_nu_cd,
      c.t_curr_pat_loc_nu_grp_cd, c.t_curr_pat_loc_nu_grp2_cd, c.t_curr_pat_loc_room_cd,
      c.t_admit_pat_loc_bed_cd, c.t_admit_pat_loc_bdg_cd, c.t_admit_pat_loc_fac_cd,
      c.t_admit_pat_loc_nu_cd, c.t_admit_pat_loc_room_cd, c.t_age_days,
      c.t_age_years, c.t_age_years_grp_cd, c.t_age_days_grp_cd,
      c.t_admit_7d_ladmit_ind, c.t_admit_15d_ladmit_ind, c.t_admit_24h_ladmit_ind,
      c.t_admit_30d_ladmit_ind, c.t_admit_48d_ladmit_ind, c.t_admit_48h_ladmit_ind,
      c.t_readmit_24h_48h_ind, c.t_readmit_7d_15d_ind, c.t_readmit_15d_30d_ind,
      c.t_readmit_30d_48d_ind, c.t_readmit_gt_48d_ind, c.t_readmit_gt_72h_ind,
      c.t_readmit_48h_72h_ind, c.t_return_ed_24h_ind, c.t_return_ed_48h_ind,
      c.t_return_ed_72h_ind, c.t_return_ed_24h_48h_ind, c.t_return_ed_49h_72h_ind,
      c.t_death_24h_admit_ind, c.t_death_24h_visit_ind, c.t_coordination_of_benefits_cd,
      c.t_prim_ins_assign_benefits_cd, c.t_prim_ins_organization_id, c.t_prim_emp_organization_id,
      c.t_emp_organization_id, c.t_prim_ins_person_id, c.t_prim_health_plan_id,
      c.t_prim_ins_birth_dt_tm, c.t_prim_ins_person_reltn_cd, c.t_prim_ins_beg_eff_dt_tm,
      c.t_prim_ins_beg_eff_dt_nbr, c.t_prim_ins_beg_eff_min_nbr, c.t_prim_ins_end_eff_dt_tm,
      c.t_prim_ins_end_eff_dt_nbr, c.t_prim_ins_end_eff_min_nbr, c.t_prim_ins_plan_type_cd,
      c.t_prim_health_plan_group_cd, c.t_prim_ins_group_cd, c.t_prim_org_plan_reltn_id,
      c.t_sec_health_plan_group_cd, c.t_sec_ins_group_cd, c.t_sec_ins_assign_benefits_cd,
      c.t_sec_ins_organization_id, c.t_sec_emp_organization_id, c.t_sec_ins_person_id,
      c.t_sec_health_plan_id, c.t_sec_ins_birth_dt_tm, c.t_sec_ins_person_reltn_cd,
      c.t_sec_ins_beg_eff_dt_tm, c.t_sec_ins_beg_eff_dt_nbr, c.t_sec_ins_beg_eff_min_nbr,
      c.t_sec_ins_end_eff_dt_tm, c.t_sec_ins_end_eff_dt_nbr, c.t_sec_ins_end_eff_min_nbr,
      c.t_sec_ins_plan_type_cd, c.t_sec_org_plan_reltn_id, c.t_other_health_plan_group_cd,
      c.t_other_ins_group_cd, c.t_other_ins_assign_benefits_cd, c.t_other_ins_organization_id,
      c.t_other_emp_organization_id, c.t_other_ins_person_id, c.t_other_health_plan_id,
      c.t_other_ins_birth_dt_tm, c.t_other_ins_person_reltn_cd, c.t_other_ins_beg_eff_dt_tm,
      c.t_other_ins_beg_eff_dt_nbr, c.t_other_ins_beg_eff_mn_nbr, c.t_other_ins_end_eff_dt_tm,
      c.t_other_ins_end_eff_dt_nbr, c.t_other_ins_end_eff_mn_nbr, c.t_other_ins_plan_type_cd,
      c.t_other_org_plan_reltn_id, c.t_triage_cd, c.t_service_category_cd,
      c.t_encntr_class_cd, c.t_reason_for_visit, c.t_person_home_zipcode_grp_cd,
      c.t_disch_shift_grp_cd, c.t_admit_shift_grp_cd, c.t_organization_id,
      c.t_nbr_consults, c.t_isolation_cd, c.t_admit_phys_position_cd,
      c.t_attend_phys_position_cd, c.t_ref_phys_position_cd, c.t_pcp_phys_position_cd,
      c.t_updt_dt_tm, c.t_updt_cnt, c.t_updt_id,
      c.t_updt_task, c.t_updt_applctx)
     ;end insert
     )
     CALL echo("*_*_* update next_inp_encntr_id *_*_*")
     UPDATE  FROM omf_encntr_st oes,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oes.next_inp_encntr_id = omf_encntr_st->data[d1.seq].encntr_id, oes.updt_dt_tm =
       cnvtdatetime(sysdate), oes.updt_cnt = (oes.updt_cnt+ 1),
       oes.updt_id = reqinfo->updt_id, oes.updt_task = reqinfo->updt_task, oes.updt_applctx = reqinfo
       ->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].encntr_type_class_cd=omf_prologue_cv->69_inpatient)
        AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oes
       WHERE (oes.encntr_id=omf_encntr_st->data[d1.seq].prev_inp_encntr_id))
      WITH status(omf_encntr_st->data[d1.seq].status,omf_encntr_st->data[d1.seq].errnum,omf_encntr_st
       ->data[d1.seq].errmsg)
     ;end update
     CALL echo("*_*_* insert previous inp encounter id *_*_*")
     DECLARE iindx = i4 WITH protect, noconstant(0)
     CALL echo("*_*_* encntr ids *_*_*")
     FOR (iindx = 0 TO size(omf_encntr_st->data,5))
      CALL echo(build2("prev_inp_encntr_id: ",omf_encntr_st->data[iindx].prev_inp_encntr_id))
      CALL echo(build2("encntr_id: ",omf_encntr_st->data[iindx].encntr_id))
     ENDFOR
     INSERT  FROM omf_encntr_st oes,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oes.encntr_id = omf_encntr_st->data[d1.seq].prev_inp_encntr_id, oes.next_inp_encntr_id =
       omf_encntr_st->data[d1.seq].encntr_id, oes.updt_dt_tm = cnvtdatetime(sysdate),
       oes.updt_cnt = 0, oes.updt_id = reqinfo->updt_id, oes.updt_task = reqinfo->updt_task,
       oes.updt_applctx = reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].status=0)
        AND (omf_encntr_st->data[d1.seq].encntr_type_class_cd=omf_prologue_cv->69_inpatient)
        AND (omf_encntr_st->data[d1.seq].prev_inp_encntr_id > 0.0)
        AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oes)
     ;end insert
     CALL echo("*_*_* update next_encntr_id *_*_*")
     UPDATE  FROM omf_encntr_st oes,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oes.next_encntr_id = omf_encntr_st->data[d1.seq].encntr_id, oes.updt_dt_tm = cnvtdatetime(
        sysdate), oes.updt_cnt = (oes.updt_cnt+ 1),
       oes.updt_id = reqinfo->updt_id, oes.updt_task = reqinfo->updt_task, oes.updt_applctx = reqinfo
       ->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oes
       WHERE (oes.encntr_id=omf_encntr_st->data[d1.seq].prev_encntr_id))
      WITH status(omf_encntr_st->data[d1.seq].status,omf_encntr_st->data[d1.seq].errnum,omf_encntr_st
       ->data[d1.seq].errmsg)
     ;end update
     CALL echo("*_*_* insert previous encounter id *_*_*")
     INSERT  FROM omf_encntr_st oes,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oes.encntr_id = omf_encntr_st->data[d1.seq].prev_encntr_id, oes.next_encntr_id =
       omf_encntr_st->data[d1.seq].encntr_id, oes.updt_dt_tm = cnvtdatetime(sysdate),
       oes.updt_cnt = 0, oes.updt_id = reqinfo->updt_id, oes.updt_task = reqinfo->updt_task,
       oes.updt_applctx = reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].status=0)
        AND (omf_encntr_st->data[d1.seq].prev_encntr_id > 0.0)
        AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oes)
     ;end insert
     CALL echo("*_*_* update/insert to the omf_encntr_st_ext table *_*_*")
     UPDATE  FROM omf_encntr_st_ext oese,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oese.return_ed_gt_72h_ind = omf_encntr_st->data[d1.seq].return_ed_gt_72h_ind, oese
       .admit_72h_ladmit_ind = omf_encntr_st->data[d1.seq].admit_72h_ladmit_ind, oese.visit_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx,
       oese.death_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.last_ip_disch_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.disch_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.exp_pm_disch_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_dt_nbr = omf_encntr_st->data[d1.seq].
       birth_dt_nbr,
       oese.birth_min_nbr = omf_encntr_st->data[d1.seq].birth_min_nbr, oese.curr_pat_loc_arrive_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.curr_pat_loc_arrive_dt_nbr = omf_encntr_st->
       data[d1.seq].curr_pat_loc_arrive_dt_nbr,
       oese.curr_pat_loc_arrive_min_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr,
       oese.prim_ins_birth_tz = omf_encntr_st->data[d1.seq].prim_ins_birth_tz, oese
       .prim_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_dt_nbr,
       oese.prim_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr, oese
       .sec_ins_birth_tz = omf_encntr_st->data[d1.seq].sec_ins_birth_tz, oese.sec_ins_birth_dt_nbr =
       omf_encntr_st->data[d1.seq].sec_ins_birth_dt_nbr,
       oese.sec_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr, oese
       .other_ins_birth_tz = omf_encntr_st->data[d1.seq].other_ins_birth_tz, oese
       .other_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_dt_nbr,
       oese.other_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_min_nbr, oese
       .updt_dt_tm = cnvtdatetime(sysdate), oese.updt_cnt = (oese.updt_cnt+ 1),
       oese.updt_id = reqinfo->updt_id, oese.updt_task = reqinfo->updt_task, oese.updt_applctx =
       reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oese
       WHERE (oese.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
      WITH status(omf_encntr_st->data[d1.seq].status,omf_encntr_st->data[d1.seq].errnum,omf_encntr_st
       ->data[d1.seq].errmsg)
     ;end update
     INSERT  FROM omf_encntr_st_ext oese,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oese.encntr_id = omf_encntr_st->data[d1.seq].encntr_id, oese.return_ed_gt_72h_ind =
       omf_encntr_st->data[d1.seq].return_ed_gt_72h_ind, oese.admit_72h_ladmit_ind = omf_encntr_st->
       data[d1.seq].admit_72h_ladmit_ind,
       oese.visit_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.death_tz = omf_encntr_st->
       data[d1.seq].time_zone_indx, oese.last_ip_disch_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.disch_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.exp_pm_disch_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.birth_dt_nbr = omf_encntr_st->data[d1.seq].birth_dt_nbr, oese.birth_min_nbr =
       omf_encntr_st->data[d1.seq].birth_min_nbr, oese.curr_pat_loc_arrive_tz = omf_encntr_st->data[
       d1.seq].time_zone_indx,
       oese.curr_pat_loc_arrive_dt_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr, oese
       .curr_pat_loc_arrive_min_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr, oese
       .prim_ins_birth_tz = omf_encntr_st->data[d1.seq].prim_ins_birth_tz,
       oese.prim_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_dt_nbr, oese
       .prim_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr, oese
       .sec_ins_birth_tz = omf_encntr_st->data[d1.seq].sec_ins_birth_tz,
       oese.sec_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_dt_nbr, oese
       .sec_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr, oese
       .other_ins_birth_tz = omf_encntr_st->data[d1.seq].other_ins_birth_tz,
       oese.other_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_dt_nbr, oese
       .other_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_min_nbr, oese
       .updt_dt_tm = cnvtdatetime(sysdate),
       oese.updt_cnt = 0, oese.updt_id = reqinfo->updt_id, oese.updt_task = reqinfo->updt_task,
       oese.updt_applctx = reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].status=0)
        AND (omf_encntr_st->data[d1.seq].encntr_id > 0.0)
        AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oese)
     ;end insert
     UPDATE  FROM omf_encntr_st_ext oese,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oese.days_next_ed_visit = omf_encntr_st->data[d1.seq].days_next_ed_visit, oese
       .days_next_ed_visit = omf_encntr_st->data[d1.seq].days_next_ed_visit, oese.visit_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx,
       oese.death_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.last_ip_disch_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.disch_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.exp_pm_disch_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_dt_nbr = omf_encntr_st->data[d1.seq].
       birth_dt_nbr,
       oese.birth_min_nbr = omf_encntr_st->data[d1.seq].birth_min_nbr, oese.curr_pat_loc_arrive_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.curr_pat_loc_arrive_dt_nbr = omf_encntr_st->
       data[d1.seq].curr_pat_loc_arrive_dt_nbr,
       oese.curr_pat_loc_arrive_min_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr,
       oese.prim_ins_birth_tz = omf_encntr_st->data[d1.seq].prim_ins_birth_tz, oese
       .prim_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_dt_nbr,
       oese.prim_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr, oese
       .sec_ins_birth_tz = omf_encntr_st->data[d1.seq].sec_ins_birth_tz, oese.sec_ins_birth_dt_nbr =
       omf_encntr_st->data[d1.seq].sec_ins_birth_dt_nbr,
       oese.sec_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr, oese
       .other_ins_birth_tz = omf_encntr_st->data[d1.seq].other_ins_birth_tz, oese
       .other_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_dt_nbr,
       oese.other_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_min_nbr, oese
       .updt_dt_tm = cnvtdatetime(sysdate), oese.updt_cnt = (oese.updt_cnt+ 1),
       oese.updt_id = reqinfo->updt_id, oese.updt_task = reqinfo->updt_task, oese.updt_applctx =
       reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oese
       WHERE (oese.encntr_id=omf_encntr_st->data[d1.seq].prev_encntr_id))
      WITH status(omf_encntr_st->data[d1.seq].status,omf_encntr_st->data[d1.seq].errnum,omf_encntr_st
       ->data[d1.seq].errmsg)
     ;end update
     INSERT  FROM omf_encntr_st_ext oese,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oese.encntr_id = omf_encntr_st->data[d1.seq].prev_encntr_id, oese.days_next_ed_visit =
       omf_encntr_st->data[d1.seq].days_next_ed_visit, oese.days_next_ed_visit = omf_encntr_st->data[
       d1.seq].days_next_ed_visit,
       oese.visit_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.death_tz = omf_encntr_st->
       data[d1.seq].time_zone_indx, oese.last_ip_disch_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.disch_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oese.exp_pm_disch_tz =
       omf_encntr_st->data[d1.seq].time_zone_indx, oese.birth_tz = omf_encntr_st->data[d1.seq].
       time_zone_indx,
       oese.birth_dt_nbr = omf_encntr_st->data[d1.seq].birth_dt_nbr, oese.birth_min_nbr =
       omf_encntr_st->data[d1.seq].birth_min_nbr, oese.curr_pat_loc_arrive_tz = omf_encntr_st->data[
       d1.seq].time_zone_indx,
       oese.curr_pat_loc_arrive_dt_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_dt_nbr, oese
       .curr_pat_loc_arrive_min_nbr = omf_encntr_st->data[d1.seq].curr_pat_loc_arrive_min_nbr, oese
       .prim_ins_birth_tz = omf_encntr_st->data[d1.seq].prim_ins_birth_tz,
       oese.prim_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_dt_nbr, oese
       .prim_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].prim_ins_birth_min_nbr, oese
       .sec_ins_birth_tz = omf_encntr_st->data[d1.seq].sec_ins_birth_tz,
       oese.sec_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_dt_nbr, oese
       .sec_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].sec_ins_birth_min_nbr, oese
       .other_ins_birth_tz = omf_encntr_st->data[d1.seq].other_ins_birth_tz,
       oese.other_ins_birth_dt_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_dt_nbr, oese
       .other_ins_birth_min_nbr = omf_encntr_st->data[d1.seq].other_ins_birth_min_nbr, oese
       .updt_dt_tm = cnvtdatetime(sysdate),
       oese.updt_cnt = 0, oese.updt_id = reqinfo->updt_id, oese.updt_task = reqinfo->updt_task,
       oese.updt_applctx = reqinfo->updt_applctx
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].status=0)
        AND (omf_encntr_st->data[d1.seq].prev_encntr_id > 0.0)
        AND (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oese)
     ;end insert
     SELECT INTO "nl:"
      oepr.encntr_prsnl_reltn_id, oepr.updt_cnt
      FROM omf_encntr_prsnl_reltn_st oepr,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_encntr_reltn_cnt))
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].encntr_reltn_cnt))
       JOIN (oepr
       WHERE (oepr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
      ORDER BY d1.seq
      HEAD d1.seq
       stat = alterlist(omf_temp->data[d1.seq].array,omf_encntr_st->data[d1.seq].encntr_reltn_cnt)
      DETAIL
       IF ((oepr.encntr_prsnl_reltn_id=omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       encntr_prsnl_reltn_id))
        omf_temp->data[d1.seq].array[d2.seq].updt_cnt = (oepr.updt_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
     DELETE  FROM omf_encntr_prsnl_reltn_st oepr,
       (dummyt d1  WITH seq = value(v_encntr_ndx))
      SET oepr.encntr_id = 1
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (oepr
       WHERE (oepr.encntr_id=omf_encntr_st->data[d1.seq].encntr_id))
     ;end delete
     INSERT  FROM omf_encntr_prsnl_reltn_st oepr,
       (dummyt d1  WITH seq = value(v_encntr_ndx)),
       (dummyt d2  WITH seq = value(omf_encntr_st->max_encntr_reltn_cnt))
      SET oepr.encntr_prsnl_reltn_id = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       encntr_prsnl_reltn_id, oepr.prsnl_person_id = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq]
       .prsnl_person_id, oepr.prsnl_person_position_cd = omf_encntr_st->data[d1.seq].encntr_reltn[d2
       .seq].prsnl_person_position_cd,
       oepr.encntr_prsnl_r_cd = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].encntr_prsnl_r_cd,
       oepr.encntr_id = omf_encntr_st->data[d1.seq].encntr_id, oepr.prsnl_person_key = omf_encntr_st
       ->data[d1.seq].encntr_reltn[d2.seq].prsnl_person_key,
       oepr.prsnl_person_ft_name = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       prsnl_person_ft_name, oepr.priority_seq = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       priority_seq, oepr.prsnl_person_grp_cd = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       prsnl_person_grp_cd,
       oepr.prsnl_person_med_spec_cd = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       prsnl_person_med_spec_cd, oepr.beg_effective_dt_tm = evaluate(v_utc_on_ind,1,cnvtdatetimeutc(
         omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].beg_effective_dt_tm,0),0,cnvtdatetime(
         omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].beg_effective_dt_tm)), oepr
       .beg_effective_tz = omf_encntr_st->data[d1.seq].time_zone_indx,
       oepr.beg_effective_dt_nbr = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       beg_effective_dt_nbr, oepr.beg_effective_min_nbr = omf_encntr_st->data[d1.seq].encntr_reltn[d2
       .seq].beg_effective_min_nbr, oepr.end_effective_dt_tm = evaluate(v_utc_on_ind,1,
        cnvtdatetimeutc(omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].end_effective_dt_tm,0),0,
        cnvtdatetime(omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].end_effective_dt_tm)),
       oepr.end_effective_tz = omf_encntr_st->data[d1.seq].time_zone_indx, oepr.end_effective_dt_nbr
        = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].end_effective_dt_nbr, oepr
       .end_effective_min_nbr = omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].
       end_effective_min_nbr,
       oepr.updt_id = reqinfo->updt_id, oepr.updt_task = reqinfo->updt_task, oepr.updt_applctx =
       reqinfo->updt_applctx,
       oepr.updt_dt_tm = cnvtdatetime(sysdate), oepr.updt_cnt = omf_temp->data[d1.seq].array[d2.seq].
       updt_cnt
      PLAN (d1
       WHERE (omf_encntr_st->data[d1.seq].time_zone_status > 0))
       JOIN (d2
       WHERE (d2.seq <= omf_encntr_st->data[d1.seq].encntr_reltn_cnt)
        AND (omf_encntr_st->data[d1.seq].encntr_reltn[d2.seq].encntr_prsnl_reltn_id > 0.0))
       JOIN (oepr)
     ;end insert
     SET v_select_temp = fillstring(32000," ")
     SET v_insert_temp = fillstring(32000," ")
     SET v_delete_temp = fillstring(32000," ")
     SET v_table_str = concat(":",fillstring(28,"t"),":")
     SET v_column_str = concat(":",fillstring(30000,"c"),":")
     SET stat = alterlist(action->row,0)
     SET v_select_temp = concat('select into "nl:"'," from ",v_table_str," st,",
      " (dummyt d with seq = value(v_encntr_ndx)),",
      " (dummyt d2 with seq = value(omf_encntr_st->max_inst_cnt))"," plan d",
      " where omf_encntr_st->data[d.seq].time_zone_status > 0 "," join d2 ",
      " where d2.seq <= omf_encntr_st->data[d.seq].hist_list[i].inst_cnt",
      " join st"," where st.encntr_loc_hist_id =",
      " omf_encntr_st->data[d.seq].hist_list[i].instance[d2.seq].","encntr_loc_hist_id ",
      " order by d.seq",
      " head report "," stat = alterlist(omf_temp->data[d.seq].array, 0) "," head d.seq",
      " stat = alterlist(omf_temp->data[d.seq].array, ",
      " omf_encntr_st->data[d.seq].hist_list[i].inst_cnt) ",
      " detail "," omf_temp->data[d.seq].array[d2.seq].updt_cnt = st.updt_cnt + 1 ",
      " with nocounter go")
     SET v_insert_temp = concat("insert into ",v_table_str," st,",
      " (dummyt d with seq = value(v_encntr_ndx)),",
      " (dummyt d2 with seq = value(omf_encntr_st->max_inst_cnt))",
      " set st.beg_transaction_dt_nbr =",
      " omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].","beg_transaction_dt_nbr,",
      " st.beg_transaction_dt_tm ="," evaluate(v_utc_on_ind, 1, ",
      " cnvtdatetimeutc(omf_encntr_st->data[d.seq].hist_list[i]->",
      "instance[d2.seq].beg_transaction_dt_tm, 0),",
      " cnvtdatetime(omf_encntr_st->data[d.seq].hist_list[i]->",
      "instance[d2.seq].beg_transaction_dt_tm)),","st.beg_transaction_tz =",
      "omf_encntr_st->data[d.seq].time_zone_indx,"," st.beg_transaction_min_nbr =",
      " omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].","beg_transaction_min_nbr,",
      " st.encntr_id =",
      " omf_encntr_st->data[d.seq].encntr_id,"," st.encntr_loc_hist_id =",
      " omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].","encntr_loc_hist_id,",
      " st.end_transaction_dt_nbr =",
      " omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].","end_transaction_dt_nbr,",
      " st.end_transaction_dt_tm ="," evaluate(v_utc_on_ind, 1, ",
      " cnvtdatetimeutc(omf_encntr_st->data[d.seq].hist_list[i]->",
      "instance[d2.seq].end_transaction_dt_tm, 0),",
      " cnvtdatetime(omf_encntr_st->data[d.seq].hist_list[i]->",
      "instance[d2.seq].end_transaction_dt_tm)),","st.end_transaction_tz =",
      "omf_encntr_st->data[d.seq].time_zone_indx,",
      " st.end_transaction_min_nbr ="," omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].",
      "end_transaction_min_nbr,",v_column_str," st.updt_applctx = reqinfo->updt_applctx,",
      " st.updt_cnt = 0,"," st.updt_dt_tm = cnvtdatetime(curdate, curtime3),",
      " st.updt_id = reqinfo->updt_id,"," st.updt_task = reqinfo->updt_task"," plan d ",
      " where omf_encntr_st->data[d.seq].time_zone_status > 0 "," join d2",
      " where d2.seq <= omf_encntr_st->data[d.seq].hist_list[i].inst_cnt",
      "   and omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].encntr_loc_hist_id > 0.0 ",
      " join st",
      " where st.encntr_loc_hist_id ="," omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].",
      "encntr_loc_hist_id"," with nocounter, outerjoin = d go")
     SET v_delete_temp = concat("delete from ",v_table_str," st,",
      " (dummyt d1 with seq = value(v_encntr_ndx))"," set st.encntr_id = 1",
      " plan d1 "," where omf_encntr_st->data[d1.seq].time_zone_status > 0 "," join st ",
      " where st.encntr_id = omf_encntr_st->data[d1.seq].encntr_id go")
     FOR (i = 1 TO 3)
       SET insert_ind = 0
       SET updt_ind = 0
       SET v_table_name = fillstring(50," ")
       SET flex_insert = fillstring(9999," ")
       SET v_select_stmt = fillstring(32000," ")
       SET v_insert_stmt = fillstring(32000," ")
       SET v_delete_stmt = fillstring(32000," ")
       SET v_select_stmt = v_select_temp
       SET v_insert_stmt = v_insert_temp
       SET v_delete_stmt = v_delete_temp
       CASE (i)
        OF 1:
         SET v_table_name = "omf_location_hist_st   "
         SET flex_insert = concat(" st.loc_building_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val1,",
          "st.loc_facility_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val2,",
          "st.loc_nurse_unit_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val3,",
          "st.transfer_reason_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val4,",
          "st.previous_nurse_unit_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val7,",
          "st.loc_room_cd = ","omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val5,",
          "st.loc_bed_cd = ","omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val6,",
          "st.transaction_ind = 1, ",
          "st.loc_nurse_unit_grp_cd = omf_encntr_st->data[d.seq].",
          "hist_list->instance[d2.seq].loc_nurse_unit_grp_cd,",
          "st.loc_nurse_unit_grp2_cd = omf_encntr_st->data[d.seq].",
          "hist_list->instance[d2.seq].loc_nurse_unit_grp2_cd,")
        OF 2:
         SET v_table_name = "omf_encntr_type_hist_st"
         SET flex_insert = concat("st.encntr_type_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val1,",
          "st.encntr_type_class_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val2,","st.person_id = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val3,")
        OF 3:
         SET v_table_name = "omf_med_service_hist_st"
         SET flex_insert = concat("st.med_service_cd = ",
          "omf_encntr_st->data[d.seq].hist_list[i]->instance[d2.seq].num_val1,")
       ENDCASE
       SET v_select_stmt = replace(v_select_stmt,v_table_str,trim(v_table_name),0)
       SET v_insert_stmt = replace(v_insert_stmt,v_table_str,trim(v_table_name),0)
       SET v_insert_stmt = replace(v_insert_stmt,v_column_str,trim(flex_insert),0)
       SET v_delete_stmt = replace(v_delete_stmt,v_table_str,trim(v_table_name),0)
       CALL parser(v_select_stmt)
       CALL parser(v_delete_stmt)
       CALL parser(trim(v_insert_stmt))
     ENDFOR
     SET stat = alterlist(omf_encntr_st->data,0)
     IF ((- (1)=validate(omf_cmb_request->encntr_id,- (1))))
      COMMIT
     ELSE
      SET reply->status_data.status = "S"
     ENDIF
     CALL echo("...exiting OMF_PM_ADT <include file>")
     IF (size(omf_ins_interface_error_request->data,5) > 0)
      IF (idebugind=1)
       SET stempstr = concat("      ERR: ",build(size(omf_ins_interface_error_request->data,5)),
        " encounters could not be processed, see OMF_INTERFACE_ERROR table for further information.")
       CALL omflogprint(stempstr)
       SET stat = initrec(omf_ins_interface_error_request)
      ENDIF
     ENDIF
     CALL echo("Entering OMF_DATE <include file>...")
     SET c_omf_date = "OMF_DATE.INC 004"
     SET v_separator = "~~"
     IF (validate(v_date_str,"N")="N")
      DECLARE v_date_str = vc
      DECLARE v_mth_str = vc
      DECLARE v_day_str = vc
      DECLARE v_mth_yr_str = vc
     ENDIF
     IF (size(omf_date->row,5) > 0)
      SET stat = alterlist(action->row,0)
      SET stat = alterlist(action->row,size(omf_date->row,5))
      SELECT INTO "nl:"
       1
       FROM (dummyt d1  WITH seq = value(size(omf_date->row,5))),
        omf_date od
       PLAN (d1
        WHERE (omf_date->row[d1.seq].dt_nbr > 0))
        JOIN (od
        WHERE (omf_date->row[d1.seq].dt_nbr=od.dt_nbr))
       DETAIL
        action->row[d1.seq].app_action = 1
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       date_str = format(cnvtdatetime(concat(omf_date->row[d1.seq].date," 00:00:00")),"@SHORTDATE4YR"
        ), year = year(omf_date->row[d1.seq].dt_nbr), quarter = evaluate(month(omf_date->row[d1.seq].
         dt_nbr),1,1,2,1,
        3,1,4,2,5,
        2,6,2,7,3,
        8,3,9,3,10,
        4,11,4,12,4),
       month = month(omf_date->row[d1.seq].dt_nbr), day_of_month = day(omf_date->row[d1.seq].dt_nbr),
       day_of_week = weekday(omf_date->row[d1.seq].dt_nbr),
       month_str = format(cnvtdatetime(concat(omf_date->row[d1.seq].date," 00:00:00")),"@MONTHABBREV"
        ), day_str = format(cnvtdatetime(concat(omf_date->row[d1.seq].date," 00:00:00")),
        "@WEEKDAYABBREV"), mth_yr_str = concat(format(cnvtdatetime(concat(omf_date->row[d1.seq].date,
           " 00:00:00")),"@MONTHABBREV"),"-",cnvtstring(year(cnvtdatetime(concat(omf_date->row[d1.seq
            ].date," 00:00:00")))))
       FROM (dummyt d1  WITH seq = value(size(omf_date->row,5)))
       PLAN (d1
        WHERE (omf_date->row[d1.seq].dt_nbr > 0)
         AND (action->row[d1.seq].app_action=0))
       DETAIL
        omf_date->row[d1.seq].date_str = date_str, omf_date->row[d1.seq].year = year, omf_date->row[
        d1.seq].quarter = quarter,
        omf_date->row[d1.seq].month = month, omf_date->row[d1.seq].day_of_month = day_of_month,
        omf_date->row[d1.seq].day_of_week = day_of_week,
        omf_date->row[d1.seq].month_str = month_str, omf_date->row[d1.seq].month_year_str =
        mth_yr_str, omf_date->row[d1.seq].day_str = day_str
        IF (day_of_week IN (0, 6))
         omf_date->row[d1.seq].weekday_ind = 0
        ELSE
         omf_date->row[d1.seq].weekday_ind = 1
        ENDIF
        omf_date->row[d1.seq].last_day_of_month_ind = 0
        IF (month IN (1, 3, 5, 7, 8,
        10, 12))
         omf_date->row[d1.seq].nbr_days_in_month = 31
        ELSEIF (month IN (4, 6, 9, 11))
         omf_date->row[d1.seq].nbr_days_in_month = 30
        ELSEIF (month=2)
         IF (mod(year,4)=0)
          omf_date->row[d1.seq].nbr_days_in_month = 29
         ELSE
          omf_date->row[d1.seq].nbr_days_in_month = 28
         ENDIF
        ENDIF
        IF ((day_of_month=omf_date->row[d1.seq].nbr_days_in_month))
         omf_date->row[d1.seq].last_day_of_month_ind = 1
        ENDIF
       WITH nocounter
      ;end select
      INSERT  FROM omf_date od,
        (dummyt d1  WITH seq = value(size(omf_date->row,5)))
       SET od.dt_nbr = omf_date->row[d1.seq].dt_nbr, od.date_str = omf_date->row[d1.seq].date_str, od
        .year = omf_date->row[d1.seq].year,
        od.quarter = omf_date->row[d1.seq].quarter, od.month = omf_date->row[d1.seq].month, od
        .day_of_month = omf_date->row[d1.seq].day_of_month,
        od.day_of_week = omf_date->row[d1.seq].day_of_week, od.weekday_ind = omf_date->row[d1.seq].
        weekday_ind, od.last_day_of_month_ind = omf_date->row[d1.seq].last_day_of_month_ind,
        od.nbr_days_in_month = omf_date->row[d1.seq].nbr_days_in_month, od.month_str = omf_date->row[
        d1.seq].month_str, od.day_str = omf_date->row[d1.seq].day_str,
        od.month_year_str = omf_date->row[d1.seq].month_year_str
       PLAN (d1
        WHERE (omf_date->row[d1.seq].dt_nbr > 0)
         AND (action->row[d1.seq].app_action=0))
        JOIN (od)
      ;end insert
     ENDIF
     SET v_date_str = ""
     SET v_mth_str = ""
     SET v_day_str = ""
     SET v_mth_yr_str = ""
     CALL echo("...exiting OMF_DATE <include file>")
    ENDIF
    SET stat = initrec(omf_encntr_st)
    SET stat = initrec(omf_date)
    UPDATE  FROM omf_extract_batch b
     SET b.process_flag = value(c_process_complete)
     WHERE b.extract_type_cd=fextracttypecd
      AND b.process_flag=value(c_process_inprocess)
      AND b.active_ind=1
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 ENDWHILE
 SET c_omf_profile_save = "OMF_TIME_ZONE_RESET.INC 000"
 IF (v_utc_on_ind=1)
  SET v_time_zone = "SYSTEM"
  SET tz->m_id = concat(trim(v_time_zone),char(0))
  CALL uar_dategetsystemtimezone(tz)
  CALL uar_datesettimezone(tz)
 ENDIF
 SET reply->status_data.status = "S"
 SET batch_reply->next_extract_dt_tm = d_incrementalto
#end_batch
 SET stat = initrec(omf_encntr_st)
 SET stat = initrec(omf_date)
 DELETE  FROM omf_extract_batch b
  WHERE b.parent_entity_id > 0.0
   AND b.extract_type_cd=fextracttypecd
   AND b.process_flag=value(c_process_complete)
  WITH nocounter
 ;end delete
 IF (idebugind=1)
  CALL omflogprint(concat("Procare ADT batch complete with status: ",reply->status_data.status))
  CALL omflogprint(concat("Reply Status Message: ",reply->subeventstatus[1].targetobjectvalue))
  SET stempstr = build2("End time: ",format(cnvtdatetime(d_incrementalto),"@SHORTDATETIME"))
  CALL omflogprint(stempstr)
  CALL omflogprint("==============================================")
 ENDIF
END GO
