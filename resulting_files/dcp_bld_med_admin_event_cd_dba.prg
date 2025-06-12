CREATE PROGRAM dcp_bld_med_admin_event_cd:dba
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
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed. Starting dcp_bld_med_admin_event_cd"
 DECLARE cmedintakealias = vc WITH protect, constant("MEDINTAKE")
 DECLARE cmedintakedisplay = vc WITH protect, constant("Med Intake")
 DECLARE cdcpgenericalias = vc WITH protect, constant("DCPGENERIC")
 DECLARE cdcpgenericdisplay = vc WITH protect, constant("DCP Generic Code")
 DECLARE bchildfailed = c1 WITH protect, noconstant("F")
 DECLARE fnextcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE calias = c20 WITH protect, noconstant("")
 DECLARE cdisplay = c20 WITH protect, noconstant("")
 DECLARE iloop = i2 WITH protect, noconstant(0)
 DECLARE fcode = f8 WITH protect, noconstant(0.0)
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c13 WITH protect, noconstant("")
 DECLARE cdfcode = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i2 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant("")
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cauthorizecd = f8 WITH public, noconstant(0.0)
 DECLARE cactivecd = f8 WITH public, noconstant(0.0)
 DECLARE cunknown23 = f8 WITH public, noconstant(0.0)
 DECLARE cunknown25 = f8 WITH public, noconstant(0.0)
 DECLARE cunknown53 = f8 WITH public, noconstant(0.0)
 DECLARE cunknown102 = f8 WITH public, noconstant(0.0)
 DECLARE crouteclinical = f8 WITH public, noconstant(0.0)
 DECLARE ccontributor = f8 WITH public, noconstant(0.0)
 SET code_set = 8
 SET cdf_meaning = "AUTH"
 EXECUTE cpm_get_cd_for_cdf
 SET cauthorizecd = code_value
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET cactivecd = code_value
 SET code_set = 23
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 SET cunknown23 = code_value
 SET code_set = 25
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 SET cunknown25 = code_value
 SET code_set = 53
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 SET cunknown53 = code_value
 SET code_set = 102
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 SET cunknown102 = code_value
 SET code_set = 87
 SET cdf_meaning = "ROUTCLINICAL"
 EXECUTE cpm_get_cd_for_cdf
 SET crouteclinical = code_value
 SET code_set = 73
 SET cdf_meaning = "POWERCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET ccontributor = code_value
 DECLARE locatecodevaluefromalias(lcodevaluealias=c20) = f8
 DECLARE locatecodefromcdf(cmeaning=c20,alias=c20) = f8
 DECLARE confirmeventcode(fcodevalue=f8) = i2
 DECLARE createeventcode(fcodevalue=f8,cdisplay=c20) = null
 DECLARE createalias(feventcd=f8,ccalias=c20) = null
 DECLARE locatecdfmeaning(lcdfalias=c20) = i2
 DECLARE createcdfmeaning(cdfalias=c20) = null
 DECLARE createcodevalue(calias=c20,addcdfmeaning=i2) = f8
 DECLARE confirmcodevalue(codevalue=f8) = null
 FOR (iloop = 1 TO 2)
   SET codevalue = 0.0
   SET fcode = 0.0
   SET cdfcode = 0.0
   IF (iloop=1)
    CALL echo(
     "*******************************Starting Steps for DCP GENERIC*************************************"
     )
    SET calias = cdcpgenericalias
    SET cdisplay = cdcpgenericdisplay
   ELSE
    CALL echo(
     "*******************************Starting Steps for MED INTAKE*************************************"
     )
    SET calias = cmedintakealias
    SET cdisplay = cmedintakedisplay
   ENDIF
   IF (calias=cdcpgenericalias)
    IF (locatecdfmeaning(calias)=0)
     CALL createcdfmeaning(calias)
    ENDIF
   ENDIF
   SET codevalue = locatecodevaluefromalias(calias)
   IF (codevalue=0.0)
    IF (calias=cdcpgenericalias)
     SET fcode = locatecodefromcdf(calias,calias)
     IF (fcode=0.0)
      SET fcode = createcodevalue(calias,1)
      CALL createalias(fcode,calias)
      CALL locatecodevaluefromalias(calias)
     ENDIF
    ELSE
     SET fcode = createcodevalue("                    ",0)
     CALL createalias(fcode,calias)
     CALL locatecodevaluefromalias(calias)
    ENDIF
   ELSE
    CALL confirmcodevalue(codevalue)
   ENDIF
 ENDFOR
