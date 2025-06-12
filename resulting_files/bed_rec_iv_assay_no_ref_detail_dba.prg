CREATE PROGRAM bed_rec_iv_assay_no_ref_detail:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 assay_display = vc
     2 assay_desc = vc
     2 assay_code_value = f8
     2 result_type = vc
     2 activity_type = vc
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
 SET col_cnt = 4
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Assay Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Result Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Activity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="IVASSAYSNOREFRNGE"))
    SET tcnt = 0
    SELECT INTO "NL:"
     FROM discrete_task_assay dta,
      v500_event_set_explode ese,
      v500_event_set_code esc,
      working_view_item wvi,
      code_value cv1,
      code_value cv2,
      reference_range_factor rrf
     PLAN (dta
      WHERE dta.active_ind=1)
      JOIN (ese
      WHERE ese.event_cd=dta.event_cd
       AND ese.event_set_level=0)
      JOIN (esc
      WHERE esc.event_set_cd=ese.event_set_cd)
      JOIN (wvi
      WHERE wvi.primitive_event_set_name=esc.event_set_name)
      JOIN (cv1
      WHERE cv1.code_value=dta.default_result_type_cd
       AND cv1.active_ind=1)
      JOIN (cv2
      WHERE cv2.code_value=dta.activity_type_cd
       AND cv2.active_ind=1)
      JOIN (rrf
      WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd))
     ORDER BY dta.mnemonic, dta.task_assay_cd
     HEAD dta.task_assay_cd
      IF (rrf.task_assay_cd=0)
       tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].assay_display = dta
       .mnemonic,
       temp->tqual[tcnt].assay_desc = dta.description, temp->tqual[tcnt].result_type = cv1.display,
       temp->tqual[tcnt].activity_type = cv2.display
      ENDIF
     WITH nocounter
    ;end select
    SET row_nbr = 0
    FOR (x = 1 TO tcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,col_cnt)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].assay_desc
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].result_type
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].activity_type
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
