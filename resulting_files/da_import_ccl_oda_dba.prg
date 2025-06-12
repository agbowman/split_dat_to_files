CREATE PROGRAM da_import_ccl_oda:dba
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
 SET readme_data->message = "Error starting da_import_ccl_oda"
 DECLARE csvfilename = vc WITH protect, noconstant("")
 DECLARE csvheaderline = i2 WITH protect, noconstant(0)
 DECLARE csverrorind = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errormessage = vc WITH protect, noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE csvline = vc WITH protect, noconstant("")
 DECLARE field = vc WITH protect, noconstant("")
 DECLARE activestatuscode = f8 WITH protect, noconstant(0)
 RECORD odastoimport(
   1 oda[*]
     2 program_name = vc
     2 program_group = i2
     2 oda_type = vc
     2 description = vc
     2 object_id = f8
     2 updt_cnt = i4
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
   stat = alterlist(odastoimport->oda,10), count = 0, csvheaderline = 0,
   csverrorind = 0
  DETAIL
   IF (((csvheaderline=0) OR (csverrorind=1)) )
    csvheaderline = 1
   ELSE
    count += 1
    IF (mod(count,10)=0)
     stat = alterlist(odastoimport->oda,(count+ 10))
    ENDIF
    csvline = csv.line, pos = 1, pos = getnextcsvfield(csvline,pos,field),
    odastoimport->oda[count].program_name = cnvtupper(field)
    IF (pos > 0)
     pos = getnextcsvfield(csvline,pos,field), odastoimport->oda[count].program_group = cnvtint(field
      )
     IF (pos > 0)
      pos = getnextcsvfield(csvline,pos,field), odastoimport->oda[count].oda_type = field
      IF (isvalidodatype(odastoimport->oda[count].oda_type) != 1)
       csverrorind = 1, errormessage = concat("Unknown ODA type '",field,"' on line=",build((count+ 1
         )))
      ELSEIF (pos > 0)
       pos = getnextcsvfield(csvline,pos,field), odastoimport->oda[count].description = field
      ELSE
       csverrorind = 1, errormessage = build("No description field found on line=",(count+ 1))
      ENDIF
     ELSE
      csverrorind = 1, errormessage = build("No ODA type found on line=",(count+ 1))
     ENDIF
    ELSE
     csverrorind = 1, errormessage = build("No group found on line=",(count+ 1))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(odastoimport->oda,count)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 IF (((csverrorind=1) OR (error(errormessage,0) != 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("CSV read failed: ",errormessage)
  GO TO exit_now
 ENDIF
 FOR (count = 1 TO size(odastoimport->oda,5))
  SELECT INTO "nl:"
   o.object_id, o.updt_cnt
   FROM ccl_report_object o
   WHERE (cnvtupper(o.object_name)=odastoimport->oda[count].program_name)
    AND (o.ccl_group=odastoimport->oda[count].program_group)
   DETAIL
    odastoimport->oda[count].object_id = o.object_id, odastoimport->oda[count].updt_cnt = o.updt_cnt
   WITH forupdate(o), nocounter
  ;end select
  IF (error(errormessage,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("ODA table check failed: ",errormessage)
   GO TO exit_now
  ENDIF
 ENDFOR
 CALL echo(concat("*** Importing ",build(size(odastoimport->oda,5))," ODAs"))
 IF (size(odastoimport->oda,5) > 0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.cki="CKI.CODEVALUE!2669"
    AND cv.active_ind=1
   DETAIL
    activestatuscode = cv.code_value
   WITH nocounter
  ;end select
  IF (((error(errormessage,0) != 0) OR (curqual=0)) )
   SET readme_data->status = "F"
   SET readme_data->message = concat("Lookup failed for active status code: ",errormessage)
   GO TO exit_now
  ENDIF
 ENDIF
 FOR (count = 1 TO size(odastoimport->oda,5))
   IF ((odastoimport->oda[count].object_id=0.0))
    SET field = getfullobjectname(odastoimport->oda[count].program_name,odastoimport->oda[count].
     program_group)
    CALL echo(concat("Insert a new row for ",field))
    INSERT  FROM ccl_report_object o
     SET o.object_id = seq(ccl_seq,nextval), o.object_name = odastoimport->oda[count].program_name, o
      .ccl_group = odastoimport->oda[count].program_group,
      o.object_type = odastoimport->oda[count].oda_type, o.report_name = field, o.object_description
       = odastoimport->oda[count].description,
      o.active_ind = 1, o.active_status_cd = activestatuscode, o.active_status_prsnl_id = reqinfo->
      updt_id,
      o.active_status_dt_tm = cnvtdatetime(sysdate), o.updt_applctx = reqinfo->updt_applctx, o
      .updt_task = reqinfo->updt_task,
      o.updt_id = reqinfo->updt_id, o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(sysdate)
     WITH nocounter
    ;end insert
    IF (((error(errormessage,0) != 0) OR (curqual=0)) )
     SET readme_data->status = "F"
     SET readme_data->message = concat("Could not insert row for ODA ",field,": ",errormessage)
     GO TO exit_now
    ENDIF
   ELSE
    SET field = getfullobjectname(odastoimport->oda[count].program_name,odastoimport->oda[count].
     program_group)
    CALL echo(concat("Update row for ",field))
    UPDATE  FROM ccl_report_object o
     SET o.object_type = odastoimport->oda[count].oda_type, o.report_name = field, o
      .object_description = odastoimport->oda[count].description,
      o.active_ind = 1, o.active_status_cd = activestatuscode, o.active_status_prsnl_id = reqinfo->
      updt_id,
      o.active_status_dt_tm = cnvtdatetime(sysdate), o.updt_applctx = reqinfo->updt_applctx, o
      .updt_task = reqinfo->updt_task,
      o.updt_id = reqinfo->updt_id, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(sysdate
       )
     WHERE (o.object_id=odastoimport->oda[count].object_id)
     WITH nocounter
    ;end update
    IF (((error(errormessage,0) != 0) OR (curqual=0)) )
     SET readme_data->status = "F"
     SET readme_data->message = concat("Could not update row for ODA ",field,": ",errormessage)
     GO TO exit_now
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(concat("*** Import complete, ",build(size(odastoimport->oda,5))," ODAs imported"))
 SET readme_data->status = "S"
 SET readme_data->message = concat("All ",build(size(odastoimport->oda,5)),
  " ODAs imported successfully.")
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
 SUBROUTINE (isvalidodatype(csvtype=vc) =i2)
   CASE (csvtype)
    OF "ODADSAPI":
    OF "ODATEXT":
     RETURN(1)
    ELSE
     RETURN(0)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getfullobjectname(objectname=vc(ref),group=i4) =vc)
   IF (group=0)
    RETURN(concat(cnvtupper(objectname),":DBA"))
   ELSE
    RETURN(concat(cnvtupper(objectname),":GROUP",trim(cnvtstring(group),3)))
   ENDIF
 END ;Subroutine
#exit_now
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
END GO
