CREATE PROGRAM cps_get_summary_sheet_tool:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 summary_sheet_qual = i4
   1 summary_sheet[*]
     2 summary_sheet_id = f8
     2 prsnl_id = f8
     2 person_id = f8
     2 display = c40
     2 description = vc
     2 summary_section_qual = i4
     2 summary_section[*]
       3 section_id = f8
       3 prsnl_id = f8
       3 display = c40
       3 subject_area_cd = f8
       3 subject_area_disp = c40
       3 subject_area_desc = c60
       3 subject_area_mean = c12
       3 section_type_cd = f8
       3 section_type_disp = c40
       3 section_type_desc = c60
       3 section_type_mean = c12
       3 comment_text = vc
       3 sortable_ind = i2
       3 script = vc
       3 max_qual = i4
       3 sequence = i4
       3 default_expand_ind = i2
       3 section_r_qual = i4
       3 section_r[*]
         4 child_id = f8
         4 sequence = i4
       3 section_attribute_qual = i4
       3 section_attribute[*]
         4 column_num = i4
         4 subj_area_dtl_cd = f8
         4 subj_area_dtl_disp = c40
         4 subj_area_dtl_desc = c60
         4 subj_area_dtl_mean = c12
         4 width = i4
         4 detail_type_cd = f8
         4 detail_type_disp = c40
         4 detail_type_desc = c60
         4 detail_type_mean = c12
         4 detail_value = vc
         4 output_mask = vc
         4 sort_direction_cd = f8
         4 sort_direction_disp = c40
         4 sort_direction_desc = c60
         4 sort_direction_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_sec
 RECORD temp_sec(
   1 summary_section_qual = i4
   1 summary_section[*]
     2 section_id = f8
     2 prsnl_id = f8
     2 display = c40
     2 subject_area_cd = f8
     2 subject_area_disp = c40
     2 subject_area_desc = c60
     2 subject_area_mean = c12
     2 section_type_cd = f8
     2 section_type_disp = c40
     2 section_type_desc = c60
     2 section_type_mean = c12
     2 comment_text = vc
     2 sortable_ind = i2
     2 script = vc
     2 max_qual = i4
     2 sequence = i4
     2 default_expand_ind = i2
     2 section_r_qual = i4
     2 section_r[*]
       3 child_id = f8
       3 sequence = i4
     2 section_attribute_qual = i4
     2 section_attribute[*]
       3 column_num = i4
       3 subj_area_dtl_cd = f8
       3 subj_area_dtl_disp = c40
       3 subj_area_dtl_desc = c60
       3 subj_area_dtl_mean = c12
       3 width = i4
       3 detail_type_cd = f8
       3 detail_type_disp = c40
       3 detail_type_desc = c60
       3 detail_type_mean = c12
       3 detail_value = vc
       3 output_mask = vc
       3 sort_direction_cd = f8
       3 sort_direction_disp = c40
       3 sort_direction_desc = c60
       3 sort_direction_mean = c12
 )
 DECLARE qidx = i4 WITH public, noconstant(0)
 DECLARE fidx = i4 WITH public, noconstant(0)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF ((request->all_allowable_ind=true))
   PLAN (s
    WHERE (((s.prsnl_id=request->prsnl_id)) OR (s.prsnl_id=0.0))
     AND s.summary_sheet_id > 0)
    JOIN (r
    WHERE r.summary_sheet_id=s.summary_sheet_id)
    JOIN (sect
    WHERE sect.section_id=r.section_id)
    JOIN (a
    WHERE a.section_id=outerjoin(sect.section_id))
    JOIN (sec_r
    WHERE sec_r.parent_id=outerjoin(sect.section_id))
    JOIN (sect2
    WHERE sect2.section_id=outerjoin(sec_r.child_id))
    JOIN (a2
    WHERE a2.section_id=outerjoin(sect2.section_id))
  ELSE
   PLAN (s
    WHERE (s.prsnl_id=request->prsnl_id)
     AND s.summary_sheet_id > 0)
    JOIN (r
    WHERE r.summary_sheet_id=s.summary_sheet_id)
    JOIN (sect
    WHERE sect.section_id=r.section_id)
    JOIN (a
    WHERE a.section_id=outerjoin(sect.section_id))
    JOIN (sec_r
    WHERE sec_r.parent_id=outerjoin(sect.section_id))
    JOIN (sect2
    WHERE sect2.section_id=outerjoin(sec_r.child_id))
    JOIN (a2
    WHERE a2.section_id=outerjoin(sect2.section_id))
  ENDIF
  INTO "NL:"
  s.summary_sheet_id, sect.section_id, sect_atr = build(a.section_id,a.column_num,a.row_num,a
   .detail_sequence),
  sec_t_sort = build(sec_r.parent_id,sec_r.child_id), atr_sort = build(a2.section_id,a2.column_num,a2
   .row_num,a2.detail_sequence)
  FROM summary_sheet s,
   summary_section_r r,
   summary_section sect,
   section_attribute a,
   section_section_r sec_r,
   summary_section sect2,
   section_attribute a2
  HEAD REPORT
   kount = 0, stat = alterlist(reply->summary_sheet,10)
  HEAD s.summary_sheet_id
   kount = (kount+ 1)
   IF (mod(kount,10)=1
    AND kount != 1)
    stat = alterlist(reply->summary_sheet,(kount+ 9))
   ENDIF
   reply->summary_sheet[kount].summary_sheet_id = s.summary_sheet_id, reply->summary_sheet[kount].
   prsnl_id = s.prsnl_id, reply->summary_sheet[kount].display = s.display,
   reply->summary_sheet[kount].description = s.description, sec_knt = 0, stat = alterlist(reply->
    summary_sheet[kount].summary_section,10),
   tsec_knt = 0, stat = alterlist(temp_sec->summary_section,10)
  HEAD sect.section_id
   sec_knt = (sec_knt+ 1)
   IF (mod(sec_knt,10)=1
    AND sec_knt != 1)
    stat = alterlist(reply->summary_sheet[kount].summary_section,(sec_knt+ 9))
   ENDIF
   reply->summary_sheet[kount].summary_section[sec_knt].section_id = sect.section_id, reply->
   summary_sheet[kount].summary_section[sec_knt].prsnl_id = sect.prsnl_id, reply->summary_sheet[kount
   ].summary_section[sec_knt].display = sect.display,
   reply->summary_sheet[kount].summary_section[sec_knt].subject_area_cd = sect.subject_area_cd, reply
   ->summary_sheet[kount].summary_section[sec_knt].section_type_cd = sect.section_type_cd, reply->
   summary_sheet[kount].summary_section[sec_knt].comment_text = sect.comment_text,
   reply->summary_sheet[kount].summary_section[sec_knt].sortable_ind = sect.sortable_ind, reply->
   summary_sheet[kount].summary_section[sec_knt].script = sect.script, reply->summary_sheet[kount].
   summary_section[sec_knt].max_qual = sect.max_qual,
   reply->summary_sheet[kount].summary_section[sec_knt].sequence = r.sequence, reply->summary_sheet[
   kount].summary_section[sec_knt].default_expand_ind = r.default_expand_ind, atr_knt = 0,
   stat = alterlist(reply->summary_sheet[kount].summary_section[sec_knt].section_attribute,10),
   ssr_knt = 0, stat = alterlist(reply->summary_sheet[kount].summary_section[sec_knt].section_r,10)
  HEAD sect_atr
   IF (a.section_id > 0)
    atr_knt = (atr_knt+ 1)
    IF (mod(atr_knt,10)=1
     AND atr_knt != 1)
     stat = alterlist(reply->summary_sheet[kount].summary_section[sec_knt].section_attribute,(atr_knt
      + 9))
    ENDIF
    reply->summary_sheet[kount].summary_section[sec_knt].section_attribute[atr_knt].column_num = a
    .column_num, reply->summary_sheet[kount].summary_section[sec_knt].section_attribute[atr_knt].
    subj_area_dtl_cd = a.subj_area_dtl_cd, reply->summary_sheet[kount].summary_section[sec_knt].
    section_attribute[atr_knt].width = a.width,
    reply->summary_sheet[kount].summary_section[sec_knt].section_attribute[atr_knt].detail_type_cd =
    a.detail_type_cd, reply->summary_sheet[kount].summary_section[sec_knt].section_attribute[atr_knt]
    .detail_value = a.detail_value, reply->summary_sheet[kount].summary_section[sec_knt].
    section_attribute[atr_knt].output_mask = a.output_mask,
    reply->summary_sheet[kount].summary_section[sec_knt].section_attribute[atr_knt].sort_direction_cd
     = a.sort_direction_cd
   ENDIF
  HEAD sec_t_sort
   IF (sec_r.parent_id > 0)
    ssr_knt = (ssr_knt+ 1)
    IF (mod(ssr_knt,10)=1
     AND ssr_knt != 1)
     stat = alterlist(reply->summary_sheet[kount].summary_section[sec_knt].section_r,(ssr_knt+ 1))
    ENDIF
    reply->summary_sheet[kount].summary_section[sec_knt].section_r[ssr_knt].child_id = sec_r.child_id,
    reply->summary_sheet[kount].summary_section[sec_knt].section_r[ssr_knt].sequence = sec_r.sequence
   ENDIF
  HEAD sect2.section_id
   IF (sect2.section_id > 0)
    tsec_knt = (tsec_knt+ 1)
    IF (mod(tsec_knt,10)=1
     AND tsec_knt != 1)
     stat = alterlist(temp_sec->summary_section,(tsec_knt+ 9))
    ENDIF
    temp_sec->summary_section[tsec_knt].section_id = sect2.section_id, temp_sec->summary_section[
    tsec_knt].prsnl_id = sect2.prsnl_id, temp_sec->summary_section[tsec_knt].display = sect2.display,
    temp_sec->summary_section[tsec_knt].subject_area_cd = sect2.subject_area_cd, temp_sec->
    summary_section[tsec_knt].section_type_cd = sect2.section_type_cd, temp_sec->summary_section[
    tsec_knt].comment_text = sect2.comment_text,
    temp_sec->summary_section[tsec_knt].sortable_ind = sect2.sortable_ind, temp_sec->summary_section[
    tsec_knt].script = sect2.script, temp_sec->summary_section[tsec_knt].max_qual = sect2.max_qual,
    tatr_knt = 0, stat = alterlist(temp_sec->summary_section[tsec_knt].section_attribute,10)
   ENDIF
  HEAD atr_sort
   IF (a2.section_id > 0)
    tatr_knt = (tatr_knt+ 1)
    IF (mod(tatr_knt,10)=1
     AND tatr_knt != 1)
     stat = alterlist(temp_sec->summary_section[tsec_knt].section_attribute,(tatr_knt+ 9))
    ENDIF
    temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].column_num = a2.column_num,
    temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].subj_area_dtl_cd = a2
    .subj_area_dtl_cd, temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].width = a2
    .width,
    temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].detail_type_cd = a2
    .detail_type_cd, temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].detail_value =
    a2.detail_value, temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].output_mask = a2
    .output_mask,
    temp_sec->summary_section[tsec_knt].section_attribute[tatr_knt].sort_direction_cd = a2
    .sort_direction_cd
   ENDIF
  FOOT  sect2.section_id
   temp_sec->summary_section[tsec_knt].section_attribute_qual = tatr_knt, stat = alterlist(temp_sec->
    summary_section[tsec_knt].section_attribute,tatr_knt)
  FOOT  sect.section_id
   reply->summary_sheet[kount].summary_section[sec_knt].section_r_qual = ssr_knt, stat = alterlist(
    reply->summary_sheet[kount].summary_section[sec_knt].section_r,ssr_knt), reply->summary_sheet[
   kount].summary_section[sec_knt].section_attribute_qual = atr_knt,
   stat = alterlist(reply->summary_sheet[kount].summary_section[sec_knt].section_attribute,atr_knt)
  FOOT  s.summary_sheet_id
   temp_sec->summary_section_qual = tsec_knt, stat = alterlist(temp_sec->summary_section,tsec_knt)
   IF (tsec_knt > 0)
    org_sec_knt = sec_knt, beg_sec_knt = (sec_knt+ 1), sec_knt = (sec_knt+ tsec_knt),
    stat = alterlist(reply->summary_sheet[kount].summary_section,sec_knt), txidx = 0
    FOR (xidx = beg_sec_knt TO sec_knt)
      txidx = (xidx - org_sec_knt), reply->summary_sheet[kount].summary_section[xidx].section_id =
      temp_sec->summary_section[txidx].section_id, reply->summary_sheet[kount].summary_section[xidx].
      prsnl_id = temp_sec->summary_section[txidx].prsnl_id,
      reply->summary_sheet[kount].summary_section[xidx].display = temp_sec->summary_section[txidx].
      display, reply->summary_sheet[kount].summary_section[xidx].subject_area_cd = temp_sec->
      summary_section[txidx].subject_area_cd, reply->summary_sheet[kount].summary_section[xidx].
      section_type_cd = temp_sec->summary_section[txidx].section_type_cd,
      reply->summary_sheet[kount].summary_section[xidx].comment_text = temp_sec->summary_section[
      txidx].comment_text, reply->summary_sheet[kount].summary_section[xidx].sortable_ind = temp_sec
      ->summary_section[txidx].sortable_ind, reply->summary_sheet[kount].summary_section[xidx].script
       = temp_sec->summary_section[txidx].script,
      reply->summary_sheet[kount].summary_section[xidx].max_qual = temp_sec->summary_section[txidx].
      max_qual
      IF ((temp_sec->summary_section[txidx].section_attribute_qual > 0))
       reply->summary_sheet[kount].summary_section[xidx].section_attribute_qual = temp_sec->
       summary_section[txidx].section_attribute_qual, stat = alterlist(reply->summary_sheet[kount].
        summary_section[xidx].section_attribute,reply->summary_sheet[kount].summary_section[xidx].
        section_attribute_qual)
       FOR (yidx = 1 TO reply->summary_sheet[kount].summary_section[xidx].section_attribute_qual)
         reply->summary_sheet[kount].summary_section[xidx].section_attribute[yidx].column_num =
         temp_sec->summary_section[txidx].section_attribute[yidx].column_num, reply->summary_sheet[
         kount].summary_section[xidx].section_attribute[yidx].subj_area_dtl_cd = temp_sec->
         summary_section[txidx].section_attribute[yidx].subj_area_dtl_cd, reply->summary_sheet[kount]
         .summary_section[xidx].section_attribute[yidx].width = temp_sec->summary_section[txidx].
         section_attribute[yidx].width,
         reply->summary_sheet[kount].summary_section[xidx].section_attribute[yidx].detail_type_cd =
         temp_sec->summary_section[txidx].section_attribute[yidx].detail_type_cd, reply->
         summary_sheet[kount].summary_section[xidx].section_attribute[yidx].detail_value = temp_sec->
         summary_section[txidx].section_attribute[yidx].detail_value, reply->summary_sheet[kount].
         summary_section[xidx].section_attribute[yidx].output_mask = temp_sec->summary_section[txidx]
         .section_attribute[yidx].output_mask,
         reply->summary_sheet[kount].summary_section[xidx].section_attribute[yidx].sort_direction_cd
          = temp_sec->summary_section[txidx].section_attribute[yidx].sort_direction_cd
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   reply->summary_sheet[kount].summary_section_qual = sec_knt, stat = alterlist(reply->summary_sheet[
    kount].summary_section,sec_knt)
  FOOT REPORT
   reply->summary_sheet_qual = kount, stat = alterlist(reply->summary_sheet,kount)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "SUMMARY_SHEET"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSEIF ((reply->summary_sheet_qual < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET pco_script_version = "003 02/07/05 SF3151"
END GO