#exit_script
 IF (bchildfailed="F")
  SET readme_data->status = "S"
  SET readme_data->message = "Success - All required rows were updated/inserted successfully."
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SUBROUTINE createcodevalue(ccodealias,addcdfmeaning)
   CALL echo(build("********CreateCodeValue******** = ",ccodealias))
   EXECUTE gm_code_value0619_def "I"
   DECLARE gm_i_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
   DECLARE gm_i_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
   SUBROUTINE gm_i_code_value0619_f8(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_code_value0619_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "active_type_cd":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].active_type_cd = ival
       SET gm_i_code_value0619_req->active_type_cdi = 1
      OF "data_status_cd":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].data_status_cd = ival
       SET gm_i_code_value0619_req->data_status_cdi = 1
      OF "data_status_prsnl_id":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
       SET gm_i_code_value0619_req->data_status_prsnl_idi = 1
      OF "active_status_prsnl_id":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
       SET gm_i_code_value0619_req->active_status_prsnl_idi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_code_value0619_i2(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_code_value0619_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "active_ind":
       SET gm_i_code_value0619_req->qual[iqual].active_ind = ival
       SET gm_i_code_value0619_req->active_indi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_code_value0619_i4(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_code_value0619_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "code_set":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].code_set = ival
       SET gm_i_code_value0619_req->code_seti = 1
      OF "collation_seq":
       SET gm_i_code_value0619_req->qual[iqual].collation_seq = ival
       SET gm_i_code_value0619_req->collation_seqi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_code_value0619_dq8(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_code_value0619_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "active_dt_tm":
       SET gm_i_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->active_dt_tmi = 1
      OF "inactive_dt_tm":
       SET gm_i_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->inactive_dt_tmi = 1
      OF "updt_dt_tm":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->updt_dt_tmi = 1
      OF "begin_effective_dt_tm":
       SET gm_i_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
      OF "end_effective_dt_tm":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
      OF "data_status_dt_tm":
       SET gm_i_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
       SET gm_i_code_value0619_req->data_status_dt_tmi = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SUBROUTINE gm_i_code_value0619_vc(icol_name,ival,iqual,null_ind)
     DECLARE stat = i2 WITH protect, noconstant(0)
     IF (size(gm_i_code_value0619_req->qual,5) < iqual)
      SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
      IF (stat=0)
       CALL echo("can not expand request structure")
       RETURN(0)
      ENDIF
     ENDIF
     CASE (cnvtlower(icol_name))
      OF "cdf_meaning":
       SET gm_i_code_value0619_req->qual[iqual].cdf_meaning = ival
       SET gm_i_code_value0619_req->cdf_meaningi = 1
      OF "display":
       SET gm_i_code_value0619_req->qual[iqual].display = ival
       SET gm_i_code_value0619_req->displayi = 1
      OF "description":
       SET gm_i_code_value0619_req->qual[iqual].description = ival
       SET gm_i_code_value0619_req->descriptioni = 1
      OF "definition":
       SET gm_i_code_value0619_req->qual[iqual].definition = ival
       SET gm_i_code_value0619_req->definitioni = 1
      OF "cki":
       IF (null_ind=1)
        CALL echo("error can not set this column to null")
        RETURN(0)
       ENDIF
       SET gm_i_code_value0619_req->qual[iqual].cki = ival
       SET gm_i_code_value0619_req->ckii = 1
      OF "concept_cki":
       SET gm_i_code_value0619_req->qual[iqual].concept_cki = ival
       SET gm_i_code_value0619_req->concept_ckii = 1
      ELSE
       CALL echo("invalid column name passed")
       RETURN(0)
     ENDCASE
     RETURN(1)
   END ;Subroutine
   SET gm_i_code_value0619_req->allow_partial_ind = 1
   SET gm_i_code_value0619_req->code_seti = 1
   IF (addcdfmeaning=1)
    SET gm_i_code_value0619_req->cdf_meaningi = 1
   ENDIF
   SET gm_i_code_value0619_req->displayi = 1
   SET gm_i_code_value0619_req->descriptioni = 1
   SET gm_i_code_value0619_req->definitioni = 1
   SET gm_i_code_value0619_req->active_indi = 1
   SET gm_i_code_value0619_req->active_dt_tmi = 1
   SET gm_i_code_value0619_req->active_type_cdi = 1
   SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
   SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
   SET gm_i_code_value0619_req->data_status_cdi = 1
   SET stat = alterlist(gm_i_code_value0619_req->qual,1)
   SET gm_i_code_value0619_req->qual[1].code_set = 72
   IF (addcdfmeaning=1)
    SET gm_i_code_value0619_req->qual[1].cdf_meaning = ccodealias
   ENDIF
   SET gm_i_code_value0619_req->qual[1].display = cdisplay
   SET gm_i_code_value0619_req->qual[1].description = cdisplay
   SET gm_i_code_value0619_req->qual[1].definition = cdisplay
   SET gm_i_code_value0619_req->qual[1].active_ind = 1
   SET gm_i_code_value0619_req->qual[1].active_type_cd = cactivecd
   SET gm_i_code_value0619_req->qual[1].active_dt_tm = cnvtdatetime(curdate,curtime3)
   SET gm_i_code_value0619_req->qual[1].begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET gm_i_code_value0619_req->qual[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   SET gm_i_code_value0619_req->qual[1].data_status_cd = cauthorizecd
   EXECUTE gm_i_code_value0619  WITH replace(request,gm_i_code_value0619_req), replace(reply,
    gm_i_code_value0619_rep)
   IF (trim(gm_i_code_value0619_rep->status_data.status,3)="F")
    SET readme_data->status = "F"
    SET readme_data->message = build("Readme Failed: Unable to add: ",ccodealias,
     " to the code_value table.")
    SET bchildfailed = "T"
    GO TO exit_script
   ELSE
    RETURN(gm_i_code_value0619_rep->qual[1].code_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE locatecdfmeaning(lcdfalias)
   CALL echo("********LocateCDFMeaning********")
   DECLARE icdfmeaningcheck = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    cdf.cdf_meaning
    FROM common_data_foundation cdf
    WHERE cdf.cdf_meaning=lcdfalias
     AND cdf.code_set=72
    DETAIL
     icdfmeaningcheck = (icdfmeaningcheck+ 1)
    WITH nocounter
   ;end select
   RETURN(icdfmeaningcheck)
 END ;Subroutine
 SUBROUTINE createcdfmeaning(cdfalias)
   CALL echo("********CreateCDFMeaning********")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM common_data_foundation c
    SET c.code_set = 72, c.cdf_meaning = cdfalias, c.display = cdfalias,
     c.definition = cdfalias, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = 1,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = 0, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET bchildfailed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Unable to add: ",cdfalias," cdf_meaning.  ",
     errmsg)
    GO TO exit_script
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE locatecodevaluefromalias(lcodevaluealias)
   CALL echo("********LocateCodeValueFromAlias********")
   DECLARE freturnedcodevalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value_alias cva
    WHERE cva.alias=lcodevaluealias
     AND cva.code_set=72
     AND cva.contributor_source_cd=ccontributor
    DETAIL
     freturnedcodevalue = cva.code_value
    WITH nocounter
   ;end select
   IF (freturnedcodevalue > 0.0)
    IF (confirmeventcode(freturnedcodevalue)=0)
     CALL createeventcode(freturnedcodevalue,cdisplay)
    ENDIF
   ENDIF
   RETURN(freturnedcodevalue)
 END ;Subroutine
 SUBROUTINE confirmeventcode(fcodevalue)
   CALL echo("********ConfirmEventCode********")
   DECLARE ieventcodecheck = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_code vec
    WHERE vec.event_cd=fcodevalue
    DETAIL
     ieventcodecheck = (ieventcodecheck+ 1)
    WITH nocounter
   ;end select
   RETURN(ieventcodecheck)
 END ;Subroutine
 SUBROUTINE locatecodefromcdf(cmeaning,alias)
   CALL echo("********LocateCodeFromCDF********")
   DECLARE fcodevalue = f8 WITH protect, noconstant(0.0)
   DECLARE cdisplay = c20 WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=72
      AND cv.cdf_meaning=cmeaning)
    DETAIL
     fcodevalue = cv.code_value, cdisplay = cv.display
    WITH nocounter
   ;end select
   IF (fcodevalue > 0.0)
    IF (locatecodevaluefromalias(alias)=0.0)
     CALL createalias(fcodevalue,alias)
     CALL locatecodevaluefromalias(alias)
    ENDIF
   ENDIF
   RETURN(fcodevalue)
 END ;Subroutine
 SUBROUTINE createeventcode(fcodevalue,cdisplay)
   CALL echo("********CreateEventCode********")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM v500_event_code v
    SET v.event_cd = fcodevalue, v.event_cd_definition = cdisplay, v.event_cd_descr = cnvtupper(
      cdisplay),
     v.event_cd_disp = cnvtupper(cdisplay), v.event_cd_disp_key = cnvtalphanum(cnvtupper(cdisplay)),
     v.code_status_cd = cactivecd,
     v.def_docmnt_attributes = " ", v.def_docmnt_format_cd = cunknown23, v.def_docmnt_storage_cd =
     cunknown25,
     v.def_event_class_cd = cunknown53, v.def_event_confid_level_cd = crouteclinical, v
     .def_event_level = 0,
     v.event_add_access_ind = 0, v.event_cd_subclass_cd = cunknown102, v.event_chg_access_ind = 0,
     v.event_set_name = null, v.retention_days = 0, v.updt_applctx = 0,
     v.updt_cnt = 0, v.updt_dt_tm = cnvtdatetime(curdate,curtime), v.updt_id = 0,
     v.updt_task = reqinfo->updt_task, v.event_code_status_cd = cauthorizecd
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET bchildfailed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Unable to add: ",cdisplay,
     " to v500_event_code  ",errmsg)
    GO TO exit_script
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE createalias(feventcd,ccalias)
   CALL echo("********CreateAlias********")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM code_value_alias cva
    SET cva.code_set = 72, cva.code_value = feventcd, cva.alias = ccalias,
     cva.alias_type_meaning = ccalias, cva.contributor_source_cd = ccontributor, cva.primary_ind = 1,
     cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_id = 0, cva.updt_task = reqinfo->
     updt_task,
     cva.updt_cnt = 1, cva.updt_applctx = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET bchildfailed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Unable to add: ",ccalias,
     " to code_value_alias  ",errmsg)
    GO TO exit_script
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE confirmcodevalue(codevalue)
   CALL echo("********ConfirmCodeValue*********")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=codevalue
     AND cv.code_set=72
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET bchildfailed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = build("Readme Failed: Code Value: ",codevalue,
     " missing on the code_value table")
    GO TO exit_script
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SET last_mod = "7/31/06 001"
END GO
