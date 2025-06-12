CREATE PROGRAM da_import_ccl_rpts:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Error starting da_import_ccl_rpts"
 DECLARE sys_guid() = c32
 DECLARE csvfilename = vc WITH protect, noconstant("")
 DECLARE csvheaderline = i2 WITH protect, noconstant(0)
 DECLARE csverrorind = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errormessage = vc WITH protect, noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE csvline = vc WITH protect, noconstant("")
 DECLARE field = vc WITH protect, noconstant("")
 DECLARE reporttypecode = f8 WITH protect, noconstant(0)
 DECLARE outputviewercode = f8 WITH protect, noconstant(0)
 DECLARE versiontext = c8 WITH protect, constant("001.000")
 DECLARE uuid = c36 WITH protect, noconstant("")
 RECORD reportstoimport(
   1 cclreport[*]
     2 program_name = vc
     2 program_group = i2
     2 description = vc
     2 full_name = vc
     2 report_uuid = vc
     2 report_id = f8
     2 type_cd = f8
     2 viewer_mode = i2
 )
 SET csvfilename = parameter(1,0)
 IF (error(errormessage,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("No CSV filename supplied: ",errormessage)
  GO TO exit_now
 ELSEIF (findfile(csvfilename,4)=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("CSV file '",csvfilename,"' cannot be read.")
  GO TO exit_now
 ENDIF
 SET logical csv_file value(csvfilename)
 FREE DEFINE rtl2
 DEFINE rtl2 "csv_file"
 SELECT INTO "nl:"
  csv.line
  FROM rtl2t csv
  WHERE csv.line > " "
  HEAD REPORT
   stat = alterlist(reportstoimport->cclreport,10), count = 0, csvheaderline = 0,
   csverrorind = 0
  DETAIL
   IF (((csvheaderline=0) OR (csverrorind=1)) )
    csvheaderline = 1
   ELSE
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(reportstoimport->cclreport,(count+ 10))
    ENDIF
    csvline = csv.line, pos = 1, pos = getnextcsvfield(csvline,pos,field),
    reportstoimport->cclreport[count].program_name = cnvtupper(field)
    IF (pos > 0)
     pos = getnextcsvfield(csvline,pos,field), reportstoimport->cclreport[count].program_group =
     cnvtint(field), reportstoimport->cclreport[count].full_name = getfullreportname(reportstoimport
      ->cclreport[count].program_name,reportstoimport->cclreport[count].program_group)
     IF (pos > 0)
      pos = getnextcsvfield(csvline,pos,field), reportstoimport->cclreport[count].description = field
      IF (pos > 0)
       pos = getnextcsvfield(csvline,pos,field), reportstoimport->cclreport[count].viewer_mode =
       cnvtint(field)
      ENDIF
     ELSE
      csverrorind = 1, errormessage = build("No description field found on line=",(count+ 1))
     ENDIF
    ELSE
     csverrorind = 1, errormessage = build("No group found on line=",(count+ 1))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reportstoimport->cclreport,count)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 IF (((csverrorind=1) OR (error(errormessage,0) != 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("CSV read failed: ",errormessage)
  GO TO exit_now
 ENDIF
 IF (size(reportstoimport->cclreport,5) > 0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.cki="CKI.CODEVALUE!4101382194"
    AND cv.active_ind=1
   DETAIL
    reporttypecode = cv.code_value
   WITH nocounter
  ;end select
  IF (((error(errormessage,0) != 0) OR (curqual=0)) )
   SET readme_data->status = "F"
   SET readme_data->message = concat("Lookup failed for report type code: ",errormessage)
   GO TO exit_now
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.cki="CKI.CODEVALUE!4110840105"
    AND cv.active_ind=1
   DETAIL
    outputviewercode = cv.code_value
   WITH nocounter
  ;end select
  IF (((error(errormessage,0) != 0) OR (curqual=0)) )
   SET readme_data->status = "F"
   SET readme_data->message = concat("Lookup failed for output viewer code: ",errormessage)
   GO TO exit_now
  ENDIF
 ENDIF
 FOR (count = 1 TO size(reportstoimport->cclreport,5))
  SELECT INTO "nl:"
   d.da_report_id, d.report_uuid
   FROM da_report d
   WHERE (d.report_name=reportstoimport->cclreport[count].full_name)
    AND d.owner_prsnl_id=0
   DETAIL
    reportstoimport->cclreport[count].report_id = d.da_report_id, reportstoimport->cclreport[count].
    report_uuid = d.report_uuid, reportstoimport->cclreport[count].type_cd = d.report_type_cd
   WITH forupdate(d), nocounter
  ;end select
  IF (error(errormessage,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("DA_REPORT table check failed: ",errormessage)
   GO TO exit_now
  ELSEIF ((reportstoimport->cclreport[count].report_id != 0)
   AND (reportstoimport->cclreport[count].type_cd != reporttypecode))
   SET readme_data->status = "F"
   SET readme_data->message = concat("Report ",reportstoimport->cclreport[count].full_name,
    " exists on DA_REPORT but is not a CCL report.")
   GO TO exit_now
  ENDIF
 ENDFOR
 CALL echo(concat("*** Importing ",build(size(reportstoimport->cclreport,5))," reports"))
 FOR (count = 1 TO size(reportstoimport->cclreport,5))
   IF ((reportstoimport->cclreport[count].report_id=0.0))
    CALL echo(concat("Insert a new row for ",reportstoimport->cclreport[count].full_name))
    SELECT INTO "nl:"
     newguid = transformguid(sys_guid())
     FROM dual
     DETAIL
      uuid = newguid
     WITH nocounter
    ;end select
    INSERT  FROM da_report d
     SET d.da_report_id = seq(da_seq,nextval), d.report_uuid = uuid, d.report_name = reportstoimport
      ->cclreport[count].full_name,
      d.owner_group_cd = 0, d.owner_prsnl_id = 0, d.create_prsnl_id = 0,
      d.version_txt = versiontext, d.report_type_cd = reporttypecode, d.report_name_key =
      cnvtalphanum(reportstoimport->cclreport[count].full_name),
      d.short_desc = reportstoimport->cclreport[count].description, d.active_ind = 1, d.core_ind = 1,
      d.deprecated_ind = 0, d.extended_ind = 0, d.long_text_id = 0,
      d.filter_prompt_ind = 0, d.active_status_prsnl_id = reqinfo->updt_id, d.create_dt_tm =
      cnvtdatetime(sysdate),
      d.last_updt_dt_tm = cnvtdatetime(sysdate), d.last_updt_user_id = reqinfo->updt_id, d
      .begin_effective_dt_tm = cnvtdatetime(sysdate),
      d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), d.updt_applctx = reqinfo->
      updt_applctx, d.updt_task = reqinfo->updt_task,
      d.updt_id = reqinfo->updt_id, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate),
      d.viewer_mode_cd = evaluate(reportstoimport->cclreport[count].viewer_mode,1,outputviewercode,0,
       0)
     WITH nocounter
    ;end insert
    IF (((error(errormessage,0) != 0) OR (curqual=0)) )
     SET readme_data->status = "F"
     SET readme_data->message = concat("Could not insert row for report ",reportstoimport->cclreport[
      count].full_name,": ",errormessage)
     GO TO exit_now
    ENDIF
   ELSE
    CALL echo(concat("Update row for ",reportstoimport->cclreport[count].full_name))
    UPDATE  FROM da_report d
     SET d.short_desc = reportstoimport->cclreport[count].description, d.report_type_cd =
      reporttypecode, d.deprecated_ind = 0,
      d.extended_ind = 0, d.active_ind = 1, d.core_ind = 1,
      d.owner_prsnl_id = 0, d.active_status_prsnl_id = reqinfo->updt_id, d.last_updt_dt_tm =
      cnvtdatetime(sysdate),
      d.last_updt_user_id = reqinfo->updt_id, d.begin_effective_dt_tm = cnvtdatetime(sysdate), d
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_id = reqinfo->
      updt_id,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate), d.viewer_mode_cd = evaluate
      (reportstoimport->cclreport[count].viewer_mode,1,outputviewercode,0,0)
     WHERE (d.da_report_id=reportstoimport->cclreport[count].report_id)
     WITH nocounter
    ;end update
    IF (((error(errormessage,0) != 0) OR (curqual=0)) )
     SET readme_data->status = "F"
     SET readme_data->message = concat("Could not update row for CCL report ",reportstoimport->
      cclreport[count].full_name,": ",errormessage)
     GO TO exit_now
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(concat("*** Import complete, ",build(size(reportstoimport->cclreport,5)),
   " CCL reports imported"))
 SET readme_data->status = "S"
 SET readme_data->message = concat("All ",build(size(reportstoimport->cclreport,5)),
  " CCL reports imported successfully.")
 FREE RECORD reportstoimport
 COMMIT
 GO TO exit_now
 SUBROUTINE (getnextcsvfield(line=vc(ref),start=i4,field=vc(ref)) =i4)
   DECLARE endoftext = i4 WITH protect, noconstant(start)
   DECLARE pos = i4 WITH protect, noconstant(start)
   IF (start > textlen(line))
    SET field = ""
    RETURN(0)
   ELSEIF (substring(start,1,line)='"')
    SET pos = findstring('"',line,(start+ 1))
    WHILE (pos > 0
     AND substring((pos+ 1),1,line)='"')
      SET pos = findstring('"',line,(pos+ 2))
    ENDWHILE
    IF (pos=0)
     SET pos = textlen(line)
     SET endoftext = pos
    ELSE
     SET endoftext = (pos - 1)
     SET pos = findstring(",",line,pos)
     IF (pos=0)
      SET pos = - (1)
     ENDIF
    ENDIF
    SET start += 1
    SET field = replace(substring(start,((endoftext - start)+ 1),line),'""','"',0)
   ELSE
    SET pos = findstring(",",line,start)
    IF (pos=0)
     SET pos = - (1)
     SET endoftext = textlen(line)
    ELSE
     SET endoftext = (pos - 1)
    ENDIF
    SET field = substring(start,((endoftext - start)+ 1),line)
   ENDIF
   RETURN((pos+ 1))
 END ;Subroutine
 SUBROUTINE (getfullreportname(reportname=vc(ref),group=i4) =vc)
   IF (group=0)
    RETURN(concat(cnvtupper(reportname),":DBA"))
   ELSE
    RETURN(concat(cnvtupper(reportname),":GROUP",trim(cnvtstring(group),3)))
   ENDIF
 END ;Subroutine
 SUBROUTINE (transformguid(guid=c32) =c36)
   DECLARE frmt = c36
   SET frmt = cnvtlower(concat(substring(1,8,guid),"-",substring(9,4,guid),"-",substring(13,4,guid),
     "-",substring(17,4,guid),"-",substring(21,12,guid)))
   RETURN(frmt)
 END ;Subroutine
#exit_now
 IF ((readme_data->status != "S"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
END GO
