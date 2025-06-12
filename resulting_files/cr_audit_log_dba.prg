CREATE PROGRAM cr_audit_log:dba
 PAINT
 SET width = 132
 SET modify = system
#initialize
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE begindate = c11
 DECLARE begindatetime = c17
 DECLARE enddate = c11
 DECLARE enddatetime = c17
 DECLARE plan_clause = vc
 DECLARE loginname = vc
 DECLARE prsnl_type_cd = f8
 DECLARE tempstr = vc
 DECLARE tempstr2 = vc
 DECLARE tempval = i4
 DECLARE tempval2 = f8
 DECLARE prsn_mrn_cd = f8
 DECLARE encntr_mrn_cd = f8
 DECLARE encntr_fin_cd = f8
 DECLARE chart_status_cd = f8
 DECLARE spooled_status_cd = f8
 DECLARE queued_status_cd = f8
 DECLARE mrn = vc
 DECLARE fin = vc
 DECLARE sec = vc
 DECLARE currentdate = c8
 DECLARE currenttime = c5
 DECLARE req_nbr = i4
 DECLARE h = i4
 DECLARE name_last = vc
 DECLARE name_first = vc
 DECLARE mrn_accept = vc
 DECLARE original_select = i2
 DECLARE person_id = f8
 DECLARE date_range = i4 WITH constant(1)
 DECLARE pt_search = i4 WITH constant(2)
 DECLARE quit = i4 WITH constant(99)
 DECLARE login_start = i2 WITH constant(54)
 DECLARE pt_start = i2 WITH constant(26)
 DECLARE dest_start = i2 WITH constant(53)
 DECLARE req_id = i2 WITH constant(14)
 DECLARE pt_name = i2 WITH constant(35)
 DECLARE mrn_st = i2 WITH constant(32)
 DECLARE fin_st = i2 WITH constant(32)
 DECLARE req_name = i2 WITH constant(36)
 DECLARE req_usr = i2 WITH constant(39)
 DECLARE pt_const = i2 WITH constant(43)
 DECLARE resub = i2 WITH constant(39)
 DECLARE com = i2 WITH constant(36)
 DECLARE dest = i2 WITH constant(59)
 DECLARE otp_dev = i2 WITH constant(65)
 DECLARE reason = i2 WITH constant(61)
 DECLARE req_dt_tm = i2 WITH constant(64)
 DECLARE sect = i2 WITH constant(63)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,prsnl_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,prsn_mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,encntr_mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,encntr_fin_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"SUCCESSFUL",1,chart_status_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"SPOOLED",1,spooled_status_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"QUEUED",1,queued_status_cd)
 CALL clear(1,1)
 CALL box(2,1,10,79)
 CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Audit Log"))
 CALL text(3,2,uar_i18ngetmessage(i18nhandle,"MAINHEAD1",
   "The Chart Request Audit Log is no longer available."))
 CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINHEAD2",
   "Please launch the DisclosureAuditLog from winintel."))
 CALL accept(4,60,"99;",99
  WHERE curaccept IN (quit))
 GO TO end_program
#get_password_info
 SELECT INTO "nl:"
  p.username, p.person_id
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.username=curuser)
   JOIN (pn
   WHERE pn.person_id=outerjoin(p.person_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd))
  DETAIL
   IF (trim(pn.name_full) != "")
    loginname = pn.name_full
   ELSE
    loginname = p.name_full_formatted
   ENDIF
  WITH maxqual(p,1)
 ;end select
#start_initial_accepts
 CALL clear(1,1)
 CALL box(2,1,10,79)
 CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Audit Log"))
 CALL text(4,2,uar_i18nbuildmessage(i18nhandle,"MAINBEGDT","0%1 Query by date range.","i",date_range
   ))
 CALL text(5,2,uar_i18nbuildmessage(i18nhandle,"MAINBEGDT","0%1 Query by patient.","i",pt_search))
 CALL text(7,2,uar_i18nbuildmessage(i18nhandle,"MAINCONQT","%1 Exit.","i",quit))
 CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT","Select Option?"))
 CALL accept(9,24,"99;",99
  WHERE curaccept IN (date_range, pt_search, quit))
 CASE (curaccept)
  OF date_range:
   SET original_select = 1
   GO TO start_date_range_accepts
  OF pt_search:
   SET original_select = 2
   GO TO start_pt_search_accepts
  OF quit:
   GO TO end_program
 ENDCASE
