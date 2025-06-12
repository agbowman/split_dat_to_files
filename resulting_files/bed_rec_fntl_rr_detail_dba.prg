CREATE PROGRAM bed_rec_fntl_rr_detail:dba
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
 SET col_cnt = 7
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Position"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Tab Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Column View"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Recommended Setting"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Actual Setting"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Resolution"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
  IF ((request->paramlist[x].meaning="EDEPTTRKLSTREF"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="EDEPTTRKLSTREF")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM detail_prefs dp,
     name_value_prefs np1,
     view_prefs vp,
     name_value_prefs np2,
     code_value cv
    PLAN (dp
     WHERE dp.application_number=4250111
      AND dp.view_name="TRKLISTVIEW"
      AND dp.active_ind=1
      AND dp.prsnl_id=0)
     JOIN (np1
     WHERE np1.parent_entity_name="DETAIL_PREFS"
      AND np1.parent_entity_id=dp.detail_prefs_id
      AND np1.active_ind=1
      AND trim(np1.pvc_name)="TABINFO")
     JOIN (vp
     WHERE vp.prsnl_id=dp.prsnl_id
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=4250111
      AND vp.view_name="TRKLISTVIEW"
      AND vp.view_seq=dp.view_seq
      AND ((vp.active_ind+ 0)=1))
     JOIN (np2
     WHERE np2.parent_entity_name="VIEW_PREFS"
      AND np2.parent_entity_id=vp.view_prefs_id
      AND trim(np2.pvc_name)="VIEW_CAPTION"
      AND np2.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=outerjoin(dp.position_cd)
      AND cv.active_ind=outerjoin(1))
    ORDER BY cv.code_value, np2.pvc_value
    DETAIL
     beg_pos = 0, end_pos = 0, str_len = 0,
     end_pos = findstring(";",np1.pvc_value,beg_pos,0), list_type = substring(beg_pos,(end_pos - 1),
      np1.pvc_value)
     CASE (list_type)
      OF "TRKBEDLIST":
       FOR (idx = 1 TO 10)
         beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
       ENDFOR
      OF "LOCATION":
       FOR (idx = 1 TO 10)
         beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
       ENDFOR
      OF "TRKPRVLIST":
       FOR (idx = 1 TO 6)
         beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
       ENDFOR
      OF "TRKGROUP":
       FOR (idx = 1 TO 6)
         beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
       ENDFOR
      ELSE
       beg_pos = 0
     ENDCASE
     end_pos = findstring(",",np1.pvc_value,beg_pos,0), str_len = (end_pos - beg_pos), refunit =
     cnvtint(substring(beg_pos,str_len,np1.pvc_value))
     IF (refunit=1)
      beg_pos = (end_pos+ 1), end_pos = findstring(";",np1.pvc_value,beg_pos,0), str_len = (end_pos
       - beg_pos),
      reftime = substring(beg_pos,str_len,np1.pvc_value)
      IF (cnvtint(reftime) < 30)
       IF (((dp.position_cd > 0
        AND cv.code_value > 0) OR (dp.position_cd=0)) )
        stat = add_rep(short_desc,cv.display,np2.pvc_value,"","> 29",
         reftime,resolution_txt)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->paramlist[x].meaning="EDEPTTRKLSTDMC"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="EDEPTTRKLSTDMC")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   FREE SET temp
   RECORD temp(
     1 pos[*]
       2 position_cd = f8
       2 pos_disp = vc
   )
   FREE SET temp2
   RECORD temp2(
     1 qual[*]
       2 column_view_id = f8
       2 document_col = i2
       2 pos_disp = vc
       2 tab_name = vc
       2 col_view = vc
   )
   SET tcnt = 0
   SELECT DISTINCT INTO "nl:"
    vp.position_cd
    FROM view_prefs vp,
     code_value cv
    PLAN (vp
     WHERE vp.application_number=4250111
      AND vp.view_name IN ("PowerNote ED", "CLINDOCUMENT")
      AND vp.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=vp.position_cd)
    HEAD REPORT
     tcnt = 0, cnt = 0, stat = alterlist(temp->pos,100)
    DETAIL
     tcnt = (tcnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp->pos,(tcnt+ 100)), cnt = 1
     ENDIF
     temp->pos[tcnt].position_cd = vp.position_cd, temp->pos[tcnt].pos_disp = cv.display
    FOOT REPORT
     stat = alterlist(temp->pos,tcnt)
    WITH nocounter
   ;end select
   SET vcnt = 0
   IF (tcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt)),
      detail_prefs dp,
      name_value_prefs np,
      view_prefs vp,
      name_value_prefs np2
     PLAN (d)
      JOIN (dp
      WHERE ((dp.application_number+ 0)=4250111)
       AND (dp.position_cd=temp->pos[d.seq].position_cd)
       AND dp.view_name="TRKLISTVIEW"
       AND ((dp.active_ind+ 0)=1))
      JOIN (np
      WHERE np.parent_entity_name="DETAIL_PREFS"
       AND np.parent_entity_id=dp.detail_prefs_id
       AND trim(np.pvc_name)="TABINFO"
       AND np.active_ind=1)
      JOIN (vp
      WHERE ((vp.application_number+ 0)=4250111)
       AND vp.position_cd=dp.position_cd
       AND trim(vp.view_name)=dp.view_name
       AND ((vp.view_seq+ 0)=dp.view_seq)
       AND vp.active_ind=1)
      JOIN (np2
      WHERE np2.parent_entity_name="VIEW_PREFS"
       AND np2.parent_entity_id=vp.view_prefs_id
       AND trim(np2.pvc_name)="VIEW_CAPTION"
       AND np2.active_ind=1)
     ORDER BY d.seq
     HEAD REPORT
      vcnt = 0, cnt = 0, stat = alterlist(temp2->qual,100)
     DETAIL
      beg_pos = 0, end_pos = 0, str_len = 0,
      end_pos = findstring(";",np.pvc_value,beg_pos,0), list_type = substring(beg_pos,(end_pos - 1),
       np.pvc_value)
      CASE (list_type)
       OF "TRKBEDLIST":
        FOR (idx = 1 TO 8)
          beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
        ENDFOR
       OF "LOCATION":
        FOR (idx = 1 TO 8)
          beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
        ENDFOR
       OF "TRKPRVLIST":
        FOR (idx = 1 TO 4)
          beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
        ENDFOR
       OF "TRKGROUP":
        FOR (idx = 1 TO 4)
          beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
        ENDFOR
       ELSE
        beg_pos = 0
      ENDCASE
      end_pos = findstring(";",np.pvc_value,beg_pos,0), str_len = (end_pos - beg_pos)
      IF (list_type != "TRKPRVLIST")
       vcnt = (vcnt+ 1), cnt = (cnt+ 1)
       IF (cnt > 100)
        stat = alterlist(temp2->qual,(vcnt+ 100)), cnt = 1
       ENDIF
       temp2->qual[vcnt].column_view_id = cnvtreal(substring(beg_pos,str_len,np.pvc_value)), temp2->
       qual[vcnt].pos_disp = temp->pos[d.seq].pos_disp, temp2->qual[vcnt].tab_name = np2.pvc_value
      ENDIF
     FOOT REPORT
      stat = alterlist(temp2->qual,vcnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (vcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(vcnt)),
      predefined_prefs p
     PLAN (d)
      JOIN (p
      WHERE (p.predefined_prefs_id=temp2->qual[d.seq].column_view_id)
       AND p.predefined_type_meaning="TRK*"
       AND p.active_ind=1)
     ORDER BY d.seq
     DETAIL
      temp2->qual[d.seq].col_view = p.name
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(vcnt)),
      name_value_prefs np
     PLAN (d)
      JOIN (np
      WHERE np.parent_entity_name="PREDEFINED_PREFS"
       AND (np.parent_entity_id=temp2->qual[d.seq].column_view_id)
       AND np.pvc_name="Colinfo*"
       AND np.pvc_value="TEDOCMAN*"
       AND np.active_ind=1)
     ORDER BY d.seq
     DETAIL
      temp2->qual[d.seq].document_col = 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(vcnt))
     PLAN (d
      WHERE (temp2->qual[d.seq].document_col=0))
     ORDER BY d.seq
     DETAIL
      stat = add_rep(short_desc,temp2->qual[d.seq].pos_disp,temp2->qual[d.seq].tab_name,temp2->qual[d
       .seq].col_view,"Use Document Management column",
       "Missing column",resolution_txt)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
