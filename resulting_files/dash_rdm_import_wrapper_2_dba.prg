CREATE PROGRAM dash_rdm_import_wrapper_2:dba
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
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD request
 RECORD request(
   1 blob_in = gvc
 )
 DECLARE logandexit(p1=vc(val)) = null WITH protect
 DECLARE log_message(p1=vc(val)) = null WITH protect
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE debug_ind = i4 WITH protect, noconstant(0)
 DECLARE filename = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locale = vc WITH protect, noconstant("")
 DECLARE locale_language = vc WITH protect, noconstant("")
 DECLARE tempdashid = f8 WITH protect, noconstant(0.0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dash_rdm_import_wrapper_2..."
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 80401))
  SET readme_data->status = "S"
  SET readme_data->message = "Insufficient CCL Level:  Templates NOT imported."
  GO TO exit_script
 ENDIF
 SET filename = "cer_install:[locale]_AnesthesiaDashboard.js"
 SET locale = trim(cnvtlower(logical("CCL_LANG")))
 IF (locale="")
  SET locale = trim(cnvtlower(logical("LANG")))
  SET idx = findstring(".",locale,1,0)
  IF (idx > 0)
   SET locale = substring(1,(idx - 1),locale)
  ENDIF
 ENDIF
 SET locale_language = substring(1,2,locale)
 IF (((locale_language="en") OR (locale_language="pt")) )
  SET filename = replace(filename,"[locale]",locale)
 ELSEIF (locale_language != "")
  SET filename = replace(filename,"[locale]",locale_language)
 ELSE
  SET filename = replace(filename,"[locale]","en_us")
 ENDIF
 CALL log_message(concat("Localized file name: ",filename))
 SET frec->file_name = filename
 SET frec->file_buf = "r"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = notrim(fillstring(100000," "))
 IF ((frec->file_desc != 0))
  SET stat = cclio("READ",frec)
 ENDIF
 SET stat = cclio("CLOSE",frec)
 IF ( NOT ((frec->file_buf > " ")))
  SET filename = "cer_install:en_us_AnesthesiaDashboard.js"
  SET frec->file_name = filename
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = notrim(fillstring(100000," "))
  IF ((frec->file_desc != 0))
   SET stat = cclio("READ",frec)
  ENDIF
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF ( NOT ((frec->file_buf > " ")))
  CALL log_message(concat("File ",filename," was not Found."))
  SET readme_data->status = "F"
  SET readme_data->message = concat("File ",filename," was not Found. ",errmsg)
  GO TO exit_script
 ENDIF
 SET request->blob_in = frec->file_buf
 SET tempdashid = 0.0
 SELECT INTO "nl:"
  FROM dash_dashboard dd
  WHERE dd.dashboard_name="Anesthesia Dashboard Template"
   AND dd.template_ind=1
  DETAIL
   tempdashid = dd.dash_dashboard_id
  WITH nocount
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to find out if the Template is already in the system. ",
    errmsg))
 ENDIF
 IF (tempdashid=0.0)
  EXECUTE dash_rdm_import_dashboard
  IF ((readme_data->status != "S"))
   GO TO exit_script
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message =
   "Readme Failed: Continuing script dash_rdm_import_wrapper_2 after Anesthesia processing..."
  ENDIF
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:[locale]_GIHistoricalDashboard.js"
 SET locale_language = substring(1,2,locale)
 IF (((locale_language="en") OR (locale_language="pt")) )
  SET filename = replace(filename,"[locale]",locale)
 ELSEIF (locale_language != "")
  SET filename = replace(filename,"[locale]",locale_language)
 ELSE
  SET filename = replace(filename,"[locale]","en_us")
 ENDIF
 CALL log_message(concat("Localized file name: ",filename))
 SET frec->file_name = filename
 SET frec->file_buf = "r"
 SET stat = cclio("OPEN",frec)
 CALL log_message(cnvtstring(frec->file_desc))
 SET frec->file_buf = notrim(fillstring(100000," "))
 IF ((frec->file_desc != 0))
  SET stat = cclio("READ",frec)
 ENDIF
 SET stat = cclio("CLOSE",frec)
 IF ( NOT ((frec->file_buf > " ")))
  SET filename = "cer_install:en_us_GIHistoricalDashboard.js"
  SET frec->file_name = filename
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = notrim(fillstring(100000," "))
  IF ((frec->file_desc != 0))
   SET stat = cclio("READ",frec)
  ENDIF
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF ( NOT ((frec->file_buf > " ")))
  CALL log_message(concat("File ",filename," was not Found."))
  SET readme_data->status = "F"
  SET readme_data->message = concat("File ",filename," was not Found. ",errmsg)
  GO TO exit_script
 ENDIF
 SET request->blob_in = frec->file_buf
 SET tempdashid = 0.0
 SELECT INTO "nl:"
  FROM dash_dashboard dd
  WHERE dd.dashboard_name="GI CQD Historical Dashboard Template"
   AND dd.template_ind=1
  DETAIL
   tempdashid = dd.dash_dashboard_id
  WITH nocount
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to find out if the Template is already in the system. ",
    errmsg))
 ENDIF
 IF (tempdashid=0.0)
  EXECUTE dash_rdm_import_dashboard
  IF ((readme_data->status != "S"))
   GO TO exit_script
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message =
   "Readme Failed: Continuing script dash_rdm_import_wrapper_2 after GI CQD processing..."
  ENDIF
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:AnesDashTempMappings.json"
 SET frec->file_name = filename
 SET frec->file_buf = "r"
 SET stat = cclio("OPEN",frec)
 CALL log_message(cnvtstring(frec->file_desc))
 SET frec->file_buf = notrim(fillstring(100000," "))
 IF ((frec->file_desc != 0))
  SET stat = cclio("READ",frec)
 ENDIF
 SET stat = cclio("CLOSE",frec)
 IF ( NOT ((frec->file_buf > " ")))
  CALL log_message(concat("File ",filename," was not Found."))
  SET readme_data->status = "F"
  SET readme_data->message = concat("File ",filename," was not Found. ",errmsg)
  GO TO exit_script
 ENDIF
 SET request->blob_in = frec->file_buf
 EXECUTE dash_rdm_import_mappings
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed: Continuing script dash_rdm_import_wrapper_2 after Anesthesia Mappings import..."
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:GIHistDashTempMappings.json"
 SET frec->file_name = filename
 SET frec->file_buf = "r"
 SET stat = cclio("OPEN",frec)
 CALL log_message(cnvtstring(frec->file_desc))
 SET frec->file_buf = notrim(fillstring(100000," "))
 IF ((frec->file_desc != 0))
  SET stat = cclio("READ",frec)
 ENDIF
 SET stat = cclio("CLOSE",frec)
 IF ( NOT ((frec->file_buf > " ")))
  CALL log_message(concat("File ",filename," was not Found."))
  SET readme_data->status = "F"
  SET readme_data->message = concat("File ",filename," was not Found. ",errmsg)
  GO TO exit_script
 ENDIF
 SET request->blob_in = frec->file_buf
 EXECUTE dash_rdm_import_mappings
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succedded"
 ENDIF
 SUBROUTINE logandexit(message)
   ROLLBACK
   CALL log_message(message)
   SET readme_data->status = "F"
   SET readme_data->message = message
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE log_message(message)
   IF (validate(debug_ind,0)=1)
    CALL echo(message)
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD frec
 FREE RECORD request
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