#end_initial_accepts
#start_pt_search_accepts
 CALL clear(1,1)
 CALL box(2,1,12,90)
 CALL text(1,30,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Audit Log"))
 CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the last name: "))
 CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINBEGTM","Enter the first name: "))
 CALL text(8,2,uar_i18ngetmessage(i18nhandle,"MAINENDDT","Enter the MRN: "))
 CALL text(11,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT","Main Menu(0), Continue(1) or Quit(2)? "))
 CALL accept(5,2,"P(80);C")
 SET name_last = cnvtupper(curaccept)
 CALL accept(7,2,"P(80);C")
 SET name_first = cnvtupper(curaccept)
 CALL accept(9,2,"P(80);C")
 SET mrn_accept = curaccept
 CALL accept(11,40,"9;",1
  WHERE curaccept IN (0, 1, 2))
 IF (curaccept=2)
  GO TO end_program
 ELSEIF (curaccept=1)
  GO TO start_data_retrieval
 ELSE
  GO TO start_initial_accepts
 ENDIF
#end_pt_search_accepts
#start_date_range_accepts
 CALL clear(1,1)
 CALL box(2,1,10,79)
 CALL text(1,25,uar_i18ngetmessage(i18nhandle,"MAINHEAD","Clinical Reporting Audit Log"))
 CALL text(4,2,uar_i18ngetmessage(i18nhandle,"MAINBEGDT","Enter the begin date: "))
 CALL text(5,2,uar_i18ngetmessage(i18nhandle,"MAINBEGTM","Enter the begin time: "))
 CALL text(6,2,uar_i18ngetmessage(i18nhandle,"MAINENDDT","Enter the end date: "))
 CALL text(7,2,uar_i18ngetmessage(i18nhandle,"MAINENDTM","Enter the end time: "))
 CALL text(9,2,uar_i18ngetmessage(i18nhandle,"MAINCONQT2","Main Menu(0), Continue(1) or Quit(2)? "))
 CALL accept(4,48,"nndaaadnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET begindate = curaccept
 CALL accept(5,48,"hh:mm;cs","00:00")
 SET begindatetime = concat(trim(begindate)," ",trim(curaccept))
 CALL accept(6,48,"nndaaadnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET enddate = curaccept
 CALL accept(7,48,"hh:mm;cs",format(cnvtdatetime(curdate,curtime),"hh:mm;;m"))
 SET enddatetime = concat(trim(enddate)," ",trim(curaccept))
 CALL accept(9,40,"9;",1
  WHERE curaccept IN (0, 1, 2))
 IF (curaccept=2)
  GO TO end_program
 ELSEIF (curaccept=1)
  GO TO start_data_retrieval
 ELSE
  GO TO start_initial_accepts
 ENDIF
#end_date_range_accepts
#start_data_retrieval
 FREE RECORD report_writer
 RECORD report_writer(
   1 qual[*]
     2 req_id = f8
     2 req_type = c12
     2 pt_name = vc
     2 mrn_list[*]
       3 mrn = vc
     2 fin_list[*]
       3 fin = vc
     2 req_name = vc
     2 cr_req_name = vc
     2 req_userid = vc
     2 cr_userid = vc
     2 patient_consent = c1
     2 resubmitted = c1
     2 comments = vc
     2 dest = vc
     2 output_dev = vc
     2 reason = vc
     2 req_dt_tm = c14
     2 sections[*]
       3 section = vc
     2 scope_flag = i2
     2 person_id = f8
     2 encntr_id = f8
     2 req_name_pe = vc
     2 req_id_pe = f8
     2 dest_name_pe = vc
     2 dest_id_pe = f8
 )
 FREE RECORD row_cnt
 RECORD row_cnt(
   1 qual[*]
     2 row_nbr = i4
     2 row_nbr_pat = i4
     2 row_nbr_dest = i4
 )
 SET currentdate = format(curdate,"@SHORTDATE")
 SET currenttime = format(curtime3,"@TIMENOSECONDS")
 IF (original_select=1)
  SET plan_clause =
  "(cr.updt_dt_tm between cnvtdatetime(BeginDateTime) and cnvtdatetime(EndDateTime))"
  SET plan_clause = concat(plan_clause,
   " or (cr.request_dt_tm between cnvtdatetime(BeginDateTime) and cnvtdatetime(EndDateTime))")
 ELSEIF (original_select=2)
  SELECT INTO "nl:"
   FROM person p,
    person_alias pa
   PLAN (p
    WHERE p.name_last_key=name_last
     AND p.name_first_key=name_first)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.alias=mrn_accept
     AND pa.person_alias_type_cd=prsn_mrn_cd)
   DETAIL
    person_id = pa.person_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET plan_clause = "cr.person_id = Person_Id"
  ELSE
   SET plan_clause = "0 = 1"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM chart_request cr,
   person p,
   chart_request_audit cra,
   output_dest od,
   person_name pn,
   prsnl pr,
   chart_print_queue cpq
  PLAN (cr
   WHERE parser(plan_clause)
    AND cr.chart_status_cd IN (chart_status_cd, queued_status_cd))
   JOIN (cpq
   WHERE cpq.distribution_id=outerjoin(cr.distribution_id)
    AND cpq.request_id=outerjoin(cr.chart_request_id)
    AND cpq.queue_status_cd=outerjoin(spooled_status_cd))
   JOIN (p
   WHERE p.person_id=cr.person_id)
   JOIN (cra
   WHERE cra.chart_request_id=outerjoin(cr.chart_request_id))
   JOIN (od
   WHERE od.output_dest_cd=outerjoin(cr.output_dest_cd))
   JOIN (pn
   WHERE pn.person_id=outerjoin(cr.request_prsnl_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd)
    AND pn.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr
   WHERE pr.person_id=outerjoin(cr.request_prsnl_id)
    AND pr.active_ind=outerjoin(1))
  ORDER BY cr.chart_request_id, cpq.batch_id DESC
  HEAD REPORT
   result_cnt = 0
  HEAD cr.chart_request_id
   IF (((cr.chart_status_cd=chart_status_cd) OR (cr.chart_status_cd=queued_status_cd
    AND cpq.queue_status_cd=spooled_status_cd)) )
    result_cnt = (result_cnt+ 1)
    IF (mod(result_cnt,50)=1)
     stat = alterlist(report_writer->qual,(result_cnt+ 49))
    ENDIF
    report_writer->qual[result_cnt].req_id = cr.chart_request_id
    CASE (cr.request_type)
     OF 1:
      report_writer->qual[result_cnt].req_type = uar_i18ngetmessage(i18nhandle,"RPTPADHOC","ADHOC")
     OF 2:
      report_writer->qual[result_cnt].req_type = uar_i18ngetmessage(i18nhandle,"RPTPEXP","EXPEDITE")
     OF 4:
      report_writer->qual[result_cnt].req_type = uar_i18ngetmessage(i18nhandle,"RPTPDIST",
       "DISTRIBUTION")
     OF 8:
      report_writer->qual[result_cnt].req_type = uar_i18ngetmessage(i18nhandle,"RPTPMRP","MRP")
    ENDCASE
    report_writer->qual[result_cnt].pt_name = p.name_full_formatted
    IF (cra.patconobt_ind=0)
     report_writer->qual[result_cnt].patient_consent = "N"
    ELSE
     report_writer->qual[result_cnt].patient_consent = "Y"
    ENDIF
    IF (cr.resubmit_cnt=0)
     report_writer->qual[result_cnt].resubmitted = "N"
    ELSE
     report_writer->qual[result_cnt].resubmitted = "Y"
    ENDIF
    IF (trim(pn.name_full) != "")
     report_writer->qual[result_cnt].cr_req_name = pn.name_full
    ELSE
     report_writer->qual[result_cnt].cr_req_name = pr.name_full_formatted
    ENDIF
    report_writer->qual[result_cnt].cr_userid = pr.username, report_writer->qual[result_cnt].comments
     = cra.comments, report_writer->qual[result_cnt].output_dev = od.name,
    report_writer->qual[result_cnt].reason = uar_get_code_description(cra.reason_cd), report_writer->
    qual[result_cnt].req_dt_tm = format(cr.request_dt_tm,"@SHORTDATETIMENOSEC"), report_writer->qual[
    result_cnt].scope_flag = cr.scope_flag,
    report_writer->qual[result_cnt].person_id = cr.person_id, report_writer->qual[result_cnt].
    encntr_id = cr.encntr_id, report_writer->qual[result_cnt].req_name_pe = cra.requestor_pe_name,
    report_writer->qual[result_cnt].dest_name_pe = cra.dest_pe_name, report_writer->qual[result_cnt].
    req_id_pe = cra.requestor_pe_id, report_writer->qual[result_cnt].dest_id_pe = cra.dest_pe_id
    IF (trim(cra.requestor_pe_name)="FREETEXT")
     report_writer->qual[result_cnt].req_name = cra.requestor_txt
    ELSEIF (trim(cra.requestor_pe_name)="CODE_VALUE")
     report_writer->qual[result_cnt].req_name = uar_get_code_description(cra.requestor_pe_id)
    ENDIF
    IF (trim(cra.dest_pe_name)="FREETEXT")
     report_writer->qual[result_cnt].dest = cra.dest_txt
    ELSEIF (trim(cra.dest_pe_name)="CODE_VALUE")
     report_writer->qual[result_cnt].dest = uar_get_code_description(cra.dest_pe_id)
    ENDIF
   ENDIF
  FOOT  cr.chart_request_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(report_writer->qual,result_cnt)
  WITH nocounter
 ;end select
 SET req_nbr = size(report_writer->qual,5)
 SELECT INTO "nl:"
  FROM chart_request_section crs,
   chart_section cs,
   (dummyt d1  WITH seq = value(req_nbr))
  PLAN (d1)
   JOIN (crs
   WHERE (crs.chart_request_id=report_writer->qual[d1.seq].req_id))
   JOIN (cs
   WHERE cs.chart_section_id=crs.chart_section_id)
  ORDER BY d1.seq
  HEAD d1.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(report_writer->qual[d1.seq].sections,(count1+ 9))
   ENDIF
   report_writer->qual[d1.seq].sections[count1].section = cs.chart_section_desc
  FOOT  d1.seq
   stat = alterlist(report_writer->qual[d1.seq].sections,count1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa,
   (dummyt d2  WITH seq = value(req_nbr))
  PLAN (d2
   WHERE (report_writer->qual[d2.seq].scope_flag=1))
   JOIN (pa
   WHERE (pa.person_id=report_writer->qual[d2.seq].person_id)
    AND pa.person_alias_type_cd=prsn_mrn_cd)
  ORDER BY d2.seq
  HEAD d2.seq
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(report_writer->qual[d2.seq].mrn_list,(count1+ 9))
   ENDIF
   report_writer->qual[d2.seq].mrn_list[count1].mrn = pa.alias
  FOOT  d2.seq
   stat = alterlist(report_writer->qual[d2.seq].mrn_list,count1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   (dummyt d3  WITH seq = value(req_nbr))
  PLAN (d3
   WHERE (report_writer->qual[d3.seq].scope_flag > 1))
   JOIN (ea
   WHERE (ea.encntr_id=report_writer->qual[d3.seq].encntr_id)
    AND ea.encntr_alias_type_cd IN (encntr_mrn_cd, encntr_fin_cd))
  ORDER BY d3.seq
  HEAD d3.seq
   count1 = 0, count2 = 0, stat = alterlist(report_writer->qual[d3.seq].mrn_list,10),
   stat = alterlist(report_writer->qual[d3.seq].fin_list,10)
  DETAIL
   IF (ea.encntr_alias_type_cd=encntr_mrn_cd)
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(report_writer->qual[d3.seq].mrn_list,(count1+ 9))
    ENDIF
    report_writer->qual[d3.seq].mrn_list[count1].mrn = ea.alias
   ELSE
    count2 = (count2+ 1)
    IF (mod(count2,10)=1
     AND count2 != 1)
     stat = alterlist(report_writer->qual[d3.seq].fin_list,(count2+ 9))
    ENDIF
    report_writer->qual[d3.seq].fin_list[count2].fin = ea.alias
   ENDIF
  FOOT  d3.seq
   stat = alterlist(report_writer->qual[d3.seq].mrn_list,count1), stat = alterlist(report_writer->
    qual[d3.seq].fin_list,count2)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM organization o,
   (dummyt d5  WITH seq = value(req_nbr))
  PLAN (d5
   WHERE (((report_writer->qual[d5.seq].req_name_pe="ORGANIZATION")) OR ((report_writer->qual[d5.seq]
   .dest_name_pe="ORGANIZATION"))) )
   JOIN (o
   WHERE o.organization_id IN (report_writer->qual[d5.seq].req_id_pe, report_writer->qual[d5.seq].
   dest_id_pe))
  DETAIL
   IF ((report_writer->qual[d5.seq].req_id_pe=report_writer->qual[d5.seq].dest_id_pe))
    report_writer->qual[d5.seq].req_name = o.org_name, report_writer->qual[d5.seq].dest = o.org_name
   ELSEIF ((report_writer->qual[d5.seq].req_name_pe="ORGANIZATION")
    AND (report_writer->qual[d5.seq].dest_name_pe="ORGANIZATION"))
    IF ((report_writer->qual[d5.seq].req_id_pe=o.organization_id))
     report_writer->qual[d5.seq].req_name = o.org_name
    ENDIF
    IF ((report_writer->qual[d5.seq].dest_id_pe=o.organization_id))
     report_writer->qual[d5.seq].dest = o.org_name
    ENDIF
   ELSEIF ((o.organization_id=report_writer->qual[d5.seq].req_id_pe)
    AND (report_writer->qual[d5.seq].req_name_pe="ORGANIZATION"))
    report_writer->qual[d5.seq].req_name = o.org_name
   ELSEIF ((o.organization_id=report_writer->qual[d5.seq].dest_id_pe)
    AND (report_writer->qual[d5.seq].dest_name_pe="ORGANIZATION"))
    report_writer->qual[d5.seq].dest = o.org_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_name pn,
   prsnl pr,
   person p,
   (dummyt d6  WITH seq = value(req_nbr))
  PLAN (d6
   WHERE (report_writer->qual[d6.seq].req_name_pe="PERSON"))
   JOIN (p
   WHERE (p.person_id=report_writer->qual[d6.seq].req_id_pe))
   JOIN (pr
   WHERE pr.person_id=outerjoin(p.person_id)
    AND pr.active_ind=outerjoin(1))
   JOIN (pn
   WHERE pn.person_id=outerjoin(p.person_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd)
    AND pn.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  DETAIL
   IF (trim(pn.name_full) != "")
    report_writer->qual[d6.seq].req_name = pn.name_full
   ELSEIF (trim(pr.name_full_formatted) != "")
    report_writer->qual[d6.seq].req_name = pr.name_full_formatted
   ELSE
    report_writer->qual[d6.seq].req_name = p.name_full_formatted
   ENDIF
   report_writer->qual[d6.seq].req_userid = pr.username
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_name pn,
   prsnl pr,
   person p,
   (dummyt d7  WITH seq = value(req_nbr))
  PLAN (d7
   WHERE (report_writer->qual[d7.seq].dest_name_pe="PERSON"))
   JOIN (p
   WHERE (p.person_id=report_writer->qual[d7.seq].dest_id_pe))
   JOIN (pr
   WHERE pr.person_id=outerjoin(p.person_id)
    AND pr.active_ind=outerjoin(1))
   JOIN (pn
   WHERE pn.person_id=outerjoin(p.person_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd)
    AND pn.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  DETAIL
   IF (trim(pn.name_full) != "")
    report_writer->qual[d7.seq].dest = pn.name_full
   ELSEIF (trim(pr.name_full_formatted) != "")
    report_writer->qual[d7.seq].dest = pr.name_full_formatted
   ELSEIF (trim(p.name_full_formatted) != "")
    report_writer->qual[d7.seq].dest = p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  FROM (dummyt d9  WITH seq = value(req_nbr))
  HEAD REPORT
   row_nbr_cnt = 0, line_s = fillstring(79,"-"), row + 1,
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTHEAD","Clinical Reporting Audit Log"), col 27, tempstr,
   row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINT","Printed: "), col 0,
   tempstr, col 9, currentdate,
   col 18, currenttime, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINTBY","Printed by: "),
   col 42, tempstr, tempval = size(trim(loginname),1)
   IF (tempval <= 25)
    col login_start, loginname
   ELSE
    tempstr = substring(1,22,loginname), tempstr = concat(tempstr,"..."), col login_start,
    tempstr
   ENDIF
   row + 1, line_s, row + 1,
   line_s, row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQTYPE","REQ TYPE"),
   col 0, tempstr, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQID","REQ ID"),
   col req_id, tempstr, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPTINFO","PATIENT/EMR INFORMATION"
    ),
   col pt_start, tempstr, tempstr = uar_i18ngetmessage(i18nhandle,"RPTDESTINFO",
    "DESTINATION INFORMATION"),
   col dest_start, tempstr, row + 2
  DETAIL
   mrn = "", fin = "", sec = "",
   row_nbr_cnt = (row_nbr_cnt+ 1)
   IF (mod(row_nbr_cnt,10)=1)
    stat = alterlist(row_cnt->qual,(row_nbr_cnt+ 9))
   ENDIF
   IF (row_nbr_cnt > 1)
    IF ((row_cnt->qual[(row_nbr_cnt - 1)].row_nbr_pat > row_cnt->qual[(row_nbr_cnt - 1)].row_nbr_dest
    ))
     row row_cnt->qual[(row_nbr_cnt - 1)].row_nbr_pat, row + 1, row_cnt->qual[row_nbr_cnt].row_nbr =
     row
    ELSE
     row row_cnt->qual[(row_nbr_cnt - 1)].row_nbr_dest, row + 1, row_cnt->qual[row_nbr_cnt].row_nbr
      = row
    ENDIF
   ELSE
    row_cnt->qual[row_nbr_cnt].row_nbr = row
   ENDIF
   tempval = size(trim(report_writer->qual[d9.seq].req_type),1)
   IF (tempval > 0)
    col 0, report_writer->qual[d9.seq].req_type, col req_id,
    report_writer->qual[d9.seq].req_id";L"
   ENDIF
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTPTNAME","Pt Name:"), col pt_start, tempstr,
   tempval = size(trim(report_writer->qual[d9.seq].pt_name),1), tempstr = trim(report_writer->qual[d9
    .seq].pt_name)
   IF (tempval > 16)
    tempstr2 = substring(1,16,tempstr), col pt_name, tempstr2,
    x = 17
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col pt_name, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTMRN","MRN#:"), col pt_start,
   tempstr, mrn_list = size(report_writer->qual[d9.seq].mrn_list,5)
   FOR (x = 1 TO mrn_list)
     IF (x=1)
      mrn = report_writer->qual[d9.seq].mrn_list[x].mrn
     ELSE
      mrn = concat(mrn,", ",report_writer->qual[d9.seq].mrn_list[x].mrn)
     ENDIF
   ENDFOR
   tempval = size(trim(mrn),1), tempstr = trim(mrn)
   IF (tempval > 19)
    tempstr2 = substring(1,19,tempstr), col mrn_st, tempstr2,
    x = 20
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col mrn_st, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTFIN","FIN#:"), col pt_start,
   tempstr, fin_list = size(report_writer->qual[d9.seq].fin_list,5)
   FOR (x = 1 TO fin_list)
     IF (x=1)
      fin = report_writer->qual[d9.seq].fin_list[x].fin
     ELSE
      fin = concat(fin,", ",report_writer->qual[d9.seq].fin_list[x].fin)
     ENDIF
   ENDFOR
   tempval = size(trim(fin),1), tempstr = trim(fin)
   IF (tempval > 19)
    tempstr2 = substring(1,19,tempstr), col fin_st, tempstr2,
    x = 20
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col fin_st, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQNM","Req Name:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].req_name),1)
   IF (tempval > 0)
    tempstr = trim(report_writer->qual[d9.seq].req_name)
   ELSE
    tempval = size(trim(report_writer->qual[d9.seq].cr_req_name),1), tempstr = trim(report_writer->
     qual[d9.seq].cr_req_name)
   ENDIF
   IF (tempval > 15)
    tempstr2 = substring(1,15,tempstr), col req_name, tempstr2,
    x = 16
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col req_name, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQUSR","Req User Id:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].req_userid),1)
   IF (((tempval > 0) OR (size(trim(report_writer->qual[d9.seq].req_name),1) > 0)) )
    tempstr = trim(report_writer->qual[d9.seq].req_userid)
   ELSE
    tempval = size(trim(report_writer->qual[d9.seq].cr_userid),1), tempstr = trim(report_writer->
     qual[d9.seq].cr_userid)
   ENDIF
   IF (tempval > 12)
    tempstr2 = substring(1,12,tempstr), col req_usr, tempstr2,
    x = 13
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col req_usr, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPTCON","Patient Consent:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].patient_consent),1)
   IF (tempval > 0)
    col pt_const, report_writer->qual[d9.seq].patient_consent
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTRSB","Resubmitted:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].resubmitted),1)
   IF (tempval > 0)
    col resub, report_writer->qual[d9.seq].resubmitted
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTCOM","Comments:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].comments),1), tempstr = trim(
    report_writer->qual[d9.seq].comments)
   IF (tempval > 15)
    tempstr2 = substring(1,15,tempstr), col com, tempstr2,
    x = 16
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col pt_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col pt_start,
    tempstr2
   ELSE
    col com, tempstr
   ENDIF
   row_cnt->qual[row_nbr_cnt].row_nbr_pat = row, row row_cnt->qual[row_nbr_cnt].row_nbr, tempstr =
   uar_i18ngetmessage(i18nhandle,"RPTDEST","Dest:"),
   col dest_start, tempstr, tempval = size(trim(report_writer->qual[d9.seq].dest),1),
   tempstr = trim(report_writer->qual[d9.seq].dest)
   IF (tempval > 19)
    tempstr2 = substring(1,19,tempstr), col dest, tempstr2,
    x = 20
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col dest_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col dest, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTOTPDEV","Output Dev:"), col dest_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].output_dev),1), tempstr = trim(
    report_writer->qual[d9.seq].output_dev)
   IF (tempval > 13)
    tempstr2 = substring(1,13,tempstr), col otp_dev, tempstr2,
    x = 14
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col dest_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col otp_dev, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTRSN","Reason:"), col dest_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].reason),1), tempstr = trim(report_writer
    ->qual[d9.seq].reason)
   IF (tempval > 17)
    tempstr2 = substring(1,17,tempstr), col reason, tempstr2,
    x = 18
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col dest_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col reason, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQDTTM","Req Dt/Tm:"), col dest_start,
   tempstr, tempstr = trim(report_writer->qual[d9.seq].req_dt_tm), col req_dt_tm,
   tempstr, row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTSEC","Sections:"),
   col dest_start, tempstr, sec_list = size(report_writer->qual[d9.seq].sections,5)
   FOR (x = 1 TO sec_list)
     IF (x=1)
      sec = report_writer->qual[d9.seq].sections[x].section
     ELSE
      sec = concat(sec,", ",report_writer->qual[d9.seq].sections[x].section)
     ENDIF
   ENDFOR
   tempval = size(trim(sec),1), tempstr = trim(sec)
   IF (tempval > 15)
    tempstr2 = substring(1,15,tempstr), col sect, tempstr2,
    x = 16
    WHILE (x <= tempval)
      IF (((x+ 25) > tempval))
       x = (x+ 25)
      ELSE
       tempstr2 = substring(x,25,tempstr), row + 1, col dest_start,
       tempstr2, x = (x+ 25)
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 25),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col sect, tempstr
   ENDIF
   row_cnt->qual[row_nbr_cnt].row_nbr_dest = row
  FOOT REPORT
   stat = alterlist(row_cnt->qual,row_nbr_cnt)
  WITH nocounter, maxcol = 80, maxrow = 209000
 ;end select
 CALL text(5,4,uar_i18ngetmessage(i18nhandle,"ENDCONQ","Main Menu(0), Continue(1) or Quit(2)?"))
 CALL accept(5,42,"9;",1
  WHERE curaccept IN (0, 1, 2))
 IF (curaccept=2)
  GO TO end_program
 ELSEIF (curaccept=0)
  GO TO start_initial_accepts
 ELSEIF (original_select=1)
  GO TO start_date_range_accepts
 ELSEIF (original_select=2)
  GO TO start_pt_search_accepts
 ENDIF
#end_data_retrieval
#end_program
 FOR (x = 1 TO 12)
   CALL clear(x,1,132)
 ENDFOR
END GO
