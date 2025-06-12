CREATE PROGRAM dab_ma_genview_pt_data3:dba
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
  SET request->visit[1].encntr_id = 20499627.00
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
   1 person_id = f8
   1 encntr_id = f8
   1 pt_name = vc
   1 reason_for_visit = vc
   1 reg_dt_tm = dq8
   1 isolation_disp = vc
   1 attenddoc_name = vc
   1 attenddoc_alias = vc
   1 admitdoc_name = vc
   1 admitdoc_alias = vc
   1 pcpdoc_name = vc
   1 pcpdoc_alias = vc
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
 DECLARE modified_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
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
 DECLARE weeksofgestationatbirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "WEEKSOFGESTATIONATBIRTH"))
 DECLARE deliverydate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYDATE"))
 DECLARE deliverytype_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYTYPE"))
 DECLARE birthweight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BIRTHWEIGHT"))
 DECLARE code_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CODE"))
 DECLARE deliveredby_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVEREDBY"))
 DECLARE placeofbirth_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PLACEOFBIRTH"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE temprxn = vc
 DECLARE first_cnt = i2
 DECLARE prob_cnt = i2
 DECLARE diag_cnt = i2
 DECLARE cc_cnt = i2
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
  HEAD e.encntr_id
   dlrec->encntr_id = e.encntr_id, dlrec->person_id = e.person_id, dlrec->pt_name = pt_name,
   dlrec->reason_for_visit = e.reason_for_visit, dlrec->isolation_disp = isolation_disp, dlrec->
   reg_dt_tm = e.reg_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c,
   ce_date_result ce
  PLAN (c
   WHERE (c.person_id=dlrec->person_id)
    AND c.event_cd IN (pcpofmother_cd, organdonor_cd, authorizedtodiscusspatientshealth_cd,
   contactproxyphonenumber_cd, proxy_cd,
   homephonenumber_cd, relationshiptopatient_cd, contactperson_cd, languagespoken_cd,
   fallsriskscore_cd,
   edc_cd, gravida_cd, term_cd, parity_cd, living_cd,
   abortion_cd, gestationalage_cd, weeksofgestationatbirth_cd, deliverydate_cd, deliverytype_cd,
   birthweight_cd, code_cd, deliveredby_cd, placeofbirth_cd)
    AND c.event_end_dt_tm >= cnvtdatetime(dlrec->reg_dt_tm)
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND ((c.encntr_id+ 0)=dlrec->encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
   JOIN (ce
   WHERE outerjoin(c.event_id)=ce.event_id
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(dlrec->seq,10)
  HEAD c.event_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq,(cnt+ 10))
    ENDIF
    dlrec->seq[cnt].result_id = c.event_cd, dlrec->seq[cnt].result_display = uar_get_code_display(c
     .event_cd), dlrec->seq[cnt].result_date = substring(1,14,format(c.updt_dt_tm,"@SHORTDATETIME;;Q"
      ))
    IF (c.event_cd IN (birthweight_cd, gestationalage_cd, weeksofgestationatbirth_cd, code_cd))
     dlrec->seq[cnt].result = concat(trim(c.result_val,3)," ",uar_get_code_display(c.result_units_cd)
      )
    ENDIF
    IF (c.event_id=ce.event_id)
     CASE (ce.date_type_flag)
      OF 0:
       dlrec->seq[cnt].result = format(ce.result_dt_tm,"mm/dd/yy hh:mm;;;d")
      OF 1:
       dlrec->seq[cnt].result = format(ce.result_dt_tm,"mm/dd/yy;;;d")
      OF 2:
       dlrec->seq[cnt].result = format(ce.result_dt_tm,"hh:mm;;;d")
     ENDCASE
    ELSE
     dlrec->seq[cnt].result = build(c.result_val,uar_get_code_display(c.result_units_cd))
    ENDIF
    CASE (c.event_cd)
     OF pcpofmother_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 13
     OF organdonor_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 12
     OF authorizedtodiscusspatientshealth_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 11
     OF contactproxyphonenumber_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 10
     OF proxy_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 9
     OF homephonenumber_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 6
     OF relationshiptopatient_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 5
     OF contactperson_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 4
     OF languagespoken_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 2
     OF fallsriskscore_cd:
      dlrec->seq[cnt].category = 7,dlrec->seq[cnt].result_sort = 1
     OF edc_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 1
     OF gravida_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 2
     OF term_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 3
     OF parity_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 4
     OF living_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 5
     OF abortion_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 6
     OF gestationalage_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 7
     OF weeksofgestationatbirth_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 8
     OF deliverydate_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 9
     OF deliverytype_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 10
     OF birthweight_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 11
     OF code_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 12
     OF deliveredby_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 13
     OF placeofbirth_cd:
      dlrec->seq[cnt].category = 8,dlrec->seq[cnt].result_sort = 14
    ENDCASE
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c1
  PLAN (c1
   WHERE (c1.person_id=dlrec->person_id)
    AND c1.event_cd=advancedirective_cd
    AND c1.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND c1.view_level=1
    AND c1.publish_flag=1
    AND c1.result_status_cd != inerror_cd
    AND c1.event_tag > " ")
  ORDER BY c1.event_cd, cnvtdatetime(c1.event_end_dt_tm) DESC
  HEAD REPORT
   cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,(cnt+ 10))
  HEAD c1.event_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq,(cnt+ 10))
    ENDIF
    dlrec->seq[cnt].category = 7, dlrec->seq[cnt].result_sort = 7, dlrec->seq[cnt].result_id = c1
    .event_cd,
    dlrec->seq[cnt].result_display = uar_get_code_display(c1.event_cd), dlrec->seq[cnt].result_date
     = substring(1,14,format(c1.updt_dt_tm,"@SHORTDATETIME;;Q")), dlrec->seq[cnt].result = build(c1
     .result_val,uar_get_code_display(c1.result_units_cd))
    IF (c1.event_cd IN (birthweight_cd, gestationalage_cd, weeksofgestationatbirth_cd, code_cd))
     dlrec->seq[cnt].result = concat(trim(c1.result_val,3)," ",uar_get_code_display(c1
       .result_units_cd))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=dlrec->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
    AND n.source_vocabulary_cd=outerjoin(snmct_cd))
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD REPORT
   cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,(dlrec->encntr_total+ 10)), prob_cnt = 0
  DETAIL
   prob_cnt = (prob_cnt+ 1), temp = " "
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq,(dlrec->encntr_total+ 10))
    ENDIF
    IF (p.nomenclature_id > 0)
     temp = n.source_string
    ELSE
     temp = p.problem_ftdesc
    ENDIF
    dlrec->seq[cnt].category = 4, dlrec->seq[cnt].category_name = "SNOMED Problem List ", dlrec->seq[
    cnt].result_date = substring(1,14,format(p.beg_effective_dt_tm,"@SHORTDATETIME;;Q")),
    dlrec->seq[cnt].result = build(uar_get_code_display(p.life_cycle_status_cd),": ",temp)
   ENDIF
  FOOT REPORT
   IF (prob_cnt=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq,cnt), dlrec->seq[cnt].category = 4
   ENDIF
   dlrec->encntr_total = cnt, stat = alterlist(dlrec->seq,cnt)
  WITH nocounter, nullreport
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=dlrec->encntr_id)
    AND ((o.order_status_cd+ 0) IN (o_ordered_cd, o_completed_cd))
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd IN (codestatus_cd, isolation_cd))
  ORDER BY o.activity_type_cd, cnvtdatetime(o.orig_order_dt_tm) DESC
  HEAD REPORT
   cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,(cnt+ 10))
  HEAD o.activity_type_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq,(cnt+ 10))
    ENDIF
    IF (o.activity_type_cd=codestatus_cd)
     dlrec->seq[cnt].result_sort = 1
    ELSE
     dlrec->seq[cnt].result_sort = 2
    ENDIF
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_display = o.hna_order_mnemonic, dlrec->seq[
    cnt].result = o.clinical_display_line
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  reaction = uar_get_code_display(a.reaction_class_cd), short_source_string_all = concat(trim(
    substring(1,40,n.source_string)),trim(substring(1,40,a.substance_ftdesc))),
  short_source_string_rxn = concat(trim(substring(1,40,n2.source_string)),trim(substring(1,40,r
     .reaction_ftdesc))),
  substance_type_disp = concat(trim(uar_get_code_display(a.substance_type_cd))," ",trim(
    uar_get_code_display(a.reaction_class_cd))), severity = uar_get_code_display(a.severity_cd), r
  .reaction_ftdesc
  FROM allergy a,
   nomenclature n,
   reaction r,
   nomenclature n2
  PLAN (a
   WHERE (a.person_id=dlrec->person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != allergy_cancelled_cd)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id))
   JOIN (n2
   WHERE n2.nomenclature_id=outerjoin(r.reaction_nom_id))
  ORDER BY a.person_id, a.allergy_id, substance_type_disp
  HEAD REPORT
   temprxn = " ", al = dlrec->encntr_total, stat = alterlist(dlrec->seq,(cnt+ 10))
  HEAD a.allergy_id
   temprxn = "", al = (al+ 1)
   IF (mod(al,10)=1)
    stat = alterlist(dlrec->seq,(al+ 10))
   ENDIF
   IF (substance_type_disp="Drug Allergy")
    dlrec->seq[al].result_display = "Drug Allergy "
   ELSEIF (substance_type_disp != "Drug Allergy")
    dlrec->seq[al].result_display = "Other Allergy "
   ENDIF
   dlrec->seq[al].category = 2, dlrec->seq[al].result_date = substring(1,14,format(a.onset_dt_tm,
     "@SHORTDATETIME;;Q"))
  DETAIL
   CALL echo(build("temprxn: ",temprxn))
   IF (temprxn > " ")
    temprxn = concat(trim(temprxn,3),", ",trim(short_source_string_rxn,3))
   ELSE
    temprxn = trim(short_source_string_rxn,3)
   ENDIF
  FOOT  a.allergy_id
   IF (((severity > " ") OR (temprxn > " ")) )
    dlrec->seq[al].result = concat(trim(short_source_string_all,3)," "," Reaction: ",trim(severity,3),
     " -- ",
     temprxn)
   ELSE
    dlrec->seq[al].result = trim(short_source_string_all,3)
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,al), dlrec->encntr_total = al
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE (d.encntr_id=dlrec->encntr_id)
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
  ORDER BY cnvtdatetime(d.diag_dt_tm) DESC
  HEAD REPORT
   d.encntr_id, cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,(cnt+ 10)),
   diag_cnt = 0
  DETAIL
   diag_cnt = (diag_cnt+ 1), cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq,(cnt+ 10))
   ENDIF
   dlrec->seq[cnt].category = 5
   IF (n.nomenclature_id > 0)
    dlrec->seq[cnt].result = n.source_string
   ELSE
    dlrec->seq[cnt].result = d.diag_ftdesc
   ENDIF
   dlrec->seq[cnt].result_display = uar_get_code_display(d.diag_type_cd), dlrec->seq[cnt].result_date
    = substring(1,14,format(d.diag_dt_tm,"@SHORTDATETIME;;Q"))
  FOOT REPORT
   IF (diag_cnt=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq,cnt), dlrec->seq[cnt].category = 5
   ENDIF
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter, nullreport
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event c
  PLAN (dd)
   JOIN (c
   WHERE (c.person_id=dlrec->person_id)
    AND c.event_cd=chiefcomplaint_cd
    AND c.event_end_dt_tm >= cnvtdatetime(dlrec->reg_dt_tm)
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND ((c.encntr_id+ 0)=dlrec->encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.result_status_cd != inerror_cd
    AND c.event_tag > " ")
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
  HEAD REPORT
   cnt = dlrec->encntr_total, stat = alterlist(dlrec->seq,cnt)
  HEAD c.event_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    IF (diag_cnt=0)
     cnt = dlrec->encntr_total, cnt = (cnt+ 1), stat = alterlist(dlrec->seq,cnt),
     CALL echo(build("CC Cnt: ",cnt)), dlrec->seq[cnt].category = 5, dlrec->seq[cnt].result = trim(c
      .result_val),
     dlrec->seq[cnt].result_date = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATETIME;;Q")),
     dlrec->seq[cnt].result_display = uar_get_code_display(c.event_cd)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter, nullreport
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl,
   prsnl_alias pla
  PLAN (epr
   WHERE (epr.encntr_id=dlrec->encntr_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd IN (attenddoc_cd, admitdoc_cd))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
   JOIN (pla
   WHERE pla.person_id=outerjoin(pl.person_id))
  ORDER BY epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm DESC
  HEAD epr.encntr_prsnl_r_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    IF (epr.encntr_prsnl_r_cd=attenddoc_cd)
     dlrec->attenddoc_name = pl.name_full_formatted, dlrec->attenddoc_alias = pla.alias
    ENDIF
    IF (epr.encntr_prsnl_r_cd=admitdoc_cd)
     dlrec->admitdoc_name = pl.name_full_formatted, dlrec->admitdoc_alias = pla.alias
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl pl2,
   person_prsnl_reltn ppr,
   prsnl_alias pla
  PLAN (ppr
   WHERE (dlrec->person_id=ppr.person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pl2
   WHERE ppr.prsnl_person_id=pl2.person_id)
   JOIN (pla
   WHERE pla.person_id=outerjoin(pl2.person_id))
  ORDER BY ppr.person_prsnl_r_cd, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_prsnl_r_cd
   first_cnt = 0
  DETAIL
   first_cnt = (first_cnt+ 1)
   IF (first_cnt=1)
    dlrec->pcpdoc_name = pl2.name_full_formatted, dlrec->pcpdoc_alias = pla.alias
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(dlrec,"dab_test_record.dat")
 SELECT INTO "nl:"
  category = dlrec->seq[d1.seq].category, result_sort = dlrec->seq[d1.seq].result_sort
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY category, result_sort
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu," Patient Data ",wr,reol), addtoreply
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
    line2 = substring(1,80,line1), string_len = size(title_string), reply->text = concat(reply->text,
     wb,reol,wr)
   ENDMACRO
   ,
   MACRO (addtoreply)
    reply->text = notrim(concat(reply->text,temp)), gline_cnt = (gline_cnt+ 1)
    IF (gline_cnt > 60)
     gline_cnt = 0
    ENDIF
   ENDMACRO
   ,
   gpage_heading
   IF ((dlrec->encntr_total=0))
    dlrec->encntr_total = 1
   ENDIF
   temp = concat(wb,reol,"Admit Dr. : ",trim(dlrec->admitdoc_name),wr,
    " ",reol), addtoreply, temp = concat(wb,"Attending : ",trim(dlrec->attenddoc_name),wr," ",
    reol),
   addtoreply, temp = concat(wb,"PCP : ",trim(dlrec->pcpdoc_name),wr," "), addtoreply
  HEAD category
   IF ((dlrec->seq[d1.seq].category=4))
    temp = concat(wb,"SNOMED Problem List ",wr,reol), addtoreply
   ELSEIF ((dlrec->seq[d1.seq].category=5))
    temp = concat(wb,"Diagnosis ",wr,reol), addtoreply
   ENDIF
  DETAIL
   temp = " "
   IF ((dlrec->seq[d1.seq].category=2))
    temp = concat(wb," ","\par ",trim(dlrec->seq[d1.seq].result_display,3),wr,
     trim(dlrec->seq[d1.seq].result,3)), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=3))
    temp = concat(wb,trim(dlrec->seq[d1.seq].result_display),": ",wr," ",
     trim(dlrec->seq[d1.seq].result)," ",reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=4)
    AND (dlrec->seq[d1.seq].result > " "))
    temp = concat("  ",trim(dlrec->seq[d1.seq].result)," ",wr," ",
     reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=5)
    AND (dlrec->seq[d1.seq].result_display > " "))
    temp = concat(wb,trim(dlrec->seq[d1.seq].result_display)," ",wr," ",
     trim(dlrec->seq[d1.seq].result)," ",reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=7))
    temp = concat(wb,trim(dlrec->seq[d1.seq].result_display)," ",wr," ",
     trim(dlrec->seq[d1.seq].result)," ",reol), addtoreply
   ENDIF
   IF ((dlrec->seq[d1.seq].category=8))
    temp = concat(wb,trim(dlrec->seq[d1.seq].result_display)," ",wr," ",
     trim(dlrec->seq[d1.seq].result)," ",reol), addtoreply
   ENDIF
  FOOT  category
   temp = " "
   IF ((dlrec->seq[d1.seq].category=2))
    temp = reol, addtoreply, temp = reol,
    addtoreply
   ELSEIF ((dlrec->seq[d1.seq].category=5))
    temp = reol, addtoreply
   ELSE
    addtoreply
   ENDIF
  WITH noforms
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD pt
 FREE RECORD dlrec
 FREE RECORD request
END GO
