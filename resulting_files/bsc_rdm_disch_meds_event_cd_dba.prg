CREATE PROGRAM bsc_rdm_disch_meds_event_cd:dba
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
 SET readme_data->message = "Readme Failed. Starting bsc_rdm_disch_meds_event_cd"
 DECLARE cdischargemedsdisplay = c20 WITH protect, constant("Discharge Medications")
 DECLARE fcode = f8 WITH protect, noconstant(0.0)
 DECLARE fcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE lastmod = c13 WITH protect, noconstant("")
 DECLARE errorcode = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH public, noconstant(" ")
 DECLARE codevalexisting = i2 WITH protect, noconstant(0)
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
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select AUTH for 8 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cauthorizecd = code_value
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select ACTIVE for 48 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cactivecd = code_value
 SET code_set = 23
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select UNKNOWN for 23 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cunknown23 = code_value
 SET code_set = 25
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select UNKNOWN for 25 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cunknown25 = code_value
 SET code_set = 53
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select UNKNOWN for 53 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cunknown53 = code_value
 SET code_set = 102
 SET cdf_meaning = "UNKNOWN"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select UNKNOWN for 102 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET cunknown102 = code_value
 SET code_set = 87
 SET cdf_meaning = "ROUTCLINICAL"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select ROUTCLINICAL for 87 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET crouteclinical = code_value
 SET code_set = 73
 SET cdf_meaning = "POWERCHART"
 EXECUTE cpm_get_cd_for_cdf
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select POWERCHART for 73 : ",errmsg)
  GO TO exit_script
 ENDIF
 SET ccontributor = code_value
 DECLARE codevalueexists(null) = i2
 DECLARE createcodevalue(null) = null
 DECLARE verifycodevalue(null) = f8
 DECLARE confirmeventcode(fcodevalue=f8) = i2
 DECLARE createeventcode(fcodevalue=f8) = null
 DECLARE confirmcodevalue(fcodevalue=f8) = null
 SET codevalexisting = codevalueexists(null)
 IF (codevalexisting != 1)
  CALL createcodevalue(null)
  SET fcode = verifycodevalue(null)
  IF (fcode > 0.0)
   IF (confirmeventcode(fcode)=0)
    CALL createeventcode(fcode)
    CALL confirmcodevalue(fcode)
   ENDIF
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme auto-successed: Code value already exists."
  GO TO exit_script
 ENDIF
 SUBROUTINE codevalueexists(null)
   CALL echo("********CodeValueExists*********")
   DECLARE icodecheck = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.concept_cki="CERNER!603C84D8-624F-40F6-B86B-C0D78D449A94"
     AND cv.code_set=72
     AND cv.active_ind=1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from CodeValueExists subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual != 0)
    SET icodecheck = 1
   ENDIF
   RETURN(icodecheck)
 END ;Subroutine
 SUBROUTINE createcodevalue(null)
   CALL echo("********CreateCodeValue********")
   INSERT  FROM code_value c
    SET c.code_set = 72, c.code_value = seq(reference_seq,nextval), c.display = cdischargemedsdisplay,
     c.display_key = cnvtalphanum(cnvtupper(cdischargemedsdisplay)), c.description =
     cdischargemedsdisplay, c.definition = cdischargemedsdisplay,
     c.active_ind = 1, c.active_type_cd = cactivecd, c.active_dt_tm = cnvtdatetime(curdate,curtime3),
     c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), c.data_status_cd = cauthorizecd,
     c.concept_cki = "CERNER!603C84D8-624F-40F6-B86B-C0D78D449A94"
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from CreateCodeValue subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = build("Readme Failed: Unable to add ",cdischargemedsdisplay,
     " to code_value")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE verifycodevalue(null)
   CALL echo("********VerifyCodeValue********")
   DECLARE freturnedcodevalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=72
     AND cv.active_ind=1
     AND cv.concept_cki="CERNER!603C84D8-624F-40F6-B86B-C0D78D449A94"
    DETAIL
     freturnedcodevalue = cv.code_value
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from VerifyCodeValue subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = build(
     "Readme Failed: Code value for Discharge Meds missing from code_value table.")
    GO TO exit_script
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
     ieventcodecheck = 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from ConfirmEventCode subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(ieventcodecheck)
 END ;Subroutine
 SUBROUTINE createeventcode(fcodevalue)
   CALL echo("********CreateEventCode********")
   INSERT  FROM v500_event_code v
    SET v.event_cd = fcodevalue, v.event_cd_definition = cdischargemedsdisplay, v.event_cd_descr =
     cnvtupper(cdischargemedsdisplay),
     v.event_cd_disp = cnvtupper(cdischargemedsdisplay), v.event_cd_disp_key = cnvtalphanum(cnvtupper
      (cdischargemedsdisplay)), v.code_status_cd = cactivecd,
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
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from CreateEventCode subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = build("Readme Failed: Unable to add ",cdischargemedsdisplay,
     " to v500_event_code")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE confirmcodevalue(fcodevalue)
   CALL echo("********ConfirmCodeValue*********")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=fcodevalue
     AND cv.code_set=72
     AND cv.active_ind=1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Readme Failed: Query from ConfirmCodeValue subroutine failed to execute: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = build("Readme Failed: Code Value: ",fcodevalue,
     " missing on the code_value table")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success - bsc_rdm_disch_meds_event_cd.prg inserted all required rows successfully."
 CALL echo(build("***************message : ",readme_data->message))
 COMMIT
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET lastmod = "02/12/2014 000"
END GO
