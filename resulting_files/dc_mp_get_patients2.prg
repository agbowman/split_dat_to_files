CREATE PROGRAM dc_mp_get_patients2
 IF ( NOT (validate(ptreply)))
  RECORD ptreply(
    1 pt_cnt = i4
    1 page_cnt = i4
    1 tabname = vc
    1 prsnlid = f8
    1 positioncd = f8
    1 viewprefsid = f8
    1 patients[*]
      2 pagenum = i4
      2 ptqualind = i4
      2 pt_id = f8
      2 encntr_id = f8
      2 encntr_typecd = f8
      2 name = vc
      2 fin = vc
      2 mrn = vc
      2 age = vc
      2 birth_dt = vc
      2 birthdtjs = vc
      2 gender = vc
      2 org_id = f8
      2 facility = vc
      2 facilitycd = f8
      2 nurse_unit = vc
      2 room = vc
      2 bed = vc
      2 los = f8
      2 attend_phy = vc
      2 nurse = vc
      2 admit_dt = vc
      2 admitdtjs = vc
      2 surg_dt = vc
      2 surgdtjs = vc
      2 allergy_cnt = i4
      2 visitreason = vc
      2 allergy[*]
        3 alg_desc = vc
        3 severity = vc
        3 type = vc
      2 diag_cnt = i4
      2 diag[*]
        3 diag_desc = vc
        3 diag_dt = vc
        3 diagdtjs = vc
        3 type = vc
      2 prob_cnt = i4
      2 problem[*]
        3 prob_desc = vc
        3 prob_dt = vc
        3 probdtjs = vc
        3 type = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i2
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patient_list_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
     2 birthdate = dq8
     2 birth_tz = i4
     2 end_effective_dt_tm = dq8
     2 service_cd = f8
     2 service_disp = c40
     2 gender_cd = f8
     2 gender_disp = c40
     2 temp_location_cd = f8
     2 temp_location_disp = c40
     2 vip_cd = f8
     2 visit_reason = vc
     2 visitor_status_cd = f8
     2 visitor_status_disp = c40
     2 deceased_date = dq8
     2 deceased_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE statusscript = vc WITH constant("dc_mp_get_patients2g")
 DECLARE nurseconcept = vc WITH constant("CERNER!342B84E3-8C00-4041-B249-0A389D5209D7"), protect
 DECLARE fincki = vc WITH constant("CERNER!D909BE9F-D045-4C81-BA6A-D1C71F605525"), protect
 DECLARE mrncki = vc WITH constant("CERNER!1A69217B-30EC-4B41-B67A-DE39630F15AD"), protect
 DECLARE attendphy = vc WITH constant("CERNER!B5FCA4F5-DCAC-4CF8-A3E2-941C08D8B725"), protect
 DECLARE activelifecd = f8 WITH constant(uar_get_code_by("MEANING",12030,"ACTIVE")), protect
 DECLARE activecd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE authcd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE modcd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE altercd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE ptsperpage = f8 WITH constant(25.0), protect
 DECLARE positioncd = f8
 DECLARE tabnumstrg = vc
 DECLARE viewprefid = f8
 DECLARE strsize = i2
 DECLARE commapos = i2
 DECLARE tabdefnumstring = vc
 DECLARE tabdefnumint = i2
 SET ptreply->tabname = "Patient Information"
 DECLARE now = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE num2 = i4
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE jrec = i4 WITH protect
 DECLARE namevar = vc WITH protect
 DECLARE facilityvar = vc WITH protect
 DECLARE visitvar = vc WITH protect
 IF (( $2 != null))
  SET jrec = cnvtjsontorec( $2)
  CALL echo("This is the converted json string to record")
  CALL echorecord(qmreq)
 ENDIF
 SET ptreply->status_data.status = "F"
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 IF ((qmreq->ptlistid=0.0)
  AND (qmreq->ptlisttype > 0.0))
  SET request->patient_list_id = qmreq->ptlistid
  SET request->patient_list_type_cd = qmreq->ptlisttype
  SET request->best_encntr_flag = 1
  SET now = alterlist(request->arguments,1)
  SET request->arguments[1].argument_name = "location"
  SET request->arguments[1].parent_entity_name = "LOCATION"
  SET request->arguments[1].parent_entity_id = qmreq->ptlistloccd
  GO TO defaultlist
 ELSE
  SET request->patient_list_id = qmreq->ptlistid
  SET request->patient_list_type_cd = qmreq->ptlisttype
  SET request->best_encntr_flag = 1
 ENDIF
 SELECT INTO "NL:"
  d.argument_name, d.argument_value, d.parent_entity_id,
  d.parent_entity_name
  FROM dcp_pl_argument d
  PLAN (d
   WHERE (d.patient_list_id=request->patient_list_id))
  HEAD REPORT
   cntr = 0
  DETAIL
   cntr = (cntr+ 1)
   IF (mod(cntr,10)=1)
    now = alterlist(request->arguments,(cntr+ 9))
   ENDIF
   request->arguments[cntr].argument_name = d.argument_name, request->arguments[cntr].argument_value
    = d.argument_value, request->arguments[cntr].parent_entity_name = d.parent_entity_name,
   request->arguments[cntr].parent_entity_id = d.parent_entity_id
  FOOT REPORT
   now = alterlist(request->arguments,cntr)
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Patient List Arguments",errmsg)
 ENDIF
 CALL echorecord(request)
 SELECT INTO "NL:"
  d.encntr_type_cd
  FROM dcp_pl_encntr_filter d
  PLAN (d
   WHERE (d.patient_list_id=request->patient_list_id))
  HEAD REPORT
   cntr = 0
  DETAIL
   cntr = (cntr+ 1)
   IF (mod(cntr,10)=1)
    now = alterlist(request->encntr_type_filters,(cntr+ 9))
   ENDIF
   request->encntr_type_filters[cntr].encntr_type_cd = d.encntr_type_cd
  FOOT REPORT
   now = alterlist(request->encntr_type_filters,cntr)
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","ENCNTR FILTERS",errmsg)
 ENDIF
#defaultlist
 CALL echorecord(request)
 CALL echo("THE POWERCHART SCRIPT IS NEXT")
 EXECUTE dcp_get_patient_list2
 CALL echorecord(reply)
 SET modify = nopredeclare
 SELECT INTO "NL:"
  admit_dt =
  IF (e.arrive_dt_tm > 0) e.arrive_dt_tm
  ELSEIF (e.reg_dt_tm > 0) e.reg_dt_tm
  ELSE e.beg_effective_dt_tm
  ENDIF
  , e.encntr_id, e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd),
  e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp =
  uar_get_code_display(e.loc_nurse_unit_cd), e_loc_room_disp = uar_get_code_display(e.loc_room_cd),
  e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd), e.organization_id, name = cnvtupper(substring(
    1,40,p.name_full_formatted)),
  p_sex_disp = uar_get_code_display(p.sex_cd), age = cnvtage(p.birth_dt_tm)
  FROM encounter e,
   person p
  PLAN (e
   WHERE expand(num,1,size(reply->patients,5),e.encntr_id,reply->patients[num].encntr_id)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY name, e.encntr_id
  HEAD REPORT
   cntr = 0, pagecount1 = 0.0, pagecount2 = 0,
   pagecount1 = cnvtreal((size(reply->patients,5)/ ptsperpage)), pagecount2 = cnvtint(pagecount1)
   IF (pagecount1 > pagecount2)
    ptreply->page_cnt = (pagecount2+ 1)
   ELSEIF (pagecount1=pagecount2)
    ptreply->page_cnt = pagecount2
   ENDIF
   namevar = "", facilityvar = "", visitvar = ""
  DETAIL
   namevar = "", faclityvar = "", visitvar = "",
   cntr = (cntr+ 1), pagecount1 = cnvtreal((cntr/ ptsperpage)), pagecount2 = cnvtint(pagecount1)
   IF (pagecount1 > pagecount2)
    pagecount2 = (pagecount2+ 1)
   ENDIF
   IF (mod(cntr,100)=1)
    now = alterlist(ptreply->patients,(cntr+ 99))
   ENDIF
   namevar = replace(p.name_full_formatted,"'","^",0), facilityvar = replace(e_loc_facility_disp,"'",
    "^",0), visitvar = replace(trim(e.reason_for_visit),"'","^",0),
   ptreply->patients[cntr].pagenum = pagecount2, ptreply->patients[cntr].pt_id = p.person_id, ptreply
   ->patients[cntr].encntr_id = e.encntr_id,
   ptreply->patients[cntr].encntr_typecd = e.encntr_type_cd, ptreply->patients[cntr].org_id = e
   .organization_id, ptreply->patients[cntr].name = cnvtupper(replace(namevar,'"',"^^",0)),
   ptreply->patients[cntr].age = age, ptreply->patients[cntr].birth_dt = format(p.birth_dt_tm,
    "dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[cntr].birthdtjs = format(p.birth_dt_tm,
    "mm/dd/yyyy;1;q"),
   ptreply->patients[cntr].gender = p_sex_disp, ptreply->patients[cntr].facility = replace(
    facilityvar,'"',"^^",0), ptreply->patients[cntr].facilitycd = e.loc_facility_cd,
   ptreply->patients[cntr].nurse_unit = replace(e_loc_nurse_unit_disp,"'","",0), ptreply->patients[
   cntr].room = e_loc_room_disp, ptreply->patients[cntr].bed = e_loc_bed_disp,
   ptreply->patients[cntr].admit_dt = format(admit_dt,"dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[
   cntr].admitdtjs = format(admit_dt,"mm/dd/yyyy hh:mm;1;q"), ptreply->patients[cntr].visitreason =
   replace(visitvar,'"',"^^",0)
   IF (e.disch_dt_tm > 0.0)
    ptreply->patients[cntr].los = datetimecmp(cnvtdatetime(e.disch_dt_tm),cnvtdatetime(admit_dt))
   ELSE
    ptreply->patients[cntr].los = datetimecmp(cnvtdatetime(curdate,curtime3),cnvtdatetime(admit_dt))
   ENDIF
  FOOT REPORT
   now = alterlist(ptreply->patients,cntr), ptreply->pt_cnt = cntr
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","PATIENT DEMOGRAPHICS",errmsg)
 ENDIF
 SELECT INTO "NL:"
  e.alias
  FROM encntr_alias e
  PLAN (e
   WHERE expand(num,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num].encntr_id)
    AND (e.encntr_alias_type_cd=
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.concept_cki=fincki
     AND c.code_set=319))
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY e.encntr_id, e.beg_effective_dt_tm DESC
  HEAD REPORT
   cntx = 0
  HEAD e.encntr_id
   cntx = locateval(num2,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num2].encntr_id), ptreply->
   patients[cntx].fin = e.alias
  FOOT  e.encntr_id
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","FIN NUMBER",errmsg)
 ENDIF
 SELECT INTO "NL:"
  e.alias
  FROM encntr_alias e
  PLAN (e
   WHERE expand(num,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num].encntr_id)
    AND e.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"MRN"))
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY e.encntr_id, e.beg_effective_dt_tm DESC
  HEAD REPORT
   cntx = 0
  HEAD e.encntr_id
   cntx = locateval(num2,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num2].encntr_id), ptreply->
   patients[cntx].mrn = e.alias
  FOOT  e.encntr_id
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","MRN NUMBER",errmsg)
 ENDIF
 SELECT INTO "NL:"
  p.name_full_formatted
  FROM dcp_shift_assignment dc,
   prsnl p
  PLAN (dc
   WHERE expand(num,1,ptreply->pt_cnt,dc.encntr_id,ptreply->patients[num].encntr_id)
    AND ((dc.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((dc.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
    AND dc.active_ind=1
    AND (dc.assign_type_cd=
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.concept_cki=nurseconcept
     AND c.code_set=259571)))
   JOIN (p
   WHERE p.person_id=dc.prsnl_id
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
    AND p.active_ind=1)
  ORDER BY dc.encntr_id, dc.beg_effective_dt_tm DESC
  HEAD REPORT
   cntx = 0
  HEAD dc.encntr_id
   cntx = locateval(num2,1,ptreply->pt_cnt,dc.encntr_id,ptreply->patients[num2].encntr_id), ptreply->
   patients[cntx].nurse = trim(p.name_full_formatted)
  FOOT  dc.encntr_id
   row + 0
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","ASSIGNED NURSE",errmsg)
 ENDIF
 SELECT INTO "NL:"
  p.name_full_formatted
  FROM encntr_prsnl_reltn e,
   prsnl p
  PLAN (e
   WHERE expand(num,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num].encntr_id)
    AND (e.encntr_prsnl_r_cd=
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.concept_cki=attendphy
     AND c.code_set=333))
    AND e.active_ind=1
    AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((e.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE e.prsnl_person_id=p.person_id
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
    AND p.active_ind=1)
  ORDER BY e.encntr_id, e.beg_effective_dt_tm DESC
  HEAD REPORT
   cntx = 0
  HEAD e.encntr_id
   cntx = locateval(num2,1,ptreply->pt_cnt,e.encntr_id,ptreply->patients[num2].encntr_id), ptreply->
   patients[cntx].attend_phy = trim(p.name_full_formatted)
  FOOT  e.encntr_id
   row + 0
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","ATTENDING",errmsg)
 ENDIF
 SELECT INTO "NL:"
  s.encntr_id, s.surg_start_dt_tm
  FROM surgical_case s
  PLAN (s
   WHERE expand(num,1,ptreply->pt_cnt,s.encntr_id,ptreply->patients[num].encntr_id)
    AND s.active_ind=1
    AND ((s.surg_start_dt_tm+ 0) != null))
  ORDER BY s.encntr_id, s.surg_start_dt_tm DESC
  HEAD REPORT
   cntx = 0
  HEAD s.encntr_id
   cntx = locateval(num2,1,ptreply->pt_cnt,s.encntr_id,ptreply->patients[num2].encntr_id), ptreply->
   patients[cntx].surg_dt = format(s.surg_start_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[
   cntx].surgdtjs = format(s.surg_start_dt_tm,"mm/dd/yyyy hh:mm;1;q")
  FOOT  s.encntr_id
   row + 0
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","SURGERY DATE",errmsg)
 ENDIF
 SELECT INTO "NL:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=qmreq->prsnlid)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   positioncd = p.position_cd, ptreply->positioncd = p.position_cd, ptreply->prsnlid = p.person_id,
   CALL echo(build("position:",uar_get_code_display(p.position_cd)))
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM app_prefs a,
   name_value_prefs n
  PLAN (a
   WHERE a.position_cd=positioncd
    AND (a.application_number=qmreq->appid))
   JOIN (n
   WHERE a.app_prefs_id=n.parent_entity_id
    AND n.pvc_name="DEFAULT_VIEWS")
  HEAD REPORT
   tabnumstrg = trim(n.pvc_value), strsize = size(tabnumstrg,1), commapos = findstring(",",tabnumstrg,
    1,0)
   IF (commapos=0)
    tabdefnumstring = "1"
   ELSE
    tabdefnumstring = substring((commapos+ 1),strsize,tabnumstrg), tabdefnumint = cnvtint(
     tabdefnumstring), tabdefnumint = (tabdefnumint+ 1),
    tabdefnumstring = cnvtstring(tabdefnumint)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM name_value_prefs n,
   view_prefs v,
   name_value_prefs n1
  PLAN (n
   WHERE n.pvc_name="DISPLAY_SEQ"
    AND n.pvc_value=tabdefnumstring)
   JOIN (v
   WHERE v.view_prefs_id=n.parent_entity_id
    AND v.position_cd=positioncd
    AND (v.application_number=qmreq->appid)
    AND v.frame_type="CHART")
   JOIN (n1
   WHERE n1.parent_entity_id=v.view_prefs_id
    AND n1.pvc_name="VIEW_CAPTION")
  HEAD REPORT
   viewprefid = v.view_prefs_id, ptreply->viewprefsid = v.view_prefs_id, ptreply->tabname = trim(n1
    .pvc_value)
  WITH nocounter
 ;end select
 IF ((qmreq->probind=1))
  SELECT INTO "NL:"
   p_life_cycle_status_disp = uar_get_code_display(p.life_cycle_status_cd), p.life_cycle_dt_tm, p
   .beg_effective_dt_tm,
   p_status_updt_precision_disp = uar_get_code_display(p.status_updt_precision_cd), p
   .status_updt_dt_tm, n.source_string,
   n.source_identifier
   FROM problem p,
    nomenclature n
   PLAN (p
    WHERE expand(num,1,ptreply->pt_cnt,p.person_id,ptreply->patients[num].pt_id)
     AND p.problem_id > 0
     AND p.life_cycle_status_cd=activelifecd
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id
     AND n.data_status_cd IN (authcd, modcd, altercd)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id, p.beg_effective_dt_tm DESC
   HEAD REPORT
    cntr = 0, cntx = 0
   HEAD p.person_id
    cntx = locateval(num2,1,ptreply->pt_cnt,p.person_id,ptreply->patients[num2].pt_id), cntr = 0
   DETAIL
    cntr = (cntr+ 1)
    IF (mod(cntr,10)=1)
     now = alterlist(ptreply->patients[cntx].problem,(cntr+ 9))
    ENDIF
    IF (n.nomenclature_id > 0)
     ptreply->patients[cntx].problem[cntr].prob_desc = trim(substring(1,230,n.source_string)),
     ptreply->patients[cntx].problem[cntr].type = trim(n.source_identifier)
    ELSE
     ptreply->patients[cntx].problem[cntr].prob_desc = trim(p.problem_ftdesc), ptreply->patients[cntx
     ].problem[cntr].type = "Free Text Description"
    ENDIF
    IF (p.life_cycle_dt_tm != null)
     ptreply->patients[cntx].problem[cntr].prob_dt = format(p.life_cycle_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[cntx].problem[cntr].probdtjs = format(p
      .life_cycle_dt_tm,"mm/dd/yyyy hh:mm;1;q")
    ELSE
     ptreply->patients[cntx].problem[cntr].prob_dt = format(p.beg_effective_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[cntx].problem[cntr].probdtjs = format(p
      .beg_effective_dt_tm,"mm/dd/yyyy hh:mm;1;q")
    ENDIF
   FOOT  p.person_id
    now = alterlist(ptreply->patients[cntx].problem,cntr), ptreply->patients[cntx].prob_cnt = cntr
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","PROBLEMS",errmsg)
  ENDIF
 ENDIF
 IF ((qmreq->probind=1))
  SELECT INTO "NL:"
   d.diagnosis_display, diagdt =
   IF (d.diag_dt_tm != null) d.diag_dt_tm
   ELSE d.beg_effective_dt_tm
   ENDIF
   , d.diag_ftdesc,
   d_diag_type_disp = uar_get_code_display(d.diag_type_cd), d.nomenclature_id, d_active_status_disp
    = uar_get_code_display(d.active_status_cd),
   n.source_string
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE expand(num,1,ptreply->pt_cnt,d.encntr_id,ptreply->patients[num].encntr_id)
     AND d.active_status_cd=activecd
     AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND n.data_status_cd IN (authcd, modcd, altercd)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.encntr_id, diagdt DESC
   HEAD REPORT
    cntr = 0, cntx = 0
   HEAD d.encntr_id
    cntx = locateval(num2,1,ptreply->pt_cnt,d.encntr_id,ptreply->patients[num2].encntr_id), cntr = 0
   DETAIL
    cntr = (cntr+ 1)
    IF (mod(cntr,10)=1)
     now = alterlist(ptreply->patients[cntx].diag,(cntr+ 9))
    ENDIF
    ptreply->patients[cntx].diag[cntr].type = d_diag_type_disp, ptreply->patients[cntx].diag[cntr].
    diag_dt = format(diagdt,"dd-mmm-yyyy hh:mm:ss;;q"), ptreply->patients[cntx].diag[cntr].diagdtjs
     = format(diagdt,"mm/dd/yyyy hh:mm;1;q")
    IF (d.nomenclature_id > 0)
     ptreply->patients[cntx].diag[cntr].diag_desc = trim(substring(1,230,n.source_string))
    ELSEIF (d.diag_ftdesc > " ")
     ptreply->patients[cntx].diag[cntr].diag_desc = trim(d.diag_ftdesc)
    ENDIF
   FOOT  d.encntr_id
    now = alterlist(ptreply->patients[cntx].diag,cntr), ptreply->patients[cntx].diag_cnt = cntr
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","DIAGNOSIS",errmsg)
  ENDIF
 ENDIF
 IF ((qmreq->allergyind=1))
  SELECT INTO "NL:"
   a.beg_effective_dt_tm, a.substance_ftdesc, type_disp = uar_get_code_display(a.substance_type_cd),
   n.source_string
   FROM allergy a,
    nomenclature n
   PLAN (a
    WHERE expand(num,1,ptreply->pt_cnt,a.person_id,ptreply->patients[num].pt_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND a.active_status_cd=activecd)
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id
     AND n.active_ind=1
     AND n.data_status_cd IN (authcd, modcd, altercd)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY a.person_id, a.beg_effective_dt_tm DESC
   HEAD REPORT
    cntr = 0, cntx = 0
   HEAD a.person_id
    cntx = locateval(num2,1,ptreply->pt_cnt,a.person_id,ptreply->patients[num2].pt_id), cntr = 0
   DETAIL
    cntr = (cntr+ 1)
    IF (mod(cntr,10)=1)
     now = alterlist(ptreply->patients[cntx].problem,(cntr+ 9))
    ENDIF
    ptreply->patients[cntx].allergy[cntr].severity = uar_get_code_display(a.severity_cd), ptreply->
    patients[cntx].allergy[cntr].type = type_disp
    IF (a.substance_nom_id=0
     AND a.substance_ftdesc > " ")
     ptreply->patients[cntx].allergy[cntr].alg_desc = trim(a.substance_ftdesc)
    ELSEIF (a.substance_nom_id > 0)
     ptreply->patients[cntx].allergy[cntr].alg_desc = trim(n.source_string)
    ENDIF
   FOOT  a.person_id
    now = alterlist(ptreply->patients[cntx].allergy,cntr), ptreply->patients[cntx].allergy_cnt = cntr
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","ALLERGIES",errmsg)
  ENDIF
 ENDIF
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(ptreply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (ptreply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET lstat = alter(ptreply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET ptreply->status_data.status = "F"
   SET ptreply->status_data.subeventstatus[error_cnt].operationname = statusscript
   SET ptreply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET ptreply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET ptreply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SET ptreply->status_data.status = "S"
#exit_script
 CALL echorecord(ptreply)
 CALL echo("SCRIPT VERSION IS 09/01/2011 Allison Wynn 003")
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(ptreply)
 ELSE
  CALL echojson(ptreply, $1)
  SELECT INTO "nl:"
   DETAIL
    row + 0
   WITH nocounter
  ;end select
 ENDIF
END GO
