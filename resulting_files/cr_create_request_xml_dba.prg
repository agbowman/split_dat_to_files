CREATE PROGRAM cr_create_request_xml:dba
 DECLARE nnumofreq = i4 WITH constant(size(report_request->requests,5))
 DECLARE request_xml = vc
 DECLARE escapexmlchars(str=vc) = vc
 SET stat = alterlist(report_reply->requests,nnumofreq)
 FOR (n = 1 TO nnumofreq)
   SELECT INTO "nl:"
    reqid = seq(chart_seq,nextval)
    FROM dual
    DETAIL
     report_reply->requests[n].report_request_id = reqid
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(nnumofreq))
  PLAN (d1)
  DETAIL
   request_xml = concat("<report-request request-id='",trim(cnvtstring(report_reply->requests[d1.seq]
      .report_request_id)),"'"), request_xml = concat(request_xml," request-type='",trim(cnvtstring(
      report_request->requests[d1.seq].request_type_flag)),"'"), request_xml = concat(request_xml,
    " scope='",trim(cnvtstring(report_request->requests[d1.seq].scope_flag)),"'"),
   request_xml = concat(request_xml," template-id='",trim(cnvtstring(report_request->requests[d1.seq]
      .template_id)),"'")
   IF ((report_request->requests[d1.seq].begin_dt_tm != null))
    request_xml = concat(request_xml," begin-dt-tm='",format(cnvtdatetimeutc(report_request->
       requests[d1.seq].begin_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].end_dt_tm != null))
    request_xml = concat(request_xml," end-dt-tm='",format(cnvtdatetimeutc(report_request->requests[
       d1.seq].end_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].result_status_flag > 0))
    request_xml = concat(request_xml," result-status='",trim(cnvtstring(report_request->requests[d1
       .seq].result_status_flag)),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].use_posting_date_flag=0))
    request_xml = concat(request_xml," use-posting-date-ind='false'")
   ELSE
    request_xml = concat(request_xml," use-posting-date-ind='true'")
   ENDIF
   request_xml = concat(request_xml," person-id='",trim(cnvtstring(report_request->requests[d1.seq].
      person_id)),"'")
   IF ((report_request->requests[d1.seq].order_id > 0))
    request_xml = concat(request_xml," order-id='",trim(cnvtstring(report_request->requests[d1.seq].
       order_id)),"'")
   ENDIF
   IF (size(trim(report_request->requests[d1.seq].accession_nbr),1) > 0)
    request_xml = concat(request_xml," accession-nbr='",trim(report_request->requests[d1.seq].
      accession_nbr),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].route_id > 0))
    request_xml = concat(request_xml," route-id='",trim(cnvtstring(report_request->requests[d1.seq].
       route_id)),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].route_stop_id > 0))
    request_xml = concat(request_xml," route-stop-id='",trim(cnvtstring(report_request->requests[d1
       .seq].route_stop_id)),"'")
   ENDIF
   request_xml = concat(request_xml," sequence='",trim(cnvtstring(report_request->requests[d1.seq].
      dist_seq)),"'>"), xencntr_size = size(report_request->requests[d1.seq].xencntr_ids,5)
   IF (xencntr_size > 0)
    FOR (y = 1 TO xencntr_size)
      request_xml = concat(request_xml,"<encounter-id>",trim(cnvtstring(report_request->requests[d1
         .seq].xencntr_ids[y].encntr_id)),"</encounter-id>")
    ENDFOR
   ELSEIF ((report_request->requests[d1.seq].encntr_id > 0))
    request_xml = concat(request_xml,"<encounter-id>",trim(cnvtstring(report_request->requests[d1.seq
       ].encntr_id)),"</encounter-id>")
   ENDIF
   event_size = size(report_request->requests[d1.seq].event_ids,5)
   FOR (y = 1 TO event_size)
     request_xml = concat(request_xml,"<event-id>"), request_xml = concat(request_xml,trim(cnvtstring
       (report_request->requests[d1.seq].event_ids[y].event_id))), request_xml = concat(request_xml,
      "</event-id>")
   ENDFOR
   IF ((report_request->requests[d1.seq].request_prsnl_id > 0))
    request_xml = concat(request_xml,"<requesting-provider"), request_xml = concat(request_xml,
     " prsnl-id='",trim(cnvtstring(report_request->requests[d1.seq].request_prsnl_id)),"'/>")
   ENDIF
   request_xml = concat(request_xml,"<destination-info")
   IF ((report_request->requests[d1.seq].output_dest_cd > 0))
    request_xml = concat(request_xml," output-dest-code='",trim(cnvtstring(report_request->requests[
       d1.seq].output_dest_cd)),"'")
   ENDIF
   request_xml = concat(request_xml,"/>")
   IF ((report_request->requests[d1.seq].provider_prsnl_id > 0))
    request_xml = concat(request_xml,"<receiving-provider"), request_xml = concat(request_xml,
     " prsnl-id='",trim(cnvtstring(report_request->requests[d1.seq].provider_prsnl_id)),"'"),
    request_xml = concat(request_xml," relation-code='",trim(cnvtstring(report_request->requests[d1
       .seq].provider_reltn_cd)),"'/>")
   ENDIF
   request_xml = concat(request_xml,"<origination-info")
   IF ((report_request->requests[d1.seq].distribution_id > 0))
    request_xml = concat(request_xml," distribution-id='",trim(cnvtstring(report_request->requests[d1
       .seq].distribution_id)),"'"), request_xml = concat(request_xml," dist-run-dt-tm='",format(
      cnvtdatetimeutc(report_request->requests[d1.seq].dist_run_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;3;Q"),
     "'"), request_xml = concat(request_xml," dist-run-type-code='",trim(cnvtstring(report_request->
       requests[d1.seq].dist_run_type_cd)),"'"),
    request_xml = concat(request_xml," reader-group='",trim(escapexmlchars(report_request->requests[
       d1.seq].reader_group)),"'")
   ENDIF
   IF (size(trim(report_request->requests[d1.seq].trigger_name),1) > 0)
    request_xml = concat(request_xml," expedite-trigger='",trim(escapexmlchars(report_request->
       requests[d1.seq].trigger_name)),"'")
   ENDIF
   IF ((report_request->requests[d1.seq].eso_trigger_id > 0))
    request_xml = concat(request_xml," eso-trigger-id='",trim(cnvtstring(report_request->requests[d1
       .seq].eso_trigger_id)),"'"), request_xml = concat(request_xml," eso-trigger-type='",trim(
      escapexmlchars(report_request->requests[d1.seq].eso_trigger_type)),"'")
   ENDIF
   request_xml = concat(request_xml,"/>"), request_xml = concat(request_xml,"</report-request>"),
   report_reply->requests[d1.seq].request_xml = request_xml,
   request_xml = ""
  WITH nocounter
 ;end select
 SUBROUTINE escapexmlchars(str)
   DECLARE sencodedstr = vc
   SET sencodedstr = replace(str,"&","&amp;",0)
   SET sencodedstr = replace(sencodedstr,"<","&lt;",0)
   SET sencodedstr = replace(sencodedstr,">","&gt;",0)
   SET sencodedstr = replace(sencodedstr,char(34),"&quot;",0)
   SET sencodedstr = replace(sencodedstr,char(39),"&apos;",0)
   RETURN(sencodedstr)
 END ;Subroutine
END GO
