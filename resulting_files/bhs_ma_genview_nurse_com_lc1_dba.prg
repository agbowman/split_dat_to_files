CREATE PROGRAM bhs_ma_genview_nurse_com_lc1:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 20499627
  SET request->visit_cnt = 1
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
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 category = i2
     2 category_name = vc
     2 result_sort = i2
     2 result_display = vc
     2 result_date = vc
     2 result = vc
     2 result_id = f8
 )
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 DECLARE last_title = vc WITH public, noconstant(" ")
 DECLARE title_string = vc WITH public, noconstant(" ")
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE temp = vc WITH public, noconstant(" ")
 DECLARE print_string = vc WITH public, noconstant(" ")
 DECLARE line1 = vc WITH public, constant(fillstring(100,"_"))
 DECLARE filler = vc WITH public, constant(fillstring(100," "))
 DECLARE line2 = vc WITH public, noconstant(" ")
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE thighcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "THIGHCIRCUMFERENCE"))
 DECLARE calfcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CALFCIRCUMFERENCE"))
 DECLARE bodymassindex_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")
  )
 DECLARE chestcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHESTCIRCUMFERENCE"))
 DECLARE bodysurfacearea_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "BODYSURFACEAREA"))
 DECLARE bsadubois_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BSADUBOIS"))
 DECLARE abdominalgirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ABDOMINALGIRTH"))
 DECLARE headcircumference_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADCIRCUMFERENCE"))
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE weight_lb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE height_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE childspreferredname_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHILDSPREFERREDNAME"))
 DECLARE admittransferdischarge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE communicationorders_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE callmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CALLMD"))
 DECLARE rntorn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN"))
 DECLARE restraints_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE placeadvancedirectiveonchart_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "PLACEADVANCEDIRECTIVEONCHART"))
 DECLARE obtainadvancedirective_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "OBTAINADVANCEDIRECTIVE"))
 DECLARE nursecommunicationnutrition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONNUTRITION"))
 DECLARE nursecommunicationcardiacrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONCARDIACREHAB"))
 DECLARE nursecommunicationrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSECOMMUNICATIONREHAB"))
 DECLARE nursecommunicationpulmonaryrehab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONPULMONARYREHAB"))
 DECLARE casemanagmentnotetochartsummary_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"CASEMANAGEMENTNOTETOCHARTSUMMARY"))
 DECLARE nursecommunicationsocialservices_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSECOMMUNICATIONSOCIALSERVICES"))
 DECLARE agencycontactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "AGENCYCONTACTPERSON"))
 DECLARE portableunitrequired_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PORTABLEUNITREQUIRED"))
 DECLARE patientgoinghomeonoxygen_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTGOINGHOMEONOXYGEN"))
 DECLARE onadmitmedicalequipcompanies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ONADMITMEDICALEQUIPCOMPANIES"))
 DECLARE jail_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"JAIL"))
 DECLARE dstransportationarranged_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGETRANSPORTATIONARRANGED"))
 DECLARE modeoftransportationarranged_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFTRANSPORTATIONARRANGED"))
 DECLARE dsarrangedtransferstarttimedate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"DISCHARGEARRANGEDTRANSPORTDATETIME"))
 DECLARE pulmonarynurseappointment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PULMONARYNURSEAPPOINTMENT"))
 DECLARE phaseiisiteofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PHASEIISITEOFCARE"))
 DECLARE cardiacorientationappointment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACORIENTATIONAPPOINTMENT"))
 DECLARE onadmitearlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"ONADMITEARLYINTERVENTIONPROGRAMS"))
 DECLARE onadmitvnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ONADMITVNAHOSPICEHOMECARE"))
 DECLARE onadmitadultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ONADMITADULTDAYHEALTHCARE"))
 DECLARE onadmitresthomescommunityresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"ONADMITRESTHOMESCOMMRESSHELTERS"))
 DECLARE onadmitnursinghomesskilledrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"ONADMITNURSINGHOMESREHABFACILITIES"))
 DECLARE onadmitchronichospitals_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ONADMITCHRONICHOSPITALS"))
 DECLARE dischargenursinghomesrehabfacilities_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGENURSINGHOMESREHABFACILITIES"))
 DECLARE dischargeresthomesresidencesshelters_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGERESTHOMESRESIDENCESSHELTERS"))
 DECLARE dischargeadultdayhealthcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEADULTDAYHEALTHCARE"))
 DECLARE dischargevnahospicehomecare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEVNAHOSPICEHOMECARE"))
 DECLARE dischargeearlyinterventionprograms_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEEARLYINTERVENTIONPROGRAMS"))
 DECLARE dischargemedicalequipmentcompanies_cd = f8 WITH public, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEMEDICALEQUIPMENTCOMPANIES"))
 DECLARE dischargechronichospital_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGECHRONICHOSPITAL"))
 DECLARE needsservicesondischarge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEEDSSERVICESONDISCHARGE"))
 DECLARE posthospitalservicesrequired_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "POSTHOSPITALSERVICESREQUIRED"))
 DECLARE first_cnt = i2
 SET stat = alterlist(dlrec->seq,request->visit_cnt)
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event c,
   ce_date_result cdr
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd IN (thighcircumference_cd, calfcircumference_cd, bodymassindex_cd,
   chestcircumference_cd, bodysurfacearea_cd,
   bsadubois_cd, abdominalgirth_cd, headcircumference_cd, childspreferredname_cd, weight_cd,
   weight_lb_cd, height_cd, nursecommunicationnutrition_cd, nursecommunicationcardiacrehab_cd,
   jail_cd,
   nursecommunicationrehab_cd, nursecommunicationpulmonaryrehab_cd,
   nursecommunicationsocialservices_cd, casemanagmentnotetochartsummary_cd, agencycontactperson_cd,
   portableunitrequired_cd, patientgoinghomeonoxygen_cd, confirmedtransferstarttimedate_cd,
   dsarrangedtransferstarttimedate_cd, pulmonarynurseappointment_cd,
   dstransportationarranged_cd, phaseiisiteofcare_cd, cardiacorientationappointment_cd,
   onadmitearlyinterventionprograms_cd, onadmitvnahospicehomecare_cd,
   onadmitadultdayhealthcare_cd, onadmitresthomescommunityresidencesshelters_cd,
   onadmitnursinghomesskilledrehabfacilities_cd, onadmitchronichospitals_cd,
   onadmitmedicalequipcompanies_cd,
   dischargenursinghomesrehabfacilities_cd, dischargeresthomesresidencesshelters_cd,
   dischargeadultdayhealthcare_cd, dischargevnahospicehomecare_cd,
   dischargeearlyinterventionprograms_cd,
   dischargemedicalequipmentcompanies_cd, dischargechronichospital_cd, needsservicesondischarge_cd,
   posthospitalservicesrequired_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
   JOIN (cdr
   WHERE outerjoin(c.event_id)=cdr.event_id
    AND cdr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(dlrec->seq,10)
  HEAD c.event_cd
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq,(cnt+ 10))
   ENDIF
  DETAIL
   dlrec->seq[cnt].result_id = c.event_cd, dlrec->seq[cnt].result_display = uar_get_code_display(c
    .event_cd), dlrec->seq[cnt].result_date = substring(1,14,format(c.event_end_dt_tm,
     "@SHORTDATETIME;;Q"))
   IF (cdr.event_id > 0.0)
    dlrec->seq[cnt].result = substring(1,14,format(cdr.result_dt_tm,"@SHORTDATETIME;;Q"))
   ELSE
    dlrec->seq[cnt].result = concat(substring(1,14,format(c.event_end_dt_tm,"@SHORTDATETIME;;Q"))," ",
     trim(c.result_val,3)," ",uar_get_code_display(c.result_units_cd))
   ENDIF
   IF (c.event_cd=height_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 1
   ELSEIF (c.event_cd=weight_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 2
   ELSEIF (c.event_cd=weight_lb_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 3
   ELSEIF (c.event_cd=headcircumference_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 4
   ELSEIF (c.event_cd=abdominalgirth_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 5
   ELSEIF (c.event_cd=bodysurfacearea_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 6
   ELSEIF (c.event_cd=bsadubois_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 7
   ELSEIF (c.event_cd=bodymassindex_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 8
   ELSEIF (c.event_cd=chestcircumference_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 9
   ELSEIF (c.event_cd=calfcircumference_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 10
   ELSEIF (c.event_cd=thighcircumference_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 11
   ELSEIF (c.event_cd=childspreferredname_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 12
   ELSEIF (c.event_cd=onadmitchronichospitals_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 2
   ELSEIF (c.event_cd=onadmitnursinghomesskilledrehabfacilities_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 3
   ELSEIF (c.event_cd=onadmitresthomescommunityresidencesshelters_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 4
   ELSEIF (c.event_cd=onadmitadultdayhealthcare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 5
   ELSEIF (c.event_cd=onadmitvnahospicehomecare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 6
   ELSEIF (c.event_cd=onadmitearlyinterventionprograms_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 7
   ELSEIF (c.event_cd=jail_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 8
   ELSEIF (c.event_cd=onadmitmedicalequipcompanies_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 9
   ELSEIF (c.event_cd=needsservicesondischarge_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 12
   ELSEIF (c.event_cd=posthospitalservicesrequired_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 13
   ELSEIF (c.event_cd=agencycontactperson_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 14
   ELSEIF (c.event_cd=pulmonarynurseappointment_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 15
   ELSEIF (c.event_cd=phaseiisiteofcare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 16
   ELSEIF (c.event_cd=cardiacorientationappointment_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 17
   ELSEIF (c.event_cd=patientgoinghomeonoxygen_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 18
   ELSEIF (c.event_cd=portableunitrequired_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 19
   ELSEIF (c.event_cd=dsarrangedtransferstarttimedate_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 20
   ELSEIF (c.event_cd=dstransportationarranged_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 21
   ELSEIF (c.event_cd=dischargechronichospital_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 22
   ELSEIF (c.event_cd=dischargenursinghomesrehabfacilities_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 23
   ELSEIF (c.event_cd=dischargeresthomesresidencesshelters_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 24
   ELSEIF (c.event_cd=dischargeadultdayhealthcare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 25
   ELSEIF (c.event_cd=dischargevnahospicehomecare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 26
   ELSEIF (c.event_cd=dischargeearlyinterventionprograms_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 27
   ELSEIF (c.event_cd=dischargemedicalequipmentcompanies_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 28
   ELSEIF (c.event_cd=nursecommunicationsocialservices_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 29
   ELSEIF (c.event_cd=casemanagmentnotetochartsummary_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 30
   ELSEIF (c.event_cd=nursecommunicationrehab_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 31
   ELSEIF (c.event_cd=nursecommunicationpulmonaryrehab_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 32
   ELSEIF (c.event_cd=nursecommunicationcardiacrehab_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 33
   ELSEIF (c.event_cd=nursecommunicationnutrition_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 34
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND ((o.order_status_cd+ 0) IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
   o_pending_rev_cd))
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd IN (admittransferdischarge_cd, communicationorders_cd, callmd_cd,
   rntorn_cd, restraints_cd))
  ORDER BY cnvtdatetime(o.orig_order_dt_tm), o.order_id
  HEAD REPORT
   cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,(cnt+ 10))
  DETAIL
   IF (o.catalog_cd IN (placeadvancedirectiveonchart_cd, obtainadvancedirective_cd))
    cnt = (cnt+ 0)
   ELSE
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq,(cnt+ 10))
    ENDIF
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_display = o.order_mnemonic, dlrec->seq[cnt].
    result = o.clinical_display_line,
    dlrec->seq[cnt].result_id = o.order_id, dlrec->seq[cnt].result_date = substring(1,14,format(o
      .orig_order_dt_tm,"@SHORTDATETIME;;Q"))
   ENDIF
   IF (o.activity_type_cd=rntorn_cd)
    dlrec->seq[cnt].result_sort = 1
   ELSEIF (o.activity_type_cd=callmd_cd)
    dlrec->seq[cnt].result_sort = 2
   ELSEIF (o.activity_type_cd=communicationorders_cd)
    dlrec->seq[cnt].result_sort = 3
   ELSEIF (o.activity_type_cd=admittransferdischarge_cd)
    dlrec->seq[cnt].result_sort = 4
   ELSEIF (o.activity_type_cd=restraints_cd)
    dlrec->seq[cnt].result_sort = 5
   ELSE
    dlrec->seq[cnt].result_sort = 99
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 CALL echorecord(dlrec)
 SELECT INTO "nl:"
  category = dlrec->seq[d1.seq].category, result_sort = dlrec->seq[d1.seq].result_sort, result_date
   = dlrec->seq[d1.seq].result_date
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY category, result_sort, result_date
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu," Nurse Communication ",wr,reol), addtoreply
   ENDMACRO
   ,
   MACRO (parse_string)
    limit = 0, maxlen = 80
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", "."))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring), temp = concat("     ",print_string,reol), addtoreply,
      tempstring = substring((pos+ 1),9999,tempstring)
    ENDWHILE
   ENDMACRO
   ,
   MACRO (gtitle_print)
    reply->text = concat(reply->text,wu,title_string," ",wr,
     " ",reol)
   ENDMACRO
   ,
   MACRO (addtoreply)
    reply->text = concat(reply->text,temp), gline_cnt = (gline_cnt+ 1)
    IF (gline_cnt > 60)
     gline_cnt = 0
    ENDIF
   ENDMACRO
   ,
   gpage_heading
   IF ((dlrec->encntr_total=0))
    dlrec->encntr_total = 1
   ENDIF
  HEAD category
   row + 0
  DETAIL
   temp = " "
   IF ((dlrec->seq[d1.seq].category=1))
    temp = concat(wb,dlrec->seq[d1.seq].result_display,": ",wr," ",
     dlrec->seq[d1.seq].result," ",reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=2))
    temp = concat(wb,dlrec->seq[d1.seq].result_display,": ",wr," ",
     dlrec->seq[d1.seq].result," ",reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=3))
    temp = concat(wb,dlrec->seq[d1.seq].result_display,": ",wr," ",
     dlrec->seq[d1.seq].result," ",reol), addtoreply
   ENDIF
   temp = reol
  FOOT  category
   addtoreply
  WITH noforms
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 FREE RECORD dlrec
 FREE RECORD request
END GO
