CREATE PROGRAM bsc_retrieve_waste_results:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 med_event_qual[*]
      2 parent_event_id = f8
    1 facility_cd = f8
    1 begin_search_date_tm = dq8
    1 end_search_date_tm = dq8
  )
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 encntr_id = f8
     2 parent_event_id = f8
     2 related_med_event_id = f8
     2 event_title = vc
     2 person_id = f8
     2 nurse_unit_cd = f8
     2 order_id = f8
     2 bag_nbr = vc
     2 dta_waste_string = vc
     2 vol_waste_val = f8
     2 vol_waste_unit_cd = f8
     2 waste_event_dt_tm = dq8
     2 ingred_qual[*]
       3 waste_val = f8
       3 med_event_id = f8
       3 waste_unit_cd = f8
       3 catalog_cd = f8
       3 ingred_event_id = f8
       3 event_title = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE retrievebyeventid(null) = null
 DECLARE retrievebyrange(null) = null
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE swaste_cki = vc WITH protect, constant("CERNER!88D791DC-3E81-4A42-BADC-67D350348341")
 DECLARE divparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE divwaste = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"WASTE"))
 DECLARE din_error = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE dinerrnomut = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE dinerrnoview = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE dinerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE dbeginbag = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE lparentmedevents = i4 WITH protect, noconstant(0)
 DECLARE lparenteventids = i4 WITH protect, noconstant(0)
 DECLARE lwasteevents = i4 WITH protect, noconstant(0)
 DECLARE lingredevents = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE dstarttime3 = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE ncnt = i4 WITH protect, noconstant(0)
 DECLARE dparenteventid = f8 WITH protect, noconstant(0)
 DECLARE nextbegindttm = dq8 WITH protect, noconstant(cnvtdatetime(000000,0))
 CALL echo(sline)
 CALL echo("********** BEGIN bsc_retrieve_waste_results **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SET reply->status_data.status = "F"
 SET lparentmedevents = size(request->med_event_qual,5)
 IF (lparentmedevents > 0)
  CALL retrievebyeventids(null)
 ELSEIF ((request->facility_cd > 0)
  AND (request->begin_search_date_tm > 0)
  AND (request->end_search_date_tm > 0))
  CALL retrievebyrange(null)
 ENDIF
 SET stat = alterlist(reply->qual,lwasteevents)
 IF (lwasteevents >= 1)
  SET reply->status_data.status = "S"
  SET sscriptmsg = ""
 ELSE
  SET reply->status_data.status = "Z"
  SET sscriptmsg = "No results found"
 ENDIF
 GO TO exit_script
 SUBROUTINE retrievebyeventids(null)
   CALL echo("********** BEGIN RetrieveByEventIDs DTA waste events query **********")
   SELECT INTO "nl:"
    FROM code_value cv,
     clinical_event ce
    PLAN (cv
     WHERE cv.concept_cki=swaste_cki
      AND cv.code_set=72)
     JOIN (ce
     WHERE expand(lidx,1,lparentmedevents,ce.parent_event_id,request->med_event_qual[lidx].
      parent_event_id)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.publish_flag=1
      AND ce.event_cd=cv.code_value
      AND  NOT (ce.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
    DETAIL
     IF ( NOT (((ce.result_status_cd=din_error) OR (((ce.result_status_cd=dinerrnomut) OR (((ce
     .result_status_cd=dinerrnoview) OR (ce.result_status_cd=dinerror)) )) )) ))
      lwasteevents += 1
      IF (mod(lwasteevents,10)=1)
       stat = alterlist(reply->qual,(lwasteevents+ 9))
      ENDIF
      reply->qual[lwasteevents].parent_event_id = ce.parent_event_id, reply->qual[lwasteevents].
      related_med_event_id = ce.parent_event_id, reply->qual[lwasteevents].dta_waste_string = ce
      .result_val
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after DTA lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
   CALL echo("********** BEGIN RetrieveByEventIDs medication waste events query **********")
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr
    PLAN (ce
     WHERE expand(lidx,1,lparentmedevents,ce.parent_event_id,request->med_event_qual[lidx].
      parent_event_id)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.publish_flag=1
      AND  NOT (ce.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.iv_event_cd=0
      AND cmr.remaining_volume > 0
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    HEAD ce.parent_event_id
     lwasteevents += 1
     IF (mod(lwasteevents,10)=1)
      stat = alterlist(reply->qual,(lwasteevents+ 9))
     ENDIF
     lingredevents = 0, reply->qual[lwasteevents].parent_event_id = ce.parent_event_id, reply->qual[
     lwasteevents].related_med_event_id = ce.parent_event_id
    DETAIL
     lingredevents += 1, stat = alterlist(reply->qual[lwasteevents].ingred_qual,lingredevents), reply
     ->qual[lwasteevents].ingred_qual[lingredevents].waste_val = cmr.remaining_volume,
     reply->qual[lwasteevents].ingred_qual[lingredevents].waste_unit_cd = cmr
     .remaining_volume_unit_cd, reply->qual[lwasteevents].ingred_qual[lingredevents].ingred_event_id
      = ce.event_id, reply->qual[lwasteevents].ingred_qual[lingredevents].catalog_cd = ce.catalog_cd
    WITH nocounter, expand = 1
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after Meds lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
   CALL echo("********** BEGIN RetrieveByEventIDs continuous waste events query **********")
   CALL echo("Find the waste event_ids from the begin bag events")
   SELECT INTO "nl:"
    FROM clinical_event ce,
     clinical_event ce2,
     ce_med_result cemr
    PLAN (ce
     WHERE expand(lidx,1,lparentmedevents,ce.event_id,request->med_event_qual[lidx].parent_event_id)
      AND ce.order_id != 0.0)
     JOIN (ce2
     WHERE ce2.order_id=ce.order_id
      AND ce2.event_end_dt_tm > ce.event_end_dt_tm
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce2.publish_flag=1)
     JOIN (cemr
     WHERE cemr.event_id=ce2.event_id
      AND cemr.iv_event_cd IN (dbeginbag, divwaste))
    ORDER BY ce.event_id, ce2.parent_event_id, ce2.event_end_dt_tm
    HEAD ce.event_id
     dparenteventid = 0.0, lingredevents = 0, nextbegindttm = cnvtdatetime(0,0)
    HEAD ce2.parent_event_id
     IF ( NOT (((ce2.result_status_cd=din_error) OR (((ce2.result_status_cd=dinerrnomut) OR (((ce2
     .result_status_cd=dinerrnoview) OR (ce2.result_status_cd=dinerror)) )) )) )
      AND ((nextbegindttm=cnvtdatetime(0,0)) OR (ce2.event_end_dt_tm <= nextbegindttm)) )
      IF (cemr.iv_event_cd=divwaste
       AND dparenteventid=0.0)
       dparenteventid = ce2.parent_event_id, lwasteevents += 1
       IF (mod(lwasteevents,10)=1)
        stat = alterlist(reply->qual,(lwasteevents+ 9))
       ENDIF
      ELSE
       nextbegindttm = ce2.event_end_dt_tm
      ENDIF
     ENDIF
    DETAIL
     IF (ce2.parent_event_id=dparenteventid)
      IF (ce2.event_cd=divparent)
       reply->qual[lwasteevents].parent_event_id = ce2.parent_event_id, reply->qual[lwasteevents].
       related_med_event_id = ce.event_id, reply->qual[lwasteevents].vol_waste_val = cemr
       .admin_dosage,
       reply->qual[lwasteevents].vol_waste_unit_cd = cemr.dosage_unit_cd, reply->qual[lwasteevents].
       encntr_id = ce2.encntr_id, reply->qual[lwasteevents].bag_nbr = cemr.substance_lot_number
      ELSE
       lingredevents += 1, stat = alterlist(reply->qual[lwasteevents].ingred_qual,lingredevents),
       reply->qual[lwasteevents].ingred_qual[lingredevents].waste_val = cemr.admin_dosage,
       reply->qual[lwasteevents].ingred_qual[lingredevents].waste_unit_cd = cemr.dosage_unit_cd,
       reply->qual[lwasteevents].ingred_qual[lingredevents].catalog_cd = ce2.catalog_cd, reply->qual[
       lwasteevents].ingred_qual[lingredevents].ingred_event_id = ce2.event_id
      ENDIF
     ENDIF
    FOOT  ce2.parent_event_id
     stat = 0
    FOOT  ce.event_id
     stat = 0
    WITH nocounter, orahintcbo("LEADING(CE CE2 CEMR)","INDEX(CEMR XPKCE_MED_RESULT)",
      "USE_NL(CE2 CEMR)")
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after continuous lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
 END ;Subroutine
 SUBROUTINE retrievebyrange(null)
   CALL echo("********** BEGIN RetrieveByRange DTA waste events query **********")
   SELECT INTO "nl:"
    FROM code_value cv,
     clinical_event ce,
     ce_event_order_link ceol,
     encounter enc
    PLAN (cv
     WHERE cv.concept_cki=swaste_cki
      AND cv.code_set=72)
     JOIN (ce
     WHERE ce.event_end_dt_tm >= cnvtdatetime(request->begin_search_date_tm)
      AND ce.event_end_dt_tm <= cnvtdatetime(request->end_search_date_tm)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.publish_flag=1
      AND ce.event_cd=cv.code_value
      AND  NOT (ce.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
     JOIN (ceol
     WHERE ceol.event_id=ce.event_id)
     JOIN (enc
     WHERE enc.encntr_id=ce.encntr_id
      AND (enc.loc_facility_cd=request->facility_cd))
    ORDER BY ce.encntr_id
    DETAIL
     IF ( NOT (((ce.result_status_cd=din_error) OR (((ce.result_status_cd=dinerrnomut) OR (((ce
     .result_status_cd=dinerrnoview) OR (ce.result_status_cd=dinerror)) )) )) ))
      lwasteevents += 1
      IF (mod(lwasteevents,10)=1)
       stat = alterlist(reply->qual,(lwasteevents+ 9))
      ENDIF
      reply->qual[lwasteevents].parent_event_id = ce.parent_event_id, reply->qual[lwasteevents].
      dta_waste_string = ce.result_val, reply->qual[lwasteevents].encntr_id = enc.encntr_id,
      reply->qual[lwasteevents].person_id = enc.person_id, reply->qual[lwasteevents].order_id = ceol
      .parent_order_ident, reply->qual[lwasteevents].nurse_unit_cd = enc.loc_nurse_unit_cd,
      reply->qual[lwasteevents].waste_event_dt_tm = ce.event_end_dt_tm, reply->qual[lwasteevents].
      related_med_event_id = ce.parent_event_id, reply->qual[lwasteevents].event_title = ce
      .event_title_text
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after DTA lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
   CALL echo("********** BEGIN RetrieveByRange MEDs waste events query **********")
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr,
     ce_event_order_link ceol,
     encounter enc
    PLAN (ce
     WHERE ce.event_end_dt_tm >= cnvtdatetime(request->begin_search_date_tm)
      AND ce.event_end_dt_tm <= cnvtdatetime(request->end_search_date_tm)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.publish_flag=1
      AND  NOT (ce.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
     JOIN (cmr
     WHERE ce.event_id=cmr.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND cmr.remaining_volume > 0
      AND cmr.iv_event_cd=0)
     JOIN (ceol
     WHERE ceol.event_id=ce.event_id)
     JOIN (enc
     WHERE enc.encntr_id=ce.encntr_id
      AND (enc.loc_facility_cd=request->facility_cd))
    ORDER BY ce.encntr_id
    HEAD ce.parent_event_id
     lwasteevents += 1
     IF (mod(lwasteevents,10)=1)
      stat = alterlist(reply->qual,(lwasteevents+ 9))
     ENDIF
     lingredevents = 0, reply->qual[lwasteevents].encntr_id = enc.encntr_id, reply->qual[lwasteevents
     ].person_id = enc.person_id,
     reply->qual[lwasteevents].order_id = ceol.parent_order_ident, reply->qual[lwasteevents].
     nurse_unit_cd = enc.loc_nurse_unit_cd, reply->qual[lwasteevents].waste_event_dt_tm = ce
     .event_end_dt_tm,
     reply->qual[lwasteevents].related_med_event_id = ce.parent_event_id
    DETAIL
     lingredevents += 1, stat = alterlist(reply->qual[lwasteevents].ingred_qual,lingredevents), reply
     ->qual[lwasteevents].ingred_qual[lingredevents].waste_val = cmr.remaining_volume,
     reply->qual[lwasteevents].ingred_qual[lingredevents].waste_unit_cd = cmr
     .remaining_volume_unit_cd, reply->qual[lwasteevents].ingred_qual[lingredevents].ingred_event_id
      = ce.event_id, reply->qual[lwasteevents].ingred_qual[lingredevents].catalog_cd = ce.catalog_cd
    WITH nocounter, expand = 1
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after Meds Range lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
   CALL echo("********** BEGIN RetrieveByRange continuous waste events query **********")
   SELECT INTO "n1:"
    FROM clinical_event ce,
     clinical_event ce2,
     ce_med_result cemr,
     ce_event_order_link ceol,
     encounter enc
    PLAN (ce
     WHERE ce.event_end_dt_tm >= cnvtdatetime(request->begin_search_date_tm)
      AND ce.event_end_dt_tm <= cnvtdatetime(request->end_search_date_tm)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.event_cd=divparent
      AND ce.publish_flag=1)
     JOIN (ce2
     WHERE ce2.parent_event_id=ce.event_id
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce2.publish_flag=1
      AND  NOT (ce2.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
     JOIN (cemr
     WHERE ce2.event_id=cemr.event_id
      AND cemr.iv_event_cd=divwaste
      AND cemr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (ceol
     WHERE ce.event_id=ceol.event_id)
     JOIN (enc
     WHERE ce.encntr_id=enc.encntr_id
      AND (enc.loc_facility_cd=request->facility_cd))
    ORDER BY ce2.parent_event_id
    HEAD ce.event_id
     lingredevents = 0, lwasteevents += 1
     IF (mod(lwasteevents,10)=1)
      stat = alterlist(reply->qual,(lwasteevents+ 9))
     ENDIF
    DETAIL
     IF (ce2.event_cd=divparent)
      reply->qual[lwasteevents].parent_event_id = ce2.parent_event_id, reply->qual[lwasteevents].
      vol_waste_val = cemr.admin_dosage, reply->qual[lwasteevents].vol_waste_unit_cd = cemr
      .dosage_unit_cd,
      reply->qual[lwasteevents].encntr_id = ce2.encntr_id, reply->qual[lwasteevents].order_id = ceol
      .parent_order_ident, reply->qual[lwasteevents].bag_nbr = cemr.substance_lot_number,
      reply->qual[lwasteevents].person_id = enc.person_id, reply->qual[lwasteevents].nurse_unit_cd =
      enc.loc_nurse_unit_cd, reply->qual[lwasteevents].waste_event_dt_tm = cemr.admin_start_dt_tm,
      reply->qual[lwasteevents].event_title = ce2.event_title_text
     ELSE
      lingredevents += 1, stat = alterlist(reply->qual[lwasteevents].ingred_qual,lingredevents),
      reply->qual[lwasteevents].ingred_qual[lingredevents].waste_val = cemr.admin_dosage,
      reply->qual[lwasteevents].ingred_qual[lingredevents].waste_unit_cd = cemr.dosage_unit_cd, reply
      ->qual[lwasteevents].ingred_qual[lingredevents].catalog_cd = ce2.catalog_cd, reply->qual[
      lwasteevents].ingred_qual[lingredevents].ingred_event_id = ce2.event_id,
      reply->qual[lwasteevents].ingred_qual[lingredevents].event_title = ce2.event_title_text
     ENDIF
    FOOT  ce.event_id
     IF (lingredevents=0)
      lwasteevents -= 1
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(sline)
   CALL echo(concat("Events after continuous lookup: ",cnvtstring(lwasteevents)))
   CALL echo(sline)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(lwasteevents)),
     ce_event_order_link ceol,
     clinical_event ce,
     ce_med_result cmr
    PLAN (d)
     JOIN (ceol
     WHERE (ceol.order_id=reply->qual[d.seq].order_id))
     JOIN (ce
     WHERE ce.parent_event_id=ceol.event_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.publish_flag=1
      AND  NOT (ce.result_status_cd IN (din_error, dinerrnomut, dinerrnoview, dinerror)))
     JOIN (cmr
     WHERE cmr.event_id=ceol.event_id
      AND cmr.iv_event_cd=dbeginbag
      AND cmr.admin_start_dt_tm <= cnvtdatetime(reply->qual[d.seq].waste_event_dt_tm))
    ORDER BY d.seq, cmr.admin_start_dt_tm DESC
    HEAD d.seq
     CALL echo(build("d.seq",d.seq)),
     CALL echo(build("event id",cmr.event_id)), reply->qual[d.seq].related_med_event_id = cmr
     .event_id
    DETAIL
     CALL echo(build("detail.seq",cmr.event_id)), lidx = locateval(lidx2,1,size(reply->qual[d.seq].
       ingred_qual,5),ce.catalog_cd,reply->qual[d.seq].ingred_qual[lidx2].catalog_cd)
     IF (lidx > 0)
      CALL echo("in lIdx")
      IF ((reply->qual[d.seq].ingred_qual[lidx].med_event_id <= 0))
       CALL echo("in event check"), reply->qual[d.seq].ingred_qual[lidx].med_event_id = cmr.event_id
      ENDIF
     ENDIF
   ;end select
 END ;Subroutine
#exit_script
 SET reply->status_data.subeventstatus[1].operationstatus = reply->status_data.status
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 SET reply->status_data.subeventstatus[1].targetobjectname = curprog
 IF ((((reply->status_data.status="S")) OR ((reply->status_data.status="Z"))) )
  SET reply->status_data.subeventstatus[1].operationname = ""
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
 ENDIF
 SET delapsedtime = ((curtime3 - dstarttime3)/ 100)
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 SET last_mod = "002"
 SET mod_date = "03/15/2019"
 SET modify = nopredeclare
 CALL echo(sline)
 CALL echo("********** END bsc_retrieve_waste_results **********")
 CALL echo(sline)
END GO
