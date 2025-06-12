CREATE PROGRAM bed_aud_chart_format:dba
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
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Chart Format Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Section Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Group Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Event Set(s)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 FREE SET temp
 RECORD temp(
   1 chart[*]
     2 name = vc
     2 sect[*]
       3 name = vc
       3 type = vc
       3 grp[*]
         4 name = vc
         4 event[*]
           5 name = vc
 )
 SET fcnt = 0
 SET scnt = 0
 SET gcnt = 0
 SET ecnt = 0
 SELECT INTO "nl:"
  FROM chart_format f,
   chart_form_sects fs,
   chart_section s,
   chart_group g,
   chart_grp_evnt_set es
  PLAN (f
   WHERE f.active_ind=1)
   JOIN (fs
   WHERE fs.chart_format_id=f.chart_format_id
    AND fs.active_ind=1)
   JOIN (s
   WHERE s.chart_section_id=fs.chart_section_id
    AND s.active_ind=1)
   JOIN (g
   WHERE g.chart_section_id=s.chart_section_id
    AND g.active_ind=1)
   JOIN (es
   WHERE es.chart_group_id=outerjoin(g.chart_group_id)
    AND es.active_ind=outerjoin(1))
  ORDER BY f.chart_format_desc, fs.cs_sequence_num, g.cg_sequence,
   es.event_set_seq
  HEAD f.chart_format_id
   scnt = 0, gcnt = 0, ecnt = 0,
   fcnt = (fcnt+ 1), stat = alterlist(temp->chart,fcnt), temp->chart[fcnt].name = f.chart_format_desc
  HEAD s.chart_section_id
   gcnt = 0, ecnt = 0, scnt = (scnt+ 1),
   stat = alterlist(temp->chart[fcnt].sect,scnt), temp->chart[fcnt].sect[scnt].name = s
   .chart_section_desc
   CASE (s.section_type_flag)
    OF 4:
     temp->chart[fcnt].sect[scnt].type = "Cross Encounter Summary"
    OF 5:
     temp->chart[fcnt].sect[scnt].type = "Encounter Comment"
    OF 6:
     temp->chart[fcnt].sect[scnt].type = "Blood Bank"
    OF 9:
     temp->chart[fcnt].sect[scnt].type = "Horizontal"
    OF 10:
     temp->chart[fcnt].sect[scnt].type = "Microbiology"
    OF 11:
     temp->chart[fcnt].sect[scnt].type = "Order Summary"
    OF 14:
     temp->chart[fcnt].sect[scnt].type = "Text(Radiology)"
    OF 16:
     temp->chart[fcnt].sect[scnt].type = "Vertical"
    OF 17:
     temp->chart[fcnt].sect[scnt].type = "Old Zonal"
    OF 18:
     temp->chart[fcnt].sect[scnt].type = "Text(Anatomic Pathology)"
    OF 21:
     temp->chart[fcnt].sect[scnt].type = "PowerForm"
    OF 22:
     temp->chart[fcnt].sect[scnt].type = "HLA"
    OF 25:
     temp->chart[fcnt].sect[scnt].type = "Document"
    OF 27:
     temp->chart[fcnt].sect[scnt].type = "GL Text"
    OF 30:
     temp->chart[fcnt].sect[scnt].type = "Allergy List"
    OF 31:
     temp->chart[fcnt].sect[scnt].type = "Problem List"
    OF 32:
     temp->chart[fcnt].sect[scnt].type = "Zonal"
    OF 33:
     temp->chart[fcnt].sect[scnt].type = "Orders"
    OF 34:
     temp->chart[fcnt].sect[scnt].type = "MAR"
    OF 35:
     temp->chart[fcnt].sect[scnt].type = "Name History"
    OF 37:
     temp->chart[fcnt].sect[scnt].type = "Immunization"
    OF 38:
     temp->chart[fcnt].sect[scnt].type = "Procedure History"
    OF 39:
     temp->chart[fcnt].sect[scnt].type = "Endorse Comment"
    OF 40:
     temp->chart[fcnt].sect[scnt].type = "Care Plan"
    OF 41:
     temp->chart[fcnt].sect[scnt].type = "MAR"
    OF 42:
     temp->chart[fcnt].sect[scnt].type = "I&O"
    OF 43:
     temp->chart[fcnt].sect[scnt].type = "Medication Profile Historical"
    OF 44:
     temp->chart[fcnt].sect[scnt].type = "Generic Discern Report"
    OF 45:
     temp->chart[fcnt].sect[scnt].type = "Listview"
   ENDCASE
  HEAD g.cg_sequence
   ecnt = 0, gcnt = (gcnt+ 1), stat = alterlist(temp->chart[fcnt].sect[scnt].grp,gcnt)
   IF (g.chart_group_desc > " ")
    temp->chart[fcnt].sect[scnt].grp[gcnt].name = g.chart_group_desc
   ELSE
    temp->chart[fcnt].sect[scnt].grp[gcnt].name = concat("Group",cnvtstring(gcnt))
   ENDIF
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(temp->chart[fcnt].sect[scnt].grp[gcnt].event,ecnt), temp->
   chart[fcnt].sect[scnt].grp[gcnt].event[ecnt].name = es.event_set_name
   IF (es.order_catalog_cd > 0)
    temp->chart[fcnt].sect[scnt].grp[gcnt].event[ecnt].name = uar_get_code_display(es
     .order_catalog_cd)
   ENDIF
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (w = 1 TO fcnt)
   FOR (x = 1 TO size(temp->chart[w].sect,5))
     FOR (y = 1 TO size(temp->chart[w].sect[x].grp,5))
       SET rcnt = (rcnt+ 1)
       SET stat = alterlist(reply->rowlist,rcnt)
       SET stat = alterlist(reply->rowlist[rcnt].celllist,5)
       SET reply->rowlist[rcnt].celllist[1].string_value = temp->chart[w].name
       SET reply->rowlist[rcnt].celllist[2].string_value = temp->chart[w].sect[x].name
       SET reply->rowlist[rcnt].celllist[3].string_value = temp->chart[w].sect[x].type
       SET reply->rowlist[rcnt].celllist[4].string_value = temp->chart[w].sect[x].grp[y].name
       FOR (z = 1 TO size(temp->chart[w].sect[x].grp[y].event,5))
         IF (z=1)
          SET reply->rowlist[rcnt].celllist[5].string_value = temp->chart[w].sect[x].grp[y].event[z].
          name
         ELSE
          SET rcnt = (rcnt+ 1)
          SET stat = alterlist(reply->rowlist,rcnt)
          SET stat = alterlist(reply->rowlist[rcnt].celllist,5)
          SET reply->rowlist[rcnt].celllist[5].string_value = temp->chart[w].sect[x].grp[y].event[z].
          name
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 IF (rcnt > 60000)
  SET reply->high_volume_flag = 2
  SET stat = alterlist(reply->collist,0)
  SET stat = alterlist(reply->rowlist,0)
  SET reply->output_filename = build("chart_format_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
