CREATE PROGRAM dcp_ver_working_view:dba
 SET modify = predeclare
 RECORD temp(
   1 position_cd = f8
   1 location_cd = f8
   1 new_working_view_id = f8
   1 orig_working_view_id = f8
   1 display_name = vc
   1 active_ind = i2
   1 version_num = f8
   1 current_working_view = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 working_view_sections[*]
     2 working_view_section_id = f8
     2 event_set_name = vc
     2 required_ind = i2
     2 included_ind = i2
     2 falloff_view_minutes = i4
     2 section_type_flag = i2
     2 display_name = vc
     2 working_view_items[*]
       3 working_view_section_id = f8
       3 working_view_item_id = f8
       3 primitive_event_set_name = vc
       3 parent_event_set_name = vc
       3 included_ind = i2
       3 falloff_view_minutes = f8
 )
 DECLARE wv_where = vc WITH noconstant(fillstring(1000,""))
 DECLARE section_counter = i4 WITH noconstant(0)
 DECLARE item_counter = i4 WITH noconstant(0)
 DECLARE temp_working_view_id = f8 WITH noconstant(0.0)
 DECLARE temp_working_view_section_id = f8 WITH noconstant(0.0)
 DECLARE num_of_sections = i4 WITH noconstant(0)
 DECLARE num_of_items = i4 WITH noconstant(0)
 DECLARE q = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE fail = c1 WITH noconstant("F")
 IF ((request->current_working_view=0))
  SET wv_where = "wv.working_view_id = request->working_view_id"
 ELSE
  SET wv_where = "wv.working_view_id = request->current_working_view"
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   temp_working_view_id = nextseqnum
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_msg = "unable to generate sequence for working_view table"
  SET fail = "T"
  CALL log_status("SEQUENCE","F","WORKING_VIEW",err_msg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi
  PLAN (wv
   WHERE parser(wv_where))
   JOIN (wvs
   WHERE wvs.working_view_id=outerjoin(wv.working_view_id))
   JOIN (wvi
   WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
  ORDER BY wv.working_view_id, wvs.working_view_section_id, wvi.working_view_item_id
  HEAD wv.working_view_id
   section_counter = 0, temp->new_working_view_id = temp_working_view_id, temp->orig_working_view_id
    = wv.working_view_id,
   temp->version_num = wv.version_num, temp->current_working_view = wv.current_working_view, temp->
   active_ind = wv.active_ind,
   temp->beg_effective_dt_tm = cnvtdatetime(wv.beg_effective_dt_tm), temp->end_effective_dt_tm =
   cnvtdatetime(wv.end_effective_dt_tm), temp->position_cd = wv.position_cd,
   temp->location_cd = wv.location_cd, temp->display_name = wv.display_name
  HEAD wvs.working_view_section_id
   item_counter = 0
   IF (wvs.working_view_section_id > 0)
    section_counter = (section_counter+ 1)
    IF (mod(section_counter,10)=1)
     stat = alterlist(temp->working_view_sections,(section_counter+ 9))
    ENDIF
    temp->working_view_sections[section_counter].event_set_name = wvs.event_set_name, temp->
    working_view_sections[section_counter].required_ind = wvs.required_ind, temp->
    working_view_sections[section_counter].included_ind = wvs.included_ind,
    temp->working_view_sections[section_counter].falloff_view_minutes = wvs.falloff_view_minutes,
    temp->working_view_sections[section_counter].section_type_flag = wvs.section_type_flag, temp->
    working_view_sections[section_counter].display_name = wvs.display_name
   ENDIF
  HEAD wvi.working_view_item_id
   IF (wvi.working_view_item_id > 0)
    item_counter = (item_counter+ 1)
    IF (mod(item_counter,10)=1)
     stat = alterlist(temp->working_view_sections[section_counter].working_view_items,(item_counter+
      9))
    ENDIF
    temp->working_view_sections[section_counter].working_view_items[item_counter].
    primitive_event_set_name = wvi.primitive_event_set_name, temp->working_view_sections[
    section_counter].working_view_items[item_counter].parent_event_set_name = wvi
    .parent_event_set_name, temp->working_view_sections[section_counter].working_view_items[
    item_counter].included_ind = wvi.included_ind,
    temp->working_view_sections[section_counter].working_view_items[item_counter].
    falloff_view_minutes = wvi.falloff_view_minutes
   ENDIF
  FOOT  wvs.working_view_section_id
   IF (wvs.working_view_section_id > 0)
    stat = alterlist(temp->working_view_sections[section_counter].working_view_items,item_counter)
   ENDIF
  FOOT  wv.working_view_id
   IF (wv.working_view_id > 0)
    stat = alterlist(temp->working_view_sections,section_counter)
   ENDIF
  WITH nocounter
 ;end select
 INSERT  FROM working_view wv
  SET wv.working_view_id = temp_working_view_id, wv.current_working_view = temp->orig_working_view_id,
   wv.display_name = temp->display_name,
   wv.position_cd = temp->position_cd, wv.location_cd = temp->location_cd, wv.version_num = temp->
   version_num,
   wv.beg_effective_dt_tm = cnvtdatetime(temp->beg_effective_dt_tm), wv.end_effective_dt_tm =
   cnvtdatetime(curdate,curtime3), wv.active_ind = 0,
   wv.active_status_cd = reqdata->active_status_cd, wv.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), wv.active_status_prsnl_id = reqinfo->updt_id,
   wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = 0, wv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET err_msg = "unable to insert into working_view table"
  SET fail = "T"
  CALL log_status("INSERT","F","WORKING_VIEW",err_msg)
  GO TO exit_script
 ENDIF
 SET num_of_sections = size(temp->working_view_sections,5)
 FOR (q = 1 TO num_of_sections)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     temp_working_view_section_id = nextseqnum
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_msg = "unable to generate sequence for working_view_section table"
    SET fail = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_SECTION",err_msg)
    GO TO exit_script
   ENDIF
   INSERT  FROM working_view_section wvs
    SET wvs.working_view_section_id = temp_working_view_section_id, wvs.working_view_id =
     temp_working_view_id, wvs.event_set_name = temp->working_view_sections[q].event_set_name,
     wvs.required_ind = temp->working_view_sections[q].required_ind, wvs.included_ind = temp->
     working_view_sections[q].included_ind, wvs.falloff_view_minutes = temp->working_view_sections[q]
     .falloff_view_minutes,
     wvs.section_type_flag = temp->working_view_sections[q].section_type_flag, wvs.display_name =
     temp->working_view_sections[q].display_name, wvs.updt_applctx = reqinfo->updt_applctx,
     wvs.updt_cnt = 0, wvs.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvs.updt_id = reqinfo->
     updt_id,
     wvs.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET err_msg = "unable to insert into working_view_section table"
    SET fail = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_SECTION",err_msg)
    GO TO exit_script
   ENDIF
   SET num_of_items = size(temp->working_view_sections[q].working_view_items,5)
   FOR (j = 1 TO num_of_items)
    INSERT  FROM working_view_item wvi
     SET wvi.working_view_item_id = seq(carenet_seq,nextval), wvi.working_view_section_id =
      temp_working_view_section_id, wvi.primitive_event_set_name = temp->working_view_sections[q].
      working_view_items[j].primitive_event_set_name,
      wvi.parent_event_set_name = temp->working_view_sections[q].working_view_items[j].
      parent_event_set_name, wvi.included_ind = temp->working_view_sections[q].working_view_items[j].
      included_ind, wvi.updt_applctx = reqinfo->updt_applctx,
      wvi.updt_cnt = 0, wvi.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvi.updt_id = reqinfo->
      updt_id,
      wvi.updt_task = reqinfo->updt_task, wvi.falloff_view_minutes = temp->working_view_sections[q].
      working_view_items[j].falloff_view_minutes
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET err_msg = "unable to insert into working_view_item table"
     SET fail = "T"
     CALL log_status("INSERT","F","WORKING_VIEW_ITEM",err_msg)
     GO TO exit_script
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM working_view wv
  WHERE (wv.working_view_id=temp->orig_working_view_id)
  WITH nocounter, forupdate(wv)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM working_view wv
   SET wv.version_num = (wv.version_num+ 1), wv.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    wv.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
    wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = (wv.updt_cnt+ 1), wv.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
   WHERE (wv.working_view_id=temp->orig_working_view_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET err_msg = "unable to update working_view table"
   SET fail = "T"
   CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 FREE RECORD temp
 RETURN(fail)
END GO
