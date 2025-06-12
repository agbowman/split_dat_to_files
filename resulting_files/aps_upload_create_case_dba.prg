CREATE PROGRAM aps_upload_create_case:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(accession_common_version,- (1))=- (1)))
  DECLARE accession_common_version = i2 WITH constant(0)
  DECLARE acc_success = i2 WITH constant(0)
  DECLARE acc_error = i2 WITH constant(1)
  DECLARE acc_future = i2 WITH constant(2)
  DECLARE acc_null_dt_tm = i2 WITH constant(3)
  DECLARE acc_template = i2 WITH constant(300)
  DECLARE acc_pool = i2 WITH constant(310)
  DECLARE acc_pool_sequence = i2 WITH constant(320)
  DECLARE acc_duplicate = i2 WITH constant(410)
  DECLARE acc_modify = i2 WITH constant(420)
  DECLARE acc_sequence_id = i2 WITH constant(430)
  DECLARE acc_insert = i2 WITH constant(440)
  DECLARE acc_pool_id = i2 WITH constant(450)
  DECLARE acc_aor_false = i2 WITH constant(500)
  DECLARE acc_aor_true = i2 WITH constant(501)
  DECLARE acc_person_false = i2 WITH constant(502)
  DECLARE acc_person_true = i2 WITH constant(503)
  DECLARE site_length = i2 WITH constant(5)
  DECLARE julian_sequence_length = i2 WITH constant(6)
  DECLARE prefix_sequence_length = i2 WITH constant(7)
  DECLARE accession_status = i4 WITH noconstant(acc_success)
  DECLARE accession_meaning = c200 WITH noconstant(fillstring(200," "))
  RECORD acc_settings(
    1 acc_settings_loaded = i2
    1 site_code_length = i4
    1 julian_sequence_length = i4
    1 alpha_sequence_length = i4
    1 year_display_length = i4
    1 default_site_cd = f8
    1 default_site_prefix = c5
    1 assignment_days = i4
    1 assignment_dt_tm = dq8
    1 check_disp_ind = i2
  )
  RECORD accession_fmt(
    1 time_ind = i2
    1 insert_aor_ind = i2
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_format_cd = f8
      2 accession_format_mean = c12
      2 accession_class_cd = f8
      2 specimen_type_cd = f8
      2 accession_dt_tm = dq8
      2 accession_day = i4
      2 accession_year = i4
      2 alpha_prefix = c2
      2 accession_seq_nbr = i4
      2 accession_pool_id = f8
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_id = f8
      2 accession = c20
      2 accession_formatted = c25
      2 activity_type_cd = f8
      2 activity_type_mean = c12
      2 order_tag = i2
      2 accession_info_pos = i2
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_parent = i2
      2 body_site_cd = f8
      2 body_site_ind = i2
      2 specimen_type_ind = i2
      2 service_area_cd = f8
      2 linked_qual[*]
        3 linked_pos = i2
  )
  RECORD accession_grp(
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 site_prefix_cd = f8
      2 accession_format_cd = f8
      2 accession_class_cd = f8
      2 accession_dt_tm = dq8
      2 accession_pool_id = f8
      2 accession_id = f8
      2 accession = c20
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 body_site_cd = f8
      2 service_area_cd = f8
  )
  DECLARE accession_nbr = c20 WITH noconstant(fillstring(20," "))
  DECLARE accession_nbr_chk = c50 WITH noconstant(fillstring(50," "))
  RECORD accession_str(
    1 site_prefix_disp = c5
    1 accession_year = i4
    1 accession_day = i4
    1 alpha_prefix = c2
    1 accession_seq_nbr = i4
    1 accession_pool_id = f8
  )
  DECLARE acc_site_prefix_cd = f8 WITH noconstant(0.0)
  DECLARE acc_site_prefix = c5 WITH noconstant(fillstring(value(site_length)," "))
  DECLARE accession_id = f8 WITH noconstant(0.0)
  DECLARE accession_dup_id = f8 WITH noconstant(0.0)
  DECLARE accession_updt_cnt = i4 WITH noconstant(0)
  DECLARE accession_assignment_ind = i2 WITH noconstant(0)
  RECORD accession_chk(
    1 check_disp_ind = i2
    1 site_prefix_cd = f8
    1 accession_year = i4
    1 accession_day = i4
    1 accession_pool_id = f8
    1 accession_seq_nbr = i4
    1 accession_class_cd = f8
    1 accession_format_cd = f8
    1 alpha_prefix = c2
    1 accession_id = f8
    1 accession = c20
    1 accession_nbr_check = c50
    1 accession_updt_cnt = i4
    1 action_ind = i2
    1 preactive_ind = i2
    1 assignment_ind = i2
  )
 ENDIF
 SUBROUTINE logtofilestart(progname)
   SELECT INTO "ccluserdir:aplog"
    date_stamp = format(curdate,"mm-dd-yy;;D"), time_stamp = format(curtime3,"hh:mm:ss;3;m")
    HEAD REPORT
     line = fillstring(125,"/")
    DETAIL
     col 0, line, col 0,
     time_stamp"########", col 10, date_stamp,
     col 20, progname"#########################", col 50,
     " S t a r t "
    WITH nocounter, append, noformfeed,
     noheading, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logtofile(message)
   SELECT INTO "ccluserdir:aplog"
    time_stamp = format(curtime3,"hh:mm:ss;3;m")
    HEAD REPORT
     line = fillstring(125,"-")
    DETAIL
     col 0, time_stamp"########", col 10,
     message
     "#########################################################################################################"
    WITH nocounter, append, noformfeed,
     noheading, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logtofileend(progname)
   SELECT INTO "ccluserdir:aplog"
    date_stamp = format(curdate,"mm-dd-yy;;D"), time_stamp = format(curtime3,"hh:mm:ss;3;m")
    HEAD REPORT
     line = fillstring(125,"\")
    DETAIL
     col 0, line, col 0,
     time_stamp"########", col 10, date_stamp,
     col 20, progname"#########################", col 50,
     "   E n d   "
    WITH nocounter, append, noformfeed,
     noheading, maxrow = 1
   ;end select
 END ;Subroutine
 DECLARE error_cnt = i2
 DECLARE case_id = f8
 DECLARE verified_cd = f8
 DECLARE report_id = f8
 DECLARE report_sequence = i2
 DECLARE serrormsg = vc
 SET error_cnt = 0
 SET report_id = 0.0
 SET report_sequence = 0
#script
 IF ((request->debug_flag >= 2))
  CALL logtofilestart("aps_upload_create_case")
  CALL logtofile(build("request->accession_nbr ......... ",request->accession_nbr))
  CALL logtofile(build("request->case_id ............... ",request->case_id))
  CALL logtofile(build("request->site_str .............. ",request->site_str))
  CALL logtofile(build("request->prefix_str ............ ",request->prefix_str))
  CALL logtofile(build("request->year_str .............. ",request->year_str))
  CALL logtofile(build("request->seq_str ............... ",request->seq_str))
  CALL logtofile(build("request->site_cd ............... ",request->site_cd))
  CALL logtofile(build("request->accession_format_cd.... ",request->accession_format_cd))
  CALL logtofile(build("request->person_id ............. ",request->person_id))
  CALL logtofile(build("request->accession_dt_tm ....... ",request->accession_dt_tm))
  CALL logtofile(build("request->case_type_cd .......... ",request->case_type_cd))
  CALL logtofile(build("request->requesting_physician_id ",request->requesting_physician_id))
  CALL logtofile(build("request->encntr_id ............. ",request->encntr_id))
  CALL logtofile(build("request->accession_nbr ......... ",request->accession_nbr))
  CALL logtofile(build("request->prefix_id ............. ",request->prefix_id))
  CALL logtofile(build("request->accession_pool_id ..... ",request->accession_pool_id))
  CALL logtofile(build("request->collected_dt_tm ....... ",request->collected_dt_tm))
  CALL logtofile(build("request->event_id .............. ",request->event_id))
  CALL logtofile(build("request->catalog_cd ............ ",request->catalog_cd))
  CALL logtofile(build("request->verify_prsnl_id ....... ",request->verify_prsnl_id))
  CALL logtofile(build("request->verify_dt_tm .......... ",request->verify_dt_tm))
  CALL logtofile(build("request->ext_accession_nbr ..... ",request->ext_accession_nbr))
  CALL logtofile(build("request->contributor_system_cd . ",request->contributor_system_cd))
  CALL logtofile(build("request->reference_nbr ......... ",request->reference_nbr))
 ENDIF
 IF (textlen(trim(request->ext_accession_nbr)) > 21)
  SET request->ext_accession_nbr = substring(1,21,request->ext_accession_nbr)
  IF ((request->debug_flag >= 2))
   CALL logtofile(build("Triming EXT_ACCESSION_NBR....... ",request->ext_accession_nbr))
  ENDIF
 ENDIF
 IF (validate(event_rep,0))
  IF ((request->debug_flag >= 2))
   CALL logtofile("Event Server reply found .......  Extracting event_id")
  ENDIF
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(size(event_rep->rb_list,5))),
    code_value_event_r cver,
    code_value cv
   PLAN (d)
    JOIN (cver
    WHERE (event_rep->rb_list[d.seq].event_cd=cver.event_cd)
     AND (event_rep->rb_list[d.seq].reference_nbr=request->reference_nbr))
    JOIN (cv
    WHERE cver.parent_cd=cv.code_value
     AND cv.code_set=200)
   DETAIL
    request->event_id = event_rep->rb_list[d.seq].event_id
   WITH nocounter
  ;end select
  IF ((request->event_id=0))
   IF ((request->debug_flag >= 2))
    CALL logtofile("Unable to find report event_id from event_rep structure!")
   ENDIF
   CALL handle_errors("GET","F","REPLY","REPORT EVENT_ID")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile(build("request->event_id .............. ",request->event_id))
 ENDIF
 IF ((request->case_id=0))
  IF ((request->debug_flag >= 2))
   CALL logtofile(build("Check for existing accession ... ",request->accession_nbr))
  ENDIF
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND (request->person_id=pc.person_id)
   DETAIL
    request->case_id = pc.case_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((request->debug_flag >= 2))
    CALL logtofile("Check for existing accession ...None Found")
   ENDIF
  ELSE
   IF ((request->debug_flag >= 2))
    CALL logtofile(build("Check for existing accession ...FOUND Case_id=",request->case_id))
   ENDIF
   GO TO process_existing
  ENDIF
 ENDIF
 IF ((request->case_id=0))
  SET accession_str->site_prefix_disp = request->site_str
  SET accession_str->alpha_prefix = request->prefix_str
  SET accession_str->accession_year = cnvtint(request->year_str)
  SET accession_str->accession_seq_nbr = cnvtint(request->seq_str)
  SET accession_str->accession_pool_id = request->accession_pool_id
  SET accession_str->accession_day = 0
  EXECUTE accession_string
  SET accession_chk->site_prefix_cd = request->site_cd
  SET accession_chk->accession_year = accession_str->accession_year
  SET accession_chk->accession_day = accession_str->accession_day
  SET accession_chk->accession_pool_id = accession_str->accession_pool_id
  SET accession_chk->accession_seq_nbr = accession_str->accession_seq_nbr
  SET accession_chk->accession_class_cd = 0.0
  SET accession_chk->accession_format_cd = request->accession_format_cd
  SET accession_chk->alpha_prefix = accession_str->alpha_prefix
  SET accession_chk->accession = accession_nbr
  SET accession_chk->accession_nbr_check = accession_nbr_chk
  SET accession_chk->action_ind = 0
  SET accession_chk->preactive_ind = 0
  SET accession_chk->check_disp_ind = 2
  EXECUTE accession_check
  IF (accession_status != acc_success)
   CALL handle_errors("ACC_ASSIGNMENT","F","ACCESSION",build("ACCESSION-",accession_meaning))
   GO TO exit_script
  ENDIF
  SET case_id = accession_id
  IF ((request->debug_flag >= 2))
   CALL logtofile(build("Accession id = ",accession_id))
  ENDIF
  IF ((request->debug_flag >= 2))
   CALL logtofile("Add pathology case record")
  ENDIF
  INSERT  FROM pathology_case pc
   SET pc.case_id = case_id, pc.person_id = request->person_id, pc.accessioned_dt_tm = cnvtdatetime(
     request->accession_dt_tm),
    pc.case_year = cnvtint(request->year_str), pc.case_number = cnvtint(request->seq_str), pc
    .case_type_cd = request->case_type_cd,
    pc.requesting_physician_id = request->requesting_physician_id, pc.encntr_id = request->encntr_id,
    pc.accession_prsnl_id = reqinfo->updt_id,
    pc.accession_nbr = request->accession_nbr, pc.prefix_id = request->prefix_id, pc.group_id =
    request->accession_pool_id,
    pc.case_collect_dt_tm =
    IF ((request->collected_dt_tm > 0)) cnvtdatetime(request->collected_dt_tm)
    ELSE null
    ENDIF
    , pc.origin_flag = 2, pc.reserved_ind = 0,
    pc.main_report_cmplete_dt_tm =
    IF ((request->verify_dt_tm > 0)) cnvtdatetime(request->verify_dt_tm)
    ELSE null
    ENDIF
    , pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0,
    pc.ext_accession_nbr = request->ext_accession_nbr, pc.contributor_system_cd = request->
    contributor_system_cd
   WITH nocounter
  ;end insert
  SET error_check = error(serrormsg,0)
  CALL logtofile(build("error",serrormsg))
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","PATHOLOGY_CASE")
   GO TO exit_script
  ENDIF
  IF ((request->debug_flag >= 2))
   CALL logtofile("Done adding pathology case record")
  ENDIF
  GO TO continue_process
 ENDIF
