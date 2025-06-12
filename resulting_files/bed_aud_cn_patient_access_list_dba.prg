CREATE PROGRAM bed_aud_cn_patient_access_list:dba
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
   1 positions[*]
     2 position_disp = vc
     2 locations[*]
       3 location_disp = vc
       3 sections[*]
         4 section_type = vc
         4 section_seq = i4
         4 columns[*]
           5 column_type = vc
           5 column_label = vc
           5 column_seq = i4
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pip p,
    code_value cv1,
    pip_section ps,
    code_value cv3,
    pip_column pc
   PLAN (p)
    JOIN (cv1
    WHERE cv1.code_value=p.position_cd
     AND cv1.active_ind=1)
    JOIN (ps
    WHERE ps.pip_id=p.pip_id)
    JOIN (cv3
    WHERE cv3.code_value=ps.section_type_cd
     AND cv3.active_ind=1)
    JOIN (pc
    WHERE pc.pip_section_id=outerjoin(ps.pip_section_id)
     AND pc.prsnl_id=0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET pcnt = 0
 SET lcnt = 0
 SET scnt = 0
 SET ccnt = 0
 SELECT INTO "NL:"
  FROM pip p,
   code_value cv1,
   code_value cv2,
   pip_section ps,
   code_value cv3,
   pip_column pc,
   code_value cv4,
   pip_prefs pp
  PLAN (p)
   JOIN (cv1
   WHERE cv1.code_value=p.position_cd
    AND cv1.active_ind=1)
   JOIN (ps
   WHERE ps.pip_id=p.pip_id)
   JOIN (cv3
   WHERE cv3.code_value=ps.section_type_cd
    AND cv3.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(p.location_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (pc
   WHERE pc.pip_section_id=outerjoin(ps.pip_section_id)
    AND pc.prsnl_id=0)
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(pc.column_type_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (pp
   WHERE pp.parent_entity_id=outerjoin(pc.pip_column_id)
    AND pp.pref_name=outerjoin("TITLE"))
  ORDER BY cv1.display, cv2.display, ps.sequence,
   pc.sequence, p.position_cd, p.location_cd,
   ps.pip_section_id
  HEAD p.position_cd
   pcnt = (pcnt+ 1), stat = alterlist(temp->positions,pcnt), temp->positions[pcnt].position_disp =
   cv1.display,
   lcnt = 0
  HEAD p.location_cd
   lcnt = (lcnt+ 1), stat = alterlist(temp->positions[pcnt].locations,lcnt)
   IF (cv2.display=" ")
    temp->positions[pcnt].locations[lcnt].location_disp = "<none>"
   ELSE
    temp->positions[pcnt].locations[lcnt].location_disp = cv2.display
   ENDIF
   scnt = 0
  HEAD ps.pip_section_id
   scnt = (scnt+ 1), stat = alterlist(temp->positions[pcnt].locations[lcnt].sections,scnt), temp->
   positions[pcnt].locations[lcnt].sections[scnt].section_type = cv3.display,
   temp->positions[pcnt].locations[lcnt].sections[scnt].section_seq = ps.sequence, ccnt = 0
  DETAIL
   IF (cv4.display > " ")
    ccnt = (ccnt+ 1), stat = alterlist(temp->positions[pcnt].locations[lcnt].sections[scnt].columns,
     ccnt), temp->positions[pcnt].locations[lcnt].sections[scnt].columns[ccnt].column_type = cv4
    .display,
    temp->positions[pcnt].locations[lcnt].sections[scnt].columns[ccnt].column_label = pp.pref_value,
    temp->positions[pcnt].locations[lcnt].sections[scnt].columns[ccnt].column_seq = pc.sequence
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Position"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Section"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Section Sequence"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Column Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Column Label"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Column Sequence"
 SET reply->collist[7].data_type = 3
 SET reply->collist[7].hide_ind = 0
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (p = 1 TO pcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->positions[p].position_disp
   SET lcnt = size(temp->positions[p].locations,5)
   FOR (x = 1 TO lcnt)
     IF (x > 1)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
     ENDIF
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->positions[p].locations[x].
     location_disp
     SET scnt = size(temp->positions[p].locations[x].sections,5)
     FOR (s = 1 TO scnt)
       IF (s > 1)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
       ENDIF
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->positions[p].locations[x].
       sections[s].section_type
       IF ((temp->positions[p].locations[x].sections[s].section_seq=0))
        SET reply->rowlist[row_nbr].celllist[4].string_value = " "
       ELSE
        SET reply->rowlist[row_nbr].celllist[4].string_value = cnvtstring(temp->positions[p].
         locations[x].sections[s].section_seq)
       ENDIF
       SET ccnt = size(temp->positions[p].locations[x].sections[s].columns,5)
       FOR (c = 1 TO ccnt)
         IF (c > 1)
          SET row_nbr = (row_nbr+ 1)
          SET stat = alterlist(reply->rowlist,row_nbr)
          SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
         ENDIF
         SET reply->rowlist[row_nbr].celllist[5].string_value = temp->positions[p].locations[x].
         sections[s].columns[c].column_type
         SET reply->rowlist[row_nbr].celllist[6].string_value = temp->positions[p].locations[x].
         sections[s].columns[c].column_label
         SET reply->rowlist[row_nbr].celllist[7].nbr_value = temp->positions[p].locations[x].
         sections[s].columns[c].column_seq
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_patient_access_list.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
