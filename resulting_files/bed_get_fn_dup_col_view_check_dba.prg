CREATE PROGRAM bed_get_fn_dup_col_view_check:dba
 RECORD reply(
   1 column_view_id = f8
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET list_type = fillstring(20," ")
 CASE (request->list_type)
  OF "TRKBEDLIST":
   SET list_type = "TRKBEDTYPE"
  OF "TRKGRP":
   SET list_type = "TRKGRPTYPE"
  OF "TRKPRVLIST":
   SET list_type = "TRKPRVTYPE"
  OF "LOCATION":
   SET list_type = "TRKPATTYPE"
 ENDCASE
 SELECT INTO "NL:"
  FROM predefined_prefs pp
  WHERE pp.predefined_type_meaning=trim(list_type)
   AND cnvtupper(pp.name)=cnvtupper(request->column_view_name)
  DETAIL
   reply->column_view_id = pp.predefined_prefs_id, reply->active_ind = pp.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
