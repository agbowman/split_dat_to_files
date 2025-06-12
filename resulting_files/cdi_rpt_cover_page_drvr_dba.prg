CREATE PROGRAM cdi_rpt_cover_page_drvr:dba
 DECLARE ssortfield1 = vc WITH public, noconstant(" ")
 DECLARE ssortfield2 = vc WITH public, noconstant(" ")
 DECLARE ssortfield3 = vc WITH public, noconstant(" ")
 DECLARE setsortvalues(isortnbr=i2,ssortfield=vc) = null WITH protect
 DECLARE enctr_cnt = i4 WITH noconstant(0)
 DECLARE alias_cnt = i4 WITH noconstant(0)
 DECLARE tmp_alias_cnt = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE sbatchselection = vc WITH noconstant(" ")
 DECLARE istringsize = i4 WITH public, noconstant(0)
 DECLARE exp_batch_size = i2 WITH protect, constant(20)
 DECLARE exp_start_idx = i4 WITH protect, noconstant(1)
 IF (pc_request=0)
  SET req_size = size(request->encntr_qual,5)
  SET sbatchselection = request->batch_selection
  SET istringsize = size(request->batch_selection)
 ELSE
  SET req_size = size(request->visit,5)
 ENDIF
 SET ecount = 0
 SET pcount = 0
 SET d = findstring("^",sbatchselection)
 SET d = findstring("^",sbatchselection,(d+ 1))
 SET d = findstring("^",sbatchselection,(d+ 1))
 IF (d > 0
  AND istringsize > d)
  SET e = findstring("^",sbatchselection,(d+ 1))
  IF (e > 0
   AND istringsize > e)
   SET stempsort = substring((d+ 1),(e - (d+ 1)),sbatchselection)
   SET ssortfield1 = stempsort
   SET f = findstring("^",sbatchselection,(e+ 1))
   IF (f > 0
    AND istringsize > f)
    SET stempsort = substring((e+ 1),(f - (e+ 1)),sbatchselection)
    SET ssortfield2 = stempsort
    SET g = findstring("^",sbatchselection,(f+ 1))
    IF (g > 0)
     SET stempsort = substring((f+ 1),(g - (f+ 1)),sbatchselection)
     SET ssortfield3 = stempsort
    ELSE
     IF (istringsize > f)
      SET stempsort = substring((f+ 1),(istringsize - f),sbatchselection)
      SET ssortfield3 = stempsort
     ENDIF
    ENDIF
   ELSE
    SET stempsort = substring((e+ 1),(istringsize - e),sbatchselection)
    SET ssortfield2 = stempsort
    SET ssortfield3 = " "
   ENDIF
  ELSE
   SET stempsort = substring((d+ 1),(istringsize - d),sbatchselection)
   SET ssortfield1 = stempsort
  ENDIF
 ENDIF
 SET table_name = "(VARIOUS)"
 IF (req_size=0)
  SET failed = none_found
  SET error_value = "No encounters passed in."
  GO TO exit_script
 ENDIF
 SET cover_page_lyt->cover_page_name = uar_get_code_description(uar_get_code_by("MEANING",28360,
   "DOC_NAME"))
 RECORD evt_val_aliases(
   1 alias[*]
     2 codeval = f8
     2 display = vc
     2 meaning = vc
 )
 SET stat = alterlist(evt_val_aliases->alias,10)
 SET alias_cnt = 0
 SELECT INTO "nl:"
  f.alias_type_cd, display = uar_get_code_display(f.alias_type_cd), meaning = uar_get_code_meaning(f
   .alias_type_cd)
  FROM cdi_ac_field f
  WHERE f.doc_class_name=" "
   AND f.auto_search_ind=1
  ORDER BY meaning
  DETAIL
   alias_cnt = (alias_cnt+ 1)
   IF (mod(alias_cnt,10)=1
    AND alias_cnt > 10)
    stat = alterlist(evt_val_aliases->alias,(alias_cnt+ 9))
   ENDIF
   evt_val_aliases->alias[alias_cnt].codeval = f.alias_type_cd, evt_val_aliases->alias[alias_cnt].
   display = display, evt_val_aliases->alias[alias_cnt].meaning = meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(evt_val_aliases->alias,alias_cnt)
 SET enctr_cnt = req_size
 SET req_size = (ceil((cnvtreal(req_size)/ exp_batch_size)) * exp_batch_size)
 SET stat = alterlist(cover_page_lyt->pages,req_size)
 FOR (i = 1 TO req_size)
   IF (i <= enctr_cnt)
    IF (pc_request=0)
     SET cover_page_lyt->pages[i].encounter_id = request->encntr_qual[i].encntr_id
     SET cover_page_lyt->pages[i].person_id = validate(request->encntr_qual[i].person_id,0.0)
    ELSE
     SET cover_page_lyt->pages[i].encounter_id = request->visit[i].encntr_id
     SET cover_page_lyt->pages[i].person_id = 0.0
    ENDIF
   ENDIF
   SET stat = alterlist(cover_page_lyt->pages[i].parent_aliases,alias_cnt)
   FOR (j = 1 TO alias_cnt)
     SET cover_page_lyt->pages[i].parent_aliases[j].alias_name = evt_val_aliases->alias[j].display
   ENDFOR
 ENDFOR
 SET exp_start_idx = 1
 WHILE (exp_start_idx < req_size)
  SELECT INTO "nl:"
   e.encntr_id, e.person_id, e.loc_facility_cd,
   e.loc_nurse_unit_cd, e.reg_dt_tm, e.disch_dt_tm,
   ea.encntr_alias_type_cd, ea.alias, o.org_name
   FROM encounter e,
    (left JOIN encntr_alias ea ON e.encntr_id=ea.encntr_id
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)),
    organization o
   PLAN (e
    WHERE expand(i,exp_start_idx,((exp_start_idx+ exp_batch_size) - 1),e.encntr_id,cover_page_lyt->
     pages[i].encounter_id)
     AND e.encntr_id > 0.0)
    JOIN (ea)
    JOIN (o
    WHERE e.organization_id=o.organization_id)
   ORDER BY e.encntr_id
   DETAIL
    FOR (j = exp_start_idx TO ((exp_start_idx+ exp_batch_size) - 1))
      IF ((cover_page_lyt->pages[j].encounter_id=e.encntr_id))
       cover_page_lyt->pages[j].person_id = e.person_id, cover_page_lyt->pages[j].facility_name =
       uar_get_code_display(e.loc_facility_cd), cover_page_lyt->pages[j].patient_location =
       uar_get_code_display(e.loc_nurse_unit_cd),
       cover_page_lyt->pages[j].admit_dt_tm = e.reg_dt_tm, cover_page_lyt->pages[j].discharge_dt_tm
        = e.disch_dt_tm, cover_page_lyt->pages[j].org_name = o.org_name,
       k = locateval(i,1,alias_cnt,ea.encntr_alias_type_cd,evt_val_aliases->alias[i].codeval)
       IF (k > 0)
        cover_page_lyt->pages[j].parent_aliases[k].alias_value = ea.alias
       ENDIF
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SET exp_start_idx = (exp_start_idx+ exp_batch_size)
 ENDWHILE
 SET exp_start_idx = 1
 WHILE (exp_start_idx < req_size)
  SELECT INTO "nl:"
   p.person_id, pa.person_alias_type_cd, pa.alias
   FROM person p,
    (left JOIN person_alias pa ON p.person_id=pa.person_id
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   PLAN (p
    WHERE expand(i,exp_start_idx,((exp_start_idx+ exp_batch_size) - 1),p.person_id,cover_page_lyt->
     pages[i].person_id)
     AND p.person_id > 0.0)
    JOIN (pa)
   ORDER BY p.person_id
   DETAIL
    FOR (i = exp_start_idx TO ((exp_start_idx+ exp_batch_size) - 1))
      IF ((cover_page_lyt->pages[i].person_id=p.person_id))
       cover_page_lyt->pages[i].patient_name = p.name_full_formatted, cover_page_lyt->pages[i].
       birth_dt_tm = p.birth_dt_tm, k = locateval(j,1,alias_cnt,pa.person_alias_type_cd,
        evt_val_aliases->alias[j].codeval)
       IF (k > 0)
        cover_page_lyt->pages[i].parent_aliases[k].alias_value = pa.alias
       ENDIF
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SET exp_start_idx = (exp_start_idx+ exp_batch_size)
 ENDWHILE
 SET stat = alterlist(cover_page_lyt->pages,enctr_cnt)
 CALL setsortvalues(1,ssortfield1)
 CALL setsortvalues(2,ssortfield2)
 CALL setsortvalues(3,ssortfield3)
 SUBROUTINE setsortvalues(isortnbr,ssortfield)
   DECLARE irecidx = i4 WITH noconstant(1)
   DECLARE ireccnt = i4 WITH noconstant(size(cover_page_lyt->pages,5))
   DECLARE ialiasidx = i4 WITH noconstant(0)
   DECLARE itemp = i4 WITH noconstant(0)
   SET ssortfield = trim(ssortfield)
   IF (ssortfield="FIN")
    SET ssortfield = "FIN NBR"
   ENDIF
   CASE (ssortfield)
    OF "ADMIT DATE":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = format(cover_page_lyt->pages[
        irecidx].admit_dt_tm,"YYYYMMDDHHMMSS;;Q")
     ENDFOR
    OF "DISCHARGE DATE":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = format(cover_page_lyt->pages[
        irecidx].discharge_dt_tm,"YYYYMMDDHHMMSS;;Q")
     ENDFOR
    OF "ENCOUNTER_ID":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = format(cover_page_lyt->pages[
        irecidx].encounter_id,"#########;P0")
     ENDFOR
    OF "FACILITY":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = cover_page_lyt->pages[irecidx].
       facility_name
     ENDFOR
    OF "PATIENT LOC":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = cover_page_lyt->pages[irecidx].
       patient_location
     ENDFOR
    OF "PATIENT NAME":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = cover_page_lyt->pages[irecidx].
       patient_name
     ENDFOR
    OF "PERSON_ID":
     FOR (irecidx = 1 TO ireccnt)
       SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = format(cover_page_lyt->pages[
        irecidx].person_id,"#########;P0")
     ENDFOR
    ELSE
     IF (size(ssortfield) > 0)
      SET ialiasidx = locateval(itemp,1,alias_cnt,ssortfield,evt_val_aliases->alias[itemp].meaning)
      IF (ialiasidx > 0)
       FOR (irecidx = 1 TO ireccnt)
         SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = cover_page_lyt->pages[irecidx].
         parent_aliases[ialiasidx].alias_value
       ENDFOR
      ENDIF
     ELSE
      FOR (irecidx = 1 TO ireccnt)
        SET cover_page_lyt->pages[irecidx].sortby[isortnbr].value = format(irecidx,"######;P0")
      ENDFOR
     ENDIF
   ENDCASE
   RETURN
 END ;Subroutine
 SET failed = false
 SET error_value = "Success."
END GO
