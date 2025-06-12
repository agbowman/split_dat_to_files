CREATE PROGRAM amb_medicare_pop_detail
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Population Lookback Range:" = "1,M",
  "Organization" = value(*),
  "Location" = value(*),
  "Health Plan Type" = value(*),
  "Financial Class" = value(*),
  "Medicare Health Plan(s)" = 0,
  "Output report parameters" = "0",
  "Client mnemonic" = "",
  "Health plan cds" = ""
  WITH outdev, lookback_range, org_id,
  loc_cd, plan_type, fin_class,
  healthplans, output_params, client_mnemonic,
  healthplancds
 DECLARE PUBLIC::main(null) = null WITH protect
 DECLARE PUBLIC::getorgparser(null) = vc WITH protect
 DECLARE PUBLIC::getlocparser(null) = vc WITH protect
 DECLARE PUBLIC::gethpparser(null) = vc WITH protect
 DECLARE PUBLIC::gatheraddress(null) = null WITH protect
 DECLARE PUBLIC::gatherphone(null) = null WITH protect
 DECLARE PUBLIC::gathermrn(null) = null WITH protect
 DECLARE PUBLIC::gatherpcp(null) = null WITH protect
 DECLARE PUBLIC::cleanmedicarepop(null) = null WITH protect
 DECLARE PUBLIC::getbatchsize(null) = null WITH protect
 DECLARE PUBLIC::getparams(null) = vc WITH protect
 DECLARE PUBLIC::buildfilename(null) = vc WITH protect
 DECLARE PUBLIC::getorgname(null) = vc WITH protect
 IF ( NOT (validate(main_pop)))
  RECORD main_pop(
    1 medicare_pop = i4
    1 plist[*]
      2 name = vc
      2 fname = vc
      2 mname = vc
      2 lname = vc
      2 dob = vc
      2 gender = vc
      2 medicareid = vc
      2 zipcode = vc
      2 gender_cd = f8
      2 address1 = vc
      2 address2 = vc
      2 city = vc
      2 state = vc
      2 phone = vc
      2 cell_phone = vc
      2 pers_id = f8
      2 reg_date = vc
      2 location = vc
      2 loc_cd = f8
      2 nurse_unit_cd = f8
      2 nurse_unit = vc
      2 encntr_id = f8
      2 mrn = vc
      2 pcp = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(pop_to_fix)))
  RECORD pop_to_fix(
    1 plist[*]
      2 name = vc
      2 fname = vc
      2 mname = vc
      2 lname = vc
      2 dob = vc
      2 gender = vc
      2 medicareid = vc
      2 zipcode = vc
      2 gender_cd = f8
      2 address1 = vc
      2 address2 = vc
      2 city = vc
      2 state = vc
      2 phone = vc
      2 cell_phone = vc
      2 pers_id = f8
      2 reg_date = vc
      2 location = vc
      2 loc_cd = f8
      2 nurse_unit_cd = f8
      2 nurse_unit = vc
      2 encntr_id = f8
      2 mrn = vc
      2 pcp = vc
  ) WITH protect
 ENDIF
 DECLARE subroutine_status = f8 WITH noconstant(0), protect
 IF ((validate(89_powerchart,- (99))=- (99)))
  DECLARE 89_powerchart = f8 WITH public, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 ENDIF
 IF ((validate(48_inactive,- (99))=- (99)))
  DECLARE 48_inactive = f8 WITH public, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 IF ((validate(48_active,- (99))=- (99)))
  DECLARE 48_active = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 FREE RECORD locs
 RECORD locs(
   1 lcnt = i2
   1 llist[*]
     2 loc_name = vc
     2 loc_cd = f8
     2 loc_type = f8
 )
 SUBROUTINE (PUBLIC::getencntrreltn(dencntr_id=f8,dreltn_cd=f8,dprov_id=f8) =null)
   FREE RECORD epr_qual
   RECORD epr_qual(
     1 epr_cnt = i4
     1 res_chk = i2
     1 mpage_ind = i2
     1 qual[*]
       2 epr_id = f8
       2 prsnl_person_id = f8
   ) WITH persistscript
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr
    PLAN (epr
     WHERE epr.encntr_id=dencntr_id
      AND epr.encntr_prsnl_r_cd=dreltn_cd
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND epr.active_ind=1)
    DETAIL
     epr_qual->epr_cnt += 1, stat = alterlist(epr_qual->qual,epr_qual->epr_cnt), epr_qual->qual[
     epr_qual->epr_cnt].epr_id = epr.encntr_prsnl_reltn_id,
     epr_qual->qual[epr_qual->epr_cnt].prsnl_person_id = epr.prsnl_person_id
     IF (dprov_id=epr.prsnl_person_id)
      epr_qual->res_chk = true
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr
    PLAN (epr
     WHERE epr.encntr_id=dencntr_id
      AND epr.encntr_prsnl_r_cd=dreltn_cd
      AND epr.active_status_cd IN (48_active, 48_inactive)
      AND epr.contributor_system_cd=89_powerchart)
    DETAIL
     epr_qual->mpage_ind = true
    WITH nocounter
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE (PUBLIC::validatefxreltn(dencntr_id=f8,dprov_id=f8) =f8)
   DECLARE ep_mufx_id = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM lh_mu_fx_metrics mufx,
     lh_mu_ep_metrics_reltn epm,
     br_eligible_provider bep
    PLAN (mufx
     WHERE mufx.encntr_id=dencntr_id)
     JOIN (epm
     WHERE epm.lh_mu_fx_metrics_id=mufx.lh_mu_fx_metrics_id)
     JOIN (bep
     WHERE bep.br_eligible_provider_id=epm.br_eligible_provider_id
      AND bep.provider_id=dprov_id)
    DETAIL
     ep_mufx_id = epm.lh_mu_ep_metrics_reltn_id
    WITH nocounter
   ;end select
   RETURN(ep_mufx_id)
 END ;Subroutine
 SUBROUTINE (PUBLIC::validatefx2reltn(dencntr_id=f8,dprov_id=f8) =f8)
   DECLARE ep_mufx2_id = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM lh_mu_fx_2_metrics mufx2,
     lh_mu_fx_2_ep_reltn epm2,
     br_eligible_provider bep
    PLAN (mufx2
     WHERE mufx2.encntr_id=dencntr_id
      AND mufx2.parent_entity_name="ENCOUNTER"
      AND mufx2.lh_mu_fx_2_metrics_id != 0)
     JOIN (epm2
     WHERE epm2.lh_mu_fx_2_metrics_id=mufx2.lh_mu_fx_2_metrics_id)
     JOIN (bep
     WHERE bep.br_eligible_provider_id=epm2.br_eligible_provider_id
      AND bep.provider_id=dprov_id)
    DETAIL
     ep_mufx2_id = epm2.lh_mu_fx_2_ep_reltn_id
    WITH nocounter
   ;end select
   RETURN(ep_mufx2_id)
 END ;Subroutine
 SUBROUTINE (PUBLIC::validatecustomsettings(codeset=f8,encntrid=f8,cve_fieldparse=vc) =vc)
   DECLARE validateoutcome = vc
   SET cveparser = concat("cnvtupper(cve.field_name)= cnvtupper('",trim(cve_fieldparse),"')")
   SELECT INTO "nl:"
    cv_type = evaluate2(
     IF (cnvtupper(cv.cdf_meaning)="LOG_DOMAIN") 1
     ELSEIF (cnvtupper(cv.cdf_meaning)="ORG") 2
     ELSEIF (cnvtupper(cv.cdf_meaning)="LOC") 3
     ENDIF
     )
    FROM encounter e,
     code_value cv,
     code_value_extension cve
    PLAN (e
     WHERE e.encntr_id=encntrid)
     JOIN (cv
     WHERE cv.code_set=codeset
      AND cv.active_ind=1
      AND cv.cdf_meaning IN ("LOC", "ORG", "LOG_DOMAIN")
      AND ((cnvtreal(cv.definition)=e.organization_id) OR (((cnvtreal(cv.definition)=e
     .loc_nurse_unit_cd) OR ((cnvtreal(cv.definition)=
     (SELECT
      org.logical_domain_id
      FROM organization org
      WHERE org.organization_id=e.organization_id)))) )) )
     JOIN (cve
     WHERE cve.code_value=cv.code_value
      AND parser(cveparser))
    ORDER BY cv_type
    HEAD cv_type
     null
    DETAIL
     IF (isnumeric(cve.field_value)=1)
      validateoutcome = trim(cnvtstring(cve.field_value))
     ELSE
      validateoutcome = trim(cve.field_value)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(validateoutcome)
 END ;Subroutine
 SUBROUTINE (PUBLIC::gatherorglocations(orgparser=vc,nurseunitparser=vc,facparser=vc) =null WITH
  protect, copy)
   DECLARE 222_facility = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
   DECLARE 222_building = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
   DECLARE 222_ambulatory = f8 WITH constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
   DECLARE 222_nurseunit = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
   DECLARE 222_room = f8 WITH constant(uar_get_code_by("MEANING",222,"BED"))
   DECLARE 222_bed = f8 WITH constant(uar_get_code_by("MEANING",222,"ROOM"))
   DECLARE 222_waitroom = f8 WITH constant(uar_get_code_by("MEANING",222,"WAITROOM"))
   DECLARE lcnt = i2 WITH noconstant(0)
   IF (validate(facparser)=0)
    SET facparser = "1=1"
   ENDIF
   SELECT INTO "nl:"
    FROM organization org,
     location l,
     (left JOIN location_group lg1 ON lg1.parent_loc_cd=l.location_cd
      AND lg1.active_ind=1
      AND lg1.root_loc_cd=0),
     (left JOIN location l1 ON l1.location_cd=lg1.child_loc_cd
      AND l1.location_type_cd=222_building
      AND l1.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND l1.end_effective_dt_tm >= cnvtdatetime(sysdate)),
     (left JOIN location_group lg2 ON lg2.parent_loc_cd=lg1.child_loc_cd
      AND parser(nurseunitparser)
      AND lg2.active_ind=1
      AND lg2.root_loc_cd=0),
     (left JOIN location l2 ON l2.location_cd=lg2.child_loc_cd
      AND l2.location_type_cd IN (222_nurseunit, 222_ambulatory)
      AND l2.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND l2.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND l2.active_ind=1),
     (left JOIN location_group lg3 ON lg3.parent_loc_cd=lg2.child_loc_cd
      AND lg3.active_ind=1
      AND lg3.root_loc_cd=0),
     (left JOIN location l3 ON l3.location_cd=lg3.child_loc_cd
      AND l3.location_type_cd IN (222_room, 222_waitroom)
      AND l3.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND l3.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND l3.active_ind=1),
     (left JOIN location_group lg4 ON lg4.parent_loc_cd=lg3.child_loc_cd
      AND lg4.active_ind=1
      AND lg4.root_loc_cd=0),
     (left JOIN location l4 ON l4.location_cd=lg4.child_loc_cd
      AND l4.location_type_cd=222_bed
      AND l4.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND l4.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND l4.active_ind=1)
    PLAN (org
     WHERE parser(orgparser)
      AND org.active_ind=1)
     JOIN (l
     WHERE l.organization_id=org.organization_id
      AND l.active_ind=1
      AND l.location_type_cd=222_facility
      AND parser(facparser))
     JOIN (lg1)
     JOIN (l1)
     JOIN (lg2)
     JOIN (l2)
     JOIN (lg3)
     JOIN (l3)
     JOIN (lg4)
     JOIN (l4)
    ORDER BY l.location_cd, lg1.child_loc_cd, lg2.child_loc_cd,
     lg3.child_loc_cd
    HEAD REPORT
     lcnt = 0
    HEAD l.location_cd
     IF (nurseunitparser="1=1")
      lcnt += 1
      IF (mod(lcnt,5)=1)
       stat = alterlist(locs->llist,(lcnt+ 5))
      ENDIF
      locs->llist[lcnt].loc_cd = l.location_cd, locs->llist[lcnt].loc_name = uar_get_code_description
      (l.location_cd), locs->llist[lcnt].loc_type = l.location_type_cd
     ENDIF
    HEAD l1.location_cd
     IF (l1.location_cd > 0
      AND nurseunitparser="1=1")
      lcnt += 1
      IF (mod(lcnt,5)=1)
       stat = alterlist(locs->llist,(lcnt+ 5))
      ENDIF
      locs->llist[lcnt].loc_cd = lg1.child_loc_cd, locs->llist[lcnt].loc_name =
      uar_get_code_description(lg1.child_loc_cd), locs->llist[lcnt].loc_type = l1.location_type_cd
     ENDIF
    HEAD l2.location_cd
     IF (l2.location_cd > 0)
      lcnt += 1
      IF (mod(lcnt,5)=1)
       stat = alterlist(locs->llist,(lcnt+ 5))
      ENDIF
      locs->llist[lcnt].loc_cd = lg2.child_loc_cd, locs->llist[lcnt].loc_name =
      uar_get_code_description(lg2.child_loc_cd), locs->llist[lcnt].loc_type = l2.location_type_cd
     ENDIF
    HEAD l3.location_cd
     IF (l3.location_cd > 0)
      lcnt += 1
      IF (mod(lcnt,5)=1)
       stat = alterlist(locs->llist,(lcnt+ 5))
      ENDIF
      locs->llist[lcnt].loc_cd = lg3.child_loc_cd, locs->llist[lcnt].loc_name =
      uar_get_code_description(lg3.child_loc_cd), locs->llist[lcnt].loc_type = l3.location_type_cd
     ENDIF
    DETAIL
     IF (l4.location_cd > 0)
      lcnt += 1
      IF (mod(lcnt,5)=1)
       stat = alterlist(locs->llist,(lcnt+ 5))
      ENDIF
      locs->llist[lcnt].loc_cd = lg4.child_loc_cd, locs->llist[lcnt].loc_name =
      uar_get_code_description(lg4.child_loc_cd), locs->llist[lcnt].loc_type = l4.location_type_cd
     ELSE
      null
     ENDIF
    FOOT REPORT
     locs->lcnt = lcnt, stat = alterlist(locs->llist,lcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(ccps_records)))
  RECORD ccps_records(
    1 cnt = i4
    1 list[*]
      2 name = vc
    1 num = i4
  ) WITH persistscript
 ENDIF
 SUBROUTINE (PUBLIC::ispromptany(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::ispromptlist(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::ispromptsingle(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::ispromptempty(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::getpromptlist(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) =
  vc)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE option_str = vc WITH noconstant(""), private
   DECLARE return_val = vc WITH noconstant("0=1"), private
   IF (which_option=list_not_in)
    SET option_str = " NOT IN ("
   ELSE
    SET option_str = " IN ("
   ENDIF
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    SET return_val = concat("(",which_column,option_str)
    FOR (item_num = 1 TO count)
     IF (mod(item_num,1000)=1
      AND item_num > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     IF (substring(1,1,reflect(parameter(which_prompt,item_num)))="C")
      SET return_val = concat(return_val,"'",value(parameter(which_prompt,item_num)),"'",",")
     ELSE
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),",")
     ENDIF
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::getpromptvalues(which_prompt=i2) =vc)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE prompt_values = vc WITH protect, noconstant("(")
   DECLARE prompt_count = i4 WITH protect, noconstant(0)
   DECLARE prompt_idx = i4 WITH protect, noconstant(0)
   IF (ispromptlist(which_prompt))
    SET prompt_count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET prompt_count = 1
   ENDIF
   FOR (prompt_idx = 1 TO prompt_count)
    SET prompt_values = build(prompt_values,value(parameter(which_prompt,prompt_idx)))
    IF (((prompt_idx+ 1) <= prompt_count))
     SET prompt_values = build(prompt_values,",")
    ENDIF
   ENDFOR
   SET prompt_values = concat(prompt_values,")")
   RETURN(prompt_values)
 END ;Subroutine
 SUBROUTINE (PUBLIC::getpromptexpand(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)
  ) =vc)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (((ispromptlist(which_prompt)) OR (ispromptsingle(which_prompt))) )
    SET record_name = getpromptrecord(which_prompt,which_column)
    IF (textlen(trim(record_name,3)) > 0)
     SET return_val = createexpandparser(which_column,record_name,which_option)
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::getpromptrecord(which_prompt=i2,which_rec=vc) =vc)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH private, noconstant(0)
   DECLARE item_num = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE alias_parser = vc WITH private, noconstant(" ")
   DECLARE cnt_parser = vc WITH private, noconstant(" ")
   DECLARE alterlist_parser = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF ((( NOT (ispromptany(which_prompt))) OR ( NOT (ispromptempty(which_prompt)))) )
    SET record_name = createrecord(which_rec)
    IF (textlen(trim(record_name,3)) > 0)
     IF (ispromptlist(which_prompt))
      SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
     ELSEIF (ispromptsingle(which_prompt))
      SET count = 1
     ENDIF
     IF (count > 0)
      SET alias_parser = concat("set curalias = which_rec_alias ",record_name,"->list[idx] go")
      SET cnt_parser = build2("set ",record_name,"->cnt = ",count," go")
      SET alterlist_parser = build2("set stat = alterlist(",record_name,"->list,",record_name,
       "->cnt) go")
      SET data_type = cnvtupper(substring(1,1,reflect(parameter(which_prompt,1))))
      SET data_type_parser = concat("set ",record_name,"->data_type = '",data_type,"' go")
      CALL parser(alias_parser)
      CALL parser(cnt_parser)
      CALL parser(alterlist_parser)
      CALL parser(data_type_parser)
      FOR (item_num = 1 TO count)
       SET idx += 1
       CASE (data_type)
        OF "I":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "F":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "C":
         SET which_rec_alias->string = value(parameter(which_prompt,item_num))
       ENDCASE
      ENDFOR
      SET cnt_parser = concat(record_name,"->cnt")
      IF (validate(parser(cnt_parser),0) > 0)
       SET return_val = record_name
      ENDIF
      SET alias_parser = concat("set curalias which_rec_alias off go")
      CALL parser(alias_parser)
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::createrecord(which_rec=vc(value,"")) =vc)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE record_parser = vc WITH private, noconstant(" ")
   DECLARE new_record_ind = i2 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF (textlen(trim(which_rec,3)) > 0)
    IF (findstring(".",which_rec,1,0) > 0)
     SET record_name = concat("ccps_",trim(which_rec,3),"_rec")
    ELSE
     SET record_name = trim(which_rec,3)
    ENDIF
   ELSE
    SET record_name = build("ccps_temp_",(ccps_records->cnt+ 1),"_rec")
   ENDIF
   SET record_name = concat(trim(replace(record_name,concat(
       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 !"#$%&',
       "'()*+,-./:;<=>?@[\]^_`{|}~"),concat(
       "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_______",
       "__________________________"),3),3))
   IF ( NOT (validate(parser(record_name))))
    SET record_parser = concat("record ",record_name," (1 cnt = i4",
     " 1 list[*] 2 string = vc 2 number = f8"," 1 data_type = c1 1 num = i4)",
     " with persistscript go")
    CALL parser(record_parser)
    IF (validate(parser(record_name)))
     SET return_val = record_name
     SET ccps_records->cnt += 1
     SET stat = alterlist(ccps_records->list,ccps_records->cnt)
     SET ccps_records->list[ccps_records->cnt].name = record_name
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (PUBLIC::createexpandparser(which_column=vc,which_rec=vc,which_option=i2(value,list_in)
  ) =vc)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE record_member = vc WITH private, noconstant(" ")
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   IF (validate(parser(which_rec)))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET data_type_parser = concat("set data_type = ",which_rec,"->data_type go")
    CALL parser(data_type_parser)
    CASE (data_type)
     OF "I":
      SET record_member = "number"
     OF "F":
      SET record_member = "number"
     OF "C":
      SET record_member = "string"
    ENDCASE
    SET return_val = build(option_str," expand(",which_rec,"->num",",",
     "1,",which_rec,"->cnt,",which_column,",",
     which_rec,"->list[",which_rec,"->num].",record_member,
     ")")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE 212_home = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE us_ph_format = f8 WITH protect, constant(uar_get_code_by("MEANING",281,"US"))
 DECLARE 43_home = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE 43_cell = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"CELL"))
 DECLARE 43_mobile = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE email_type = f8 WITH protect, constant(uar_get_code_by("MEANING",23056,"MAILTO"))
 DECLARE 367_medicare = f8 WITH protect, constant(uar_get_code_by("MEANING",367,"MEDICARE"))
 DECLARE 331_pcp = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
 DECLARE 57_female = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2774"))
 DECLARE 57_male = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2773"))
 DECLARE 4_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2623"))
 DECLARE start_date = dq8 WITH protect, constant(cnvtlookbehind( $LOOKBACK_RANGE))
 DECLARE report_name = vc WITH protect, constant("amb_medicare_pop_detail")
 DECLARE display_org = vc WITH protect, noconstant("")
 DECLARE display_location = vc WITH protect, noconstant("")
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(20)
 DECLARE record_size = i4 WITH protect, noconstant(0)
 DECLARE batch_cnt = i4 WITH protect, noconstant(0)
 DECLARE numpersons = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(0)
 DECLARE expand_stop = i4 WITH protect, noconstant(0)
 SUBROUTINE PUBLIC::getorgparser(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("getOrgParser")
   ENDIF
   DECLARE org_parser = vc WITH protect, noconstant("")
   IF (isnumeric( $ORG_ID) > 0)
    IF (validate(debug_ind,0)=1)
     CALL echo("single org")
    ENDIF
    SET display_org = getorgname(null)
    SET org_parser = concat("org.organization_id = ",cnvtstring( $ORG_ID))
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo("all orgs")
    ENDIF
    SET display_org = "All User Associated Organizations"
    SET org_parser =
"org.organization_id IN (select por.organization_id             from prsnl_org_reltn por,              organization o      \
         where por.person_id  = reqinfo->updt_id               and por.beg_effective_dt_tm < cnvtdatetime(curdate, curtime\
3)               and por.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)               and por.active_ind = 1 )\
"
   ENDIF
   RETURN(org_parser)
 END ;Subroutine
 SUBROUTINE PUBLIC::getorgname(null)
   DECLARE org_name = vc WITH protect, noconstant("")
   IF (validate(debug_ind,0)=1)
    CALL echo("inside getOrgName")
   ENDIF
   SELECT INTO "nl:"
    FROM organization o
    WHERE (o.organization_id= $ORG_ID)
    DETAIL
     org_name = substring(1,100,trim(o.org_name))
    WITH nocounter
   ;end select
   RETURN(org_name)
 END ;Subroutine
 SUBROUTINE PUBLIC::getlocparser(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("getLocParser")
   ENDIF
   DECLARE loc_parser = vc WITH protect, noconstant("")
   IF (isnumeric( $LOC_CD) > 0)
    IF (validate(debug_ind,0)=1)
     CALL echo("single location")
    ENDIF
    SELECT INTO "nl:"
     FROM location l
     WHERE (l.location_cd= $LOC_CD)
     DETAIL
      display_location = substring(1,100,trim(uar_get_code_display(l.location_cd)))
     WITH nocounter
    ;end select
    SET loc_parser = concat("lg2.child_loc_cd = ",cnvtstring( $LOC_CD))
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo("all locations")
    ENDIF
    SET display_location = "All Locations"
    SET loc_parser = "1=1"
   ENDIF
   RETURN(loc_parser)
 END ;Subroutine
 SUBROUTINE PUBLIC::gethpparser(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("getHpParser")
   ENDIF
   DECLARE hp_parser = vc WITH protect, noconstant("")
   IF ((locs->lcnt > 0))
    IF (operator(trim( $HEALTHPLANCDS,7),"REGEXPLIKE","^\([0-9,. ]+\)$")=1)
     SET hp_parser = concat("hp.health_plan_id in ", $HEALTHPLANCDS)
    ELSEIF (ispromptempty(7)=0)
     IF (ispromptsingle(7))
      IF (validate(debug_ind,0)=1)
       CALL echo("single")
      ENDIF
      SET hp_parser = concat("hp.health_plan_id = ",cnvtstring( $HEALTHPLANS))
     ELSE
      IF (validate(debug_ind,0)=1)
       CALL echo("multiple")
      ENDIF
      SET hp_parser = replace(getpromptlist(7,"hp.health_plan_id"),"'","")
     ENDIF
    ELSE
     IF (validate(debug_ind,0)=1)
      CALL echo("No health plans selected")
     ENDIF
     SELECT INTO  $OUTDEV
      FROM (dummyt d  WITH seq = 1)
      PLAN (d)
      HEAD REPORT
       row + 1, col 1, "No health plans selected"
      WITH nocounter
     ;end select
     GO TO exit_script
    ENDIF
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo("No locations selected")
    ENDIF
    SELECT INTO  $OUTDEV
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     HEAD REPORT
      row + 1, col 1, "No locations selected"
     WITH nocounter
    ;end select
    GO TO exit_script
   ENDIF
   RETURN(hp_parser)
 END ;Subroutine
 SUBROUTINE PUBLIC::gatheraddress(null)
  IF (validate(debug_ind,0)=1)
   CALL echo("gatherAddress")
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = batch_cnt),
    address a
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ batch_size)))
     AND assign(expand_stop,(expand_start+ (batch_size - 1))))
    JOIN (a
    WHERE expand(numpersons,expand_start,expand_stop,a.parent_entity_id,main_pop->plist[numpersons].
     pers_id)
     AND a.parent_entity_name="PERSON"
     AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND a.active_ind=1
     AND a.address_type_cd=212_home)
   ORDER BY a.parent_entity_id, a.address_type_seq, a.beg_effective_dt_tm DESC
   HEAD REPORT
    cur_seq = 0
   HEAD a.parent_entity_id
    cur_pos = 0, cur_pos = locateval(cur_seq,1,main_pop->medicare_pop,a.parent_entity_id,main_pop->
     plist[cur_seq].pers_id)
    IF (cur_pos > 0)
     main_pop->plist[cur_pos].address1 = trim(a.street_addr), main_pop->plist[cur_pos].address2 =
     trim(a.street_addr2), main_pop->plist[cur_pos].zipcode = trim(a.zipcode)
     IF (a.city_cd > 0.0)
      main_pop->plist[cur_pos].city = trim(uar_get_code_display(a.city_cd))
     ELSE
      main_pop->plist[cur_pos].city = a.city
     ENDIF
     IF (a.state_cd > 0.0)
      main_pop->plist[cur_pos].state = trim(uar_get_code_display(a.state_cd))
     ELSE
      main_pop->plist[cur_pos].state = trim(a.state)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::gatherphone(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("gatherPhone")
   ENDIF
   DECLARE cell_stored_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = batch_cnt),
     phone ph
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ batch_size)))
      AND assign(expand_stop,(expand_start+ (batch_size - 1))))
     JOIN (ph
     WHERE expand(numpersons,expand_start,expand_stop,ph.parent_entity_id,main_pop->plist[numpersons]
      .pers_id)
      AND ph.parent_entity_name="PERSO*"
      AND ph.contact_method_cd != email_type
      AND ph.phone_type_cd IN (43_home, 43_cell, 43_mobile)
      AND ph.phone_type_seq=1
      AND ph.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND ph.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ph.active_ind=1)
    ORDER BY ph.parent_entity_id, ph.phone_type_cd, ph.beg_effective_dt_tm DESC
    HEAD REPORT
     cur_seq = 0
    HEAD ph.parent_entity_id
     cur_pos = 0, cur_pos = locateval(cur_seq,1,main_pop->medicare_pop,ph.parent_entity_id,main_pop->
      plist[cur_seq].pers_id), cell_stored_ind = 0
    HEAD ph.phone_type_cd
     IF (ph.phone_type_cd=43_home)
      IF (cur_pos > 0)
       IF (ph.phone_format_cd=0.0)
        IF (ph.phone_num_key != null)
         main_pop->plist[cur_pos].phone = cnvtphone(ph.phone_num_key,us_ph_format)
        ELSE
         main_pop->plist[cur_pos].phone = cnvtphone(ph.phone_num,us_ph_format)
        ENDIF
       ELSE
        IF (ph.phone_num_key != null)
         main_pop->plist[cur_pos].phone = cnvtphone(ph.phone_num_key,ph.phone_format_cd)
        ELSE
         main_pop->plist[cur_pos].phone = cnvtphone(ph.phone_num,ph.phone_format_cd)
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (ph.phone_type_cd IN (43_cell, 43_mobile)
      AND cell_stored_ind=0)
      IF (cur_pos > 0)
       IF (ph.phone_format_cd=0.0)
        IF (ph.phone_num_key != null)
         main_pop->plist[cur_pos].cell_phone = cnvtphone(ph.phone_num_key,us_ph_format)
        ELSE
         main_pop->plist[cur_pos].cell_phone = cnvtphone(ph.phone_num,us_ph_format)
        ENDIF
       ELSE
        IF (ph.phone_num_key != null)
         main_pop->plist[cur_pos].cell_phone = cnvtphone(ph.phone_num_key,ph.phone_format_cd)
        ELSE
         main_pop->plist[cur_pos].cell_phone = cnvtphone(ph.phone_num,ph.phone_format_cd)
        ENDIF
       ENDIF
       cell_stored_ind = 1
      ENDIF
     ENDIF
    FOOT  ph.phone_type_cd
     null
    FOOT  ph.parent_entity_id
     null
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::gathermrn(null)
  IF (validate(debug_ind,0)=1)
   CALL echo("gatherMRN")
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = batch_cnt),
    person_alias pa
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ batch_size)))
     AND assign(expand_stop,(expand_start+ (batch_size - 1))))
    JOIN (pa
    WHERE expand(numpersons,expand_start,expand_stop,pa.person_id,main_pop->plist[numpersons].pers_id
     )
     AND pa.person_alias_type_cd=4_mrn
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY pa.person_id, pa.person_alias_type_cd, pa.beg_effective_dt_tm DESC
   HEAD REPORT
    cur_seq = 0
   HEAD pa.person_id
    cur_pos = 0, cur_pos = locateval(cur_seq,1,main_pop->medicare_pop,pa.person_id,main_pop->plist[
     cur_seq].pers_id)
    IF (cur_pos > 0)
     main_pop->plist[cur_pos].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::gatherpcp(null)
  IF (validate(debug_ind,0)=1)
   CALL echo("gatherPCP")
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = batch_cnt),
    person_prsnl_reltn ppr,
    prsnl pr
   PLAN (d
    WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ batch_size)))
     AND assign(expand_stop,(expand_start+ (batch_size - 1))))
    JOIN (ppr
    WHERE expand(numpersons,expand_start,expand_stop,ppr.person_id,main_pop->plist[numpersons].
     pers_id)
     AND ppr.person_prsnl_r_cd=331_pcp
     AND ppr.active_ind=1
     AND ((cnvtdatetime(sysdate) BETWEEN ppr.beg_effective_dt_tm AND ppr.end_effective_dt_tm) OR (
    cnvtdatetime(sysdate) > ppr.beg_effective_dt_tm
     AND ppr.end_effective_dt_tm = null)) )
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(ppr.prsnl_person_id)) )
   ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
   HEAD REPORT
    cur_seq = 0
   HEAD ppr.person_id
    cur_pos = 0, cur_pos = locateval(cur_seq,1,main_pop->medicare_pop,ppr.person_id,main_pop->plist[
     cur_seq].pers_id)
    IF (ppr.prsnl_person_id != 0)
     main_pop->plist[cur_pos].pcp = trim(pr.name_full_formatted,3)
    ELSE
     main_pop->plist[cur_pos].pcp = trim(ppr.ft_prsnl_name)
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (PUBLIC::gathermedicarepop(hpparser=vc) =i4 WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("gatherMedicarePop hpparser:",hpparser))
   ENDIF
   DECLARE seq_encpop = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM health_plan hp,
     person_plan_reltn ppr,
     person p,
     encounter e
    PLAN (hp
     WHERE parser(hpparser)
      AND hp.active_ind=1
      AND hp.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ppr
     WHERE ppr.health_plan_id=hp.health_plan_id
      AND ppr.active_ind=1
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=ppr.person_id)
     JOIN (e
     WHERE e.person_id=p.person_id
      AND expand(seq_encpop,1,locs->lcnt,e.location_cd,locs->llist[seq_encpop].loc_cd)
      AND e.active_ind=1
      AND e.reg_dt_tm > cnvtdatetime(start_date))
    ORDER BY p.person_id, e.reg_dt_tm DESC
    HEAD REPORT
     pcnt = 0
    HEAD p.person_id
     pcnt += 1
     IF (mod(pcnt,100)=1)
      stat = alterlist(main_pop->plist,(pcnt+ 99))
     ENDIF
     main_pop->plist[pcnt].name = trim(p.name_full_formatted), main_pop->plist[pcnt].fname = trim(p
      .name_first), main_pop->plist[pcnt].mname = trim(p.name_middle),
     main_pop->plist[pcnt].lname = trim(p.name_last), main_pop->plist[pcnt].medicareid = trim(ppr
      .member_nbr), main_pop->plist[pcnt].dob = datetimezoneformat(p.birth_dt_tm,p.birth_tz,
      "MM/dd/yyyy"),
     main_pop->plist[pcnt].gender = uar_get_code_display(p.sex_cd), main_pop->plist[pcnt].gender_cd
      = p.sex_cd, main_pop->plist[pcnt].pers_id = p.person_id,
     main_pop->plist[pcnt].encntr_id = e.encntr_id, main_pop->plist[pcnt].loc_cd = e.location_cd,
     main_pop->plist[pcnt].reg_date = format(e.reg_dt_tm,"MM/DD/YY;;d"),
     main_pop->plist[pcnt].location = uar_get_code_display(e.location_cd), main_pop->plist[pcnt].
     nurse_unit_cd = e.loc_nurse_unit_cd, main_pop->plist[pcnt].nurse_unit = uar_get_code_display(e
      .loc_nurse_unit_cd)
    FOOT REPORT
     main_pop->medicare_pop = pcnt, stat = alterlist(main_pop->plist,pcnt)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::cleanmedicarepop(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("cleanMedicarePop")
   ENDIF
   DECLARE popidx = i4 WITH protect, noconstant(1)
   WHILE (popidx <= size(main_pop->plist,5)
    AND size(main_pop->plist,5) > 0)
     IF (((textlen(trim(main_pop->plist[popidx].fname,3))=0) OR (((textlen(trim(main_pop->plist[
       popidx].lname,3))=0) OR (((textlen(trim(main_pop->plist[popidx].phone,3))=0) OR (((checkgender
     (popidx)=0) OR (((checkmednumber(popidx)=0) OR (checkzip(popidx)=0)) )) )) )) )) )
      CALL movemedicarepop(popidx)
     ELSE
      SET popidx += 1
     ENDIF
   ENDWHILE
   SET main_pop->medicare_pop = size(main_pop->plist,5)
 END ;Subroutine
 SUBROUTINE (PUBLIC::checkgender(popidx=i4) =i2 WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("checkGender popIdx: ",popidx))
   ENDIF
   DECLARE validgender = i2 WITH protect, noconstant(0)
   DECLARE gender = vc WITH protect, constant(trim(main_pop->plist[popidx].gender,3))
   IF (textlen(gender) > 0
    AND ((gender="M") OR (((gender="F") OR (((gender="Male") OR (((gender="male") OR (((gender=
   "Female") OR (gender="female")) )) )) )) )) )
    SET validgender = 1
   ENDIF
   RETURN(validgender)
 END ;Subroutine
 SUBROUTINE (PUBLIC::checkmednumber(popidx=i4) =i2 WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("checkMedNumber popIdx: ",popidx))
   ENDIF
   DECLARE validmednumber = i2 WITH protect, noconstant(0)
   DECLARE mednumber = vc WITH protect, noconstant(main_pop->plist[popidx].medicareid)
   SET mednumber = replace(mednumber," ","")
   SET mednumber = replace(mednumber,"-","")
   IF (((operator(mednumber,"REGEXPLIKE","[0-9]{8}A")=1) OR (operator(mednumber,"REGEXPLIKE",
    "A[0-9]{10}")=1)) )
    SET validmednumber = 1
    SET main_pop->plist[popidx].medicareid = mednumber
   ENDIF
   RETURN(validmednumber)
 END ;Subroutine
 SUBROUTINE (PUBLIC::checkzip(popidx=i4) =i2 WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("checkZip popIdx: ",popidx))
   ENDIF
   DECLARE validzip = i2 WITH protect, noconstant(0)
   DECLARE zip = vc WITH protect, noconstant(main_pop->plist[popidx].zipcode)
   SET zip = replace(zip," ","")
   SET zip = replace(zip,"-","")
   IF (((textlen(zip)=5) OR (textlen(zip)=9)) )
    SET validzip = 1
    SET main_pop->plist[popidx].zipcode = zip
   ENDIF
   RETURN(validzip)
 END ;Subroutine
 SUBROUTINE (PUBLIC::movemedicarepop(popidx=i4) =null WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("moveMedicarePop popIdx: ",popidx))
   ENDIF
   SET stat = movereclist(main_pop->plist,pop_to_fix->plist,popidx,size(pop_to_fix->plist,5),1,
    true)
   SET stat = alterlist(main_pop->plist,(size(main_pop->plist,5) - 1),(popidx - 1))
 END ;Subroutine
 SUBROUTINE PUBLIC::getbatchsize(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("getBatchSize")
   ENDIF
   DECLARE oidx = i4 WITH protect, noconstant(0)
   SET record_size = main_pop->medicare_pop
   IF (mod(record_size,batch_size) != 0)
    SET stat = alterlist(main_pop->plist,value((record_size+ (batch_size - mod(record_size,batch_size
       )))))
    SET record_size = size(main_pop->plist,5)
    FOR (oidx = (main_pop->medicare_pop+ 1) TO record_size)
      SET main_pop->plist[oidx].pers_id = main_pop->plist[main_pop->medicare_pop].pers_id
    ENDFOR
   ENDIF
   SET batch_cnt = ceil((cnvtreal(record_size)/ batch_size))
   SET numpersons = 0
   SET expand_start = 1
   SET expand_stop = batch_size
   IF (validate(debug_ind,0)=1)
    CALL echo(build("batch_cnt: ",trim(cnvtstring(batch_cnt))))
   ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::getparam(param=vc) =vc WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("getParam param:",param))
   ENDIF
   DECLARE formattedparam = vc WITH protect, noconstant("")
   IF (isnumeric(param))
    SET formattedparam = build(param)
   ELSE
    SET formattedparam = build("^",param,"^")
   ENDIF
   RETURN(formattedparam)
 END ;Subroutine
 SUBROUTINE PUBLIC::getparams(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("getParams")
   ENDIF
   DECLARE params = vc WITH protect, noconstant("")
   SET params = build2(report_name," ","^",buildfilename(null),"^",
    ",^", $LOOKBACK_RANGE,"^",",",getparam( $ORG_ID),
    ",",getparam( $LOC_CD),",^^",",^^",",0",
    ",^0^",",^^",",^",getpromptvalues(7),"^")
   SET params = replace(params,".000000",".0")
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("params: ",params))
   ENDIF
   RETURN(params)
 END ;Subroutine
 SUBROUTINE PUBLIC::buildfilename(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("buildFileName")
   ENDIF
   DECLARE file_name = vc WITH protect, noconstant("")
   DECLARE org_name = vc WITH protect, noconstant("")
   DECLARE validated_client_mnemonic = vc WITH protect, constant(replace( $CLIENT_MNEMONIC," ","_",0)
    )
   IF (isnumeric( $ORG_ID) > 0)
    SET org_name = replace(trim(substring(1,30,getorgname(null)))," ","_",0)
    SET file_name = build2("PCA_",validated_client_mnemonic,"_",org_name)
   ELSE
    SET file_name = build2("PCA_",validated_client_mnemonic)
   ENDIF
   RETURN(file_name)
 END ;Subroutine
 SUBROUTINE (PUBLIC::outputtodevice(devicename=vc) =null WITH protect)
  IF (validate(debug_ind,0)=1)
   CALL echo("outputToDevice")
  ENDIF
  SELECT INTO
   IF (validate(request->qual[1].parameter,"")="MINE") value(devicename)
   ELSE value(build2(devicename,"_",format(cnvtdatetime(sysdate),"YYYYMMDD;;d"),".csv"))
   ENDIF
   firstname = substring(1,50,main_pop->plist[d1.seq].fname), middlename = substring(1,50,main_pop->
    plist[d1.seq].mname), lastname = substring(1,50,main_pop->plist[d1.seq].lname),
   patient_full_name = substring(1,100,main_pop->plist[d1.seq].name), dob = substring(1,15,main_pop->
    plist[d1.seq].dob), gender = substring(1,15,main_pop->plist[d1.seq].gender),
   medicareid = substring(1,25,main_pop->plist[d1.seq].medicareid), address1 = substring(1,50,
    main_pop->plist[d1.seq].address1), address2 = substring(1,50,main_pop->plist[d1.seq].address2),
   city = substring(1,50,main_pop->plist[d1.seq].city), state = substring(1,50,main_pop->plist[d1.seq
    ].state), zip = substring(1,50,main_pop->plist[d1.seq].zipcode),
   patientid = substring(1,20,main_pop->plist[d1.seq].mrn), phone = substring(1,20,main_pop->plist[d1
    .seq].phone), cellphone = substring(1,20,main_pop->plist[d1.seq].cell_phone),
   physician = substring(1,100,main_pop->plist[d1.seq].pcp), location = substring(1,100,
    display_location)
   FROM (dummyt d1  WITH seq = size(main_pop->plist,5))
   PLAN (d1)
   WITH nocounter, pcformat('""',"|",1), format = stream,
    format
  ;end select
 END ;Subroutine
 SUBROUTINE PUBLIC::exitifzeropatients(null)
  IF (validate(debug_ind,0)=1)
   CALL echo("exitIfZeroPatients")
  ENDIF
  IF (size(main_pop->plist,5)=0)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     row + 1, col 1, "No Medicare patients found"
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::outputparams(params=vc) =null WITH protect)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("outputParams params:",params))
   ENDIF
   RECORD paramlines(
     1 lines[*]
       2 line = vc
   ) WITH protect
   DECLARE lineidx = i4 WITH protect, noconstant(0)
   DECLARE charidx = i4 WITH protect, noconstant(1)
   DECLARE maxlinelen = f8 WITH protect, constant((maxcol - 1))
   DECLARE maxlineleni4 = i4 WITH protect, constant(maxlinelen)
   DECLARE linecount = i4 WITH protect, constant(ceil((textlen(params)/ maxlinelen)))
   SET stat = alterlist(paramlines->lines,linecount)
   FOR (lineidx = 1 TO linecount)
    SET paramlines->lines[lineidx].line = substring(charidx,maxlineleni4,params)
    SET charidx += maxlineleni4
   ENDFOR
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = linecount)
    PLAN (d)
    DETAIL
     row + 1, col 0, paramlines->lines[d.seq].line
    WITH nocounter
   ;end select
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE PUBLIC::main(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("Main")
   ENDIF
   IF (( $OUTPUT_PARAMS="1"))
    CALL outputparams(getparams(null))
   ENDIF
   DECLARE orgparser = vc WITH protect, constant(getorgparser(null))
   DECLARE locparser = vc WITH protect, constant(getlocparser(null))
   CALL gatherorglocations(orgparser,locparser,"1=1")
   CALL gathermedicarepop(gethpparser(null))
   CALL exitifzeropatients(null)
   CALL getbatchsize(null)
   CALL gatheraddress(null)
   CALL gatherphone(null)
   CALL gathermrn(null)
   CALL gatherpcp(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("main_pop after gathering:")
    CALL echorecord(main_pop)
   ENDIF
   CALL cleanmedicarepop(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("main_pop after gathering and cleaning:")
    CALL echorecord(main_pop)
   ENDIF
   CALL exitifzeropatients(null)
   CALL outputtodevice( $OUTDEV)
 END ;Subroutine
 CALL main(null)
#exit_script
 FREE RECORD main_pop
END GO
