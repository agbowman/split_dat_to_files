CREATE PROGRAM ec_inet_audit
 RECORD wv(
   1 views[*]
     2 working_view_id = f8
     2 events_in_band = i4
     2 display_name = vc
     2 pref_name = vc
     2 additional_info_ind = i2
     2 location = vc
     2 position = vc
     2 settings[*]
       3 entry_id = f8
       3 chrono_time_sort = vc
       3 default_freq_interval = vc
       3 default_open = vc
       3 hide_empty_cols_rows = vc
       3 last_x_hours = vc
       3 retrieve_type = vc
       3 seeker = vc
       3 task_integration = vc
       3 order_integration = vc
       3 result_cap = vc
       3 bmdi_look_back_min = vc
       3 bmdi_look_forward_min = vc
       3 enhanced_performance = vc
       3 fall_off_time = vc
       3 level = vc
       3 position_cd = f8
       3 loc_cd = f8
       3 invalid_cd = vc
       3 path_type = i2
 )
 RECORD paths(
   1 qual[6]
     2 path = vc
     2 display = vc
     2 type = i2
 )
 DECLARE filename_pt1 = vc WITH constant("ec_inet_audit_part_1.csv"), protect
 DECLARE filename_pt2 = vc WITH constant("ec_inet_audit_part_2.csv"), protect
 DECLARE filename_pt3 = vc WITH constant("ec_inet_audit_part_3.csv"), protect
 DECLARE filename_pt4 = vc WITH constant("ec_inet_audit_part_4.csv"), protect
 DECLARE filename_pt5 = vc WITH constant("ec_inet_audit_part_5.csv"), protect
 DECLARE add_log_row(rn=vc,fn=vc,err=vc) = null WITH protect
 DECLARE data_file = vc
 DECLARE logfile = vc WITH noconstant(build2(trim(curprog),".log")), protect
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE str = vc
 DECLARE int_cnt = i4
 SET paths->qual[1].path = concat("prefgroup=component,","prefgroup=system,","prefcontext=default,",
  "prefroot=prefroot")
 SET paths->qual[1].display = "Default->Component"
 SET paths->qual[1].type = 0
 SET paths->qual[2].path = concat("prefgroup=working views,","prefgroup=system,",
  "prefcontext=default,","prefroot=prefroot")
 SET paths->qual[2].display = "Default->Working Views"
 SET paths->qual[2].type = 0
 SET paths->qual[3].path = concat("prefgroup=component,","prefgroup=*,","prefcontext=position,",
  "prefroot=prefroot")
 SET paths->qual[3].display = "Position->"
 SET paths->qual[3].type = 1
 SET paths->qual[4].path = concat("prefgroup=working views,","prefgroup=*,","prefcontext=position,",
  "prefroot=prefroot")
 SET paths->qual[4].display = "Position->"
 SET paths->qual[4].type = 2
 SET paths->qual[5].path = concat("prefgroup=component,","prefgroup=*,",
  "prefcontext=position location,","prefroot=prefroot")
 SET paths->qual[5].display = "Position Location->"
 SET paths->qual[5].type = 3
 SET paths->qual[6].path = concat("prefgroup=working views,","prefgroup=*,",
  "prefcontext=position location,","prefroot=prefroot")
 SET paths->qual[6].display = "Position Location->"
 SET paths->qual[6].type = 4
 SELECT INTO "nl"
  wv.working_view_id, totalitems = count(*)
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wv.working_view_id=wvs.working_view_id)
   JOIN (wvi
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
  GROUP BY wv.working_view_id
  ORDER BY totalitems DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(wv->views,20)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,20)=0)
    stat = alterlist(wv->views,(20+ cnt))
   ENDIF
   wv->views[cnt].working_view_id = wv.working_view_id, wv->views[cnt].events_in_band = totalitems
  FOOT REPORT
   stat = alterlist(wv->views,cnt)
  WITH noheading
 ;end select
 SELECT INTO "nl"
  wv.display_name, loc_disp = uar_get_code_display(wv.location_cd), post_disp = uar_get_code_display(
   wv.position_cd)
  FROM (dummyt d  WITH seq = value(size(wv->views,5))),
   working_view wv
  PLAN (d)
   JOIN (wv
   WHERE (wv.working_view_id=wv->views[d.seq].working_view_id))
  DETAIL
   wv->views[d.seq].display_name = wv.display_name, wv->views[d.seq].pref_name = cnvtlower(wv
    .display_name), wv->views[d.seq].location = loc_disp,
   wv->views[d.seq].position = post_disp
  WITH noheading, nocounter
 ;end select
 SET new_row = (size(wv->views,5)+ 1)
 SET stat = alterlist(wv->views,new_row)
 SET wv->views[new_row].display_name = "Default"
 SET wv->views[new_row].pref_name = "interactiveviewglobalprefs"
 SET wv_cnt = 0
 SET max_wv_cnt = size(wv->views,5)
 DECLARE path_string = vc
 WHILE (max_wv_cnt > wv_cnt)
   SET wv_cnt = (wv_cnt+ 1)
   SET path_cnt = 0
   SET max_path_cnt = size(paths->qual,5)
   WHILE (max_path_cnt > path_cnt)
     SET path_cnt = (path_cnt+ 1)
     SET path_string = concat("prefgroup=",wv->views[wv_cnt].pref_name,",",paths->qual[path_cnt].path
      )
     SELECT INTO "nl:"
      FROM prefdir_entrydata pe1,
       prefdir_entrydata pe2,
       prefdir_value pv,
       prefdir_entry pe
      PLAN (pe1
       WHERE pe1.dist_name=patstring(value(path_string)))
       JOIN (pe2
       WHERE pe2.parent_id=pe1.entry_id)
       JOIN (pe
       WHERE pe.entry_id=pe2.entry_id
        AND pe.value IN ("chrono_time_sort", "default_freq_interval", "default_open",
       "hide_empty_cols_rows", "last_x_hours",
       "retrieve_type", "seeker", "task_integration", "order_integration", "result_cap",
       "bmdi_look_back_min", "bmdi_look_forward_min", "enhanced_performance"))
       JOIN (pv
       WHERE pv.entry_id=pe.entry_id)
      ORDER BY pe1.entry_id
      HEAD REPORT
       cnt = size(wv->views[wv_cnt].settings,5)
       IF (cnt=0)
        stat = alterlist(wv->views[wv_cnt].settings,20)
       ELSE
        stat = alterlist(wv->views[wv_cnt].settings,(20+ cnt))
       ENDIF
      HEAD pe1.dist_name
       cnt = (cnt+ 1)
       IF (mod(cnt,20)=0)
        stat = alterlist(wv->views[wv_cnt].settings,(20+ cnt))
       ENDIF
       wv->views[wv_cnt].settings[cnt].level = paths->qual[path_cnt].display, wv->views[wv_cnt].
       settings[cnt].entry_id = pe1.entry_id, wv->views[wv_cnt].settings[cnt].path_type = paths->
       qual[path_cnt].type,
       str = piece(piece(pe1.dist_name,",",3,notfnd),"=",2,notfnd), str2 = piece(str,"^",1,notfnd)
       IF (str2 != "<not_found>")
        wv->views[wv_cnt].settings[cnt].position_cd = cnvtreal(str2), wv->views[wv_cnt].settings[cnt]
        .loc_cd = cnvtreal(piece(str,"^",2,notfnd))
       ELSE
        IF (cnvtreal(str)=0)
         wv->views[wv_cnt].settings[cnt].invalid_cd = str
         IF ((wv->views[wv_cnt].settings[cnt].path_type > 0))
          wv->views[wv_cnt].settings[cnt].path_type = 5
         ENDIF
        ELSE
         wv->views[wv_cnt].settings[cnt].position_cd = cnvtreal(str)
        ENDIF
       ENDIF
       default_cnt = 0
      DETAIL
       CASE (pe.value)
        OF "chrono_time_sort":
         wv->views[wv_cnt].settings[cnt].chrono_time_sort = pv.value
        OF "default_freq_interval":
         wv->views[wv_cnt].settings[cnt].default_freq_interval = pv.value
        OF "default_open":
         default_cnt = (default_cnt+ 1),wv->views[wv_cnt].settings[cnt].default_open = cnvtstring(
          default_cnt)
        OF "hide_empty_cols_rows":
         wv->views[wv_cnt].settings[cnt].hide_empty_cols_rows = pv.value
        OF "last_x_hours":
         wv->views[wv_cnt].settings[cnt].last_x_hours = pv.value
        OF "retrieve_type":
         wv->views[wv_cnt].settings[cnt].retrieve_type = pv.value
        OF "seeker":
         wv->views[wv_cnt].settings[cnt].seeker = pv.value
        OF "task_integration":
         wv->views[wv_cnt].settings[cnt].task_integration = pv.value
        OF "order_integration":
         wv->views[wv_cnt].settings[cnt].order_integration = pv.value
        OF "result_cap":
         wv->views[wv_cnt].settings[cnt].result_cap = pv.value
        OF "bmdi_look_back_min":
         wv->views[wv_cnt].settings[cnt].bmdi_look_back_min = pv.value
        OF "bmdi_look_forward_min":
         wv->views[wv_cnt].settings[cnt].bmdi_look_forward_min = pv.value
        OF "enhanced_performance":
         wv->views[wv_cnt].settings[cnt].enhanced_performance = pv.value
       ENDCASE
      FOOT REPORT
       stat = alterlist(wv->views[wv_cnt].settings,cnt)
      WITH nocounter, noheading
     ;end select
   ENDWHILE
 ENDWHILE
 SELECT INTO "nl"
  position = uar_get_code_display(wv->views[d1.seq].settings[d2.seq].position_cd), location =
  uar_get_code_display(wv->views[d1.seq].settings[d2.seq].loc_cd)
  FROM (dummyt d1  WITH seq = value(size(wv->views,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(wv->views[d1.seq].settings,5)))
   JOIN (d2)
  DETAIL
   CASE (wv->views[d1.seq].settings[d2.seq].path_type)
    OF 1:
     wv->views[d1.seq].settings[d2.seq].level = trim(concat(wv->views[d1.seq].settings[d2.seq].level,
       position,"->Component"),4)
    OF 2:
     wv->views[d1.seq].settings[d2.seq].level = trim(concat(wv->views[d1.seq].settings[d2.seq].level,
       position,"->Working Views"),4)
    OF 3:
     wv->views[d1.seq].settings[d2.seq].level = concat(wv->views[d1.seq].settings[d2.seq].level,trim(
       position),"/",trim(location),"->Component")
    OF 4:
     wv->views[d1.seq].settings[d2.seq].level = concat(wv->views[d1.seq].settings[d2.seq].level,trim(
       position),"/",trim(location),"->Working Views")
    OF 5:
     wv->views[d1.seq].settings[d2.seq].level = concat(wv->views[d1.seq].settings[d2.seq].level,trim(
       wv->views[d1.seq].settings[d2.seq].invalid_cd),"*")
   ENDCASE
  WITH noheading, nocounter
 ;end select
 SELECT INTO value(filename_pt1)
  working_view_id = wv->views[d1.seq].working_view_id, events_in_the_band = wv->views[d1.seq].
  events_in_band, display = substring(1,50,wv->views[d1.seq].display_name),
  level = substring(1,50,wv->views[d1.seq].settings[d2.seq].level), chrono_time_sort = wv->views[d1
  .seq].settings[d2.seq].chrono_time_sort, default_freq_interval = substring(1,40,
   uar_get_code_display(cnvtreal(wv->views[d1.seq].settings[d2.seq].default_freq_interval))),
  default_open = wv->views[d1.seq].settings[d2.seq].default_open, hide_empty_cols_rows = wv->views[d1
  .seq].settings[d2.seq].hide_empty_cols_rows, last_x_hours = wv->views[d1.seq].settings[d2.seq].
  last_x_hours,
  retrieve_type = substring(1,50,wv->views[d1.seq].settings[d2.seq].retrieve_type), seeker = wv->
  views[d1.seq].settings[d2.seq].seeker, task_integration = wv->views[d1.seq].settings[d2.seq].
  task_integration,
  order_integration = wv->views[d1.seq].settings[d2.seq].order_integration, result_cap = wv->views[d1
  .seq].settings[d2.seq].result_cap, bmdi_look_back_min = wv->views[d1.seq].settings[d2.seq].
  bmdi_look_back_min,
  bmdi_look_forward_min = wv->views[d1.seq].settings[d2.seq].bmdi_look_forward_min,
  enhanced_performance = wv->views[d1.seq].settings[d2.seq].enhanced_performance
  FROM (dummyt d1  WITH seq = value(size(wv->views,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(wv->views[d1.seq].settings,5)))
   JOIN (d2)
  ORDER BY display
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 SELECT INTO value(filename_pt2)
  position = wv->views[d.seq].position, location = wv->views[d.seq].location, working_view = wv->
  views[d.seq].display_name,
  section_name = wvs.display_name, item_name = wvi.primitive_event_set_name, fall_off_time_mins = wvi
  .falloff_view_minutes
  FROM (dummyt d  WITH seq = value(size(wv->views,5))),
   working_view_section wvs,
   working_view_item wvi
  PLAN (d)
   JOIN (wvs
   WHERE (wvs.working_view_id=wv->views[d.seq].working_view_id))
   JOIN (wvi
   WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
  ORDER BY d.seq, wvs.working_view_section_id, wvi.working_view_item_id
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 SELECT DISTINCT INTO value(filename_pt3)
  error_type = "DTAs with More than one Event Code", dta = d.task_assay_cd, mnemonic = substring(1,40,
   d.mnemonic),
  activity_type = uar_get_code_display(d.activity_type_cd), event_cd = d.event_cd, event_cd_disp =
  substring(1,40,v5c.event_cd_disp),
  event_set_name = substring(1,40,v5c.event_set_name), view_section = substring(1,40,wvs
   .event_set_name), view_item = substring(1,40,wvi.primitive_event_set_name)
  FROM discrete_task_assay d,
   discrete_task_assay d2,
   v500_event_code v5c,
   working_view_section wvs,
   working_view_item wvi
  PLAN (d
   WHERE d.active_ind=1
    AND d.event_cd != 0)
   JOIN (d2
   WHERE d2.event_cd=d.event_cd
    AND d2.task_assay_cd != d.task_assay_cd
    AND d2.active_ind=1)
   JOIN (v5c
   WHERE v5c.event_cd=d.event_cd)
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(v5c.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
  ORDER BY d.mnemonic_key_cap, v5c.event_cd_disp
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 SELECT DISTINCT INTO value(filename_pt3)
  error_type = "Event Sets with more than one Event Code", event_cd = v5c.event_cd, event_cd_disp =
  substring(1,40,v5c.event_cd_disp),
  event_set_name = substring(1,40,v5c.event_set_name), dta = d.task_assay_cd, mnemonic = substring(1,
   40,d.mnemonic),
  view_section = substring(1,40,wvs.event_set_name), view_item = substring(1,40,wvi
   .primitive_event_set_name)
  FROM v500_event_code v5c,
   v500_event_code v5c2,
   discrete_task_assay d,
   working_view_section wvs,
   working_view_item wvi
  PLAN (v5c)
   JOIN (v5c2
   WHERE cnvtupper(v5c2.event_set_name)=cnvtupper(v5c.event_set_name)
    AND v5c2.event_set_name != " "
    AND v5c2.event_cd != v5c.event_cd)
   JOIN (d
   WHERE d.event_cd=v5c.event_cd)
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(v5c.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
  ORDER BY v5c.event_set_name
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000, append
 ;end select
 SELECT INTO value(filename_pt4)
  form_description = substring(1,50,f.description), section_desc = substring(1,50,s.description),
  grid_type = i.description,
  dta.event_cd, evcode_display = substring(1,40,v5c.event_cd_disp), evset_name = substring(1,40,v5c
   .event_set_name),
  prf2.pvc_name, prf2.pvc_value, dta.mnemonic,
  dta.description, i.input_type
  FROM dcp_forms_def d,
   dcp_forms_ref f,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs prf,
   name_value_prefs prf2,
   discrete_task_assay dta,
   v500_event_code v5c
  PLAN (f
   WHERE f.active_ind=1)
   JOIN (d
   WHERE f.dcp_form_instance_id=d.dcp_form_instance_id
    AND d.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
    AND s.active_ind=1)
   JOIN (i
   WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
    AND i.active_ind=1
    AND i.input_type IN (17, 19))
   JOIN (prf
   WHERE i.dcp_input_ref_id=prf.parent_entity_id
    AND prf.active_ind=1
    AND prf.pvc_name="grid_event_cd")
   JOIN (prf2
   WHERE prf.parent_entity_id=prf2.parent_entity_id
    AND prf2.active_ind=1
    AND ((prf2.pvc_name="discrete_task_assay") OR (prf2.pvc_name="discrete_task_assay2")) )
   JOIN (dta
   WHERE dta.task_assay_cd=prf2.merge_id)
   JOIN (v5c
   WHERE v5c.event_cd=outerjoin(dta.event_cd))
  ORDER BY i.input_type, f.description, s.description,
   v5c.event_cd_disp
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 SET data_file = "ec_inet_encntr_ctxt.csv"
 SELECT INTO value(data_file)
  entry_id = pde.entry_id, entry_data = pded.entry_data, updt_dt_tm = pded.updt_dt_tm,
  updt_cnt = pded.updt_cnt
  FROM prefdir_entry pde,
   prefdir_context pdc,
   prefdir_entrydata pded
  PLAN (pde
   WHERE pde.value_upper="USE_ENCOUNTER_CONTEXT")
   JOIN (pdc
   WHERE pdc.entry_id=pde.entry_id
    AND pdc.value_upper="DEFAULT")
   JOIN (pded
   WHERE pded.entry_id=pde.entry_id)
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 IF (curqual > 0)
  CALL add_log_row("USE_ENCOUNTER_CONTEXT Default Preference Setting",data_file,"")
 ELSE
  CALL add_log_row("USE_ENCOUNTER_CONTEXT Default Preference Setting",data_file,"No Rows Returned")
 ENDIF
 SET data_file = "ec_inet_wv_ref.csv"
 SELECT INTO value(data_file)
  dist_name = pded_sections.dist_name, policy = pdp.value
  FROM prefdir_context pdc,
   prefdir_group pdg,
   prefdir_entrydata pded_sections,
   prefdir_policy pdp
  PLAN (pdc
   WHERE pdc.value_upper="REFERENCE")
   JOIN (pdg
   WHERE pdg.entry_id=pdc.entry_id
    AND pdg.value_upper="WORKING VIEWS")
   JOIN (pded_sections
   WHERE pded_sections.entry_id=pdc.entry_id)
   JOIN (pdp
   WHERE pdp.entry_id=pdc.entry_id)
  ORDER BY dist_name
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 IF (curqual > 0)
  CALL add_log_row("Working View Sections within Reference Section",data_file,"")
 ELSE
  CALL add_log_row("Working View Sections within Reference Section",data_file,"No Rows Returned")
 ENDIF
 SET data_file = "ec_inet_w_enc_policy.csv"
 SELECT INTO value(data_file)
  dist_name = pded_sections.dist_name, policy = pdp.value
  FROM prefdir_context pdc,
   prefdir_group pdg,
   prefdir_entrydata pded_sections,
   prefdir_policy pdp
  PLAN (pdc
   WHERE pdc.value_upper="REFERENCE")
   JOIN (pdg
   WHERE pdg.entry_id=pdc.entry_id
    AND pdg.value_upper="WORKING VIEWS")
   JOIN (pded_sections
   WHERE pded_sections.entry_id=pdc.entry_id)
   JOIN (pdp
   WHERE pdp.entry_id=pdc.entry_id
    AND pdp.value_upper="*ENCOUNTER*")
  ORDER BY dist_name
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 IF (curqual > 0)
  CALL add_log_row("Working View Sections with ENCOUNTER Policy",data_file,"")
 ELSE
  CALL add_log_row("Working View Sections with ENCOUNTER Policy",data_file,"No Rows Returned")
 ENDIF
 SET data_file = "ec_inet_wv_enc_ctxt.csv"
 SELECT INTO value(data_file)
  count(pded_section.dist_name)
  FROM prefdir_entrydata pded_root,
   prefdir_entrydata pded_context,
   prefdir_entrydata pded_section,
   prefdir_context pdc
  PLAN (pded_root
   WHERE (pded_root.parent_id=- (1.00)))
   JOIN (pded_context
   WHERE pded_context.parent_id=pded_root.entry_id)
   JOIN (pded_section
   WHERE pded_section.parent_id=pded_context.entry_id)
   JOIN (pdc
   WHERE pdc.entry_id=pded_section.entry_id
    AND pdc.value_upper="ENCOUNTER")
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 IF (curqual > 0)
  CALL add_log_row("Working View Sections within ENCOUNTER Context",data_file,"")
 ELSE
  CALL add_log_row("Working View Sections within ENCOUNTER Context",data_file,"No Rows Returned")
 ENDIF
 SET data_file = "ec_inet_dta_def_fwd.csv"
 SELECT INTO value(data_file)
  dta.task_assay_cd, dta.mnemonic, dta.description,
  default_type_flag = evaluate(dta.default_type_flag,1,"Default from the reference range",2,
   "Default the last charted value",
   3,"Default from template script"), event_cd = uar_get_code_display(dta.event_cd)
  FROM discrete_task_assay dta
  WHERE  NOT (dta.default_type_flag IN (0, - (1)))
  ORDER BY dta.mnemonic
  WITH nocounter, pcformat('"',",",1), format = stream,
   maxcol = 10000
 ;end select
 IF (curqual > 0)
  CALL add_log_row("Defaulting forward at the DTA level",data_file,"")
 ELSE
  CALL add_log_row("Defaulting forward at the DTA level",data_file,"No Rows Returned")
 ENDIF
 SUBROUTINE add_log_row(rn,fn,err)
  DECLARE rpt_out = vc
  SELECT INTO value(logfile)
   DETAIL
    rpt_out = substring(1,45,rn), col 0, rpt_out,
    rpt_out = substring(1,45,fn), col 50, rpt_out,
    rpt_out = substring(1,30,err), col 100, rpt_out
   WITH nocounter, format = variable, noformfeed,
    maxcol = 132, maxrow = 1, append
  ;end select
 END ;Subroutine
END GO
