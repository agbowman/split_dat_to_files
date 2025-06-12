CREATE PROGRAM bed_rec_iview_titrate_detail:dba
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
     2 mill_name = vc
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
 SET col_cnt = 1
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Millennium Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="IVIEWTITRATEMEDIND"))
    SET tcnt = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     WHERE ocs.ingredient_rate_conversion_ind IN (1, - (1))
     ORDER BY ocs.mnemonic
     DETAIL
      IF ((ocs.ingredient_rate_conversion_ind=- (1)))
       tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].mill_name = ocs
       .mnemonic
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,col_cnt)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].mill_name
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
