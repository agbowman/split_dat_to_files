CREATE PROGRAM ccps_clairvia_ref_data_ext
 PROMPT
  "Printer" = "MINE",
  "Facility " = "",
  "Start DD-MMM-YYYY HH:MM " = "",
  "End   DD-MMM-YYYY HH:MM " = "",
  "MBO " = "",
  "Directory " = "cer_temp:"
  WITH outdev, fac, startdttm,
  enddttm, mbo, filedir
 RECORD map(
   1 seq[*]
     2 event_code = f8
     2 clin_event_code = f8
     2 mnemonic = vc
     2 description = vc
     2 activity_type = vc
     2 result_type = vc
     2 code_cnt = i4
     2 response[*]
       3 sex = vc
       3 age_from = vc
       3 age_to = vc
       3 source_string = vc
     2 pf[*]
       3 form_desc = vc
       3 section_desc = vc
     2 iview[*]
       3 view_desc = vc
       3 section_desc = vc
 )
 RECORD drec(
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD fac(
   1 seq[*]
     2 display_key = vc
 )
 DECLARE primary_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3128"))
 DECLARE ivsolutions_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!33873"))
 DECLARE pharmacy_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
 DECLARE alt_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE auth_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mod_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE census_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!5203"))
 DECLARE inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE observation_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"))
 DECLARE dcpgenericcode_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1302386"))
 DECLARE begin_dt_tm = dq8 WITH public, noconstant
 DECLARE end_dt_tm = dq8 WITH public, noconstant
 DECLARE this_row = vc WITH public, noconstant(" ")
 DECLARE last_row = vc WITH public, noconstant(" ")
 DECLARE line1 = vc WITH public, noconstant(" ")
 DECLARE e_idx = i4 WITH public, noconstant(0)
 DECLARE a_idx = i4 WITH public, noconstant(0)
 DECLARE b_idx = i4 WITH public, noconstant(0)
 DECLARE ln_cnt = i4 WITH public, noconstant(0)
 DECLARE rank_flag = i2 WITH public, noconstant(0)
 DECLARE str = vc WITH public, noconstant("")
 DECLARE notfnd = vc WITH public, constant("<not_found>")
 DECLARE num = i4 WITH public, noconstant(1)
 DECLARE data = vc WITH public, noconstant("")
 DECLARE filedir = vc WITH public, noconstant( $FILEDIR)
 DECLARE mbo_mne = vc WITH public, constant(cnvtupper(trim( $MBO,3)))
 DECLARE voutdev = vc WITH public, constant(build(filedir,"CLAIRVIA_",trim(cnvtupper(mbo_mne),3),
   "_MAP.txt"))
 IF (( $STARTDTTM > " "))
  SET begin_dt_tm = cnvtdatetime( $STARTDTTM)
 ENDIF
 IF (( $ENDDTTM > " "))
  SET end_dt_tm = cnvtdatetime( $ENDDTTM)
 ENDIF
 IF (datetimediff(cnvtdatetime(end_dt_tm),cnvtdatetime(begin_dt_tm)) > 0)
  SET rank_flag = 1
 ENDIF
 SET data =  $FAC
 WHILE (str != notfnd)
   SET str = piece(data,",",num,notfnd)
   SET num = (num+ 1)
   SET stat = alterlist(fac->seq,num)
   SET fac->seq[num].display_key = str
 ENDWHILE
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   person p
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ed.end_effective_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND ed.encntr_domain_type_cd=census_cd
    AND (ed.loc_facility_cd=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE expand(num,1,size(fac->seq,5),cv.display_key,fac->seq[num].display_key)
     AND cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.active_ind=1)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.loc_nurse_unit_cd != 0.00
    AND e.loc_bed_cd != 0.00)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.person_id
  HEAD REPORT
   drec->person_qual_cnt = 0
  HEAD e.person_id
   drec->person_qual_cnt = (drec->person_qual_cnt+ 1)
   IF (mod(drec->person_qual_cnt,1000)=1)
    stat = alterlist(drec->person_qual,(drec->person_qual_cnt+ 999))
   ENDIF
   drec->person_qual[drec->person_qual_cnt].person_id = e.person_id
  FOOT REPORT
   stat = alterlist(drec->person_qual,drec->person_qual_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.mnemonic, a.description, activity_type = uar_get_code_display(a.activity_type_cd),
  result_type = uar_get_code_display(a.default_result_type_cd), sex = substring(1,1,
   uar_get_code_display(f.sex_cd)), age_from = concat(trim(cnvtstring((((f.age_from_minutes/ 60)/ 24)
     / 365)))," ",uar_get_code_display(f.age_from_units_cd)),
  age_to = concat(trim(cnvtstring((((f.age_to_minutes/ 60)/ 24)/ 365)))," ",uar_get_code_display(f
    .age_to_units_cd)), nom.source_string, nom.mnemonic
  FROM discrete_task_assay a,
   data_map m,
   reference_range_factor f,
   alpha_responses ar,
   nomenclature nom
  PLAN (a
   WHERE a.active_ind=1
    AND a.mnemonic > " ")
   JOIN (m
   WHERE m.task_assay_cd=outerjoin(a.task_assay_cd))
   JOIN (f
   WHERE f.task_assay_cd=outerjoin(a.task_assay_cd)
    AND f.active_ind=outerjoin(1))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(f.reference_range_factor_id))
   JOIN (nom
   WHERE nom.nomenclature_id=outerjoin(ar.nomenclature_id))
  ORDER BY a.mnemonic, a.activity_type_cd, f.age_from_minutes,
   f.reference_range_factor_id, ar.sequence
  HEAD REPORT
   cnt = 0, stat = alterlist(map->seq,1000)
  HEAD a.mnemonic
   cnt = (cnt+ 1)
   IF (mod(cnt,1000)=1)
    stat = alterlist(map->seq,(cnt+ 1000))
   ENDIF
   map->seq[cnt].event_code = a.task_assay_cd
   IF (a.event_cd=0)
    map->seq[cnt].clin_event_code = 999.00
   ELSE
    map->seq[cnt].clin_event_code = a.event_cd
   ENDIF
   map->seq[cnt].mnemonic = a.mnemonic, map->seq[cnt].description = a.description, map->seq[cnt].
   activity_type = uar_get_code_display(a.activity_type_cd),
   map->seq[cnt].result_type = uar_get_code_display(a.default_result_type_cd), r_cnt = 0, last_row =
   ""
  DETAIL
   IF (nom.source_string > " ")
    this_row = build(sex,"|",age_from,"|",age_to,
     "|",nom.source_string)
    IF (this_row != last_row)
     last_row = this_row, r_cnt = (r_cnt+ 1), stat = alterlist(map->seq[cnt].response,r_cnt),
     map->seq[cnt].response[r_cnt].sex = sex, map->seq[cnt].response[r_cnt].age_from = age_from, map
     ->seq[cnt].response[r_cnt].age_to = age_to,
     map->seq[cnt].response[r_cnt].source_string = nom.source_string
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(map->seq,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  form_desc = substring(1,50,f.description), section_desc = substring(1,50,s.description)
  FROM dcp_forms_def d,
   dcp_forms_ref f,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs prf
  PLAN (d
   WHERE d.active_ind=1)
   JOIN (f
   WHERE d.dcp_forms_ref_id=f.dcp_forms_ref_id
    AND f.active_ind=1
    AND f.end_effective_dt_tm > sysdate)
   JOIN (s
   WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
    AND s.active_ind=1
    AND s.end_effective_dt_tm > sysdate)
   JOIN (i
   WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
    AND i.active_ind=1)
   JOIN (prf
   WHERE i.dcp_input_ref_id=prf.parent_entity_id
    AND prf.merge_name="DISCRETE_TASK_ASSAY"
    AND prf.merge_id != 0.00
    AND prf.active_ind=1)
  ORDER BY prf.merge_id, f.description, s.description
  DETAIL
   this_row = build(f.description,s.description)
   IF (this_row != last_row)
    a_idx = locateval(b_idx,1,size(map->seq,5),prf.merge_id,map->seq[b_idx].event_code), last_row =
    this_row, pf_cnt = (size(map->seq[a_idx].pf,5)+ 1),
    stat = alterlist(map->seq[a_idx].pf,pf_cnt), map->seq[a_idx].pf[pf_cnt].form_desc = f.description,
    map->seq[a_idx].pf[pf_cnt].section_desc = s.description
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  wview = wv.display_name, section = substring(1,50,wvs.event_set_name), section_required =
  IF (wvs.required_ind=1) "y"
  ELSE "n"
  ENDIF
  ,
  section_included =
  IF (wvs.included_ind) "i"
  ELSE "e"
  ENDIF
  , event_set = substring(1,50,wvi.primitive_event_set_name), event_set_parent = substring(1,50,wvi
   .parent_event_set_name),
  item_event_cd = vec.event_cd, item_dta_event_cd = dta.task_assay_cd, item_included = wvi
  .included_ind,
  dta = dta.mnemonic, vec.event_cd
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi,
   v500_event_code vec,
   discrete_task_assay dta
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vec
   WHERE cnvtupper(vec.event_set_name)=cnvtupper(wvi.primitive_event_set_name))
   JOIN (dta
   WHERE dta.event_cd=vec.event_cd)
  ORDER BY dta.task_assay_cd, wv.display_name, wvs.event_set_name
  DETAIL
   this_row = build(wv.display_name,wvs.event_set_name)
   IF (this_row != last_row)
    last_row = this_row, a_idx = locateval(b_idx,1,size(map->seq,5),dta.task_assay_cd,map->seq[b_idx]
     .event_code), wv_cnt = (size(map->seq[a_idx].iview,5)+ 1),
    stat = alterlist(map->seq[a_idx].iview,wv_cnt), map->seq[a_idx].iview[wv_cnt].view_desc = concat(
     "IVIEW-",wv.display_name), map->seq[a_idx].iview[wv_cnt].section_desc = wvs.event_set_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_type_cd=pharmacy_cd
    AND ocs.dcp_clin_cat_cd=ivsolutions_cd
    AND ocs.mnemonic_type_cd=primary_cd
    AND  NOT (cnvtupper(ocs.mnemonic) IN ("ZZ*", "OBSOLETE*"))
    AND ocs.active_ind=1)
  HEAD REPORT
   cnt = size(map->seq,5), stat = alterlist(map->seq,(cnt+ 1000))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,1000)=1)
    stat = alterlist(map->seq,(cnt+ 1000))
   ENDIF
   map->seq[cnt].event_code = ocs.catalog_cd, map->seq[cnt].mnemonic = ocs.mnemonic, map->seq[cnt].
   description = uar_get_code_display(ocs.dcp_clin_cat_cd),
   map->seq[cnt].activity_type = uar_get_code_display(ocs.catalog_type_cd), map->seq[cnt].result_type
    = "AlphaNumeric"
  FOOT REPORT
   stat = alterlist(map->seq,cnt)
  WITH nocounter
 ;end select
 IF (rank_flag=0)
  GO TO mapping_output
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE expand(e_idx,1,drec->person_qual_cnt,ce.person_id,drec->person_qual[e_idx].person_id)
    AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ce.result_status_cd IN (mod_status_cd, auth_status_cd, alt_status_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.event_cd != dcpgenericcode_cd)
   JOIN (e
   WHERE ce.encntr_id=e.encntr_id
    AND e.encntr_type_class_cd IN (inpatient_class_cd, observation_class_cd))
  ORDER BY ce.event_cd
  HEAD ce.event_cd
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  ce.event_cd
   a_idx = 0, loop_cntr = 0
   WHILE (a_idx=0
    AND loop_cntr < size(map->seq,5))
    loop_cntr = (loop_cntr+ 1),
    IF ((((ce.task_assay_cd=map->seq[loop_cntr].event_code)) OR ((((ce.event_cd=map->seq[loop_cntr].
    clin_event_code)) OR ((ce.catalog_cd=map->seq[loop_cntr].event_code))) )) )
     a_idx = loop_cntr, map->seq[a_idx].code_cnt = cnt
    ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
