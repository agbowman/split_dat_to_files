CREATE PROGRAM bhs_ma_merge_list_rpt:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Start Date for Merge List Report " = "CURDATE",
  "End Date for Merge List Report " = "CURDATE"
  WITH outdev, start_date, end_date
 RECORD data(
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 to_person_id = f8
     2 person_combine_id = f8
     2 to_person_name_full = c30
     2 to_person_addr_ln_1 = c15
     2 to_person_addr_ln_2 = c15
     2 to_bhs_mrn = c10
     2 to_bmc_mrn = c10
     2 to_fmc_mrn = c10
     2 to_mlh_mrn = c10
     2 to_bwh_mrn = c10
     2 to_bnh_mrn = c10
     2 to_fin_nbr = c10
     2 to_ssn = c9
     2 to_gender = c1
     2 to_dob = c10
     2 to_attend_doc = c30
     2 to_admit_dx = c20
     2 to_pat_loc = c15
     2 to_pat_type = c15
     2 from_person_id = f8
     2 from_person_name_full = c30
     2 from_person_addr_ln_1 = c15
     2 from_person_addr_ln_2 = c15
     2 from_bhs_mrn = c10
     2 from_bmc_mrn = c10
     2 from_fmc_mrn = c10
     2 from_mlh_mrn = c10
     2 from_bwh_mrn = c10
     2 from_bhn_mrn = c10
     2 from_fin_nbr = c10
     2 from_ssn = c9
     2 from_gender = c1
     2 from_dob = c10
     2 from_attend_doc = c30
     2 from_admit_dx = c20
     2 encntr_id = f8
 )
 DECLARE equal_line = c12 WITH public, constant(fillstring(12,"="))
 SET start_date =  $START_DATE
 SET end_date =  $END_DATE
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE fin_nbr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE bhs_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN"))
 DECLARE bmc_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN"))
 DECLARE fmc_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"FMCMRN"))
 DECLARE mlh_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN"))
 DECLARE bwh_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BWHMRN"))
 DECLARE bnh_mrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BNHMRN"))
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
   WHERE pc.updt_dt_tm >= cnvtdatetime(cnvtdate(start_date),0)
    AND pc.updt_dt_tm <= cnvtdatetime(cnvtdate(end_date),235959)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.to_person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(pc.to_person_id))
    AND (pa.person_alias_type_cd= Outerjoin(ssn_cd)) )
   JOIN (ad
   WHERE (ad.parent_entity_id= Outerjoin(pc.to_person_id))
    AND (ad.parent_entity_name= Outerjoin("PERSON"))
    AND (ad.address_type_cd= Outerjoin(home_addr_type_cd)) )
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(pc.encntr_id))
    AND (e.person_id= Outerjoin(pc.to_person_id))
    AND (e.active_ind= Outerjoin(1)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(fin_nbr_cd))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(attend_doc_cd))
    AND (epr.active_ind= Outerjoin(1)) )
   JOIN (pl
   WHERE (pl.person_id= Outerjoin(epr.prsnl_person_id)) )
   JOIN (dg
   WHERE (dg.encntr_id= Outerjoin(e.encntr_id))
    AND (dg.diag_type_cd= Outerjoin(admit_diag_cd)) )
  ORDER BY pc.person_combine_id
  HEAD REPORT
   pcnt = 0
  HEAD pc.person_combine_id
   pcnt += 1
   IF (mod(pcnt,10)=1
    AND pcnt != 1)
    stat = alterlist(data->person_qual,(pcnt+ 9))
   ENDIF
   stat = alterlist(data->person_qual,pcnt), data->person_qual[pcnt].person_combine_id = pc
   .person_combine_id, data->person_qual[pcnt].to_person_id = pc.to_person_id,
   data->person_qual[pcnt].from_person_id = pc.from_person_id, data->person_qual[pcnt].encntr_id = pc
   .encntr_id, data->person_qual[pcnt].to_person_name_full = substring(1,30,p.name_full_formatted),
   data->person_qual[pcnt].to_person_addr_ln_1 = substring(1,15,ad.street_addr), data->person_qual[
   pcnt].to_person_addr_ln_2 = concat(trim(ad.city),", ",trim(ad.state)," ",trim(ad.zipcode)), data->
   person_qual[pcnt].to_gender = substring(1,1,uar_get_code_display(p.sex_cd)),
   data->person_qual[pcnt].to_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    "MM/DD/YYYY;;D"), data->person_qual[pcnt].to_ssn = pa.alias, data->person_qual[pcnt].to_admit_dx
    = substring(1,20,dg.diag_ftdesc),
   data->person_qual[pcnt].to_attend_doc = substring(1,30,pl.name_full_formatted), data->person_qual[
   pcnt].to_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd), data->person_qual[pcnt].to_pat_type
    = uar_get_code_display(e.encntr_type_cd),
   data->person_qual[pcnt].to_fin_nbr = ea.alias
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
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(ssn_cd)) )
   JOIN (ad
   WHERE (ad.parent_entity_id= Outerjoin(p.person_id))
    AND (ad.parent_entity_name= Outerjoin("PERSON"))
    AND (ad.address_type_cd= Outerjoin(home_addr_type_cd)) )
  DETAIL
   data->person_qual[dd.seq].from_person_name_full = substring(1,30,p.name_full_formatted), data->
   person_qual[dd.seq].from_person_addr_ln_1 = substring(1,15,ad.street_addr), data->person_qual[dd
   .seq].from_person_addr_ln_2 = concat(trim(ad.city),", ",trim(ad.state)," ",trim(ad.zipcode)),
   data->person_qual[dd.seq].from_gender = substring(1,1,uar_get_code_display(p.sex_cd)), data->
   person_qual[dd.seq].from_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    "MM/DD/YYYY;;D"), data->person_qual[dd.seq].from_ssn = pa.alias
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
    AND pa.alias_pool_cd IN (bhs_mrn_pool_cd, bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd,
   bwh_mrn_pool_cd,
   bnh_mrn_pool_cd))
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
    OF bwh_mrn_pool_cd:
     data->person_qual[dd.seq].to_bwh_mrn = pa.alias
    OF bnh_mrn_pool_cd:
     data->person_qual[dd.seq].to_bnh_mrn = pa.alias
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
    AND pa.alias_pool_cd IN (bhs_mrn_pool_cd, bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd,
   bwh_mrn_pool_cd,
   bnh_mrn_pool_cd))
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
    OF bwh_mrn_pool_cd:
     data->person_qual[dd.seq].from_bwh_mrn = pa.alias
    OF bnh_mrn_pool_cd:
     data->person_qual[dd.seq].from_bnh_mrn = pa.alias
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
    yrow += 10, row + 1
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
     "{b} -PERMANENT CHART COPY-{endb}", rowplusone, rowplusone
     IF ((data->person_qual[x].encntr_id > 0))
      CALL print(calcpos(225,yrow)), "{b}Encounter Move{endb}"
     ELSE
      CALL print(calcpos(225,yrow)), "{b}Person Combine{endb}"
     ENDIF
     rowplusone, rowplusone, rowplusone,
     CALL print(calcpos(xcol2,yrow)), "{b}SENDING PATIENT{endb}",
     CALL print(calcpos(xcol6,yrow)),
     "{b}RECEIVING PATIENT{endb}", rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "NAME:",
     CALL print(calcpos(xcol2,yrow)), data->person_qual[x].from_person_name_full,
     CALL print(calcpos(xcol5,yrow)), "NAME:",
     CALL print(calcpos(xcol6,yrow)),
     data->person_qual[x].to_person_name_full, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "ADDR:",
     CALL print(calcpos(xcol2,yrow)), data->person_qual[x].from_person_addr_ln_1,
     CALL print(calcpos(xcol5,yrow)), "ADDR:",
     CALL print(calcpos(xcol6,yrow)),
     data->person_qual[x].to_person_addr_ln_1, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "BHS MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_bhs_mrn,
     CALL print(calcpos(xcol5,yrow)), "BHS MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_bhs_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "BMC MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_bmc_mrn,
     CALL print(calcpos(xcol5,yrow)), "BMC MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_bmc_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "FMC MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_fmc_mrn,
     CALL print(calcpos(xcol5,yrow)), "FMC MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_fmc_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "MLH MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_mlh_mrn,
     CALL print(calcpos(xcol5,yrow)), "MLH MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_mlh_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "BWH MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_bwh_mrn,
     CALL print(calcpos(xcol5,yrow)), "BWH MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_bwh_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "BNH MR #:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_bnh_mrn,
     CALL print(calcpos(xcol5,yrow)), "BNH MR #:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_bnh_mrn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "ACCOUNT#:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_fin_nbr,
     CALL print(calcpos(xcol5,yrow)), "ACCOUNT#:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_fin_nbr, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "SOC SEC#:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_ssn,
     CALL print(calcpos(xcol5,yrow)), "SOC SEC#:",
     CALL print(calcpos(xcol7,yrow)),
     data->person_qual[x].to_ssn, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "SEX:",
     CALL print(calcpos(xcol8,yrow)), data->person_qual[x].from_gender,
     CALL print(calcpos(xcol9,yrow)), "DATE OF BIRTH:",
     CALL print(calcpos(xcol10,yrow)),
     data->person_qual[x].from_dob,
     CALL print(calcpos(xcol5,yrow)), "SEX:",
     CALL print(calcpos(xcol11,yrow)), data->person_qual[x].to_gender,
     CALL print(calcpos(xcol12,yrow)),
     "DATE OF BIRTH:",
     CALL print(calcpos(xcol13,yrow)), data->person_qual[x].to_dob,
     rowplusone,
     CALL print(calcpos(xcol1,yrow)), "ATT. MD :",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_attend_doc,
     CALL print(calcpos(xcol5,yrow)),
     "ATT. MD :",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_attend_doc,
     rowplusone,
     CALL print(calcpos(xcol1,yrow)), "ADMIT DX:",
     CALL print(calcpos(xcol3,yrow)), data->person_qual[x].from_admit_dx,
     CALL print(calcpos(xcol5,yrow)),
     "ADMIT DX:",
     CALL print(calcpos(xcol7,yrow)), data->person_qual[x].to_admit_dx,
     rowplusone,
     CALL print(calcpos(xcol5,yrow)), "PATIENT LOC :",
     CALL print(calcpos(xcol14,yrow)), data->person_qual[x].to_pat_loc, rowplusone,
     CALL print(calcpos(xcol5,yrow)), "PATIENT TYPE:",
     CALL print(calcpos(xcol14,yrow)),
     data->person_qual[x].to_pat_type, rowplusone, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "Person Combine ID = ",
     CALL print(calcpos(225,yrow)),
     data->person_qual[x].person_combine_id, rowplusone,
     CALL print(calcpos(xcol1,yrow)),
     "Sending Patient Person ID = ",
     CALL print(calcpos(225,yrow)), data->person_qual[x].from_person_id,
     rowplusone,
     CALL print(calcpos(xcol1,yrow)), "Receiving Patient Person ID = ",
     CALL print(calcpos(225,yrow)), data->person_qual[x].to_person_id, rowplusone,
     CALL print(calcpos(xcol1,yrow)), "Encounter ID = ",
     CALL print(calcpos(225,yrow)),
     data->person_qual[x].encntr_id, rowplusone, rowplusone,
     CALL print(calcpos(xcol3,yrow)), "SENDING PATIENT = ENCOUNTER ORIGINALLY ENTERED ON THE RECORD",
     rowplusone,
     CALL print(calcpos(xcol3,yrow)), "RECEIVING PATIENT = RECORD TO WHICH THE ENCOUNTER WAS MOVED",
     rowplusone,
     rowplusone, xcol = 200,
     CALL print(calcpos(xcol,yrow)),
     "MERGE NOTICE = {b}SAME PATIENT{endb}"
   ENDFOR
  FOOT PAGE
   row + 0
  WITH nocounter, maxcol = 800, maxrow = 800,
   dio = postscript
 ;end select
 FREE RECORD data
END GO
