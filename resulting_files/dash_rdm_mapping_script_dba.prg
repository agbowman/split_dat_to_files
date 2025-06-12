CREATE PROGRAM dash_rdm_mapping_script:dba
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
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE comp_id = f8 WITH protect, noconstant(0.0)
 DECLARE comp_setting_id = f8 WITH protect, noconstant(0.0)
 DECLARE level_1_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE level_2_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE level_3_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE level_4_parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE mini_wiki_txt_id = f8 WITH protect, noconstant(0.0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script DASH_CONFIG_MAPPING_SCRIPT..."
 CALL echo("processing component : 'Case Progression Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Case Progression Day Of Template"
   AND dc.component_name="Case Progression Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Case Progression</h2><br><p>This component is a running tally of how many cases are planned for the day, along with th\
eir current status.</p><br><p><b>Scheduled</b> - This is all cases with a Scheduled Start Date/time equal to the selected \
filter day which do NOT have  the Add-on indicator set to Yes. All cases scheduled are displayed, regardless of what their\
 final disposition is (that is, if  a case is terminated, it is still included in the scheduled value).</p><br><p><b>Add-o\
n</b> - This is all cases with a Scheduled Start Date/Time equal to the selected day which does have the Add-on  indicator\
 set to Yes. All cases scheduled as Add-ons are displayed, regardless of what their final disposition is (that is, if  an \
add-on case is terminated, it is still included in the Add-on value).</p><br><p><b>Cancel/Resched</b> - This is all cases \
which will no longer be completed on the day of surgery. This includes cases that  were cancelled, rescheduled or terminat\
ed.</p><ul>	<li><b>Canceled</b> - the cases have a Scheduled Start Date/Time equal to the selected day/days, and a Cancel \
Date equal to      the scheduled date.</li>	<li><b>Rescheduled</b> - the cases where the Reschedule Action Date is the sam\
e as the Scheduled Start Date, so they were      rescheduled on the day of surgery.</li>	<li><b>Terminated</b> - This is a\
ll cases with a terminated intraoperative record.</li></ul><br><p><b>Active</b> - This is all cases with a Scheduled Start\
 Date/Time equal to the selected day which have an active  intraoperative document (document has been opened) at least one\
 documented case time in the intraoperative record and are not  Canceled, Terminated or Complete.</p><br><p><b>Complete</b\
> - This is all cases with a Scheduled Start Date/Time equal to the selected day which has a Finalized  Date/Time and are \
not Cancelled or Terminated.</p><br><p><b>Remaining</b> - This is the calculated number of planned cases that have not had\
 a status change yet. This is represented  by the following equation:<br/>(Scheduled + Add-on) - (Active + Complete + Canc\
el/Reschedule + Terminated) = Remaining.</p><br><p><b>PT in PACU</b> - This is the number of patients currently in the PAC\
U area. If a facility has a PACU I and PACU II, this  field displays two numbers divided by a slash. The first value is th\
e number of patients who have a documented Patient In PACU  I Date/Time (CDF Meaning = PTINPACUI) with no corresponding Pa\
tient Out PACU I Date/Time (CDF Meaning = PTOUTPACUI). The second  value is the number of patients who have a documented P\
atient In PACU II Date/Time (CDF Meaning = PTINPACUII) with no  corresponding Patient Out PACU II Date/Time (CDF Meaning =\
 PTOUTPACUII).</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "label",
  "", "F", "Case Progression",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Number of Cases with Late Starts Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Number of Cases with Late Starts Day Of Template"
   AND dc.component_name="Number of Cases with Late Starts Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Number of Cases with Late Starts</h2><br><p><b>Late Start</b> - Defined as any case where the documented Patient In Ro\
om time from the intraoperative record is more  than 15 minutes after the scheduled patient in room time which is calculat\
ed as the Scheduled Start time plus the Scheduled  Setup Duration.</p><br><p>For example:<br/>Main-2013-392 is scheduled t\
o start at 10:00 am and includes a 10 minute Setup. The scheduled Patient In Room time is 10:10.  The Patient In Room is d\
ocumented as 10:26. This case is not on time.<br/>10:00 + 10 = 10:10. 10:10 - 10:26 = 16 minutes difference.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "maxDatapoints",
  "", "F", "",
  comp_id, "this limits the number of items displayed on the x axis", 1,
  "Max Data Points", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Number of Cases with Late Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "pointLabels",
  "", "", "",
  comp_id, "config section for labels at the data points", 1,
  "Point Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "show",
  "true,false", "R", "true",
  comp_id, "If true, display label text", 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "location",
  "n,ne,e,se,s,sw,w,nw", "S", "s",
  comp_id, concat("compass location  ","where to display label relative to data point"), 1,
  "Location", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesColors",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Colors", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "lightblue,aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "lightblue",
  comp_id, "the color of the bars", 1,
  "Series 1", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "axes",
  "", "", "",
  comp_id, "a collection of Axes", 1,
  "Axes", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "xaxis",
  "", "", "",
  comp_id, "Settings for the X-axis", 1,
  "X-axis", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "tickOptions",
  "", "", "",
  comp_id, "Options for the axis tick marks", 1,
  "Tick Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "angle",
  "", "F", "60",
  comp_id, "angle to display x-axis label", 1,
  "Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "config section for the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, "config section for the cursor", 1,
  "Cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location.  Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Number of Minutes Cases Started Late Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Number of Minutes Cases Started Late Day Of Template"
   AND dc.component_name="Number of Minutes Cases Started Late Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Number of Minutes Cases Started Late</h2><br><p><b>Late</b> - Defined as the difference between the documented Patient\
 In Room Date/Time from the intraoperative record  versus the Scheduled Patient In Room Date/Time. Any case with a differe\
nce of more than 15 minutes qualifies as a case to be  included in the display.</p><br><p>In the related details table, th\
e number of minutes late is calculated based on the HH:MM:SS of the scheduled and documented  times. It then rounds off to\
 the nearest minute. For instance, if the case was scheduled to start at 10 am, but it started at  10:05, the details tabl\
e could show it started 6 minutes late if the documented time was actually 10:05:30.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "maxDatapoints",
  "", "F", "",
  comp_id, "this limits the number of items displayed on the x axis", 1,
  "Max Data Points", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "Number of Minutes Cases Started Late",
  comp_id, concat("the title"," of the component"), 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Number of Cases with Late Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "pointLabels",
  "", "", "",
  comp_id, "config section for labels at the data points", 1,
  "Point Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "show",
  "true,false", "R", "true",
  comp_id, "If true, display label text", 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "location",
  "n,ne,e,se,s,sw,w,nw", "S", "s",
  comp_id, concat("compass location  ","where to display label relative to data point"), 1,
  "Location", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesColors",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Colors", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "lightblue,aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "blue",
  comp_id, "the color of the bars", 1,
  "Series 1", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "axes",
  "", "", "",
  comp_id, "a collection of Axes", 1,
  "Axes", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "xaxis",
  "", "", "",
  comp_id, "Settings for the X-Axis", 1,
  "X-Axis", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "tickOptions",
  "", "", "",
  comp_id, "Options for the axis tick marks", 1,
  "Tick Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "angle",
  "", "F", "60",
  comp_id, "the angle to display x-axis label", 1,
  "Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "config section for the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, "config section for the cursor as displayed 	on the plot", 1,
  "Cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location.  Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Minutes Cases Started Late Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'First Case On-time Starts Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="First Case On-time Starts Day Of Template"
   AND dc.component_name="First Case On-time Starts Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>First Case On-time Starts</h2><br><p>Delays in the first case of the day can have a domino effect throughout the rest \
of the days schedule. This component  provides a clear understanding how well the first cases are being executed.</p><br>\
<p><b>First Case</b> - Defined as the first case scheduled in that room between 6 am - 9am. Specifically, cases with  a st\
art time of 8:59:59 will qualify, but cases with a start time of 9:00:00 will not.</p><br><p><b>On-time</b> - Defined as a\
ny case where the documented Patient In Room time from the intraoperative record is less  than or equal to 5 minutes after\
 the scheduled patient in room time which is calculated as the Scheduled Start time plus the  Scheduled Setup Duration.</p\
><br><p>For example:<br/>Main-2013-399 is scheduled to start at 7:30 am and includes a 10 minute Setup. So the Scheduled P\
atient In Room is 7:40. The  Patient In Room is documented as 7:50. This case is not on time.<br/>7:30 + 10 = 7:40. 7:40 -\
 7:50 = 10 minutes difference.</p><br><p>Cases that start earlier than scheduled are considered on-time. However, they are\
 not included in the calculation until their  scheduled start time is met.</p><br><p>For example:<br/>A case is scheduled \
to start at 8:30 am, but it actually starts at 8:00. If you run the dashboard at 7:45, that case is not  included in the c\
alculation. If you run it at 8 or 8:01 am, then it is included.</p><br><p><b>Benchmark Source</b> - OR Benchmarks</p><br><\
p><b>Case Filter</b> - This includes only cases where the scheduled start date/time has already occurred. For example, if \
a  case is scheduled to start in 10 minutes, it is not yet included in the calculation. This does not include cancelled or\
  terminated cases.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "First Case On-time Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "rendererOptions",
  "", "", "",
  comp_id, "options for the series", 1,
  "Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "showDataLabels",
  "true,false", "R", "true",
  comp_id, concat("if true, show labels on"," data slices"), 1,
  "Show Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "startAngle",
  "", "F", "-45",
  comp_id, "angle to start drawing donut, in degrees", 1,
  "Start Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "thickness",
  "", "F", "",
  comp_id, "thickness of the donut", 1,
  "Thickness", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "sliceMargin",
  "", "F", "",
  comp_id, concat("angular spacing between donut slices, in"," degrees"), 1,
  "Slice Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "ringMargin",
  "", "F", "",
  comp_id, "pixel distance between rings", 1,
  "Ring Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "fill",
  "true,false", "R", "",
  comp_id, "if true, fill the slices", 1,
  "Fill", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabels",
  ",label,value,percent", "S", "",
  comp_id, concat("the type of labels"," to place on the pie slices"), 1,
  "Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabelPositionFactor",
  "", "F", "",
  comp_id, concat("a Multiplier of the pie"," radius which controls position of label on slice"), 1,
  "Data Label Position Factor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Subsequent On-time Starts Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Subsequent On-time Starts Day Of Template"
   AND dc.component_name="Subsequent On-time Starts Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Subsequent On-time Starts</h2><br><p>Ensuring that all cases are starting on time is a key component to keeping the OR\
 on schedule.</p><br><p><b>Subsequent case</b> - Defined as any case which is NOT the first case scheduled in that room be\
tween 6 am - 9am.  Specifically, this will not include cases with a start time of 9:00:00. This includes cases that were s\
cheduled before that  timeframe in addition to the cases scheduled after it.</p><br><p><b>On-time</b> - Defined as any cas\
e where the documented Patient In Room time from the Intraoperative record is less than or  equal to 15 minutes after the \
scheduled patient in room time which is calculated as the Scheduled Start time plus the Scheduled  Setup Duration.</p><br>\
<p>For example:<br/>Main-2013-249 is scheduled to start at 10:00 am and includes a 10 minute Setup. So the Scheduled Patie\
nt In Room is 10:10. The  Patient In Room is documented as 10:26. This case is not on time.</p><br><p>10:00 + 10 = 10:10. \
10:10 - 10:26 = 16 minutes difference.</p><br><p>Cases that start earlier than scheduled are considered on-time. However, \
they are not included in the calculation until their  scheduled start time is met.</p><br><p>For example:<br/>A case is sc\
heduled to start at 10 am, but it actually starts at 9:30. If you run the dashboard at 9:45, that case is not  included in\
 the calculation. If you run it at 10 or 10:01 am, then it is included.</p><br><p><b>Benchmark Source</b> - OR Benchmarks<\
/p><br><p><b>Case Filter</b> - This will only include cases where the scheduled start date/time has already occurred. or e\
xample, if a  case is scheduled to start in 10 minutes, it is not yet included in the calculation.  This does not include \
cancelled or  terminated cases.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Subsequent On-time Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "rendererOptions",
  "", "", "",
  comp_id, "options for the series", 1,
  "Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "showDataLabels",
  "true,false", "R", "true",
  comp_id, concat("if true, show labels on"," data slices"), 1,
  "Show Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "thickness",
  "", "F", "",
  comp_id, "thickness of the donut", 1,
  "Thickness", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "sliceMargin",
  "", "F", "",
  comp_id, concat("angular spacing between donut slices, in"," degrees"), 1,
  "Slice Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "ringMargin",
  "", "F", "",
  comp_id, "pixel distance between rings", 1,
  "Ring Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "fill",
  "true,false", "R", "",
  comp_id, "if true, fill the slices", 1,
  "Fill", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabels",
  ",label,value,percent", "S", "",
  comp_id, concat("the type of labels to"," place on the pie slices"), 1,
  "Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabelPositionFactor",
  "", "F", "",
  comp_id, concat("a Multiplier of the pie"," radius which controls position of label on slice"), 1,
  "Data Label Position Factor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "startAngle",
  "", "F", "",
  comp_id, "angle to start drawing donut, in degrees", 1,
  "Start Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Case Cancelled on DOS Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Case Cancelled on DOS Day Of Template"
   AND dc.component_name="Case Cancelled on DOS Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Cases Cancelled/Rescheduled on DOS</h2><br><p><b>Canceled on Day of Surgery</b> - Defined as a case which was cancelle\
d where the Canceled date is equal to the Scheduled  Start date.</p><br><p><b>Rescheduled on Day of Surgery</b> - Defined \
as a case which was Rescheduled to a different date, but the date when the  reschedule action occurred was equal to the sc\
heduled date. This calculation only includes cases that were scheduled and  rescheduled using the Scheduling Appointment B\
ook.</p><br><p>The display of this component is sorted by OR Room.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "maxDatapoints",
  "", "F", "",
  comp_id, "this limits the number of items displayed on the x axis", 1,
  "Max Data Points", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "Case Cancelled on DOS",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Case Cancelled on DOS",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "pointLabels",
  "", "", "",
  comp_id, "config section for labels at the data points", 1,
  "Point Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "show",
  "true,false", "R", "true",
  comp_id, "If true, display label text", 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "location",
  "n,ne,e,se,s,sw,w,nw", "S", "s",
  comp_id, concat("compass location  ","where to display label relative to data point"), 1,
  "Location", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesColors",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "lightblue,aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "lime",
  comp_id, "the color of the bars", 1,
  "Series 1", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "axes",
  "", "", "",
  comp_id, "a collection of Axes", 1,
  "Axes", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "xaxis",
  "", "", "",
  comp_id, "x axis", 1,
  "X-Axis", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "tickOptions",
  "", "", "",
  comp_id, "tick options", 1,
  "Tick Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "angle",
  "", "F", "60",
  comp_id, "the angle to display x-axis label", 1,
  "Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "config section for the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the color of the text", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, concat("config section for the cursor as displayed on"," the plot"), 1,
  "cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location.  Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Add-on Cases Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Add-on Cases Day Of Template"
   AND dc.component_name="Add-on Cases Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Add-on Cases</h2><br><p>Number of cases scheduled with the Add-on Indicator set to Yes.</p><br><p><b>Filter:</b> This \
component does not include cases which were Canceled, Rescheduled on Day of Surgery, or Terminated.</p><br><p>The threshol\
d from green to yellow is set at 5% of total number of valid (not canceled, rescheduled or terminated) scheduled  cases on\
 the selected day/days (such as 5 out of 100). The threshold from yellow to red is set at 10% of total number of valid  (n\
ot cancelled, rescheduled or terminated) scheduled cases on the selected day/days (such as 10 out of 100).</p><br><p>The d\
efault maximum for the gauge is 20% of the total scheduled cases. However, if the actual percentage exceeds 20%, then  the\
 gauge displays as maxed out.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Add-on Cases",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, concat("config section for the grid on which the plot is"," drawn"), 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Anticipated Stops Day Of Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Anticipated Stops Day Of Template"
   AND dc.component_name="Anticipated Stops Day Of Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Anticipated Stops</h2><br><p><b>Stop</b> - The stop time is defined as the documented Patient Out of OR Room time in t\
he intraoperative record. If a case  does not have a documented Surgery Stop time, then the system will provide a predicte\
d stop time based on the Actual or  Anticipated Start date/time plus the scheduled duration minus the Scheduled Cleanup Ti\
me.</p><br><p>Times are displayed in 30 minute increments (such as 1-1:30) with the label set at the middle of the timefra\
me (such as  1:15). The dot in each time increment indicates the total number of cases anticipated to be complete within t\
hat 30 minute  increment.</p><br><p><b>Case Filter</b> - This includes all cases scheduled on the selected filter day. The\
 display shows 30 minutes prior to  current time and 6 hours after current time.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Anticipated Stops",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "series",
  "", "", "",
  comp_id, "the collection of series", 1,
  "Series", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "", "", "",
  comp_id, "Data line", 1,
  "Data line", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "lineWidth",
  "", "F", "2",
  comp_id, "the width of the line", 1,
  "Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "1",
  "", "", "",
  comp_id, "Current patients indicator", 1,
  "The symbol indicating the number of patients currently in PACU", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "markerOptions",
  "", "", "",
  comp_id, "options for the line marks", 1,
  "Marker Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "size",
  "", "F", "10",
  comp_id, "the size of the mark", 1,
  "Size", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "style",
  "diamond,circle,square,x,plus,dash,filledDiamond,filledCircle,filledSquare", "S", "diamond",
  comp_id, "The shape of the mark", 1,
  "Shape", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "color",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "red",
  comp_id, "the color of the mark", 1,
  "Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, concat("config section for the cursor as displayed on"," the plot"), 1,
  "cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location. Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Day Of Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Case Progression Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Case Progression Historical Template"
   AND dc.component_name="Case Progression Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Case Progression</h2><br><p>This component displays a tally of cases, and their final status, for a given day or range\
 of days.</p><br><p><b>Scheduled</b> - This is all cases with a Scheduled Start Date/time equal to the selected filter day\
/days which do NOT have  the Add-on indicator set to Yes. All cases scheduled are displayed, regardless of what their fina\
l disposition is (that is, if  a case is terminated, it is still included in the scheduled value).</p><br><p><b>Add-on</b>\
 - This is all cases with a Scheduled Start Date/Time equal to the selected day/days which does have the Add-on  indicator\
 set to Yes. All cases scheduled as Add-ons are displayed, regardless of what their final disposition is (that is, if  an \
add-on case is terminated, it is still included in the Add-on value).</p><br><p><b>Cancel/Resched</b> - This is all cases \
which will no longer be completed on the day of surgery. This includes cases that  were cancelled, rescheduled or terminat\
ed.</p><ul>	<li><b>Canceled</b> - the cases have a Scheduled Start Date/Time equal to the selected day/days, and a Cancel \
Date equal to      the scheduled date.</li>	<li><b>Rescheduled</b> - the cases where the Reschedule Action Date is the sam\
e as the Scheduled Start Date, so they were      rescheduled on the day of surgery.</li>	<li><b>Terminated</b> - This is a\
ll cases with a terminated intraoperative record.</li></ul><br><p><b>Complete</b> - This is all cases with a Scheduled Sta\
rt Date/Time equal to the selected day/days which has a Finalized  Date/Time and are not Cancelled or Terminated.</p><br><\
p><b>Incomplete</b> - This is the calculated number of planned cases that are not finalized. This includes cases that have\
 not  been checked in yet.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "label",
  "", "F", "Case Progression",
  comp_id, "the title of the component", 1,
  "Label", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Progression Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Number of Cases with Late Starts Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Number of Cases with Late Starts Historical Template"
   AND dc.component_name="Number of Cases with Late Starts Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records: ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Number of Cases with Late Starts</h2><br><p><b>Late Start</b> - Defined as any case where the documented Patient In Ro\
om time from the intraoperative record is more  than 15 minutes after the scheduled patient in room time which is calculat\
ed as the Scheduled Start time plus the Scheduled  Setup Duration.</p><br><p>For example:<br/>Main-2013-392 is scheduled t\
o start at 10:00 am and includes a 10 minute Setup. The scheduled Patient In Room time is 10:10.  The Patient In Room is d\
ocumented as 10:26. This case is not on time.<br/>10:00 + 10 = 10:10. 10:10 - 10:26 = 16 minutes difference.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "maxDatapoints",
  "", "F", "",
  comp_id, "this limits the number of items displayed on the x axis", 1,
  "Max Data Points", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "Number of Cases with Late Starts",
  comp_id, concat("the title of"," the component"), 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Number of Cases with Late Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "pointLabels",
  "", "", "",
  comp_id, "config section for labels at the data points", 1,
  "Point Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "show",
  "true,false", "R", "true",
  comp_id, "If true, display label text", 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "location",
  "n,ne,e,se,s,sw,w,nw", "S", "s",
  comp_id, concat("compass location  ","where to display label relative to data point"), 1,
  "Location", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesColors",
  "", "", "",
  comp_id, "defaults for all Series", 1,
  "Series Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "lightblue,aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "lightblue",
  comp_id, "the color of the bars", 1,
  "Series 1", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "axes",
  "", "", "",
  comp_id, "a collection of Axes", 1,
  "Axes", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "xaxis",
  "", "", "",
  comp_id, "axis x", 1,
  "X-Axis", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "tickOptions",
  "", "", "",
  comp_id, "tick options", 1,
  "Tick Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "angle",
  "", "F", "60",
  comp_id, "angle to display x-axis label", 1,
  "Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "config section for the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow "," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, "config section for the cursor", 1,
  "Cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location.  Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Number of Cases with Late Starts Historical Template' Config Setting records:  ",
   errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'First Case On-time Starts Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="First Case On-time Starts Historical Template"
   AND dc.component_name="First Case On-time Starts Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>First Case On-time Starts</h2><br><p>Delays in the first case of the day can have a domino effect throughout the rest \
of the days schedule. This component  provides a clear understanding how well the first cases are being executed.</p><br>\
<p><b>First Case</b> - Defined as the first case scheduled in that room between 6 am - 9am. Specifically, cases with  a st\
art time of 8:59:59 will qualify, but cases with a start time of 9:00:00 will not.</p><br><p><b>On-time</b> &#8211; Define\
d as any case where the documented Patient In Room time from the intraoperative record is less  than or equal to 5 minutes\
 after the scheduled patient in room time which is calculated as the Scheduled Start time plus the  Scheduled Setup Durati\
on.</p><br><p>For example:<br/>Main-2013-399 is scheduled to start at 7:30 am and includes a 10 minute Setup. So the Sched\
uled Patient In Room is 7:40. The  Patient In Room is documented as 7:50. This case is not on time.<br/>7:30 + 10 = 7:40. \
7:40 - 7:50 = 10 minutes difference.</p><br><p>Cases that start earlier than scheduled are considered on-time. However, th\
ey are not included in the calculation until their  scheduled start time is met.</p><br><p>For example:<br/>A case is sche\
duled to start at 8:30 am, but it actually starts at 8:00. If you run the dashboard at 7:45, that case is not  included in\
 the calculation. If you run it at 8 or 8:01 am, then it is included.</p><br><p><b>Benchmark Source</b> - OR Benchmarks</p\
><br><p><b>Case Filter</b> - This includes only cases where the scheduled start date/time has already occurred. For exampl\
e, if a  case is scheduled to start in 10 minutes, it is not yet included in the calculation. This does not include cancel\
led or  terminated cases.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "First Case On-time Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "rendererOptions",
  "", "", "",
  comp_id, "options for the series", 1,
  "Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "showDataLabels",
  "true,false", "R", "true",
  comp_id, concat("if true, show labels on"," data slices"), 1,
  "Show Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "startAngle",
  "", "F", "-45",
  comp_id, "angle to start drawing donut in degrees", 1,
  "Start Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "thickness",
  "", "F", "",
  comp_id, "thickness of the donut", 1,
  "Thickness", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "sliceMargin",
  "", "F", "",
  comp_id, concat("angular spacing between donut slices, in"," degrees"), 1,
  "Slice Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "ringMargin",
  "", "F", "",
  comp_id, "pixel distance between rings", 1,
  "Ring Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "fill",
  "true,false", "R", "",
  comp_id, "if true, fill the slices", 1,
  "Fill", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabels",
  ",label,value,percent", "S", "",
  comp_id, concat("the type of labels to"," place on the pie slices"), 1,
  "Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabelPositionFactor",
  "", "F", "",
  comp_id, concat("a Multiplier of the pie"," radius which controls position of label on slice"), 1,
  "Data Label Position Factor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'First Case On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Subsequent On-time Starts Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Subsequent On-time Starts Historical Template"
   AND dc.component_name="Subsequent On-time Starts Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Subsequent On-time Starts</h2><br><p>Ensuring that all cases are starting on time is a key component to keeping the OR\
 on schedule.</p><br><p><b>Subsequent case</b> - Defined as any case which is NOT the first case scheduled in that room be\
tween 6 am - 9am.  Specifically, this will not include cases with a start time of 9:00:00. This includes cases that were s\
cheduled before that  timeframe in addition to the cases scheduled after it.</p><br><p><b>On-time</b> - Defined as any cas\
e where the documented Patient In Room time from the Intraoperative record is less than or  equal to 15 minutes after the \
scheduled patient in room time which is calculated as the Scheduled Start time plus the Scheduled  Setup Duration.</p><br>\
<p>For example:<br/>Main-2013-249 is scheduled to start at 10:00 am and includes a 10 minute Setup. So the Scheduled Patie\
nt In Room is 10:10. The  Patient In Room is documented as 10:26. This case is not on time.</p><br><p>10:00 + 10 = 10:10. \
10:10 - 10:26 = 16 minutes difference.</p><br><p>Cases that start earlier than scheduled are considered on-time. However, \
they are not included in the calculation until their  scheduled start time is met.</p><br><p>For example:<br/>A case is sc\
heduled to start at 10 am, but it actually starts at 9:30. If you run the dashboard at 9:45, that case is not  included in\
 the calculation. If you run it at 10 or 10:01 am, then it is included.</p><br><p><b>Benchmark Source</b> - OR Benchmarks<\
/p><br><p><b>Case Filter</b> - This will only include cases where the scheduled start date/time has already occurred. or e\
xample, if a  case is scheduled to start in 10 minutes, it is not yet included in the calculation.  This does not include \
cancelled or  terminated cases.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Subsequent On-time Starts",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "rendererOptions",
  "", "", "",
  comp_id, "options for the series", 1,
  "Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "showDataLabels",
  "true,false", "R", "true",
  comp_id, concat("if true, show labels on"," data slices"), 1,
  "Show Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "thickness",
  "", "F", "",
  comp_id, "thickness of the donut", 1,
  "Thickness", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "sliceMargin",
  "", "F", "",
  comp_id, concat("angular spacing between donut slices, in"," degrees"), 1,
  "Slice Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "ringMargin",
  "", "F", "",
  comp_id, "pixel distance between rings", 1,
  "Ring Margin", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "fill",
  "true,false", "R", "",
  comp_id, "if true, fill the slices", 1,
  "Fill", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabels",
  ",label,value,percent", "S", "",
  comp_id, concat("the type of labels to"," place on the pie slices"), 1,
  "Data Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "dataLabelPositionFactor",
  "", "F", "",
  comp_id, concat("a Multiplier of the pie"," radius which controls position of label on slice"), 1,
  "Data Label Position Factor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "startAngle",
  "", "F", "",
  comp_id, "angle to start drawing donut, in degrees", 1,
  "Start Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Subsequent On-time Starts Historical Template' Config Setting records: ",errmsg
   )
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Case Cancelled on DOS Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Case Cancelled on DOS Historical Template"
   AND dc.component_name="Case Cancelled on DOS Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Cases Cancelled/Rescheduled on DOS</h2><br><p><b>Canceled on Day of Surgery</b> - Defined as a case which was cancelle\
d where the Canceled date is equal to the Scheduled  Start date.</p><br><p><b>Rescheduled on Day of Surgery</b> - Defined \
as a case which was Rescheduled to a different date, but the date when the  reschedule action occurred was equal to the sc\
heduled date. This calculation only includes cases that were scheduled and  rescheduled using the Scheduling Appointment B\
ook.</p><br><p>The display of this component will be sorted by surgeon and will only show the top 10 (highest number of ca\
ncellations)  surgeons in order to optimally display the data.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "maxDatapoints",
  "", "F", "",
  comp_id, "this limits the number of items displayed on the x axis", 1,
  "Max Data Points", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "plot title", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Case Cancelled on DOS Historical",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesDefaults",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Defaults", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "pointLabels",
  "", "", "",
  comp_id, "config section for labels at the data points", 1,
  "Point Labels", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "show",
  "true,false", "R", "true",
  comp_id, "If true, display label text", 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "location",
  "n,ne,e,se,s,sw,w,nw", "S", "s",
  comp_id, concat("compass location  ","where to display label relative to data point"), 1,
  "Location", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "seriesColors",
  "", "", "",
  comp_id, "defaults for all series", 1,
  "Series Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 SET level_2_parent_id = comp_setting_id
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "lightblue,aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "lime",
  comp_id, "the color of the bars", 1,
  "Series 1", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "axes",
  "", "", "",
  comp_id, "a collection of axes", 1,
  "Axes", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "xaxis",
  "", "", "",
  comp_id, "x axis", 1,
  "X-Axis", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "tickOptions",
  "", "", "",
  comp_id, "tick options", 1,
  "Tick Options", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_4_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_4_parent_id, "angle",
  "", "F", "60",
  comp_id, "the angle to display x-axis label", 1,
  "Angle", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, "config section for the cursor", 1,
  "cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location.  Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Case Cancelled on DOS Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Add-on Cases Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Add-on Cases Historical Template"
   AND dc.component_name="Add-on Cases Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Add-on Cases</h2><br><p>Number of cases scheduled with the Add-on Indicator set to Yes.</p><br><p><b>Filter:</b> This \
component does not include cases which were Canceled, Rescheduled on Day of Surgery, or Terminated.</p><br><p>The threshol\
d from green to yellow is set at 5% of total number of valid (not canceled, rescheduled or terminated) scheduled  cases on\
 the selected day/days (such as 5 out of 100). The threshold from yellow to red is set at 10% of total number of valid  (n\
ot cancelled, rescheduled or terminated) scheduled cases on the selected day/days (such as 10 out of 100).</p><br><p>The d\
efault maximum for the gauge is 20% of the total scheduled cases. However, if the actual percentage exceeds 20%, then  the\
 gauge displays as maxed out.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Add-on Cases",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Add-on Cases Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("processing component : 'Patients entering PACU Historical Template'")
 SELECT INTO "nl:"
  FROM dash_component dc
  WHERE dc.component_template_name="Anticipated Stops Historical Template"
   AND dc.component_name="Anticipated Stops Historical Template"
   AND dc.org_id=0.0
  DETAIL
   comp_id = dc.dash_component_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   mini_wiki_txt_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM long_text_reference
  (long_text_id, long_text, parent_entity_name,
  parent_entity_id, active_ind, active_status_prsnl_id,
  updt_applctx, updt_cnt, updt_dt_tm,
  updt_id, updt_task)
  VALUES(mini_wiki_txt_id,
"<h2>Patients Entering PACU</h2><br><p><b>Stop</b> - The stop time is defined as the documented Patient Out of OR Room time\
 in the intraoperative record.  If a case does not have a documented Surgery Stop time, then a predicted stop time is used\
 based on the Actual or Anticipated  Start date/time plus the scheduled duration minus the Scheduled Cleanup Time.</p><br>\
<p>Times are displayed in 30 minute increments (such as 1-1:30) with the label set at the middle of the timeframe (such as\
  1:15).  The dot in each time increment indicates the total number of cases anticipated to be complete within that 30 min\
ute  increment.</p><br><p><b>Case Filter</b> - This includes all cases scheduled on the selected filter day. The display s\
hows 30 minutes prior to  current time and 6 hours after current time.</p><br><p>If multiple days including the current da\
y are included in the filter, then it shows historical stop times and anticipated  stop times together. For example, if yo\
u run the dashboard for today and yesterday at 10 am, then the 11-11:30 timeblock shows  4 cases = 3 that stopped in that \
timeblock yesterday, and 1 that is anticipated to stop in that timeblock today.</p>\
", "DASH_COMPONENT",
  comp_id, 1, 0.0,
  reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
  reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dash_component dc
  SET dc.mini_wiki_txt_id = mini_wiki_txt_id, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
   (dc.updt_cnt+ 1),
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task
  WHERE dc.dash_component_id=comp_id
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, 0, "chartConfig",
  "", "", "",
  comp_id, "this section allows for configuring of the visuals of the chart", 1,
  "Chart Config", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_1_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "title",
  "", "", "",
  comp_id, "the title of the component", 1,
  "Title", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "text",
  "", "F", "Anticipated Stops",
  comp_id, "text of the title", 1,
  "Text", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "textColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the text", 1,
  "Text Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "series",
  "", "", "",
  comp_id, "The collection of series", 1,
  "Series", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "0",
  "", "", "",
  comp_id, "Data line", 1,
  "data line", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_3_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_3_parent_id, "lineWidth",
  "", "F", "2",
  comp_id, "the width of the line", 1,
  "Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "grid",
  "", "", "",
  comp_id, "the grid on which the plot is drawn", 1,
  "Grid", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "shadow",
  "true,false", "R", "false",
  comp_id, concat("if true, display shadow"," behind grid"), 1,
  "Shadow", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "background",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow,transparent",
  "S", "transparent",
  comp_id, "the background color", 1,
  "Background", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawGridlines",
  "true,false", "R", "",
  comp_id, concat("if true, display gridlines"," on the grid"), 1,
  "Draw Gridlines", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "drawBorder",
  "true,false", "R", "",
  comp_id, "if true, display border around grid", 1,
  "Draw Border", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "color of the grid lines", 1,
  "Grid Line Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "gridLineWidth",
  "", "F", "",
  comp_id, "width of the grid lines", 1,
  "Grid Line Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderColor",
  ",aqua,black,blue,fuchsia,gray,green,lime,maroon,navy,olive,	purple,red,silver,teal,white,yellow",
  "S", "",
  comp_id, "the color of the grid border", 1,
  "Border Color", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "borderWidth",
  "", "F", "",
  comp_id, "width of the border in pixels", 1,
  "Border Width", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_1_parent_id, "cursor",
  "", "", "",
  comp_id, "config section for the cursor", 1,
  "cursor", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET level_2_parent_id = comp_setting_id
 SELECT INTO "nl:"
  se_id = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   comp_setting_id = se_id
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM dash_component_setting
  (dash_component_setting_id, parent_setting_id, config_setting_name,
  interface_options_txt, interface_type, setting_default_value_txt,
  dash_component_id, description, active_ind,
  display_name, updt_applctx, updt_cnt,
  updt_dt_tm, updt_id, updt_task)
  VALUES(comp_setting_id, level_2_parent_id, "show",
  "true,false", "R", "false",
  comp_id, concat("if true, show a cross-hair at",
   " the cursor location. Doesnt display in config tool."), 1,
  "Show", reqinfo->updt_applctx, 0,
  cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to create 'Anticipated Stops Historical Template' Config Setting records: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: config mapping records imported successfully.")
#exit_script
END GO