#process_existing
 IF ((request->debug_flag >= 2))
  CALL logtofile("Process existing accession")
 ENDIF
 SET case_id = request->case_id
 SET primary_ind = 0
 IF ((request->debug_flag >= 2))
  CALL logtofile("Get primary report")
 ENDIF
 SELECT INTO "nl:"
  pr.primary_ind
  FROM prefix_report_r pr
  WHERE (request->prefix_id=pr.prefix_id)
   AND (request->catalog_cd=pr.catalog_cd)
  HEAD REPORT
   primary_ind = 0
  DETAIL
   primary_ind = pr.primary_ind
  WITH nocounter
 ;end select
 IF (primary_ind=1)
  UPDATE  FROM pathology_case pc
   SET pc.main_report_cmplete_dt_tm =
    IF ((request->verify_dt_tm > 0)) cnvtdatetime(request->verify_dt_tm)
    ELSE null
    ENDIF
    , pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   WHERE case_id=pc.case_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","PATHOLOGY_CASE")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("Check for existing report")
 ENDIF
 SELECT INTO "nl:"
  cr.report_id, cr.case_id, cr.event_id,
  cr.catalog_cd, cr.report_sequence
  FROM case_report cr
  WHERE case_id=cr.case_id
   AND (request->catalog_cd=cr.catalog_cd)
   AND (request->event_id=cr.event_id)
  DETAIL
   report_id = cr.report_id, report_sequence = cr.report_sequence
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (report_id=0)) )
  SELECT INTO "nl:"
   cr.report_id, cr.case_id, cr.event_id,
   cr.catalog_cd, cr.report_sequence
   FROM case_report cr
   WHERE case_id=cr.case_id
    AND (request->catalog_cd=cr.catalog_cd)
   ORDER BY cr.report_sequence
   DETAIL
    report_id = 0.0, report_sequence = (cr.report_sequence+ 1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET report_id = 0.0
   SET report_sequence = 0
  ENDIF
 ENDIF
#continue_process
 IF ((request->debug_flag >= 2))
  CALL logtofile("Continue processing")
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("Get verified code")
 ENDIF
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 1305
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_cd = code_value
 IF (verified_cd=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 1305")
  GO TO exit_script
 ENDIF
 IF (report_id > 0)
  IF ((request->debug_flag >= 2))
   CALL logtofile("Update existing case report")
  ENDIF
  UPDATE  FROM case_report cr
   SET cr.report_id = report_id, cr.case_id = case_id, cr.event_id = request->event_id,
    cr.catalog_cd = request->catalog_cd, cr.report_sequence = report_sequence, cr.status_prsnl_id =
    request->verify_prsnl_id,
    cr.status_dt_tm =
    IF ((request->verify_dt_tm > 0)) cnvtdatetime(request->verify_dt_tm)
    ELSE null
    ENDIF
    , cr.status_cd = verified_cd, cr.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
    updt_applctx,
    cr.updt_cnt = 0
   WHERE report_id=cr.report_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","CASE_REPORT UPDATE")
   GO TO exit_script
  ENDIF
 ELSE
  IF ((request->debug_flag >= 2))
   CALL logtofile("Get sequence number")
  ENDIF
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    report_id = seq_nbr
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","DUAL (SEQUENCE NUMBER)")
   GO TO exit_script
  ENDIF
  IF ((request->debug_flag >= 2))
   CALL logtofile("Insert case report")
  ENDIF
  INSERT  FROM case_report cr
   SET cr.report_id = report_id, cr.case_id = case_id, cr.event_id = request->event_id,
    cr.catalog_cd = request->catalog_cd, cr.report_sequence = report_sequence, cr.status_prsnl_id =
    request->verify_prsnl_id,
    cr.status_dt_tm =
    IF ((request->verify_dt_tm > 0)) cnvtdatetime(request->verify_dt_tm)
    ELSE null
    ENDIF
    , cr.status_cd = verified_cd, cr.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
    updt_applctx,
    cr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","CASE_REPORT INSERT")
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  IF ((request->debug_flag > 0))
   CALL echo("<<<<< FAILURE <<<<<")
   SET x = 0
   FOR (x = 1 TO error_cnt)
     CALL echo(build("Error:_",x,"_of_",error_cnt))
     CALL echo(concat("---> ",trim(reply->status_data.subeventstatus[x].operationname)," ",trim(reply
        ->status_data.subeventstatus[x].operationstatus)," ",
       trim(reply->status_data.subeventstatus[x].targetobjectname)," ",trim(reply->status_data.
        subeventstatus[x].targetobjectvalue)))
     IF ((request->debug_flag >= 2))
      CALL logtofile("<<<<< FAILURE <<<<<")
      CALL logtofile(build("Error:_",x,"_of_",error_cnt))
      CALL logtofile(concat("---> ",trim(reply->status_data.subeventstatus[x].operationname)," ",trim
        (reply->status_data.subeventstatus[x].operationstatus)," ",
        trim(reply->status_data.subeventstatus[x].targetobjectname)," ",trim(reply->status_data.
         subeventstatus[x].targetobjectvalue)))
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  IF ((request->debug_flag > 0))
   CALL echo(">>>>> SUCCESS >>>>>")
   IF ((request->debug_flag >= 2))
    CALL logtofile(">>>>> SUCCESS >>>>>")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("~ ~ C E R N E R      We make healthcare smarter ~ ~")
  CALL logtofileend("aps_upload_create_case")
 ENDIF
END GO
