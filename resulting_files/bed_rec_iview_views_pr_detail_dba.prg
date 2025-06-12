CREATE PROGRAM bed_rec_iview_views_pr_detail:dba
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
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
 )
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET col_cnt = 2
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "View Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Number of Primitive Event Sets (Assays)"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="IVIEWVIEWSPRFMRSKS2"))
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM working_view wv,
      working_view_section wvs,
      working_view_item wvi
     PLAN (wv
      WHERE wv.active_ind=1)
      JOIN (wvs
      WHERE wvs.working_view_id=wv.working_view_id
       AND wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
     ORDER BY wv.working_view_id
     HEAD REPORT
      tcnt = 0
     HEAD wv.working_view_id
      pecnt = 0
     DETAIL
      pecnt = (pecnt+ 1)
     FOOT  wv.working_view_id
      IF (pecnt > 1000)
       tcnt = (tcnt+ 1), stat = alterlist(temp->vlist,tcnt), temp->vlist[tcnt].view_name = wv
       .display_name,
       temp->vlist[tcnt].prim_event_cnt = pecnt
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (tcnt > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   vname = cnvtupper(temp->vlist[d.seq].view_name)
   FROM (dummyt d  WITH seq = tcnt)
   ORDER BY vname
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp->vlist[d.seq].view_name, reply->rowlist[rcnt
    ].celllist[2].double_value = temp->vlist[d.seq].prim_event_cnt
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO
