CREATE PROGRAM aps_upload_validate_case:dba
 RECORD reply(
   1 unformatted_accession_nbr = c25
   1 formatted_accession_nbr = c25
   1 site_str = c5
   1 prefix_str = c2
   1 year_str = c4
   1 seq_str = c7
   1 site_cd = f8
   1 accession_format_cd = f8
   1 case_type_cd = f8
   1 prefix_id = f8
   1 accession_pool_id = f8
   1 case_id = f8
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
 DECLARE text = c100
 DECLARE real = f8
 DECLARE six = i2
 DECLARE pos = i2
 DECLARE startpos2 = i2
 DECLARE len = i4
 DECLARE endstring = c2
 SUBROUTINE get_text(startpos,textstring,delimit)
   SET siz = size(trim(textstring),1)
   SET pos = startpos
   SET endstring = "F"
   WHILE (pos <= siz)
    IF (substring(pos,1,trim(textstring))=delimit)
     IF (pos=siz)
      SET endstring = "T"
     ENDIF
     SET len = (pos - startpos)
     SET text = substring(startpos,len,trim(textstring))
     SET real = cnvtreal(trim(text))
     SET startpos = (pos+ 1)
     SET startpos2 = (pos+ 1)
     SET pos = siz
    ENDIF
    SET pos += 1
   ENDWHILE
 END ;Subroutine
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
#script
 IF ((request->debug_flag >= 2))
  CALL logtofilestart("aps_upload_validate_case")
  CALL logtofile(build("request->accession_nbr ......... ",request->accession_nbr))
  CALL logtofile(build("request->contributor_source_cd . ",request->contributor_source_cd))
  CALL logtofile(build("request->person_id ............. ",request->person_id))
  CALL logtofile(build("request->encntr_id ............. ",request->encntr_id))
 ENDIF
 DECLARE error_cnt = i2
 DECLARE site_code_len = i2
 DECLARE raw_site = c255
 DECLARE raw_prefix = c255
 DECLARE raw_year = c4
 DECLARE raw_seq = c7
 DECLARE site_str = c5
 DECLARE site_code = f8
 DECLARE prefix_str = c2
 DECLARE prefix_id = f8
 DECLARE case_type_code = f8
 DECLARE ap_activity_type_code = f8
 DECLARE accession_format_code = f8
 DECLARE accession_pool_id = f8
 DECLARE curyear = c4
 DECLARE case_id = f8
 DECLARE uar_fmt_accession(p1,p2) = c25
 SET error_cnt = 0
 CALL get_text(1,build(request->accession_nbr,"-"),"-")
 SET raw_site = build(text)
 CALL get_text(startpos2,build(request->accession_nbr,"-"),"-")
 SET raw_prefix = build(text)
 CALL get_text(startpos2,build(request->accession_nbr,"-"),"-")
 SET raw_year = build(text)
 CALL get_text(startpos2,build(request->accession_nbr,"-"),"-")
 SET raw_seq = build(text)
 IF ((request->debug_flag >= 2))
  CALL logtofile("8 Get site code length")
 ENDIF
 SELECT INTO "nl:"
  ase.accession_setup_id
  FROM accession_setup ase
  WHERE ase.accession_setup_id > 0
  DETAIL
   site_code_len = ase.site_code_length
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL handle_errors("SELECT","F","TABLE","ACCESSION_SETUP")
  GO TO exit_script
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("7 Get site code")
 ENDIF
 IF (site_code_len > 0)
  IF (textlen(raw_site) > 0
   AND cnvtint(raw_site) != 0)
   SELECT INTO "nl:"
    cva.code_value
    FROM code_value_alias cva
    WHERE (request->contributor_source_cd=cva.contributor_source_cd)
     AND 2062=cva.code_set
     AND raw_site=cva.alias
    DETAIL
     site_code = cva.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    CALL handle_errors("SELECT","F","TABLE","CODE_VALUE_ALIAS SITE")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE site_code=cv.code_value
     AND 2062=cv.code_set
     AND 1=cv.active_ind
    DETAIL
     site_str = concat(substring(1,(5 - textlen(trim(cv.display))),"00000"),cv.display)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 2062")
    GO TO exit_script
   ENDIF
  ELSE
   SET site_code = 0
   SET site_str = "00000"
  ENDIF
 ELSE
  SET site_code = 0
  SET site_str = "00000"
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("6 get ap activity type code")
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE 106=cv.code_set
   AND "AP"=cv.cdf_meaning
   AND 1=cv.active_ind
  DETAIL
   ap_activity_type_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 106")
  GO TO exit_script
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("5 Get accession format code")
 ENDIF
 SELECT INTO "nl:"
  cva.code_value
  FROM code_value_alias cva,
   accession_assign_xref aax
  PLAN (cva
   WHERE (request->contributor_source_cd=cva.contributor_source_cd)
    AND 2057=cva.code_set
    AND raw_prefix=cva.alias)
   JOIN (aax
   WHERE site_code=aax.site_prefix_cd
    AND cva.code_value=aax.accession_format_cd
    AND ap_activity_type_code=aax.activity_type_cd)
  DETAIL
   accession_format_code = cva.code_value, accession_pool_id = aax.accession_assignment_pool_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE_ALIAS PREFIX")
  GO TO exit_script
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("4 Get prefix string and code")
 ENDIF
 SELECT INTO "nl:"
  cv.display, ap.prefix_id
  FROM code_value cv,
   ap_prefix ap
  PLAN (cv
   WHERE accession_format_code=cv.code_value
    AND 1=cv.active_ind)
   JOIN (ap
   WHERE cv.code_value=ap.accession_format_cd
    AND site_code=ap.site_cd
    AND 1=cv.active_ind)
  DETAIL
   prefix_str = cv.display, prefix_id = ap.prefix_id, case_type_code = ap.case_type_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE 2057")
  GO TO exit_script
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("3 Check year")
 ENDIF
 SET curyear = format(cnvtdatetime(sysdate),"yyyy;;d")
 IF (cnvtint(raw_year) > cnvtint(curyear))
  CALL handle_errors("CHECK","F","FUNCTION","YEAR")
  GO TO exit_script
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("2 Check for existing accession")
  CALL echo("2 Check for existing accession")
 ENDIF
 SET accession_str->accession_pool_id = accession_pool_id
 SET accession_str->alpha_prefix = trim(prefix_str)
 SET accession_str->accession_year = cnvtint(raw_year)
 SET accession_str->accession_seq_nbr = cnvtint(raw_seq)
 SET accession_str->site_prefix_disp = concat(substring(1,(5 - textlen(trim(site_str))),"00000"),
  site_str)
 CALL echo("accession_str->accession_seq_nbr = ",0)
 CALL echo(accession_str->accession_seq_nbr)
 SET accession_str->accession_day = 0
 EXECUTE accession_string
 SET accession_chk->site_prefix_cd = site_code
 SET accession_chk->accession_year = accession_str->accession_year
 SET accession_chk->accession_day = accession_str->accession_day
 SET accession_chk->accession_pool_id = accession_str->accession_pool_id
 SET accession_chk->accession_seq_nbr = accession_str->accession_seq_nbr
 SET accession_chk->accession_class_cd = 0.0
 SET accession_chk->accession_format_cd = accession_format_code
 SET accession_chk->alpha_prefix = accession_str->alpha_prefix
 SET accession_chk->accession = accession_nbr
 CALL echo("accession_chk->accession = ",0)
 CALL echo(accession_chk->accession)
 SET accession_chk->accession_nbr_check = accession_nbr_chk
 SET accession_chk->action_ind = 1
 SET accession_chk->preactive_ind = 0
 SET accession_chk->check_disp_ind = 2
 EXECUTE accession_check
 CALL echo("accession_status = ",0)
 CALL echo(accession_status)
 IF (accession_status != acc_success)
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE accession_nbr=pc.accession_nbr
   DETAIL
    reply->case_id = pc.case_id
   WITH nocounter
  ;end select
  CALL echo("1 curqual = ",0)
  CALL echo(curqual)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   CALL handle_errors("ACC_ASSIGNMENT","F","ACCESSION",build("ACCESSION-",accession_meaning))
  ELSE
   SELECT INTO "nl:"
    pc.case_id
    FROM pathology_case pc
    WHERE accession_nbr=pc.accession_nbr
     AND (request->person_id=pc.person_id)
    DETAIL
     reply->case_id = pc.case_id
    WITH nocounter
   ;end select
   CALL echo("2 curqual = ",0)
   CALL echo(curqual)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    CALL handle_errors("SELECT","Z","TABLE","PATHOLOGY_CASE (Accession not Patient's)")
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
    CALL handle_errors("SELECT","P","TABLE","PATHOLOGY_CASE (Accession and Patient found)")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->debug_flag >= 2))
  CALL logtofile("1 Format accession")
 ENDIF
 SET reply->unformatted_accession_nbr = build(substring(1,5,accession_nbr),substring(6,2,
   accession_nbr),substring(8,4,accession_nbr),substring(12,7,accession_nbr))
 SET reply->formatted_accession_nbr = trim(uar_fmt_accession(accession_nbr,size(trim(accession_nbr),1
    )))
 SET reply->site_str = site_str
 SET reply->prefix_str = prefix_str
 SET reply->prefix_id = prefix_id
 SET reply->year_str = raw_year
 SET reply->seq_str = raw_seq
 SET reply->site_cd = site_code
 SET reply->accession_format_cd = accession_format_code
 SET reply->accession_pool_id = accession_pool_id
 SET reply->case_type_cd = case_type_code
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
  IF ((request->debug_flag > 0))
   CALL echo("<<<<< FAILURE <<<<<")
   SET x = 0
   CALL echo("reply->status_data->status = ",0)
   CALL echo(reply->status_data.status)
   IF ((request->debug_flag >= 2))
    CALL logtofile(concat("reply->status_data->status = ",reply->status_data.status))
   ENDIF
   FOR (x = 1 TO error_cnt)
     CALL echo(build("Error:_",x,"_of_",error_cnt))
     CALL echo(concat("---> ",trim(reply->status_data.subeventstatus[x].operationname)," ",trim(reply
        ->status_data.subeventstatus[x].operationstatus)," ",
       trim(reply->status_data.subeventstatus[x].targetobjectname)," ",trim(reply->status_data.
        subeventstatus[x].targetobjectvalue)))
     IF ((request->debug_flag >= 2))
      CALL logtofile("<<<<< FAILURE <<<<<")
      CALL logtofile(concat("---> ",trim(reply->status_data.subeventstatus[x].operationname)," ",trim
        (reply->status_data.subeventstatus[x].operationstatus)," ",
        trim(reply->status_data.subeventstatus[x].targetobjectname)," ",trim(reply->status_data.
         subeventstatus[x].targetobjectvalue)))
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  IF ((request->debug_flag > 0))
   CALL echo(">>>>> SUCCESS >>>>>")
   IF ((request->debug_flag >= 2))
    CALL logtofile(">>>>> SUCCESS >>>>>")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->debug_flag > 0))
  CALL echo(" .                                                         .")
  CALL echo(build("     request->accession_nbr ......... ",request->accession_nbr))
  CALL echo(build("     request->contributor_source_cd . ",request->contributor_source_cd))
  CALL echo(build("     request->person_id ............. ",request->person_id))
  CALL echo(build("     request->encntr_id ............. ",request->encntr_id))
  CALL echo(build("     error_cnt ...................... ",error_cnt))
  CALL echo(build("     site_code_len .................. ",site_code_len))
  CALL echo(build("     raw_site ....................... ",raw_site))
  CALL echo(build("     raw_prefix ..................... ",raw_prefix))
  CALL echo(build("     raw_year ....................... ",raw_year))
  CALL echo(build("     raw_seq ........................ ",raw_seq))
  CALL echo(build("     site_str ....................... ",site_str))
  CALL echo(build("     site_code ...................... ",site_code))
  CALL echo(build("     prefix_str ..................... ",prefix_str))
  CALL echo(build("     prefix_id ...................... ",prefix_id))
  CALL echo(build("     case_type_cd ................... ",case_type_code))
  CALL echo(build("     ap_activity_type_code .......... ",ap_activity_type_code))
  CALL echo(build("     accession_format_code .......... ",accession_format_code))
  CALL echo(build("     accession_pool_id .............. ",accession_pool_id))
  CALL echo(build("     curyear ........................ ",curyear))
  CALL echo(build("     reply->unformatted_acc_nbr ..... ",reply->unformatted_accession_nbr))
  CALL echo(build("     reply->formatted_acc_nbr ....... ",reply->formatted_accession_nbr))
  CALL echo(build("     reply->case_id ................. ",reply->case_id))
  CALL echo(" .                                                       .")
  IF ((request->debug_flag >= 2))
   CALL logtofile(build("error_cnt ...................... ",error_cnt))
   CALL logtofile(build("site_code_len .................. ",site_code_len))
   CALL logtofile(build("raw_site ....................... ",raw_site))
   CALL logtofile(build("raw_prefix ..................... ",raw_prefix))
   CALL logtofile(build("raw_year ....................... ",raw_year))
   CALL logtofile(build("raw_seq ........................ ",raw_seq))
   CALL logtofile(build("site_str ....................... ",site_str))
   CALL logtofile(build("site_code ...................... ",site_code))
   CALL logtofile(build("prefix_str ..................... ",prefix_str))
   CALL logtofile(build("prefix_id ...................... ",prefix_id))
   CALL logtofile(build("case_type_cd ................... ",case_type_code))
   CALL logtofile(build("ap_activity_type_code .......... ",ap_activity_type_code))
   CALL logtofile(build("accession_format_code .......... ",accession_format_code))
   CALL logtofile(build("accession_pool_id .............. ",accession_pool_id))
   CALL logtofile(build("curyear ........................ ",curyear))
   CALL logtofile(build("reply->unformatted_acc_nbr ..... ",reply->unformatted_accession_nbr))
   CALL logtofile(build("reply->formatted_acc_nbr ....... ",reply->formatted_accession_nbr))
   CALL logtofile(build("reply->case_id ................. ",reply->case_id))
   CALL logtofileend("aps_upload_validate_case")
  ENDIF
 ENDIF
END GO
