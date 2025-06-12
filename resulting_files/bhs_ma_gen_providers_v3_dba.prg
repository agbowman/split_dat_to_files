CREATE PROGRAM bhs_ma_gen_providers_v3:dba
 DECLARE dischargevnahomecare = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEVNAHOMECARE")), protect
 DECLARE dischargenursingfacilities = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGENURSINGFACILITIES")), protect
 DECLARE dischargelongtermcarefacility = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGELONGTERMCAREFACILITY")), protect
 DECLARE modeoftransportationarranged = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFTRANSPORTATIONARRANGED")), protect
 DECLARE dischargearrangedtransportdatetime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEARRANGEDTRANSPORTDATETIME")), protect
 DECLARE dischargetransportationarranged = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGETRANSPORTATIONARRANGED")), protect
 DECLARE dischargelevelofcareatdischarge = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGELEVELOFCAREATDISCHARGE")), protect
 DECLARE consultdoc = f8 WITH constant(uar_get_code_by("MEANING",333,"CONSULTDOC")), protect
 DECLARE attendoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC")), protect
 DECLARE pcp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",331,"PCP")), protect
 DECLARE resident_oe_field_id = f8
 DECLARE covering_resident_dta = f8
 DECLARE covering_resident_pager_dta = f8
 DECLARE teaching_coverage = f8
 DECLARE rncd = f8
 DECLARE pid = f8
 SET resident_oe_field_id = 963911.00
 SET covering_resident_dta = uar_get_code_by("displaykey",72,"COVERINGRESIDENT")
 SET covering_resident_pager_dta = uar_get_code_by("displaykey",72,"COVERINGRESIDENTPAGER")
 SET eid =  $1
 SET teaching_coverage = uar_get_code_by("displaykey",200,"TEACHINGCOVERAGE")
 SET rncd = uar_get_code_by("displaykey",88,"BHSRN")
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mdtornconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNCONSULTS"))
 CALL echo(mdtornconsults_cd)
 DECLARE consults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 CALL echo(consults_cd)
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
 FREE RECORD providers
 RECORD providers(
   1 pcp = vc
   1 attn = vc
   1 resident = vc
   1 covresident = vc
   1 pager = vc
   1 rn = vc
   1 casemgmt = vc
   1 referral[*]
     2 refname = vc
   1 consultsord[*]
     2 ordname = vc
   1 consultsprv[*]
     2 prvname = vc
   1 disch_plan[*]
     2 disch_labele = vc
     2 disch_content = vc
 )
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
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
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=eid
    AND o.template_order_flag IN (0, 1)
    AND o.orderable_type_flag=0
    AND o.activity_type_cd IN (mdtornconsults_cd, consults_cd))
  ORDER BY o.encntr_id, o.orig_order_dt_tm, o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(providers->consultsord,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(providers->consultsord,(cnt+ 10))
   ENDIF
   providers->consultsord[cnt].ordname = build(wb,o.order_mnemonic,":",wr,o.clinical_display_line)
  FOOT  o.encntr_id
   stat = alterlist(providers->consultsord,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(providers)
 GO TO end_report
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (epr
   WHERE epr.encntr_id=eid
    AND epr.encntr_prsnl_r_cd IN (attendoc)
    AND epr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  ORDER BY epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (epr.encntr_prsnl_r_cd=consultdoc)
    cnt = (cnt+ 1), stat = alterlist(providers->consultsprv,cnt), providers->consultsprv[cnt].prvname
     = concat(wb,"Consults: ",wr,pr.name_full_formatted)
   ENDIF
   IF (epr.encntr_prsnl_r_cd=attendoc)
    providers->attn = pr.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person_prsnl_reltn ppr,
   prsnl pr
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (ppr
   WHERE ppr.person_id=e.person_id
    AND ppr.person_prsnl_r_cd=pcp
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD ppr.person_prsnl_r_cd
   providers->pcp = pr.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ((ce.event_cd+ 0) IN (covering_resident_dta, covering_resident_pager_dta,
   dischargelevelofcareatdischarge, dischargetransportationarranged,
   dischargearrangedtransportdatetime,
   modeoftransportationarranged, dischargelongtermcarefacility, dischargenursingfacilities,
   dischargevnahomecare))
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD REPORT
   c = 0
  HEAD ce.event_cd
   IF (ce.event_cd=covering_resident_dta)
    providers->covresident = trim(ce.result_val)
   ELSEIF (ce.event_cd=covering_resident_pager_dta)
    providers->pager = trim(ce.result_val)
   ELSEIF (ce.event_cd IN (dischargelevelofcareatdischarge, dischargetransportationarranged,
   dischargearrangedtransportdatetime, modeoftransportationarranged, dischargelongtermcarefacility,
   dischargenursingfacilities, dischargevnahomecare))
    c = (c+ 1), stat = alterlist(providers->disch_plan,c), providers->disch_plan[c].disch_labele =
    trim(uar_get_code_display(ce.event_cd)),
    providers->disch_plan[c].disch_content = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.encntr_id=eid
    AND ((o.catalog_cd+ 0)=teaching_coverage)
    AND ((o.order_status_cd+ 0) IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
   o_pending_rev_cd)))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=resident_oe_field_id)
  ORDER BY o.orig_order_dt_tm
  DETAIL
   IF ((providers->resident > " "))
    providers->resident = concat(providers->resident,"; ",trim(od.oe_field_display_value))
   ELSE
    providers->resident = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(providers)
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl pr
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ce.event_title_text="Case Management *"
    AND ce.view_level=1)
   JOIN (pr
   WHERE pr.person_id=ce.updt_id)
  ORDER BY ce.event_start_dt_tm
  DETAIL
   providers->casemgmt = pr.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p = uar_get_code_display(p.position_cd), sa.beg_effective_dt_tm,
  sa.end_effective_dt_tm, a = sa.active_ind, pu = sa.purge_ind
  FROM encounter e,
   dcp_shift_assignment sa,
   prsnl p
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (sa
   WHERE ((sa.loc_bed_cd=e.loc_bed_cd) OR (((sa.loc_bed_cd=0
    AND sa.loc_room_cd=e.loc_room_cd
    AND sa.active_ind=1
    AND sa.purge_ind=0) OR (sa.loc_room_cd=0
    AND sa.loc_unit_cd=e.loc_nurse_unit_cd
    AND sa.active_ind=1
    AND sa.purge_ind=0
    AND sa.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN sa.beg_effective_dt_tm AND sa.end_effective_dt_tm))
   )) )
   JOIN (p
   WHERE p.person_id=sa.prsnl_id)
  ORDER BY sa.end_effective_dt_tm
  DETAIL
   IF (sa.active_ind=1
    AND sa.purge_ind=0
    AND p="BHS RN")
    providers->rn = trim(p.name_full_formatted)
   ENDIF
  WITH format(date,";;q")
 ;end select
 SET x = 1
 SET lidx = 0
 SET tmp_display1 = fillstring(30," ")
 DECLARE temp_disp1 = vc
 DECLARE temp_disp2 = vc
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "PRIMARY PROVIDERS"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Primary Care Physician: ",wr,providers->pcp)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Attending: ",wr,providers->attn)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Covering Physician: ",wr,providers->covresident)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Covering Physician Pager: ",wr,providers->pager)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("RN: ",wr,providers->rn)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF (size(providers->consultsprv,5) > 0)
  SET temp_disp2 = trim(providers->consultsprv[1].prvname)
  IF (size(providers->consultsprv,5) > 1)
   FOR (x = 1 TO size(providers->consultsprv,5))
     SET temp_disp2 = concat(temp_disp2,"; ",trim(providers->consultsprv[x].prvname))
   ENDFOR
  ENDIF
  SET temp_disp1 = concat(temp_disp2)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 IF (size(providers->consultsord,5) > 0)
  SET temp_disp2 = trim(providers->consultsord[1].ordname)
  IF (size(providers->consultsord,5) > 1)
   FOR (x = 1 TO size(providers->consultsord,5))
     SET temp_disp2 = concat(temp_disp2,"; ",reol,trim(providers->consultsord[x].ordname))
   ENDFOR
  ENDIF
  SET temp_disp1 = concat(temp_disp2)
  SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Case Manager: ",wr,providers->casemgmt)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Discharge Plan: ")
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 FOR (x = 1 TO size(providers->disch_plan,5))
   SET lidx = (lidx+ 1)
   SET stat = alterlist(drec->line_qual,lidx)
   SET temp_disp1 = concat(providers->disch_plan[x].disch_labele,": ",wr,providers->disch_plan[x].
    disch_content)
   SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 ENDFOR
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 FREE RECORD dlrec
 FREE RECORD request
#end_report
END GO
