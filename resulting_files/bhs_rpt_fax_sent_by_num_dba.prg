CREATE PROGRAM bhs_rpt_fax_sent_by_num:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Number" = "9999"
  WITH outdev, s_start_date, s_end_date,
  adhoc_number
 RECORD faxes(
   1 cntfax = i4
   1 dialed[*]
     2 station = vc
     2 phone_number = vc
     2 report_name = vc
     2 handle_id = f8
     2 transmission_status = vc
     2 faxed_by = vc
     2 date_started = vc
     2 transmitted_date = vc
 )
 DECLARE mf_cs3000_fax = f8 WITH constant(uar_get_code_by("DISPLAYKEY",3000,"FAX")), protect
 DECLARE ms_msg1 = vc WITH protect
 DECLARE ms_searh_string = vc WITH noconstant(concat(trim("*",3),trim( $ADHOC_NUMBER,3),trim("*",3))),
 protect
 SELECT DISTINCT INTO "NL:"
  station = st.description, phone_number = req.adhoc_phone_suffix, report_name = trim(replace(replace
    (req.report_name,char(10),""),char(13),""),3),
  handle_id = req.handle_id, transmission_status = uar_get_code_display(rep.transmission_status_cd),
  faxed_by = p.name_full_formatted
  FROM station st,
   outputctx req,
   report_queue rep,
   person p
  PLAN (rep
   WHERE rep.original_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $S_START_DATE,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),235959))
   JOIN (req
   WHERE req.handle_id=rep.output_handle_id
    AND req.adhoc_phone_suffix > " "
    AND req.adhoc_phone_suffix=patstring(ms_searh_string))
   JOIN (st
   WHERE st.output_dest_cd=req.output_dest_cd)
   JOIN (p
   WHERE p.person_id=req.requesting_user_id)
  ORDER BY st.description, req.handle_id, rep.transmission_status_cd,
   cnvtdatetime(rep.transmit_dt_tm), rep.priority_value, 0
  HEAD REPORT
   stat = alterlist(faxes->dialed,10)
  DETAIL
   faxes->cntfax += 1
   IF (mod(faxes->cntfax,10)=1
    AND (faxes->cntfax > 1))
    stat = alterlist(faxes->dialed,(faxes->cntfax+ 9))
   ENDIF
   faxes->dialed[faxes->cntfax].station = st.description, faxes->dialed[faxes->cntfax].phone_number
    = req.adhoc_phone_suffix, faxes->dialed[faxes->cntfax].report_name = trim(replace(replace(req
      .report_name,char(10),""),char(13),""),3),
   faxes->dialed[faxes->cntfax].handle_id = req.handle_id, faxes->dialed[faxes->cntfax].
   transmission_status = uar_get_code_display(rep.transmission_status_cd), faxes->dialed[faxes->
   cntfax].faxed_by = p.name_full_formatted,
   faxes->dialed[faxes->cntfax].date_started = format(rep.original_dt_tm,"mm/dd/yyyy hh:mm;;Q"),
   faxes->dialed[faxes->cntfax].transmitted_date = format(rep.transmit_dt_tm,"mm/dd/yyyy hh:mm;;Q")
  FOOT REPORT
   stat = alterlist(faxes->dialed,faxes->cntfax)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  station = st.description, phone_number = concat(trim(rd.area_code,3),trim(rd.exchange,3),trim(rd
    .phone_suffix,3)), report_name = trim(replace(replace(req.report_name,char(10),""),char(13),""),3
   ),
  handle_id = req.handle_id, transmission_status = uar_get_code_display(rep.transmission_status_cd),
  faxed_by = p.name_full_formatted
  FROM station st,
   outputctx req,
   report_queue rep,
   person p,
   remote_device rd,
   device d,
   output_dest od
  PLAN (rep
   WHERE rep.original_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $S_START_DATE,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),235959))
   JOIN (req
   WHERE req.handle_id=rep.output_handle_id)
   JOIN (st
   WHERE st.output_dest_cd=req.output_dest_cd)
   JOIN (od
   WHERE od.output_dest_cd=st.output_dest_cd)
   JOIN (rd
   WHERE rd.device_cd=od.device_cd
    AND concat(trim(rd.area_code,3),trim(rd.exchange,3),trim(rd.phone_suffix,3))=patstring(
    ms_searh_string))
   JOIN (d
   WHERE d.device_cd=rd.device_cd
    AND d.device_type_cd=mf_cs3000_fax)
   JOIN (p
   WHERE p.person_id=req.requesting_user_id)
  ORDER BY st.description, req.handle_id, rep.transmission_status_cd,
   cnvtdatetime(rep.transmit_dt_tm), rep.priority_value, 0
  HEAD REPORT
   IF (size(faxes->dialed,5)=0)
    stat = alterlist(faxes->dialed,10)
   ELSE
    stat = alterlist(faxes->dialed,(faxes->cntfax+ 9))
   ENDIF
  DETAIL
   faxes->cntfax += 1
   IF (mod(faxes->cntfax,10)=1
    AND (faxes->cntfax > 1))
    stat = alterlist(faxes->dialed,(faxes->cntfax+ 9))
   ENDIF
   faxes->dialed[faxes->cntfax].station = st.description, faxes->dialed[faxes->cntfax].phone_number
    = concat(trim(rd.area_code,3),trim(rd.exchange,3),trim(rd.phone_suffix,3)), faxes->dialed[faxes->
   cntfax].report_name = trim(replace(replace(req.report_name,char(10),""),char(13),""),3),
   faxes->dialed[faxes->cntfax].handle_id = req.handle_id, faxes->dialed[faxes->cntfax].
   transmission_status = uar_get_code_display(rep.transmission_status_cd), faxes->dialed[faxes->
   cntfax].faxed_by = p.name_full_formatted,
   faxes->dialed[faxes->cntfax].date_started = format(rep.original_dt_tm,"mm/dd/yyyy hh:mm;;Q"),
   faxes->dialed[faxes->cntfax].transmitted_date = format(rep.transmit_dt_tm,"mm/dd/yyyy hh:mm;;Q")
  FOOT REPORT
   stat = alterlist(faxes->dialed,faxes->cntfax)
  WITH nocounter
 ;end select
 IF (size(faxes->dialed,5) > 0)
  SELECT INTO  $OUTDEV
   station = substring(1,30,faxes->dialed[d1.seq].station), phone_number = substring(1,30,faxes->
    dialed[d1.seq].phone_number), report_name = substring(1,200,faxes->dialed[d1.seq].report_name),
   handle_id = faxes->dialed[d1.seq].handle_id, transmission_status = substring(1,30,faxes->dialed[d1
    .seq].transmission_status), faxed_by = substring(1,80,faxes->dialed[d1.seq].faxed_by),
   date_started = substring(1,30,faxes->dialed[d1.seq].date_started), transmitted_date = substring(1,
    30,faxes->dialed[d1.seq].transmitted_date)
   FROM (dummyt d1  WITH seq = size(faxes->dialed,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    ms_msg1 = "No Faxes found with that Number", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
