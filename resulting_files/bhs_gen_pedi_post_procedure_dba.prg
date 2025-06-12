CREATE PROGRAM bhs_gen_pedi_post_procedure:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE business = f8 WITH constant(uar_get_code_by("MEANING",43,"BUSINESS")), protect
 DECLARE home = f8 WITH constant(uar_get_code_by("MEANING",43,"HOME")), protect
 DECLARE nok = f8 WITH constant(uar_get_code_by("MEANING",351,"NOK")), protect
 DECLARE emc = f8 WITH constant(uar_get_code_by("MEANING",351,"EMC")), protect
 SET eid = request->visit[1].encntr_id
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
  SET request->visit[1].encntr_id = 32207420.00
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
 FREE RECORD pedi
 RECORD pedi(
   1 emrname = vc
   1 bemrphone = vc
   1 hemrphone = vc
   1 nokname = vc
   1 bnokphone = vc
   1 hnokphone = vc
   1 proc = vc
 )
 SET x = 1
 SET lidx = 0
 DECLARE tmp_display1 = vc
 DECLARE temp_disp1 = vc
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
  FROM encntr_person_reltn epr,
   person p,
   phone ph
  PLAN (epr
   WHERE epr.encntr_id=eid
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate
    AND ((epr.person_reltn_type_cd+ 0) IN (nok, emc)))
   JOIN (p
   WHERE p.person_id=epr.related_person_id)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON")
  DETAIL
   IF (epr.person_reltn_type_cd=emc)
    pedi->emrname = concat(trim(p.name_full_formatted)," - ",uar_get_code_display(epr.person_reltn_cd
      ))
    IF (ph.phone_type_cd=home)
     pedi->hemrphone = trim(ph.phone_num)
    ELSEIF (ph.phone_type_cd=business)
     pedi->bemrphone = trim(ph.phone_num)
    ENDIF
   ELSEIF (epr.person_reltn_type_cd=nok)
    pedi->nokname = concat(trim(p.name_full_formatted)," - ",uar_get_code_display(epr.person_reltn_cd
      ))
    IF (ph.phone_type_cd=home)
     pedi->hnokphone = trim(ph.phone_num)
    ELSEIF (ph.phone_type_cd=business)
     pedi->bnokphone = trim(ph.phone_num)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=eid)
  DETAIL
   pedi->proc = trim(e.reason_for_visit)
  WITH nocounter
 ;end select
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Emergency Contact: ",wr,pedi->emrname)
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Business Phone: ",wr,pedi->bemrphone)
 SET drec->line_qual[lidx].disp_line = concat(rtab,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Home Phone: ",wr,pedi->hemrphone)
 SET drec->line_qual[lidx].disp_line = concat(rtab,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Next of Kin: ",wr,pedi->nokname)
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Business Phone: ",wr,pedi->bnokphone)
 SET drec->line_qual[lidx].disp_line = concat(rtab,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Home Phone: ",wr,pedi->hnokphone)
 SET drec->line_qual[lidx].disp_line = concat(rtab,rh2bu,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Booked Procedure: ",wr,pedi->proc)
 SET drec->line_qual[lidx].disp_line = concat(rh2bu,trim(temp_disp1),reol)
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
