CREATE PROGRAM bhs_ma_genview_pt_snapshot:dba
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
  SET request->visit[1].encntr_id = 1135322
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
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 pt_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 isolation_disp = vc
     2 reason_for_visit = vc
     2 height_dt_tm = vc
     2 height_in = vc
     2 weight_dt_tm = vc
     2 weight_lbs = vc
     2 height_cm = vc
     2 weight_calc_kg = vc
     2 weight_kilo = vc
     2 total_al = i4
     2 allergy[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = vc
       3 substance_type_disp = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 section1_total = i4
     2 section1_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 section3_total = i4
     2 section3_events[*]
       3 event_cd_disp = vc
       3 event_cd = f8
       3 event_type = vc
       3 event_dt_tm = vc
       3 result = vc
     2 problem_total = i4
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
       3 full_text = vc
     2 isol_code_total = i4
     2 isol_code[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
     2 admitdoc_name = vc
     2 admitdoc_alias = vc
     2 attenddoc_name = vc
     2 attenddoc_alias = vc
     2 pcpdoc_name = vc
     2 pcpdoc_alias = vc
     2 nurse_name = vc
     2 nurse_alias = vc
     2 total_diag = i4
     2 diagnosis[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = c16
       3 diag_type_desc = vc
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
 DECLARE allergy_cancelled_cd = f8 WITH public, noconstant(0.0)
 DECLARE chiefcomplaint_cd = f8 WITH public, noconstant(0.0)
 DECLARE isolationtypes_cd = f8 WITH public, noconstant(0.0)
 DECLARE advanceddirectives_cd = f8 WITH public, noconstant(0.0)
 DECLARE weightptcare_cd = f8 WITH public, noconstant(0.0)
 DECLARE height_cd = f8 WITH public, noconstant(0.0)
 DECLARE inerror_cd = f8 WITH public, noconstant(0.0)
 SET allergy_cancelled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 SET e_encntr_status_cd = uar_get_code_by("MEANING",261,"ACTIVE")
 SET chiefcomplaint_cd = uar_get_code_by("DISPLAYKEY",72,"CHIEFCOMPLAINT")
 SET inerror_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET isolationtypes_cd = uar_get_code_by("DISPLAYKEY",72,"ISOLATIONTYPES")
 SET advanceddirectives_cd = uar_get_code_by("DISPLAYKEY",72,"ADVANCEDDIRECTIVES")
 SET weightptcare_cd = uar_get_code_by("DISPLAYKEY",72,"WEIGHTPTCARE")
 SET height_cd = uar_get_code_by("DISPLAYKEY",72,"HEIGHT")
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE primarynurse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",331,"PRIMARYCARENURSE")
  )
 DECLARE codestatus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE isolation_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE authorizedtodiscusspatientshealth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   72,"AUTHORIZEDTODISCUSSPATIENTSHEALTH"))
 DECLARE contactproxyphonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE proxy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
 DECLARE copyplacedonchart_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "COPYPLACEDONCHART"))
 DECLARE advancedirective_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVE"))
 DECLARE homephonenumber_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HOMEPHONENUMBER"))
 DECLARE relationshiptopatient_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELATIONSHIPTOPATIENT"))
 DECLARE contactperson_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CONTACTPERSON")
  )
 DECLARE ispatientachronicco2retainer_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "ISPATIENTACHRONICCO2RETAINER"))
 DECLARE languagespoken_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKEN"))
 DECLARE fallsriskscore_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "FALLSRISKSCORE"))
 DECLARE pcpofmother_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PCPOFMOTHER"))
 DECLARE organdonor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ORGANDONOR"))
 DECLARE edc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"EDC"))
 DECLARE gravida_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDA"))
 DECLARE term_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TERM"))
 DECLARE parity_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PARITY"))
 DECLARE living_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"LIVING"))
 DECLARE abortion_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"ABORTION"))
 DECLARE gestationalage_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "GESTATIONALAGE"))
 DECLARE deliverydate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYDATE"))
 DECLARE deliverytype_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYTYPE"))
 DECLARE birthweight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BIRTHWEIGHT"))
 DECLARE code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CODE"))
 DECLARE deliveredby_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVEREDBY"))
 DECLARE placeofbirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PLACEOFBIRTH"))
 SELECT INTO "nl:"
  sex_disp = uar_get_code_display(p.sex_cd), pt_name = cnvtupper(substring(1,10,p.name_last_key)),
  isolation_disp = uar_get_code_display(e.isolation_cd)
  FROM encounter e,
   encntr_alias ea,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ea
   WHERE outerjoin(e.encntr_id)=ea.encntr_id
    AND ea.active_ind=outerjoin(1)
    AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq,(cnt+ 9))
   ENDIF
   dlrec->seq[cnt].encntr_id = e.encntr_id, dlrec->seq[cnt].person_id = e.person_id, dlrec->seq[cnt].
   pt_name = pt_name,
   dlrec->seq[cnt].reason_for_visit = e.reason_for_visit, dlrec->seq[cnt].isolation_disp =
   isolation_disp
  FOOT  e.encntr_id
   col + 0
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  sort_order =
  IF (c.event_cd=pcpofmother_cd) 13
  ELSEIF (c.event_cd=organdonor_cd) 12
  ELSEIF (c.event_cd=authorizedtodiscusspatientshealth_cd) 11
  ELSEIF (c.event_cd=contactproxyphonenumber_cd) 9
  ELSEIF (c.event_cd=proxy_cd) 9
  ELSEIF (c.event_cd=copyplacedonchart_cd) 8
  ELSEIF (c.event_cd=advancedirective_cd) 7
  ELSEIF (c.event_cd=homephonenumber_cd) 5
  ELSEIF (c.event_cd=relationshiptopatient_cd) 5
  ELSEIF (c.event_cd=contactperson_cd) 4
  ELSEIF (c.event_cd=ispatientachronicco2retainer_cd) 3
  ELSEIF (c.event_cd=languagespoken_cd) 2
  ELSEIF (c.event_cd=fallsriskscore_cd) 1
  ELSE 999
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event c
  PLAN (dd)
   JOIN (c
   WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
    AND c.event_cd IN (pcpofmother_cd, organdonor_cd, authorizedtodiscusspatientshealth_cd,
   contactproxyphonenumber_cd, proxy_cd,
   homephonenumber_cd, relationshiptopatient_cd, contactperson_cd, languagespoken_cd,
   fallsriskscore_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
  ORDER BY c.encntr_id, sort_order, c.parent_event_id,
   c.event_id
  HEAD c.encntr_id
   cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section1_events,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].section1_events,(cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].section1_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
   section1_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section1_events[cnt].event_cd_disp
    = uar_get_code_display(c.event_cd),
   dlrec->seq[dd.seq].section1_events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
     "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section1_events[cnt].result = build(c.result_val,
    uar_get_code_display(c.result_units_cd))
  FOOT  c.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].section1_events,cnt), dlrec->seq[dd.seq].section1_total = cnt
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  sort_order =
  IF (c.event_cd=edc_cd) 1
  ELSEIF (c.event_cd=gravida_cd) 2
  ELSEIF (c.event_cd=term_cd) 3
  ELSEIF (c.event_cd=parity_cd) 4
  ELSEIF (c.event_cd=living_cd) 5
  ELSEIF (c.event_cd=abortion_cd) 6
  ELSEIF (c.event_cd=gestationalage_cd) 7
  ELSEIF (c.event_cd=deliverydate_cd) 8
  ELSEIF (c.event_cd=deliverytype_cd) 8
  ELSEIF (c.event_cd=birthweight_cd) 8
  ELSEIF (c.event_cd=code_cd) 8
  ELSEIF (c.event_cd=deliveredby_cd) 8
  ELSEIF (c.event_cd=placeofbirth_cd) 13
  ELSE 999
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event c
  PLAN (dd)
   JOIN (c
   WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
    AND c.event_cd IN (edc_cd, gravida_cd, term_cd, parity_cd, living_cd,
   abortion_cd, gestationalage_cd, deliverydate_cd, deliverytype_cd, birthweight_cd,
   code_cd, deliveredby_cd, placeofbirth_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
  ORDER BY c.encntr_id, sort_order, c.parent_event_id,
   c.event_id
  HEAD c.encntr_id
   cnt = 0, stat = alterlist(dlrec->seq[dd.seq].section3_events,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].section3_events,(cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].section3_events[cnt].event_type = c.event_tag, dlrec->seq[dd.seq].
   section3_events[cnt].event_cd = c.event_cd, dlrec->seq[dd.seq].section3_events[cnt].event_cd_disp
    = uar_get_code_display(c.event_cd),
   dlrec->seq[dd.seq].section3_events[cnt].event_dt_tm = substring(1,14,format(c.updt_dt_tm,
     "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].section3_events[cnt].result = build(c.result_val,
    uar_get_code_display(c.result_units_cd))
  FOOT  c.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].section3_events,cnt), dlrec->seq[dd.seq].section3_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
  FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
   problem p,
   nomenclature n
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=dlrec->seq[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0, stat = alterlist(dlrec->seq[d.seq].problem,10)
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[d.seq].problem,(cnt+ 10))
    ENDIF
    IF (p.nomenclature_id > 0)
     dlrec->seq[d.seq].problem[cnt].text = n.source_string
    ELSE
     dlrec->seq[d.seq].problem[cnt].text = p.problem_ftdesc
    ENDIF
    dlrec->seq[d.seq].problem[cnt].status = uar_get_code_display(p.life_cycle_status_cd), dlrec->seq[
    d.seq].problem[cnt].beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[d.seq].problem[cnt].full_text = build(dlrec->seq[d.seq].
     problem[cnt].status,": ",dlrec->seq[d.seq].problem[cnt].text)
   ENDIF
  FOOT  p.person_id
   dlrec->seq[d.seq].problem_total = cnt, stat = alterlist(dlrec->seq[d.seq].problem,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.activity_type_cd=codestatus_cd) 1
  ELSE o.activity_type_cd
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   order_action oa,
   prsnl p,
   prsnl p2
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND  NOT (o.order_status_cd IN (o_incomplete_cd, o_inprocess_cd, o_pending_cd, o_pending_rev_cd))
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd IN (codestatus_cd, isolation_cd))
   JOIN (oa
   WHERE outerjoin(o.order_id)=oa.order_id)
   JOIN (p
   WHERE outerjoin(oa.action_personnel_id)=p.person_id)
   JOIN (p2
   WHERE outerjoin(oa.order_provider_id)=p2.person_id)
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(dlrec->seq[dd.seq].isol_code,10)
  HEAD sort_order
   col + 0
  DETAIL
   col + 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].isol_code,(cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].isol_code[cnt].order_mnemonic = o.hna_order_mnemonic, dlrec->seq[dd.seq].
   isol_code[cnt].clinical_display_line = o.clinical_display_line
  FOOT  sort_order
   col + 0
  FOOT  o.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].isol_code,cnt), dlrec->seq[dd.seq].isol_code_total = cnt
  WITH nocounter, maxcol = 800
 ;end select
 SELECT INTO "nl:"
  reaction = uar_get_code_display(a.reaction_class_cd), short_source_string = concat(trim(substring(1,
     40,n.source_string)),trim(substring(1,40,a.substance_ftdesc))), substance_type_disp = concat(
   trim(uar_get_code_display(a.substance_type_cd))," ",trim(uar_get_code_display(a.reaction_class_cd)
    ))
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   allergy a,
   nomenclature n
  PLAN (dd)
   JOIN (a
   WHERE (a.person_id=dlrec->seq[dd.seq].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != allergy_cancelled_cd)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  ORDER BY a.person_id, substance_type_disp
  HEAD a.person_id
   al = 0, stat = alterlist(dlrec->seq[dd.seq].allergy,10)
  DETAIL
   al = (al+ 1)
   IF (mod(al,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].allergy,(al+ 9))
   ENDIF
   dlrec->seq[dd.seq].allergy[al].source_string = short_source_string, dlrec->seq[dd.seq].allergy[al]
   .substance_type_disp = build(substance_type_disp)
  FOOT  a.person_id
   stat = alterlist(dlrec->seq[dd.seq].allergy,al), dlrec->seq[dd.seq].total_al = al
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   diagnosis d,
   nomenclature n
  PLAN (dd)
   JOIN (d
   WHERE (d.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
  ORDER BY d.encntr_id, cnvtdatetime(d.diag_dt_tm) DESC, d.nomenclature_id
  HEAD d.encntr_id
   cnt = 0, stat = alterlist(dlrec->seq[dd.seq].diagnosis,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].diagnosis,(cnt+ 10))
   ENDIF
   IF (n.nomenclature_id > 0)
    dlrec->seq[dd.seq].diagnosis[cnt].source_string = n.source_string
   ELSE
    dlrec->seq[dd.seq].diagnosis[cnt].source_string = d.diag_ftdesc
   ENDIF
   dlrec->seq[dd.seq].diagnosis[cnt].diag_dt_tm = substring(1,14,format(d.diag_dt_tm,
     "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].diagnosis[cnt].diag_type_desc = uar_get_code_display(d
    .diag_type_cd)
  FOOT  d.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].diagnosis,cnt), dlrec->seq[dd.seq].total_diag = cnt
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event c
  PLAN (dd)
   JOIN (c
   WHERE (dlrec->seq[dd.seq].encntr_id=c.encntr_id)
    AND c.event_cd=chiefcomplaint_cd
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
  ORDER BY c.encntr_id, cnvtdatetime(c.event_end_dt_tm)
  HEAD c.encntr_id
   col + 0
  DETAIL
   IF ((dlrec->seq[dd.seq].total_diag=0))
    cnt = 1, stat = alterlist(dlrec->seq[dd.seq].diagnosis,cnt), dlrec->seq[dd.seq].diagnosis[cnt].
    source_string = c.result_val,
    dlrec->seq[dd.seq].diagnosis[cnt].diag_dt_tm = substring(1,14,format(c.event_end_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[dd.seq].diagnosis[cnt].diag_type_desc = uar_get_code_display(
     c.event_cd), dlrec->seq[dd.seq].total_diag = cnt
   ENDIF
  FOOT  c.encntr_id
   col + 0
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   encntr_prsnl_reltn epr,
   prsnl pl,
   prsnl_alias pla
  PLAN (dd)
   JOIN (epr
   WHERE (epr.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=attenddoc_cd)
   JOIN (pl
   WHERE pl.person_id=outerjoin(epr.prsnl_person_id))
   JOIN (pla
   WHERE pla.person_id=outerjoin(pl.person_id))
  ORDER BY epr.beg_effective_dt_tm
  DETAIL
   IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
    dlrec->seq[dd.seq].attenddoc_name = pl.name_full_formatted, dlrec->seq[dd.seq].attenddoc_alias =
    pla.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
   prsnl pl2,
   person_prsnl_reltn ppr,
   prsnl_alias pla
  PLAN (d)
   JOIN (ppr
   WHERE (dlrec->seq[d.seq].person_id=ppr.person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pl2
   WHERE ppr.prsnl_person_id=pl2.person_id)
   JOIN (pla
   WHERE pla.person_id=outerjoin(pl2.person_id))
  DETAIL
   dlrec->seq[d.seq].pcpdoc_name = pl2.name_full_formatted, dlrec->seq[d.seq].pcpdoc_alias = pla
   .alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
   prsnl pl2,
   person_prsnl_reltn ppr,
   prsnl_alias pla
  PLAN (d)
   JOIN (ppr
   WHERE (dlrec->seq[d.seq].person_id=ppr.person_id)
    AND ppr.person_prsnl_r_cd=primarynurse_cd
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pl2
   WHERE pl2.person_id=ppr.prsnl_person_id)
   JOIN (pla
   WHERE pla.person_id=outerjoin(pl2.person_id))
  DETAIL
   dlrec->seq[d.seq].nurse_name = pl2.name_full_formatted, dlrec->seq[d.seq].nurse_alias = pla.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dummyt
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu," General Information",wr,reol), addtoreply
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
    line2 = substring(1,80,line1), string_len = size(title_string), stat = movestring(cnvtupper(
      title_string),1,line2,(40 - ceil((string_len/ 2))),string_len),
    reply->text = concat(reply->text,wb,substring(1,79,line2),reol,wr)
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
   temp = ""
   FOR (i = 1 TO dlrec->encntr_total)
     temp = concat(wb,reol,"Attending: ",wr,trim(dlrec->seq[i].attenddoc_name),
      wr," "), addtoreply, temp = concat(wb,reol,"PCP: ",wr,trim(dlrec->seq[i].pcpdoc_name),
      wr," "),
     addtoreply, temp = concat(wb,reol,"Nurse Assigned to Patient: ",wr,trim(dlrec->seq[i].nurse_name
       ),
      wr," "), addtoreply,
     temp = concat(wb,reol,"Reason For Visit: ",wr,trim(dlrec->seq[i].reason_for_visit),
      wr," "), addtoreply
     FOR (iso_x = 1 TO dlrec->seq[i].isol_code_total)
      temp = concat(wb,reol,dlrec->seq[i].isol_code[iso_x].order_mnemonic,wr," ",
       dlrec->seq[i].isol_code[iso_x].clinical_display_line," "),addtoreply
     ENDFOR
   ENDFOR
  WITH noforms
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD pt
 FREE RECORD dlrec
 FREE RECORD request
END GO
