CREATE PROGRAM cp_get_disclosure_log:dba
 RECORD reply(
   1 file_name = vc
   1 qual[*]
     2 line = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD report_writer
 RECORD report_writer(
   1 qual[*]
     2 req_id = f8
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
     2 resubmited = c1
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
     2 resubmit_cnt = i4
     2 display_ind = i2
     2 resub_dt_tm = c14
     2 loc_req_org = vc
     2 loc_dest_org = vc
 )
 FREE SET temp_request
 RECORD temp_request(
   1 qual[*]
     2 person_id = f8
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 person_id = f8
     2 name_full = vc
     2 name_first = vc
     2 name_last = vc
     2 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CP_GET_DISCLOSURE_LOG"
#initialize
 CALL log_message("Begin script: cp_get_disclosure_log",log_level_debug)
 SET reply->status_data.status = "F"
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
 DECLARE outfile = vc
 DECLARE date = vc
 DECLARE sect_msg = vc
 SET date = format(cnvtdatetime(sysdate),"MMDDHHMMSS;;D")
 SET outfile = concat("ccluserdir:Dlog",date,".log")
 SET reply->file_name = outfile
 DECLARE login_start = i2 WITH constant(92)
 DECLARE pt_start = i2 WITH constant(4)
 DECLARE dest_start = i2 WITH constant(83)
 DECLARE req_id = i2 WITH constant(19)
 DECLARE pt_name = i2 WITH constant(35)
 DECLARE mrn_st = i2 WITH constant(13)
 DECLARE fin_st = i2 WITH constant(13)
 DECLARE req_name = i2 WITH constant(72)
 DECLARE req_usr = i2 WITH constant(9)
 DECLARE pt_const = i2 WITH constant(71)
 DECLARE resub = i2 WITH constant(39)
 DECLARE com = i2 WITH constant(11)
 DECLARE dest = i2 WITH constant(70)
 DECLARE otp_dev = i2 WITH constant(6)
 DECLARE reason = i2 WITH constant(75)
 DECLARE req_dt_tm = i2 WITH constant(67)
 DECLARE sect = i2 WITH constant(25)
 DECLARE res_dt_tm = i2 WITH constant(72)
 DECLARE left_max = i2 WITH constant(46)
 DECLARE left_inc = i2 WITH constant(47)
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,prsnl_type_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,prsn_mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,encntr_mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,encntr_fin_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"SUCCESSFUL",1,chart_status_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"SPOOLED",1,spooled_status_cd)
 SET stat = uar_get_meaning_by_codeset(18609,"QUEUED",1,queued_status_cd)
 SET sect_msg = uar_i18ngetmessage(i18nhandle,"RPTHEAD","Printed section data was not captured!")
 FREE RECORD row_cnt
 RECORD row_cnt(
   1 qual[*]
     2 row_nbr = i4
     2 row_nbr_pat = i4
     2 row_nbr_dest = i4
 )
 SET currentdate = format(curdate,"@SHORTDATE")
 SET currenttime = format(curtime3,"@TIMENOSECONDS")
 DECLARE num = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE replyindex = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  p.username, p.person_id
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE (p.username=request->username))
   JOIN (pn
   WHERE (pn.person_id= Outerjoin(p.person_id))
    AND (pn.active_ind= Outerjoin(1))
    AND (pn.name_type_cd= Outerjoin(prsnl_type_cd)) )
  DETAIL
   IF (trim(p.name_full_formatted) != "")
    loginname = p.name_full_formatted
   ELSE
    loginname = pn.name_full
   ENDIF
  WITH maxqual(p,1)
 ;end select
 IF ((request->begin_dt_tm > 0)
  AND (request->person_id > 0))
  SET plan_clause =
  "((cr.updt_dt_tm between cnvtdatetime(request->begin_dt_tm) and cnvtdatetime(request->end_dt_tm))"
  SET plan_clause = concat(plan_clause,
   " or (cr.request_dt_tm between cnvtdatetime(request->begin_dt_tm)")
  SET plan_clause = concat(plan_clause," and cnvtdatetime(request->end_dt_tm)))")
  SET plan_clause = concat(plan_clause," and cr.person_id = request->person_id")
 ELSEIF ((request->begin_dt_tm > 0))
  SET plan_clause =
  "(cr.updt_dt_tm between cnvtdatetime(request->begin_dt_tm) and cnvtdatetime(request->end_dt_tm))"
  SET plan_clause = concat(plan_clause,
   " or (cr.request_dt_tm between cnvtdatetime(request->begin_dt_tm)")
  SET plan_clause = concat(plan_clause," and cnvtdatetime(request->end_dt_tm))")
 ELSE
  SET plan_clause = " cr.person_id = request->person_id"
 ENDIF
 CALL echo(build("plan Statment:  ",plan_clause))
 SELECT INTO "nl:"
  FROM chart_request cr,
   person p,
   chart_request_audit cra,
   output_dest od,
   chart_print_queue cpq,
   dummyt d
  PLAN (cr
   WHERE parser(plan_clause)
    AND ((cr.chart_status_cd+ 0) IN (chart_status_cd, queued_status_cd))
    AND ((cr.request_type+ 0)=8))
   JOIN (p
   WHERE p.person_id=cr.person_id)
   JOIN (cpq
   WHERE (cpq.distribution_id= Outerjoin(cr.distribution_id))
    AND (cpq.request_id= Outerjoin(cr.chart_request_id))
    AND (cpq.queue_status_cd= Outerjoin(spooled_status_cd)) )
   JOIN (d)
   JOIN (cra
   WHERE (cra.chart_request_id= Outerjoin(cr.chart_request_id)) )
   JOIN (od
   WHERE (od.output_dest_cd= Outerjoin(cr.output_dest_cd)) )
  ORDER BY cr.request_dt_tm, cr.chart_request_id, cpq.batch_id DESC
  HEAD REPORT
   result_cnt = 0, x = 0
  HEAD cr.chart_request_id
   IF (((cr.chart_status_cd=chart_status_cd) OR (cr.chart_status_cd=queued_status_cd
    AND cpq.queue_status_cd=spooled_status_cd)) )
    FOR (x = 0 TO cr.resubmit_cnt)
      result_cnt += 1
      IF (mod(result_cnt,50)=1)
       stat = alterlist(report_writer->qual,(result_cnt+ 49)), stat = alterlist(temp_request->qual,(
        result_cnt+ 49))
      ENDIF
      report_writer->qual[result_cnt].resubmit_cnt = x
      IF (x > 0)
       report_writer->qual[result_cnt].display_ind = 0
      ELSE
       report_writer->qual[result_cnt].display_ind = 1
      ENDIF
      report_writer->qual[result_cnt].req_id = cr.chart_request_id, report_writer->qual[result_cnt].
      pt_name = p.name_full_formatted
      IF (cra.patconobt_ind=0)
       report_writer->qual[result_cnt].patient_consent = "N"
      ELSE
       report_writer->qual[result_cnt].patient_consent = "Y"
      ENDIF
      IF (cr.resubmit_cnt=0)
       report_writer->qual[result_cnt].resubmited = "N"
      ELSE
       report_writer->qual[result_cnt].resubmited = "Y"
      ENDIF
      temp_request->qual[result_cnt].person_id = cr.request_prsnl_id, report_writer->qual[result_cnt]
      .comments = cra.comments, report_writer->qual[result_cnt].output_dev = od.name,
      report_writer->qual[result_cnt].reason = uar_get_code_description(cra.reason_cd), report_writer
      ->qual[result_cnt].req_dt_tm = format(cr.request_dt_tm,"@SHORTDATETIMENOSEC"), report_writer->
      qual[result_cnt].scope_flag = cr.scope_flag,
      report_writer->qual[result_cnt].person_id = cr.person_id, report_writer->qual[result_cnt].
      encntr_id = cr.encntr_id, report_writer->qual[result_cnt].req_name_pe = cra.requestor_pe_name,
      report_writer->qual[result_cnt].dest_name_pe = cra.dest_pe_name, report_writer->qual[result_cnt
      ].req_id_pe = cra.requestor_pe_id, report_writer->qual[result_cnt].dest_id_pe = cra.dest_pe_id
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
    ENDFOR
   ENDIF
  FOOT  cr.chart_request_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(report_writer->qual,result_cnt), stat = alterlist(temp_request->qual,result_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 SET req_nbr = size(report_writer->qual,5)
 SET reply->status_data.status = "S"
 CALL error_and_zero_check(req_nbr,"CP_GET_DISCLOSURE_LOG","GETAUDITLOG",1,1)
 EXECUTE cp_get_prsnl_ident_by_id2  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
  "TEMP_REPLY")
 IF ((temp_reply->status_data.status="S"))
  FOR (x = 1 TO req_nbr)
    SET num = 0
    SET start = 1
    SET replyindex = 0
    IF ((temp_request->qual[x].person_id > 0))
     SET replyindex = locateval(num,start,size(temp_reply->qual,5),temp_request->qual[x].person_id,
      temp_reply->qual[num].person_id)
     SET report_writer->qual[x].cr_req_name = temp_reply->qual[replyindex].name_full
     SET report_writer->qual[x].cr_userid = temp_reply->qual[replyindex].username
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM chart_printed_sections cps,
   chart_section cs,
   (dummyt d1  WITH seq = value(req_nbr))
  PLAN (d1)
   JOIN (cps
   WHERE (cps.chart_request_id=report_writer->qual[d1.seq].req_id)
    AND (cps.resubmit_nbr=report_writer->qual[d1.seq].resubmit_cnt))
   JOIN (cs
   WHERE cs.chart_section_id=cps.chart_section_id)
  ORDER BY d1.seq, cps.chart_request_id, cps.resubmit_nbr DESC
  HEAD d1.seq
   count1 = 0, report_writer->qual[d1.seq].resub_dt_tm = format(cps.resubmit_dt_tm,
    "@SHORTDATETIMENOSEC"), report_writer->qual[d1.seq].display_ind = 1
  DETAIL
   count1 += 1
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
   count1 += 1
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
    count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(report_writer->qual[d3.seq].mrn_list,(count1+ 9))
    ENDIF
    report_writer->qual[d3.seq].mrn_list[count1].mrn = ea.alias
   ELSE
    count2 += 1
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
  FROM requester r,
   (dummyt d5  WITH seq = value(req_nbr))
  PLAN (d5
   WHERE (((report_writer->qual[d5.seq].req_name_pe="REQUESTER")) OR ((report_writer->qual[d5.seq].
   dest_name_pe="REQUESTER"))) )
   JOIN (r
   WHERE r.requester_id IN (report_writer->qual[d5.seq].req_id_pe, report_writer->qual[d5.seq].
   dest_id_pe))
  DETAIL
   IF ((r.requester_id=report_writer->qual[d5.seq].req_id_pe)
    AND (report_writer->qual[d5.seq].req_name_pe="REQUESTER"))
    report_writer->qual[d5.seq].req_name = r.name_full_formatted
   ENDIF
   IF ((r.requester_id=report_writer->qual[d5.seq].dest_id_pe)
    AND (report_writer->qual[d5.seq].dest_name_pe="REQUESTER"))
    report_writer->qual[d5.seq].dest = r.name_full_formatted
   ENDIF
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
 FREE SET temp_request
 RECORD temp_request(
   1 qual[*]
     2 person_id = f8
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 person_id = f8
     2 name_full = vc
     2 name_first = vc
     2 name_last = vc
     2 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(temp_request->qual,req_nbr)
 SELECT INTO "nl:"
  FROM (dummyt d6  WITH seq = value(req_nbr))
  PLAN (d6
   WHERE (report_writer->qual[d6.seq].req_name_pe="PERSON"))
  DETAIL
   temp_request->qual[d6.seq].person_id = report_writer->qual[d6.seq].req_id_pe
  WITH nocounter
 ;end select
 EXECUTE cp_get_prsnl_ident_by_id2  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
  "TEMP_REPLY")
 IF ((temp_reply->status_data.status="S"))
  FOR (x = 1 TO req_nbr)
    SET num = 0
    SET start = 1
    SET replyindex = 0
    IF ((temp_request->qual[x].person_id > 0))
     SET replyindex = locateval(num,start,size(temp_reply->qual,5),temp_request->qual[x].person_id,
      temp_reply->qual[num].person_id)
     SET report_writer->qual[x].req_name = temp_reply->qual[replyindex].name_full
     SET report_writer->qual[x].req_userid = temp_reply->qual[replyindex].username
    ENDIF
  ENDFOR
 ENDIF
 FREE SET temp_request
 RECORD temp_request(
   1 qual[*]
     2 person_id = f8
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 person_id = f8
     2 name_full = vc
     2 name_first = vc
     2 name_last = vc
     2 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(temp_request->qual,req_nbr)
 SELECT INTO "nl:"
  FROM (dummyt d7  WITH seq = value(req_nbr))
  PLAN (d7
   WHERE (report_writer->qual[d7.seq].dest_name_pe="PERSON"))
  DETAIL
   temp_request->qual[d7.seq].person_id = report_writer->qual[d7.seq].dest_id_pe
  WITH nocounter
 ;end select
 EXECUTE cp_get_prsnl_ident_by_id2  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
  "TEMP_REPLY")
 IF ((temp_reply->status_data.status="S"))
  FOR (x = 1 TO req_nbr)
    SET num = 0
    SET start = 1
    SET replyindex = 0
    IF ((temp_request->qual[x].person_id > 0))
     SET replyindex = locateval(num,start,size(temp_reply->qual,5),temp_request->qual[x].person_id,
      temp_reply->qual[num].person_id)
     SET report_writer->qual[x].dest = temp_reply->qual[replyindex].name_full
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM location l,
   organization o,
   (dummyt d8  WITH seq = value(req_nbr))
  PLAN (d8
   WHERE (((report_writer->qual[d8.seq].req_name_pe="CODE_VALUE")
    AND (report_writer->qual[d8.seq].req_id_pe > 0)) OR ((report_writer->qual[d8.seq].dest_name_pe=
   "CODE_VALUE")
    AND report_writer->qual[d8.seq].dest_id_pe)) )
   JOIN (l
   WHERE l.location_cd IN (report_writer->qual[d8.seq].req_id_pe, report_writer->qual[d8.seq].
   dest_id_pe)
    AND l.location_cd > 0)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
  DETAIL
   IF ((report_writer->qual[d8.seq].req_id_pe=l.location_cd))
    report_writer->qual[d8.seq].loc_req_org = o.org_name
   ENDIF
   IF ((report_writer->qual[d8.seq].dest_id_pe=l.location_cd))
    report_writer->qual[d8.seq].loc_dest_org = o.org_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(outfile)
  FROM (dummyt d9  WITH seq = value(req_nbr))
  WHERE (report_writer->qual[d9.seq].display_ind=1)
  HEAD REPORT
   row_nbr_cnt = 0, line_s = fillstring(131,"-"), row + 1,
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTHEAD","Disclosure Audit Log"), col 56, tempstr,
   row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINT","Printed: "), col 0,
   tempstr, col 9, currentdate,
   col 18, currenttime, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINTBY","Printed by: "),
   col 80, tempstr, tempval = size(trim(loginname),1)
   IF (tempval <= 29)
    col login_start, loginname
   ELSE
    tempstr = substring(1,26,loginname), tempstr = concat(tempstr,"..."), col login_start,
    tempstr
   ENDIF
   row + 1, line_s, row + 1,
   line_s, row + 1
  DETAIL
   mrn = "", fin = "", sec = "",
   row_nbr_cnt += 1
   IF (mod(row_nbr_cnt,10)=1)
    stat = alterlist(row_cnt->qual,(row_nbr_cnt+ 9))
   ENDIF
   row_cnt->qual[row_nbr_cnt].row_nbr = row, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQID",
    "Chart Request Id:"), col 0,
   tempstr, col req_id, report_writer->qual[d9.seq].req_id";L",
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPTNAME","Patient Name:"), col pt_start,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].pt_name),1), tempstr = trim(report_writer
    ->qual[d9.seq].pt_name)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col req_id, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col req_id,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col req_id,
    tempstr2
   ELSE
    col req_id, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTMRN","MRN:"), col mrn_st,
   tempstr, mrn_list = size(report_writer->qual[d9.seq].mrn_list,5)
   FOR (x = 1 TO mrn_list)
     IF (x=1)
      mrn = report_writer->qual[d9.seq].mrn_list[x].mrn
     ELSE
      mrn = concat(mrn,", ",report_writer->qual[d9.seq].mrn_list[x].mrn)
     ENDIF
   ENDFOR
   tempval = size(trim(mrn),1), tempstr = trim(mrn)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col req_id, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col req_id,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col req_id,
    tempstr2
   ELSE
    col req_id, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTFIN","FIN:"), col fin_st,
   tempstr, fin_list = size(report_writer->qual[d9.seq].fin_list,5)
   FOR (x = 1 TO fin_list)
     IF (x=1)
      fin = report_writer->qual[d9.seq].fin_list[x].fin
     ELSE
      fin = concat(fin,", ",report_writer->qual[d9.seq].fin_list[x].fin)
     ENDIF
   ENDFOR
   tempval = size(trim(fin),1), tempstr = trim(fin)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col req_id, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col req_id,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col req_id,
    tempstr2
   ELSE
    col req_id, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQUSR","User Id:"), col req_usr,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].cr_userid),1), tempstr = trim(
    report_writer->qual[d9.seq].cr_userid)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col req_id, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col req_id,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col req_id,
    tempstr2
   ELSE
    col req_id, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTOTPDEV","Output Dev:"), col otp_dev,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].output_dev),1), tempstr = trim(
    report_writer->qual[d9.seq].output_dev)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col req_id, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col req_id,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col req_id,
    tempstr2
   ELSE
    col req_id, tempstr
   ENDIF
   row_cnt->qual[row_nbr_cnt].row_nbr_pat = row, row row_cnt->qual[row_nbr_cnt].row_nbr, tempstr =
   uar_i18ngetmessage(i18nhandle,"RPTREQDTTM","Orig Req Dt/Tm:"),
   col req_dt_tm, tempstr, tempstr = trim(report_writer->qual[d9.seq].req_dt_tm),
   col dest_start, tempstr, row + 1,
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTRESDTTM","Res Dt/Tm:"), col res_dt_tm, tempstr,
   tempstr = trim(report_writer->qual[d9.seq].resub_dt_tm), col dest_start, tempstr,
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTDEST","Destination:"), col dest,
   tempstr
   IF (report_writer->qual[d9.seq].loc_dest_org)
    tempval = size(trim(concat(report_writer->qual[d9.seq].dest," *")),1), tempstr = trim(concat(
      report_writer->qual[d9.seq].dest," *"))
   ELSE
    tempval = size(trim(report_writer->qual[d9.seq].dest),1), tempstr = trim(report_writer->qual[d9
     .seq].dest)
   ENDIF
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col dest_start, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col dest_start,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col dest_start, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTREQNM","Requestor:"), col req_name,
   tempstr
   IF (report_writer->qual[d9.seq].loc_req_org)
    tempval = size(trim(concat(report_writer->qual[d9.seq].req_name," **")),1)
    IF (tempval > 0)
     tempstr = trim(concat(report_writer->qual[d9.seq].req_name," **"))
    ELSE
     tempval = size(trim(concat(report_writer->qual[d9.seq].cr_req_name," **")),1), tempstr = trim(
      concat(report_writer->qual[d9.seq].cr_req_name," **"))
    ENDIF
   ELSE
    tempval = size(trim(report_writer->qual[d9.seq].req_name),1)
    IF (tempval > 0)
     tempstr = trim(report_writer->qual[d9.seq].req_name)
    ELSE
     tempval = size(trim(report_writer->qual[d9.seq].cr_req_name),1), tempstr = trim(report_writer->
      qual[d9.seq].cr_req_name)
    ENDIF
   ENDIF
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col dest_start, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col dest_start,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col dest_start, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTRSN","Reason:"), col reason,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].reason),1), tempstr = trim(report_writer
    ->qual[d9.seq].reason)
   IF (tempval > left_max)
    tempstr2 = substring(1,left_max,tempstr), col dest_start, tempstr2,
    x = left_inc
    WHILE (x <= tempval)
      IF (((x+ left_max) > tempval))
       x += left_max
      ELSE
       tempstr2 = substring(x,left_max,tempstr), row + 1, col dest_start,
       tempstr2, x += left_max
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - left_max),tempval,tempstr), col dest_start,
    tempstr2
   ELSE
    col dest_start, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPTCON","Auth Rec'd:"), col pt_const,
   tempstr, tempval = size(trim(report_writer->qual[d9.seq].patient_consent),1)
   IF (tempval > 0)
    col dest_start, report_writer->qual[d9.seq].patient_consent
   ENDIF
   row_cnt->qual[row_nbr_cnt].row_nbr_dest = row
   IF ((row_cnt->qual[row_nbr_cnt].row_nbr_pat > row_cnt->qual[row_nbr_cnt].row_nbr_dest))
    row row_cnt->qual[row_nbr_cnt].row_nbr_pat, row + 1, row_cnt->qual[row_nbr_cnt].row_nbr = row
   ELSE
    row row_cnt->qual[row_nbr_cnt].row_nbr_dest, row + 1, row_cnt->qual[row_nbr_cnt].row_nbr = row
   ENDIF
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTCOM","Comments:"), col 0, tempstr,
   tempval = size(trim(report_writer->qual[d9.seq].comments),1), tempstr = trim(report_writer->qual[
    d9.seq].comments)
   IF (tempval > 120)
    tempstr2 = substring(1,120,tempstr), col com, tempstr2,
    x = 121
    WHILE (x <= tempval)
      IF (((x+ 120) > tempval))
       x += 120
      ELSE
       tempstr2 = substring(x,120,tempstr), row + 1, col com,
       tempstr2, x += 120
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 120),tempval,tempstr), col com,
    tempstr2
   ELSE
    col com, tempstr
   ENDIF
   row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RPTSEC","Chart Sections Printed:"), col 0,
   tempstr, sec_list = size(report_writer->qual[d9.seq].sections,5)
   FOR (x = 1 TO sec_list)
     IF (x=1)
      sec = report_writer->qual[d9.seq].sections[x].section
     ELSE
      sec = concat(sec,", ",report_writer->qual[d9.seq].sections[x].section)
     ENDIF
   ENDFOR
   tempval = size(trim(sec),1), tempstr = trim(sec)
   IF (tempval > 105)
    tempstr2 = substring(1,105,tempstr), col sect, tempstr2,
    x = 106
    WHILE (x <= tempval)
      IF (((x+ 105) > tempval))
       x += 105
      ELSE
       tempstr2 = substring(x,105,tempstr), row + 1, col sect,
       tempstr2, x += 105
      ENDIF
    ENDWHILE
    row + 1, tempstr2 = substring((x - 105),tempval,tempstr), col sect,
    tempstr2
   ELSEIF (tempval=0)
    col sect, sect_msg
   ELSE
    col sect, tempstr
   ENDIF
   IF (report_writer->qual[d9.seq].loc_dest_org)
    row + 1, tempstr = trim(concat("*  ",report_writer->qual[d9.seq].loc_dest_org)), col 0,
    tempstr
   ENDIF
   IF (report_writer->qual[d9.seq].loc_req_org)
    row + 1, tempstr = trim(concat("** ",report_writer->qual[d9.seq].loc_req_org)), col 0,
    tempstr
   ENDIF
   row + 2
  FOOT REPORT
   stat = alterlist(row_cnt->qual,row_nbr_cnt)
  WITH nocounter, maxcol = 132, maxrow = 120000
 ;end select
 FREE DEFINE rtl
 DEFINE rtl value(outfile)
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].line = r.line
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL error_and_zero_check(curqual,"CP_GET_DISCLOSURE_LOG","GETAUDITLOG",1,0)
#exit_script
 CALL log_message("Exiting script: cp_get_disclosure_log",log_level_debug)
END GO
