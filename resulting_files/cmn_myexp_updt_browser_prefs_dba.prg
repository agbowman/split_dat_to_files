CREATE PROGRAM cmn_myexp_updt_browser_prefs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Run Mode (0-Audit configurations, 1-Update configurations)" = 0
  WITH outdev, runmode
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD audit_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::getmyexpviewdata(null) = null WITH protect
 DECLARE PUBLIC::updatenamevalueprefs(null) = null WITH protect
 DECLARE PUBLIC::insertedgebrowserprefs(null) = null WITH protect
 DECLARE PUBLIC::insertnamevalueprefs(view_prefs_id=f8) = null WITH protect
 DECLARE PUBLIC::getreport(null) = null WITH protect
 FREE RECORD view_data
 RECORD view_data(
   1 ie_browser_qual[*]
     2 position_cd = f8
     2 application_name = vc
     2 name_value_prefs_id = f8
     2 view_caption = vc
   1 default_browser_qual[*]
     2 position_cd = f8
     2 application_name = vc
     2 view_prefs_id = f8
     2 view_caption = vc
 ) WITH protect
 DECLARE str_web_browser_selection = vc WITH protect, constant("WEB_BROWSER_SELECTION")
 DECLARE str_view_prefs = vc WITH protect, constant("VIEW_PREFS")
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   CALL echo("Starting cmn_myexp_updt_browser_prefs")
   SET audit_reply->status_data.status = "F"
   IF (validate(xxcclseclogin->loggedin) > 0)
    IF ((xxcclseclogin->loggedin != 1))
     SET audit_reply->status_data.subeventstatus.targetobjectvalue =
     "User is not logged into secure CCL session."
     GO TO exit_script
    ENDIF
   ENDIF
   CALL getmyexpviewdata(null)
   IF (( $RUNMODE=1))
    IF (size(view_data->ie_browser_qual,5) > 0)
     CALL updatenamevalueprefs(null)
    ENDIF
    IF (size(view_data->default_browser_qual,5) > 0)
     CALL insertedgebrowserprefs(null)
    ENDIF
    SET reqinfo->commit_ind = 1
   ENDIF
   CALL getreport(null)
   SET audit_reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE PUBLIC::getmyexpviewdata(null)
   DECLARE pref_cnt = i4 WITH protect, noconstant(0)
   DECLARE view_cnt = i4 WITH protect, noconstant(0)
   DECLARE str_view_caption = vc WITH protect, constant("VIEW_CAPTION")
   DECLARE str_myexp_driver = vc WITH protect, constant("pex_mp_myexp_user_driver")
   DECLARE str_discernrpt = vc WITH protect, constant("DISCERNRPT")
   DECLARE str_report_name = vc WITH protect, constant("REPORT_NAME")
   DECLARE str_detail_prefs = vc WITH protect, constant("DETAIL_PREFS")
   DECLARE str_org_frame = vc WITH protect, constant("ORG")
   DECLARE str_ie_browser_value = vc WITH protect, constant("0")
   SELECT INTO "nl:"
    FROM view_prefs vp,
     (left JOIN name_value_prefs nvp2 ON nvp2.parent_entity_id=vp.view_prefs_id
      AND nvp2.parent_entity_name=str_view_prefs
      AND nvp2.pvc_name=str_web_browser_selection
      AND nvp2.active_ind=1),
     (left JOIN name_value_prefs nvp3 ON nvp3.parent_entity_id=vp.view_prefs_id
      AND nvp3.parent_entity_name=str_view_prefs
      AND nvp3.pvc_name=str_view_caption
      AND nvp3.active_ind=1),
     detail_prefs dp,
     name_value_prefs nvp,
     application ap
    PLAN (nvp
     WHERE nvp.pvc_name=str_report_name
      AND cnvtlower(nvp.pvc_value)=str_myexp_driver
      AND nvp.parent_entity_name=str_detail_prefs
      AND nvp.active_ind=1)
     JOIN (dp
     WHERE dp.view_name=str_discernrpt
      AND dp.comp_name=str_discernrpt
      AND dp.prsnl_id=0.0
      AND dp.active_ind=1
      AND dp.detail_prefs_id=nvp.parent_entity_id)
     JOIN (vp
     WHERE vp.view_name=str_discernrpt
      AND vp.frame_type=str_org_frame
      AND vp.prsnl_id=0.0
      AND vp.active_ind=1
      AND vp.view_seq=dp.view_seq
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=dp.application_number)
     JOIN (ap
     WHERE ap.application_number=vp.application_number
      AND ap.active_ind=1)
     JOIN (nvp2)
     JOIN (nvp3)
    ORDER BY dp.position_cd
    DETAIL
     IF (textlen(trim(nvp2.pvc_name))=0)
      view_cnt = (view_cnt+ 1), stat = alterlist(view_data->default_browser_qual,view_cnt), view_data
      ->default_browser_qual[view_cnt].view_prefs_id = vp.view_prefs_id,
      view_data->default_browser_qual[view_cnt].position_cd = vp.position_cd, view_data->
      default_browser_qual[view_cnt].application_name = ap.description, view_data->
      default_browser_qual[view_cnt].view_caption = nvp3.pvc_value
     ELSEIF (nvp2.pvc_value=str_ie_browser_value)
      pref_cnt = (pref_cnt+ 1), stat = alterlist(view_data->ie_browser_qual,pref_cnt), view_data->
      ie_browser_qual[pref_cnt].name_value_prefs_id = nvp2.name_value_prefs_id,
      view_data->ie_browser_qual[pref_cnt].position_cd = dp.position_cd, view_data->ie_browser_qual[
      pref_cnt].application_name = ap.description, view_data->ie_browser_qual[pref_cnt].view_caption
       = nvp3.pvc_value
     ENDIF
    WITH nocounter
   ;end select
   CALL errorcheck(audit_reply,"GetMyExpViewData")
 END ;Subroutine
 SUBROUTINE PUBLIC::updatenamevalueprefs(null)
   DECLARE nvp_idx = i4 WITH protect, noconstant(0)
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = "1", nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp.updt_cnt+
     1),
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task
    WHERE expand(nvp_idx,1,size(view_data->ie_browser_qual,5),nvp.name_value_prefs_id,view_data->
     ie_browser_qual[nvp_idx].name_value_prefs_id)
    WITH nocounter
   ;end update
   CALL errorcheck(audit_reply,"UpdateNameValuePrefs")
 END ;Subroutine
 SUBROUTINE PUBLIC::insertedgebrowserprefs(null)
   FOR (idx = 1 TO size(view_data->default_browser_qual,5))
     CALL insertnamevalueprefs(view_data->default_browser_qual[idx].view_prefs_id)
   ENDFOR
 END ;Subroutine
 SUBROUTINE PUBLIC::insertnamevalueprefs(view_prefs_id)
   DECLARE name_value_prefs_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    x = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(x)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.active_ind = 1, nvp.parent_entity_id =
     view_prefs_id,
     nvp.parent_entity_name = str_view_prefs, nvp.pvc_name = str_web_browser_selection, nvp.pvc_value
      = "1",
     nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ),
     nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL errorcheck(audit_reply,"InsertNameValuePrefs")
 END ;Subroutine
 SUBROUTINE PUBLIC::getreport(null)
   DECLARE soutput = vc WITH protect, noconstant("")
   DECLARE message = vc WITH protect, noconstant("")
   DECLARE tabledata = vc WITH protect, noconstant("")
   DECLARE viewcaption = vc WITH protect, noconstant("")
   DECLARE position = vc WITH protect, noconstant("")
   DECLARE str_global_preference = vc WITH protect, constant("*Global Preference*")
   SET soutput = build2(
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
    "<html>","<head>","<title>MyExperience Web Browser Preferences Audit</title>",
    '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />',
    '<meta http-equiv="X-UA-Compatible" content="IE=edge" />',
    "<html><head><title>Data List</title></head><body>","<table border='0' width='100%'>")
   SET tabledata = build2(tabledata,"<tr>")
   SET tabledata = build2(tabledata,"<td>","<B>Application Name</B>","</td>")
   SET tabledata = build2(tabledata,"<td>","<B>Position</B>","</td>")
   SET tabledata = build2(tabledata,"<td>","<B>Tab Name</B>","</td>")
   SET tabledata = build2(tabledata,"</tr>")
   FOR (idx = 1 TO value(size(view_data->ie_browser_qual,5)))
     IF ((view_data->ie_browser_qual[idx].position_cd=0.0))
      SET position = str_global_preference
     ELSE
      SET position = uar_get_code_display(view_data->ie_browser_qual[idx].position_cd)
     ENDIF
     SET tabledata = build2(tabledata,"<tr>")
     SET tabledata = build2(tabledata,"<td>",view_data->ie_browser_qual[idx].application_name,"</td>"
      )
     SET tabledata = build2(tabledata,"<td>",position,"</td>")
     SET tabledata = build2(tabledata,"<td>",view_data->ie_browser_qual[idx].view_caption,"</td>")
     SET tabledata = build2(tabledata,"</tr>")
   ENDFOR
   FOR (idx = 1 TO value(size(view_data->default_browser_qual,5)))
     IF ((view_data->default_browser_qual[idx].position_cd=0.0))
      SET position = str_global_preference
     ELSE
      SET position = uar_get_code_display(view_data->default_browser_qual[idx].position_cd)
     ENDIF
     SET tabledata = build2(tabledata,"<tr>")
     SET tabledata = build2(tabledata,"<td>",view_data->default_browser_qual[idx].application_name,
      "</td>")
     SET tabledata = build2(tabledata,"<td>",position,"</td>")
     SET tabledata = build2(tabledata,"<td>",view_data->default_browser_qual[idx].view_caption,
      "</td>")
     SET tabledata = build2(tabledata,"</tr>")
   ENDFOR
   IF (((size(view_data->ie_browser_qual,5) > 0) OR (size(view_data->default_browser_qual,5) > 0)) )
    IF (( $RUNMODE=1))
     SET message =
     "<p>The MyExperience preferences for the above positions were updated to use Edge as the Web Browser.</p>"
    ELSE
     SET message =
     "<p>The MyExperience preferences for the above positions are using IE as the Web Browser.</p>"
    ENDIF
   ELSE
    SET message = "<p>No MyExperience preferences found that are using IE as the Web Browser.</p>"
   ENDIF
   SET _memory_reply_string = build2(soutput,tabledata,"</table>",message,"</body></html>")
 END ;Subroutine
#exit_script
 CALL echorecord(audit_reply)
END GO
