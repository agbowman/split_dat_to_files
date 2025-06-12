CREATE PROGRAM dcp_get_genview_insurance:dba
 SET rhead =
 "{\rtf1\ansi \deff0{\fonttbl{\f0\fswissArial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET temp_disp1 = fillstring(200," ")
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 RECORD dispa(
   1 display1 = vc
   1 spaces1 = vc
   1 display2 = vc
 )
 RECORD tempa(
   1 encntr_id = f8
   1 person_id = f8
   1 fin_class = vc
   1 emg_contact = vc
   1 fin_nbr = vc
   1 contact_home_phon_nbr = vc
   1 contact_bus_phon_nbr = vc
   1 cont_relt_to_pat = vc
   1 nok = vc
   1 nok_relt_to_pat = vc
   1 nok_address = vc
   1 icnt = i4
   1 qual[*]
     2 ins_comp_name = vc
     2 effective_dt_from = dq8
     2 plan_id = vc
     2 insured_name = vc
     2 insured_ssn = vc
     2 insured_relt_to_pat = vc
     2 auth_nbr = vc
     2 person_id = f8
     2 ins_comp_cont_phone_nbr = vc
     2 group_number = vc
     2 effective_dt_to = dq8
     2 contact_person_name = vc
   1 nok_csz = vc
   1 nok_phone_nbr = vc
   1 guarantor = vc
   1 guar_relt_to_pat = vc
   1 guar_address = vc
   1 guar_csz = vc
   1 guar_phone = vc
 )
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_alias_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_phone_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_phone_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_address_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_address_cd = code_value
 SET code_set = 338
 SET cdf_meaning = "INSURANCE CO"
 EXECUTE cpm_get_cd_for_cdf
 SET org_insur_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "INSURED"
 EXECUTE cpm_get_cd_for_cdf
 SET insured_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "EMC"
 EXECUTE cpm_get_cd_for_cdf
 SET emc_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "FAMILY"
 EXECUTE cpm_get_cd_for_cdf
 SET family_cd = code_value
 SET code_set = 351
 SET cdf_meaning = "DEFGUAR"
 EXECUTE cpm_get_cd_for_cdf
 SET def_guar_cd = code_value
 SET code_set = 370
 SET cdf_meaning = "SPONSOR"
 EXECUTE cpm_get_cd_for_cdf
 SET sponsor_cd = code_value
 SET disp_label1 = fillstring(40," ")
 SET disp_label2 = fillstring(80," ")
 SET disp_value1 = fillstring(80," ")
 SET disp_value2 = fillstring(80," ")
 SET tmp_display1 = fillstring(10," ")
 SET tmp_display2 = fillstring(10," ")
 SET tmp_display = fillstring(80," ")
 SET start_value_space = fillstring(5," ")
 SET start_label_space = fillstring(1," ")
 SET mid_value_space = fillstring(8," ")
 SET mid_label_space = fillstring(15," ")
 SET visit_cnt = 1
 FOR (x = 1 TO visit_cnt)
   SELECT INTO "nl"
    e.encntr_id, ea.encntr_id
    FROM encounter e,
     (dummyt d1  WITH seq = 1),
     encntr_alias ea
    PLAN (e
     WHERE (e.encntr_id=request->visit[x].encntr_id))
     JOIN (d1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=finnbr_cd
      AND ea.active_ind=1)
    DETAIL
     tempa->encntr_id = e.encntr_id, tempa->person_id = e.person_id
     IF (ea.alias_pool_cd > 0)
      tempa->fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      tempa->fin_nbr = trim(ea.alias)
     ENDIF
     tempa->fin_class = uar_get_code_display(e.financial_class_cd)
    WITH outerjoin = d1, nocounter
   ;end select
   SET tempa->icnt = 0
   SET stat = alterlist(tempa->qual,1)
   SELECT INTO "nl:"
    epr.encntr_id, hp.health_plan_id, ph.parent_entity_id,
    opr.health_plan_id, au.authorization_id, o.organization_id
    FROM encntr_plan_reltn epr,
     health_plan hp,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1),
     authorization au,
     phone ph,
     org_plan_reltn opr,
     (dummyt d3  WITH seq = 1),
     org_plan_reltn opr2,
     organization o
    PLAN (epr
     WHERE (epr.encntr_id=tempa->encntr_id)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (hp
     WHERE hp.health_plan_id=epr.health_plan_id
      AND hp.active_ind=1)
     JOIN (opr
     WHERE opr.health_plan_id=hp.health_plan_id
      AND opr.organization_id=epr.organization_id
      AND opr.active_ind=1
      AND opr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND opr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (o
     WHERE o.organization_id=opr.organization_id)
     JOIN (d3)
     JOIN (opr2
     WHERE opr2.health_plan_id=hp.health_plan_id
      AND opr2.org_plan_reltn_cd=sponsor_cd
      AND opr2.active_ind=1
      AND opr2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND opr2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (d1)
     JOIN (ph
     WHERE ph.parent_entity_id=o.organization_id
      AND ph.parent_entity_name="ORGANIZATION"
      AND ph.phone_type_cd=bus_phone_cd
      AND ph.active_ind=1
      AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (d2)
     JOIN (au
     WHERE (au.person_id=tempa->person_id)
      AND (au.encntr_id=tempa->encntr_id)
      AND au.health_plan_id=hp.health_plan_id
      AND au.active_ind=1
      AND au.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND au.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY epr.priority_seq
    DETAIL
     tempa->icnt = (tempa->icnt+ 1), stat = alterlist(tempa->qual,tempa->icnt), tempa->qual[tempa->
     icnt].person_id = epr.person_id,
     tempa->qual[tempa->icnt].ins_comp_name = o.org_name, tempa->qual[tempa->icnt].group_number =
     opr2.group_nbr, tempa->qual[tempa->icnt].plan_id = epr.member_nbr,
     tempa->qual[tempa->icnt].auth_nbr = trim(au.auth_nbr), tempa->qual[tempa->icnt].
     effective_dt_from = epr.beg_effective_dt_tm, tempa->qual[tempa->icnt].effective_dt_to = epr
     .end_effective_dt_tm
     IF (ph.phone_format_cd > 0)
      tempa->qual[tempa->icnt].ins_comp_cont_phone_nbr = cnvtphone(trim(ph.phone_num),ph
       .phone_format_cd)
     ELSE
      tempa->qual[tempa->icnt].ins_comp_cont_phone_nbr = trim(ph.phone_num)
     ENDIF
    WITH nocounter, outerjoin = d3, dontcare = opr2,
     outerjoin = d1, outerjoin = d2, dontcare = ph
   ;end select
   SELECT INTO "nl:"
    epr.encntr_id, ph.phone_id, pa.person_id,
    a.address_id
    FROM encntr_person_reltn epr,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     address a,
     person_alias pa,
     phone ph
    PLAN (epr
     WHERE (epr.encntr_id=tempa->encntr_id)
      AND epr.person_reltn_type_cd IN (insured_cd, emc_cd, family_cd, def_guar_cd)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (d1)
     JOIN (ph
     WHERE ph.parent_entity_id=epr.related_person_id
      AND ph.parent_entity_name="PERSON"
      AND ph.phone_type_cd IN (bus_phone_cd, home_phone_cd)
      AND ph.active_ind=1
      AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (d2)
     JOIN (a
     WHERE a.parent_entity_id=epr.related_person_id
      AND a.parent_entity_name="PERSON"
      AND a.address_type_cd=home_address_cd
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (d3)
     JOIN (pa
     WHERE pa.person_id=epr.related_person_id
      AND pa.person_alias_type_cd IN (ssn_alias_cd)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    HEAD REPORT
     defguar_ind = 0, emc_ind = 0, family_ind = 0
    DETAIL
     IF (epr.person_reltn_type_cd=insured_cd)
      IF ((tempa->icnt > 0))
       FOR (xx = 1 TO tempa->icnt)
         IF ((tempa->qual[xx].person_id=epr.related_person_id))
          tempa->qual[xx].insured_name = epr.ft_rel_person_name, tempa->qual[xx].insured_relt_to_pat
           = uar_get_code_display(epr.person_reltn_cd)
          IF (pa.person_alias_type_cd=ssn_alias_cd)
           IF (pa.alias_pool_cd > 0)
            tempa->qual[xx].insured_ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
           ELSE
            tempa->qual[xx].insured_ssn = pa.alias
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF (epr.person_reltn_type_cd=emc_cd)
      IF (emc_ind=0)
       tempa->emg_contact = epr.ft_rel_person_name, tempa->cont_relt_to_pat = uar_get_code_display(
        epr.person_reltn_cd), emc_ind = 1
      ENDIF
      IF (ph.phone_type_cd=home_phone_cd)
       IF (ph.phone_format_cd > 0)
        tempa->contact_home_phon_nbr = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSE
        tempa->contact_home_phon_nbr = trim(ph.phone_num)
       ENDIF
      ENDIF
      IF (ph.phone_type_cd=bus_phone_cd)
       IF (ph.phone_format_cd > 0)
        tempa->contact_bus_phon_nbr = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSE
        tempa->contact_bus_phon_nbr = trim(ph.phone_num)
       ENDIF
      ENDIF
     ELSEIF (epr.person_reltn_type_cd=family_cd)
      IF (family_ind=0)
       tempa->nok = epr.ft_rel_person_name, tempa->nok_relt_to_pat = uar_get_code_display(epr
        .person_reltn_cd), family_ind = 1
      ENDIF
      IF (ph.phone_type_cd=home_phone_cd)
       IF (ph.phone_format_cd > 0)
        tempa->nok_phone_nbr = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSE
        tempa->nok_phone_nbr = trim(ph.phone_num)
       ENDIF
      ENDIF
      tempa->nok_address = trim(a.street_addr), tempa->nok_csz = concat(trim(a.city),", ",trim(a
        .state),"  ",trim(a.zipcode))
     ELSEIF (epr.person_reltn_type_cd=def_guar_cd)
      IF (defguar_ind=0)
       tempa->guarantor = epr.ft_rel_person_name, tempa->guar_relt_to_pat = uar_get_code_display(epr
        .person_reltn_cd), defguar_ind = 1
      ENDIF
      IF (ph.phone_type_cd=home_phone_cd)
       IF (ph.phone_format_cd > 0)
        tempa->guar_phone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
       ELSE
        tempa->guar_phone = trim(ph.phone_num)
       ENDIF
      ENDIF
      tempa->guar_address = trim(a.street_addr), tempa->guar_csz = concat(trim(a.city),", ",trim(a
        .state),"  ",trim(a.zipcode)), defguar_ind = 1
     ENDIF
    WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
     dontcare = ph, dontcare = a
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     g_length = 62, lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(40," "), drec->line_qual[
     lidx].disp_line = concat(rhead,rtab,rtab,rtab,rh2bu,
      "INSURANCE INFORMATION",reol,wr),
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     drec->line_qual[lidx].disp_line = reol, disp_label1 = "Emergency Contact:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(16," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->emg_contact > "   "))
      dispa->display1 = trim(tempa->emg_contact)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
      reol), disp_label1 = "Relationship to Patient:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->cont_relt_to_pat > "   "))
      dispa->display1 = trim(tempa->cont_relt_to_pat)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
      reol), disp_label1 = "Contact's Home Phone #:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->contact_home_phon_nbr > "   "))
      dispa->display1 = trim(tempa->contact_home_phon_nbr)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
      reol), disp_label1 = "Business Phone #:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->contact_bus_phon_nbr > "   "))
      dispa->display1 = trim(tempa->contact_bus_phon_nbr)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, disp_label1 =
     "Next of Kin:",
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     dispa->spaces1 = fillstring(20," "), dispa->display1 = fillstring(10," ")
     IF ((tempa->nok > "   "))
      dispa->display1 = trim(tempa->nok)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "Relationship to Patient:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->nok_relt_to_pat > "   "))
      dispa->display1 = trim(tempa->nok_relt_to_pat)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
      reol), disp_label1 = "Phone #:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(20," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->nok_phone_nbr > "   "))
      dispa->display1 = trim(tempa->nok_phone_nbr)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "Address:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(20," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->nok_address > "   "))
      dispa->display1 = trim(tempa->nok_address)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "City, State, Zip code:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->nok_csz > "   "))
      dispa->display1 = trim(tempa->nok_csz)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, disp_label1 =
     "Guarantor:",
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     dispa->spaces1 = fillstring(17," "), dispa->display1 = fillstring(10," ")
     IF ((tempa->guarantor > "   "))
      dispa->display1 = trim(tempa->guarantor)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "Relationship to the Patient:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(14," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->guar_relt_to_pat > "   "))
      dispa->display1 = trim(tempa->guar_relt_to_pat)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
      reol), disp_label1 = "Phone #:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(20," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->guar_phone > "   "))
      dispa->display1 = trim(tempa->guar_phone)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "Address:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(20," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->guar_address > "   "))
      dispa->display1 = trim(tempa->guar_address)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "City, State, Zip code:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->guar_csz > "   "))
      dispa->display1 = trim(tempa->guar_csz)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), lidx = (lidx+ 1), row + 1,
     stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol, disp_label1 =
     "Financial Class:",
     lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
     dispa->spaces1 = fillstring(18," "), dispa->display1 = fillstring(10," ")
     IF ((tempa->fin_class > "   "))
      dispa->display1 = trim(tempa->fin_class)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol), disp_label1 = "Financial Number:", lidx = (lidx+ 1),
     row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(17," "),
     dispa->display1 = fillstring(10," ")
     IF ((tempa->fin_nbr > "   "))
      dispa->display1 = trim(tempa->fin_nbr)
     ENDIF
     drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
      dispa->display1,reol)
     IF ((tempa->icnt > 0))
      FOR (vv = 1 TO tempa->icnt)
        disp_label1 = "Insurance Company Name:", lidx = (lidx+ 1), row + 1,
        stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(11," "), dispa->display1
         = fillstring(10," ")
        IF ((tempa->qual[vv].ins_comp_name > "   "))
         dispa->display1 = trim(tempa->qual[vv].ins_comp_name)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
         display1,
         reol), disp_label1 = "Insured Name:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(16," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].insured_name > "   "))
         dispa->display1 = trim(tempa->qual[vv].insured_name)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
         dispa->display1,reol), disp_label1 = "Relationship to Patient:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].insured_relt_to_pat > "   "))
         dispa->display1 = trim(tempa->qual[vv].insured_relt_to_pat)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
         display1,
         reol), disp_label1 = "Insured Social Security Number:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(11," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].insured_ssn > "   "))
         dispa->display1 = trim(tempa->qual[vv].insured_ssn)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
         display1,
         reol), disp_label1 = "Group Number:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(28," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].group_number > "   "))
         dispa->display1 = trim(tempa->qual[vv].group_number)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
         dispa->display1,reol), disp_label1 = "Plan ID:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(20," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].plan_id > "   "))
         dispa->display1 = trim(tempa->qual[vv].plan_id)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
         dispa->display1,reol), disp_label1 = "Effective Date:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(18," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].effective_dt_from > 0)
         AND (tempa->qual[vv].effective_dt_to > 0))
         tmp_display1 = format(tempa->qual[vv].effective_dt_from,"MM/DD/YYYY;;d"), tmp_display2 =
         format(tempa->qual[vv].effective_dt_to,"MM/DD/YYYY;;d")
        ELSE
         tmp_display1 = "  ", tmp_display2 = "  "
        ENDIF
        tmp_display = concat("From: ",tmp_display1,"      ","To: ",tmp_display2), dispa->display1 =
        tmp_display, drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,
         rtab,
         dispa->display1,reol),
        disp_label1 = "Insurance Company Contact Phone #:", lidx = (lidx+ 1), row + 1,
        stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(6," "), dispa->display1
         = fillstring(10," ")
        IF ((tempa->qual[vv].ins_comp_cont_phone_nbr > "   "))
         dispa->display1 = trim(tempa->qual[vv].ins_comp_cont_phone_nbr)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,dispa->display1,
         reol), disp_label1 = "Contact Person Name:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].contact_person_name > "   "))
         dispa->display1 = trim(tempa->qual[vv].contact_person_name)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
         display1,
         reol), disp_label1 = "Authorization Number:", lidx = (lidx+ 1),
        row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "),
        dispa->display1 = fillstring(10," ")
        IF ((tempa->qual[vv].auth_nbr > "   "))
         dispa->display1 = trim(tempa->qual[vv].auth_nbr)
        ENDIF
        drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
         display1,
         reol), lidx = (lidx+ 1), row + 1,
        stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
      ENDFOR
     ELSE
      disp_label1 = "Insurance Company Name:", lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(11," "), dispa->display1 =
      fillstring(10," "),
      drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
       display1,
       reol), disp_label1 = "Insured Name:", lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(16," "),
      dispa->display1 = fillstring(10," "), drec->line_qual[lidx].disp_line = concat(
       start_label_space,disp_label1,rtab,rtab,dispa->display1,
       reol), disp_label1 = "Relationship to Patient:",
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      dispa->spaces1 = fillstring(15," "), dispa->display1 = fillstring(10," "), drec->line_qual[lidx
      ].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->display1,
       reol),
      disp_label1 = "Insured Social Security Number:", lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(11," "), dispa->display1 =
      fillstring(10," "),
      drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
       display1,
       reol), disp_label1 = "Group Number:", lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(28," "),
      dispa->display1 = fillstring(10," "), drec->line_qual[lidx].disp_line = concat(
       start_label_space,disp_label1,rtab,rtab,rtab,
       dispa->display1,reol), disp_label1 = "Plan ID:",
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      dispa->spaces1 = fillstring(20," "), dispa->display1 = fillstring(10," "), drec->line_qual[lidx
      ].disp_line = concat(start_label_space,disp_label1,rtab,rtab,rtab,
       dispa->display1,reol),
      disp_label1 = "Effective Date:", lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(18," "), dispa->display1 =
      fillstring(10," "),
      tmp_display1 = "  ", tmp_display2 = "  ", tmp_display = concat("From: ",tmp_display1,"      ",
       "To: ",tmp_display2),
      dispa->display1 = tmp_display, drec->line_qual[lidx].disp_line = concat(start_label_space,
       disp_label1,rtab,rtab,dispa->display1,
       reol), disp_label1 = "Insurance Company Contact Phone #:",
      lidx = (lidx+ 1), row + 1, stat = alterlist(drec->line_qual,lidx),
      dispa->spaces1 = fillstring(6," "), dispa->display1 = fillstring(10," "), drec->line_qual[lidx]
      .disp_line = concat(start_label_space,disp_label1,rtab,dispa->display1,reol),
      disp_label1 = "Contact Person Name:", lidx = (lidx+ 1), row + 1,
      stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "), dispa->display1 =
      fillstring(10," "),
      drec->line_qual[lidx].disp_line = concat(start_label_space,disp_label1,rtab,rtab,dispa->
       display1,
       reol), disp_label1 = "Authorization Number:", lidx = (lidx+ 1),
      row + 1, stat = alterlist(drec->line_qual,lidx), dispa->spaces1 = fillstring(15," "),
      dispa->display1 = fillstring(10," "), drec->line_qual[lidx].disp_line = concat(
       start_label_space,disp_label1,rtab,rtab,dispa->display1,
       reol)
     ENDIF
    FOOT REPORT
     FOR (x = 1 TO lidx)
       reply->text = concat(reply->text,drec->line_qual[x].disp_line)
     ENDFOR
    WITH nocounter, maxcol = 500, maxrow = 800
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
