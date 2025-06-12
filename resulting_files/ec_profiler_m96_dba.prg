CREATE PROGRAM ec_profiler_m96:dba
 DECLARE startpos = i4 WITH noconstant(0)
 DECLARE endpos = i4 WITH noconstant(0)
 DECLARE shold = vc WITH noconstant(" ")
 DECLARE icur_list_size = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE inew_list_size = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 FREE RECORD section_hold
 RECORD section_hold(
   1 qual[*]
     2 section_id = f8
 )
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM cr_report_section crs,
   long_text_reference ltr
  PLAN (crs
   WHERE crs.report_section_id > 0)
   JOIN (ltr
   WHERE ltr.long_text_id=crs.long_text_id)
  HEAD REPORT
   icnt = 0
  DETAIL
   startpos = findstring('<parameter classification="result" name="include-images"',ltr.long_text)
   IF (startpos > 0)
    endpos = findstring(">",substring(startpos,(size(ltr.long_text,1) - startpos),ltr.long_text)),
    startpos = (startpos+ endpos), endpos = findstring("</parameter>",substring(startpos,50,ltr
      .long_text))
    IF (startpos > 0
     AND endpos > 0)
     shold = substring(startpos,(endpos - 1),ltr.long_text)
     IF (shold="true")
      icnt = (icnt+ 1), stat = alterlist(section_hold->qual,icnt), section_hold->qual[icnt].
      section_id = crs.section_id
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (size(section_hold,5) > 0)
  SET icur_list_size = size(section_hold->qual,5)
  SET iloop_cnt = ceil((cnvtreal(icur_list_size)/ ibatch_size))
  SET inew_list_size = (iloop_cnt * ibatch_size)
  SET stat = alterlist(section_hold->qual,inew_list_size)
  FOR (ifor_idx = (icur_list_size+ 1) TO inew_list_size)
    SET section_hold->qual[ifor_idx].section_id = section_hold->qual[icur_list_size].section_id
  ENDFOR
  SET istart = 1
  SET iexpandidx = 0
  SELECT INTO "nl:"
   FROM cr_report_request_section rrs,
    cr_report_request rr,
    encounter e,
    prsnl p,
    (dummyt d  WITH seq = value(iloop_cnt))
   PLAN (d
    WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
    JOIN (rrs
    WHERE expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),rrs.section_id,section_hold->qual[
     iexpandidx].section_id))
    JOIN (rr
    WHERE rr.report_request_id=rrs.report_request_id
     AND rr.request_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (e
    WHERE e.encntr_id=rr.encntr_id)
    JOIN (p
    WHERE p.person_id=rr.request_prsnl_id)
   ORDER BY e.loc_facility_cd, p.position_cd
   HEAD REPORT
    facilitycnt = 0
   HEAD e.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd, positioncnt = 0
   HEAD p.position_cd
    positioncnt = (positioncnt+ 1), reply->facilities[facilitycnt].position_cnt = positioncnt, stat
     = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
    reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
    facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, reportcnt = 0
   DETAIL
    reportcnt = (reportcnt+ 1)
   FOOT  p.position_cd
    detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,detailcnt),
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply
    ->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
     cnvtstring(reportcnt))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
