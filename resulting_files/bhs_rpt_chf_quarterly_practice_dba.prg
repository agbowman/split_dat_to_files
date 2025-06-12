CREATE PROGRAM bhs_rpt_chf_quarterly_practice:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 t_action_dt_tm = dq8
   1 two_year_date = dq8
   1 name = vc
   1 practice_cnt = i4
   1 practice_qual[*]
     2 practice_id = f8
     2 email = vc
   1 pat_cnt = i4
   1 pat_qual[*]
     2 org = vc
     2 org_key = vc
     2 phys_id = f8
     2 person_id = f8
     2 practice_id = f8
     2 name = vc
     2 mrn = vc
     2 dob = dq8
     2 street1 = vc
     2 street2 = vc
     2 street3 = vc
     2 street4 = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 problem_ind = i2
     2 last_visit_dt_tm = dq8
     2 last_visit_encntr_id = f8
     2 iv_meds_ind = i2
     2 spiro_ind = i2
     2 beta_blocker_ind = i2
     2 ace_arb_ind = i2
     2 af_ind = i2
     2 warf_ind = i2
     2 lv_dt_tm = dq8
     2 lv_value = vc
     2 ldl_dt_tm = dq8
     2 ldl_val = vc
     2 creatinine_dt_tm = dq8
     2 creatinine_val = vc
     2 hosp_dt_tm = dq8
     2 icd_ind = i2
     2 education = vc
     2 smoking = vc
     2 pneu_vac_dt_tm = dq8
     2 flu_vac_dt_tm = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE month = i2
 IF (validate(request->batch_selection))
  SET t_record->t_action_dt_tm = cnvtdatetime(request->ops_date)
  SET month = month(cnvtdatetime(request->ops_date))
  IF ((t_record->t_action_dt_tm <= 0))
   SET month = month(cnvtdatetime(sysdate))
  ENDIF
  IF (((month=1) OR (((month=4) OR (((month=7) OR (month=10)) )) )) )
   SET count = 1
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE pneu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINE"))
 DECLARE flu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINE"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE ldl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE creatinine_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",72,"Creatinine-Blood"))
 DECLARE yes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30443,"YES"))
 DECLARE no_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30443,"NO"))
 DECLARE ace_med01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"QUINAPRIL"))
 DECLARE ace_med02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PERINDOPRIL"))
 DECLARE ace_med03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"RAMIPRIL"))
 DECLARE ace_med04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEBENAZEPRIL"))
 DECLARE ace_med05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BENAZEPRIL"))
 DECLARE ace_med06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CAPTOPRIL"))
 DECLARE ace_med07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace_med08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FOSINOPRIL"))
 DECLARE ace_med09_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ENALAPRILFELODIPINE"))
 DECLARE ace_med10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace_med11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRANDOLAPRIL"))
 DECLARE ace_med12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOEXIPRIL"))
 DECLARE ace_med13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TRANDOLAPRILVERAPAMIL"))
 DECLARE ace_med14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace_med15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace_com01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEQUINAPRIL"))
 DECLARE ace_com02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BENAZEPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CAPTOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ENALAPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FOSINOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELISINOPRIL"))
 DECLARE ace_com07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEMOEXIPRIL"))
 DECLARE arb_med01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CANDESARTAN"))
 DECLARE arb_med02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IRBESARTAN"))
 DECLARE arb_med03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEOLMESARTAN"))
 DECLARE arb_med04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OLMESARTAN"))
 DECLARE arb_med05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LOSARTAN"))
 DECLARE arb_med06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"VALSARTAN"))
 DECLARE arb_med07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEVALSARTAN"))
 DECLARE arb_med08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TELMISARTAN"))
 DECLARE arb_med09_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"EPROSARTAN"))
 DECLARE arb_med10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINETELMISARTAN"))
 DECLARE arb_med11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ALISKIRENVALSARTAN"))
 DECLARE arb_com01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CANDESARTANHYDROCHLOROTHIAZIDE"))
 DECLARE arb_com02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEIRBESARTAN"))
 DECLARE arb_com03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEOLMESARTAN"))
 DECLARE arb_com04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEVALSARTAN"))
 DECLARE arb_com05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEHYDROCHLOROTHIAZIDEVALSARTAN"))
 DECLARE arb_com06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELOSARTAN"))
 DECLARE arb_com07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDETELMISARTAN"))
 DECLARE arb_com08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "EPROSARTANHYDROCHLOROTHIAZIDE"))
 DECLARE bb1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ACEBUTOLOL"))
 DECLARE bb2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ATENOLOL"))
 DECLARE bb3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SOTALOL"))
 DECLARE bb4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BETAXOLOL"))
 DECLARE bb5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BISOPROLOL"))
 DECLARE bb6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TIMOLOL"))
 DECLARE bb7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ESMOLOL"))
 DECLARE bb8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CARVEDILOL"))
 DECLARE bb9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NADOLOL"))
 DECLARE bb10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PROPRANOLOL"))
 DECLARE bb11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LABETALOL"))
 DECLARE bb12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PENBUTOLOL"))
 DECLARE bb13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"METOPROLOL"))
 DECLARE bb14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PINDOLOL"))
 DECLARE bb15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ATENOLOLCHLORTHALIDONE"))
 DECLARE bb16_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BISOPROLOLHYDROCHLOROTHIAZIDE"))
 DECLARE bb17_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEPROPRANOLOL"))
 DECLARE bb18_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEMETOPROLOL"))
 DECLARE coreg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CARVEDILOL"))
 DECLARE spir1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SPIRONOLACTONE"))
 DECLARE spir2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDESPIRONOLACTONE"))
 DECLARE iv1_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVINFUSION"))
 DECLARE iv2_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSH"))
 DECLARE iv3_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSHSLOWLY"))
 DECLARE iv4_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPB"))
 DECLARE iv5_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,
   "SUBCUTANEOUSINJECTION"))
 DECLARE iv6_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"INTRAMUSCULAR"))
 DECLARE iv1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MILRINONE"))
 DECLARE iv2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NESIRITIDE"))
 DECLARE iv3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DOBUTAMINE"))
 DECLARE iv4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NITROPRUSSIDE"))
 DECLARE iv5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FUROSEMIDE"))
 DECLARE warfarin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN"))
 DECLARE lv1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLSTANDARDWNUCIMAGINGTEST"))
 DECLARE lv2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLSTANDARDWNUCIMAGING"))
 DECLARE lv3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLPOSTMIWNUCIMAGINGTEST"))
 DECLARE lv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLPOSTMIWNUCIMAGING"))
 DECLARE lv4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLMODIFIEDWNUCIMAGINGTEST"))
 DECLARE lv5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TREADMILLMODIFIEDWNUCIMAGING"))
 DECLARE lv6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NMVASCFLOWIMAGINGNONCARDIAC"))
 DECLARE lv7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NMCARDIACSHUNTDETERMINATION"))
 DECLARE lv8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACWWOCONTRASTFLOW"))
 DECLARE lv9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MRICARDIACWWOCONTRAST"))
 DECLARE lv10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MRICARDIACWWOCONTRAST")
  )
 DECLARE lv11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACWOCONTRASTFLOW"))
 DECLARE lv12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MRICARDIACWOCONTRAST"))
 DECLARE lv13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACVELOCITYFLOWMAP"))
 DECLARE lv14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACMORPHOLOGYWOCONTRAST"))
 DECLARE lv15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACMORPHOLOGYWCONTRAST"))
 DECLARE lv16_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACFUNCTIONWWOMORPHOLOGY"))
 DECLARE lv17_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MRICARDIACFUNCTIONWWOCONTRAST"))
 DECLARE lv18_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MRICARDIACFUNCTIONLTD")
  )
 DECLARE lv19_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CARDIACCATHLABREPORT"))
 DECLARE lv20_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STRESSWADENOSINEINFSESTAMIBI"))
 DECLARE lv21_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STRESSWDOBUTAMINEINFSESTAMIBI"))
 DECLARE lv22_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STRESSWPERSANTINEINFSESTAMIBI"))
 DECLARE lv23_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NMGATEDBLOODPOOLEFMULTI"))
 DECLARE lv24_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"EJECTIONFRACTION"))
 DECLARE lv25_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "USECHOCARDIOREALTIMELTD"))
 DECLARE lv26_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "USECHOCARDIOREALTIMECOMP"))
 DECLARE lv27_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"USDOPPLERECHOCARDIOLTD"
   ))
 DECLARE lv28_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "USDOPPLERECHOCARDIOCOMP"))
 DECLARE lv29_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "USDOPPLERECHOCARDIOCOLORFLOW"))
 DECLARE lv30_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSESOPHAGEALECHOCARDIOGRAM"))
 DECLARE lv31_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"STRESSTESTECHO"))
 DECLARE lv32_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STRESSECHOWDOBUTAMINEINFUSION"))
 DECLARE lv33_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"STRESSECHOMLH"))
 DECLARE lv34_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"STRESSECHOFMC"))
 DECLARE lv35_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"STRESSECHOCARDIOGRAM"))
 DECLARE lv36_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"STRESSECHO"))
 DECLARE lv37_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOTRANSTHORACICSOFTMED"))
 DECLARE lv38_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOTRANSTHORACIC"))
 DECLARE lv39_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOTRANSESOPHAGEAL"))
 DECLARE lv40_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOSTRESSWDOBUTAMINE")
  )
 DECLARE lv41_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOSTRESS"))
 DECLARE lv42_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOCOMPLETE"))
 DECLARE lv43_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAMWDOPPLERADULT"))
 DECLARE lv44_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOCARDIOGRAMWDOPPLER"
   ))
 DECLARE lv45_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAMWCOLORFLOWDOPPLERADU"))
 DECLARE lv46_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAMWCOLORFLOWDOPPLER"))
 DECLARE lv47_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAMTRANSTHORACIC"))
 DECLARE lv48_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOCARDIOGRAMMLH"))
 DECLARE lv49_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOCARDIOGRAMFMC"))
 DECLARE lv50_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHOCARDIOGRAMCOMPLETE"
   ))
 DECLARE lv51_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAM2DWCONTRAST"))
 DECLARE lv52_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHOCARDIOGRAM2DONLYADULT"))
 DECLARE lv53_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHO2DWCONTRAST"))
 DECLARE lv54_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ECHO2DMMODELIMITEDORFOLLOWUP"))
 DECLARE lv55_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ECHO2DMMODECOMP"))
 DECLARE lv56_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DOPPLERCOLORECHOCARDIOG"))
 DECLARE lv57_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHESTDOPPLERECHOCOMPLETE"))
 DECLARE t_line = vc
 DECLARE l_line = vc
 DECLARE p_line = vc
 DECLARE problem = vc
 DECLARE address = vc
 DECLARE ace_arb = vc
 DECLARE beta_blocker = vc
 DECLARE warfarin = vc
 DECLARE icd = vc
 DECLARE iv_meds = vc
 DECLARE spiro = vc
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM bhs_practice_location b
  PLAN (b
   WHERE b.email != null)
  DETAIL
   t_record->practice_cnt += 1, stat = alterlist(t_record->practice_qual,t_record->practice_cnt),
   t_record->practice_qual[t_record->practice_cnt].practice_id = b.location_id,
   t_record->practice_qual[t_record->practice_cnt].email = b.email
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->practice_cnt)
   SELECT INTO "nl:"
    FROM bhs_physician_location b,
     bhs_practice_location b1
    PLAN (b
     WHERE (b.location_id=t_record->practice_qual[i].practice_id))
     JOIN (b1
     WHERE b1.location_id=b.location_id)
    ORDER BY b.person_id
    HEAD REPORT
     t_record->name = b1.location_description, l_line = "b.pcp_id in ( ", p_line =
     "sa1.person_id in ( ",
     first_ind = 0
    HEAD b.person_id
     IF (first_ind=0)
      l_line = concat(l_line,trim(cnvtstring(b.person_id))), p_line = concat(p_line,trim(cnvtstring(b
         .person_id))), first_ind = 1
     ELSE
      l_line = concat(l_line,",",trim(cnvtstring(b.person_id))), p_line = concat(p_line,",",trim(
        cnvtstring(b.person_id)))
     ENDIF
    FOOT REPORT
     l_line = concat(l_line,")"), p_line = concat(p_line,")")
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM bhs_problem_registry b
    PLAN (b
     WHERE parser(l_line)
      AND b.active_ind=1
      AND b.problem="CHF")
    DETAIL
     t_record->pat_cnt += 1
     IF (mod(t_record->pat_cnt,1000)=1)
      stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 999))
     ENDIF
     idx = t_record->pat_cnt, t_record->pat_qual[idx].person_id = b.person_id, t_record->pat_qual[idx
     ].phys_id = b.pcp_id,
     t_record->pat_qual[idx].practice_id = b.practice_id
    FOOT REPORT
     stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
    WITH nocounter
   ;end select
   SET nsize = t_record->pat_cnt
   SET nbucketsize = 40
   SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
   SET nstart = 1
   SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
   SET stat = alterlist(t_record->pat_qual,ntotal)
   FOR (j = (nsize+ 1) TO ntotal)
     SET t_record->pat_qual[j].person_id = t_record->pat_qual[nsize].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     person p,
     person_alias pa,
     address a,
     bhs_problem_registry b,
     bhs_physician_location bp,
     bhs_practice_location bpl
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (p
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
      person_id)
      AND p.active_ind=1)
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND pa.person_alias_type_cd=mrn_cd
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (a
     WHERE (a.parent_entity_id= Outerjoin(p.person_id))
      AND (a.parent_entity_name= Outerjoin("PERSON")) )
     JOIN (b
     WHERE b.person_id=p.person_id
      AND b.problem="CHF")
     JOIN (bp
     WHERE bp.person_id=b.pcp_id)
     JOIN (bpl
     WHERE bpl.location_id=bp.location_id)
    ORDER BY p.person_id, pa.active_status_dt_tm DESC
    HEAD p.person_id
     done = 0, idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].
      person_id), t_record->pat_qual[idx].org_key = bpl.location_description,
     t_record->pat_qual[idx].org = bpl.location_description, t_record->pat_qual[idx].name = p
     .name_full_formatted, t_record->pat_qual[idx].dob = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
       .birth_tz),1),
     t_record->pat_qual[idx].street1 = a.street_addr, t_record->pat_qual[idx].street2 = a
     .street_addr2, t_record->pat_qual[idx].street3 = a.street_addr3,
     t_record->pat_qual[idx].street4 = a.street_addr4, t_record->pat_qual[idx].state = a.state,
     t_record->pat_qual[idx].city = a.city,
     t_record->pat_qual[idx].zip = a.zipcode
    HEAD pa.active_status_dt_tm
     IF (done=0)
      IF (pa.alias != "RAD*")
       t_record->pat_qual[idx].mrn = pa.alias, done = 1
      ENDIF
     ENDIF
    WITH orahint("index(pa XIE2PERSON_ALIAS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     problem p,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (p
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id
      AND n.nomen_list_key="REGISTRY-CHF")
    ORDER BY p.person_id
    HEAD p.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].problem_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     diagnosis dg,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (dg
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),dg.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=dg.nomenclature_id
      AND n.nomen_list_key="REGISTRY-CHF")
    ORDER BY dg.person_id
    HEAD dg.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].problem_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     problem p,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (p
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id
      AND n.nomen_list_key="REGISTRY-ATRIALFIBRILLATION")
    ORDER BY p.person_id
    HEAD p.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].af_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     diagnosis dg,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (dg
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),dg.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=dg.nomenclature_id
      AND n.nomen_list_key="REGISTRY-ATRIALFIBRILLATION")
    ORDER BY dg.person_id
    HEAD dg.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].af_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     sch_appt sa,
     sch_appt sa1
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (sa
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),sa.person_id,t_record->pat_qual[indx].
      person_id)
      AND sa.state_meaning="CHECKED IN"
      AND sa.role_meaning="PATIENT")
     JOIN (sa1
     WHERE sa1.schedule_id=sa.schedule_id
      AND parser(p_line)
      AND sa1.state_meaning="CHECKED IN"
      AND sa1.role_meaning="RESOURCE")
    ORDER BY sa.person_id, sa.beg_dt_tm DESC
    HEAD sa.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,sa.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].last_visit_dt_tm = cnvtdatetime(sa.beg_dt_tm), t_record->pat_qual[idx1]
     .last_visit_encntr_id = sa.encntr_id
    WITH orahint("index(sa XIE97SCH_APPT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     orders o,
     order_detail od
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (o
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
      person_id)
      AND o.catalog_cd IN (iv1_cd, iv2_cd, iv3_cd, iv4_cd, iv5_cd))
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning="RXROUTE"
      AND od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
     iv6_rte_cd))
    ORDER BY o.person_id, o.catalog_cd
    HEAD o.person_id
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id)
    HEAD o.catalog_cd
     t_record->pat_qual[idx].iv_meds_ind = 1
    WITH orahint("index(O XIE99ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     orders o
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (o
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
      person_id)
      AND o.catalog_cd IN (ace_med01_cd, ace_med02_cd, ace_med03_cd, ace_med04_cd, ace_med05_cd,
     ace_med06_cd, ace_med07_cd, ace_med08_cd, ace_med09_cd, ace_med10_cd,
     ace_med11_cd, ace_med12_cd, ace_med13_cd, ace_med14_cd, ace_med15_cd,
     ace_com01_cd, ace_com02_cd, ace_com03_cd, ace_com04_cd, ace_com05_cd,
     ace_com06_cd, ace_com07_cd, arb_med01_cd, arb_med02_cd, arb_med03_cd,
     arb_med04_cd, arb_med05_cd, arb_med06_cd, arb_med07_cd, arb_med08_cd,
     arb_med09_cd, arb_med10_cd, arb_med11_cd, arb_com01_cd, arb_com02_cd,
     arb_com03_cd, arb_com04_cd, arb_com05_cd, arb_com06_cd, arb_com07_cd,
     arb_com08_cd, bb1_cd, bb2_cd, bb3_cd, bb4_cd,
     bb5_cd, bb6_cd, bb7_cd, bb8_cd, bb9_cd,
     bb10_cd, bb11_cd, bb12_cd, bb13_cd, bb14_cd,
     bb15_cd, bb16_cd, bb17_cd, bb18_cd, warfarin_cd,
     coreg_cd, spir1_cd, spir2_cd)
      AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
     future_cd))
    ORDER BY o.person_id, o.catalog_cd
    HEAD o.person_id
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id)
    HEAD o.catalog_cd
     IF (o.catalog_cd IN (ace_med01_cd, ace_med02_cd, ace_med03_cd, ace_med04_cd, ace_med05_cd,
     ace_med06_cd, ace_med07_cd, ace_med08_cd, ace_med09_cd, ace_med10_cd,
     ace_med11_cd, ace_med12_cd, ace_med13_cd, ace_med14_cd, ace_med15_cd,
     ace_com01_cd, ace_com02_cd, ace_com03_cd, ace_com04_cd, ace_com05_cd,
     ace_com06_cd, ace_com07_cd, arb_med01_cd, arb_med02_cd, arb_med03_cd,
     arb_med04_cd, arb_med05_cd, arb_med06_cd, arb_med07_cd, arb_med08_cd,
     arb_med09_cd, arb_med10_cd, arb_med11_cd, arb_com01_cd, arb_com02_cd,
     arb_com03_cd, arb_com04_cd, arb_com05_cd, arb_com06_cd, arb_com07_cd,
     arb_com08_cd))
      t_record->pat_qual[idx].ace_arb_ind = 1
     ENDIF
     IF (o.catalog_cd IN (bb1_cd, bb2_cd, bb3_cd, bb4_cd, bb5_cd,
     bb6_cd, bb7_cd, bb8_cd, bb9_cd, bb10_cd,
     bb11_cd, bb12_cd, bb13_cd, bb14_cd, bb15_cd,
     bb16_cd, bb17_cd, bb18_cd))
      t_record->pat_qual[idx].beta_blocker_ind = 1
     ENDIF
     IF ((t_record->pat_qual[idx].af_ind=1))
      IF (o.catalog_cd=warfarin_cd)
       t_record->pat_qual[idx].warf_ind = 1
      ENDIF
     ELSE
      t_record->pat_qual[idx].warf_ind = 2
     ENDIF
     IF (o.catalog_cd IN (spir1_cd, spir2_cd)
      AND o.catalog_cd=coreg_cd)
      t_record->pat_qual[idx].spiro_ind = 1
     ENDIF
    WITH orahint("index(O XIE99ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     clinical_event ce
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (ce
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
      person_id)
      AND ce.event_cd IN (lv1_cd, lv2_cd, lv3_cd, lv4_cd, lv5_cd,
     lv6_cd, lv7_cd, lv8_cd, lv9_cd, lv10_cd,
     lv11_cd, lv12_cd, lv13_cd, lv14_cd, lv15_cd,
     lv16_cd, lv17_cd, lv18_cd, lv19_cd, lv20_cd,
     lv21_cd, lv22_cd, lv23_cd, lv24_cd, lv25_cd,
     lv26_cd, lv27_cd, lv28_cd, lv29_cd, lv30_cd,
     lv31_cd, lv32_cd, lv33_cd, lv34_cd, lv35_cd,
     lv36_cd, lv37_cd, lv38_cd, lv39_cd, lv40_cd,
     lv41_cd, lv42_cd, lv43_cd, lv44_cd, lv45_cd,
     lv46_cd, lv47_cd, lv48_cd, lv49_cd, lv50_cd,
     lv51_cd, lv52_cd, lv53_cd, lv54_cd, lv55_cd,
     lv56_cd, lv57_cd))
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].lv_dt_tm = ce.clinsig_updt_dt_tm, t_record->pat_qual[idx].lv_value =
     uar_get_code_display(ce.event_cd)
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     clinical_event ce
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (ce
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
      person_id)
      AND ce.event_cd=ldl_cd)
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].ldl_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[idx]
     .ldl_val = ce.result_val
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     clinical_event ce
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (ce
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
      person_id)
      AND ce.event_cd=creatinine_cd)
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].creatinine_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->
     pat_qual[idx].creatinine_val = ce.result_val
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     scd_story s,
     clinical_event ce,
     encounter e,
     scd_story_pattern ssp,
     scr_pattern sp,
     scd_paragraph spar,
     scr_paragraph_type spt,
     scd_sentence ss,
     scd_term st,
     scr_term_hier sth,
     scr_term_text sttt,
     scd_term_data std,
     diagnosis dg,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (s
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),s.person_id,t_record->pat_qual[indx].
      person_id)
      AND s.story_completion_status_cd=10396.00)
     JOIN (ce
     WHERE ce.event_id=s.event_id
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.event_tag != "In Error")
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND e.arrive_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime),- (365)))
     JOIN (ssp
     WHERE ssp.scd_story_id=s.scd_story_id)
     JOIN (sp
     WHERE sp.scr_pattern_id=ssp.scr_pattern_id
      AND sp.display_key="PHYSICIANDISCHARGESUMMARY")
     JOIN (spar
     WHERE spar.scd_story_id=s.scd_story_id)
     JOIN (spt
     WHERE spt.scr_paragraph_type_id=spar.scr_paragraph_type_id)
     JOIN (ss
     WHERE ss.scd_story_id=spar.scd_story_id
      AND ss.scd_paragraph_id=spar.scd_paragraph_id)
     JOIN (st
     WHERE st.scd_story_id=s.scd_story_id
      AND st.scd_sentence_id=ss.scd_sentence_id)
     JOIN (sth
     WHERE sth.scr_term_hier_id=st.scr_term_hier_id)
     JOIN (sttt
     WHERE sttt.scr_term_id=sth.scr_term_id)
     JOIN (std
     WHERE std.scd_term_data_id=st.scd_term_data_id
      AND std.fkey_entity_name="DIAGNOSIS")
     JOIN (dg
     WHERE dg.diagnosis_id=std.fkey_id)
     JOIN (n
     WHERE n.nomenclature_id=dg.nomenclature_id
      AND n.nomen_list_key="REGISTRY-CHF")
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].hosp_dt_tm = cnvtdatetime(e.arrive_dt_tm)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     problem p,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (p
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id
      AND n.nomen_list_key="REGISTRY-INTERNALCARDIACDEVICE")
    ORDER BY p.person_id
    HEAD p.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].icd_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     diagnosis dg,
     bhs_nomen_list n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (dg
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),dg.person_id,t_record->pat_qual[indx].
      person_id))
     JOIN (n
     WHERE n.nomenclature_id=dg.nomenclature_id
      AND n.nomen_list_key="REGISTRY-INTERNALCARDIACDEVICE")
    ORDER BY dg.person_id
    HEAD dg.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].icd_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (hem
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
      person_id)
      AND hem.parent_entity_name="HM_EXPECT_STEP")
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Heart Failure Education")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].education = uar_get_code_display(hem.modifier_reason_cd)
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (hem
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
      person_id)
      AND hem.parent_entity_name="HM_EXPECT_STEP"
      AND hem.modifier_reason_cd IN (yes_cd, no_cd))
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Tobacco Use")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].smoking = uar_get_code_display(hem.modifier_reason_cd)
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     clinical_event ce
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (ce
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
      person_id)
      AND ce.event_cd=pneu_vac_cd)
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].pneu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     clinical_event ce
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (ce
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
      person_id)
      AND ce.event_cd=flu_vac_cd)
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].flu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (hem
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
      person_id)
      AND hem.parent_entity_name="HM_EXPECT_STEP")
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Influenza")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id)
     IF (cnvtdatetime(hem.updt_dt_tm) > cnvtdatetime(t_record->pat_qual[idx].flu_vac_dt_tm))
      t_record->pat_qual[idx].flu_vac_dt_tm = cnvtdatetime(hem.updt_dt_tm)
     ENDIF
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (hem
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
      person_id)
      AND hem.parent_entity_name="HM_EXPECT_STEP")
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Pneumococcal")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id)
     IF (cnvtdatetime(hem.updt_dt_tm) > cnvtdatetime(t_record->pat_qual[idx].pneu_vac_dt_tm))
      t_record->pat_qual[idx].pneu_vac_dt_tm = cnvtdatetime(hem.updt_dt_tm)
     ENDIF
    WITH maxcol = 1000
   ;end select
   SELECT INTO "chf_registry.xls"
    name = t_record->pat_qual[d.seq].name, id = t_record->pat_qual[d.seq].person_id
    FROM (dummyt d  WITH seq = t_record->pat_cnt),
     bhs_problem_registry b,
     person p
    PLAN (d)
     JOIN (b
     WHERE (b.person_id=t_record->pat_qual[d.seq].person_id))
     JOIN (p
     WHERE p.person_id=b.pcp_id)
    ORDER BY name, id
    HEAD REPORT
     t_line = concat("Quarterly CHF Registry for ",t_record->name), col 0, t_line,
     row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),"Date of Birth",
      char(9),"PCP",char(9),"Last office visit with PCP",char(9),
      "CHF on Problem List",char(9),"IV Meds",char(9),"Spiro and Coreg",
      char(9),"Beta Blocker Therapy",char(9),"ACEI/ARB Prescribed",char(9),
      "Warfarin for Atrial Fib or Cont",char(9),"LV Assessment Date Time",char(9),"LV Assessment",
      char(9),"LDL Date Time",char(9),"LDL Value",char(9),
      "Creatinine Date Time",char(9),"Creatinine Value",char(9),"Last Hospitalization for HF dx",
      char(9),"ICD/ Biventricular ICD",char(9),"Patient Education",char(9),
      "Smoking Status",char(9),"Pneumo-coccal Vaccine",char(9),"Influenza Vaccine",
      char(9),"Street Address",char(9),"City",char(9),
      "State",char(9),"Zip Code",char(9)), col 0,
     t_line, row + 1
    HEAD name
     null
    HEAD id
     IF ((t_record->pat_qual[d.seq].problem_ind=1))
      problem = "yes"
     ELSE
      problem = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].ace_arb_ind=1))
      ace_arb = "yes"
     ELSE
      ace_arb = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].beta_blocker_ind=1))
      beta_blocker = "yes"
     ELSE
      beta_blocker = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].warf_ind=1))
      warfarin = "yes"
     ELSEIF ((t_record->pat_qual[d.seq].warf_ind=0))
      warfarin = "no"
     ELSE
      warfarin = "NA"
     ENDIF
     IF ((t_record->pat_qual[d.seq].icd_ind=1))
      icd = "yes"
     ELSE
      icd = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].iv_meds_ind=1))
      iv_meds = "yes"
     ELSE
      iv_meds = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].spiro_ind=1))
      spiro = "yes"
     ELSE
      spiro = "no"
     ENDIF
     address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2,
       " ",t_record->pat_qual[d.seq].street3,
       " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(9
       ),t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
      char(9),p.name_full_formatted,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,
       "mm/dd/yyyy;;q"),char(9),
      problem,char(9),iv_meds,char(9),spiro,
      char(9),beta_blocker,char(9),ace_arb,char(9),
      warfarin,char(9),format(t_record->pat_qual[d.seq].lv_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->
      pat_qual[d.seq].lv_value,
      char(9),format(t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[
      d.seq].ldl_val,char(9),
      format(t_record->pat_qual[d.seq].creatinine_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d
      .seq].creatinine_val,char(9),format(t_record->pat_qual[d.seq].hosp_dt_tm,"mm/dd/yyyy;;q"),
      char(9),icd,char(9),t_record->pat_qual[d.seq].education,char(9),
      t_record->pat_qual[d.seq].smoking,char(9),format(t_record->pat_qual[d.seq].pneu_vac_dt_tm,
       "mm/dd/yyyy;;q"),char(9),format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),
      char(9),address,char(9),t_record->pat_qual[d.seq].city,char(9),
      t_record->pat_qual[d.seq].state,char(9),t_record->pat_qual[d.seq].zip,char(9)), col 0,
     t_line, row + 1
    WITH nocounter, maxcol = 1000, formfeed = none
   ;end select
   IF (findfile("chf_registry.xls")=1)
    SET email_list = t_record->practice_qual[i].email
    SET subject_line = concat("Quarterly CHF Registry Report for ",t_record->name)
    CALL emailfile("chf_registry.xls","chf_registry.xls",email_list,subject_line,1)
   ENDIF
   SET t_record->pat_cnt = 0
   SET stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
 ENDFOR
#exit_script
 SET reply->status_data[1].status = "S"
END GO
