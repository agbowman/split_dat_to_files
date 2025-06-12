CREATE PROGRAM bhs_ma_gen_status_info:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE dialysis_106 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"DIALYSISTXPROCEDURES")),
 protect
 DECLARE vent_106 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"VENTILATIONINVASIVE")),
 protect
 DECLARE treatmentplan_200 = f8 WITH constant(uar_get_code_by("dislaykey",200,"TREATMENTPLAN")),
 protect
 DECLARE chemocycle_200 = f8 WITH constant(uar_get_code_by("displaykey",200,"CHEMOTHERAPYCYCLE")),
 protect
 DECLARE isol_106 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION")), protect
 DECLARE rt_106 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RTTXPROCEDURES")), protect
 DECLARE spiritualsacramentalresources = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSACRAMENTALRESOURCES")), protect
 DECLARE authorizedtodiscusspatientshealth = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTHORIZEDTODISCUSSPATIENTSHEALTH")), protect
 DECLARE trach_type = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRACHAIRWAYTYPE")), protect
 DECLARE trach_time = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRACHTUBEINSERTDATETIME")),
 protect
 DECLARE trach_size = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRACHEOSTOMYSIZE")), protect
 DECLARE eid = f8
 DECLARE pid = f8
 SET eid = request->visit[1].encntr_id
 DECLARE rntorn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN")), protect
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE advacedirective = f8 WITH public, constant(uar_get_code_by("displaykey",72,
   "ADVANCEDIRECTIVE"))
 DECLARE orgdonor = f8 WITH public, constant(uar_get_code_by("displaykey",72,"ORGANDONOR"))
 DECLARE contactperson = f8 WITH public, constant(uar_get_code_by("displaykey",72,"CONTACTPERSON"))
 DECLARE contactphone = f8 WITH public, constant(uar_get_code_by("displaykey",72,"HOMEPHONENUMBER"))
 DECLARE language = f8 WITH public, constant(uar_get_code_by("displaykey",72,"LANGUAGESPOKENV001"))
 DECLARE dietcd = f8 WITH public, constant(uar_get_code_by("displaykey",6000,"NUTRITIONSERVICES"))
 DECLARE code_status_cd1 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NORESUSCITATION"))
 DECLARE code_status_cd2 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd3 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLRESUSCITATION"))
 DECLARE code_status_cd4 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd5 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDRESUSCITATION"))
 DECLARE code_status_cd6 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NOPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd7 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "RESUSCITATIONPERIOPERATIVE"))
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
  SET request->visit[1].encntr_id = 33799517.00
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
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD info
 RECORD info(
   1 code_status = vc
   1 hcp = vc
   1 orgdonor = vc
   1 visitreason = vc
   1 problist = vc
   1 dietords = vc
   1 ventords = vc
   1 dialords = vc
   1 chemords = vc
   1 treaords = vc
   1 isolords = vc
   1 rtords = vc
   1 emrperson = vc
   1 emrphone = vc
   1 language = vc
   1 admitdx = vc
   1 otherdx = vc
   1 trachtype = vc
   1 trachsize = vc
   1 trachtime = vc
   1 sacramentofsick = vc
   1 authtodiscuss = vc
   1 rntorn[*]
     2 ordmnemonic = vc
     2 orddate = vc
 )
 SET x = 1
 SET lidx = 0
 SET tmp_display1 = fillstring(30," ")
 DECLARE temp_disp1 = vc
 DECLARE temp_disp2 = vc
 DECLARE temp_disp5 = vc
 DECLARE temp_disp6 = vc
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
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=eid
    AND ((((o.catalog_cd+ 0) IN (code_status_cd1, code_status_cd2, code_status_cd3, code_status_cd4,
   code_status_cd5,
   code_status_cd6, code_status_cd7))
    AND ((o.order_status_cd+ 0)=o_ordered_cd)) OR (((o.catalog_cd+ 0) IN (1849265, 103359880, 1849244,
   1849246, 1849259,
   1849248, 1849261, 1849257, 1849253, 1849267,
   1849263))
    AND o.template_order_id=0
    AND ((o.order_status_cd+ 0)=o_ordered_cd))) )
  ORDER BY o.current_start_dt_tm
  HEAD REPORT
   c = 0
  DETAIL
   IF (o.activity_type_cd != rntorn)
    info->code_status = trim(o.order_mnemonic)
   ELSE
    c = (c+ 1), stat = alterlist(info->rntorn,c), info->rntorn[c].ordmnemonic = trim(o
     .order_detail_display_line),
    info->rntorn[c].orddate = trim(format(o.orig_ord_as_flag,"mm/dd/yy hh:mm;;q"))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ((ce.event_cd+ 0) IN (advacedirective, orgdonor, contactperson, contactphone, language,
   spiritualsacramentalresources, authorizedtodiscusspatientshealth, trach_time, trach_size,
   trach_type))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.event_start_dt_tm
  DETAIL
   IF (ce.event_cd=advacedirective)
    info->hcp = trim(ce.event_tag)
   ELSEIF (ce.event_cd=orgdonor)
    info->orgdonor = trim(ce.event_tag)
   ELSEIF (ce.event_cd=contactperson)
    info->emrperson = trim(ce.event_tag)
   ELSEIF (ce.event_cd=contactphone)
    info->emrphone = trim(ce.event_tag)
   ELSEIF (ce.event_cd=language)
    info->language = trim(ce.event_tag)
   ELSEIF (ce.event_cd=spiritualsacramentalresources
    AND ce.result_val IN ("Sacrament*", "Baptism*"))
    info->sacramentofsick = concat(trim(ce.result_val)," ",concat(format(ce.clinsig_updt_dt_tm,
       "mm/dd/yy hh:mm;;q")))
   ELSEIF (ce.event_cd=authorizedtodiscusspatientshealth)
    info->authtodiscuss = trim(ce.result_val)
   ELSEIF (ce.event_cd=trach_type)
    info->trachtype = trim(ce.result_val)
   ELSEIF (ce.event_cd=trach_size)
    info->trachsize = trim(ce.result_val)
   ELSEIF (ce.event_cd=trach_time)
    info->trachtime = trim(substring(3,16,ce.result_val)), info->trachtime = concat(substring(5,2,
      info->trachtime),"/",substring(7,2,info->trachtime),"/",substring(1,4,info->trachtime),
     " ",substring(9,2,info->trachtime),":",substring(11,2,info->trachtime))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=eid)
  DETAIL
   pid = e.person_id, info->admitdx = trim(e.reason_for_visit)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.encntr_id, diag_dt_tm = cnvtdatetime(d.diag_dt_tm), d.nomenclature_id,
  d.diagnosis_id
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE d.encntr_id=eid
    AND ((cnvtdatetime(curdate,curtime3)+ 0) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm)
    AND ((d.active_ind+ 0)=1))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
  ORDER BY d.encntr_id, diag_dt_tm DESC, d.nomenclature_id,
   d.diagnosis_id
  HEAD REPORT
   temp = fillstring(500,"")
  DETAIL
   IF (n.nomenclature_id > 0)
    temp = n.source_string
   ELSEIF (size(trim(d.diag_ftdesc)) > 0)
    temp = d.diag_ftdesc
   ELSEIF (size(trim(d.diagnosis_display)) > 0)
    temp = d.diagnosis_display
   ENDIF
   IF ((info->otherdx > ""))
    info->otherdx = concat(info->otherdx,"\par","_",temp)
   ELSE
    info->otherdx = concat("\par","_",temp)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE prob_active_cd = f8
 SET prob_active_cd = uar_get_code_by("displaykey",12030,"ACTIVE")
 DECLARE prob_inactive_cd = f8
 SET prob_inactive_cd = uar_get_code_by("displaykey",12030,"INACTIVE")
 SELECT INTO "nl:"
  FROM encounter e,
   problem p,
   nomenclature n
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.life_cycle_status_cd IN (prob_active_cd, prob_inactive_cd)
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
  ORDER BY p.onset_dt_tm
  HEAD REPORT
   tempprob = fillstring(100," ")
  DETAIL
   IF (size(trim(p.annotated_display)) > 0)
    tempprob = p.annotated_display
   ELSEIF (size(trim(n.source_string)) > 0)
    tempprob = n.source_string
   ELSE
    tempprob = p.problem_ftdesc
   ENDIF
   IF ((info->problist > " "))
    info->problist = concat(info->problist,"\par","_",tempprob)
   ELSE
    info->problist = concat("\par","_",tempprob)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.person_id=pid
    AND ((o.catalog_type_cd=dietcd) OR (((o.activity_type_cd IN (dialysis_106, vent_106, isol_106,
   rt_106)) OR (o.catalog_cd IN (treatmentplan_200, chemocycle_200, 31942634.00))) ))
    AND ((o.order_status_cd+ 0)=o_ordered_cd)
    AND o.template_order_id=0)
  ORDER BY o.current_start_dt_tm DESC
  DETAIL
   CASE (o.catalog_type_cd)
    OF dietcd:
     IF ((info->dietords > " "))
      info->dietords = concat(info->dietords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->dietords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
   ENDCASE
   CASE (o.activity_type_cd)
    OF dialysis_106:
     IF ((info->dialords > " "))
      info->dialords = concat(info->dialords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->dialords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
    OF vent_106:
     IF ((info->ventords > " "))
      info->ventords = concat(info->ventords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->ventords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
    OF isol_106:
     IF ((info->isolords > " "))
      info->isolords = concat(info->isolords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->isolords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
    OF rt_106:
     IF ((info->rtords > " "))
      info->rtords = concat(info->rtords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->rtords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
   ENDCASE
   CASE (o.catalog_cd)
    OF chemocycle_200:
     IF ((info->chemords > " "))
      info->chemords = concat(info->chemords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->chemords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
    OF 31942634.00:
     IF ((info->treaords > " "))
      info->treaords = concat(info->treaords,reol,"_",trim(o.order_mnemonic),": ",
       trim(o.clinical_display_line))
     ELSE
      info->treaords = concat(reol,"_",trim(o.order_mnemonic),": ",trim(o.clinical_display_line))
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "PATIENT INFORMATION"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Code Status: ",wr,info->code_status)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Spiritual/Sacramental Resources: ",wr,info->sacramentofsick)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Organ Donor: ",wr,info->orgdonor)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Emergency Contact: ",wr,info->emrperson," / ",info->emrphone)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Authorized to Discuss Patients Health: ",wr,info->authtodiscuss)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("HCP: ",wr,info->hcp)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Admitting Dx: ",wr,info->admitdx)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Other Dx: ",wr,info->otherdx)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Problem List: ",wr,info->problist)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("RN To RN Communications: ")
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 FOR (x = 1 TO size(info->rntorn,5))
   SET lidx = (lidx+ 1)
   SET stat = alterlist(drec->line_qual,lidx)
   SET temp_disp1 = concat(wr,">>",info->rntorn[x].ordmnemonic)
   SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDFOR
 IF ((info->isolords > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Isolation: ",wr,info->isolords)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Diet: ",wr,info->dietords)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 IF ((info->trachtype > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Trach Airway Type: ",wr,info->trachtype)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((info->trachtime > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Trach Tube Insert Date/Time: ",wr,info->trachtime)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((info->trachsize > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Tracheostomy size: ",wr,info->trachsize)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((info->ventords > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Vent: ",wr,info->ventords)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((info->dialords > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Dialysis: ",wr,info->dialords)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 IF ((info->rtords > " "))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("Respiratory Therapy: ",wr,info->rtords)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
