CREATE PROGRAM chf_data_collection:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 doc_id = f8
     2 chf_ind = i2
     2 bnp_ind = i2
     2 ace_ind = i2
     2 arb_ind = i2
     2 dig_ind = i2
     2 ld_ind = i2
     2 nit_ind = i2
     2 spir_ind = i2
     2 bb_ind = i2
     2 cor_ind = i2
     2 meto_ind = i2
     2 iv_ind = i2
     2 minox_ind = i2
 )
 SET dr_k_cd = 749878.00
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE iv1_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVINFUSION"))
 DECLARE iv2_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSH"))
 DECLARE iv3_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSHSLOWLY"))
 DECLARE iv4_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPB"))
 DECLARE iv5_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,
   "SUBCUTANEOUSINJECTION"))
 DECLARE iv6_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"INTRAMUSCULAR"))
 DECLARE bnp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"NTPROBNP"))
 DECLARE ace1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"QUINAPRIL"))
 DECLARE ace2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEQUINAPRIL"))
 DECLARE ace3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PERINDOPRIL"))
 DECLARE ace4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"RAMIPRIL"))
 DECLARE ace5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"AMLODIPINEBENAZEPRIL")
  )
 DECLARE ace6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BENAZEPRIL"))
 DECLARE ace7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BENAZEPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CAPTOPRIL"))
 DECLARE ace9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CAPTOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ENALAPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FOSINOPRIL"))
 DECLARE ace13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FOSINOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"HYDROCHLOROTHIAZIDE")
  )
 DECLARE ace15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEMOEXIPRIL"))
 DECLARE ace16_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRILFELODIPINE")
  )
 DECLARE ace17_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace18_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRANDOLAPRIL"))
 DECLARE ace19_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOEXIPRIL"))
 DECLARE ace20_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELISINOPRIL"))
 DECLARE ace21_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TRANDOLAPRILVERAPAMIL"))
 DECLARE arb1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CANDESARTAN"))
 DECLARE arb2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CANDESARTANHYDROCHLOROTHIAZIDE"))
 DECLARE arb3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEIRBESARTAN"))
 DECLARE arb4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IRBESARTAN"))
 DECLARE arb5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TAZAROTENETOPICAL"))
 DECLARE arb6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OLMESARTAN"))
 DECLARE arb7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEOLMESARTAN"))
 DECLARE arb8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LOSARTAN"))
 DECLARE arb9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"VALSARTAN"))
 DECLARE arb10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEVALSARTAN"))
 DECLARE arb11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELOSARTAN"))
 DECLARE arb12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TELMISARTAN"))
 DECLARE arb13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDETELMISARTAN"))
 DECLARE arb14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"EPROSARTAN"))
 DECLARE digoxin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DIGOXIN"))
 DECLARE ld1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUMETANIDE"))
 DECLARE ld2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TORSEMIDE"))
 DECLARE ld3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ETHACRYNICACID"))
 DECLARE ld4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FUROSEMIDE"))
 DECLARE nit1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDRALAZINEISOSORBIDEDINITRATE"))
 DECLARE nit2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ISOSORBIDEDINITRATE"))
 DECLARE nit3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ISOSORBIDEMONONITRATE"
   ))
 DECLARE nit4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NITROGLYCERIN"))
 DECLARE spir1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SPIRONOLACTONE"))
 DECLARE spir2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDESPIRONOLACTONE"))
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
 DECLARE metolazone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"METOLAZONE"))
 DECLARE iv1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MILRINONE"))
 DECLARE iv2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NESIRITIDE"))
 DECLARE iv3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DOBUTAMINE"))
 DECLARE iv4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NITROPRUSSIDE"))
 DECLARE minoxidil_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MINOXIDIL"))
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 DECLARE t_line = vc
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr
  PLAN (ppr
   WHERE ppr.prsnl_person_id=dr_k_cd
    AND ppr.active_ind=1
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   t_record->pat_cnt = (t_record->pat_cnt+ 1)
   IF (mod(t_record->pat_cnt,1000)=1)
    stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 999))
   ENDIF
   t_record->pat_qual[t_record->pat_cnt].pid = ppr.person_id, t_record->pat_qual[t_record->pat_cnt].
   doc_id = ppr.prsnl_person_id
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->pat_cnt
 SET nbucketsize = 40
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->pat_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->pat_qual[j].pid = t_record->pat_qual[nsize].pid
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   problem p,
   bhs_nomen_list b
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (p
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].pid))
   JOIN (b
   WHERE b.nomenclature_id=p.nomenclature_id
    AND b.nomen_list_key="REGISTRY-CHF")
  DETAIL
   idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].pid), t_record->
   pat_qual[idx].chf_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   diagnosis di,
   bhs_nomen_list b
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (di
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),di.person_id,t_record->pat_qual[indx].pid))
   JOIN (b
   WHERE b.nomenclature_id=di.nomenclature_id
    AND b.nomen_list_key="REGISTRY-CHF")
  DETAIL
   idx = locateval(indx,1,t_record->pat_cnt,di.person_id,t_record->pat_qual[indx].pid), t_record->
   pat_qual[idx].chf_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].pid)
    AND ce.event_cd=bnp_cd
    AND ce.result_units_cd != null)
  ORDER BY ce.person_id, ce.clinical_event_id
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].pid)
  HEAD ce.clinical_event_id
   IF (cnvtint(ce.result_val) > 400)
    t_record->pat_qual[idx].bnp_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   orders o,
   order_detail od
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].pid)
    AND o.catalog_cd IN (ace1_cd, ace2_cd, ace3_cd, ace4_cd, ace5_cd,
   ace6_cd, ace7_cd, ace8_cd, ace9_cd, ace10_cd,
   ace11_cd, ace12_cd, ace13_cd, ace14_cd, ace15_cd,
   ace16_cd, ace17_cd, ace18_cd, ace19_cd, ace20_cd,
   ace21_cd, arb1_cd, arb2_cd, arb3_cd, arb4_cd,
   arb5_cd, arb6_cd, arb7_cd, arb8_cd, arb9_cd,
   arb10_cd, arb11_cd, arb12_cd, arb13_cd, arb14_cd,
   digoxin_cd, ld1_cd, ld2_cd, ld3_cd, ld4_cd,
   nit1_cd, nit2_cd, nit3_cd, nit4_cd, spir1_cd,
   spir2_cd, bb1_cd, bb2_cd, bb3_cd, bb4_cd,
   bb5_cd, bb6_cd, bb7_cd, bb8_cd, bb9_cd,
   bb10_cd, bb11_cd, bb12_cd, bb13_cd, bb14_cd,
   bb15_cd, bb16_cd, bb17_cd, bb18_cd, coreg_cd,
   metolazone_cd, iv1_cd, iv2_cd, iv3_cd, iv4_cd,
   minoxidil_cd)
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="RXROUTE")
  ORDER BY o.person_id, o.order_id
  HEAD o.person_id
   idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].pid)
  HEAD o.order_id
   IF (o.catalog_cd IN (ace1_cd, ace2_cd, ace3_cd, ace4_cd, ace5_cd,
   ace6_cd, ace7_cd, ace8_cd, ace9_cd, ace10_cd,
   ace11_cd, ace12_cd, ace13_cd, ace14_cd, ace15_cd,
   ace16_cd, ace17_cd, ace18_cd, ace19_cd, ace20_cd,
   ace21_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].ace_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (arb1_cd, arb2_cd, arb3_cd, arb4_cd, arb5_cd,
   arb6_cd, arb7_cd, arb8_cd, arb9_cd, arb10_cd,
   arb11_cd, arb12_cd, arb13_cd, arb14_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].arb_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd=digoxin_cd)
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].dig_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (ld1_cd, ld2_cd, ld3_cd, ld4_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].ld_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (nit1_cd, nit2_cd, nit3_cd, nit4_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].nit_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (spir1_cd, spir2_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].spir_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (bb1_cd, bb2_cd, bb3_cd, bb4_cd, bb5_cd,
   bb6_cd, bb7_cd, bb8_cd, bb9_cd, bb10_cd,
   bb11_cd, bb12_cd, bb13_cd, bb14_cd, bb15_cd,
   bb16_cd, bb17_cd, bb18_cd))
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].bb_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd=coreg_cd)
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].cor_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd=metolazone_cd)
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].meto_ind = 1
    ENDIF
   ENDIF
   IF (o.catalog_cd IN (iv1_cd, iv2_cd, iv3_cd, iv4_cd))
    t_record->pat_qual[idx].iv_ind = 1
   ENDIF
   IF (o.catalog_cd=minoxidil_cd)
    IF (od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
    iv6_rte_cd))
     t_record->pat_qual[idx].iv_ind = 1
    ELSE
     t_record->pat_qual[idx].minox_ind = 1
    ENDIF
   ENDIF
  WITH orahint("index(O XIE99ORDERS)")
 ;end select
 SELECT INTO "chf_data.xls"
  age = cnvtage(p.birth_dt_tm)
  FROM (dummyt d  WITH seq = t_record->pat_cnt),
   person p,
   prsnl pr,
   person_alias pa
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=t_record->pat_qual[d.seq].pid)
    AND p.active_ind=1)
   JOIN (pr
   WHERE (pr.person_id=t_record->pat_qual[d.seq].doc_id))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1)
  ORDER BY pr.name_full_formatted, p.name_full_formatted, p.person_id
  HEAD REPORT
   t_line = concat("Physician",char(9),"Patient",char(9),"Age",
    char(9),"MRN #",char(9),"Meets Criteria",char(9),
    "Problem or Dx",char(9),"proBNP",char(9),"ACE",
    char(9),"ARB",char(9),"Digoxin",char(9),
    "Loop Diuretic",char(9),"Nitrates",char(9),"Spirinolactone",
    char(9),"Beta Blocker",char(9),"coreg",char(9),
    "Metolazone",char(9),"IV Meds",char(9),"Minoxidil"), col 0, t_line,
   row + 1
  HEAD p.person_id
   criteria_ind = 0
   IF ((t_record->pat_qual[d.seq].chf_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].bnp_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].dig_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].dig_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].dig_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].ld_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].ld_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].ld_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].nit_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].nit_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].nit_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ld_ind=1)
    AND (t_record->pat_qual[d.seq].nit_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].meto_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].cor_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].spir_ind=1)
    AND (t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].bb_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].spir_ind=1)
    AND (t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].bb_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].spir_ind=1)
    AND (t_record->pat_qual[d.seq].ace_ind=1)
    AND (t_record->pat_qual[d.seq].arb_ind=1)
    AND (t_record->pat_qual[d.seq].bb_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].ld_ind=1)
    AND (t_record->pat_qual[d.seq].bb_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].iv_ind=1))
    criteria_ind = 1
   ENDIF
   IF ((t_record->pat_qual[d.seq].minox_ind=1))
    criteria_ind = 1
   ENDIF
   t_line = concat(pr.name_full_formatted,char(9),p.name_full_formatted,char(9),age,
    char(9),pa.alias,char(9),trim(cnvtstring(criteria_ind)),char(9),
    trim(cnvtstring(t_record->pat_qual[d.seq].chf_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d
      .seq].bnp_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d.seq].ace_ind)),
    char(9),trim(cnvtstring(t_record->pat_qual[d.seq].arb_ind)),char(9),trim(cnvtstring(t_record->
      pat_qual[d.seq].dig_ind)),char(9),
    trim(cnvtstring(t_record->pat_qual[d.seq].ld_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d
      .seq].nit_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d.seq].spir_ind)),
    char(9),trim(cnvtstring(t_record->pat_qual[d.seq].bb_ind)),char(9),trim(cnvtstring(t_record->
      pat_qual[d.seq].cor_ind)),char(9),
    trim(cnvtstring(t_record->pat_qual[d.seq].meto_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d
      .seq].iv_ind)),char(9),trim(cnvtstring(t_record->pat_qual[d.seq].minox_ind))), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 DECLARE dclcom = vc
 IF (findfile("chf_data.xls")=1)
  SET email_list = "anthony.jacobson@bhs.org"
  SET subject_line = "CHF Data for Dr K (All Patients)"
  CALL emailfile("chf_data.xls","chf_data.xls",email_list,subject_line,1)
 ENDIF
END GO
