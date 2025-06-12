CREATE PROGRAM bhs_ma_pvpatlist_sn:dba
 IF ( NOT (validate(req2,0)))
  RECORD req2(
    1 fromccl = i4
    1 printcpt4codes = i4
    1 chestpainobs = i4
    1 pagebreak = i4
  )
  SET req2->fromccl = 0
  SET req2->printcpt4codes = 1
  SET req2->chestpainobs = 0
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
     2 mrn = vc
     2 acct = vc
     2 gender = vc
     2 age = vc
     2 dob = vc
     2 dos = i2
     2 admit = vc
     2 disch = vc
     2 admitdoc = vc
     2 pcpdoc = vc
     2 person_id = f8
     2 encntr_id = f8
     2 pt_type = vc
     2 pt_type_str = vc
     2 chief_complaint = vc
     2 diag_type = vc
     2 source_string = vc
     2 diag_dt_tm = vc
     2 sn_qual_cnt = i4
     2 sn_qual[*]
       3 sn_text = vc
       3 sn_prsnl = vc
       3 sn_date = vc
     2 nurse_qual[*]
       3 nurse = vc
     2 casemanager = vc
     2 chestpainobs = i2
 )
 IF (validate(displaynurse)=0)
  SET displaynurse = 0
 ENDIF
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET count = 0
 SET xxx = fillstring(50," ")
 SET uname = fillstring(50," ")
 SET tempfile1a = fillstring(27," ")
 SET g = fillstring(27,"_")
 SET k = fillstring(34,"_")
 SET ops_ind = "N"
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 DECLARE cpt_text = vc WITH public, noconstant(" ")
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE line1 = vc WITH public, constant(fillstring(200,"-"))
 DECLARE nursecnt = i4 WITH noconstant(0)
 DECLARE admitinpatientservice_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITINPATIENTSERVICE")), protect
 DECLARE assignobservationstatus_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ASSIGNOBSERVATIONSTATUS")), protect
 DECLARE selectadmitinpatientservice_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTADMITINPATIENTSERVICE")), protect
 DECLARE selectobservationstatus_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTOBSERVATIONSTATUS")), protect
 DECLARE statuschangepatienttypeto_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSCHANGEPATIENTTYPETO")), protect
 DECLARE statusdaystaypatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSDAYSTAYPATIENT")), protect
 DECLARE statusinpatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"STATUSINPATIENT")),
 protect
 DECLARE statusobservationpatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT")), protect
 DECLARE chestpainobs_str = vc WITH protect, constant("Chest Pain Observation (Cardiology)")
 DECLARE authverified = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE bmdservice = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BMDSERVICE"))
 DECLARE edadmitreqform = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EDADMISSIONREQUESTFORM"))
 DECLARE nursing = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",259571,"NURSING"))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE finnbr_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",319,"FINNBR"))
 DECLARE principle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",17,"PRINCIPLE"))
 DECLARE working_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",17,"WORKING"))
 DECLARE bhstraumamd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSTRAUMAMD"))
 DECLARE bhstraumamd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222   3=99223   4=99231   5=99232   ",
   "6=99233   99234   99235   99236  D=99238   D1=99239   C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsthoracicmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSTHORACICMD")
  )
 DECLARE bhsthoracicmd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234    99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsurologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSUROLOGYMD"))
 DECLARE bhsurologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234    99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhspulmonarymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPULMONARYMD"))
 DECLARE bhspulmonarymd_txt = vc WITH public, constant(concat(
   "E1=99291  E2=99292  1=99221  2=99222  3=99223  4=99231  ",
   "5=99232  6=99233  99234  99235  99236  D=99238  D1=99239  C1=99251  C2=99252  ",
   "C3=99253                     R= Resident Assisted Service     ",
   "No Charge     Not Seen     -QI         ","Updated Diagnosis:_______________ "))
 DECLARE bhsneurologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPHYSICIANNEUROLOGY"))
 DECLARE bhsneurologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222   3=99223   4=99231   5=99232   6=99233  99234  99235  99236  ",
   "D=99238   D1=99239   C1=99251   C2=99252   C3=99253   C4=99254   ",
   "C5=99255   C6=99261   C7=99262   C8=99263    R=Resident Assisted ",
   "Service    No Charge       Not Seen      -QI      ","Updated Diagnosis:________________"))
 DECLARE bhsgimd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSGIMD"))
 DECLARE bhsgimd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222   3=99223   4=99231   5=99232   ",
   "6=99233   99234    99235    99236    D=99238   D1=99239   C1=99251   C2=99252   ",
   "C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263       R=Resident Assisted Service    ","No Charge       Not Seen      -QI      ",
   "Updated Diagnosis:________________ "))
 DECLARE bhsendoscopymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSENDOSCOPYMD"))
 DECLARE bhsendoscopymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233  99234  99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhscardiacsurgerymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCARDIACSURGERYMD"))
 DECLARE bhscardiacsurgerymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234    99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsrenalmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSRENALMD"))
 DECLARE bhsrenalmd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234    99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________"))
 DECLARE bhsoncologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSONCOLOGYMD")
  )
 DECLARE bhsoncologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234   99235   99236   D=99238    D1=99239    C1=99251  C2=99252    ",
   "C3=99253    C4=99254    C5=99255   C6=99261    C7=99262    ",
   "C8=99263    R=Resident Assisted Service  No Charge   ",
   "Not Seen      -QI      Update Diagnosis: __________________"))
 DECLARE bhsneonatalmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSNEONATALMD")
  )
 DECLARE bhsneonatalmd_txt = vc WITH public, constant(concat(
   "E4=99288   E5=99295   E6=99296   E14=99294   E8=99298   ",
   "E15=99299   E9=99436   E10=99440   1=99221   2=99222   3=99223   ",
   "4=99231   5=99232   6=99233   99234  99235  99236  D=99238   D1=99239   C1=99251   ",
   "C2=99252   C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263   R=Resident Assisted Service  No Charge  Not Seen   ",
   "-QI            Updated Diagnosis:________________"))
 DECLARE bhsinfectiousdiseasemd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSINFECTIOUSDISEASEMD"))
 DECLARE bhsinfectiousdiseasemd_txt = vc WITH public, constant(concat(
   "4=99231    5=99232    6=99233   99235  99236   D=99238    D1=99239    ",
   "C1=99251    C2=99252    C3=99253    C4=99254    C5=99255    ",
   "C6=99261    C7=99262    C8=99263  R=Resident Assisted Service   ",
   "No Charge  Update Diagnosis:______________________________"))
 DECLARE bhsgeneralsurgerymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSGENERALSURGERYMD"))
 DECLARE bhsgeneralsurgerymd_txt = vc WITH public, constant(concat(
   "99221  99222   99223    99231    99232    99233    99234","   99235 ",
   "99236 99238    99239    99251 99252 99253    99254   99255   ",
   "99261    99263  No Charge    Not Seen    -QI    ","Update Diagnosis:________________"))
 DECLARE bhsgeneralpediatricsmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSGENERALPEDIATRICSMD"))
 DECLARE bhsgeneralpediatricsmd_txt = vc WITH public, constant(concat(
   "217 218  219   220   221   222   231   232   233   234   299   300   ",
   "235   236   238 239  431  433  435 OD   OIL   OIM   OIH   IB   ",
   "IL   IC   SHC  SI   SE   ADL   ADM   ADH   DCS   DCL   IN   NN   ",
   "NAD    IC1  IC2  No Change    Not Seen    -QI    ",
   "Update Diagnosis:____________________________"))
 DECLARE bhscriticalcaremd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCRITICALCAREMD"))
 DECLARE bhscriticalcaremd_txt = vc WITH public, constant(concat(
   "E1=99291   E2=99292  4=99231   5=99232   6=99233  99234  99235  99236 ",
   "D=99238   D1=99239   C1=99251   ",
   "C2=99252   C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263    R=Resident Assisted Service     No Charge       ",
   "Not Seen    -QI          Updated Diagnosis:________________ "))
 DECLARE bhscardiologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCARDIOLOGYMD"))
 DECLARE bhscardiologymd_txt = vc WITH public, constant(concat(
   "E1=99291   E2=99292    1=99221   2=99222   3=99223   4=99231   ",
   "5=99232   6=99233   99234  99235  99236  D=99238   D1=99239   C1=99251   C2=99252   ",
   "C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   C8=99263    ",
   "R=Resident Assisted Service     No Charge       Not Seen    -QI  ",
   "Updated Diagnosis:________________"))
 DECLARE bhspsychiatrymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPSYCHIATRYMD"))
 DECLARE bhspsychiatrymd_txt = vc WITH public, constant(concat(
   "D=99238  D1=99239  C1=99251   C2=99253   C4=99254   6=99233  99234  99235  99236   ",
   "C5=99255   C6=99261   C7=99262   C8=99263   90801   90816   ",
   "90817   90818   90819   90821   90822   90847   90862   90970   90880   ",
   "90889  No Charge    Not Seen    -QI    Update Diagnosis:____________"))
 DECLARE bhsobgynmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSOBGYNMD"))
 DECLARE bhsobgynmd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233  99234  99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263    R=Resident Assisted Service   ",
   "Update Diagnosis_________________________"))
 DECLARE bhsermedicinemd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSERMEDICINEMD"))
 DECLARE bhsermedicinemd_txt = vc WITH public, constant(concat(
   "99281   99282    99283   99284   99285  99234  99235  99236 ",
   "99291   99292   GC=Resident Assisted  ","Update Diagnosis:________________"))
 DECLARE bhsanesthesiologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSANESTHESIOLOGYMD"))
 DECLARE bhsanesthesiologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233  99234  99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________"))
 DECLARE dba_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 DECLARE dba_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233   99234   99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255       ",
   "[ ]  Hospice     GV          GW   No Charge    Not Seen    -QI    ",
   "Update Diagnosis:________________  "))
 DECLARE bhsphysiciangeneralmedicine_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPHYSICIANGENERALMEDICINE"))
 DECLARE bhsphysiciangeneralmedicine_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233   99234   99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255       ",
   "[ ]  Hospice     GV          GW   No Charge    Not Seen    -QI    ",
   "Update Diagnosis:________________  "))
 DECLARE bhsphysicianphysicianpractices = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPHYSICIANPHYSICIANPRACTICES"))
 DECLARE bhsphysicianphysicianpractices_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99234   99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255       ",
   "[ ] Hospice     GV          GW   No Charge    Not Seen    -QI    ",
   "Update Diagnosis:________________ "))
 DECLARE bhsdba_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSDBA"))
 DECLARE bhsdba_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233   99234   99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255       ",
   "[ ]  Hospice     GV          GW   No Charge    Not Seen    -QI    ",
   "Update Diagnosis:________________  "))
 DECLARE bhsap_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSASSOCIATEPROFESSIONAL"))
 DECLARE bhsap_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233  99234  99235   99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE sticky_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",14122,"POWERCHART"))
 DECLARE rounds_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",14122,"ROUNDSNOTE"))
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET list_name = fillstring(40," ")
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="LISTNAME"))
    SET list_name = trim(request->nv[x].pvc_value)
   ENDIF
 ENDFOR
 DECLARE position_disp = c40 WITH public, noconstant(" ")
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND (cv.code_value=reqinfo->position_cd))
  DETAIL
   position_disp = cv.display
  WITH nocounter
 ;end select
 IF ((request->visit_cnt > 0))
  SELECT INTO "nl:"
   e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
   p.birth_dt_tm, ea.alias, pl.name_full_formatted,
   e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
   epr.seq, nullind_e_disch_dt_tm = nullind(e.disch_dt_tm), nullind_e_reg_dt_tm = nullind(e.reg_dt_tm
    )
   FROM (dummyt d  WITH seq = value(request->visit_cnt)),
    encounter e,
    person p,
    (dummyt d1  WITH seq = 1),
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl pl
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ((ea.encntr_alias_type_cd=mrn_alias_cd) OR (ea.encntr_alias_type_cd=finnbr_cd))
     AND ea.active_ind=1)
    JOIN (d2)
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.encntr_prsnl_r_cd=attend_doc_cd
     AND epr.active_ind=1
     AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null))
     AND epr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pl
    WHERE pl.person_id=epr.prsnl_person_id)
   ORDER BY uar_get_code_display(e.loc_nurse_unit_cd), uar_get_code_display(e.loc_room_cd),
    uar_get_code_display(e.loc_bed_cd)
   HEAD REPORT
    count = 0, gender = " ", dos = 0
   HEAD e.encntr_id
    count += 1, stat = alterlist(temp->qual,count), temp->qual[count].name = substring(1,30,p
     .name_full_formatted),
    temp->qual[count].person_id = p.person_id, temp->qual[count].encntr_id = e.encntr_id, temp->qual[
    count].pt_type = uar_get_code_display(e.encntr_type_cd),
    temp->qual[count].chief_complaint = e.reason_for_visit, temp->qual[count].age = cnvtage(cnvtdate(
      p.birth_dt_tm),curdate), temp->qual[count].dob = format(p.birth_dt_tm,"@SHORTDATE;;q"),
    temp->qual[count].mrn = cnvtalias(ea.alias,ea.alias_pool_cd), gender = cnvtupper(substring(1,1,
      uar_get_code_display(p.sex_cd))), temp->qual[count].gender = gender,
    temp->qual[count].admitdoc = substring(1,30,pl.name_full_formatted), temp->qual[count].unit =
    substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), temp->qual[count].room = substring(1,
     10,uar_get_code_display(e.loc_room_cd)),
    temp->qual[count].bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), temp->qual[count].
    admit = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;q")
    IF (nullind_e_disch_dt_tm=0
     AND e.disch_dt_tm <= cnvtdatetime(curdate,curtime))
     temp->qual[count].disch = format(e.reg_dt_tm,"@SHORTDATE;;q")
    ENDIF
    IF (nullind_e_reg_dt_tm=0)
     dos = datetimediff(cnvtdatetime(curdate,curtime),e.reg_dt_tm), temp->qual[count].dos = (dos+ 1)
    ENDIF
   DETAIL
    IF (ea.encntr_alias_type_cd=mrn_alias_cd)
     temp->qual[count].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     temp->qual[count].acct = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = pa,
    outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=temp->qual[d.seq].encntr_id)
     AND o.catalog_cd IN (admitinpatientservice_var, assignobservationstatus_var,
    selectadmitinpatientservice_var, selectobservationstatus_var, statuschangepatienttypeto_var,
    statusdaystaypatient_var, statusinpatient_var, statusobservationpatient_var))
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    temp->qual[d.seq].pt_type_str = concat(trim(temp->qual[d.seq].pt_type)," ",format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q"))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    clinical_event ce1,
    clinical_event ce2,
    clinical_event ce3
   PLAN (d)
    JOIN (ce1
    WHERE (ce1.person_id=temp->qual[d.seq].person_id)
     AND ce1.event_cd=bmdservice
     AND ce1.result_val=chestpainobs_str
     AND ce1.result_status_cd=authverified)
    JOIN (ce2
    WHERE ce2.event_id=ce1.parent_event_id)
    JOIN (ce3
    WHERE ce3.event_id=ce2.parent_event_id
     AND ce3.event_cd=edadmitreqform)
   DETAIL
    temp->qual[d.seq].chestpainobs = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    prsnl pl2,
    person_prsnl_reltn ppr
   PLAN (d)
    JOIN (ppr
    WHERE (temp->qual[d.seq].person_id=ppr.person_id)
     AND ppr.person_prsnl_r_cd=pcp_cd
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pl2
    WHERE ppr.prsnl_person_id=pl2.person_id)
   DETAIL
    temp->qual[d.seq].pcpdoc = substring(1,30,pl2.name_full_formatted)
   WITH nocounter
  ;end select
  DECLARE primary_rank_cd = f8
  SET primary_rank_cd = uar_get_code_by("DISPLAY",12034,"Primary")
  SELECT DISTINCT INTO "nl:"
   source_string =
   IF (n.source_string > " ") n.source_string
   ELSE d.diag_ftdesc
   ENDIF
   , sort_order =
   IF (d.ranking_cd=primary_rank_cd) 1
   ELSEIF (d.diag_type_cd=principle_cd) 2
   ELSE 3
   ENDIF
   FROM (dummyt dd  WITH seq = value(size(temp->qual,5))),
    diagnosis d,
    nomenclature n
   PLAN (dd)
    JOIN (d
    WHERE (d.encntr_id=temp->qual[dd.seq].encntr_id)
     AND ((d.active_ind+ 0)=1)
     AND cnvtdatetime(sysdate) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm)
    JOIN (n
    WHERE (n.nomenclature_id= Outerjoin(d.nomenclature_id))
     AND (n.active_ind= Outerjoin(1)) )
   ORDER BY d.encntr_id, sort_order DESC, d.diag_dt_tm DESC
   HEAD d.encntr_id
    col + 0
   HEAD sort_order
    col + 0
   DETAIL
    IF (d.ranking_cd=primary_rank_cd)
     temp->qual[dd.seq].diag_type = concat(trim(uar_get_code_display(primary_rank_cd))," Diagnosis: "
      )
    ELSE
     temp->qual[dd.seq].diag_type = concat(trim(uar_get_code_display(d.diag_type_cd))," Diagnosis: ")
    ENDIF
    temp->qual[dd.seq].source_string = source_string, temp->qual[dd.seq].diag_dt_tm = format(d
     .diag_dt_tm,"@SHORTDATETIME;;Q")
   FOOT  sort_order
    col + 0
   FOOT  d.encntr_id
    col + 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.person_id, sn.sticky_note_type_cd, sn.parent_entity_id,
   moddate = format(sn.updt_dt_tm,"MM/DD/YYYY;;D")
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    sticky_note sn,
    prsnl pr
   PLAN (d)
    JOIN (sn
    WHERE (temp->qual[d.seq].person_id=sn.parent_entity_id)
     AND ((sn.sticky_note_type_cd=sticky_cd) OR (sn.sticky_note_type_cd=rounds_cd
     AND sn.public_ind=1)) )
    JOIN (pr
    WHERE sn.updt_id=pr.person_id)
   ORDER BY d.seq, sn.sticky_note_id
   DETAIL
    sn_cnt = (temp->qual[d.seq].sn_qual_cnt+ 1), stat = alterlist(temp->qual[d.seq].sn_qual,sn_cnt),
    temp->qual[d.seq].sn_qual[sn_cnt].sn_text = sn.sticky_note_text,
    temp->qual[d.seq].sn_qual[sn_cnt].sn_prsnl = substring(1,25,pr.name_full_formatted), temp->qual[d
    .seq].sn_qual[sn_cnt].sn_date = moddate, temp->qual[d.seq].sn_qual_cnt = sn_cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   DETAIL
    uname = p.name_full_formatted
   WITH nocounter
  ;end select
  SET new_timedisp = cnvtstring(curtime3)
  IF ((req2->fromccl=1))
   SET tempfile1a = request->output_device
  ELSE
   SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  ENDIF
  IF (displaynurse=1)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     prsnl pr,
     (dummyt d  WITH seq = size(temp->qual,5))
    PLAN (d)
     JOIN (ce
     WHERE (ce.encntr_id=temp->qual[d.seq].encntr_id)
      AND ce.event_title_text="Case Management *"
      AND ce.view_level=1)
     JOIN (pr
     WHERE pr.person_id=ce.updt_id)
    ORDER BY ce.encntr_id, ce.event_start_dt_tm DESC
    HEAD ce.encntr_id
     temp->qual[d.seq].casemanager = concat(trim(pr.name_first,3)," ",trim(pr.name_last,3))
    WITH nocounter
   ;end select
   IF (ml_debug_flag > 5)
    CALL echo("Locate assigned nurse(s)")
   ENDIF
   SELECT INTO "NL:"
    FROM encntr_domain e,
     dcp_shift_assignment sa,
     dcp_care_team ct,
     dcp_care_team_prsnl ctp,
     prsnl p,
     (dummyt d  WITH seq = size(temp->qual,5))
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=temp->qual[d.seq].encntr_id))
     JOIN (sa
     WHERE ((sa.loc_bed_cd=e.loc_bed_cd
      AND sa.loc_bed_cd > 0) OR (sa.loc_bed_cd=0
      AND sa.loc_room_cd=e.loc_room_cd
      AND sa.active_ind=1
      AND sa.loc_room_cd > 0))
      AND sa.active_ind=1
      AND sa.purge_ind=0
      AND cnvtdatetime(sysdate) BETWEEN sa.beg_effective_dt_tm AND sa.end_effective_dt_tm
      AND sa.assign_type_cd=nursing)
     JOIN (ct
     WHERE (ct.careteam_id> Outerjoin(0))
      AND (ct.careteam_id= Outerjoin(sa.careteam_id))
      AND (ct.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(curdate,curtime)))
      AND (ct.end_effective_dt_tm>= Outerjoin(cnvtdatetime(curdate,curtime))) )
     JOIN (ctp
     WHERE (ctp.careteam_id> Outerjoin(0))
      AND (ctp.careteam_id= Outerjoin(ct.careteam_id))
      AND (ctp.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(curdate,curtime)))
      AND (ctp.end_effective_dt_tm>= Outerjoin(cnvtdatetime(curdate,curtime))) )
     JOIN (p
     WHERE ((p.person_id=sa.prsnl_id
      AND sa.prsnl_id > 0) OR (p.person_id=ctp.prsnl_id
      AND ctp.prsnl_id > 0))
      AND p.person_id > 0)
    ORDER BY e.encntr_id, p.name_full_formatted
    HEAD e.encntr_id
     nursecnt = 0
    HEAD p.name_full_formatted
     nursecnt += 1, stat = alterlist(temp->qual[d.seq].nurse_qual,nursecnt), temp->qual[d.seq].
     nurse_qual[nursecnt].nurse = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
     IF (cnvtupper(uar_get_code_display(p.position_cd))="BHS RN")
      temp->qual[d.seq].nurse_qual[nursecnt].nurse = concat(temp->qual[d.seq].nurse_qual[nursecnt].
       nurse," RN")
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SELECT
   IF ((req2->fromccl=1))INTO value(request->output_device)
   ELSEIF ((req2->fromccl=0))INTO value(tempfile1a)
   ELSE
   ENDIF
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1, "{font/8}", row + 1,
    x = 0,
    MACRO (line_wrap)
     limit = 0, maxlen = 140, cr = char(10)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit += 1, pos = 0
       WHILE (pos=0)
        ii += 1,
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(70,ycol)), printstring,
       ycol += 12, row + 1, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    IF (list_name > " ")
     "{pos/40/40}{cpi/14}List Name: ", list_name, row + 1,
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ELSE
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ENDIF
    ycol = 72, "{pos/30/55}{f/8}{cpi/14}Location", "{pos/102/55}MR",
    "{pos/147/55}Name  ", "{pos/280/55}Acct#", "{pos/330/55}DOB",
    "{pos/370/55}Day", "{pos/410/55}Admit", "{pos/470/55}Disch",
    "{pos/510/55}Attending MD{f/8}{cpi/16}", row + 1
   DETAIL
    row + 0, xcol = 40
    IF (((ycol+ 60) > 680)
     AND x < count)
     start_cnt = (x+ 1), BREAK
    ENDIF
    FOR (x = start_cnt TO count)
      IF ((temp->qual[x].unit > " "))
       a = findstring("Med/Tele",temp->qual[x].unit)
       IF (a > 1)
        stat = movestring("        ",1,temp->qual[x].unit,a,8)
       ENDIF
       xxx = concat(trim(temp->qual[x].unit)," ",trim(temp->qual[x].room),"-",trim(temp->qual[x].bed)
        )
      ELSE
       xxx = fillstring(50," ")
      ENDIF
      CALL print(calcpos(40,ycol)), line1, row + 1,
      ycol += 6,
      CALL print(calcpos(30,ycol)), "{b}",
      xxx,
      CALL print(calcpos(102,ycol)), "{b}",
      temp->qual[x].mrn,
      CALL print(calcpos(147,ycol)), "{b}",
      temp->qual[x].name, "{endb}",
      CALL print(calcpos(280,ycol)),
      temp->qual[x].acct,
      CALL print(calcpos(330,ycol)), temp->qual[x].dob
      IF ((temp->qual[x].dos > 0))
       CALL print(calcpos(370,ycol)), temp->qual[x].dos";L"
      ENDIF
      CALL print(calcpos(410,ycol)), temp->qual[x].admit,
      CALL print(calcpos(470,ycol)),
      temp->qual[x].disch,
      CALL print(calcpos(510,ycol)), temp->qual[x].admitdoc
      IF ((temp->qual[x].chestpainobs=1))
       ycol += 12, row + 1,
       CALL print(calcpos(70,ycol)),
       chestpainobs_str
      ENDIF
      ycol += 12, row + 1,
      CALL print(calcpos(30,ycol)),
      temp->qual[x].pt_type_str,
      CALL print(calcpos(132,ycol)), "Chief Complaint: ",
      temp->qual[x].chief_complaint,
      CALL print(calcpos(465,ycol)), "PCP: ",
      temp->qual[x].pcpdoc
      IF (size(temp->qual[x].nurse_qual,5) > 0)
       ycol += 12, row + 1,
       CALL print(calcpos(452,ycol)),
       "Nurse(s): "
       FOR (nursecnt = 1 TO size(temp->qual[x].nurse_qual,5))
         IF (nursecnt > 1)
          ycol += 12, row + 1
         ENDIF
         CALL print(calcpos(485,ycol)), temp->qual[x].nurse_qual[nursecnt].nurse
       ENDFOR
      ENDIF
      IF (textlen(trim(temp->qual[x].casemanager,3)) > 0)
       ycol += 12, row + 1,
       CALL print(calcpos(432,ycol)),
       "Case manager: ", temp->qual[x].casemanager
      ENDIF
      ycol += 12, row + 1
      IF ((temp->qual[x].source_string > " "))
       CALL print(calcpos(118,ycol)), temp->qual[x].diag_type, " ",
       temp->qual[x].source_string, ycol += 12, row + 1
      ENDIF
      IF ((req2->printcpt4codes=1))
       CASE (reqinfo->position_cd)
        OF bhsurologymd_cd:
         cpt_text = bhsurologymd_txt
        OF bhspulmonarymd_cd:
         cpt_text = bhspulmonarymd_txt
        OF bhsdba_cd:
         cpt_text = bhsdba_txt
        OF bhsphysiciangeneralmedicine_cd:
         cpt_text = bhsphysiciangeneralmedicine_txt
        OF bhsphysicianphysicianpractices:
         cpt_text = bhsphysicianphysicianpractices_txt
        OF dba_cd:
         cpt_text = dba_txt
        OF bhsanesthesiologymd_cd:
         cpt_text = bhsanesthesiologymd_txt
        OF bhsermedicinemd_cd:
         cpt_text = bhsermedicinemd_txt
        OF bhsobgynmd_cd:
         cpt_text = bhsobgynmd_txt
        OF bhspsychiatrymd_cd:
         cpt_text = bhspsychiatrymd_txt
        OF bhscardiologymd_cd:
         cpt_text = bhscardiologymd_txt
        OF bhscriticalcaremd_cd:
         cpt_text = bhscriticalcaremd_txt
        OF bhsgeneralpediatricsmd_cd:
         cpt_text = bhsgeneralpediatricsmd_txt
        OF bhsgeneralsurgerymd_cd:
         cpt_text = bhsgeneralsurgerymd_txt
        OF bhsinfectiousdiseasemd_cd:
         cpt_text = bhsinfectiousdiseasemd_txt
        OF bhsneonatalmd_cd:
         cpt_text = bhsneonatalmd_txt
        OF bhsoncologymd_cd:
         cpt_text = bhsoncologymd_txt
        OF bhsrenalmd_cd:
         cpt_text = bhsrenalmd_txt
        OF bhscardiacsurgerymd_cd:
         cpt_text = bhscardiacsurgerymd_txt
        OF bhsendoscopymd_cd:
         cpt_text = bhsendoscopymd_txt
        OF bhsgimd_cd:
         cpt_text = bhsgimd_txt
        OF bhsneurologymd_cd:
         cpt_text = bhsneurologymd_txt
        OF bhspulmonarymd_cd:
         cpt_text = bhspulmonarymd_txt
        OF bhsurologymd_cd:
         cpt_text = bhsurologymd_txt
        OF bhsthoracicmd_cd:
         cpt_text = bhsthoracicmd_txt
        OF bhstraumamd_cd:
         cpt_text = bhstraumamd_txt
        OF bhsap_cd:
         cpt_text = bhsap_txt
        ELSE
         cpt_text = " "
       ENDCASE
       IF ((reqinfo->position_cd=bhsgeneralpediatricsmd_cd))
        "{f/0}{cpi/16}", row + 1,
        CALL print(calcpos(70,ycol)),
        "217 218  219  220  221  222  223  231  232  233  234  235  ",
        "236  238 239  431  433  435  ", ycol += 12,
        row + 1,
        CALL print(calcpos(70,ycol)), "OD   OIL  OIM  OIH   IB   IL   IC  SHC   SI   SE  ADL  ",
        "ADM  ADH  DCS  DCL   IN   NN  NAD  ", ycol += 10, "{f/8}{cpi/16}",
        row + 1,
        CALL print(calcpos(70,ycol)), "No Change    Not Seen    -QI    Update Diagnosis:",
        "____________________________", ycol += 12, row + 1
       ELSE
        tempstring = cpt_text, line_wrap
       ENDIF
      ENDIF
      FOR (s = 1 TO temp->qual[x].sn_qual_cnt)
        temp_note = fillstring(500," "), dline = fillstring(90," ")
        IF (((s+ 1) <= temp->qual[x].sn_qual_cnt))
         IF ((temp->qual[x].sn_qual[s].sn_text != temp->qual[x].sn_qual[(s+ 1)].sn_text))
          temp_note = temp->qual[x].sn_qual[s].sn_text, sn_text = replace(temp_note,char(10)," ",0),
          sn_text1 = replace(sn_text,char(13)," ",0),
          temp_note = sn_text1
         ENDIF
        ELSE
         temp_note = temp->qual[x].sn_qual[s].sn_text, sn_text = replace(temp_note,char(10)," ",0),
         sn_text1 = replace(sn_text,char(13)," ",0),
         temp_note = sn_text1
        ENDIF
        line_length = size(temp_note,1), y = 0, a = 90,
        m = 1, blank_txt = fillstring(90," ")
        WHILE (y <= line_length)
          dline = substring(m,a,temp_note)
          WHILE (substring(a,1,dline) > " ")
           a -= 1,dline = substring(m,a,temp_note)
          ENDWHILE
          IF (dline != blank_txt)
           IF (ycol > 680
            AND x < count)
            start_cnt = (x+ 1), BREAK
           ENDIF
           IF (m=1)
            CALL print(calcpos(30,ycol)), "(", temp->qual[x].sn_qual[s].sn_prsnl,
            ")", row + 1
           ENDIF
           IF (m=1)
            CALL print(calcpos(150,ycol)), " ", temp->qual[x].sn_qual[s].sn_date,
            " ", row + 1
           ENDIF
           y += a,
           CALL print(calcpos(200,ycol)), dline,
           row + 1, m += a, ycol += 11
          ELSE
           y = (line_length+ 5)
          ENDIF
          a = 90
        ENDWHILE
      ENDFOR
      ycol += 18, row + 1
      IF (ycol > 680
       AND x < count)
       start_cnt = (x+ 1), BREAK
      ENDIF
    ENDFOR
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}Page", curpage, row + 1,
    xcol = 310,
    CALL print(calcpos(xcol,ycol)), curdate,
    curtime, row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ELSEIF ((request->person_cnt > 0))
  SELECT INTO "nl:"
   p.name_full_formatted, p.birth_dt_tm, pa.alias,
   pl.name_full_formatted
   FROM (dummyt d  WITH seq = value(request->person_cnt)),
    person p,
    (dummyt d1  WITH seq = 1),
    person_alias pa
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->person[d.seq].person_id))
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=mrn_alias_cd
     AND pa.active_ind=1)
   HEAD REPORT
    count = 0, gender = " "
   HEAD p.person_id
    count += 1, stat = alterlist(temp->qual,count), temp->qual[count].name = substring(1,30,p
     .name_full_formatted),
    temp->qual[count].person_id = p.person_id, temp->qual[count].age = cnvtage(cnvtdate(p.birth_dt_tm
      ),curdate), temp->qual[count].dob = format(p.birth_dt_tm,"@SHORTDATE;;q"),
    temp->qual[count].mrn = cnvtalias(pa.alias,pa.alias_pool_cd), gender = cnvtupper(substring(1,1,
      uar_get_code_display(p.sex_cd))), temp->qual[count].gender = gender
   WITH nocounter, outerjoin = d1, dontcare = pa
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
    prsnl pl2,
    person_prsnl_reltn ppr
   PLAN (d)
    JOIN (ppr
    WHERE (temp->qual[d.seq].person_id=ppr.person_id)
     AND ppr.person_prsnl_r_cd=pcp_cd
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (pl2
    WHERE ppr.prsnl_person_id=pl2.person_id)
   DETAIL
    temp->qual[d.seq].pcpdoc = substring(1,30,pl2.name_full_formatted)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   DETAIL
    uname = p.name_full_formatted
   WITH nocounter
  ;end select
  SET new_timedisp = cnvtstring(curtime3)
  IF ((req2->fromccl=1))
   SET tempfile1a = request->output_device
  ELSE
   SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  ENDIF
  SELECT
   IF ((req2->fromccl=1))INTO value(request->output_device)
   ELSEIF ((req2->fromccl=0))INTO value(tempfile1a)
   ELSE
   ENDIF
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1, "{font/8}", row + 1,
    x = 0,
    MACRO (line_wrap)
     limit = 0, maxlen = 140, cr = char(10)
     WHILE (tempstring > " "
      AND limit < 1000)
       ii = 0, limit += 1, pos = 0
       WHILE (pos=0)
        ii += 1,
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(70,ycol)), printstring,
       ycol += 12, row + 1, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    IF (list_name > " ")
     "{pos/40/40}{cpi/14}List Name: ", list_name, row + 1,
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ELSE
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ENDIF
    ycol = 72, "{pos/100/60}{f/8}{cpi/14}MR", "{pos/180/60}Name  ",
    "{pos/280/60}Sex/Age", "{pos/330/60}DOB{f/8}{cpi/16}", row + 1
   DETAIL
    row + 0, xcol = 40
    IF (((ycol+ 60) > 680)
     AND x < count)
     start_cnt = (x+ 1), BREAK
    ENDIF
    FOR (x = start_cnt TO count)
      CALL print(calcpos(40,ycol)), line1, row + 1,
      ycol += 6,
      CALL print(calcpos(100,ycol)), "{b}",
      temp->qual[x].mrn,
      CALL print(calcpos(180,ycol)), "{b}",
      temp->qual[x].name, "{endb}",
      CALL print(calcpos(280,ycol)),
      temp->qual[x].gender,
      CALL print(calcpos(285,ycol)), temp->qual[x].age,
      CALL print(calcpos(330,ycol)), temp->qual[x].dob, ycol += 12,
      row + 1,
      CALL print(calcpos(180,ycol)), "PCP: ",
      temp->qual[x].pcpdoc, ycol += 12, row + 1
      IF ((req2->printcpt4codes=1))
       CASE (reqinfo->position_cd)
        OF bhsurologymd_cd:
         cpt_text = bhsurologymd_txt
        OF bhspulmonarymd_cd:
         cpt_text = bhspulmonarymd_txt
        OF bhsdba_cd:
         cpt_text = bhsdba_txt
        OF bhsphysiciangeneralmedicine_cd:
         cpt_text = bhsphysiciangeneralmedicine_txt
        OF dba_cd:
         cpt_text = dba_txt
        OF bhsanesthesiologymd_cd:
         cpt_text = bhsanesthesiologymd_txt
        OF bhsermedicinemd_cd:
         cpt_text = bhsermedicinemd_txt
        OF bhsobgynmd_cd:
         cpt_text = bhsobgynmd_txt
        OF bhspsychiatrymd_cd:
         cpt_text = bhspsychiatrymd_txt
        OF bhscardiologymd_cd:
         cpt_text = bhscardiologymd_txt
        OF bhscriticalcaremd_cd:
         cpt_text = bhscriticalcaremd_txt
        OF bhsgeneralpediatricsmd_cd:
         cpt_text = bhsgeneralpediatricsmd_txt
        OF bhsgeneralsurgerymd_cd:
         cpt_text = bhsgeneralsurgerymd_txt
        OF bhsinfectiousdiseasemd_cd:
         cpt_text = bhsinfectiousdiseasemd_txt
        OF bhsneonatalmd_cd:
         cpt_text = bhsneonatalmd_txt
        OF bhsoncologymd_cd:
         cpt_text = bhsoncologymd_txt
        OF bhsrenalmd_cd:
         cpt_text = bhsrenalmd_txt
        OF bhscardiacsurgerymd_cd:
         cpt_text = bhscardiacsurgerymd_txt
        OF bhsendoscopymd_cd:
         cpt_text = bhsendoscopymd_txt
        OF bhsgimd_cd:
         cpt_text = bhsgimd_txt
        OF bhsneurologymd_cd:
         cpt_text = bhsneurologymd_txt
        OF bhspulmonarymd_cd:
         cpt_text = bhspulmonarymd_txt
        OF bhsurologymd_cd:
         cpt_text = bhsurologymd_txt
        OF bhsthoracicmd_cd:
         cpt_text = bhsthoracicmd_txt
        OF bhstraumamd_cd:
         cpt_text = bhstraumamd_txt
        OF bhsap_cd:
         cpt_text = bhsap_txt
        ELSE
         cpt_text = " "
       ENDCASE
       IF ((reqinfo->position_cd=bhsgeneralpediatricsmd_cd))
        "{f/0}{cpi/16}", row + 1,
        CALL print(calcpos(70,ycol)),
        "217 218  219  220  221  222  223  231  232  233  234  235  ",
        "236  238 239  431  433  435   ", ycol += 10,
        row + 1,
        CALL print(calcpos(70,ycol)), "OD   OIL  OIM  OIH   IB   IL   IC  SHC   SI   SE  ADL  ",
        "ADM  ADH  DCS  DCL   IN   NN  NAD  ", ycol += 12, "{f/8}{cpi/16}",
        row + 1,
        CALL print(calcpos(70,ycol)), "No Change    Not Seen    -QI    Update Diagnosis:",
        "____________________________", ycol += 12, row + 1
       ELSE
        tempstring = cpt_text, line_wrap
       ENDIF
      ENDIF
      ycol += 18, row + 1
      IF (ycol > 680
       AND x < count)
       start_cnt = (x+ 1), BREAK
      ENDIF
    ENDFOR
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}Page", curpage, row + 1,
    xcol = 310,
    CALL print(calcpos(xcol,ycol)), curdate,
    curtime, row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ELSE
  CALL echo("We're hitting the 3rd else encntr_cnt !> 0, person_cnt !>0")
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  CALL echo(build("tempfile1a = ",tempfile1a))
  SELECT
   IF ((req2->fromccl=1))INTO value(request->output_device)
   ELSEIF ((req2->fromccl=0))INTO value(tempfile1a)
   ELSE
   ENDIF
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1
   HEAD PAGE
    "{pos/240/80}{f/13}{cpi/10}Printed Patient List", row + 1
    IF (list_name > " ")
     "{pos/260/92}{cpi/14}List Name: ", list_name, row + 1,
     "{pos/260/104}{cpi/14}For: ", uname, row + 1
    ELSE
     "{pos/260/92}{cpi/14}For: ", uname, row + 1
    ENDIF
    ycol = 72, "{pos/30/60}{f/13}{cpi/14}Location", "{pos/115/60}MR",
    "{pos/180/60}Name  ", "{pos/280/60}Sex/Age", "{pos/330/60}DOB",
    "{pos/370/60}Day", "{pos/410/60}Admit", "{pos/450/60}Disch",
    "{pos/490/60}Attending MD{f/12}{cpi/16}", row + 1, xcol = 180,
    ycol = 350,
    CALL print("*** No patients for this provider *** "), row + 1
   DETAIL
    xcol = 180
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}Page", curpage, row + 1,
    xcol = 310,
    CALL print(calcpos(xcol,ycol)), curdate,
    curtime, row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ENDIF
 IF ((req2->fromccl=1))
  SET stat = 0
 ELSE
  SET spool value(trim(tempfile1a)) value(request->output_device) WITH deleted
 ENDIF
 SET reply->text = tempfile1a
 FREE RECORD pt
 IF (ml_debug_flag > 10)
  CALL echorecord(temp)
 ENDIF
 FREE RECORD temp
END GO
