CREATE PROGRAM bed_get_sch_dispscheme_detail:dba
 FREE SET reply
 RECORD reply(
   1 mnemonic = vc
   1 description = vc
   1 back_color = i4
   1 fore_color = i4
   1 brush_type = i4
   1 hatch_style = i4
   1 border_style = i4
   1 border_size = i4
   1 border_color = i4
   1 shape = i4
   1 hatch_color = i4
   1 pen_shape = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SELECT INTO "nl:"
  FROM sch_disp_scheme sds
  PLAN (sds
   WHERE (sds.disp_scheme_id=request->disp_scheme_id))
  DETAIL
   reply->mnemonic = sds.mnemonic, reply->description = sds.description, reply->back_color = sds
   .back_color,
   reply->fore_color = sds.fore_color, reply->brush_type = sds.brush_type, reply->hatch_style = sds
   .hatch_style,
   reply->border_style = sds.border_style, reply->border_size = sds.border_size, reply->border_color
    = sds.border_color,
   reply->shape = sds.shape, reply->hatch_color = sds.hatch_color, reply->pen_shape = sds.pen_shape
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
