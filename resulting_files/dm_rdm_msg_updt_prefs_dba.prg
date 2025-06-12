CREATE PROGRAM dm_rdm_msg_updt_prefs:dba
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
 SET readme_data->message = "Readme failed: Starting dm_rdm_msg_updt_prefs..."
 FREE RECORD report_param
 RECORD report_param(
   1 params[*]
     2 param_value = vc
 ) WITH protect
 FREE RECORD edge_browser_tabs
 RECORD edge_browser_tabs(
   1 tabs[*]
     2 edge_browser_pref_id = f8
 ) WITH protect
 FREE RECORD html_tabs
 RECORD html_tabs(
   1 tabs[*]
     2 report_param_pref_id = f8
     2 report_name_pref_id = f8
     2 new_report_name_str = vc
 ) WITH protect
 FREE RECORD insert_web_pref
 RECORD insert_web_pref(
   1 tabs[*]
     2 parent_entity_id = f8
 ) WITH protect
 FREE RECORD mc_discern_tabs
 RECORD mc_discern_tabs(
   1 tabs[*]
     2 report_name_pref_id = f8
     2 new_report_name_str = vc
 ) WITH protect
 DECLARE PUBLIC::getwebbrowsertabs(null) = null WITH protect
 DECLARE PUBLIC::updatewebbrowsertabs(null) = null WITH protect
 DECLARE PUBLIC::gethtmltabs(null) = null WITH protect
 DECLARE PUBLIC::updthtmltabs(null) = null WITH protect
 DECLARE PUBLIC::insertwebprefs(null) = null WITH protect
 DECLARE PUBLIC::docommit(null) = null WITH protect
 DECLARE PUBLIC::main(null) = null WITH protect
 DECLARE PUBLIC::getmcdiscerntabs(null) = null WITH protect
 DECLARE PUBLIC::updturl(null) = null WITH protect
 DECLARE newurl = vc WITH protect, noconstant("")
 DECLARE reportname = vc WITH protect, noconstant("")
 DECLARE reportparamvalue = vc WITH protect, noconstant("")
 SUBROUTINE PUBLIC::getwebbrowsertabs(null)
   DECLARE tabidx = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant("")
   DECLARE insertcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM name_value_prefs n1,
     detail_prefs d,
     view_prefs v,
     name_value_prefs n2
    PLAN (n1
     WHERE n1.pvc_name="REPORT_NAME"
      AND ((n1.pvc_value="mp_unified_org_driver") OR (n1.pvc_value="mp_unified_driver")) )
     JOIN (d
     WHERE d.detail_prefs_id=n1.parent_entity_id
      AND ((d.view_name="HOMEVIEW") OR (d.view_name="MCDISCERNRPT")) )
     JOIN (v
     WHERE v.view_name=d.view_name
      AND v.view_seq=d.view_seq
      AND v.application_number=d.application_number
      AND v.position_cd=d.position_cd)
     JOIN (n2
     WHERE (n2.parent_entity_id= Outerjoin(v.view_prefs_id))
      AND (n2.pvc_name= Outerjoin("WEB_BROWSER_SELECTION")) )
    DETAIL
     tabidx += 1, stat = alterlist(edge_browser_tabs->tabs,tabidx)
     IF (n2.name_value_prefs_id > 0)
      edge_browser_tabs->tabs[tabidx].edge_browser_pref_id = n2.name_value_prefs_id
     ELSE
      insertcnt += 1, stat = alterlist(insert_web_pref->tabs,insertcnt), insert_web_pref->tabs[
      insertcnt].parent_entity_id = v.view_prefs_id
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed: retrieving web browser tab configurations - ",
     errmsg)
    GO TO exit_script
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(edge_browser_tabs)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::updatewebbrowsertabs(null)
   DECLARE tabcnt = i4 WITH protect, constant(size(edge_browser_tabs->tabs,5))
   DECLARE errmsg = c132 WITH protect, noconstant("")
   IF (size(edge_browser_tabs->tabs,5)=0)
    RETURN(null)
   ENDIF
   UPDATE  FROM name_value_prefs n,
     (dummyt d  WITH seq = value(tabcnt))
    SET n.pvc_value = "1", n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = (n.updt_cnt+ 1),
     n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE d.seq <= value(tabcnt)
      AND (edge_browser_tabs->tabs[d.seq].edge_browser_pref_id > 0))
     JOIN (n
     WHERE (n.name_value_prefs_id=edge_browser_tabs->tabs[d.seq].edge_browser_pref_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed: setting web browser to Edge- ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::gethtmltabs(null)
   DECLARE tabidx = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant("")
   DECLARE insertcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM name_value_prefs n1,
     name_value_prefs n2,
     detail_prefs d
    PLAN (n1
     WHERE n1.pvc_name="REPORT_NAME"
      AND ((n1.pvc_value="mp_unified_org_driver") OR (n1.pvc_value="mp_unified_driver")) )
     JOIN (n2
     WHERE n1.parent_entity_id=n2.parent_entity_id
      AND n2.pvc_name="REPORT_PARAM")
     JOIN (d
     WHERE d.detail_prefs_id=n1.parent_entity_id
      AND d.view_name IN ("HOMEVIEW", "MCDISCERNRPT"))
    DETAIL
     tabidx += 1, stat = alterlist(html_tabs->tabs,tabidx), reportparamvalue = n2.pvc_value,
     newurl = ""
     IF (textlen(trim(reportparamvalue)) > 0)
      index = 1, paramcount = arraysplit(report_param->params[index].param_value,index,
       reportparamvalue,",",2)
      IF (((paramcount=6) OR (paramcount=7)) )
       viewpointname = report_param->params[6].param_value, staticcontentlocation = report_param->
       params[5].param_value
       IF (paramcount=7)
        debugindicator = report_param->params[7].param_value
       ELSE
        debugindicator = ""
       ENDIF
       newurl = build("<url>$DM_INFO:CONTENT_SERVICE_URL$/mp-content/idx.html?m=",
        "^ORG^&uId=$USR_PERSONID$&pCd=$USR_PositionCd$&app=^$APP_AppName$^&vId=",viewpointname)
      ELSEIF (((paramcount=9) OR (paramcount=10)) )
       viewpointname = report_param->params[9].param_value, staticcontentlocation = report_param->
       params[8].param_value
       IF (paramcount=10)
        debugindicator = report_param->params[10].param_value
       ELSE
        debugindicator = ""
       ENDIF
       newurl = build("<url>$DM_INFO:CONTENT_SERVICE_URL$/mp-content/idx.html?m=",
        "^CHT^&pId=$PAT_PERSONID$&eId=$VIS_ENCNTRID$&uId=$USR_PERSONID$",
        "&pCd=$USR_PositionCd$&ppr=$PAT_PPRCode$&app=^$APP_AppName$^&vId=",viewpointname)
      ENDIF
      IF (staticcontentlocation != "")
       newurl = build(newurl,"&sLoc=",staticcontentlocation)
      ENDIF
      IF (debugindicator != "")
       newurl = build(newurl,"&dbg=",debugindicator)
      ENDIF
     ENDIF
     IF (size(newurl,1) < 255
      AND size(newurl,1) > 0)
      html_tabs->tabs[tabidx].report_name_pref_id = n1.name_value_prefs_id, html_tabs->tabs[tabidx].
      report_param_pref_id = n2.name_value_prefs_id, html_tabs->tabs[tabidx].new_report_name_str =
      newurl
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed retrieving reportName and reportParams",errmsg)
    GO TO exit_script
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(html_tabs)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::updthtmltabs(null)
   DECLARE tabcnt = i4 WITH protect, constant(size(html_tabs->tabs,5))
   DECLARE errmsg = c132 WITH protect, noconstant("")
   IF (size(html_tabs->tabs,5)=0)
    RETURN(null)
   ENDIF
   UPDATE  FROM name_value_prefs n,
     (dummyt d  WITH seq = value(tabcnt))
    SET n.pvc_value = html_tabs->tabs[d.seq].new_report_name_str, n.updt_applctx = reqinfo->
     updt_applctx, n.updt_cnt = (n.updt_cnt+ 1),
     n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE d.seq <= value(tabcnt))
     JOIN (n
     WHERE (n.name_value_prefs_id=html_tabs->tabs[d.seq].report_name_pref_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed: setting report_name and report_param - ",errmsg
     )
    GO TO exit_script
   ENDIF
   UPDATE  FROM name_value_prefs n,
     (dummyt d  WITH seq = value(tabcnt))
    SET n.pvc_value = "", n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = (n.updt_cnt+ 1),
     n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE d.seq <= value(tabcnt))
     JOIN (n
     WHERE (n.name_value_prefs_id=html_tabs->tabs[d.seq].report_param_pref_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed: setting report_name and report_param - ",errmsg
     )
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertwebprefs(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM name_value_prefs nvp,
     (dummyt d  WITH seq = value(size(insert_web_pref->tabs,5)))
    SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "VIEW_PREFS",
     nvp.pvc_name = "WEB_BROWSER_SELECTION",
     nvp.pvc_value = "1", nvp.parent_entity_id = insert_web_pref->tabs[d.seq].parent_entity_id, nvp
     .updt_task = reqinfo->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 1, nvp.updt_id = reqinfo->updt_id,
     nvp.updt_dt_tm = cnvtdatetime(sysdate), nvp.active_ind = 1
    PLAN (d)
     JOIN (nvp)
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Insert Failed: setting HOMEVIEW and MCDISCERNRPT tab web browser selection - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::getmcdiscerntabs(null)
   DECLARE tabidx = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant("")
   DECLARE insertcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM name_value_prefs n1,
     name_value_prefs n2,
     detail_prefs d
    PLAN (n1
     WHERE n1.pvc_name="REPORT_PARAM"
      AND n1.pvc_value="")
     JOIN (n2
     WHERE n1.parent_entity_id=n2.parent_entity_id
      AND n2.pvc_name="REPORT_NAME")
     JOIN (d
     WHERE d.detail_prefs_id=n1.parent_entity_id
      AND d.view_name="MCDISCERNRPT")
    DETAIL
     tabidx += 1, stat = alterlist(mc_discern_tabs->tabs,tabidx), reportname = n2.pvc_value,
     newurl = ""
     IF (textlen(trim(reportname)) > 0)
      index = 1
      IF (findstring("$PAT_PERSONID$",reportname,1,0) <= 0)
       newurl = replace(reportname,"m=^ORG^",
        "m=^CHT^&pId=$PAT_PERSONID$&eId=$VIS_ENCNTRID$&ppr=$PAT_PPRCode$",1)
      ENDIF
      IF (size(newurl,1) < 255
       AND size(newurl,1) > 0)
       mc_discern_tabs->tabs[tabidx].report_name_pref_id = n2.name_value_prefs_id, mc_discern_tabs->
       tabs[tabidx].new_report_name_str = newurl
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed retrieving MCDiscern Tabs",errmsg)
    GO TO exit_script
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(mc_discern_tabs)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::updturl(null)
   DECLARE tabcnt = i4 WITH protect, constant(size(mc_discern_tabs->tabs,5))
   DECLARE errmsg = c132 WITH protect, noconstant("")
   IF (size(mc_discern_tabs->tabs,5)=0)
    RETURN(null)
   ENDIF
   UPDATE  FROM name_value_prefs n,
     (dummyt d  WITH seq = value(tabcnt))
    SET n.pvc_value = mc_discern_tabs->tabs[d.seq].new_report_name_str, n.updt_applctx = reqinfo->
     updt_applctx, n.updt_cnt = (n.updt_cnt+ 1),
     n.updt_dt_tm = cnvtdatetime(sysdate), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE d.seq <= value(tabcnt))
     JOIN (n
     WHERE (n.name_value_prefs_id=mc_discern_tabs->tabs[d.seq].report_name_pref_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Update Failed: setting chart mode HTMLDriver - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::main(null)
   CALL getwebbrowsertabs(null)
   CALL gethtmltabs(null)
   CALL getmcdiscerntabs(null)
   CALL updatewebbrowsertabs(null)
   CALL updthtmltabs(null)
   CALL updturl(null)
   IF (size(insert_web_pref->tabs,5) > 0)
    CALL insertwebprefs(null)
   ENDIF
   IF (size(html_tabs->tabs,5)=0
    AND size(edge_browser_tabs->tabs,5)=0)
    SET readme_data->status = "S"
    SET readme_data->message = concat("dm_rdm_msg_updt_prefs found no tab configurations to update.")
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = concat("msg_updt_prefs has successfully completed the update.")
    COMMIT
   ENDIF
 END ;Subroutine
 CALL main(null)
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD html_tabs
 FREE RECORD edge_browser_tabs
 FREE RECORD insert_web_pref
 FREE RECORD report_param
 FREE RECORD mc_discern_tabs
END GO
