CREATE PROGRAM dcp_outpt_summary
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "391970"
 SET rhead =
 "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Microsoft Sans Serif;}{\f1\fswiss Tahoma;}}\deflang2057\deflange2057"
 SET rhead1 =
 "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red150\green150\blue255;}\deftab1134"
 SET rmarg = "\margt1100\margb1100\margl1100\margr1100"
 SET rh2r = "\pard\plain\f1\fs34\cb2\sl0"
 SET rh2b = "\plain\i\b\f1\fs48\cf2\cb3\sl0"
 SET rh2c = "\plain\f1\fs18\cb2\sl0"
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET tqr = "\tqr"
 SET ctab = "\tqc "
 SET ra = "\qr"
 SET rm = "\margrsxn2000"
 SET wr = "\plain\f0\fs20\cb2 "
 SET wr2 = "\plain\f0\fs16\cb2 "
 SET wb = "\plain\f0\fs20\b\cb2\lin600 "
 SET wt = "\plain\f1\fs30\cb2 "
 SET wu = "\plain\f0\fs18\ul\cb2 "
 SET wi = "\plain \f0 \fs18 \i \cb2 "
 SET wbi = "\plain \f0 \fs18 \b \i \cb2 "
 SET wiu = "\plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET wsub = " \plain \f0 \fs18 \sub\cb2 "
 SET wsuper = " \plain \f0 \fs18 \super\cb2 "
 SET tabset = "\pard\plain\ql\li0\ri0\widctlpar\tqr\tx3000"
 SET tabset0 = "\tqr \tx9600"
 SET tabset1 = "\tqc \tx5070 \tqr \tx9600"
 SET tabset2 = "\pard \plain \ql \li0\ ri0 \widctlpar \tqr \tx9600"
 SET tabset3 = "\tx4500"
 SET tabsetdrugs = "\tx3500\tx4200 \tx5100 \tx6000 \tx6700 \tx7800 \tx8700 \tx9800"
 SET rtfeof = "}"
 SET indent =
 "\pard\plain \s15\ql\li540\ri0\widctlpar\tqr\tx9600\aspalpha\aspnum\faauto\adjustright\rin0\lin600 "
 SET tblt = "\trbrdrt\brdrs\brdw15\brdrcf0 "
 SET tbll = "\trbrdrl\brdrs\brdw15\brdrcf0 "
 SET tblb = "\trbrdrb\brdrs\brdw15\brdrcf0 "
 SET tblr = "\trbrdrr\brdrs\brdw15\brdrcf0 "
 SET tblrow = "\trbrdrh\brdrs\brdw15\brdrcf0 "
 SET tblcol = "\trbrdrv\brdrs\brdw15\brdrcf0 "
 SET clt = "\clbrdrt\brdrs\brdw15\brdrcf0 "
 SET cll = "\clbrdrl\brdrs\brdw15\brdrcf0 "
 SET clb = "\clbrdrb\brdrs\brdw15\brdrcf0 "
 SET clr = "\clbrdrr\brdrs\brdw15\brdrcf0 "
 SET tblt0 = "\trbrdrt\brdrs\brdw0 "
 SET tbll0 = "\trbrdrl\brdrs\brdw0 "
 SET tblb0 = "\trbrdrb\brdrs\brdw0 "
 SET tblr0 = "\trbrdrr\brdrs\brdw0 "
 SET clt0 = "\clbrdrt\brdrs\brdw0 "
 SET cll0 = "\clbrdrl\brdrs\brdw0 "
 SET clb0 = "\clbrdrb\brdrs\brdw0 "
 SET clr0 = "\clbrdrr\brdrs\brdw0 "
 SET tbltdrugs = "\trbrdrt\brdrs\brdrw15\brdrcf2 "
 SET tblldrugs = "\trbrdrl\brdrs\brdRw15\brdrcf2 "
 SET tblbdrugs = "\trbrdrb\brdrs\brdRw15\brdrcf2 "
 SET tblrdrugs = "\trbrdrr\brdrs\brdRw15\brdrcf2 "
 SET tblrowdrugs = "\trbrdrh\brdrs\brdRw15\brdrcf2 "
 SET tblcoldrugs = "\trbrdrv\brdrs\brdRw15\brdrcf2 "
 SET cltdrugs = "\clbrdrt\brdrs\brdrw15\brdrcf2 "
 SET clldrugs = "\clbrdrl\brdrs\brdrw15\brdrcf2 "
 SET clbdrugs = "\clbrdrb\brdrs\brdrw15\brdrcf2 "
 SET clrdrugs = "\clbrdrr\brdrs\brdrw15\brdrcf2 "
 SET tabsetability = "\tx3260 \tx5980 \tx8700 \tx9600"
 SET cur_ward_cd = 0
 SET graham_ward_cd = uar_get_code_by("DISPLAYKEY",220,"GRAHAM")
 SET cass_ward_cd = uar_get_code_by("DISPLAYKEY",220,"CASS")
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
 )
 RECORD test_result(
   1 cnt = i2
   1 qual[*]
     2 result_val = vc
 )
 RECORD problem_acute(
   1 cnt = i2
   1 qual[*]
     2 source_string = vc
 )
 RECORD problem_chronic(
   1 cnt = i2
   1 qual[*]
     2 source_string = vc
 )
 RECORD future_appt(
   1 cnt = i2
   1 qual[*]
     2 appt_dt_tm = vc
     2 beg_dt_tm = vc
     2 end_dt_tm = vc
     2 appt_location = vc
     2 appt_synonym_free = vc
 )
 RECORD med_procedure(
   1 cnt = i2
   1 qual[*]
     2 source_string = vc
 )
 RECORD med_order(
   1 cnt = i2
   1 qual[*]
     2 order_mnemonic = vc
     2 orig_order_dt_tm = vc
 )
 RECORD med_rad_order(
   1 cnt = i2
   1 qual[*]
     2 order_mnemonic = vc
     2 status_dt_tm = vc
 )
 SET line = fillstring(73,"_")
 SET lidx = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cur_date = format(curdate,"DD-MMM-YYYY;;d")
 SET encntr_id = 0
 SET encntr_type = fillstring(50," ")
 SET building = fillstring(50," ")
 SET person_id = 0
 SET pt_first = fillstring(50," ")
 SET pt_last = fillstring(50," ")
 SET dob = fillstring(20," ")
 SET pt_age = fillstring(20," ")
 SET cnn = fillstring(20," ")
 SET nhs = fillstring(20," ")
 SET pt_addr = fillstring(50," ")
 SET pt_addr2 = fillstring(50," ")
 SET pt_addr3 = fillstring(50," ")
 SET pt_city = fillstring(50," ")
 SET pt_postcode = fillstring(50," ")
 SET ward = fillstring(50," ")
 SET med_svc = fillstring(50," ")
 SET admit_date = fillstring(50," ")
 SET disch_date = fillstring(50," ")
 SET disch_date_p = fillstring(50," ")
 SET gp_first = fillstring(50," ")
 SET gp_last = fillstring(50," ")
 SET gp_addr = fillstring(50," ")
 SET gp_addr2 = fillstring(50," ")
 SET gp_addr3 = fillstring(50," ")
 SET gp_city = fillstring(50," ")
 SET gp_postcode = fillstring(50," ")
 SET attend_first = fillstring(50," ")
 SET attend_last = fillstring(50," ")
 SET attend_title = fillstring(50," ")
 SET attend_bus_phone = fillstring(50," ")
 SET attend_fax_phone = fillstring(50," ")
 SET attend_telfax = ""
 SET tempcount = 0
 SET res_val = fillstring(100," ")
 SET res_unit = fillstring(100," ")
 SET user_title = fillstring(10," ")
 SET user_first = fillstring(45," ")
 SET user_last = fillstring(45," ")
 SET user_position = fillstring(50," ")
 SET user_bleep_no = fillstring(20," ")
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 331
 SET cdf_meaning = "PCP"
 EXECUTE cpm_get_cd_for_cdf
 SET gp_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET cnn_alias_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET nhs_alias_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_addr_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_addr_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_phone_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "FAX BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET fax_phone_cd = code_value
 SET code_set = 213
 SET cdf_meaning = "PRSNL"
 EXECUTE cpm_get_cd_for_cdf
 SET prsnl_name_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "PAGER ALT"
 EXECUTE cpm_get_cd_for_cdf
 SET pager_alt_cd = code_value
 SET tempint = 0
 SET cnn_cd = uar_get_code_by("MEANING",4,"MRN")
 SELECT INTO "nl:"
  FROM encounter e,
   org_alias_pool_reltn oa,
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (oa
   WHERE oa.organization_id=e.organization_id
    AND oa.alias_entity_alias_type_cd=cnn_cd
    AND oa.active_ind=1
    AND oa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND oa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.alias_pool_cd=oa.alias_pool_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   cnn = cnvtalias(pa.alias,pa.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   person_alias pa2,
   (dummyt d2  WITH seq = 1),
   encntr_prsnl_reltn epr,
   (dummyt d4  WITH seq = 1),
   prsnl p1,
   (dummyt d7  WITH seq = 1),
   address a2,
   (dummyt d8  WITH seq = 1),
   phone ph1,
   (dummyt d9  WITH seq = 1),
   phone ph2,
   (dummyt d10  WITH seq = 1),
   person_name pn1
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d1)
   JOIN (pa2
   WHERE pa2.person_id=p.person_id
    AND pa2.person_alias_type_cd=nhs_alias_cd
    AND pa2.active_ind=1)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1)
   JOIN (d4)
   JOIN (p1
   WHERE p1.person_id=epr.prsnl_person_id
    AND p1.active_ind=1)
   JOIN (d7)
   JOIN (a2
   WHERE a2.parent_entity_id=p.person_id
    AND a2.parent_entity_name="PERSON"
    AND a2.address_type_cd=home_addr_cd
    AND a2.active_ind=1)
   JOIN (d8)
   JOIN (ph1
   WHERE ph1.parent_entity_id=epr.prsnl_person_id
    AND ph1.phone_type_cd=bus_phone_cd
    AND ph1.active_ind=1)
   JOIN (d9)
   JOIN (ph2
   WHERE ph2.parent_entity_id=epr.prsnl_person_id
    AND ph2.phone_type_cd=fax_phone_cd
    AND ph2.active_ind=1)
   JOIN (d10)
   JOIN (pn1
   WHERE pn1.person_id=epr.prsnl_person_id
    AND pn1.name_type_cd=prsnl_name_cd
    AND pn1.active_ind=1)
  DETAIL
   person_id = e.person_id, encntr_id = e.encntr_id, pt_first = trim(p.name_first),
   pt_addr = trim(a2.street_addr), pt_addr2 = trim(a2.street_addr2), pt_addr3 = trim(a2.street_addr3),
   pt_city = trim(a2.city), pt_postcode = trim(a2.zipcode), dob = format(p.birth_dt_tm,
    "dd-mmm-yyyy;;"),
   pt_age = trim(cnvtage(p.birth_dt_tm)), nhs = trim(format(pa2.alias,"### ### ####")), attend_first
    = trim(p1.name_first),
   attend_title = trim(pn1.name_title), attend_bus_phone = trim(format(ph1.phone_num,"### #### ####")
    ), attend_fax_phone = trim(format(ph2.phone_num,"### #### ####")),
   med_svc = trim(uar_get_code_display(e.med_service_cd)), ward = trim(uar_get_code_display(e
     .loc_nurse_unit_cd)), cur_ward_cd = e.loc_nurse_unit_cd,
   admit_date = format(e.reg_dt_tm,"dd-mmm-yyyy;;"), disch_date = format(e.disch_dt_tm,
    "dd-mmm-yyyy;;"), disch_date_p = format(e.est_depart_dt_tm,"dd-mmm-yyyy;;"),
   building = uar_get_code_description(e.loc_building_cd), encntr_type = uar_get_code_description(e
    .encntr_type_cd)
  WITH nocounter, dontcare = pa1, dontcare = pa2,
   outerjoin = d2, dontcare = epr, outerjoin = d4,
   dontcare = p1, outerjoin = d7, dontcare = a2,
   outerjoin = d8, dontcare = ph1, outerjoin = d9,
   dontcare = ph2, outerjoin = d10, dontcare = pn1
 ;end select
 FREE RECORD psreply
 RECORD psreply(
   1 prg_mode_flag = f8
   1 current_dt_tm = dq8
   1 entity_cnt = i4
   1 entity[*]
     2 entity_id = f8
     2 entity_name = c30
     2 status_flag = i2
     2 status_details = vc
     2 xml_fail_ind = i2
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_slice_id = f8
     2 pm_wait_list_id = f8
     2 organization_id = f8
     2 sch_schedule_id = f8
     2 point_dt_tm = f8
     2 ae_apc_ind = i2
     2 ae_apc_admit_dt_tm = dq8
     2 cloud_referral_encntr_id = f8
     2 pm_offer_id = f8
     2 gp
       3 nhs_alias = c8
       3 name_title = c25
       3 name_last = c25
       3 name_first = c25
       3 name_full_formatted = c45
       3 practice
         4 nhs_alias = c6
         4 name = c45
         4 org_id = f8
         4 address
           5 street1 = c35
           5 street2 = c35
           5 street3 = c35
           5 street4 = c35
           5 city = c35
           5 county = c35
           5 country = c35
           5 postcode = c8
         4 phone = vc
       3 pct
         4 nhs_alias = c5
         4 name = c45
         4 org_id = f8
       3 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD psrequest
 RECORD psrequest(
   1 load
     2 consultant_flag = i2
     2 gp_flag = i2
     2 referrer_flag = i2
     2 granularity_flag = i2
     2 practice_add_flag = i2
     2 ed_staff_flag = i2
 )
 SET stat = alterlist(psreply->entity,1)
 SET psreply->entity_cnt = 1
 SET psreply->current_dt_tm = cnvtdatetime(sysdate)
 SET psreply->entity[1].point_dt_tm = cnvtdatetime(sysdate)
 SET psreply->entity[1].person_id = person_id
 SET psrequest->load.gp_flag = 2
 SET psrequest->load.practice_add_flag = 1
 EXECUTE ukr_get_prsnl  WITH replace(request,psrequest), replace(reply,psreply)
 SET gp_first = psreply->entity[1].gp.name_first
 SET gp_last = psreply->entity[1].gp.name_last
 SET gp_addr = psreply->entity[1].gp.practice.address.street1
 SET gp_addr2 = psreply->entity[1].gp.practice.address.street2
 SET gp_addr3 = psreply->entity[1].gp.practice.address.street3
 SET gp_city = psreply->entity[1].gp.practice.address.city
 SET gp_postcode = psreply->entity[1].gp.practice.address.postcode
 FREE RECORD psreply
 FREE RECORD psrequest
 SET attend_telfax = concat(attend_bus_phone,attend_fax_phone)
 SELECT INTO "nl:"
  FROM encounter e,
   person_prsnl_activity ppa,
   prsnl p,
   phone ph
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ppa
   WHERE ppa.person_id=e.person_id)
   JOIN (p
   WHERE p.person_id=ppa.prsnl_id)
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.phone_type_cd= Outerjoin(pager_alt_cd))
    AND (ph.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ph.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
    AND (ph.active_ind= Outerjoin(1)) )
  ORDER BY ppa.ppa_last_dt_tm
  DETAIL
   user_first = p.name_first, user_last = p.name_last, user_position = trim(uar_get_code_display(p
     .position_cd))
   IF (size(trim(ph.phone_num)) > 0)
    user_bleep_no = cnvtphone(ph.phone_num,ph.phone_format_cd)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE dhba1ccd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"HBA1C"))
 DECLARE dt4cd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"FREET4"))
 DECLARE dtshcd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"TSH"))
 DECLARE dcholestrolcd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"CHOLESTEROL"))
 DECLARE dhdlcd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",72,"HDL"))
 SET stat = alterlist(test_result->qual,5)
 SELECT INTO "nl:"
  FROM clinical_event c
  WHERE (c.encntr_id=request->visit[1].encntr_id)
   AND c.event_cd IN (dhba1ccd, dt4cd, dtshcd, dcholestrolcd, dhdlcd)
   AND trim(c.result_val) != ""
  DETAIL
   res_val = trim(c.result_val), res_unit = trim(uar_get_code_display(c.result_units_cd))
   CASE (c.event_cd)
    OF dcholestrolcd:
     test_result->qual[1].result_val = concat(res_val," ",res_unit)
    OF dhdlcd:
     test_result->qual[2].result_val = concat(res_val," ",res_unit)
    OF dhba1ccd:
     test_result->qual[3].result_val = concat(res_val," ",res_unit)
    OF dt4cd:
     test_result->qual[4].result_val = concat(res_val," ",res_unit)
    OF dtshcd:
     test_result->qual[5].result_val = concat(res_val," ",res_unit)
   ENDCASE
  WITH nocounter
 ;end select
 SET tempcount = 0
 DECLARE active_life_status_cd = f8 WITH noconstant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 SELECT DISTINCT INTO "nl:"
  nom.source_string
  FROM encounter e,
   problem prob,
   nomenclature nom
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (prob
   WHERE prob.person_id=e.person_id
    AND prob.life_cycle_status_cd=active_life_status_cd
    AND prob.active_ind=1
    AND prob.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (nom
   WHERE nom.nomenclature_id=prob.nomenclature_id)
  ORDER BY nom.source_string
  DETAIL
   tempcount += 1, stat = alterlist(problem_chronic->qual,tempcount), problem_chronic->qual[tempcount
   ].source_string = trim(cnvtcap(nom.source_string))
  WITH nocounter
 ;end select
 SET chronic_prob_count = tempcount
 DECLARE active_allergy_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 SET tempcount = 0
 SELECT DISTINCT INTO "nl:"
  nom.source_string
  FROM encounter e,
   allergy a,
   nomenclature nom
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,0)
    AND a.reaction_status_cd=active_allergy_cd
    AND ((a.cancel_dt_tm = null) OR (a.cancel_dt_tm >= cnvtdatetime((curdate+ 1),0))) )
   JOIN (nom
   WHERE nom.nomenclature_id=a.substance_nom_id)
  ORDER BY nom.source_string
  DETAIL
   tempcount += 1, stat = alterlist(allergy->qual,tempcount), allergy->qual[tempcount].list = trim(
    cnvtcap(nom.source_string))
  WITH nocounter
 ;end select
 SET allergy_count = tempcount
 SELECT DISTINCT INTO "nl:"
  nom.source_string
  FROM diagnosis dia,
   nomenclature nom
  PLAN (dia
   WHERE (dia.encntr_id=request->visit[1].encntr_id)
    AND dia.active_ind=1)
   JOIN (nom
   WHERE nom.nomenclature_id=dia.nomenclature_id)
  ORDER BY nom.source_string
  DETAIL
   tempcount += 1, stat = alterlist(problem_acute->qual,tempcount), problem_acute->qual[tempcount].
   source_string = trim(cnvtcap(nom.source_string))
  WITH nocounter
 ;end select
 SET acute_prob_count = tempcount
 SET tempcount = 0
 SELECT INTO "nl:"
  FROM procedure p,
   nomenclature nom
  PLAN (p
   WHERE (p.encntr_id=request->visit[1].encntr_id))
   JOIN (nom
   WHERE nom.nomenclature_id=p.nomenclature_id)
  DETAIL
   tempcount += 1, stat = alterlist(med_procedure->qual,tempcount), med_procedure->qual[tempcount].
   source_string = trim(cnvtcap(nom.source_string))
  WITH nocounter
 ;end select
 SET procedure_count = tempcount
 SET tempcount = 0
 SELECT INTO "nl:"
  FROM encounter e,
   sch_appt scha,
   sch_event schd
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (scha
   WHERE scha.person_id=e.person_id
    AND scha.beg_dt_tm > cnvtdatetime(sysdate)
    AND  NOT (scha.state_meaning IN ("CANCELED", "NOSHOW", "RESCHEDULED")))
   JOIN (schd
   WHERE schd.sch_event_id=scha.sch_event_id)
  DETAIL
   tempcount += 1, stat = alterlist(future_appt->qual,tempcount), future_appt->qual[tempcount].
   appt_dt_tm = format(scha.beg_dt_tm,"DD-MMM-YYYY HH:MM;;"),
   future_appt->qual[tempcount].beg_dt_tm = format(scha.beg_dt_tm,";;Q"), future_appt->qual[tempcount
   ].end_dt_tm = format(scha.end_dt_tm,";;Q"), future_appt->qual[tempcount].appt_location = trim(
    uar_get_code_description(scha.appt_location_cd)),
   future_appt->qual[tempcount].appt_synonym_free = trim(schd.appt_synonym_free)
  WITH nocounter
 ;end select
 SET future_appt_count = tempcount
 DECLARE dradiologycd = f8 WITH noconstant(uar_get_code_by("MEANING",6000,"RADIOLOGY"))
 DECLARE dlabcd = f8 WITH noconstant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE dsurgcd = f8 WITH noconstant(uar_get_code_by("MEANING",6000,"SURGERY"))
 DECLARE dcellpathcd = f8 WITH noconstant(uar_get_code_by("MEANING",106,"AP"))
 SET tempcount = 0
 SELECT INTO "nl:"
  FROM orders o,
   dummyt d
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND ((o.catalog_type_cd IN (dradiologycd, dsurgcd)) OR (o.catalog_type_cd=dlabcd
    AND o.activity_type_cd=dcellpathcd)) )
   JOIN (d
   WHERE uar_get_code_meaning(o.sch_state_cd) != "CANCELED"
    AND uar_get_code_meaning(o.order_status_cd) IN ("ORDERED", "FUTURE", "INPROCESS", "PENDING"))
  ORDER BY o.orig_order_dt_tm
  DETAIL
   tempcount += 1, stat = alterlist(med_order->qual,tempcount), med_order->qual[tempcount].
   order_mnemonic = o.order_mnemonic,
   med_order->qual[tempcount].orig_order_dt_tm = format(o.orig_order_dt_tm,"DD-MMM-YYYY HH:MM;;")
  WITH nocounter
 ;end select
 SET order_count = tempcount
 SET tempcount = 0
 SELECT INTO "nl:"
  FROM orders o,
   dummyt d
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id))
   JOIN (d
   WHERE uar_get_code_meaning(o.sch_state_cd) != "CANCELED"
    AND uar_get_code_meaning(o.order_status_cd)="COMPLETED"
    AND ((uar_get_code_meaning(o.catalog_type_cd)="RADIOLOGY") OR (uar_get_code_meaning(o
    .activity_type_cd)="RADIOLOGY")) )
  ORDER BY o.status_dt_tm
  DETAIL
   tempcount += 1, stat = alterlist(med_rad_order->qual,tempcount), med_rad_order->qual[tempcount].
   order_mnemonic = o.order_mnemonic,
   med_rad_order->qual[tempcount].status_dt_tm = format(o.status_dt_tm,"DD-MMM-YYYY HH:MM;;")
  WITH nocounter
 ;end select
 SET radiology_count = tempcount
 SET nok_cd = uar_get_code_by("MEANING",351,"NOK")
 SET carer_cd = uar_get_code_by("MEANING",351,"PCG")
 DECLARE home_address_cd = f8 WITH noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE home_phone_cd = f8 WITH noconstant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE work_address_cd = f8 WITH noconstant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE work_phone_cd = f8 WITH noconstant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mobile_phone_cd = f8 WITH noconstant(uar_get_code_by("MEANING",43,"PAGER PERS"))
 SET nok = fillstring(40," ")
 SET nok_home_address = fillstring(100," ")
 SET nok_home_phone = fillstring(20," ")
 SET nok_work_address = fillstring(100," ")
 SET nok_work_phone = fillstring(20," ")
 SET nok_mobile_phone = fillstring(20," ")
 SET carer = fillstring(40," ")
 SET carer_home_address = fillstring(100," ")
 SET carer_home_phone = fillstring(20," ")
 SET carer_work_address = fillstring(100," ")
 SET carer_work_phone = fillstring(20," ")
 SET carer_mobile_phone = fillstring(20," ")
 SELECT INTO "nl:"
  FROM encounter e,
   person_person_reltn pp,
   person p,
   address a,
   phone ph,
   address a1,
   phone ph1,
   phone ph2
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pp
   WHERE pp.person_id=e.person_id
    AND pp.person_reltn_type_cd IN (nok_cd, carer_cd)
    AND pp.active_ind=1
    AND pp.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pp.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=pp.related_person_id
    AND pp.active_ind=1
    AND pp.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(pp.related_person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_address_cd))
    AND (a.active_ind= Outerjoin(1))
    AND (a.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(pp.related_person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.phone_type_cd= Outerjoin(home_phone_cd))
    AND (ph.active_ind= Outerjoin(1))
    AND (ph.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (ph.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (a1
   WHERE (a1.parent_entity_id= Outerjoin(pp.related_person_id))
    AND (a1.parent_entity_name= Outerjoin("PERSON"))
    AND (a1.address_type_cd= Outerjoin(work_address_cd))
    AND (a1.active_ind= Outerjoin(1))
    AND (a1.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (a1.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph1
   WHERE (ph1.parent_entity_id= Outerjoin(pp.related_person_id))
    AND (ph1.parent_entity_name= Outerjoin("PERSON"))
    AND (ph1.phone_type_cd= Outerjoin(work_phone_cd))
    AND (ph1.active_ind= Outerjoin(1))
    AND (ph1.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (ph1.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ph2
   WHERE (ph2.parent_entity_id= Outerjoin(pp.related_person_id))
    AND (ph2.parent_entity_name= Outerjoin("PERSON"))
    AND (ph2.phone_type_cd= Outerjoin(mobile_phone_cd))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
    AND (ph2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  DETAIL
   IF (pp.person_reltn_type_cd=nok_cd)
    nok = trim(p.name_full_formatted), nok_home_address = trim(a.street_addr)
    IF (trim(a.street_addr2) != "")
     nok_home_address = concat(trim(nok_home_address),", ",a.street_addr2)
    ENDIF
    IF (trim(a.street_addr3) != "")
     nok_home_address = concat(trim(nok_home_address),", ",a.street_addr3)
    ENDIF
    IF (trim(a.street_addr4) != "")
     nok_home_address = concat(trim(nok_home_address),", ",a.street_addr4)
    ENDIF
    IF (trim(a.city) != "")
     nok_home_address = concat(trim(nok_home_address),", ",a.city)
    ENDIF
    IF (trim(a.zipcode) != "")
     nok_home_address = concat(trim(nok_home_address),", ",a.zipcode)
    ENDIF
    nok_home_phone_no = ph.phone_num, nok_work_address = trim(a1.street_addr)
    IF (trim(a1.street_addr2) != "")
     nok_work_address = concat(trim(nok_work_address),", ",a1.street_addr2)
    ENDIF
    IF (trim(a1.street_addr3) != "")
     nok_work_address = concat(trim(nok_work_address),", ",a1.street_addr3)
    ENDIF
    IF (trim(a1.street_addr4) != "")
     nok_work_address = concat(trim(nok_work_address),", ",a1.street_addr4)
    ENDIF
    IF (trim(a1.city) != "")
     nok_work_address = concat(trim(nok_work_address),", ",a1.city)
    ENDIF
    IF (trim(a1.zipcode) != "")
     nok_work_address = concat(trim(nok_work_address),", ",a1.zipcode)
    ENDIF
    nok_work_phone_no = ph1.phone_num, nok_mobile_phone_no = ph2.phone_num
   ELSEIF (pp.person_reltn_type_cd=carer_cd)
    carer = trim(p.name_full_formatted), carer_home_address = trim(a.street_addr)
    IF (trim(a.street_addr2) != "")
     carer_home_address = concat(trim(carer_home_address),", ",a.street_addr2)
    ENDIF
    IF (trim(a.street_addr3) != "")
     carer_home_address = concat(trim(carer_home_address),", ",a.street_addr3)
    ENDIF
    IF (trim(a.street_addr4) != "")
     carer_home_address = concat(trim(carer_home_address),", ",a.street_addr4)
    ENDIF
    IF (trim(a.city) != "")
     carer_home_address = concat(trim(carer_home_address),", ",a.city)
    ENDIF
    IF (trim(a.zipcode) != "")
     carer_home_address = concat(trim(carer_home_address),", ",a.zipcode)
    ENDIF
    carer_home_phone_no = ph.phone_num, carer_work_address = trim(a1.street_addr)
    IF (trim(a1.street_addr2) != "")
     carer_work_address = concat(trim(carer_work_address),", ",a1.street_addr2)
    ENDIF
    IF (trim(a1.street_addr3) != "")
     carer_work_address = concat(trim(carer_work_address),", ",a1.street_addr3)
    ENDIF
    IF (trim(a1.street_addr4) != "")
     carer_work_address = concat(trim(carer_work_address),", ",a1.street_addr4)
    ENDIF
    IF (trim(a1.city) != "")
     carer_work_address = concat(trim(carer_work_address),", ",a1.city)
    ENDIF
    IF (trim(a1.zipcode) != "")
     carer_work_address = concat(trim(carer_work_address),", ",a1.zipcode)
    ENDIF
    carer_work_phone_no = ph1.phone_num, carer_mobile_phone_no = ph2.phone_num
   ENDIF
  WITH nocounter
 ;end select
 SET truststring = fillstring(50," ")
 SET nhs_trust_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
 SELECT INTO "nl:"
  FROM encounter e,
   org_org_reltn oor,
   organization o
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (oor
   WHERE oor.related_org_id=e.organization_id
    AND oor.org_org_reltn_cd=nhs_trust_cd
    AND oor.active_ind=1
    AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND oor.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (o
   WHERE o.organization_id=oor.organization_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   truststring = o.org_name
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(rhead,
    rhead1,rmarg,rh2r,wt,
    "\tqc\tx4800\tqr\tx9600",rtab),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat("\b ",
    truststring),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(rtab,
    rh2b," NHS ",wt,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(rtab,
    "Discharge Information Form",reol,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
   "\trowd \trgaph100",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(tblt0,
    tbll0,tblb0,tblr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
    cll0,clb0,clr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cellx3700"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
    cll0,clb0,clr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cellx6700"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
    cll0,clb0,clr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cellx9600"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\li0\intab"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
    "GP: Dr ",trim(gp_first)," ",trim(gp_last))
   IF (trim(gp_addr) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(gp_addr))
   ENDIF
   IF (trim(gp_addr2) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(gp_addr2))
   ENDIF
   IF (trim(gp_addr3) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(gp_addr3))
   ENDIF
   IF (trim(gp_city) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(gp_city))
   ENDIF
   IF (trim(gp_postcode) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(gp_postcode))
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "\ql Date: ",wr,trim(cur_date),reol,
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
    "NHS No:  ",wr2,trim(nhs),wr,
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
    "MRN:  ",wr2,trim(cnn),reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
    "\ql Patient: ",trim(pt_first)," ",trim(pt_last)),
   lidx += 1
   IF (trim(pt_addr) != "")
    stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,trim(
      pt_addr))
   ENDIF
   IF (trim(pt_addr2) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(pt_addr2))
   ENDIF
   IF (trim(pt_addr3) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(pt_addr3))
   ENDIF
   IF (trim(pt_city) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(pt_city))
   ENDIF
   IF (trim(pt_postcode) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     trim(pt_postcode)),
    lidx += 1
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
    reol,wr,"DOB:  ",wr2,
    trim(dob)," (",trim(pt_age),")",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
   "\cell\row \li540",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = indent,
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    line,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Consultant at Discharge: ",wr),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(" ",
    trim(attend_first)," ",trim(attend_last),";  ",
    trim(med_svc))
   IF (trim(attend_telfax) != "")
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     tabset1,rtab,"("),
    lidx += 1, stat = alterlist(drec->line_qual,lidx)
    IF (trim(attend_bus_phone) != "")
     drec->line_qual[lidx].disp_line = concat("Tel: ",attend_bus_phone,"    ")
    ENDIF
    IF (trim(attend_fax_phone) != "")
     drec->line_qual[lidx].disp_line = concat("Fax: ",attend_fax_phone)
    ENDIF
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(")")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    " \fs12 ",reol,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Ward: ",wr2,trim(ward)),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    tabset1,rtab,"Admission Date: ",wr2,
    trim(admit_date)),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    rtab,"Discharge Date:",wr2),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (((trim(disch_date) != "") OR (disch_date != null)) )
    drec->line_qual[lidx].disp_line = concat("  ",trim(disch_date))
   ELSE
    drec->line_qual[lidx].disp_line = "  Type Here"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    " \fs12 ",reol,reol,indent),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
   "\trowd \trgaph100 \trleft385",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(tblt0,
    tbll0,tblb0,tblr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
    cll0,clb0,clr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cellx4800"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
    cll0,clb0,clr0),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cellx9600"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\li0\intab ",wb,"Problems & Diagnosis - Present Admission\cell ",wb,
    "Problems & Diagnosis - Lifelong\cell\row\li540"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\intab  "
   IF (acute_prob_count > 0)
    FOR (forcount1 = 1 TO acute_prob_count)
      IF (trim(problem_acute->qual[forcount1].source_string) != "")
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        wr2,trim(problem_acute->qual[forcount1].source_string),"; ")
      ENDIF
    ENDFOR
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "None")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\cell  ")
   IF (chronic_prob_count > 0)
    FOR (forcount3 = 1 TO chronic_prob_count)
      IF (trim(problem_chronic->qual[forcount3].source_string) != "")
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        wr2,trim(problem_chronic->qual[forcount3].source_string),"; ")
      ENDIF
    ENDFOR
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "None.")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell\row",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Procedures / Investigations Done: ")
   IF (((procedure_count+ radiology_count) > 0))
    IF (procedure_count > 0)
     FOR (forcount6 = 1 TO procedure_count)
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        reol,wr2,"  ",trim(med_procedure->qual[forcount6].source_string))
     ENDFOR
    ENDIF
    IF (radiology_count > 0)
     FOR (forcount6 = 1 TO radiology_count)
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        reol,wr2,"  ",trim(med_rad_order->qual[forcount6].order_mnemonic)),
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        " (Completed: ",med_rad_order->qual[forcount6].status_dt_tm,")")
     ENDFOR
    ENDIF
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  None")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Procedures / Investigations Pending: ")
   IF (order_count > 0)
    FOR (forcount4 = 1 TO order_count)
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       reol,wr2,"  ",trim(med_order->qual[forcount4].order_mnemonic)),
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       " (Ordered: ",med_order->qual[forcount4].orig_order_dt_tm,")")
    ENDFOR
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  None.")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Allergies: ")
   IF (allergy_count > 0)
    FOR (forcount5 = 1 TO allergy_count)
      IF (((allergy_count=1) OR (trim(allergy->qual[forcount5].list) != "No Known Allergies")) )
       lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
        wr2,"  ",trim(allergy->qual[forcount5].list),"; ")
      ENDIF
    ENDFOR
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  None Recorded.")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Chronic Disease Register Tests: ",wr2,"Cholesterol: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (trim(test_result->qual[1].result_val) != "")
    drec->line_qual[lidx].disp_line = trim(test_result->qual[1].result_val)
   ELSE
    drec->line_qual[lidx].disp_line = " None"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    HDL: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (trim(test_result->qual[2].result_val) != "")
    drec->line_qual[lidx].disp_line = trim(test_result->qual[2].result_val)
   ELSE
    drec->line_qual[lidx].disp_line = " None"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    HbA1c: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (trim(test_result->qual[2].result_val) != "")
    drec->line_qual[lidx].disp_line = trim(test_result->qual[3].result_val)
   ELSE
    drec->line_qual[lidx].disp_line = " None"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    T4: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (trim(test_result->qual[2].result_val) != "")
    drec->line_qual[lidx].disp_line = trim(test_result->qual[4].result_val)
   ELSE
    drec->line_qual[lidx].disp_line = " None"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    TSH: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx)
   IF (trim(test_result->qual[3].result_val) != "")
    drec->line_qual[lidx].disp_line = trim(test_result->qual[5].result_val)
   ELSE
    drec->line_qual[lidx].disp_line = " None"
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wsuper,
    "[Please Edit]",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Patient Capability: "),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = notrim(concat
    (wr2,"    Self Caring: Yes       ")),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = notrim(concat
    ("    Continence: Fully Continent       ")),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    Mobility: Fully Mobile"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wsuper,
    "[Please Edit]",reol,indent),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    tabset0,wb,"Outcome:  Home  /  Transferred to:       /  Deceased"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    " ",rtab,wr2,"Post Mortem:  Y / N",
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wsuper,
    "[Please Edit]",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    line,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Clinical Presentation:",wr2,"  Type here",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Significant Investigations:",wr2,"  Type here",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Clinical Course:",wr2,"  Type here",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Information Given To Patient:",wr2,"  Type here",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    line,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Follow up Arrangements")
   IF (future_appt_count > 0)
    FOR (forcount2 = 1 TO future_appt_count)
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       reol,wr2,trim(future_appt->qual[forcount2].appt_synonym_free)),
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       tabset3,rtab,trim(future_appt->qual[forcount2].appt_dt_tm))
    ENDFOR
   ELSE
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(":",
     wr2,"  By GP")
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Social Support Arrangements made by Hospital: ",wr2,"(Please Edit)",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "Meals on Wheels:  Y / N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "     Home Help:  Y / N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "     Home Care:  Y / N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "     District Nurse:  Y / N",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    line,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Drugs on Discharge",reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "Drug",tabsetdrugs,rtab,"Dose",
    rtab,"Route",rtab,"Frequency",rtab),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "# Days",rtab,"GP to Cont.?",rtab,"Pharmacy(Y/N)",
    reol,indent),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "\trowd \trgaph100 \trleft540"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    tbltdrugs,tblldrugs,tblbdrugs,tblrdrugs,tblrowdrugs,
    tblcoldrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx3500",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx4200",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx5100",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx6000",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx6700",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx7800",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx8700",
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    cltdrugs,clldrugs,clbdrugs,clrdrugs),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx9800"
   FOR (tempint = 0 TO 7)
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab\posx1000\cell\cell\cell\cell\cell\cell\cell\row")
   ENDFOR
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "\li540",reol)
   IF (((cur_ward_cd=graham_ward_cd) OR (cur_ward_cd=cass_ward_cd)) )
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     line,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     "Home Situation / Previous Services:",wr,reol," ",
     reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     line,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     "Next Of Kin:")
    IF (trim(nok) != "")
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      " ",trim(nok))
     IF (concat(trim(nok_home_address),trim(nok_home_phone),trim(nok_mobile_phone)) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
     ENDIF
     IF (trim(nok_home_address) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Home Address:",trim(nok_home_address))
     ENDIF
     IF (trim(nok_home_phone) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Home Phone:",trim(nok_home_phone))
     ENDIF
     IF (trim(nok_mobile_phone) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Mobile Phone:",trim(nok_mobile_phone))
     ENDIF
    ELSE
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      " Not Known")
    ENDIF
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     wb,"Carer:")
    IF (trim(carer) != "")
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      " ",trim(carer))
     IF (trim(carer_home_address) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Home Address:",trim(carer_home_address))
     ENDIF
     IF (trim(carer_home_phone) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Home Phone:",trim(carer_home_phone))
     ENDIF
     IF (trim(carer_mobile_phone) != "")
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "   Mobile Phone:",trim(carer_mobile_phone))
     ENDIF
    ELSE
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      " Not Known")
    ENDIF
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol,
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     line,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     "Members of Multidisciplinary Team Involved:",reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
     tabsetdrugs," Name and Role",rtab,"Contact Information",
     reol,indent),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "\trowd \trgaph100 \trleft540"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(tblt,
     tbll,tblb,tblr,tblrow,
     tblcol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt,
     cll,clb,clr),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx4200",
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt,
     cll,clb,clr),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx8700"
    FOR (tempint = 1 TO 6)
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       "\li0\intab\posx1000\cell\cell\row")
    ENDFOR
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li540"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     line,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
     "Abilities on Discharge:",reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
     tabsetability,rtab," Current Abilities",rtab,
     "Future Goals",reol,indent),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "\trowd \trgaph100 \trleft540"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(tblt,
     tbll,tblb,tblr,tblrow,
     tblcol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt,
     cll,clb,clr),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx3260",
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt,
     cll,clb,clr),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx5980",
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt,
     cll,clb,clr),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cellx8700",
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Mobility\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Transfers\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Personal Care\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Domestic\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Cognitive State\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li0\intab\posx1000 Communication and Swallow\cell\cell\cell\row"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     "\li540"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     wb,"Services on Discharge (inc. Contact Information):",wr,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     wb,"Equipment on Discharge (inc. Requisition No.):",wr,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     wb,"Problems / Risks Identified on Discharge:",wr2,reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
    "(e.g. Patient Self-Discharge; Housing/Environment Health risks or concerns;",
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
     " Other issues not addressed in hospital)",reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "  \bullet",fillstring(4," "),reol),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    line,reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
    "Form Electronically Signed By:"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr," ",
    trim(user_title)," ",trim(user_first),
    " ",trim(user_last),":",wr2,"  ",
    user_position),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol)
   IF (size(trim(user_bleep_no)) > 0)
    drec->line_qual[lidx].disp_line = concat(tabset0,rtab,"Bleep No. / Ext.: ",user_bleep_no,reol)
   ELSE
    drec->line_qual[lidx].disp_line = concat(tabset0,rtab,"Bleep No. / Ext.:____________",reol)
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
    reol,reol,wb,line,
    reol),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
    "Copy: ",wsub,"[Please Edit]",wr2,
    "     GP: Y/N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    Patient: Y/N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    Pharmacy: Y/N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    Coding: Y/N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
    "    Notes: Y/N"),
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
   IF (((cur_ward_cd=graham_ward_cd) OR (cur_ward_cd=cass_ward_cd)) )
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
     "CC: ",reol)
   ENDIF
   lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = reol
   IF (((findstring("wait list",cnvtlower(encntr_type))+ findstring("outpatient",cnvtlower(
     encntr_type))) > 0))
    lidx = 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(rhead,
     rhead1,rmarg,rh2r,wt,
     "Discharge Information form not produced:"),
    lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
     "Invalid Encounter Type (",trim(encntr_type),")")
   ENDIF
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
 SELECT INTO "cer_temp:DWK_Discharge_Summary"
  FROM (dummyt d  WITH seq = 1)
  FOOT REPORT
   reply->text
  WITH nocounter, maxcol = 32000
 ;end select
END GO
