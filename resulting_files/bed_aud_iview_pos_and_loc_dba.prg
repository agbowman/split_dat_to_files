CREATE PROGRAM bed_aud_iview_pos_and_loc:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 entry_id = f8
     2 position_code_value = f8
     2 location_code_value = f8
     2 position_display = vc
     2 location_display = vc
 )
 FREE RECORD count_temp
 RECORD count_temp(
   1 tqual[*]
     2 entry_id = f8
 )
 FREE RECORD sort_temp
 RECORD sort_temp(
   1 tqual[*]
     2 entry_id = f8
     2 position_display = vc
     2 location_display = vc
     2 views[*]
       3 display = vc
       3 view_name = vc
       3 view_disp = vc
       3 parse_statement = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET pref_parse = ' p1.dist_name_short = "prefcontext=position*"'
  SET tcnt = 0
  SELECT INTO "NL:"
   FROM prefdir_entrydata p0,
    prefdir_entrydata p1,
    prefdir_entrydata p2
   PLAN (p0
    WHERE p0.dist_name_short="prefroot=prefroot")
    JOIN (p1
    WHERE p1.parent_id=p0.entry_id
     AND parser(pref_parse))
    JOIN (p2
    WHERE p2.parent_id=p1.entry_id)
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(count_temp->tqual,tcnt), count_temp->tqual[tcnt].entry_id = p2
    .entry_id
   WITH nocounter
  ;end select
  IF (tcnt > 0)
   SET p2_parse = ' p2.dist_name_short = "prefgroup=component*"'
   SET p3_parse = ' p3.dist_name_short = "prefgroup=powerdoc*"'
   SET p4_parse = ' p4.dist_name_short = "prefentry=documentsettypes*"'
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt),
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4
    PLAN (d)
     JOIN (p2
     WHERE (p2.parent_id=count_temp->tqual[d.seq].entry_id)
      AND parser(p2_parse))
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND parser(p3_parse))
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND parser(p4_parse))
    HEAD d.seq
     vcnt = 0
    DETAIL
     search_ind = 1, start_pos = 1
     WHILE (search_ind=1)
      beg_pos = findstring("prefvalue:",p4.entry_data,start_pos),
      IF (beg_pos=0)
       search_ind = 0
      ELSE
       beg_pos = (beg_pos+ 10), end_pos = findstring("prefvalue:",p4.entry_data,beg_pos)
       IF (end_pos=0)
        end_pos = (findstring("pref",p4.entry_data,beg_pos) - 2), search_ind = 0
       ELSE
        end_pos = (end_pos - 2)
       ENDIF
       high_volume_cnt = (high_volume_cnt+ 1), start_pos = end_pos
      ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build("********************* high_volume_cnt = ",high_volume_cnt))
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET pref_parse = ' p1.dist_name_short = "prefcontext=position*"'
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM prefdir_entrydata p0,
   prefdir_entrydata p1,
   prefdir_entrydata p2
  PLAN (p0
   WHERE p0.dist_name_short="prefroot=prefroot")
   JOIN (p1
   WHERE p1.parent_id=p0.entry_id
    AND parser(pref_parse))
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id)
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].entry_id = p2.entry_id,
   a = findstring("prefgroup=",p2.dist_name,1,1), b = findstring("=",p2.dist_name,a), c = findstring(
    ",",p2.dist_name,a),
   grpstr = substring((b+ 1),((c - b) - 1),p2.dist_name), a = findstring("prefcontext=",p2.dist_name,
    1), b = findstring("=",p2.dist_name,a),
   c = findstring(",",p2.dist_name,(b+ 1)), cxtstr = substring((b+ 1),((c - b) - 1),p2.dist_name)
   IF (cxtstr="position")
    temp->tqual[tcnt].position_code_value = cnvtint(grpstr), temp->tqual[tcnt].location_code_value =
    0
   ELSEIF (cxtstr="position location")
    a = findstring("^",grpstr), temp->tqual[tcnt].position_code_value = cnvtint(substring(1,(a - 1),
      grpstr)), b = textlen(grpstr),
    temp->tqual[tcnt].location_code_value = cnvtint(substring((a+ 1),((b - a) - 1),grpstr)),
    CALL echo(build("cd1: ",temp->tqual[tcnt].location_code_value))
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Position"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location (if left blank it is a position level preference)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "View Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "View Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(sort_temp->tqual,tcnt)
 SET sort_cnt = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   code_value cv1,
   code_value cv2,
   dummyt d1
  PLAN (d
   WHERE (temp->tqual[d.seq].position_code_value > 0))
   JOIN (cv1
   WHERE (cv1.code_value=temp->tqual[d.seq].position_code_value)
    AND cv1.active_ind=1)
   JOIN (d1)
   JOIN (cv2
   WHERE (cv2.code_value=temp->tqual[d.seq].location_code_value)
    AND cv2.active_ind=1)
  ORDER BY cv1.display_key, cv2.display_key
  DETAIL
   sort_cnt = (sort_cnt+ 1), temp->tqual[d.seq].location_display = cv2.display, temp->tqual[d.seq].
   position_display = cv1.display,
   sort_temp->tqual[sort_cnt].position_display = temp->tqual[d.seq].position_display, sort_temp->
   tqual[sort_cnt].location_display = temp->tqual[d.seq].location_display, sort_temp->tqual[sort_cnt]
   .entry_id = temp->tqual[d.seq].entry_id
  WITH nocounter, outerjoin = d1
 ;end select
 SET max_views = 0
 SET p2_parse = ' p2.dist_name_short = "prefgroup=component*"'
 SET p3_parse = ' p3.dist_name_short = "prefgroup=powerdoc*"'
 SET p4_parse = ' p4.dist_name_short = "prefentry=documentsettypes*"'
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4
  PLAN (d)
   JOIN (p2
   WHERE (p2.parent_id=sort_temp->tqual[d.seq].entry_id)
    AND parser(p2_parse))
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND parser(p3_parse))
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id
    AND parser(p4_parse))
  HEAD d.seq
   vcnt = 0
  DETAIL
   search_ind = 1, start_pos = 1
   WHILE (search_ind=1)
    beg_pos = findstring("prefvalue:",p4.entry_data,start_pos),
    IF (beg_pos=0)
     search_ind = 0
    ELSE
     beg_pos = (beg_pos+ 10), end_pos = findstring("prefvalue:",p4.entry_data,beg_pos)
     IF (end_pos=0)
      end_pos = (findstring("pref",p4.entry_data,beg_pos) - 2), search_ind = 0
     ELSE
      end_pos = (end_pos - 2)
     ENDIF
     len = ((end_pos - beg_pos)+ 1), vcnt = (vcnt+ 1), stat = alterlist(sort_temp->tqual[d.seq].views,
      vcnt)
     IF (vcnt > max_views)
      max_views = vcnt
     ENDIF
     sort_temp->tqual[d.seq].views[vcnt].display = trim(substring(beg_pos,len,p4.entry_data)),
     sort_temp->tqual[d.seq].views[vcnt].view_name = trim(substring(beg_pos,len,p4.entry_data)),
     sort_temp->tqual[d.seq].views[vcnt].parse_statement = build("prefgroup=",sort_temp->tqual[d.seq]
      .views[vcnt].display,",%"),
     start_pos = end_pos
    ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = value(max_views)),
   working_view wv
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(sort_temp->tqual[d1.seq].views,5))
   JOIN (wv
   WHERE cnvtupper(wv.display_name)=cnvtupper(sort_temp->tqual[d1.seq].views[d2.seq].display))
  DETAIL
   sort_temp->tqual[d1.seq].views[d2.seq].view_name = wv.display_name
  WITH nocounter
 ;end select
 SET p5_parse = ' p2.dist_name_short = "prefgroup=docsettypes*"'
 SET p7_parse = ' p4.dist_name_short = "prefentry=displayname*"'
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = tcnt),
   (dummyt d2  WITH seq = value(max_views)),
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(sort_temp->tqual[d1.seq].views,5))
   JOIN (p2
   WHERE parser(p5_parse))
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND operator(p3.dist_name,"LIKE",patstring(sort_temp->tqual[d1.seq].views[d2.seq].parse_statement,
     1)))
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id
    AND parser(p7_parse))
  HEAD REPORT
   ccnt = 0
  DETAIL
   search_ind = 1, start_pos = 1, beg_pos = findstring("prefvalue:",p4.entry_data,start_pos)
   IF (beg_pos=0)
    search_ind = 0
   ELSE
    beg_pos = (beg_pos+ 10), end_pos = (findstring("pref",p4.entry_data,beg_pos) - 2), search_ind = 0,
    len = ((end_pos - beg_pos)+ 1), sort_temp->tqual[d1.seq].views[d2.seq].view_disp = trim(substring
     (beg_pos,len,p4.entry_data)), start_pos = end_pos
   ENDIF
  WITH nocounter
 ;end select
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
  SET vcnt = size(sort_temp->tqual[x].views,5)
  IF (vcnt > 0)
   FOR (v = 1 TO vcnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
     SET reply->rowlist[row_nbr].celllist[1].string_value = sort_temp->tqual[x].position_display
     SET reply->rowlist[row_nbr].celllist[2].string_value = sort_temp->tqual[x].location_display
     SET reply->rowlist[row_nbr].celllist[3].string_value = sort_temp->tqual[x].views[v].view_disp
     SET reply->rowlist[row_nbr].celllist[4].string_value = sort_temp->tqual[x].views[v].view_name
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_pos_and_loc.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
