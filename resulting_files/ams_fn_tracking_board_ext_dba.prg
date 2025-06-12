CREATE PROGRAM ams_fn_tracking_board_ext:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email Address" = ""
  WITH outdev, p_email
 FREE RECORD rreport
 RECORD rreport(
   1 qual_knt = i4
   1 qual[*]
     2 rpt_name = vc
     2 col_name_knt = i4
     2 col_name[*]
       3 name = vc
     2 data_row_knt = i4
     2 data_row[*]
       3 data_col_knt = i4
       3 data_col[*]
         4 value = vc
 )
 DECLARE icurrentrpt = i2 WITH protect, noconstant(0)
 DECLARE imaxcolknt = i2 WITH protect, constant(14)
 DECLARE squote = c1 WITH protect, constant('"')
 DECLARE scomma = c1 WITH protect, constant(",")
 DECLARE slocalpath = vc WITH protect, noconstant(logical("cer_temp"))
 IF (cursys="AIX")
  IF (substring(size(trim(slocalpath,3)),1,slocalpath)="/")
   SET slocalpath = slocalpath
  ELSE
   SET slocalpath = concat(slocalpath,"/")
  ENDIF
 ENDIF
 DECLARE sfilename = vc WITH protect, constant(build2(slocalpath,trim(cnvtlower(curdomain),3),
   "_fn_tb_ex_",format(cnvtdatetime(curdate,curtime3),"yyyymmdd;;q"),".csv"))
 DECLARE srecordline = vc WITH protect, noconstant("")
 DECLARE email_file(mail_addr=vc,from_addr=vc,mail_sub=vc,attach_file_full=vc) = i2
 DECLARE bisanopsjob = i2 WITH protect, noconstant(false)
 IF (validate(request->batch_selection,"F")="F")
  SET ssendto = trim( $OUTDEV,3)
 ELSE
  SET bisanopsjob = true
 ENDIF
 CALL echo("***")
 CALL echo(build2("***   sFileName: ",sfilename))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Configure Tracking Lists")
 CALL echo("***")
 SET icurrentrpt = 1
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Configure Tracking Lists"
 SET rreport->qual[icurrentrpt].col_name_knt = 14
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,14)
 SET rreport->qual[icurrentrpt].col_name[1].name = "List_Description"
 SET rreport->qual[icurrentrpt].col_name[2].name = "List_Display"
 SET rreport->qual[icurrentrpt].col_name[3].name = "List_Type"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Bed_View"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Tracking_Group"
 SET rreport->qual[icurrentrpt].col_name[6].name = "Location_View"
 SET rreport->qual[icurrentrpt].col_name[7].name = "Column_View"
 SET rreport->qual[icurrentrpt].col_name[8].name = "Toolbar"
 SET rreport->qual[icurrentrpt].col_name[9].name = "List_Color"
 SET rreport->qual[icurrentrpt].col_name[10].name = "Auto_Refresh"
 SET rreport->qual[icurrentrpt].col_name[11].name = "Auto_Scroll"
 SET rreport->qual[icurrentrpt].col_name[12].name = "Solution"
 SET rreport->qual[icurrentrpt].col_name[13].name = "Last_Update"
 SET rreport->qual[icurrentrpt].col_name[14].name = "Last_Updated_By"
 SELECT INTO "nl:"
  list_description = tl.list_name, list_display = tl.list_display_txt, list_type = dm1.definition,
  bed_view = uar_get_code_display(tl.bed_view_cd), tracking_group = uar_get_code_display(tl
   .track_group_cd), location_view = uar_get_code_display(tl.location_view_cd),
  column_view = tv.view_name, toolbar = tag.group_name, list_color = tl.list_color_nbr,
  auto_refresh = tl.refresh_interval, auto_scroll = tl.scroll_interval, solution = dm2.definition,
  last_update = format(tl.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"), last_updated_by = p.name_full_formatted
  FROM track_list tl,
   track_view_field_list tv,
   track_action_group_reltn tagr,
   track_action_group tag,
   person p,
   dm_flags dm1,
   dm_flags dm2
  PLAN (tl)
   JOIN (p
   WHERE p.person_id=tl.updt_id)
   JOIN (tv
   WHERE tv.track_view_field_list_id=tl.track_view_field_list_id)
   JOIN (tagr
   WHERE tl.track_list_id=tagr.parent_entity_id)
   JOIN (tag
   WHERE tag.track_action_group_id=tagr.track_action_group_id)
   JOIN (dm1
   WHERE dm1.table_name="TRACK_FILTER"
    AND dm1.column_name="LIST_TYPE_FLAG"
    AND dm1.flag_value=tl.list_type_flag)
   JOIN (dm2
   WHERE dm2.table_name="TRACK_LIST"
    AND dm2.column_name="SOLUTION_FLAG"
    AND dm2.flag_value=tl.solution_flag)
  ORDER BY tl.list_name
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    list_description,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(list_display,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(list_type,3), rreport->qual[icurrentrpt].
   data_row[dknt].data_col[4].value = trim(bed_view,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(tracking_group,3), rreport->
   qual[icurrentrpt].data_row[dknt].data_col[6].value = trim(location_view,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[7].value = trim(column_view,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[8].value = trim(toolbar,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[9].value = trim(cnvtstring(list_color),3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[10].value = trim(cnvtstring(auto_refresh),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[11].value = trim(cnvtstring(auto_scroll),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[12].value = trim(solution,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[13].value = trim(last_update,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[14].value = trim(last_updated_by,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Toolbar Build")
 CALL echo("***")
 SET icurrentrpt = 2
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Toolbar Build"
 SET rreport->qual[icurrentrpt].col_name_knt = 6
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,6)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Toolbar"
 SET rreport->qual[icurrentrpt].col_name[2].name = "Action_Name"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Last_Update"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Last_Updated_By"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Group_Type_Flag"
 SET rreport->qual[icurrentrpt].col_name[6].name = "List_Type_Flag"
 SELECT INTO "nl:"
  toolbar = tag.group_name, action_name = ta.action_name, last_update = format(tag.updt_dt_tm,
   "mm/dd/yyyy hh:mm;;q"),
  last_updated_by = p.name_full_formatted, group_type_flag = tag.group_type_flag, list_type_flag =
  tag.list_type_flag
  FROM track_action ta,
   track_action_group tag,
   person p
  PLAN (ta)
   JOIN (tag
   WHERE tag.track_action_group_id=ta.parent_entity_id)
   JOIN (p
   WHERE p.person_id=tag.updt_id)
  ORDER BY tag.group_name, ta.action_seq
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    toolbar,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(action_name,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(last_update,3), rreport->qual[icurrentrpt].
   data_row[dknt].data_col[4].value = trim(last_updated_by,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(cnvtstring(group_type_flag),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[6].value = trim(cnvtstring(list_type_flag),3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Tracking List Assignments")
 CALL echo("***")
 SET icurrentrpt = 3
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Tracking List Assignments"
 SET rreport->qual[icurrentrpt].col_name_knt = 4
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,4)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Position"
 SET rreport->qual[icurrentrpt].col_name[2].name = "List_Display"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Last_Update"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Last_Updated_By"
 SELECT INTO "nl:"
  position = uar_get_code_display(tla.parent_entity_id), list_display = tl.list_name, last_update =
  format(tla.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"),
  last_updated_by = p.name_full_formatted
  FROM track_list_assignment tla,
   track_list tl,
   person p
  PLAN (tla
   WHERE ((tla.track_list_id+ 0) > 0))
   JOIN (tl
   WHERE tl.track_list_id=tla.track_list_id)
   JOIN (p
   WHERE p.person_id=tla.updt_id)
  ORDER BY uar_get_code_display(tla.parent_entity_id)
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    position,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(list_display,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(last_update,3), rreport->qual[icurrentrpt].
   data_row[dknt].data_col[4].value = trim(last_updated_by,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Tracking List Filter Build")
 CALL echo("***")
 SET icurrentrpt = 4
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Tracking List Filter Build"
 SET rreport->qual[icurrentrpt].col_name_knt = 12
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,12)
 SET rreport->qual[icurrentrpt].col_name[1].name = "List_Display"
 SET rreport->qual[icurrentrpt].col_name[2].name = "Filter_Display"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Filter_Type"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Operator"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Value"
 SET rreport->qual[icurrentrpt].col_name[6].name = "AND_"
 SET rreport->qual[icurrentrpt].col_name[7].name = "NOT_"
 SET rreport->qual[icurrentrpt].col_name[8].name = "OR_"
 SET rreport->qual[icurrentrpt].col_name[9].name = "Field_Enum"
 SET rreport->qual[icurrentrpt].col_name[10].name = "List_Type_Flag"
 SET rreport->qual[icurrentrpt].col_name[11].name = "Last_Filter_Reltn_Update"
 SET rreport->qual[icurrentrpt].col_name[12].name = "Last_Filter_Update_By"
 SELECT INTO "nl:"
  list_display = tl.list_name, filter_display = tf.filter_name, filter_type = dm1.definition,
  operator = dm2.definition, value = tfv.value_txt, and_ = evaluate(tf.and_ind,0,"",1,"AND"),
  not_ = evaluate(tf.not_ind,0,"",1,"NOT"), or_ = evaluate(tf.or_ind,0,"",1,"OR"), field_enum = tf
  .field_enum,
  list_type_flag = tf.list_type_flag, last_filter_reltn_update = format(tlf.updt_dt_tm,
   "mm/dd/yyyy hh:mm;;q"), last_filter_update_by = p.name_full_formatted
  FROM track_list_filter_reltn tlf,
   track_filter tf,
   track_list tl,
   track_filter_value tfv,
   person p,
   dm_flags dm1,
   dm_flags dm2
  PLAN (tlf)
   JOIN (tl
   WHERE tl.track_list_id=tlf.track_list_id)
   JOIN (tf
   WHERE tf.track_filter_id=tlf.track_filter_id)
   JOIN (tfv
   WHERE tfv.track_filter_id=tlf.track_filter_id)
   JOIN (p
   WHERE p.person_id=tf.updt_id)
   JOIN (dm1
   WHERE dm1.table_name="TRACK_FILTER"
    AND dm1.column_name="FILTER_TYPE_FLAG"
    AND dm1.flag_value=tf.filter_type_flag)
   JOIN (dm2
   WHERE dm2.table_name="TRACK_FILTER_VALUE"
    AND dm2.column_name="OPERATOR_FLAG"
    AND dm2.flag_value=tfv.operator_flag)
  ORDER BY tl.list_name
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    list_display,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(filter_display,3), rreport->
   qual[icurrentrpt].data_row[dknt].data_col[3].value = trim(filter_type,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[4].value = trim(operator,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(value,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[6].value = trim(and_,3), rreport->qual[icurrentrpt].data_row[
   dknt].data_col[7].value = trim(not_,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[8].value = trim(or_,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[9].value = trim(cnvtstring(field_enum),3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[10].value = trim(cnvtstring(list_type_flag),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[11].value = trim(last_filter_reltn_update,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[12].value = trim(last_filter_update_by,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Column Views")
 CALL echo("***")
 SET icurrentrpt = 5
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Column Views"
 SET rreport->qual[icurrentrpt].col_name_knt = 9
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,9)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Column_View_Name"
 SET rreport->qual[icurrentrpt].col_name[2].name = "Font"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Font_Size"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Font_Style"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Font_Color"
 SET rreport->qual[icurrentrpt].col_name[6].name = "Background_Color"
 SET rreport->qual[icurrentrpt].col_name[7].name = "Freeze_Column"
 SET rreport->qual[icurrentrpt].col_name[8].name = "Last_Update"
 SET rreport->qual[icurrentrpt].col_name[9].name = "Last_Updated_By"
 SELECT INTO "nl:"
  column_view_name = tv.view_name, font = tv.font_face, font_size = tv.font_size,
  font_style = evaluate(tv.font_style,0,"Null",1,"Bold",
   3,"Italics"), font_color = tv.font_color, background_color = tv.back_color,
  freeze_column = tv.freeze_field, last_update = format(tv.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"),
  last_updated_by = p.name_full_formatted
  FROM track_view_field_list tv,
   person p
  PLAN (tv
   WHERE ((tv.track_view_field_list_id+ 0) > 0))
   JOIN (p
   WHERE p.person_id=tv.updt_id)
  ORDER BY tv.view_name
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    column_view_name,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(font,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(cnvtstring(font_size),3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[4].value = trim(font_style,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(cnvtstring(font_color),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[6].value = trim(cnvtstring(background_color),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[7].value = trim(cnvtstring(freeze_column),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[8].value = trim(last_update,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[9].value = trim(last_updated_by,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Column Builds")
 CALL echo("***")
 SET icurrentrpt = 6
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Column Builds"
 SET rreport->qual[icurrentrpt].col_name_knt = 10
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,10)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Column_View_Name"
 SET rreport->qual[icurrentrpt].col_name[2].name = "Heading"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Selected_Field"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Display_Seq"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Width"
 SET rreport->qual[icurrentrpt].col_name[6].name = "Alignment"
 SET rreport->qual[icurrentrpt].col_name[7].name = "Wrap_Text"
 SET rreport->qual[icurrentrpt].col_name[8].name = "Read_Only"
 SET rreport->qual[icurrentrpt].col_name[9].name = "Last_Update"
 SET rreport->qual[icurrentrpt].col_name[10].name = "Last_Updated_By"
 SELECT INTO "nl:"
  column_view_name = tvl.view_name, heading = tfs.display_txt, selected_field = tfs.field_enum,
  display_seq = tfs.field_seq, width = tfs.display_width, alignment = dm.definition,
  wrap_text = evaluate(tfs.wrap_ind,0,"NO",1,"YES"), read_only = evaluate(tfs.read_only_ind,0,"NO",1,
   "YES"), last_update = format(tfs.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"),
  last_updated_by = p.name_full_formatted
  FROM track_field_spec tfs,
   track_view_field_list tvl,
   person p,
   dm_flags dm
  PLAN (tfs
   WHERE ((tfs.track_field_spec_id+ 0) > 0))
   JOIN (tvl
   WHERE tvl.track_view_field_list_id=tfs.track_view_field_list_id)
   JOIN (p
   WHERE p.person_id=tfs.updt_id)
   JOIN (dm
   WHERE dm.table_name="TRACK_FIELD_SPEC"
    AND dm.column_name="ALIGNMENT_FLAG"
    AND dm.flag_value=tfs.alignment_flag)
  ORDER BY tvl.view_name, tfs.field_seq
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    column_view_name,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(heading,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(cnvtstring(selected_field),3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[4].value = trim(cnvtstring(display_seq),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(cnvtstring(width,5,2),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[6].value = trim(alignment,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[7].value = trim(wrap_text,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[8].value = trim(read_only,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[9].value = trim(last_update,3), rreport->qual[icurrentrpt].
   data_row[dknt].data_col[10].value = trim(last_updated_by,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Custom Toolbar and Custom Menu")
 CALL echo("***")
 SET icurrentrpt = 7
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Custom Toolbar and Custom Menu"
 SET rreport->qual[icurrentrpt].col_name_knt = 5
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,5)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Group_Name"
 SET rreport->qual[icurrentrpt].col_name[2].name = "List_Type"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Toolbar_Menu"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Last_Updated_By"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Last_Updated"
 SELECT INTO "nl:"
  group_name = tag.group_name, list_type = dm1.definition, toolbar_menu = dm2.definition,
  last_updated_by = p.name_full_formatted, last_updated = format(tag.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"
   )
  FROM track_action_group tag,
   person p,
   dm_flags dm1,
   dm_flags dm2
  PLAN (tag
   WHERE tag.group_type_flag IN (1, 2))
   JOIN (p
   WHERE p.person_id=tag.updt_id)
   JOIN (dm1
   WHERE dm1.table_name="TRACK_VIEW_FIELD_LIST"
    AND dm1.column_name="LIST_TYPE_FLAG"
    AND dm1.flag_value=tag.list_type_flag)
   JOIN (dm2
   WHERE dm2.table_name="TRACK_ACTION_GROUP"
    AND dm2.column_name="GROUP_TYPE_FLAG"
    AND dm2.flag_value=tag.group_type_flag)
  ORDER BY tag.group_type_flag, tag.list_type_flag
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    group_name,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(list_type,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[3].value = trim(toolbar_menu,3), rreport->qual[icurrentrpt].
   data_row[dknt].data_col[4].value = trim(last_updated_by,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(last_updated,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Custom Toolbar and Custom Menu details")
 CALL echo("***")
 SET icurrentrpt = 8
 SET stat = alterlist(rreport->qual,icurrentrpt)
 SET rreport->qual_knt = icurrentrpt
 SET rreport->qual[icurrentrpt].rpt_name = "Custom Toolbar and Custom Menu Details"
 SET rreport->qual[icurrentrpt].col_name_knt = 5
 SET stat = alterlist(rreport->qual[icurrentrpt].col_name,5)
 SET rreport->qual[icurrentrpt].col_name[1].name = "Action"
 SET rreport->qual[icurrentrpt].col_name[2].name = "Group_Type_Flag"
 SET rreport->qual[icurrentrpt].col_name[3].name = "Toolbar_Menu"
 SET rreport->qual[icurrentrpt].col_name[4].name = "Last_Updated_By"
 SET rreport->qual[icurrentrpt].col_name[5].name = "Last_Updated"
 SELECT INTO "nl:"
  action = ta.action_name, group_type_flag = tag.group_type_flag, toolbar_menu = dm.definition,
  last_updated_by = p.name_full_formatted, last_updated = format(tag.updt_dt_tm,"mm/dd/yyyy hh:mm;;q"
   )
  FROM track_action ta,
   track_action_group tag,
   person p,
   dm_flags dm
  PLAN (ta
   WHERE ta.parent_entity_name="TRACK_ACTION_GROUP")
   JOIN (tag
   WHERE tag.track_action_group_id=ta.parent_entity_id
    AND tag.group_type_flag IN (1, 2))
   JOIN (p
   WHERE p.person_id=ta.updt_id)
   JOIN (dm
   WHERE dm.table_name="TRACK_ACTION_GROUP"
    AND dm.column_name="GROUP_TYPE_FLAG"
    AND dm.flag_value=tag.group_type_flag)
  ORDER BY ta.action_seq
  HEAD REPORT
   dknt = 0, stat = alterlist(rreport->qual[icurrentrpt].data_row,10)
  DETAIL
   dknt = (dknt+ 1)
   IF (mod(dknt,10)=1
    AND dknt != 1)
    stat = alterlist(rreport->qual[icurrentrpt].data_row,(dknt+ 9))
   ENDIF
   rreport->qual[icurrentrpt].data_row[dknt].data_col_knt = rreport->qual[icurrentrpt].col_name_knt,
   stat = alterlist(rreport->qual[icurrentrpt].data_row[dknt].data_col,rreport->qual[icurrentrpt].
    data_row[dknt].data_col_knt), rreport->qual[icurrentrpt].data_row[dknt].data_col[1].value = trim(
    action,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[2].value = trim(cnvtstring(group_type_flag),3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[3].value = trim(toolbar_menu,3), rreport->qual[
   icurrentrpt].data_row[dknt].data_col[4].value = trim(last_updated_by,3),
   rreport->qual[icurrentrpt].data_row[dknt].data_col[5].value = trim(last_updated,3)
  FOOT REPORT
   rreport->qual[icurrentrpt].data_row_knt = dknt, stat = alterlist(rreport->qual[icurrentrpt].
    data_row,dknt)
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo("***   Generate File")
 CALL echo("***")
 SELECT INTO value(sfilename)
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   icoltoadd = 0,
   MACRO (complete_record_line)
    FOR (adx = 1 TO icoltoadd)
      srecordline = build2(srecordline,scomma,squote,squote)
    ENDFOR
   ENDMACRO
   ,
   MACRO (add_record_header)
    srecordline = build2(squote,"@BOR ",trim(rreport->qual[idx].rpt_name,3),squote), icoltoadd = (
    imaxcolknt - 1), complete_record_line,
    col 0, srecordline, row + 1
   ENDMACRO
   ,
   MACRO (add_column_header)
    FOR (bdx = 1 TO rreport->qual[idx].col_name_knt)
      IF (bdx=1)
       srecordline = build2(squote,trim(rreport->qual[idx].col_name[bdx].name,3),squote)
      ELSE
       srecordline = build2(srecordline,scomma,squote,trim(rreport->qual[idx].col_name[bdx].name,3),
        squote)
      ENDIF
    ENDFOR
    icoltoadd = (imaxcolknt - rreport->qual[idx].col_name_knt), complete_record_line, col 0,
    srecordline, row + 1
   ENDMACRO
   ,
   MACRO (add_column_data)
    FOR (cdx = 1 TO rreport->qual[idx].data_row[jdx].data_col_knt)
      IF (cdx=1)
       srecordline = build2(squote,trim(rreport->qual[idx].data_row[jdx].data_col[cdx].value,3),
        squote)
      ELSE
       srecordline = build2(srecordline,scomma,squote,trim(rreport->qual[idx].data_row[jdx].data_col[
         cdx].value,3),squote)
      ENDIF
    ENDFOR
    icoltoadd = (imaxcolknt - rreport->qual[idx].data_row[jdx].data_col_knt), complete_record_line,
    col 0,
    srecordline, row + 1
   ENDMACRO
   ,
   MACRO (add_record_footer)
    srecordline = build2(squote,"@EOR ",trim(rreport->qual[idx].rpt_name,3),squote), icoltoadd = (
    imaxcolknt - 1), complete_record_line,
    col 0, srecordline, row + 1
   ENDMACRO
  DETAIL
   FOR (idx = 1 TO rreport->qual_knt)
     srecordline = "", add_record_header, srecordline = "",
     add_column_header
     FOR (jdx = 1 TO rreport->qual[idx].data_row_knt)
      srecordline = "",add_column_data
     ENDFOR
     add_record_footer
     IF ((idx != rreport->qual_knt))
      srecordline = build2(squote,squote), icoltoadd = (imaxcolknt - 1), complete_record_line,
      col 0, srecordline, row + 1
     ENDIF
   ENDFOR
  WITH nocounter, nullreport, formfeed = none,
   format = crstream, maxcol = 2000, maxrow = 1
 ;end select
 CALL echo("***")
 CALL echo("***   Email File")
 CALL echo("***")
 SET stat = email_file( $P_EMAIL,"cerner","FirstNet Tracking Board Extract",sfilename)
 IF (bisanopsjob=false)
  SET smsg = build2(sfilename," sent to ", $P_EMAIL)
  SELECT INTO value(ssendto)
   message = trim(substring(1,100,smsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, skipreport = 1
  ;end select
 ENDIF
 SUBROUTINE email_file(mail_addr,from_addr,mail_sub,attach_file_full)
   DECLARE ccl_ver = i4 WITH private, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
   DECLARE start_pos = i4 WITH private, noconstant(0)
   DECLARE cur_pos = i4 WITH private, noconstant(0)
   DECLARE end_flag = i2 WITH private, noconstant(0)
   DECLARE stemp = vc WITH private, noconstant("")
   DECLARE mail_to = vc WITH private, noconstant("")
   DECLARE attach_file = vc WITH private, noconstant("")
   DECLARE dclcom = vc WITH private, noconstant("")
   DECLARE dclstatus = i2 WITH private, noconstant(1)
   IF (cursys != "AIX")
    RETURN(0)
   ENDIF
   SET start_pos = 1
   SET cur_pos = 1
   SET end_flag = 0
   WHILE (end_flag=0
    AND cur_pos < 500)
     SET stemp = piece(mail_addr,";",cur_pos,"Not Found")
     IF (stemp != "Not Found")
      IF (cursys="AIX")
       IF (size(trim(mail_to))=0)
        SET mail_to = stemp
       ELSE
        SET mail_to = concat(mail_to," ",stemp)
       ENDIF
      ENDIF
     ELSE
      SET end_flag = 1
     ENDIF
     SET cur_pos = (cur_pos+ 1)
   ENDWHILE
   SET start_pos = 1
   IF (cursys="AIX")
    SET cur_pos = findstring("/",attach_file_full,start_pos,1)
    IF (cur_pos < 1)
     SET attach_file = trim(attach_file_full,3)
    ELSE
     SET attach_file = trim(substring((cur_pos+ 1),((size(attach_file_full) - cur_pos)+ 1),
       attach_file_full),3)
    ENDIF
   ENDIF
   IF (cursys2="AIX")
    SET dclcom = concat("uuencode ",attach_file_full," ",attach_file," ",
     '|mailx -s "',mail_sub,'" ',"-r ",from_addr,
     " ",mail_to)
   ELSEIF (cursys2="HPX")
    SET dclcom = concat("uuencode ",attach_file_full," ",attach_file," ",
     '|mailx -m -s "',mail_sub,'" ',"-r ",from_addr,
     " ",mail_to)
   ELSEIF (cursys2="LNX")
    SET dclcom = concat("uuencode ",attach_file_full," ",attach_file," ",
     '|mailx -s "',mail_sub,'" '," ",mail_to)
   ENDIF
   CALL dcl(dclcom,size(trim(dclcom)),dclstatus)
   IF (dclstatus=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo("***")
 CALL echo(build2("***   sFileName: ",sfilename))
 CALL echo("***")
 SET script_ver = "002 04/09/12 More Modifications"
END GO
