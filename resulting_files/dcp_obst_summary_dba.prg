CREATE PROGRAM dcp_obst_summary:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH noconstant(" "), private
 ENDIF
 SET last_mod = "427022"
 DECLARE loop_baby = i4
 DECLARE loop_details = i4
 DECLARE lidx = i4
 DECLARE daliaspool = f8
 SET cnt = 0
 SET x = 0
 SET lidx = 0
 SET line = fillstring(145,"-")
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 RECORD reply(
   1 text = vc
 )
 SET rhead =
 "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Microsoft Sans Serif;}{\f1\fswiss Tahoma;}}\deflang2057\deflange2057"
 SET rhead1 =
 "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red150\green150\blue255;}\deftab1134"
 SET rmarg = "\margt1100\margb1100\margl1100\margr1100"
 SET rh2r = "\pard\plain\f1\fs12\cb2\sl0"
 SET rh2b = "\plain\i\b\f1\fs18\cf2\cb3\sl0"
 SET rh2c = "\plain\f1\fs16\cb2\sl0"
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET tqr = "\tqr"
 SET ctab = "\tqc "
 SET ra = "\qr"
 SET rm = "\margrsxn2000"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wr2 = " \plain \f0 \fs16 \cb2 "
 SET wb = " \plain \f0 \fs20 \b \cb2\lin600 "
 SET wt = " \plain \f1 \fs30 \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET tabset = "\pard\plain\ql\li0\ri0\widctlpar\tqr\tx3000"
 SET tabset0 = "\tqr \tx9600"
 SET tabset1 = "\tqc \tx6000 \tqr \tx11000"
 SET tabsetbaby1 = "\tqc \tx7200"
 SET tabsetbaby2 = "\tqr \tx11000"
 SET tabsetmother1 = "\tqc \tx4000"
 SET tabset2 = "\pard \plain \ql \li0\ ri0 \widctlpar \tqr \tx9600"
 SET tabset3 = "\tx4500"
 SET tabsetdrugs = "\tx4200 \tx5100 \tx6000 \tx6900 \tx7800 \tx8700 \tx9600"
 SET tabsetproblems = "\tx5070"
 SET tabsetbb1 = "\tx3000"
 SET tsbdm = "\tx7000"
 SET tsbdms = "\tx5500"
 SET tabsetmthrhist = "\tx2800"
 SET testtab = "\tb6500"
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
 SET cll0 = "\clbrdrl\brdrs\brdw0 "
 SET tblr0 = "\trbrdrr\brdrs\brdw0 "
 SET clt0 = "\clbrdrt\brdrs\brdw0 "
 SET clb0 = "\clbrdrb\brdrs\brdw0 "
 SET clr0 = "\clbrdrr\brdrs\brdw0 "
 SET newpage = "\page"
 DECLARE menc_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MATERNITY"))
 DECLARE nenc_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"NEWBORN"))
 DECLARE palias_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE pa2lias_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE eprcon = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mreltn = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",40,"MOTHER"))
 CALL echo(build("MRELTN->",mreltn))
 DECLARE bncode = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASBN"))
 DECLARE dhomeaddrcd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE dhomephonecd = f8 WITH public, noconstant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE dfinnbr = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE dfamily = f8 WITH public, noconstant(uar_get_code_by("MEANING",351,"FAMILY"))
 FREE SET data
 RECORD data(
   1 encntr_id = f8
   1 person_id = f8
   1 mdob = vc
   1 mfname = vc
   1 msname = vc
   1 mcnn = vc
   1 mnhs = vc
   1 building = vc
   1 madd = vc
   1 madd2 = vc
   1 madd3 = vc
   1 madd4 = vc
   1 mzip = c15
   1 mphone = vc
   1 mmobile = vc
   1 mconfname = vc
   1 mconsname = vc
   1 mgpsname = vc
   1 mgpphone = vc
   1 mgpadd = vc
   1 mgpadd2 = vc
   1 mgpadd3 = vc
   1 mgpadd4 = vc
   1 mgpzip = c15
   1 med_hist[*]
     2 list = vc
   1 allergies[*]
     2 list = vc
   1 post_natal_comps[*]
     2 list = vc
   1 methnicity = vc
   1 mbloodgrp = vc
   1 mrhesus = vc
   1 mhopathy = vc
   1 mantibodies = vc
   1 rubella = vc
   1 rubellaigg = vc
   1 rubellaigm = vc
   1 mvdrl = vc
   1 msmokeday = vc
   1 msmokbefore = vc
   1 mhep = vc
   1 mbmi = vc
   1 mdrinks = vc
   1 mprev_preg = vc
   1 mliveb = vc
   1 mstillb = vc
   1 mspontab = vc
   1 mantid = vc
   1 minducab = vc
   1 mneonat = vc
   1 smokedatbook = vc
   1 gestbookweeks = vc
   1 gestbookdays = vc
   1 test_bmi = vc
   1 exptdeldate = vc
   1 ultrasounfdate = vc
   1 feedingintbook = vc
   1 followup = vc
   1 details[*]
     2 person_id = f8
     2 encntr_id = f8
     2 person_details[1]
       3 newbsex = vc
       3 newbfname = vc
       3 newbsname = vc
       3 newbdob = vc
       3 newbtob = vc
       3 newbtob1 = vc
       3 newbcnn = vc
       3 newbnhs = vc
       3 newbweight = vc
       3 newbheadcirc = vc
       3 newbgest = vc
       3 newbresusc = vc
       3 newbvitk = vc
       3 newbcong = vc
       3 newbasstd = vc
       3 newbceord = vc
       3 newboutcome = vc
       3 newbbirthorder = vc
       3 nn4bweight = vc
       3 nn4bgest = vc
       3 newbapgar1 = vc
       3 newbapgar5 = vc
       3 newbapgar10 = vc
       3 newbmidwife = vc
       3 newbfeeding = vc
       3 newbantid = vc
       3 newbcord = vc
       3 newbbloodgrp = vc
       3 newbguthrie = vc
       3 newbbcg = vc
       3 newbrhesus = vc
       3 newbhopathy = vc
       3 newbfollowup = vc
       3 newburine = vc
       3 newbmeconium = vc
       3 newbparentid = f8
       3 eventdatetime = dq8
       3 newbonset = vc
       3 newbpresentation = vc
       3 newbdelmode = vc
       3 newbdelby = vc
       3 newbdura1 = vc
       3 newbdura2 = vc
       3 newbdura3 = vc
       3 newbbloodls = vc
       3 newbmembranes = vc
       3 newbplacenta = vc
       3 newbperistat = vc
       3 newbperisut = vc
       3 newbanalg = vc
       3 newbanasth = vc
       3 newbsmokdel = vc
       3 nvitalweight = vc
       3 complications[*]
         4 list = vc
 )
 DECLARE cnn_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",263,"MRN"))
 DECLARE cnn_code = f8
 SET cnn_code = cnn_cd
 DECLARE sfacilitydisp = vc
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (e.encntr_id=request->visit[1].encntr_id)
  DETAIL
   sfacilitydisp = uar_get_code_display(e.loc_facility_cd)
  WITH nocounter, time = 10000
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_alias pa1,
   encntr_prsnl_reltn epr,
   prsnl p1,
   address a,
   phone ph
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa1
   WHERE pa1.person_id=p.person_id
    AND pa1.active_ind=1
    AND pa1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=eprcon
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p1
   WHERE p1.person_id=epr.prsnl_person_id
    AND p1.active_ind=1
    AND p1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE a.parent_entity_id=e.person_id
    AND a.address_type_cd=dhomeaddrcd
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(e.person_id))
    AND (ph.phone_type_cd= Outerjoin(dhomephonecd))
    AND (ph.active_ind= Outerjoin(1))
    AND (ph.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  DETAIL
   data->encntr_id = e.encntr_id, data->person_id = e.person_id, data->mfname = trim(p
    .name_full_formatted),
   data->msname = trim(p.name_last_key), data->mdob = format(p.birth_dt_tm,"DD-MMM-YYYY;;D"), data->
   building = trim(uar_get_code_description(e.loc_building_cd)),
   data->madd = trim(a.street_addr), data->madd2 = trim(a.street_addr2), data->madd3 = trim(a
    .street_addr3),
   data->madd4 = trim(a.street_addr4), data->mzip = a.zipcode, data->mphone = trim(ph.phone_num),
   data->mconfname = trim(p1.name_first_key), data->mconsname = trim(p1.name_last_key), data->
   methnicity = trim(uar_get_code_display(p.ethnic_grp_cd))
   IF (pa1.alias_pool_cd=cnn_code)
    data->mcnn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
   ENDIF
   IF (pa1.person_alias_type_cd=pa2lias_type)
    data->mnhs = cnvtalias(pa1.alias,pa1.alias_pool_cd)
   ENDIF
  WITH time = 10000, nocounter
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
 SET psreply->entity[1].person_id = data->person_id
 SET psrequest->load.gp_flag = 2
 SET psrequest->load.practice_add_flag = 1
 EXECUTE ukr_get_prsnl  WITH replace(request,psrequest), replace(reply,psreply)
 SET data->mgpadd = psreply->entity[1].gp.practice.address.street1
 SET data->mgpadd2 = psreply->entity[1].gp.practice.address.street2
 SET data->mgpadd3 = psreply->entity[1].gp.practice.address.street3
 SET data->mgpadd4 = psreply->entity[1].gp.practice.address.street4
 SET data->mgpzip = psreply->entity[1].gp.practice.address.postcode
 SET data->mgpphone = psreply->entity[1].gp.practice.phone
 SET data->mgpsname = psreply->entity[1].gp.name_full_formatted
 FREE RECORD psrequest
 FREE RECORD psreply
 DECLARE smoking_day = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFCIGARETTESPERDAYNOW"))
 DECLARE smoked_before_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "TOBACCOUSEWITHIN1YEAROFPREGNANCY"))
 DECLARE drinks_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ALCOHOLUSE"))
 DECLARE bmi_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEXMETRIC"))
 DECLARE mfollow = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HOSPITALFOLLOWUP"))
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND datetimecmp(cnvtdatetime(curdate,0),ce.valid_from_dt_tm) < 210
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   IF (ce.event_cd=smoking_day)
    data->msmokeday = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=smoked_before_cd)
    data->msmokbefore = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=drinks_cd)
    data->mdrinks = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=bmi_cd)
    data->mbmi = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=mfollow)
    data->followup = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE prev_preg_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFPREVIOUSPREGNANCIES"))
 DECLARE live_birth_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFLIVEBIRTHS"))
 DECLARE still_birth_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFSTILLBIRTHS"))
 DECLARE ind_abor_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFINDUCEDABORTIONS"))
 DECLARE spont_abor_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFSPONTANEOUSABORTIONS"))
 DECLARE neo_natal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFNEONATALDEATHS"))
 DECLARE vdrl_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"TREPONEMAPALLIDUMAB"))
 DECLARE hopathy_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "HAEMOGLOBINOPATHYTEST"))
 DECLARE hepatitis_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HEPBTEST"))
 DECLARE rubellaigg_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RUBELAIGG"))
 DECLARE rubellaigm_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RUBELAIGM"))
 DECLARE rubella_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RUBELLAAVIDITY"))
 DECLARE rhesus2_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RHESUS"))
 DECLARE antibodies_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"SC"))
 DECLARE blood_grp_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ABOONLY"))
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND datetimecmp(cnvtdatetime(curdate,0),ce.valid_from_dt_tm) < 210
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   IF (ce.event_cd=prev_preg_cd)
    data->mprev_preg = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=live_birth_cd)
    data->mliveb = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=still_birth_cd)
    data->mstillb = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=ind_abor_cd)
    data->minducab = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=spont_abor_cd)
    data->mspontab = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=neo_natal_cd)
    data->mneonat = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=vdrl_cd)
    data->mvdrl = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=hopathy_cd)
    data->mhopathy = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=hepatitis_cd)
    data->mhep = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=rubella_cd)
    data->rubella = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=rubellaigg_cd)
    data->rubellaigg = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=rubellaigm_cd)
    data->rubellaigm = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=rhesus2_cd)
    data->mrhesus = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=antibodies_cd)
    data->mantibodies = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=blood_grp_nb_cd)
    data->mbloodgrp = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE smoked_booking_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "TOBACCOUSENOW"))
 DECLARE gestation_booking_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "GESTATIONWEEKS"))
 DECLARE expected_del_date_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDDATEOFDELIVERY"))
 DECLARE ultrasound_booking_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "ULTRASOUNDDATETIME"))
 DECLARE feeding_intention_booking_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FEEDINGINTENTIONATBOOKING"))
 DECLARE gestation_booking_days_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "GESTATIONDAYS"))
 DECLARE bmi_cdd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEXMETRIC"))
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND datetimecmp(cnvtdatetime(curdate,0),ce.valid_from_dt_tm) < 210
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   IF (ce.event_cd=smoked_booking_cd)
    data->smokedatbook = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=gestation_booking_cd)
    data->gestbookweeks = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=expected_del_date_cd)
    data->exptdeldate = concat(substring(9,2,ce.result_val),"/",substring(7,2,ce.result_val),"/",
     substring(3,4,ce.result_val))
   ENDIF
   IF (ce.event_cd=ultrasound_booking_cd)
    data->ultrasounfdate = concat(substring(9,2,ce.result_val),"/",substring(7,2,ce.result_val),"/",
     substring(3,4,ce.result_val))
   ENDIF
   IF (ce.event_cd=feeding_intention_booking_cd)
    data->feedingintbook = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=gestation_booking_days_cd)
    data->gestbookdays = trim(ce.result_val)
   ENDIF
   IF (ce.event_cd=bmi_cdd)
    data->test_bmi = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 SET medhcount = 0
 DECLARE chicken_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"CHICKENPOX"))
 DECLARE congen_abnormal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "CONGENITALABNORMALITIES"))
 DECLARE sanguinity_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"CONSANGUINITY"))
 DECLARE deep_vein_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "DEEPVEINTHROMBOSIS"))
 DECLARE diabetes_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"DIABETES"))
 DECLARE epilepsy_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"EPILEPSY"))
 DECLARE heart_disease_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HEARTDISEASE"
   ))
 DECLARE hepatitis_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HEPATITIS"))
 DECLARE hyper_tension_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HYPERTENSION"
   ))
 DECLARE kidney_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"KIDNEY"))
 DECLARE mulit_birth_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"MULTIPLEBIRTHS"
   ))
 DECLARE psyc_tricmmh_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PSYCHIATRICMMH"))
 DECLARE pulm_embol_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYEMBOLUS"))
 DECLARE rheum_fever_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RHEUMATICFEVER"
   ))
 DECLARE thyroid_disease_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "THYROIDDISEASE"))
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=data->person_id)
    AND datetimecmp(cnvtdatetime(curdate,0),ce.valid_from_dt_tm) < 210
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.event_cd IN (chicken_cd, congen_abnormal_cd, sanguinity_cd, deep_vein_cd, diabetes_cd,
   epilepsy_cd, heart_disease_cd, hepatitis_cd, hyper_tension_cd, kidney_cd,
   mulit_birth_cd, psyc_tricmmh_cd, pulm_embol_cd, rheum_fever_cd, thyroid_disease_cd)
    AND substring(1,4,ce.result_val)="Self"
    AND trim(ce.result_val) != "")
  DETAIL
   medhcount += 1, stat = alterlist(data->med_hist,medhcount), data->med_hist[medhcount].list = trim(
    uar_get_code_display(ce.event_cd))
 ;end select
 SET med_hist_count = medhcount
 SET tempcount = 0
 DECLARE active_allergy_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 SET tempcount = 0
 SELECT DISTINCT INTO "nl:"
  nom.source_string
  FROM allergy a,
   nomenclature nom
  PLAN (a
   WHERE (a.person_id=data->person_id)
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,0)
    AND a.reaction_status_cd=active_allergy_cd
    AND ((a.cancel_dt_tm = null) OR (a.cancel_dt_tm >= cnvtdatetime((curdate+ 1),0))) )
   JOIN (nom
   WHERE nom.nomenclature_id=a.substance_nom_id)
  ORDER BY nom.source_string
  DETAIL
   tempcount += 1, stat = alterlist(data->allergies,tempcount), data->allergies[tempcount].list =
   trim(cnvtcap(nom.source_string))
  WITH nocounter, time = 10000
 ;end select
 SET allergy_count = tempcount
 SET pnccount = 0
 DECLARE retent_furine_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "RETENTIONOFURINE"))
 DECLARE infection_breast_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIONOFBREAST"))
 DECLARE infection_gentract_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIONOFGENITALTRACT"))
 DECLARE infection_urinary_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIONOFURINARYTRACT"))
 DECLARE infection_wound_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIONOFWOUND"))
 DECLARE infection_other_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFECTIONOTHER"))
 DECLARE deep_vein_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "DEEPVEINTHROMBOSIS"))
 DECLARE pulm_embolism_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYEMBOLISM"))
 DECLARE haematoma_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"HAEMATOMA"))
 DECLARE persis_hyper_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PERSISTENTHYPERTENSION"))
 DECLARE anaemia_postnatal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "ANAEMIAPOSTNATAL"))
 DECLARE blood_trans_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODTRANSFUSIONGIVEN"))
 DECLARE erpc_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ERPC"))
 DECLARE primary_pph_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"PRIMARYPPH"))
 DECLARE secondary_pph_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"SECONDARYPPH"
   ))
 DECLARE other_surg_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"OTHERSURGERY"))
 DECLARE sterilisation_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "STERILISATION"))
 DECLARE svt_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"SVT"))
 DECLARE depression_postnatal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "MILDDEPRESSIONPOSTNATAL"))
 DECLARE psychref_postnatal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "PSYCHIATRICREFERRALPOSTNATAL"))
 DECLARE socialref_postnatal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "SOCIALWORKERREFERRALPOSTNATAL"))
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.event_cd IN (retent_furine_cd, infection_breast_cd, infection_gentract_cd,
   infection_urinary_cd, infection_wound_cd,
   infection_other_cd, deep_vein_cd, pulm_embolism_cd, haematoma_cd, persis_hyper_cd,
   anaemia_postnatal_cd, blood_trans_cd, erpc_cd, primary_pph_cd, secondary_pph_cd,
   other_surg_cd, sterilisation_cd, svt_cd, depression_postnatal_cd, psychref_postnatal_cd,
   socialref_postnatal_cd)
    AND trim(ce.result_val) != "")
  DETAIL
   pnccount += 1, stat = alterlist(data->post_natal_comps,pnccount), data->post_natal_comps[pnccount]
   .list = trim(uar_get_code_display(ce.event_cd))
  WITH nocounter
 ;end select
 SET post_natal_count = pnccount
 SET loop_baby = 0
 SET daliaspool = 0.0
 SELECT INTO "nl:"
  FROM encounter e,
   org_alias_pool_reltn oapr
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1
    AND ((e.reg_dt_tm+ 0) != null))
   JOIN (oapr
   WHERE oapr.organization_id=e.organization_id
    AND ((oapr.alias_entity_alias_type_cd+ 0)=dfinnbr)
    AND oapr.alias_entity_name="ENCNTR_ALIAS")
  DETAIL
   daliaspool = oapr.alias_pool_cd
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM encntr_alias ea1,
   encntr_alias ea2,
   encounter e,
   person_person_reltn ppr
  PLAN (ea1
   WHERE (ea1.encntr_id=request->visit[1].encntr_id)
    AND ea1.alias_pool_cd=daliaspool
    AND ea1.encntr_alias_type_cd=dfinnbr
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ea2
   WHERE ea2.alias=ea1.alias
    AND ea2.alias_pool_cd=daliaspool
    AND ea2.encntr_alias_type_cd=dfinnbr
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=ea2.encntr_id
    AND e.active_ind=1
    AND e.reg_dt_tm != null)
   JOIN (ppr
   WHERE ppr.person_id=e.person_id
    AND ppr.person_reltn_cd=mreltn
    AND ppr.person_reltn_type_cd=dfamily
    AND ppr.active_ind=1
    AND datetimecmp(cnvtdatetime(curdate,0),ppr.beg_effective_dt_tm) < 210)
  DETAIL
   loop_baby += 1, stat = alterlist(data->details,loop_baby), data->details[loop_baby].encntr_id = e
   .encntr_id,
   data->details[loop_baby].person_id = e.person_id
  WITH nocounter
 ;end select
 DECLARE casenote = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE nhsssn = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 SET initc = size(data->details,5)
 CALL echo(initc)
 SET neo_natal_count = 0
 FOR (detcnt = 1 TO initc)
   SELECT INTO "nl:"
    FROM person p,
     person_alias pa
    PLAN (p
     WHERE (p.person_id=data->details[detcnt].person_id)
      AND p.active_ind=1)
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     stat = alter(data->details[detcnt].person_details,1), data->details[detcnt].person_details.
     newbsex = trim(uar_get_code_display(p.sex_cd)), data->details[detcnt].person_details.newbfname
      = p.name_full_formatted,
     data->details[detcnt].person_details.newbsname = trim(p.name_last_key), data->details[detcnt].
     person_details.newbdob = format(p.birth_dt_tm,"DD-MMM-YYYY;;D"), data->details[detcnt].
     person_details.newbtob1 = format(p.birth_dt_tm,"HH:MM;;d")
     IF (pa.person_alias_type_cd=casenote)
      data->details[detcnt].person_details.newbcnn = cnvtalias(pa.alias,pa.alias_pool_cd)
     ENDIF
     IF (pa.person_alias_type_cd=nhsssn)
      data->details[detcnt].person_details.newbnhs = cnvtalias(pa.alias,pa.alias_pool_cd)
     ENDIF
    WITH nocounter
   ;end select
   SET nnccount = 0
   DECLARE congen_infection_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "CONGENITALINFECTION"))
   DECLARE infection_cord_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "INFECTIONOFCORD"))
   DECLARE infection_eye_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "INFECTIONOFEYE"))
   DECLARE infection_skin_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "INFECTIONOFSKIN"))
   DECLARE oral_infection_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ORALINFECTION"))
   DECLARE sysic_infection_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "SYSTEMICINFECTION"))
   DECLARE abnormal_bleed_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ABNORMALBLEEDING"))
   DECLARE abnormal_hips_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ABNORMALITYOFHIPS"))
   DECLARE anaemia_postnatal_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ANAEMIAPOSTNATAL"))
   DECLARE anaemia_newborn_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ANAEMIANEWBORN"))
   DECLARE birth_trauma_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BIRTHTRAUMA"
     ))
   DECLARE blood_given_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "BLOODTRANSFUSIONGIVEN"))
   DECLARE convulsions_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"CONVULSIONS")
    )
   DECLARE grow_retardation_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "GROWTHRETARDATION"))
   DECLARE inborn_disorder_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "INBORNMETABOLICDISORDER"))
   DECLARE jaundice_photother_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "JAUNDICEREQUIRINGPHOTOTHERAPY"))
   DECLARE feeding_difficulties_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "MAJORFEEDINGDIFFICULTIES"))
   DECLARE maternal_drug_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "MATERNALDRUGEFFECTS"))
   DECLARE resp_difficulty_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "RESPIRATORYDIFFICULTY"))
   SELECT DISTINCT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.encntr_id=data->details[detcnt].encntr_id)
      AND ce.valid_from_dt_tm < cnvtdatetime(sysdate)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.event_cd IN (congen_infection_cd, infection_cord_cd, infection_eye_cd, infection_skin_cd,
     oral_infection_cd,
     sysic_infection_cd, abnormal_bleed_cd, abnormal_hips_cd, anaemia_postnatal_cd,
     anaemia_newborn_cd,
     birth_trauma_cd, blood_given_cd, convulsions_cd, grow_retardation_cd, inborn_disorder_cd,
     jaundice_photother_cd, feeding_difficulties_cd, maternal_drug_cd, resp_difficulty_cd)
      AND trim(ce.result_val) != "")
    DETAIL
     nnccount += 1, stat = alterlist(data->details[detcnt].person_details[1].complications,nnccount),
     data->details[detcnt].person_details.complications[nnccount].list = trim(uar_get_code_display(ce
       .event_cd))
    WITH nocounter
   ;end select
   SET neo_natal_count = nnccount
   DECLARE baby_weight_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BIRTHWEIGHTG"
     ))
   DECLARE head_circ_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "HEADCIRCUMFERENCE"))
   DECLARE gestation_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "GESTATIONATBIRTH"))
   DECLARE resc_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "RESUSCITATIONDETAILS"))
   DECLARE vit_k_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"VITAMINKGIVEN"))
   DECLARE apgaronecd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"APGARSCORE1MIN"))
   DECLARE apgartwocd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"APGARSCORE5MIN"))
   DECLARE apgarthreecd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "APGARSCORE10MIN"))
   DECLARE feeding_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "TYPEOFFEEDINGATBIRTH"))
   DECLARE cord_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"CORDON"))
   DECLARE guthrie_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "GUTHRIESAMPLETAKEN"))
   DECLARE bcg_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BCGVACCINEGIVEN"))
   DECLARE follow_up_nb_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "HOSPITALFOLLOWUP"))
   DECLARE passed_urine_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "PASSEDURINENEWBORN"))
   DECLARE passed_meconium_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "PASSEDMECONIUM"))
   DECLARE tobcd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYDATETIME"))
   DECLARE brthordcd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"BIRTHORDER"))
   DECLARE rhesus_grp_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"RHESUS"))
   DECLARE hopathy_grp_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "HAEMOGLOBINOPATHYTEST"))
   SELECT INTO "nl:"
    FROM encounter e,
     clinical_event ce
    PLAN (e
     WHERE (e.encntr_id=data->details[detcnt].encntr_id)
      AND e.active_ind=1)
     JOIN (ce
     WHERE (ce.encntr_id= Outerjoin(e.encntr_id))
      AND (ce.valid_from_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
      AND (ce.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    DETAIL
     stat = alter(data->details[detcnt].person_details,1)
     IF (ce.event_cd=baby_weight_cd)
      data->details[detcnt].person_details.newbweight = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=head_circ_cd)
      data->details[detcnt].person_details.newbheadcirc = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=gestation_cd)
      data->details[detcnt].person_details.newbgest = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=resc_cd)
      data->details[detcnt].person_details.newbresusc = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=vit_k_cd)
      data->details[detcnt].person_details.newbvitk = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=apgaronecd)
      data->details[detcnt].person_details.newbapgar1 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=apgartwocd)
      data->details[detcnt].person_details.newbapgar5 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=apgarthreecd)
      data->details[detcnt].person_details.newbapgar10 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=feeding_nb_cd)
      data->details[detcnt].person_details.newbfeeding = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=cord_nb_cd)
      data->details[detcnt].person_details.newbcord = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=guthrie_nb_cd)
      data->details[detcnt].person_details.newbguthrie = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=blood_grp_nb_cd)
      data->details[detcnt].person_details.newbbloodgrp = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=rhesus_grp_cd)
      data->details[detcnt].person_details.newbrhesus = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=hopathy_grp_cd)
      data->details[detcnt].person_details.newbhopathy = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=bcg_nb_cd)
      data->details[detcnt].person_details.newbbcg = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=follow_up_nb_cd)
      data->details[detcnt].person_details.newbfollowup = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=passed_urine_cd)
      data->details[detcnt].person_details.newburine = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=passed_meconium_cd)
      data->details[detcnt].person_details.newbmeconium = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=tobcd)
      data->details[detcnt].person_details.newbtob = concat(substring(11,2,ce.result_val),":",
       substring(13,2,ce.result_val))
     ENDIF
     IF (ce.event_cd=brthordcd)
      data->details[detcnt].person_details.newbceord = trim(ce.result_val)
     ENDIF
    WITH nocounter, time = 10000
   ;end select
   DECLARE congab = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASSCA"))
   DECLARE nn4bgest = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASGLLO"))
   SELECT INTO "nl:"
    FROM person_patient pp,
     encntr_info ei
    PLAN (ei
     WHERE (ei.encntr_id=data->details[detcnt].encntr_id))
     JOIN (pp
     WHERE (pp.person_id=data->details[detcnt].person_id)
      AND pp.active_ind=1)
    DETAIL
     stat = alter(data->details[detcnt].person_details,1)
     IF (pp.birth_order_cd > 0.0)
      data->details[detcnt].person_details.newbbirthorder = trim(uar_get_code_display(pp
        .birth_order_cd),3)
     ELSE
      data->details[detcnt].person_details.newbbirthorder = cnvtstring(pp.birth_order)
     ENDIF
     data->details[detcnt].person_details.nn4bweight = cnvtstring(pp.birth_weight)
     IF (ei.info_sub_type_cd=congab)
      data->details[detcnt].person_details.newbcong = trim(uar_get_code_display(ei.value_cd))
     ENDIF
     IF (ei.info_sub_type_cd=nn4bgest)
      data->details[detcnt].person_details.nn4bgest = trim(uar_get_code_display(ei.value_cd))
     ENDIF
   ;end select
   DECLARE auth_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"AUTH"))
   DECLARE mod_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"MODIFIED"))
   SET mbrthordcd = uar_get_code_by("DISPLAYKEY",72,"BIRTHORDER")
   SELECT INTO "nl:"
    FROM encounter e,
     clinical_event ce,
     clinical_event ce2,
     clinical_event ce3
    PLAN (e
     WHERE (e.encntr_id=request->visit[1].encntr_id)
      AND e.active_ind=1)
     JOIN (ce
     WHERE ce.encntr_id=e.encntr_id
      AND ce.event_cd=mbrthordcd
      AND (ce.result_val=data->details[detcnt].person_details.newbbirthorder)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.result_status_cd IN (auth_cd, mod_cd))
     JOIN (ce2
     WHERE ce2.encntr_id=ce.encntr_id
      AND ce2.event_id=ce.parent_event_id
      AND ce2.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce2.result_status_cd IN (auth_cd, mod_cd))
     JOIN (ce3
     WHERE ce3.encntr_id=ce.encntr_id
      AND ce3.event_id=ce2.parent_event_id
      AND ce3.event_title_text="Maternal Delivery Detail")
    DETAIL
     stat = alter(data->details[detcnt].person_details,1), data->details[detcnt].person_details.
     newbparentid = ce3.event_id
   ;end select
   DECLARE midwifecd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"MIDWIFE"))
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_prsnl_reltn epr,
     prsnl p
    PLAN (e
     WHERE (e.encntr_id=data->details[detcnt].encntr_id)
      AND e.active_ind=1)
     JOIN (epr
     WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
      AND (epr.encntr_prsnl_r_cd= Outerjoin(midwifecd)) )
     JOIN (p
     WHERE (p.person_id= Outerjoin(epr.prsnl_person_id))
      AND (p.active_ind= Outerjoin(1)) )
    DETAIL
     stat = alter(data->details[detcnt].person_details,1), data->details[detcnt].person_details.
     newbmidwife = trim(p.name_full_formatted)
    WITH time = 10000
   ;end select
   DECLARE blood_loss_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "DELIVERYBLOODLOSS"))
   DECLARE onset = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ONSETOFLABOUR"))
   DECLARE presentation = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"PRESENTATION"))
   DECLARE del_mode_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "METHODOFDELIVERY"))
   DECLARE delvd_by_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"DELIVEREDBY"))
   DECLARE dura1_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"STAGEITOTAL"))
   DECLARE dura2_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"STAGEIITOTAL"))
   DECLARE dura3_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"STAGEIIITOTAL"))
   DECLARE membranes_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"MEMBRANES"))
   DECLARE placenta_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"PLACENTA"))
   DECLARE per_status_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"PERINEUM"))
   DECLARE per_sutured_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"SUTURED"))
   DECLARE analgesia_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ANALGESIA"))
   DECLARE anaesthesia_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "ANAESTHESIADURINGLABOUR"))
   DECLARE smoke_del_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "SMOKINGATDELIVERY"))
   DECLARE antid = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"ANTIDGIVEN"))
   DECLARE indassdelcd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "INDICATIONFORASSISTEDDELIVERY"))
   DECLARE outcomecd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"OUTCOME"))
   SELECT INTO "nl:"
    FROM encounter e,
     clinical_event ce,
     clinical_event ce2
    PLAN (e
     WHERE (e.encntr_id=request->visit[1].encntr_id)
      AND e.active_ind=1)
     JOIN (ce2
     WHERE ce2.encntr_id=e.encntr_id
      AND (ce2.parent_event_id=data->details[detcnt].person_details.newbparentid))
     JOIN (ce
     WHERE ce.parent_event_id=ce2.event_id
      AND ce.result_status_cd IN (auth_cd, mod_cd))
    DETAIL
     stat = alter(data->details[detcnt].person_details,1)
     IF (ce.event_cd=blood_loss_cd)
      data->details[detcnt].person_details.newbbloodls = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=onset)
      data->details[detcnt].person_details.newbonset = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=presentation)
      data->details[detcnt].person_details.newbpresentation = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=del_mode_cd)
      data->details[detcnt].person_details.newbdelmode = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=delvd_by_cd)
      data->details[detcnt].person_details.newbdelby = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=dura1_cd)
      data->details[detcnt].person_details.newbdura1 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=dura2_cd)
      data->details[detcnt].person_details.newbdura2 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=dura3_cd)
      data->details[detcnt].person_details.newbdura3 = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=membranes_cd)
      data->details[detcnt].person_details.newbmembranes = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=placenta_cd)
      data->details[detcnt].person_details.newbplacenta = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=per_status_cd)
      data->details[detcnt].person_details.newbperistat = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=per_sutured_cd)
      data->details[detcnt].person_details.newbperisut = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=analgesia_cd)
      data->details[detcnt].person_details.newbanalg = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=anaesthesia_cd)
      data->details[detcnt].person_details.newbanasth = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=smoke_del_cd)
      data->details[detcnt].person_details.newbsmokdel = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=antid)
      data->details[detcnt].person_details.newbantid = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=indassdelcd)
      data->details[detcnt].person_details.newbasstd = trim(ce.result_val)
     ENDIF
     IF (ce.event_cd=outcomecd)
      data->details[detcnt].person_details.newboutcome = trim(ce.result_val)
     ENDIF
    WITH nocounter
   ;end select
   DECLARE vitalweight = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTKG"))
   SELECT INTO "nl:"
    FROM encounter e,
     clinical_event ce
    PLAN (e
     WHERE (e.encntr_id=data->details[detcnt].encntr_id)
      AND e.active_ind=1
      AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ce
     WHERE (ce.encntr_id= Outerjoin(e.encntr_id))
      AND (ce.event_cd= Outerjoin(vitalweight))
      AND (ce.valid_from_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
      AND (ce.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    DETAIL
     stat = alter(data->details[detcnt].person_details,1), data->details[detcnt].person_details.
     nvitalweight = trim(ce.result_val)
    WITH nocounter
   ;end select
 ENDFOR
 SET building = data->building
 SET formsize = size(data->details,5)
 IF (formsize=0)
  SET formsize = 1
 ENDIF
 SET formcnt = 0
 CALL echo("LISA")
 CALL echo(formsize)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   FOR (formcnt = 1 TO formsize)
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      rhead,rhead1,rmarg,rh2r,wt,
      "\tqc\tx4800\tqr\tx9600",rtab),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      sfacilitydisp,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      rtab,"Obstetric Summary",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      line,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "MOTHER"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tabsetmother1,wr,rtab,trim(data->mcnn),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      data->mfname)
     IF ((data->mnhs=""))
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       tabsetmother1,rtab,wr,"No NHS Number",reol,
       reol)
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       tabsetmother1,rtab,wr,trim(data->mnhs),reol,
       reol)
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->madd),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->madd2),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->madd3),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->madd4),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "BABY"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tsbdm,wr,rtab,trim(data->details[formcnt].person_details.newbcnn),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbfname))
     IF ((data->details[formcnt].person_details.newbnhs=""))
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       tsbdm,rtab,wr,"No NHS Number",reol,
       reol)
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       tsbdm,rtab,wr,trim(data->details[formcnt].person_details.newbnhs),reol,
       reol)
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Sex: ",wr,trim(data->details[formcnt].person_details.newbsex)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tsbdm,rtab,wb,"DOB: ",wr,
      trim(data->details[formcnt].person_details.newbdob),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Birth Order: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      data->details[formcnt].person_details.newbbirthorder),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tsbdm,rtab,wb,"Time of Birth:"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbtob1),reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "NEWBORN DETAILS"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row \li540",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx6500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->mzip)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tabsetmthrhist,rtab,wb,"DOB: ",wr,
      trim(data->mdob),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Tel. ",wr,trim(data->mphone),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Cons. ",wr,trim(data->mconfname)," ",
      trim(data->mconsname)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Outcome: ",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Weight: ",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Head Circ.:",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Gestation:",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newboutcome),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.nn4bweight),"    g",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbheadcirc),"      cms",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbgest),"      wks",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row\li540",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx2500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "MATERNAL HISTORY",reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Ethnic Group: ",wr,trim(data->methnicity),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Blood Group: ",wr,trim(data->mbloodgrp),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Haem'opathy: ",wr,trim(data->mhopathy),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Rubella IgG: ",wr,trim(data->rubellaigg),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Rubella IgM: ",wr,trim(data->rubellaigm),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Rubella Avidity: ",wr,trim(data->rubella),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Smoking Day: ",wr,trim(data->msmokeday),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Smoked before: ",wr,trim(data->msmokbefore),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Drinks: ",wr,trim(data->mdrinks),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Allergies: ",reol)
     IF (allergy_count > 0)
      FOR (forcount5 = 1 TO allergy_count)
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wr2,trim(data->allergies[forcount5].list),"; ")
      ENDFOR
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "None.")
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
      reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Rhesus: ",wr,trim(data->mrhesus),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Antibodies: ",wr,trim(data->mantibodies),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Hepatitis: ",wr,trim(data->mhep),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "V.D.R.L. ",wr,trim(data->mvdrl),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "BMI: ",wr,trim(data->mbmi),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Medical History: ",reol)
     IF (med_hist_count > 0)
      FOR (forcount3 = 1 TO med_hist_count)
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wr2,trim(data->med_hist[forcount3].list),"; ")
      ENDFOR
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "None.")
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Resusc.: ",wr,trim(data->details[formcnt].person_details.newbresusc),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Vitamin K Given? ",wr,trim(data->details[formcnt].person_details.newbvitk),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Congenital Abnormalities: ",wr,trim(data->details[formcnt].person_details.newbcong)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Indication for Assisted Delivery:",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbasstd),reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Apgar: ","   1m",wr,trim(data->details[formcnt].person_details.newbapgar1)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "             5m",wr,trim(data->details[formcnt].person_details.newbapgar5)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "             10m"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbapgar10),reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "MIDWIFE ",wr,trim(data->details[formcnt].person_details.newbmidwife),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Signature "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row\li540",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "OBSTETRIC HISTORY",reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "No. of Previous Pregnancies ",wr,trim(data->mprev_preg),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "No. of Live Births ",wr,trim(data->mliveb),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "No. of Still Births ",wr,trim(data->mstillb),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "No. of Abortions - "," Spont. ",wr,trim(data->mspontab)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "   Induc. ",wr,trim(data->minducab),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "No. of Neo-natal Deaths ",wr,trim(data->mneonat),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "G.P. DETAILS",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Name. ",wr,trim(data->mgpsname)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "                     Tel:",wr,trim(data->mgpphone),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Addr.   ",wr,trim(data->mgpadd),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      "               ",trim(data->mgpadd2),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      "               ",trim(data->mgpadd3),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      "               ",trim(data->mgpadd4),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      "               ",trim(data->mgpzip)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row\li540",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx7750"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "BOOKING INFO",reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Smoked at Booking:  ",wr,trim(data->smokedatbook),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Gestation at Booking:  ",wr,trim(data->gestbookweeks),"w "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->gestbookdays),"d",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Expected Del. Date:  ",wr,trim(data->exptdeldate),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Ultrasound:  ",wr,trim(data->ultrasounfdate),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Feeding Intention:  ",wr,trim(data->feedingintbook),reol,
      reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      "LABOUR & DELIVERY"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wbu,
      reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Weight (KG): "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.nvitalweight),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Blood Group:",wr,trim(data->details[formcnt].person_details.newbbloodgrp),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Rhesus:",wr,trim(data->details[formcnt].person_details.newbrhesus),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Feeding: ",wr,trim(data->details[formcnt].person_details.newbfeeding),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Passed Meconium: ",wr,trim(data->details[formcnt].person_details.newbmeconium),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol
      ),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol,
      wb,"BCG:               "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbbcg),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      " H'opathy:              "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbhopathy),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      " Guthrie:           "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbguthrie),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      " Cord:               "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbcord),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      " Passed Urine: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      data->details[formcnt].person_details.newburine,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row\li540",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\trowd \trgaph100",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      tblt0,tbll0,tblb0,tblr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx5000"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(clt0,
      cll0,clb0,clr0),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\cellx10500"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
      "\li0\intab"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Onset: ",wr,trim(data->details[formcnt].person_details.newbonset),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Presentation: ",wr,trim(data->details[formcnt].person_details.newbpresentation),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Delivery Mode: ",wr,trim(data->details[formcnt].person_details.newbdelmode),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Delivered by: ",wr,trim(data->details[formcnt].person_details.newbdelby),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Duration:                       ","1st. "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbdura1)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      "              ",wb,"2nd. "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbdura2),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "    (mn)                          ","3rd. "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbdura3),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Blood Loss (ml): "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbbloodls),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Membranes: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbmembranes),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Placenta: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbplacenta),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Perineum Status: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbperistat),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Perineum Sutured: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbperisut),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Analgesia: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbanalg),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Anaesthesia: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbanasth),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Smoking at Delivery: "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbsmokdel)),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = "\cell",
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Maternal Post-natal Complications:",reol)
     IF (post_natal_count > 0)
      FOR (forcount1 = 1 TO post_natal_count)
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wr2,trim(data->post_natal_comps[forcount1].list),"; ")
      ENDFOR
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "None.")
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol
      ),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Neo-natal Complications:",reol)
     IF (neo_natal_count > 0)
      FOR (forcount2 = 1 TO neo_natal_count)
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wr2,trim(data->details[formcnt].person_details.complications[forcount2].list),"; ")
      ENDFOR
     ELSE
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr2,
       "None.")
     ENDIF
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(reol
      ),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Hospital follow up mother?",wr," ",trim(data->followup),
      reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "                                Baby?    "),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wr,
      trim(data->details[formcnt].person_details.newbfollowup),reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Mother's address different?",reol,reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Date of Transfer - Mother:  ",wi,"(Please Type)",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "                              Baby:",wi,"     (Please Type)",reol,
      reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "Date of Discharge: ",wi,"(Please Type)",reol),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb,
      "              Signature:"),
     lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line =
     "\cell\row\li540"
     IF (formsize > 1)
      lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
       newpage)
     ENDIF
   ENDFOR
  FOOT REPORT
   FOR (z = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[z].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 132, maxrow = 500
 ;end select
 SET reply->text = concat(reply->text,rtfeof)
 SELECT INTO "obtest.rtf"
  FROM (dummyt d  WITH seq = 1)
  FOOT REPORT
   reply->text
  WITH nocounter, maxcol = 32000
 ;end select
 CALL echorecord(drec)
 CALL echo(reply->text)
END GO
