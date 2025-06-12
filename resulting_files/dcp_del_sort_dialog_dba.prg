CREATE PROGRAM dcp_del_sort_dialog:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 IF ((request->prsnl_id > 0))
  DELETE  FROM dcp_custom_cols_sort dcc
   WHERE (dcc.spread_type_cd=request->spread_type_cd)
    AND (dcc.prsnl_id=request->prsnl_id)
  ;end delete
 ELSEIF ((request->position_cd > 0))
  DELETE  FROM dcp_custom_cols_sort dcc
   WHERE (dcc.spread_type_cd=request->spread_type_cd)
    AND (dcc.position_cd=request->position_cd)
  ;end delete
 ELSE
  DELETE  FROM dcp_custom_cols_sort dcc
   WHERE (dcc.spread_type_cd=request->spread_type_cd)
    AND dcc.position_cd=0
    AND dcc.prsnl_id=0
  ;end delete
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP Custom Columns Table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
