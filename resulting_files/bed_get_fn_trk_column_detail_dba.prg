CREATE PROGRAM bed_get_fn_trk_column_detail:dba
 FREE SET reply
 RECORD reply(
   1 color = vc
   1 font = vc
   1 columns[*]
     2 name_value_prefs_id = f8
     2 code_value = f8
     2 heading = vc
     2 mean = vc
     2 sequence = i4
     2 width = i4
   1 sort_options[*]
     2 code_value = f8
     2 sort_option = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET beg_pos = 0
 SET end_pos = 0
 SET temp_beg_pos = 0
 SET temp_end_pos = 0
 SET col_count = 0
 SET tot_col_count = 0
 SET color = fillstring(200," ")
 SET font = fillstring(200," ")
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  WHERE nvp.active_ind=1
   AND nvp.parent_entity_name="PREDEFINED_PREFS"
   AND (nvp.parent_entity_id=request->column_view_id)
   AND nvp.pvc_name="Colinfo*"
  ORDER BY nvp.pvc_name
  HEAD REPORT
   stat = alterlist(reply->columns,5), col_count = 0, tot_col_count = 0
  DETAIL
   col_count = (col_count+ 1), tot_col_count = (tot_col_count+ 1)
   IF (col_count > 5)
    stat = alterlist(reply->columns,(tot_col_count+ 5)), col_count = 1
   ENDIF
   tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   column_cdf = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
    = findstring("^",nvp.pvc_value,beg_pos,0),
   column_heading = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
   end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   custom_value = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+
   1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   column_width = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+
   1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   column_code_value = 0.0
   IF (end_pos > 0)
    column_seq = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1
    ), column_code_value = cnvtreal(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSE
    column_seq = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ENDIF
   reply->columns[tot_col_count].name_value_prefs_id = nvp.name_value_prefs_id, reply->columns[
   tot_col_count].mean = column_cdf, reply->columns[tot_col_count].code_value = column_code_value,
   reply->columns[tot_col_count].heading = column_heading, reply->columns[tot_col_count].sequence =
   column_seq, reply->columns[tot_col_count].width = column_width
  FOOT REPORT
   stat = alterlist(reply->columns,tot_col_count)
  WITH nocounter
 ;end select
 DECLARE list_type_mean = vc
 SELECT INTO "NL:"
  FROM predefined_prefs pp
  WHERE (pp.predefined_prefs_id=request->column_view_id)
  DETAIL
   IF (pp.predefined_type_meaning="TRKPRVTYPE")
    list_type_mean = "TRKPRVLIST"
   ELSE
    list_type_mean = "TRKBEDLIST"
   ENDIF
  WITH nocounter
 ;end select
 IF (tot_col_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_col_count),
    code_value cv
   PLAN (d
    WHERE (reply->columns[d.seq].code_value=0)
     AND (reply->columns[d.seq].mean > "  *"))
    JOIN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND (cv.cdf_meaning=reply->columns[d.seq].mean)
     AND cv.definition=list_type_mean)
   DETAIL
    reply->columns[d.seq].code_value = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  WHERE nvp.active_ind=1
   AND nvp.parent_entity_name="PREDEFINED_PREFS"
   AND (nvp.parent_entity_id=request->column_view_id)
   AND nvp.pvc_name="GrouperClrFontInfo"
  DETAIL
   beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,beg_pos,0), font = substring(beg_pos,(end_pos
     - beg_pos),nvp.pvc_value),
   beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), color = substring(
    beg_pos,(end_pos - beg_pos),nvp.pvc_value),
   reply->color = color, reply->font = font
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  WHERE nvp.active_ind=1
   AND nvp.parent_entity_name="PREDEFINED_PREFS"
   AND (nvp.parent_entity_id=request->column_view_id)
   AND nvp.pvc_name="ColumnViewInfo"
  DETAIL
   tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   color = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos =
   findstring("^",nvp.pvc_value,beg_pos,0),
   font = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos =
   findstring(";",nvp.pvc_value,beg_pos,0),
   column_mean = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
   end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   column_code_value = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
   end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
   column_sort = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value))
   IF (column_mean != "NONE")
    stat = alterlist(reply->sort_options,1), reply->sort_options[1].code_value = column_code_value,
    reply->sort_options[1].sort_option = column_sort,
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_mean =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), column_code_value =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), column_sort = cnvtint(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value))
    IF (column_mean != "NONE")
     stat = alterlist(reply->sort_options,2), reply->sort_options[2].code_value = column_code_value,
     reply->sort_options[2].sort_option = column_sort,
     beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_mean =
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
     beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), column_code_value =
     cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
     beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), column_sort = cnvtint
     (substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value))
     IF (column_mean != "NONE")
      stat = alterlist(reply->sort_options,3), reply->sort_options[3].code_value = column_code_value,
      reply->sort_options[3].sort_option = column_sort
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (tot_col_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
