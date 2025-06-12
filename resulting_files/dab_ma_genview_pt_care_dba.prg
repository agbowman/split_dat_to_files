CREATE PROGRAM dab_ma_genview_pt_care:dba
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
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 category = i2
     2 category_name = vc
     2 result_sort = i2
     2 result_display = vc
     2 result_date = dq8
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
 DECLARE dietary_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE respther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE diets_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"DIETS"))
 DECLARE supplements_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"SUPPLEMENTS"))
 DECLARE infantformulas_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INFANTFORMULAS"))
 DECLARE infantformulaadditives_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INFANTFORMULAADDITIVES"))
 DECLARE testdiet_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"TESTDIET"))
 DECLARE tubefeedingcontinuous_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGCONTINUOUS"))
 DECLARE tubefeedingadditives_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGADDITIVES"))
 DECLARE tubefeedingbolus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGBOLUS"))
 DECLARE nutritionservicesconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NUTRITIONSERVICESCONSULTS"))
 SET stat = alterlist(dlrec->seq,request->visit_cnt)
 DECLARE rttxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "RTTXPROCEDURES"))
 DECLARE nsgrespiratorytx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NSGRESPIRATORYTX"))
 DECLARE ventilationnoninvasive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONNONINVASIVE"))
 DECLARE ventilationinvasive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONINVASIVE"))
 DECLARE sleepstudies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"SLEEPSTUDIES"))
 SET stat = alterlist(dlrec->seq,request->visit_cnt)
 DECLARE woundcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE orthopedictreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ORTHOPEDICTREATMENTS"))
 DECLARE orthosupply_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ORTHOSUPPLY"))
 DECLARE asmttxmonitoring_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ASMTTXMONITORING"))
 DECLARE intakeandoutput_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INTAKEANDOUTPUT"))
 SET stat = alterlist(dlrec->seq,request->visit_cnt)
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND ((o.order_status_cd+ 0) IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
   o_pending_rev_cd))
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd IN (diets_cd, supplements_cd, infantformulas_cd, infantformulaadditives_cd,
   testdiet_cd,
   tubefeedingcontinuous_cd, tubefeedingadditives_cd, tubefeedingbolus_cd,
   nutritionservicesconsults_cd, rttxprocedures_cd,
   nsgrespiratorytx_cd, ventilationnoninvasive_cd, ventilationinvasive_cd, sleepstudies_cd,
   woundcare_cd,
   orthopedictreatments_cd, orthosupply_cd, asmttxmonitoring_cd, intakeandoutput_cd))
  ORDER BY cnvtdatetime(o.orig_order_dt_tm), o.order_id
  HEAD REPORT
   cnt = 0, stat = alterlist(dlrec->seq,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq,(cnt+ 10))
   ENDIF
   dlrec->seq[cnt].result_id = o.order_id, dlrec->seq[cnt].result_display = o.order_mnemonic, dlrec->
   seq[cnt].result = o.clinical_display_line,
   dlrec->seq[cnt].result_date = cnvtdatetime(o.orig_order_dt_tm)
   IF (o.activity_type_cd=diets_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 1
   ELSEIF (o.activity_type_cd=supplements_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 2
   ELSEIF (o.activity_type_cd=infantformulas_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 3
   ELSEIF (o.activity_type_cd=infantformulaadditives_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 4
   ELSEIF (o.activity_type_cd=testdiet_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 5
   ELSEIF (o.activity_type_cd=tubefeedingcontinuous_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 6
   ELSEIF (o.activity_type_cd=tubefeedingadditives_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 7
   ELSEIF (o.activity_type_cd=tubefeedingbolus_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 8
   ELSEIF (o.activity_type_cd=nutritionservicesconsults_cd)
    dlrec->seq[cnt].category = 1, dlrec->seq[cnt].result_sort = 9
   ELSEIF (o.activity_type_cd=rttxprocedures_cd)
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_sort = 1
   ELSEIF (o.activity_type_cd=nsgrespiratorytx_cd)
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_sort = 2
   ELSEIF (o.activity_type_cd=ventilationnoninvasive_cd)
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_sort = 3
   ELSEIF (o.activity_type_cd=ventilationinvasive_cd)
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_sort = 4
   ELSEIF (o.activity_type_cd=sleepstudies_cd)
    dlrec->seq[cnt].category = 2, dlrec->seq[cnt].result_sort = 5
   ELSEIF (o.activity_type_cd=asmttxmonitoring_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 1
   ELSEIF (o.activity_type_cd=orthosupply_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 3
   ELSEIF (o.activity_type_cd=orthopedictreatments_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 4
   ELSEIF (o.activity_type_cd=woundcare_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 5
   ELSEIF (o.activity_type_cd=intakeandoutput_cd)
    dlrec->seq[cnt].category = 3, dlrec->seq[cnt].result_sort = 6
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  category = dlrec->seq[d1.seq].category, result_sort = dlrec->seq[d1.seq].result_sort, result_date
   = dlrec->seq[d1.seq].result_date
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY category, result_sort, result_date
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu," Patient Care Orders ",wr,reol), addtoreply
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
   IF ((dlrec->seq[d1.seq].category=1))
    title_string = "Diet: ", gtitle_print
   ELSEIF ((dlrec->seq[d1.seq].category=2))
    title_string = "Respiratory Therapy: ", gtitle_print
   ELSEIF ((dlrec->seq[d1.seq].category=3))
    title_string = "Assess/Monitor/Treat: ", gtitle_print
   ENDIF
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
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
