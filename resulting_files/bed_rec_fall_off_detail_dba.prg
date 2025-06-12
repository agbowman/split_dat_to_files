CREATE PROGRAM bed_rec_fall_off_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET col_cnt = 9
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Position"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Working View"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Working View Section"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Working View Item"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Actual Setting"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Recommended Setting"
 SET reply->collist[8].data_type = 3
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Resolution"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="IVIEWFALLOFFTIME"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IVIEWFALLOFFTIME")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM working_view wv,
      working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code v,
      v500_event_set_code v2,
      code_value pos,
      code_value loc
     PLAN (wvi
      WHERE wvi.falloff_view_minutes > 0)
      JOIN (wvs
      WHERE wvs.working_view_section_id=wvi.working_view_section_id)
      JOIN (v
      WHERE v.event_set_name=wvi.primitive_event_set_name)
      JOIN (v2
      WHERE v2.event_set_name=wvs.event_set_name)
      JOIN (wv
      WHERE wv.working_view_id=wvs.working_view_id
       AND wv.active_ind=1)
      JOIN (pos
      WHERE pos.code_value=outerjoin(wv.position_cd)
       AND pos.active_ind=outerjoin(1))
      JOIN (loc
      WHERE loc.code_value=outerjoin(wv.location_cd)
       AND loc.active_ind=outerjoin(1))
     ORDER BY cnvtupper(pos.display), cnvtupper(loc.display), cnvtupper(wv.display_name),
      cnvtupper(v2.event_set_cd_disp), cnvtupper(v.event_set_cd_disp)
     HEAD REPORT
      cnt = 0, tcnt = size(reply->rowlist,5), stat = alterlist(reply->rowlist,(tcnt+ 100))
     DETAIL
      IF (((wv.position_cd > 0
       AND pos.code_value > 0) OR (wv.position_cd=0)) )
       IF (((wv.location_cd > 0
        AND loc.code_value > 0) OR (wv.location_cd=0)) )
        cnt = (cnt+ 1), tcnt = (tcnt+ 1)
        IF (cnt > 100)
         stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
        ENDIF
        stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
        string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = pos.display,
        reply->rowlist[tcnt].celllist[3].string_value = loc.display, reply->rowlist[tcnt].celllist[4]
        .string_value = wv.display_name, reply->rowlist[tcnt].celllist[5].string_value = v2
        .event_set_cd_disp,
        reply->rowlist[tcnt].celllist[6].string_value = v.event_set_cd_disp, reply->rowlist[tcnt].
        celllist[7].double_value = (wvi.falloff_view_minutes/ 60.00), reply->rowlist[tcnt].celllist[8
        ].nbr_value = 0,
        reply->rowlist[tcnt].celllist[9].string_value = resolution_txt
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->rowlist,tcnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
