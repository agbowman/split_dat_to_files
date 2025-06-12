CREATE PROGRAM cr_ops_journal:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE dist_date = dq8
 DECLARE mrn_cd = f8
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 DECLARE tmp_tz_offset = i4
 DECLARE tmp_tz_daylight = i4
 DECLARE cur_tz_name = vc
 SET cur_tz_name = datetimezonebyindex(0,tmp_tz_offset,tmp_tz_daylight,1)
 SET dist_id = fillstring(100," ")
 SET run_type_cd = fillstring(30," ")
 SET failed = "F"
 SET printer = fillstring(20," ")
 SET message_log = fillstring(200," ")
 SET print_dt_tm = cnvtdatetime(sysdate)
 SET outfile = fillstring(40," ")
 SELECT INTO "nl:"
  i.info_name
  FROM dm_info i
  WHERE i.info_domain=trim(request->batch_selection)
   AND i.info_char="CLINICAL_REPORTING"
   AND i.info_date=cnvtdatetime(request->ops_date)
  DETAIL
   IF (curutc)
    dist_date = cnvtdatetimeutc(cnvtdatetime(i.info_name),2)
   ELSE
    dist_date = cnvtdatetime(i.info_name)
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_info
  SET info_number = (info_number+ 1)
  WHERE info_domain=trim(request->batch_selection)
   AND info_char="CLINICAL_REPORTING"
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.batch_name_key=cnvtalphanum(cnvtupper(request->batch_selection))
   AND c.param_type_flag=2
   AND c.active_ind=1
  DETAIL
   dist_id = trim(c.param)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "CR_OPS_JOURNAL"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "This distribution name is not built in the operations portion of the distribution tool."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.param
  FROM charting_operations c
  WHERE c.batch_name_key=cnvtalphanum(cnvtupper(request->batch_selection))
   AND c.param_type_flag=3
   AND c.active_ind=1
  DETAIL
   run_type_cd = c.param
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "CR_OPS_JOURNAL"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "This distribution has no run type set up."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET message_log = concat("Begin Operations Journal for ",request->batch_selection)
 CALL update_log(trim(message_log))
 COMMIT
 SET outfile = build("ops_jrnl",cnvtstring(curtime3))
 FREE RECORD patients
 RECORD patients(
   1 qual[*]
     2 person_id = f8
 )
 SELECT DISTINCT INTO value(outfile)
  cr.report_request_id, cr.request_type_flag, cr.dist_run_dt_tm"yyyy-mmm-dd hh:mm:ss ;;d",
  cr.encntr_id, accession_number = uar_fmt_accession(cr.accession_nbr,size(cr.accession_nbr,1)), cr
  .order_id,
  cr.scope_flag, display_dist = uar_get_code_display(cr.dist_run_type_cd), crt.template_id,
  crt.template_name, od.output_dest_cd, od.description,
  p.person_id, p.name_full_formatted, ea.encntr_alias_type_cd,
  cd.distribution_id, check = decode(od.output_dest_cd,1,0), cd.dist_descr
  FROM cr_report_request cr,
   chart_distribution cd,
   cr_report_template crt,
   dummyt d1,
   output_dest od,
   person p,
   dummyt d2,
   encntr_alias ea
  PLAN (cr
   WHERE cr.dist_run_dt_tm=cnvtdatetime(dist_date)
    AND cr.distribution_id=cnvtreal(dist_id)
    AND cr.request_type_flag=4
    AND cr.dist_run_type_cd=cnvtreal(run_type_cd))
   JOIN (crt
   WHERE cr.template_id=crt.template_id)
   JOIN (p
   WHERE cr.person_id=p.person_id)
   JOIN (cd
   WHERE cd.distribution_id=cnvtreal(dist_id))
   JOIN (d1)
   JOIN (od
   WHERE cr.output_dest_cd=od.output_dest_cd)
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=cr.encntr_id
    AND ea.encntr_id > 0
    AND ea.encntr_alias_type_cd=mrn_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY cr.request_dt_tm, cr.report_request_id
  HEAD REPORT
   line1 = fillstring(130,"="), line2 = fillstring(20,"_"), pat_count = 0,
   size_patients = 0, chart_count = 0, dist_count = 0,
   chart_ind = 0, row 1,
   CALL center("D I S T R I B U T I O N  J O U R N A L",0,132),
   row + 2, col 1, "Distribution:",
   col + 2,
   CALL print(substring(1,50,cd.dist_descr)), col 84,
   "Run Date/Time:", col + 3, dist_date";;q",
   " ", cur_tz_name, row + 1,
   col 1, "Report Template:", col + 2,
   CALL print(substring(1,50,crt.template_name)), col 84, "Print Date/Time:",
   col + 1, print_dt_tm";;q", " ",
   cur_tz_name, row + 1, col 1,
   "Run Type:", col + 2, display_dist,
   row + 1, row + 1, line1,
   row + 1
  HEAD PAGE
   col 1, "Name", col 30,
   "Med Rec #", col 65
   IF (cr.scope_flag=1)
    "Person ID"
   ELSEIF (cr.scope_flag=2)
    "Encounter ID"
   ELSEIF (cr.scope_flag=4)
    "Accession #"
   ELSEIF (cr.scope_flag=3)
    "Order #"
   ENDIF
   col 87, "Output Device", col 118,
   "Page: ", col 124, curpage"###",
   row + 1, line1, row + 1
  DETAIL
   chart_ind = 1, chart_count += 1, size_patients = size(patients->qual,5),
   already_there = 0
   FOR (x = 1 TO size_patients)
     IF ((patients->qual[x].person_id=p.person_id))
      already_there = 1
     ENDIF
   ENDFOR
   IF (already_there=0)
    pat_count += 1, stat = alterlist(patients->qual,pat_count), patients->qual[pat_count].person_id
     = p.person_id
   ENDIF
   col 1,
   CALL print(substring(1,25,p.name_full_formatted)), col 30,
   CALL print(substring(1,30,cnvtalias(ea.alias,ea.alias_pool_cd))), col 65
   IF (cr.scope_flag=1)
    p.person_id
   ELSEIF (cr.scope_flag=2)
    cr.encntr_id
   ELSEIF (cr.scope_flag=4)
    accession_number
   ELSEIF (cr.scope_flag=3)
    cr.order_id
   ENDIF
   IF (check=1)
    col 87,
    CALL print(substring(1,30,od.name))
   ELSE
    col 87, "Invalid Destination"
   ENDIF
   row + 1
  FOOT REPORT
   IF (chart_ind=1)
    row + 3, col 1, "TOTAL # OF PATIENTS:",
    col + 2, pat_count"#####", row + 2,
    col 1, "TOTAL # OF CHARTS:", col + 2,
    chart_count"#####"
   ELSE
    col 1, "No Charts Qualified for Distribution:", col + 2,
    CALL print(substring(1,50,request->batch_selection))
   ENDIF
  WITH nullreport, maxcol = 132, maxrow = 56,
   outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  o.output_dest_cd, d.name
  FROM output_dest o,
   device d
  PLAN (o
   WHERE o.output_dest_cd=cnvtreal(trim(request->output_dist)))
   JOIN (d
   WHERE d.device_cd=o.device_cd)
  DETAIL
   printer = d.name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "CH_OPS_JOURNAL"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "UNABLE TO LOCATE PRINTER NAME FOR NUMBER ENTERED IN OPS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SUBROUTINE update_log(str)
   DECLARE nextseq = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    seq1 = seq(chart_dist_log_seq,nextval)
    FROM dual
    DETAIL
     nextseq = seq1
    WITH nocounter
   ;end select
   UPDATE  FROM chart_dist_log cdl
    SET cdl.log_dt_tm = cnvtdatetime(sysdate), cdl.batch_selection = request->batch_selection, cdl
     .distribution_id = cnvtreal(dist_id),
     cdl.dist_run_type_cd = cnvtreal(run_type_cd), cdl.dist_run_dt_tm = cnvtdatetime(dist_date), cdl
     .message_text = str,
     cdl.updt_cnt = 0, cdl.updt_dt_tm = cnvtdatetime(sysdate), cdl.updt_id = reqinfo->updt_id,
     cdl.updt_applctx = reqinfo->updt_applctx, cdl.updt_task = reqinfo->updt_task
    WHERE cdl.chart_log_num=nextseq
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM chart_dist_log cdl
     SET cdl.chart_log_num = nextseq, cdl.log_dt_tm = cnvtdatetime(sysdate), cdl.batch_selection =
      request->batch_selection,
      cdl.distribution_id = cnvtreal(dist_id), cdl.dist_run_type_cd = cnvtreal(run_type_cd), cdl
      .dist_run_dt_tm = cnvtdatetime(dist_date),
      cdl.message_text = str, cdl.updt_cnt = 0, cdl.updt_dt_tm = cnvtdatetime(sysdate),
      cdl.updt_id = reqinfo->updt_id, cdl.updt_applctx = reqinfo->updt_applctx, cdl.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SET outfile1 = fillstring(60," ")
 SET outfile1 = build("ccluserdir:",outfile,".dat")
 FREE DEFINE rtl
 DEFINE rtl value(outfile1)
 SELECT INTO value(printer)
  substring(1,130,r.line)
  FROM rtlt r
  WITH nocounter, dio = postscript
 ;end select
 SET stat = remove(concat(outfile1,";*"))
 IF (stat=1)
  SET message_log = concat("Remove ops journal file ",outfile1)
  CALL update_log(trim(message_log))
  COMMIT
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
 SET message_log = concat("End Operations Journal for ",request->batch_selection)
 CALL update_log(trim(message_log))
 COMMIT
END GO
