CREATE PROGRAM cp_get_chart_requests:dba
 RECORD reply(
   1 request_list[*]
     2 chart_request_id = f8
     2 resubmit_count = i4
     2 resubmit_dt_tm = dq8
     2 scope_flag = i2
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = vc
     2 chart_format_id = f8
     2 chart_format_desc = vc
     2 status_cd = f8
     2 status_display = c50
     2 status_cdf = c12
     2 queue_status_cd = f8
     2 queue_status_cdf = c12
     2 queue_status_disp = c40
     2 request_type = i4
     2 distribution_id = f8
     2 distribution_desc = vc
     2 date_range_ind = i2
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 request_prsnl_id = f8
     2 request_prsnl = vc
     2 request_dt_tm = dq8
     2 output_dest = vc
     2 page_count = i4
     2 updt_cnt = i4
     2 pending_flag = i2
     2 provider_id = f8
     2 provider_name = vc
     2 prov_r_cd = f8
     2 prov_r_cd_disp = vc
     2 recover_cnt = i4
     2 recover_dt_tm = dq8
     2 proc_time = f8
     2 server_name = c20
     2 trig_id = f8
     2 trig_type = c15
     2 event_ind = i2
     2 client_name = vc
     2 client_id = f8
     2 facility_id = f8
     2 facility = vc
     2 building = vc
     2 building_id = f8
     2 nurse_unit = vc
     2 nurse_unit_id = f8
     2 room = vc
     2 room_id = f8
     2 bed = vc
     2 bed_id = f8
     2 trigger_name = c100
     2 chart_route_id = f8
     2 route_name = vc
     2 sequence_group_id = f8
     2 group_name = vc
     2 event_list[*]
       3 event_id = f8
     2 mrn_list[*]
       3 mrn = vc
     2 encntr_list[*]
       3 encntr_id = f8
     2 chart_section_list[*]
       3 chart_section_id = f8
       3 chart_section_desc = vc
     2 chart_batch_id = f8
     2 suppress_mrpnodata_ind = i2
     2 order_group_flag = i4
     2 group_order_id = f8
     2 order_list[*]
       3 order_id = f8
     2 result_lookup_ind = i2
     2 trigger_qualifier_id = f8
     2 user_role_profile = vc
     2 non_ce_begin_dt_tm = dq8
     2 non_ce_end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET count1 = 0
 SET date_clause = fillstring(300," ")
 SET request_type_clause = fillstring(300," ")
 SET where_clause = fillstring(2000," ")
 SET filter_clause = fillstring(1300," ")
 SET filter_nbr = 0
 SET begin_dt_tm = "01-jan-1800"
 DECLARE encntr_mrn_cd = f8
 DECLARE prsn_mrn_cd = f8
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,prsn_mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,encntr_mrn_cd)
 SET reply->status_data.status = "F"
 IF ((request->start_dt_tm=0)
  AND (request->end_dt_tm=0))
  SET date_clause = trim(concat("cr.request_dt_tm >= cnvtdatetime(begin_dt_tm)",
    " and cr.request_dt_tm <= cnvtdatetime(curdate+1,0)"))
 ELSEIF ((request->start_dt_tm=0)
  AND (request->end_dt_tm != 0))
  SET date_clause = " cr.request_dt_tm <= cnvtdatetime(request->end_dt_tm)"
 ELSEIF ((request->start_dt_tm != 0)
  AND (request->end_dt_tm=0))
  SET date_clause = trim(concat("cr.request_dt_tm >= cnvtdatetime(request->start_dt_tm)",
    " and cr.request_dt_tm <= cnvtdatetime(curdate+1,0)"))
 ELSEIF ((request->start_dt_tm != 0)
  AND (request->end_dt_tm != 0))
  SET date_clause = trim(concat("cr.request_dt_tm <= cnvtdatetime(request->end_dt_tm)",
    " and cr.request_dt_tm >= cnvtdatetime(request->start_dt_tm)"))
 ENDIF
 SET c1 = fillstring(30," ")
 SET c2 = fillstring(100," ")
 SET c3 = fillstring(100," ")
 SET c4 = fillstring(30," ")
 SET szor = " or "
 IF (btest(request->request_type,0)=1)
  SET c1 = "(cr.request_type = 1)"
 ELSE
  SET c1 = "(0 != 0)"
 ENDIF
 IF (btest(request->request_type,1)=1)
  SET c2 = "(cr.request_type = 2 and (cr.mcis_ind != 1 or cr.mcis_ind = NULL))"
 ELSE
  SET c2 = "(0 != 0)"
 ENDIF
 IF (btest(request->request_type,2)=1)
  SET c3 = "(cr.request_type = 4 or (cr.request_type = 2 and cr.mcis_ind = 1))"
 ELSE
  SET c3 = "(0 != 0)"
 ENDIF
 IF (btest(request->request_type,3)=1)
  SET c4 = "(cr.request_type = 8)"
 ELSE
  SET c4 = "(0 != 0)"
 ENDIF
 SET request_type_clause = concat(" and (",trim(c1),szor,trim(c2),szor,
  trim(c3),szor,trim(c4),")")
 CALL echo(build("request_type_clause: ",request_type_clause))
 SET filter_nbr = size(request->status_filter_list,5)
 CALL echo(build("filter_nbr: ",filter_nbr))
 IF (filter_nbr > 0)
  FOR (num = 1 TO filter_nbr)
    IF (num=1)
     SET filter_clause = build(" and cr.chart_status_cd+0 in (0.0, ",request->status_filter_list[num]
      .status_cd)
    ELSE
     SET filter_clause = build(filter_clause,", ",request->status_filter_list[num].status_cd)
    ENDIF
  ENDFOR
  SET filter_clause = build(filter_clause,")")
 ENDIF
 CALL echo(build("filter_clause: ",filter_clause))
 SET where_clause = concat(trim(date_clause),trim(request_type_clause),trim(filter_clause))
 CALL echo(build("where_clause: ",where_clause))
 SELECT INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr,
   chart_print_queue cpq,
   person p,
   chart_format cf,
   output_dest od,
   prsnl p2,
   chart_distribution d,
   prsnl p1,
   encounter e,
   organization o,
   chart_route crt,
   chart_sequence_group cs
  PLAN (cr
   WHERE parser(where_clause))
   JOIN (cpq
   WHERE cpq.distribution_id=outerjoin(cr.distribution_id)
    AND cpq.request_id=outerjoin(cr.chart_request_id))
   JOIN (p
   WHERE p.person_id=cr.person_id)
   JOIN (cf
   WHERE cf.chart_format_id=cr.chart_format_id)
   JOIN (p2
   WHERE p2.person_id=cr.request_prsnl_id)
   JOIN (d
   WHERE d.distribution_id=cr.distribution_id)
   JOIN (od
   WHERE od.output_dest_cd=outerjoin(cr.output_dest_cd))
   JOIN (p1
   WHERE p1.person_id=outerjoin(cr.prsnl_person_id))
   JOIN (e
   WHERE e.encntr_id=cr.encntr_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
   JOIN (crt
   WHERE crt.chart_route_id=cr.chart_route_id)
   JOIN (cs
   WHERE cs.sequence_group_id=cr.sequence_group_id)
  ORDER BY cr.chart_request_id, cpq.batch_id DESC
  HEAD REPORT
   count = 0
  HEAD cr.chart_request_id
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->request_list,(count+ 9))
   ENDIF
   reply->request_list[count].chart_request_id = cr.chart_request_id, reply->request_list[count].
   resubmit_count = cr.resubmit_cnt, reply->request_list[count].resubmit_dt_tm = cr.resubmit_dt_tm,
   reply->request_list[count].scope_flag = cr.scope_flag, reply->request_list[count].person_id = cr
   .person_id, reply->request_list[count].person_name = p.name_full_formatted,
   reply->request_list[count].encntr_id = cr.encntr_id, reply->request_list[count].order_id = cr
   .order_id, reply->request_list[count].accession_nbr = cr.accession_nbr,
   reply->request_list[count].chart_format_id = cr.chart_format_id, reply->request_list[count].
   chart_format_desc = cf.chart_format_desc, reply->request_list[count].status_cd = cr
   .chart_status_cd,
   reply->request_list[count].status_display = uar_get_code_display(cr.chart_status_cd), reply->
   request_list[count].status_cdf = uar_get_code_meaning(cr.chart_status_cd)
   IF (cpq.request_id > 0)
    reply->request_list[count].queue_status_cd = cpq.queue_status_cd, reply->request_list[count].
    queue_status_cdf = uar_get_code_meaning(cpq.queue_status_cd), reply->request_list[count].
    queue_status_disp = uar_get_code_display(cpq.queue_status_cd)
   ENDIF
   IF (((cr.request_type=2
    AND ((cr.mcis_ind != 1) OR (cr.mcis_ind=null)) ) OR (cr.request_type IN (1, 4, 8))) )
    reply->request_list[count].request_type = cr.request_type
   ELSE
    reply->request_list[count].request_type = 5
   ENDIF
   reply->request_list[count].distribution_id = cr.distribution_id, reply->request_list[count].
   distribution_desc = d.dist_descr, reply->request_list[count].date_range_ind = cr.date_range_ind,
   reply->request_list[count].begin_dt_tm = cr.begin_dt_tm, reply->request_list[count].end_dt_tm = cr
   .end_dt_tm, reply->request_list[count].request_prsnl_id = cr.request_prsnl_id,
   reply->request_list[count].request_prsnl = p2.name_full_formatted, reply->request_list[count].
   request_dt_tm = cr.request_dt_tm, reply->request_list[count].provider_id = cr.prsnl_person_id,
   reply->request_list[count].provider_name = p1.name_full_formatted, reply->request_list[count].
   output_dest = od.name
   IF (trim(reply->request_list[count].output_dest)="")
    IF (cr.trigger_id > 0)
     reply->request_list[count].output_dest = "Defined by Chart Server"
    ELSE
     reply->request_list[count].output_dest = "Output Destination Is Not Valid"
    ENDIF
   ENDIF
   reply->request_list[count].page_count = cr.total_pages, reply->request_list[count].updt_cnt = cr
   .updt_cnt, reply->request_list[count].pending_flag = cr.chart_pending_flag,
   reply->request_list[count].prov_r_cd = cr.prsnl_person_r_cd, reply->request_list[count].
   recover_cnt = cr.recover_cnt, reply->request_list[count].recover_dt_tm = cr.recover_dt_tm,
   reply->request_list[count].proc_time = cr.process_time, reply->request_list[count].server_name =
   cr.server_name, reply->request_list[count].trig_id = cr.trigger_id,
   reply->request_list[count].trig_type = cr.trigger_type, reply->request_list[count].event_ind = cr
   .event_ind, reply->request_list[count].client_name = o.org_name,
   reply->request_list[count].client_id = o.organization_id, reply->request_list[count].facility =
   uar_get_code_description(e.loc_facility_cd), reply->request_list[count].facility_id = e
   .loc_facility_cd,
   reply->request_list[count].building = uar_get_code_description(e.loc_building_cd), reply->
   request_list[count].building_id = e.loc_building_cd, reply->request_list[count].nurse_unit =
   uar_get_code_description(e.loc_nurse_unit_cd),
   reply->request_list[count].nurse_unit_id = e.loc_nurse_unit_cd, reply->request_list[count].room =
   uar_get_code_description(e.loc_room_cd), reply->request_list[count].room_id = e.loc_room_cd,
   reply->request_list[count].bed = uar_get_code_description(e.loc_bed_cd), reply->request_list[count
   ].bed_id = e.loc_bed_cd, reply->request_list[count].trigger_name = cr.trigger_name,
   reply->request_list[count].chart_route_id = cr.chart_route_id, reply->request_list[count].
   route_name = crt.route_name, reply->request_list[count].sequence_group_id = cr.sequence_group_id,
   reply->request_list[count].group_name = cs.group_name, reply->request_list[count].chart_batch_id
    = cr.chart_batch_id, reply->request_list[count].suppress_mrpnodata_ind = cr
   .suppress_mrpnodata_ind,
   reply->request_list[count].order_group_flag = cr.order_group_flag, reply->request_list[count].
   group_order_id = cr.group_order_id, reply->request_list[count].result_lookup_ind = cr
   .result_lookup_ind,
   reply->request_list[count].trigger_qualifier_id = cr.chart_trigger_id, reply->request_list[count].
   user_role_profile = validate(cr.user_role_profile,""), reply->request_list[count].
   non_ce_begin_dt_tm = cr.non_ce_begin_dt_tm,
   reply->request_list[count].non_ce_end_dt_tm = cr.non_ce_end_dt_tm
  FOOT  cr.chart_request_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(reply->request_list,count)
  WITH nocounter
 ;end select
 CALL echo(build("count = ",count))
 IF (count=0)
  GO TO exit_script
 ENDIF
 SET req_nbr = size(reply->request_list,5)
 SELECT INTO "nl:"
  d2.chart_request_id
  FROM chart_request_event cre,
   (dummyt d2  WITH seq = value(req_nbr))
  PLAN (d2
   WHERE (reply->request_list[d2.seq].event_ind=1))
   JOIN (cre
   WHERE (cre.chart_request_id=reply->request_list[d2.seq].chart_request_id))
  HEAD d2.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d2.seq].event_list,(count1+ 9))
   ENDIF
   reply->request_list[d2.seq].event_list[count1].event_id = cre.event_id
  FOOT  d2.seq
   stat = alterlist(reply->request_list[d2.seq].event_list,count1)
  WITH nocounter
 ;end select
 CALL echo(build("count1 = ",count1))
 SELECT INTO "nl:"
  d4.chart_request_id
  FROM person_alias pa,
   (dummyt d4  WITH seq = value(req_nbr))
  PLAN (d4
   WHERE (reply->request_list[d4.seq].scope_flag=1))
   JOIN (pa
   WHERE (pa.person_id=reply->request_list[d4.seq].person_id)
    AND pa.person_alias_type_cd=prsn_mrn_cd)
  HEAD d4.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d4.seq].mrn_list,(count1+ 9))
   ENDIF
   reply->request_list[d4.seq].mrn_list[count1].mrn = pa.alias
  FOOT  d4.seq
   stat = alterlist(reply->request_list[d4.seq].mrn_list,count1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d6.chart_request_id
  FROM encntr_alias ea,
   (dummyt d6  WITH seq = value(req_nbr))
  PLAN (d6
   WHERE (reply->request_list[d6.seq].scope_flag > 1))
   JOIN (ea
   WHERE (ea.encntr_id=reply->request_list[d6.seq].encntr_id)
    AND ea.encntr_alias_type_cd=encntr_mrn_cd)
  HEAD d6.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d6.seq].mrn_list,(count1+ 9))
   ENDIF
   reply->request_list[d6.seq].mrn_list[count1].mrn = ea.alias
  FOOT  d6.seq
   stat = alterlist(reply->request_list[d6.seq].mrn_list,count1)
  WITH nocounter
 ;end select
 SET req_nbr = size(reply->request_list,5)
 SELECT INTO "nl:"
  d8.chart_request_id
  FROM chart_request_encntr cen,
   (dummyt d8  WITH seq = value(req_nbr))
  PLAN (d8
   WHERE (reply->request_list[d8.seq].scope_flag=5))
   JOIN (cen
   WHERE (cen.chart_request_id=reply->request_list[d8.seq].chart_request_id))
  HEAD d8.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d8.seq].encntr_list,(count1+ 9))
   ENDIF
   reply->request_list[d8.seq].encntr_list[count1].encntr_id = cen.encntr_id
  FOOT  d8.seq
   stat = alterlist(reply->request_list[d8.seq].encntr_list,count1)
  WITH nocounter
 ;end select
 CALL echo(build("count1 = ",count1))
 SET req_nbr = size(reply->request_list,5)
 SELECT INTO "nl:"
  d8.chart_request_id
  FROM chart_request_order cro,
   (dummyt d8  WITH seq = value(req_nbr))
  PLAN (d8
   WHERE (reply->request_list[d8.seq].scope_flag=3))
   JOIN (cro
   WHERE (cro.chart_request_id=reply->request_list[d8.seq].chart_request_id))
  HEAD d8.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d8.seq].order_list,(count1+ 9))
   ENDIF
   reply->request_list[d8.seq].order_list[count1].order_id = cro.order_id
  FOOT  d8.seq
   stat = alterlist(reply->request_list[d8.seq].order_list,count1)
  WITH nocounter
 ;end select
 CALL echo(build("count1 = ",count1))
 SELECT INTO "nl:"
  FROM chart_request_section crs,
   (dummyt d10  WITH seq = value(req_nbr)),
   chart_section cs
  PLAN (d10)
   JOIN (crs
   WHERE (crs.chart_request_id=reply->request_list[d10.seq].chart_request_id))
   JOIN (cs
   WHERE cs.chart_section_id=crs.chart_section_id)
  HEAD d10.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->request_list[d10.seq].chart_section_list,(count1+ 9))
   ENDIF
   reply->request_list[d10.seq].chart_section_list[count1].chart_section_id = crs.chart_section_id,
   reply->request_list[d10.seq].chart_section_list[count1].chart_section_desc = cs.chart_section_desc
  FOOT  d10.seq
   stat = alterlist(reply->request_list[d10.seq].chart_section_list,count1)
  WITH nocounter
 ;end select
#exit_script
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
