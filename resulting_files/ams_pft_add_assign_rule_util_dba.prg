CREATE PROGRAM ams_pft_add_assign_rule_util:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Work Item:" = 0,
  "Assignment Rule:" = "",
  "Search for user:" = "",
  "User:" = 0,
  "Facility:" = 0,
  "Encounter type:" = 0,
  "Current financial class:" = 0,
  "Primary health plan:" = 0,
  "Patient last name between:" = "",
  "and" = ""
  WITH outdev, assignruleid, assignruledisp,
  usersearchstr, userid, orgid,
  encountertypecd, financialclasscd, healthplancd,
  lastnamestartstr, lastnameendstr
 EXECUTE ams_define_toolkit_common
 DECLARE populaterequest(null) = null WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_PFT_ADD_ASSIGN_RULE_UTIL")
 DECLARE fac_prompt_pos = i2 WITH protect, constant(6)
 DECLARE enc_type_prompt_pos = i2 WITH protect, constant(7)
 DECLARE fin_class_prompt_pos = i2 WITH protect, constant(8)
 DECLARE health_plan_prompt_pos = i2 WITH protect, constant(9)
 DECLARE personnel_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002623,"PERSONNEL")
  )
 DECLARE i = i4 WITH protect
 DECLARE j = i4 WITH protect
 DECLARE rulecnt = i4 WITH protect
 DECLARE amsuser = i2 WITH protect
 DECLARE listcheck = c1 WITH protect
 DECLARE listcnt = i4 WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE enctypecnt = i4 WITH protect
 DECLARE finclasscnt = i4 WITH protect
 DECLARE healthplancnt = i4 WITH protect
 DECLARE currrow = i4 WITH protect
 DECLARE critcnt = i4 WITH protect
 DECLARE maxgroupnbr = i4 WITH protect
 DECLARE prevtask = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE duplicateind = i2 WITH protect
 DECLARE nameerrorind = i2 WITH protect
 DECLARE displineprefix = vc
 DECLARE orgdisp = vc WITH protect
 DECLARE enctypedisp = vc WITH protect
 DECLARE finclassdisp = vc WITH protect
 DECLARE healthplandisp = vc WITH protect
 DECLARE namedisp = vc WITH protect
 IF (validate(debug,0)=0)
  DECLARE debug = i2 WITH protect, noconstant(0)
 ENDIF
 RECORD e_type(
   1 list[*]
     2 enc_type_cd = f8
 ) WITH protect
 RECORD fin_class(
   1 list[*]
     2 fin_class_cd = f8
 ) WITH protect
 RECORD health_plan(
   1 list[*]
     2 health_plan_id = f8
 ) WITH protect
 RECORD pft_request(
   1 ruleid = f8
   1 rulename = vc
   1 entitytype = f8
   1 rulecriterias[*]
     2 isaddedorremoved = i2
     2 groupnbr = i4
     2 criteriatokens[*]
       3 criteriaid = f8
       3 criterianame = vc
       3 criteriaentityname = vc
       3 criterialongvalue = f8
       3 criteriastringvalue = vc
       3 activeind = i2
 ) WITH protect
 RECORD pft_reply(
   1 statusmessage = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD rules(
   1 list_sz = i4
   1 rule_id = f8
   1 rule_name = vc
   1 entity_type_cd = f8
   1 max_group_nbr = i4
   1 list[*]
     2 duplicate_ind = i2
     2 disp_line = vc
     2 person_id = f8
     2 name_full_formatted = vc
     2 org_id = f8
     2 last_name_start = c1
     2 last_name_end = c1
     2 enc_type_list[*]
       3 enc_type_cd = f8
     2 fin_class_list[*]
       3 fin_class_cd = f8
     2 health_plan_list[*]
       3 health_plan_id = f8
 ) WITH protect
 IF (debug=1)
  CALL echo(build2("*** Beginning ",script_name," ***"))
 ENDIF
 IF (isamsuser(reqinfo->updt_id)=0)
  SET amsuser = 0
  GO TO exit_script
 ELSE
  SET amsuser = 1
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(fac_prompt_pos,0)))
 IF (debug=1)
  CALL echo("Determining if facility list box was multi-selected")
  CALL echo(build2("listCheck =  ",listcheck))
 ENDIF
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(fac_prompt_pos,listcnt)))
    IF (listcheck="F")
     SET rules->list_sz = (rules->list_sz+ 1)
     SET stat = alterlist(rules->list,rules->list_sz)
     SET rules->list[rules->list_sz].org_id = parameter(fac_prompt_pos,listcnt)
     SET rules->list[rules->list_sz].person_id =  $USERID
    ENDIF
  ENDWHILE
 ELSE
  SET rules->list_sz = 1
  SET stat = alterlist(rules->list,rules->list_sz)
  SET rules->list[rules->list_sz].org_id =  $ORGID
  SET rules->list[rules->list_sz].person_id =  $USERID
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(enc_type_prompt_pos,0)))
 IF (debug=1)
  CALL echo("Determining if encounter type list box was multi-selected")
  CALL echo(build2("listCheck =  ",listcheck))
 ENDIF
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(enc_type_prompt_pos,listcnt)))
    IF (listcheck="F")
     SET enctypecnt = (enctypecnt+ 1)
     FOR (rulecnt = 1 TO rules->list_sz)
      SET stat = alterlist(rules->list[rulecnt].enc_type_list,enctypecnt)
      SET rules->list[rulecnt].enc_type_list[enctypecnt].enc_type_cd = parameter(enc_type_prompt_pos,
       listcnt)
     ENDFOR
    ENDIF
  ENDWHILE
 ELSEIF (parameter(enc_type_prompt_pos,0) > 0.0)
  SET enctypecnt = 1
  FOR (rulecnt = 1 TO rules->list_sz)
   SET stat = alterlist(rules->list[rulecnt].enc_type_list,enctypecnt)
   SET rules->list[rulecnt].enc_type_list[enctypecnt].enc_type_cd =  $ENCOUNTERTYPECD
  ENDFOR
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(fin_class_prompt_pos,0)))
 IF (debug=1)
  CALL echo("Determining if financial class list box was multi-selected")
  CALL echo(build2("listCheck =  ",listcheck))
 ENDIF
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(fin_class_prompt_pos,listcnt)))
    IF (listcheck="F")
     SET finclasscnt = (finclasscnt+ 1)
     FOR (rulecnt = 1 TO rules->list_sz)
      SET stat = alterlist(rules->list[rulecnt].fin_class_list,finclasscnt)
      SET rules->list[rulecnt].fin_class_list[finclasscnt].fin_class_cd = parameter(
       fin_class_prompt_pos,listcnt)
     ENDFOR
    ENDIF
  ENDWHILE
 ELSEIF (parameter(fin_class_prompt_pos,0) > 0.0)
  SET finclasscnt = 1
  FOR (rulecnt = 1 TO rules->list_sz)
   SET stat = alterlist(rules->list[rulecnt].fin_class_list,finclasscnt)
   SET rules->list[rulecnt].fin_class_list[finclasscnt].fin_class_cd =  $FINANCIALCLASSCD
  ENDFOR
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(health_plan_prompt_pos,0)))
 IF (debug=1)
  CALL echo("Determining if health plan list box was multi-selected")
  CALL echo(build2("listCheck =  ",listcheck))
 ENDIF
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(health_plan_prompt_pos,listcnt)))
    IF (listcheck="F")
     SET healthplancnt = (healthplancnt+ 1)
     FOR (rulecnt = 1 TO rules->list_sz)
      SET stat = alterlist(rules->list[rulecnt].health_plan_list,healthplancnt)
      SET rules->list[rulecnt].health_plan_list[healthplancnt].health_plan_id = parameter(
       health_plan_prompt_pos,listcnt)
     ENDFOR
    ENDIF
  ENDWHILE
 ELSEIF (parameter(health_plan_prompt_pos,0) > 0.0)
  SET healthplancnt = 1
  FOR (rulecnt = 1 TO rules->list_sz)
   SET stat = alterlist(rules->list[rulecnt].health_plan_list,healthplancnt)
   SET rules->list[rulecnt].health_plan_list[healthplancnt].health_plan_id =  $HEALTHPLANCD
  ENDFOR
 ENDIF
 FOR (rulecnt = 1 TO rules->list_sz)
  IF (debug=1)
   CALL echo("Determining if patient last name input is valid")
  ENDIF
  IF (( $LASTNAMEENDSTR <=  $LASTNAMESTARTSTR)
   AND textlen(trim( $LASTNAMEENDSTR)) > 0)
   IF (debug=1)
    CALL echo("lastNameEndStr is alphabetically after lastNameStartStr or the same value")
    CALL echo(build2("lastNameEndStr =  ", $LASTNAMEENDSTR))
    CALL echo(build2("lastNameStartStr =  ", $LASTNAMESTARTSTR))
   ENDIF
   SET nameerrorind = 1
   GO TO exit_script
  ELSEIF (((textlen(trim( $LASTNAMESTARTSTR)) > 0
   AND textlen(trim( $LASTNAMEENDSTR))=0) OR (textlen(trim( $LASTNAMESTARTSTR))=0
   AND textlen(trim( $LASTNAMEENDSTR)) > 0)) )
   IF (debug=1)
    CALL echo("one lastNameStr not filled out but the other is")
    CALL echo(build2("lastNameEndStr =  ", $LASTNAMEENDSTR))
    CALL echo(build2("lastNameStartStr =  ", $LASTNAMESTARTSTR))
   ENDIF
   SET nameerrorind = 1
   GO TO exit_script
  ELSE
   SET rules->list[rulecnt].last_name_start =  $LASTNAMESTARTSTR
   SET rules->list[rulecnt].last_name_end =  $LASTNAMEENDSTR
  ENDIF
 ENDFOR
 IF (debug=1)
  CALL echo("rules record after being loaded initially")
  CALL echorecord(rules)
 ENDIF
 IF (debug=1)
  CALL echo("Building display lines for rules...")
 ENDIF
 SELECT INTO "nl:"
  d.seq, p.name_full_formatted, o.org_name,
  cv.display, hp.plan_name
  FROM (dummyt d  WITH seq = value(rules->list_sz)),
   organization o,
   prsnl p,
   (left JOIN code_value cv ON cv.code_set IN (71, 354)
    AND ((expand(i,1,size(rules->list[d.seq].enc_type_list,5),cv.code_value,rules->list[d.seq].
    enc_type_list[i].enc_type_cd)) OR (expand(i,1,size(rules->list[d.seq].fin_class_list,5),cv
    .code_value,rules->list[d.seq].fin_class_list[i].fin_class_cd))) ),
   (left JOIN health_plan hp ON expand(i,1,size(rules->list[d.seq].health_plan_list,5),hp
    .health_plan_id,rules->list[d.seq].health_plan_list[i].health_plan_id))
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=rules->list[d.seq].org_id))
   JOIN (p
   WHERE (p.person_id=rules->list[d.seq].person_id))
   JOIN (cv)
   JOIN (hp)
  ORDER BY d.seq, cv.code_set, cv.display_key,
   cv.code_value, cnvtupper(hp.plan_name), hp.health_plan_id
  HEAD d.seq
   IF (debug=1)
    CALL echo(build2("Display line for rule ",trim(cnvtstring(d.seq))))
   ENDIF
   displineprefix = build2(trim(p.name_full_formatted)," is responsible for"), enctypedisp = "",
   finclassdisp = "",
   namedisp = ""
   IF (textlen(trim(o.org_name_key)) > 0)
    orgdisp = build2(" facility ",trim(o.org_name))
   ELSE
    orgdisp = ""
   ENDIF
  HEAD cv.code_value
   IF (cv.code_set=71)
    IF (textlen(trim(enctypedisp))=0
     AND textlen(trim(orgdisp))=0)
     enctypedisp = build2(" encounter type ",trim(cv.display))
    ELSEIF (textlen(trim(enctypedisp))=0
     AND textlen(trim(orgdisp)) > 0)
     enctypedisp = build2(" and encounter type ",trim(cv.display))
    ELSEIF (textlen(trim(enctypedisp)) > 0)
     enctypedisp = build2(enctypedisp,", ",trim(cv.display))
    ENDIF
   ELSEIF (cv.code_set=354)
    IF (textlen(trim(finclassdisp))=0
     AND textlen(trim(orgdisp))=0
     AND textlen(trim(enctypedisp))=0)
     finclassdisp = build2(" current financial class ",trim(cv.display))
    ELSEIF (textlen(trim(finclassdisp))=0
     AND ((textlen(trim(orgdisp)) > 0) OR (textlen(trim(enctypedisp)) > 0)) )
     finclassdisp = build2(" and current financial class ",trim(cv.display))
    ELSEIF (textlen(trim(finclassdisp)) > 0)
     finclassdisp = build2(finclassdisp,", ",trim(cv.display))
    ENDIF
   ENDIF
   healthplandisp = ""
  HEAD hp.health_plan_id
   IF (hp.health_plan_id != 0.0)
    IF (textlen(trim(healthplandisp))=0
     AND textlen(trim(orgdisp))=0
     AND textlen(trim(enctypedisp))=0
     AND textlen(trim(finclassdisp))=0)
     healthplandisp = build2(" primary health plan ",trim(hp.plan_name))
    ELSEIF (textlen(trim(healthplandisp))=0
     AND ((textlen(trim(orgdisp)) > 0) OR (((textlen(trim(enctypedisp)) > 0) OR (textlen(trim(
      finclassdisp)) > 0)) )) )
     healthplandisp = build2(" and primary health plan ",trim(hp.plan_name))
    ELSEIF (textlen(trim(healthplandisp)) > 0)
     healthplandisp = build2(healthplandisp,", ",trim(hp.plan_name))
    ENDIF
   ENDIF
  FOOT  d.seq
   IF (textlen(trim( $LASTNAMESTARTSTR)) > 0)
    IF (((textlen(trim(orgdisp)) > 0) OR (((textlen(trim(enctypedisp)) > 0) OR (((textlen(trim(
      finclassdisp)) > 0) OR (textlen(trim(healthplandisp)) > 0)) )) )) )
     namedisp = " and"
    ENDIF
    namedisp = build2(trim(namedisp)," patient last name between ",rules->list[d.seq].last_name_start,
     " and ",rules->list[d.seq].last_name_end)
   ENDIF
   rules->list[d.seq].disp_line = build2(trim(displineprefix),trim(orgdisp),trim(enctypedisp),trim(
     finclassdisp),trim(healthplandisp),
    trim(namedisp)), rules->list[d.seq].name_full_formatted = p.name_full_formatted
   IF (debug=1)
    CALL echo(build2("dispLinePrefix = |",displineprefix,"|")),
    CALL echo(build2("orgDisp = |",orgdisp,"|")),
    CALL echo(build2("encTypeDisp = |",enctypedisp,"|")),
    CALL echo(build2("finClassDisp = |",finclassdisp,"|")),
    CALL echo(build2("healthPlanDisp = |",healthplandisp,"|")),
    CALL echo(build2("nameDisp = |",namedisp,"|")),
    CALL echo(build2("Finished display line: ",rules->list[d.seq].disp_line))
   ENDIF
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL echo("Checking for duplicate rules...")
 ENDIF
 SELECT
  IF ((rules->list_sz=1)
   AND (rules->list[1].org_id=0.0))
   PLAN (d)
    JOIN (pac
    WHERE (pac.pft_assignment_rule_id= $ASSIGNRULEID)
     AND pac.active_ind=1
     AND pac.criteria_name="OWNER"
     AND  NOT ( EXISTS (
    (SELECT
     pac3.group_nbr
     FROM pft_assignment_criteria pac3
     WHERE pac3.pft_assignment_rule_id=pac.pft_assignment_rule_id
      AND pac3.active_ind=1
      AND pac3.group_nbr=pac.group_nbr
      AND pac3.criteria_name="FACILITY"))))
    JOIN (pac2
    WHERE pac2.pft_assignment_rule_id=pac.pft_assignment_rule_id
     AND pac2.active_ind=1
     AND pac2.group_nbr=pac.group_nbr
     AND pac2.criteria_name != "FACILITY"
     AND pac2.criteria_name != "OWNER"
     AND pac2.criteria_name != "OWNER_TYPE")
  ELSE
   PLAN (d)
    JOIN (pac
    WHERE (pac.pft_assignment_rule_id= $ASSIGNRULEID)
     AND pac.active_ind=1
     AND pac.criteria_name="FACILITY"
     AND (pac.criteria_entity_id=rules->list[d.seq].org_id))
    JOIN (pac2
    WHERE pac2.pft_assignment_rule_id=pac.pft_assignment_rule_id
     AND pac2.active_ind=1
     AND pac2.group_nbr=pac.group_nbr
     AND pac2.criteria_name != "FACILITY"
     AND pac2.criteria_name != "OWNER"
     AND pac2.criteria_name != "OWNER_TYPE")
  ENDIF
  INTO "nl:"
  sort_thingy = evaluate(pac2.criteria_name,"ENCOUNTER_TYPE",1,"CURRENT_FINANCIAL_CLASS",2,
   "PRIMARY_HEALTH_PLAN",3,"NAME_STARTS",4,"NAME_ENDS",
   5)
  FROM (dummyt d  WITH seq = value(rules->list_sz)),
   pft_assignment_criteria pac,
   pft_assignment_criteria pac2
  ORDER BY pac.group_nbr, sort_thingy, pac2.criteria_entity_id,
   pac2.value_txt
  HEAD pac.group_nbr
   enctypecnt = 0, finclasscnt = 0, healthplancnt = 0,
   namestart = "", nameend = "", enctypematch = 1,
   finclassmatch = 1, healthplanmatch = 1, stat = initrec(e_type),
   stat = initrec(fin_class), stat = initrec(health_plan)
  DETAIL
   CASE (pac2.criteria_name)
    OF "ENCOUNTER_TYPE":
     enctypecnt = (enctypecnt+ 1),stat = alterlist(e_type->list,enctypecnt),e_type->list[enctypecnt].
     enc_type_cd = pac2.criteria_entity_id
    OF "CURRENT_FINANCIAL_CLASS":
     finclasscnt = (finclasscnt+ 1),stat = alterlist(fin_class->list,finclasscnt),fin_class->list[
     finclasscnt].fin_class_cd = pac2.criteria_entity_id
    OF "PRIMARY_HEALTH_PLAN":
     healthplancnt = (healthplancnt+ 1),stat = alterlist(health_plan->list,healthplancnt),health_plan
     ->list[healthplancnt].health_plan_id = pac2.criteria_entity_id
    OF "NAME_STARTS":
     namestart = trim(pac2.value_txt)
    OF "NAME_ENDS":
     nameend = trim(pac2.value_txt)
   ENDCASE
  FOOT  pac.group_nbr
   IF (debug=1)
    CALL echo(build2("pac.group_nbr = ",pac.group_nbr)),
    CALL echo(build2("encTypeCnt = ",enctypecnt)),
    CALL echo(build2("size rules->enc_type_list = ",size(rules->list[d.seq].enc_type_list,5))),
    CALL echo(build2("finClassCnt = ",finclasscnt)),
    CALL echo(build2("size of rules->fin_class_list = ",size(rules->list[d.seq].fin_class_list,5))),
    CALL echo(build2("healthPlanCnt = ",healthplancnt)),
    CALL echo(build2("size of rules->health_plan_list = ",size(rules->list[d.seq].health_plan_list,5)
     )),
    CALL echo(build2("nameStart = ",namestart)),
    CALL echo(build2("nameEnd = ",nameend))
   ENDIF
   IF (enctypecnt=size(rules->list[d.seq].enc_type_list,5)
    AND finclasscnt=size(rules->list[d.seq].fin_class_list,5)
    AND healthplancnt=size(rules->list[d.seq].health_plan_list,5)
    AND (namestart=rules->list[d.seq].last_name_start)
    AND (nameend=rules->list[d.seq].last_name_end))
    IF (debug=1)
     CALL echo("All counts match group_nbr, performing detailed checks")
    ENDIF
    FOR (cnt = 1 TO enctypecnt)
      IF (enctypematch=1)
       pos = locateval(i,1,enctypecnt,rules->list[d.seq].enc_type_list[cnt].enc_type_cd,e_type->list[
        i].enc_type_cd)
       IF (pos=0)
        enctypematch = 0
       ENDIF
      ENDIF
    ENDFOR
    IF (debug=1)
     CALL echo(build2("encTypeMatch = ",enctypematch))
    ENDIF
    IF (enctypematch=1)
     FOR (cnt = 1 TO finclasscnt)
       IF (finclassmatch=1)
        pos = locateval(i,1,finclasscnt,rules->list[d.seq].fin_class_list[cnt].fin_class_cd,fin_class
         ->list[i].fin_class_cd)
        IF (pos=0)
         finclassmatch = 0
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (debug=1)
     CALL echo(build2("finClassMatch = ",finclassmatch))
    ENDIF
    IF (enctypematch=1
     AND finclassmatch=1)
     FOR (cnt = 1 TO healthplancnt)
       IF (healthplanmatch=1)
        pos = locateval(i,1,healthplancnt,rules->list[d.seq].health_plan_list[cnt].health_plan_id,
         health_plan->list[i].health_plan_id)
        IF (pos=0)
         healthplanmatch = 0
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (debug=1)
     CALL echo(build2("healthPlanMatch = ",healthplanmatch))
    ENDIF
    IF (enctypematch=1
     AND finclassmatch=1
     AND healthplanmatch=1)
     rules->list[d.seq].duplicate_ind = 1, duplicateind = 1
    ENDIF
    IF (debug=1)
     CALL echo(build2("duplicateInd = ",duplicateind))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (duplicateind=1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  par.pft_assignment_rule_id, par.assignment_rule_name, par.entity_type_cd,
  pac.criteria_entity_id
  FROM pft_assignment_rule par,
   pft_assignment_criteria pac
  PLAN (par
   WHERE (par.pft_assignment_rule_id= $ASSIGNRULEID))
   JOIN (pac
   WHERE pac.pft_assignment_rule_id=par.pft_assignment_rule_id
    AND pac.active_ind=1
    AND (pac.group_nbr=
   (SELECT
    max(pac2.group_nbr)
    FROM pft_assignment_criteria pac2
    WHERE pac2.pft_assignment_rule_id=par.pft_assignment_rule_id)))
  ORDER BY par.pft_assignment_rule_id, pac.pft_assignment_criteria_id
  HEAD par.pft_assignment_rule_id
   rules->rule_id = par.pft_assignment_rule_id, rules->rule_name = par.assignment_rule_name, rules->
   entity_type_cd = par.entity_type_cd,
   rules->max_group_nbr = pac.group_nbr, stat = alterlist(pft_request->rulecriterias,1), pft_request
   ->rulecriterias[1].isaddedorremoved = 0,
   pft_request->rulecriterias[1].groupnbr = pac.group_nbr, critcnt = 0
  DETAIL
   critcnt = (critcnt+ 1), stat = alterlist(pft_request->rulecriterias[1].criteriatokens,critcnt),
   pft_request->rulecriterias[1].criteriatokens[critcnt].activeind = pac.active_ind,
   pft_request->rulecriterias[1].criteriatokens[critcnt].criteriaentityname = pac
   .criteria_entity_name, pft_request->rulecriterias[1].criteriatokens[critcnt].criteriaid = pac
   .pft_assignment_criteria_id, pft_request->rulecriterias[1].criteriatokens[critcnt].
   criterialongvalue = pac.criteria_entity_id,
   pft_request->rulecriterias[1].criteriatokens[critcnt].criterianame = pac.criteria_name,
   pft_request->rulecriterias[1].criteriatokens[critcnt].criteriastringvalue = pac.value_txt
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL echo("rules record after getting entity_type_cd and group_nbr")
  CALL echorecord(rules)
 ENDIF
 IF ((((rules->list_sz > 1)) OR ((((rules->list[1].org_id > 0.0)) OR (((size(rules->list[1].
  enc_type_list,5) > 0) OR (((size(rules->list[1].fin_class_list,5) > 0) OR (((size(rules->list[1].
  health_plan_list,5) > 0) OR (textlen(trim(rules->list[1].last_name_start)) > 0
  AND textlen(trim(rules->list[1].last_name_end)) > 0)) )) )) )) )) )
  CALL populaterequest(null)
  SET prevtask = reqinfo->updt_task
  SET reqinfo->updt_task = - (3202004)
  EXECUTE pft_wf_modify_assignment_rule  WITH replace("REQUEST",pft_request), replace("REPLY",
   pft_reply)
  SET reqinfo->updt_task = prevtask
  IF (debug=1)
   CALL echorecord(pft_reply)
  ENDIF
  CALL updtdminfo(script_name,cnvtreal(rules->list_sz))
  IF ((pft_reply->status_data.status="S"))
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
 SET currrow = 1
 SELECT INTO  $OUTDEV
  FROM dummyt d
  HEAD REPORT
   SUBROUTINE cclrtf_print(par_flag,par_startcol,par_numcol,par_blob,par_bloblen,par_check)
     m_output_buffer_len = 0, blob_out = fillstring(32768," "), blob_buf = fillstring(200," "),
     blob_len = 0, m_linefeed = concat(char(10)), textindex = 0,
     numcol = par_numcol, whiteflag = 0,
     CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
     m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
     IF (m_output_buffer_len > 0)
      m_cc = 1
      WHILE (m_cc > 0)
       m_cc2 = findstring(m_linefeed,blob_out,m_cc),
       IF (m_cc2)
        blob_len = (m_cc2 - m_cc)
        IF (blob_len <= par_numcol)
         m_blob_buf = substring(m_cc,blob_len,blob_out), col par_startcol
         IF (par_check)
          CALL print(trim(check(m_blob_buf)))
         ELSE
          CALL print(trim(m_blob_buf))
         ENDIF
         row + 1
        ELSE
         m_blobbuf = substring(m_cc,blob_len,blob_out),
         CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check), row + 1
        ENDIF
        IF (m_cc2 >= m_output_buffer_len)
         m_cc = 0
        ELSE
         m_cc = (m_cc2+ 1)
        ENDIF
       ELSE
        blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
        CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check),
        m_cc = 0
       ENDIF
      ENDWHILE
     ENDIF
   END ;Subroutine report
   ,
   SUBROUTINE cclrtf_printline(par_startcol,par_numcol,blob_out,blob_len,par_check)
     textindex = 0, numcol = par_numcol, whiteflag = 0,
     lastline = 0, m_linefeed = concat(char(10)), m_maxchar = concat(char(128)),
     m_find = 0
     WHILE (blob_len > 0)
       IF (blob_len <= par_numcol)
        numcol = blob_len, lastline = 1
       ENDIF
       textindex = (m_cc+ par_numcol)
       IF (lastline=0)
        whiteflag = 0
        WHILE (whiteflag=0)
         IF (((substring(textindex,1,blob_out)=" ") OR (substring(textindex,1,blob_out)=m_linefeed))
         )
          whiteflag = 1
         ELSE
          textindex = (textindex - 1)
         ENDIF
         ,
         IF (((textindex=m_cc) OR (textindex=0)) )
          textindex = (m_cc+ par_numcol), whiteflag = 1
         ENDIF
        ENDWHILE
        numcol = ((textindex - m_cc)+ 1)
       ENDIF
       m_blob_buf = substring(m_cc,numcol,blob_out)
       IF (m_blob_buf > " ")
        col par_startcol
        IF (par_check)
         CALL print(trim(check(m_blob_buf)))
        ELSE
         CALL print(trim(m_blob_buf))
        ENDIF
        row + 1
       ELSE
        blob_len = 0
       ENDIF
       m_cc = (m_cc+ numcol)
       IF (blob_len > numcol)
        blob_len = (blob_len - numcol)
       ELSE
        blob_len = 0
       ENDIF
     ENDWHILE
   END ;Subroutine report
  DETAIL
   row currrow,
   CALL center("New Assignment Rules Report",0,100), currrow = (currrow+ 3)
   IF (amsuser=0)
    col 5, row currrow, "ERROR: You are not recognized as an AMS associate."
   ELSEIF (( $ORGID=0.0)
    AND ( $ENCOUNTERTYPECD=0.0)
    AND ( $FINANCIALCLASSCD=0.0)
    AND ( $HEALTHPLANCD=0.0)
    AND ( $LASTNAMESTARTSTR="")
    AND ( $LASTNAMEENDSTR=""))
    col 5, row currrow, "ERROR: You must select at least one criteria to build a new rule."
   ELSEIF (nameerrorind=1)
    col 5, row currrow, "ERROR: Patient last name criteria must be alphabetical order",
    currrow = (currrow+ 1), col 12, row currrow,
    "and contain a starting and ending character."
   ELSEIF (duplicateind=1)
    col 5, row currrow, "ERROR: An existing rule exists with the same criteria.",
    currrow = (currrow+ 3), col 5, row currrow,
    "Duplicate Rule", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    FOR (i = 1 TO rules->list_sz)
      IF ((rules->list[i].duplicate_ind=1))
       row currrow,
       CALL cclrtf_print(0,5,90,rules->list[i].disp_line,32000,1), currrow = (row+ 2)
      ENDIF
    ENDFOR
   ELSEIF ((pft_reply->status_data.status="S"))
    IF ((rules->list_sz=1))
     tempstr = build2("Successfully created ",trim(cnvtstring(rules->list_sz)),
      " new assignment rule for {B}",rules->list[1].name_full_formatted)
    ELSE
     tempstr = build2("Successfully created ",trim(cnvtstring(rules->list_sz)),
      " new assignment rules for {B}",rules->list[1].name_full_formatted)
    ENDIF
    col 5, row currrow, tempstr,
    currrow = (currrow+ 3), col 5, row currrow,
    "New Rules", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    FOR (i = 1 TO rules->list_sz)
      row currrow,
      CALL cclrtf_print(0,5,90,rules->list[i].disp_line,32000,1), currrow = (row+ 2)
    ENDFOR
   ELSE
    col 5, row currrow, "ERROR: Script failed to complete successfully.",
    currrow = (currrow+ 3), col 5, row currrow,
    pft_reply->status_data.subeventstatus.operationname, currrow = (currrow+ 1), col 5,
    row currrow, pft_reply->status_data.subeventstatus.operationstatus, currrow = (currrow+ 1),
    col 5, row currrow, pft_reply->status_data.subeventstatus.targetobjectname,
    currrow = (currrow+ 1), col 5, row currrow,
    pft_reply->status_data.subeventstatus.targetobjectvalue
   ENDIF
  WITH nocounter, dio = 8, maxcol = 100
 ;end select
 IF (debug=1)
  CALL echo(build2("*** Ending ",script_name," ***"))
 ENDIF
 SUBROUTINE populaterequest(null)
   DECLARE rulecnt = i4 WITH protect, noconstant(1)
   SET pft_request->ruleid = rules->rule_id
   SET pft_request->rulename = rules->rule_name
   SET pft_request->entitytype = rules->entity_type_cd
   SET maxgroupnbr = (rules->max_group_nbr - 1)
   SET stat = alterlist(pft_request->rulecriterias,(rules->list_sz+ 1))
   FOR (i = 1 TO rules->list_sz)
     SET critcnt = 0
     SET rulecnt = (rulecnt+ 1)
     SET pft_request->rulecriterias[rulecnt].isaddedorremoved = 1
     SET maxgroupnbr = (maxgroupnbr+ 1)
     SET pft_request->rulecriterias[rulecnt].groupnbr = maxgroupnbr
     SET critcnt = (critcnt+ 1)
     IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
      SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
     ENDIF
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname =
     "CODE_VALUE"
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue =
     personnel_type_cd
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame = "OWNER_TYPE"
     SET critcnt = (critcnt+ 1)
     IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
      SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
     ENDIF
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname = "PRSNL"
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue = rules->list[
     i].person_id
     SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame = "OWNER"
     IF ((rules->list[i].org_id > 0.0))
      SET critcnt = (critcnt+ 1)
      IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
       SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
      ENDIF
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname =
      "ORGANIZATION"
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue = rules->
      list[i].org_id
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame = "FACILITY"
     ENDIF
     FOR (j = 1 TO size(rules->list[i].enc_type_list,5))
       SET critcnt = (critcnt+ 1)
       IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
        SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
       ENDIF
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname =
       "CODE_VALUE"
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue = rules->
       list[i].enc_type_list[j].enc_type_cd
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame =
       "ENCOUNTER_TYPE"
     ENDFOR
     FOR (j = 1 TO size(rules->list[i].fin_class_list,5))
       SET critcnt = (critcnt+ 1)
       IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
        SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
       ENDIF
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname =
       "CODE_VALUE"
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue = rules->
       list[i].fin_class_list[j].fin_class_cd
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame =
       "CURRENT_FINANCIAL_CLASS"
     ENDFOR
     FOR (j = 1 TO size(rules->list[i].health_plan_list,5))
       SET critcnt = (critcnt+ 1)
       IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
        SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
       ENDIF
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriaentityname =
       "HEALTH_PLAN"
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterialongvalue = rules->
       list[i].health_plan_list[j].health_plan_id
       SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame =
       "PRIMARY_HEALTH_PLAN"
     ENDFOR
     IF (textlen(trim( $LASTNAMESTARTSTR)) > 0
      AND textlen(trim( $LASTNAMEENDSTR)) > 0)
      SET critcnt = (critcnt+ 1)
      IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
       SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
      ENDIF
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame = "NAME_STARTS"
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriastringvalue = rules->
      list[i].last_name_start
      SET critcnt = (critcnt+ 1)
      IF (critcnt > size(pft_request->rulecriterias[rulecnt].criteriatokens,5))
       SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,(critcnt+ 5))
      ENDIF
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].activeind = 1
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criterianame = "NAME_ENDS"
      SET pft_request->rulecriterias[rulecnt].criteriatokens[critcnt].criteriastringvalue = rules->
      list[i].last_name_end
     ENDIF
     SET stat = alterlist(pft_request->rulecriterias[rulecnt].criteriatokens,critcnt)
   ENDFOR
   SET maxgroupnbr = (maxgroupnbr+ 1)
   SET pft_request->rulecriterias[1].groupnbr = maxgroupnbr
   IF (debug=1)
    CALL echo("pft_request after being loaded by populateRequest()")
    CALL echorecord(pft_request)
   ENDIF
 END ;Subroutine
 SET last_mod = "000"
END GO
