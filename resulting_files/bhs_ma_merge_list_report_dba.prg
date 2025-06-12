CREATE PROGRAM bhs_ma_merge_list_report:dba
 PROMPT
  "Output to File/Printer/MINE                       " = "MINE",
  "Start Date for Merge List Report" = curdate,
  "End Date for Merge List Report" = curdate
 RECORD data(
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 to_person_id = f8
     2 to_person_name_full = c25
     2 to_person_addr_ln_1 = c15
     2 to_person_addr_ln_2 = c15
     2 to_bhs_mrn = c10
     2 to_bmc_mrn = c10
     2 to_fmc_mrn = c10
     2 to_mlh_mrn = c10
     2 to_fin_nbr = c10
     2 to_ssn = c9
     2 to_gender = c1
     2 to_dob = c10
     2 to_attend_doc = c20
     2 to_admit_dx = c20
     2 to_pat_loc = c15
     2 to_pat_type = c15
     2 from_person_id = f8
     2 from_person_name_full = c20
     2 from_person_addr_ln_1 = c15
     2 from_person_addr_ln_2 = c15
     2 from_bhs_mrn = c10
     2 from_bmc_mrn = c10
     2 from_fmc_mrn = c10
     2 from_mlh_mrn = c10
     2 from_fin_nbr = c10
     2 from_ssn = c9
     2 from_gender = c1
     2 from_dob = c10
     2 from_attend_doc = c10
     2 from_admit_dx = c20
     2 encntr_id = f8
     2 antepartum_flag = c1
     2 audiology_flag = c1
     2 cardio_flag = c1
     2 consults_flag = c1
     2 lab_flag = c1
     2 neuro_diag_flag = c1
     2 nutri_serv_flag = c1
     2 occ_therapy_flag = c1
     2 patient_care_flag = c1
     2 pharmacy_flag = c1
     2 phys_therapy_flag = c1
     2 pulm_lab_flag = c1
     2 pulm_med_flag = c1
     2 rad_flag = c1
     2 resp_flag = c1
     2 speech_therapy_flag = c1
 )
 DECLARE equal_line = c12 WITH public, constant(fillstring(12,"="))
 SET start_date =  $2
 SET end_date =  $3
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE fin_nbr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE bhs_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN"))
 DECLARE bmc_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN"))
 DECLARE fmc_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"FMCMRN"))
 DECLARE mlh_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN"))
 DECLARE antep_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE audio_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE cardio_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"CARDIOLOGY"))
 DECLARE consults_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"CONSULTS"))
 DECLARE lab_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE neuro_diag_cat_cd = f8 WITH pubic, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE nutri_serv_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE occ_therapy_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE pat_care_cat_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"PATIENTCARE"))
 DECLARE pharm_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE phys_therapy_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE pulm_lab_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE pulm_med_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULMONARY"))
 DECLARE rad_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RADIOLOGY"))
 DECLARE resp_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE speech_cat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE attend_doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE home_addr_type_cd = f8 WITH public, constant(uar_get_code_by("meaning",212,"HOME"))
 DECLARE admit_diag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",17,"ADMIT"))
 SELECT INTO "nl:"
  pc.to_person_id, pc.from_person_id, pc.encntr_id,
  pc.combine_id, p.name_full_formatted, p.sex_cd,
  p.birth_dt_tm, pa.alias, ad.street_addr,
  ad.city, ad.state, ad.zipcode,
  e.encntr_type_cd, e.loc_nurse_unit_cd, ea.alias,
  pl.name_full_formatted, dg.diag_ftdesc
  FROM person_combine pc,
   person p,
   person_alias pa,
   address ad,
   encounter e,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   diagnosis dg
  PLAN (pc
   WHERE pc.updt_dt_tm >= cnvtdatetime(cnvtdate2(start_date,"YYYYMMDD"),0)
    AND pc.updt_dt_tm <= cnvtdatetime(cnvtdate2(end_date,"YYYYMMDD"),235959)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.to_person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(pc.to_person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_cd))
   JOIN (ad
   WHERE ad.parent_entity_id=outerjoin(pc.to_person_id)
    AND ad.parent_entity_name=outerjoin("PERSON")
    AND ad.address_type_cd=outerjoin(home_addr_type_cd))
   JOIN (e
   WHERE e.encntr_id=outerjoin(pc.encntr_id)
    AND e.person_id=outerjoin(pc.to_person_id))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(attend_doc_cd))
   JOIN (pl
   WHERE pl.person_id=outerjoin(epr.prsnl_person_id))
   JOIN (dg
   WHERE dg.encntr_id=outerjoin(e.encntr_id)
    AND dg.diag_type_cd=outerjoin(admit_diag_cd))
  ORDER BY pc.person_combine_id
  HEAD REPORT
   pcnt = 0
  HEAD pc.person_combine_id
   pcnt = (pcnt+ 1)
   IF (mod(pcnt,10)=1
    AND pcnt != 1)
    stat = alterlist(data->person_qual,(pcnt+ 9))
   ENDIF
   stat = alterlist(data->person_qual,pcnt), data->person_qual[pcnt].to_person_id = pc.to_person_id,
   data->person_qual[pcnt].from_person_id = pc.from_person_id,
   data->person_qual[pcnt].encntr_id = pc.encntr_id, data->person_qual[pcnt].to_person_name_full =
   substring(1,20,p.name_full_formatted), data->person_qual[pcnt].to_person_addr_ln_1 = substring(1,
    15,ad.street_addr),
   data->person_qual[pcnt].to_person_addr_ln_2 = concat(trim(ad.city),", ",trim(ad.state)," ",trim(ad
     .zipcode)), data->person_qual[pcnt].to_gender = substring(1,1,uar_get_code_display(p.sex_cd)),
   data->person_qual[pcnt].to_dob = format(p.birth_dt_tm,"MM/DD/YYYY;;D"),
   data->person_qual[pcnt].to_ssn = pa.alias, data->person_qual[pcnt].to_admit_dx = substring(1,20,dg
    .diag_ftdesc), data->person_qual[pcnt].to_attend_doc = substring(1,20,pl.name_full_formatted),
   data->person_qual[pcnt].to_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd), data->person_qual[
   pcnt].to_pat_type = uar_get_code_display(e.encntr_type_cd), data->person_qual[pcnt].to_fin_nbr =
   ea.alias,
   data->person_qual[pcnt].antepartum_flag = "N", data->person_qual[pcnt].audiology_flag = "N", data
   ->person_qual[pcnt].cardio_flag = "N",
   data->person_qual[pcnt].consults_flag = "N", data->person_qual[pcnt].lab_flag = "N", data->
   person_qual[pcnt].neuro_diag_flag = "N",
   data->person_qual[pcnt].nutri_serv_flag = "N", data->person_qual[pcnt].occ_therapy_flag = "N",
   data->person_qual[pcnt].patient_care_flag = "N",
   data->person_qual[pcnt].pharmacy_flag = "N", data->person_qual[pcnt].phys_therapy_flag = "N", data
   ->person_qual[pcnt].pulm_lab_flag = "N",
   data->person_qual[pcnt].pulm_med_flag = "N", data->person_qual[pcnt].rad_flag = "N", data->
   person_qual[pcnt].resp_flag = "N",
   data->person_qual[pcnt].speech_therapy_flag = "N"
  DETAIL
   row + 0
  FOOT REPORT
   stat = alterlist(data->person_qual,pcnt), data->person_qual_cnt = pcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p.sex_cd, p.birth_dt_tm,
  pa.alias, ad.street_addr, ad.city,
  ad.state, ad.zipcode
  FROM (dummyt dd  WITH seq = value(data->person_qual_cnt)),
   person p,
   person_alias pa,
   address ad
  PLAN (dd
   WHERE (data->person_qual_cnt > 0))
   JOIN (p
   WHERE (p.person_id=data->person_qual[dd.seq].from_person_id))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(ssn_cd))
   JOIN (ad
   WHERE ad.parent_entity_id=outerjoin(p.person_id)
    AND ad.parent_entity_name=outerjoin("PERSON")
    AND ad.address_type_cd=outerjoin(home_addr_type_cd))
  DETAIL
   data->person_qual[dd.seq].from_person_name_full = substring(1,20,p.name_full_formatted), data->
   person_qual[dd.seq].from_person_addr_ln_1 = substring(1,15,ad.street_addr), data->person_qual[dd
   .seq].from_person_addr_ln_2 = concat(trim(ad.city),", ",trim(ad.state)," ",trim(ad.zipcode)),
   data->person_qual[dd.seq].from_gender = substring(1,1,uar_get_code_display(p.sex_cd)), data->
   person_qual[dd.seq].from_dob = format(p.birth_dt_tm,"MM/DD/YYYY;;D"), data->person_qual[dd.seq].
   from_ssn = pa.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pa.alias
  FROM (dummyt dd  WITH seq = value(data->person_qual_cnt)),
   person_alias pa
  PLAN (dd
   WHERE (data->person_qual_cnt > 0))
   JOIN (pa
   WHERE (pa.person_id=data->person_qual[dd.seq].to_person_id)
    AND pa.person_alias_type_cd IN (cmrn_cd, mrn_cd)
    AND pa.alias_pool_cd IN (bhs_mrn_pool_cd, bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd))
  DETAIL
   CASE (pa.alias_pool_cd)
    OF bhs_mrn_pool_cd:
     data->person_qual[dd.seq].to_bhs_mrn = pa.alias
    OF bmc_mrn_pool_cd:
     data->person_qual[dd.seq].to_bmc_mrn = pa.alias
    OF fmc_mrn_pool_cd:
     data->person_qual[dd.seq].to_fmc_mrn = pa.alias
    OF mlh_mrn_pool_cd:
     data->person_qual[dd.seq].to_mlh_mrn = pa.alias
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pa.alias
  FROM (dummyt dd  WITH seq = value(data->person_qual_cnt)),
   person_alias pa
  PLAN (dd
   WHERE (data->person_qual_cnt > 0))
   JOIN (pa
   WHERE (pa.person_id=data->person_qual[dd.seq].from_person_id)
    AND pa.person_alias_type_cd IN (cmrn_cd, mrn_cd)
    AND pa.alias_pool_cd IN (bhs_mrn_pool_cd, bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd))
  DETAIL
   CASE (pa.alias_pool_cd)
    OF bhs_mrn_pool_cd:
     data->person_qual[dd.seq].from_bhs_mrn = pa.alias
    OF bmc_mrn_pool_cd:
     data->person_qual[dd.seq].from_bmc_mrn = pa.alias
    OF fmc_mrn_pool_cd:
     data->person_qual[dd.seq].from_fmc_mrn = pa.alias
    OF mlh_mrn_pool_cd:
     data->person_qual[dd.seq].from_mlh_mrn = pa.alias
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(data->person_qual_cnt)),
   orders o
  PLAN (dd
   WHERE (data->person_qual_cnt > 0))
   JOIN (o
   WHERE (o.encntr_id=data->person_qual[dd.seq].encntr_id)
    AND o.catalog_type_cd IN (antep_cat_cd, audio_cat_cd, cardio_cat_cd, consults_cat_cd, lab_cat_cd,
   neuro_diag_cat_cd, nutri_serv_cat_cd, occ_therapy_cat_cd, pat_care_cat_cd, pharm_cat_cd,
   phys_therapy_cat_cd, pulm_lab_cat_cd, pulm_med_cat_cd, rad_cat_cd, resp_cat_cd,
   speech_cat_cd)
    AND o.active_ind=1)
  DETAIL
   CASE (o.catalog_type_cd)
    OF antep_cat_cd:
     data->person_qual[dd.seq].antepartum_flag = "Y"
    OF audio_cat_cd:
     data->person_qual[dd.seq].audiology_flag = "Y"
    OF cardio_cat_cd:
     data->person_qual[dd.seq].cardio_flag = "Y"
    OF consults_cat_cd:
     data->person_qual[dd.seq].consults_flag = "Y"
    OF lab_cat_cd:
     data->person_qual[dd.seq].lab_flag = "Y"
    OF neuro_diag_cat_cd:
     data->person_qual[dd.seq].neuro_diag_flag = "Y"
    OF nutri_serv_cat_cd:
     data->person_qual[dd.seq].nutri_serv_flag = "Y"
    OF occ_therapy_cat_cd:
     data->person_qual[dd.seq].occ_therapy_flag = "Y"
    OF pat_care_cat_cd:
     data->person_qual[dd.seq].patient_care_flag = "Y"
    OF pharm_cat_cd:
     data->person_qual[dd.seq].pharmacy_flag = "Y"
    OF phys_therapy_cat_cd:
     data->person_qual[dd.seq].phys_therapy_flag = "Y"
    OF pulm_lab_cat_cd:
     data->person_qual[dd.seq].pulm_lab_flag = "Y"
    OF pulm_med_cat_cd:
     data->person_qual[dd.seq].pulm_med_flag = "Y"
    OF rad_cat_cd:
     data->person_qual[dd.seq].rad_flag = "Y"
    OF resp_cat_cd:
     data->person_qual[dd.seq].resp_flag = "Y"
    OF speech_cat_cd:
     data->person_qual[dd.seq].speech_therapy_flag = "Y"
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO value( $1)
  dd.seq, to_person_id = data->person_qual[dd.seq].to_person_id
  FROM dummyt dd
  PLAN (dd
   WHERE (data->person_qual_cnt > 0))
  ORDER BY data->person_qual[dd.seq].to_person_id
  HEAD PAGE
   xcol1 = 30, xcol2 = 65, xcol3 = 90,
   xcol4 = 230, xcol5 = 310, xcol6 = 345,
   xcol7 = 370, xcol8 = 60, xcol9 = 80,
   xcol10 = 170, xcol11 = 340, xcol12 = 360,
   xcol13 = 450, xcol14 = 390, xcol15 = 360,
   yrow = 0, cnt = value(data->person_qual_cnt), stat = value(size(data->person_qual,5)),
   MACRO (rowplusone)
    yrow = (yrow+ 10), row + 1
   ENDMACRO
  DETAIL
   FOR (x = 1 TO data->person_qual_cnt)
     IF (x > 1)
      BREAK
     ENDIF
     xcol = 200,
     CALL print(calcpos(xcol,yrow)), "{b}BAYSTATE HEALTH SYSTEMS{endb}",
     rowplusone,
     CALL print(calcpos(xcol1,yrow)), curdate"mm/dd/yy;;D",
     " ", curtime, rowplusone,
     CALL print(calcpos(xcol1,yrow)), equal_line,
     CALL print(calcpos(xcol5,yrow)),
     "M   M EEEEE RRRR  GGGGG EEEEE", rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "MERGE NOTICE",
     CALL print(calcpos(xcol5,yrow)), "MM MM E     R   R G     E",
     rowplusone,
     CALL print(calcpos(xcol5,yrow)), "M M M EEE   RRRR  G GGG EEE",
     rowplusone,
     CALL print(calcpos(xcol1,yrow)), "SAME PATIENT",
     CALL print(calcpos(xcol5,yrow)), "M   M E     R  R  G   G E", rowplusone,
     CALL print(calcpos(xcol1,yrow)), equal_line,
     CALL print(calcpos(xcol5,yrow)),
     "M   M EEEEE R   R GGGGG EEEEE", rowplusone,
     CALL print(calcpos(xcol5,yrow)),
     "{b} -PERMANENT CHART COPY-{endb}", rowplusone, rowplusone,
     rowplusone,
     CALL print(calcpos(xcol2,yrow)), "{b}SENDING PATIENT{endb}",
     CALL print(calcpos(xcol6,yrow)), "{b}RECEIVING PATIENT{endb}", rowplusone,
     CALL print(calcpos(xcol1,yrow)), "NAME:",
     CALL print(calcpos(xcol2,yrow)),
     data->person_qual[x].from_person_name_full,
     CALL print(calcpos(xcol5,yrow)), "NAME:",
     CALL print(calcpos(xcol6,yrow)), data->person_qual[x].to_person_name_full, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "ADDR:",
     CALL print(calcpos(xcol2,yrow)),
     data->person_qual[x].from_person_addr_ln_1,
     CALL print(calcpos(xcol5,yrow)), "ADDR:",
     CALL print(calcpos(xcol6,yrow)), data->person_qual[x].to_person_addr_ln_1, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "BHS MR #:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_bhs_mrn,
     CALL print(calcpos(xcol5,yrow)), "BHS MR #:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_bhs_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "BMC MR #:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_bmc_mrn,
     CALL print(calcpos(xcol5,yrow)), "BMC MR #:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_bmc_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "FMC MR #:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_fmc_mrn,
     CALL print(calcpos(xcol5,yrow)), "FMC MR #:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_fmc_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "MLH MR #:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_mlh_mrn,
     CALL print(calcpos(xcol5,yrow)), "MLH MR #:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_mlh_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "ACCOUNT#:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_fin_nbr,
     CALL print(calcpos(xcol5,yrow)), "ACCOUNT#:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_fin_nbr, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "SOC SEC#:",
     CALL print(calcpos(xcol3,yrow)),
     data->person_qual[x].from_ssn,
     CALL print(calcpos(xcol5,yrow)), "SOC SEC#:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_ssn, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "SEX:",
     CALL print(calcpos(xcol8,yrow)),
     data->person_qual[x].from_gender,
     CALL print(calcpos(xcol9,yrow)), "DATE OF BIRTH:",
     CALL print(calcpos(xcol10,yrow)), data->person_qual[x].from_dob,
     CALL print(calcpos(xcol5,yrow)),
     "SEX:",
     CALL print(calcpos(xcol11,yrow)), data->person_qual[x].to_gender,
     CALL print(calcpos(xcol12,yrow)), "DATE OF BIRTH:",
     CALL print(calcpos(xcol13,yrow)),
     data->person_qual[x].to_dob, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "ATT. MD :",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_attend_doc,
     CALL print(calcpos(xcol5,yrow)), "ATT. MD :",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_attend_doc, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "ADMIT DX:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_admit_dx,
     CALL print(calcpos(xcol5,yrow)), "ADMIT DX:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_admit_dx, rowplusone,
     CALL print(calcpos(xcol5,yrow)),
     "PATIENT LOC :",
     CALL print(calcpos(xcol14,yrow)), data->person_qual[x].to_pat_loc,
     rowplusone,
     CALL print(calcpos(xcol5,yrow)), "PATIENT TYPE:",
     CALL print(calcpos(xcol14,yrow)), data->person_qual[x].to_pat_type, rowplusone,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "{b}ORDERS/DATA MOVED:{endb}",
     rowplusone, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "ANTEPARTUM          :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].antepartum_flag,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "AUDIOLOGY           :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].audiology_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)), "CARDIOLOGY          :",
     CALL print(calcpos(xcol15,yrow)),
     data->person_qual[x].cardio_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "CONSULTS            :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].consults_flag,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "LABORATORY          :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].lab_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)), "NEURODIAGNOSTICS    :",
     CALL print(calcpos(xcol15,yrow)),
     data->person_qual[x].neuro_diag_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "NUTRITION SERVICES  :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].nutri_serv_flag,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "OCCUPATIONAL THERAPY:",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].occ_therapy_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)), "PATIENT CARE        :",
     CALL print(calcpos(xcol15,yrow)),
     data->person_qual[x].patient_care_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "PHARMACY            :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].pharmacy_flag,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "PHYSICAL THERAPY    :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].phys_therapy_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)), "PULMONARY LAB       :",
     CALL print(calcpos(xcol15,yrow)),
     data->person_qual[x].pulm_lab_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "PULMONARY MEDICINE  :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].pulm_med_flag,
     rowplusone,
     CALL print(calcpos(xcol4,yrow)), "RADIOLOGY           :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].rad_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)), "RESPIRATORY THERAPY :",
     CALL print(calcpos(xcol15,yrow)),
     data->person_qual[x].resp_flag, rowplusone,
     CALL print(calcpos(xcol4,yrow)),
     "SPEECH THERAPY      :",
     CALL print(calcpos(xcol15,yrow)), data->person_qual[x].speech_therapy_flag,
     rowplusone, rowplusone,
     CALL print(calcpos(xcol3,yrow)),
     "SENDING PATIENT = EPISODE ORIGINALLY ENTERED ON THE RECORD", rowplusone,
     CALL print(calcpos(xcol3,yrow)),
     "RECEIVING PATIENT = RECORD TO WHICH THE EPISODE WAS MOVED", rowplusone, rowplusone,
     xcol = 200,
     CALL print(calcpos(xcol,yrow)), "MERGE NOTICE = {b}SAME PATIENT{endb}"
   ENDFOR
  FOOT PAGE
   row + 0
  WITH nocounter, maxcol = 800, maxrow = 800,
   dio = postscript
 ;end select
 FREE RECORD data
END GO
