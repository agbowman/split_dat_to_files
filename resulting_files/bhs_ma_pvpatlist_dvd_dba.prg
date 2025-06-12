CREATE PROGRAM bhs_ma_pvpatlist_dvd:dba
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
     2 diag_type = vc
     2 source_string = vc
     2 diag_dt_tm = vc
 )
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
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsurologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSUROLOGYMD"))
 DECLARE bhsurologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhspulmonarymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPULMONARYMD"))
 DECLARE bhspulmonarymd_txt = vc WITH public, constant(concat(
   "E1=99291  E2=99292  1=99221  2=99222  3=99223  4=99231  ",
   "5=99232  6=99233  D=99238  D1=99239  C1=99251  C2=99252  ",
   "C3=99253                     R= Resident Assisted Service     ",
   "No Charge     Not Seen     -QI         ","Updated Diagnosis:_______________ "))
 DECLARE bhsneurologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSNEUROLOGYMD"))
 DECLARE bhsneurologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222   3=99223   4=99231   5=99232   6=99233   ",
   "D=99238   D1=99239   C1=99251   C2=99252   C3=99253   C4=99254   ",
   "C5=99255   C6=99261   C7=99262   C8=99263    R=Resident Assisted ",
   "Service    No Charge       Not Seen      -QI      ","Updated Diagnosis:________________"))
 DECLARE bhsgimd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSGIMD"))
 DECLARE bhsgimd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222   3=99223   4=99231   5=99232   ",
   "6=99233   D=99238   D1=99239   C1=99251   C2=99252   ",
   "C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263       R=Resident Assisted Service    ","No Charge       Not Seen      -QI      ",
   "Updated Diagnosis:________________ "))
 DECLARE bhsendoscopymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSENDOSCOPYMD"))
 DECLARE bhsendoscopymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233  99234  99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhscardiacsurgerymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCARDIACSURGERYMD"))
 DECLARE bhscardiacsurgerymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsrenalmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSRENALMD"))
 DECLARE bhsrenalmd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________"))
 DECLARE bhsoncologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSONCOLOGYMD")
  )
 DECLARE bhsoncologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    D=99238    D1=99239    C1=99251  C2=99252    ",
   "C3=99253    C4=99254    C5=99255   C6=99261    C7=99262    ",
   "C8=99263    R=Resident Assisted Service  No Charge   ",
   "Not Seen      -QI      Update Diagnosis: __________________"))
 DECLARE bhsneonatalmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSNEONATALMD")
  )
 DECLARE bhsneonatalmd_txt = vc WITH public, constant(concat(
   "E4=99288   E5=99295   E6=99296   E14=99294   E8=99298   ",
   "E15=99299   E9=99436   E10=99440   1=99221   2=99222   3=99223   ",
   "4=99231   5=99232   6=99233   D=99238   D1=99239   C1=99251   ",
   "C2=99252   C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263   R=Resident Assisted Service  No Charge  Not Seen   ",
   "-QI            Updated Diagnosis:________________"))
 DECLARE bhsinfectiousdiseasemd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSINFECTIOUSDISEASEMD"))
 DECLARE bhsinfectiousdiseasemd_txt = vc WITH public, constant(concat(
   "4=99231    5=99232    6=99233    D=99238    D1=99239    ",
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
   "217 218  219   220   221   222   231   232   233   234   ",
   "235   236   238 239  431  433  435 OD   OIL   OIM   OIH   IB   ",
   "IL   IC   SHC  SI   SE   ADL   ADM   ADH   DCS   DCL   IN   NN   ",
   "NAD  No Change    Not Seen    -QI    ","Update Diagnosis:____________________________"))
 DECLARE bhscriticalcaremd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCRITICALCAREMD"))
 DECLARE bhscriticalcaremd_txt = vc WITH public, constant(concat(
   "E1=99291   E2=99292  4=99231   5=99232   6=99233   ",
   "4=99231   5=99232   6=99233   D=99238   D1=99239   C1=99251   ",
   "C2=99252   C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   ",
   "C8=99263    R=Resident Assisted Service     No Charge       ",
   "Not Seen    -QI          Updated Diagnosis:________________ "))
 DECLARE bhscardiologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSCARDIOLOGYMD"))
 DECLARE bhscardiologymd_txt = vc WITH public, constant(concat(
   "E1=99291   E2=99292    1=99221   2=99222   3=99223   4=99231   ",
   "5=99232   6=99233   D=99238   D1=99239   C1=99251   C2=99252   ",
   "C3=99253   C4=99254   C5=99255   C6=99261   C7=99262   C8=99263    ",
   "R=Resident Assisted Service     No Charge       Not Seen    -QI  ",
   "Updated Diagnosis:________________"))
 DECLARE bhspsychiatrymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPSYCHIATRYMD"))
 DECLARE bhspsychiatrymd_txt = vc WITH public, constant(concat(
   "D=99238  D1 =99239  C1=99251   C2=99253   C4=99254   6=99233   ",
   "C5=99255   C6=99261   C7=99262   C8=99263   90801   90816   ",
   "90817   90818   90819   90821   90822   90847   90862   90970   90880   ",
   "90889  No Charge    Not Seen    -QI    Update Diagnosis:____________"))
 DECLARE bhsobgynmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSOBGYNMD"))
 DECLARE bhsobgynmd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263    R=Resident Assisted Service   ",
   "Update Diagnosis_________________________"))
 DECLARE bhsermedicinemd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSERMEDICINEMD"))
 DECLARE bhsermedicinemd_txt = vc WITH public, constant(concat(
   "99281  99282  99283  99284  99285  99291  99292   ",
   "GC=Resident Assisted   Update Diagnosis_________________________"))
 DECLARE bhsanesthesiologymd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSANESTHESIOLOGYMD"))
 DECLARE bhsanesthesiologymd_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________"))
 DECLARE dba_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 DECLARE dba_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsphysiciangeneralmedicine_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPHYSICIANGENERALMEDICINE"))
 DECLARE bhsphysiciangeneralmedicine_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
 DECLARE bhsdba_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",88,"BHSDBA"))
 DECLARE bhsdba_txt = vc WITH public, constant(concat(
   "1=99221   2=99222    3=99223   4=99231   5=99232   ",
   "6=99233    99235 99236  D=99238    D1=99239    C1=99251  ",
   "C2=99252    C3=99253    C4=99254    C5=99255   C6=99261    ",
   "C7=99262    C8=99263   No Charge    Not Seen    -QI    ","Update Diagnosis:________________ "))
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
   epr.seq
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
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pl
    WHERE pl.person_id=epr.prsnl_person_id)
   ORDER BY uar_get_code_display(e.loc_nurse_unit_cd), uar_get_code_display(e.loc_room_cd),
    uar_get_code_display(e.loc_bed_cd)
   HEAD REPORT
    count = 0, gender = " ", dos = 0
   HEAD e.encntr_id
    count = (count+ 1), stat = alterlist(temp->qual,count), temp->qual[count].name = substring(1,30,p
     .name_full_formatted),
    temp->qual[count].person_id = p.person_id, temp->qual[count].encntr_id = e.encntr_id, temp->qual[
    count].pt_type = uar_get_code_display(e.encntr_type_cd),
    temp->qual[count].diag_type = "Chief Complaint: ", temp->qual[count].source_string = e
    .reason_for_visit, temp->qual[count].age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
    temp->qual[count].dob = format(p.birth_dt_tm,"@SHORTDATE;;q"), temp->qual[count].mrn = cnvtalias(
     ea.alias,ea.alias_pool_cd), gender = cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))),
    temp->qual[count].gender = gender, temp->qual[count].admitdoc = substring(1,30,pl
     .name_full_formatted), temp->qual[count].unit = substring(1,20,uar_get_code_display(e
      .loc_nurse_unit_cd)),
    temp->qual[count].room = substring(1,10,uar_get_code_display(e.loc_room_cd)), temp->qual[count].
    bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), temp->qual[count].admit = format(e
     .reg_dt_tm,"@SHORTDATE;;q")
    IF (nullind(e.disch_dt_tm)=0
     AND e.disch_dt_tm <= cnvtdatetime(curdate,curtime))
     temp->qual[count].disch = format(e.reg_dt_tm,"@SHORTDATE;;q")
    ENDIF
    IF (nullind(e.reg_dt_tm)=0)
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
    prsnl pl2,
    person_prsnl_reltn ppr
   PLAN (d)
    JOIN (ppr
    WHERE (temp->qual[d.seq].person_id=ppr.person_id)
     AND ppr.person_prsnl_r_cd=pcp_cd
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
     AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pl2
    WHERE ppr.prsnl_person_id=pl2.person_id)
   DETAIL
    temp->qual[d.seq].pcpdoc = substring(1,30,pl2.name_full_formatted)
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   source_string =
   IF (n.source_string > " ") n.source_string
   ELSE d.diag_ftdesc
   ENDIF
   , sort_order = uar_get_code_display(d.diag_type_cd)
   FROM (dummyt dd  WITH seq = value(size(temp->qual,5))),
    diagnosis d,
    nomenclature n
   PLAN (dd)
    JOIN (d
    WHERE (d.encntr_id=temp->qual[dd.seq].encntr_id)
     AND d.diag_type_cd IN (principle_cd, working_cd)
     AND ((d.active_ind+ 0)=1))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(d.nomenclature_id)
     AND n.active_ind=outerjoin(1))
   ORDER BY d.encntr_id, sort_order DESC, cnvtdatetime(d.diag_dt_tm),
    d.nomenclature_id
   HEAD d.encntr_id
    col + 0
   HEAD sort_order
    col + 0
   HEAD d.diag_dt_tm
    col + 0
   HEAD d.nomenclature_id
    col + 0
   DETAIL
    temp->qual[dd.seq].diag_type = concat(trim(uar_get_code_display(d.diag_type_cd))," Diagnosis: "),
    temp->qual[dd.seq].source_string = source_string, temp->qual[dd.seq].diag_dt_tm = format(d
     .diag_dt_tm,"@SHORTDATETIME;;Q")
   FOOT  d.nomenclature_id
    col + 0
   FOOT  d.diag_dt_tm
    col + 0
   FOOT  sort_order
    col + 0
   FOOT  d.encntr_id
    col + 0
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
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  SELECT INTO request->output_device
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
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(70,ycol)), printstring,
       ycol = (ycol+ 12), row + 1, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    IF (list_name > " ")
     "{pos/40/40}{cpi/14}List Name: ", list_name, row + 1,
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ELSE
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ENDIF
    ycol = 72, "{pos/30/60}{f/8}{cpi/14}Location", "{pos/115/60}MR",
    "{pos/180/60}Name  ", "{pos/280/60}Acct#", "{pos/330/60}DOB",
    "{pos/370/60}Day", "{pos/410/60}Admit", "{pos/450/60}Disch",
    "{pos/490/60}Attending MD{f/8}{cpi/16}", row + 1, ycol = (ycol+ 12)
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
      ycol = (ycol+ 6),
      CALL print(calcpos(30,ycol)), "{b}",
      xxx,
      CALL print(calcpos(115,ycol)), "{b}",
      temp->qual[x].mrn,
      CALL print(calcpos(180,ycol)), "{b}",
      temp->qual[x].name, "{endb}",
      CALL print(calcpos(280,ycol)),
      temp->qual[x].acct,
      CALL print(calcpos(330,ycol)), temp->qual[x].dob
      IF ((temp->qual[x].dos > 0))
       CALL print(calcpos(370,ycol)), temp->qual[x].dos";L"
      ENDIF
      CALL print(calcpos(410,ycol)), temp->qual[x].admit,
      CALL print(calcpos(450,ycol)),
      temp->qual[x].disch,
      CALL print(calcpos(490,ycol)), temp->qual[x].admitdoc,
      ycol = (ycol+ 12), row + 1,
      CALL print(calcpos(70,ycol)),
      temp->qual[x].pt_type,
      CALL print(calcpos(150,ycol)), temp->qual[x].diag_type,
      " ", temp->qual[x].source_string,
      CALL print(calcpos(300,ycol)),
      "PCP: ", temp->qual[x].pcpdoc, ycol = (ycol+ 12),
      row + 1
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
       ELSE
        cpt_text = " "
      ENDCASE
      IF ((reqinfo->position_cd=bhsgeneralpediatricsmd_cd))
       "{f/0}{cpi/16}", row + 1,
       CALL print(calcpos(70,ycol)),
       "217 218  219  220  221  222  223  231  232  233  234  235  ", "236  238 239  431  433  435",
       ycol = (ycol+ 12),
       row + 1,
       CALL print(calcpos(70,ycol)), "OD   OIL  OIM  OIH   IB   IL   IC  SHC   SI   SE  ADL  ",
       "ADM  ADH  DCS  DCL   IN   NN  NAD", ycol = (ycol+ 10), "{f/8}{cpi/16}",
       row + 1,
       CALL print(calcpos(70,ycol)), "No Change    Not Seen    -QI    Update Diagnosis:",
       "____________________________", ycol = (ycol+ 12), row + 1
      ELSE
       tempstring = cpt_text, line_wrap
      ENDIF
      ycol = (ycol+ 48), row + 1
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
    count = (count+ 1), stat = alterlist(temp->qual,count), temp->qual[count].name = substring(1,30,p
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
     AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
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
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  SELECT INTO request->output_device
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
       ii = 0, limit = (limit+ 1), pos = 0
       WHILE (pos=0)
        ii = (ii+ 1),
        IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,tempstring),
       CALL print(calcpos(70,ycol)), printstring,
       ycol = (ycol+ 12), row + 1, tempstring = substring((pos+ 1),9999,tempstring)
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    IF (list_name > " ")
     "{pos/40/40}{cpi/14}List Name: ", list_name, row + 1,
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ELSE
     "{pos/500/40}{cpi/14}For: ", uname, row + 1
    ENDIF
    ycol = 120, "{pos/100/60}{f/8}{cpi/14}MR", "{pos/180/60}Name  ",
    "{pos/280/60}Sex/Age", "{pos/330/60}DOB{f/8}{cpi/16}", row + 1,
    ycol = 72
   DETAIL
    row + 0, xcol = 40
    IF (((ycol+ 60) > 680)
     AND x < count)
     start_cnt = (x+ 1), BREAK
    ENDIF
    FOR (x = start_cnt TO count)
      CALL print(calcpos(40,ycol)), line1, row + 1,
      ycol = (ycol+ 6),
      CALL print(calcpos(100,ycol)), "{b}",
      temp->qual[x].mrn,
      CALL print(calcpos(180,ycol)), "{b}",
      temp->qual[x].name, "{endb}",
      CALL print(calcpos(280,ycol)),
      temp->qual[x].gender,
      CALL print(calcpos(285,ycol)), temp->qual[x].age,
      CALL print(calcpos(330,ycol)), temp->qual[x].dob, ycol = (ycol+ 12),
      row + 1,
      CALL print(calcpos(180,ycol)), "PCP: ",
      temp->qual[x].pcpdoc, ycol = (ycol+ 12), row + 1
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
       ELSE
        cpt_text = " "
      ENDCASE
      IF ((reqinfo->position_cd=bhsgeneralpediatricsmd_cd))
       "{f/0}{cpi/16}", row + 1,
       CALL print(calcpos(70,ycol)),
       "217 218  219  220  221  222  223  231  232  233  234  235  ", "236  238 239  431  433  435",
       ycol = (ycol+ 10),
       row + 1,
       CALL print(calcpos(70,ycol)), "OD   OIL  OIM  OIH   IB   IL   IC  SHC   SI   SE  ADL  ",
       "ADM  ADH  DCS  DCL   IN   NN  NAD", ycol = (ycol+ 12), "{f/8}{cpi/16}",
       row + 1,
       CALL print(calcpos(70,ycol)), "No Change    Not Seen    -QI    Update Diagnosis:",
       "____________________________", ycol = (ycol+ 12), row + 1
      ELSE
       tempstring = cpt_text, line_wrap
      ENDIF
      ycol = (ycol+ 48), row + 1
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
  SELECT INTO request->output_device
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
    ycol = 140, "{pos/30/125}{f/13}{cpi/14}Location", "{pos/115/125}MR",
    "{pos/180/125}Name  ", "{pos/280/125}Sex/Age", "{pos/330/125}DOB",
    "{pos/370/125}Day", "{pos/410/125}Admit", "{pos/450/125}Disch",
    "{pos/490/125}Attending MD{f/12}{cpi/16}", row + 1, xcol = 180,
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
 FREE RECORD pt
 FREE RECORD temp
END GO
