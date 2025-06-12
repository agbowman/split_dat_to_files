CREATE PROGRAM dash_rdm_import_wrapper:dba
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
 FREE RECORD ltr
 RECORD ltr(
   1 rec[*]
     2 id = f8
     2 new_text = vc
 )
 DECLARE logandexit(p1=vc(val)) = null WITH protect
 DECLARE log_message(p1=vc(val)) = null WITH protect
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE debug_ind = i4 WITH protect, noconstant(0)
 DECLARE filename = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locale = vc WITH protect, noconstant("")
 DECLARE locale_language = vc WITH protect, noconstant("")
 DECLARE tempdashid = f8 WITH protect, noconstant(0.0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dash_rdm_import_wrapper..."
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 80401))
  SET readme_data->status = "S"
  SET readme_data->message = "Insufficient CCL Level:  Templates NOT imported."
  GO TO exit_script
 ENDIF
 DELETE  FROM dash_filter df
  WHERE df.dash_filter_id != 0.0
   AND ((df.dash_dashboard_id IN (
  (SELECT
   dd.dash_dashboard_id
   FROM dash_dashboard dd
   WHERE dd.dashboard_template_name IN ("OR Manager Day Of Dashboard Template",
   "OR Manager Historical Dashboard Template")))) OR (df.dash_dashboard_id=0.0
   AND df.filter_template_name != "facility template"))
 ;end delete
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to empty the Filter table. ",errmsg))
 ENDIF
 DELETE  FROM dash_item_group dg
  WHERE dg.dash_item_group_id != 0.0
   AND dg.dash_dashboard_id IN (
  (SELECT
   dd.dash_dashboard_id
   FROM dash_dashboard dd
   WHERE dd.dashboard_template_name IN ("OR Manager Day Of Dashboard Template",
   "OR Manager Historical Dashboard Template")))
 ;end delete
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to empty the Item Group table. ",errmsg))
 ENDIF
 SELECT INTO "nl:"
  FROM dash_component dc,
   long_text_reference ltr
  PLAN (dc
   WHERE dc.component_template_name IN ("Number of Cases with Late Starts Day Of Template",
   "Number of Minutes Cases Started Late Day Of Template", "Case Cancelled on DOS Day Of Template",
   "Add-on Cases Day Of Template", "Add-on Cases Historical Template")
    AND dc.template_ind=0
    AND dc.active_ind=1)
   JOIN (ltr
   WHERE ltr.parent_entity_name="DASH_COMPONENT"
    AND ltr.long_text_id=dc.content_data_id)
  HEAD REPORT
   stat = alterlist(ltr->rec,10), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ltr->rec,(cnt+ 9))
   ENDIF
   ltr->rec[cnt].id = dc.content_data_id, ltr->rec[cnt].new_text = replace(ltr.long_text,"BaseChart",
    "ORGeneric")
  FOOT REPORT
   stat = alterlist(ltr->rec,cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed pulling the Component info to update ORGeneric charttype.",errmsg))
 ENDIF
 FOR (idx = 1 TO cnt)
  UPDATE  FROM long_text_reference ltr
   SET ltr.long_text = ltr->rec[idx].new_text, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ltr.updt_id = 0.0, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx
   PLAN (ltr
    WHERE ltr.parent_entity_name="DASH_COMPONENT"
     AND (ltr.long_text_id=ltr->rec[idx].id))
  ;end update
  IF (error(errmsg,0) > 0)
   CALL logandexit(concat("Failed trying to update the Components to ORGeneric charttype.",errmsg))
  ENDIF
 ENDFOR
 SET stat = alterlist(ltr->rec,0)
 SELECT INTO "nl:"
  FROM dash_component dc,
   long_text_reference ltr
  PLAN (dc
   WHERE dc.component_template_name IN ("First Case On-time Starts Day Of Template",
   "Subsequent On-time Starts Day Of Template", "First Case On-time Starts Historical Template",
   "Subsequent On-time Starts Historical Template")
    AND dc.template_ind=0
    AND dc.active_ind=1)
   JOIN (ltr
   WHERE ltr.parent_entity_name="DASH_COMPONENT"
    AND ltr.long_text_id=dc.content_data_id)
  HEAD REPORT
   stat = alterlist(ltr->rec,10), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ltr->rec,(cnt+ 9))
   ENDIF
   ltr->rec[cnt].id = dc.content_data_id, ltr->rec[cnt].new_text = replace(ltr.long_text,"BaseChart",
    "OnTimeStarts")
  FOOT REPORT
   stat = alterlist(ltr->rec,cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed pulling the Component info to update OnTimeStarts charttype.",errmsg
    ))
 ENDIF
 FOR (idx = 1 TO cnt)
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = ltr->rec[idx].new_text, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ltr.updt_id = 0.0, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo->updt_applctx
    PLAN (ltr
     WHERE ltr.parent_entity_name="DASH_COMPONENT"
      AND (ltr.long_text_id=ltr->rec[idx].id))
   ;end update
 ENDFOR
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to update the Components to OnTimeStarts charttype.",errmsg))
 ENDIF
 SET filename = "cer_install:[locale]_ORMngrDayOfDashboard.js"
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
  SET filename = "cer_install:en_us_ORMngrDayOfDashboard.js"
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
 SELECT INTO "nl:"
  FROM dash_dashboard dd
  WHERE dd.dashboard_name="OR Manager Day Of Dashboard Template"
   AND dd.template_ind=1
  DETAIL
   tempdashid = dd.dash_dashboard_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to find out if the Template is already in the system. ",
    errmsg))
 ENDIF
 IF (tempdashid > 0.0)
  EXECUTE dash_rdm_update_dashboard
 ELSE
  EXECUTE dash_rdm_import_dashboard
 ENDIF
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed: Continuing script dash_rdm_import_wrapper after OR Day of processing..."
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:[locale]_ORMngrHistoricalDashboard.js"
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
  SET filename = "cer_install:en_us_ORMngrHistoricalDashboard.js"
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
 SELECT INTO "nl:"
  FROM dash_dashboard dd
  WHERE dd.dashboard_name="OR Manager Historical Dashboard Template"
   AND dd.template_ind=1
  DETAIL
   tempdashid = dd.dash_dashboard_id
  WITH nocount
 ;end select
 IF (error(errmsg,0) > 0)
  CALL logandexit(concat("Failed trying to find out if the Template is already in the system. ",
    errmsg))
 ENDIF
 IF (tempdashid > 0.0)
  EXECUTE dash_rdm_update_dashboard
 ELSE
  EXECUTE dash_rdm_import_dashboard
 ENDIF
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed: Continuing script dash_rdm_import_wrapper after OR Hist processing..."
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:ORManDayOfDashTempMappings.json"
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
  "Readme Failed: Continuing script dash_rdm_import_wrapper after OR Day Of Mappings import..."
 ENDIF
 SET frec->file_desc = 0
 SET request->blob_in = ""
 SET filename = "cer_install:ORManHistDashTempMappings.json"
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
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 FREE RECORD frec
 FREE RECORD request
END GO