#mapping_output
 SELECT INTO value(voutdev)
  activity_type = map->seq[d1.seq].activity_type, cntr = map->seq[d1.seq].code_cnt
  FROM (dummyt d1  WITH seq = size(map->seq,5))
  ORDER BY cntr DESC, activity_type, d1.seq
  HEAD REPORT
   line1 = build("LINE|RANK|CODE_VALUE|MNE|DESCRIPTION|ACTIVITY_TYPE|RESULT_TYPE|",
    "SEX|AGE_FROM|AGE_TO|SOURCE_STRING|POWERFORM|PFSECTION|IVIEW|IVIEWSECTION"), line1, row + 1,
   ln_cnt = 0
  HEAD d1.seq
   ln_cnt = (ln_cnt+ 1)
   FOR (a = 1 TO maxval(1,size(map->seq[d1.seq].pf,5),size(map->seq[d1.seq].response,5),size(map->
     seq[d1.seq].iview,5)))
     line1 = build(ln_cnt,"|",map->seq[d1.seq].code_cnt,"|",map->seq[d1.seq].event_code,
      "|",map->seq[d1.seq].mnemonic,"|",map->seq[d1.seq].description,"|",
      map->seq[d1.seq].activity_type,"|",map->seq[d1.seq].result_type,"|")
     IF (a <= size(map->seq[d1.seq].response,5))
      line1 = build(line1,map->seq[d1.seq].response[a].sex,"|",map->seq[d1.seq].response[a].age_from,
       "|",
       map->seq[d1.seq].response[a].age_to,"|",map->seq[d1.seq].response[a].source_string,"|")
     ELSE
      line1 = build(line1,"||||")
     ENDIF
     IF (a <= size(map->seq[d1.seq].pf,5))
      line1 = build(line1,map->seq[d1.seq].pf[a].form_desc,"|",map->seq[d1.seq].pf[a].section_desc,
       "|")
     ELSE
      line1 = build(line1,"||")
     ENDIF
     IF (a <= size(map->seq[d1.seq].iview,5))
      line1 = build(line1,map->seq[d1.seq].iview[a].view_desc,"|",map->seq[d1.seq].iview[a].
       section_desc,"|")
     ELSE
      line1 = build(line1,"||")
     ENDIF
     line1, row + 1
   ENDFOR
  WITH nocounter, noformfeed, maxrow = 1,
   format = variable, maxcol = 2000
 ;end select
#exit_script
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   CALL print(format(sysdate,";;q")), row + 1,
   CALL print(build2("Clairvia Reference Data Mapping Extract (",trim(curprog),") node:",curnode)),
   row + 1,
   CALL print(build2("Date Range: ",format(begin_dt_tm,";;q")," to ",format(end_dt_tm,";;q"))), row
    + 1
   IF (size(map->seq,5) > 0)
    CALL print(build2("Extract file written to: ",trim(voutdev,3)," The file should contain ",trim(
      cnvtstring(ln_cnt))," records."))
   ELSE
    CALL print("No qualifying data found.")
   ENDIF
  WITH nocounter, maxcol = 10000, separator = " ",
   format = variable, maxrow = 1
 ;end select
END GO
