CREATE PROGRAM dcp_del_pip_columns:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET bfoundcolumn = 0
 SET columnlistsize = size(request->column_list,5)
 DELETE  FROM pip_prefs pp,
   (dummyt d  WITH seq = value(columnlistsize))
  SET pp.seq = 1
  PLAN (d)
   JOIN (pp
   WHERE (pp.parent_entity_id=request->column_list[d.seq].pip_column_id)
    AND pp.parent_entity_name="PIP_COLUMN")
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET bfoundcolumn = 1
 ENDIF
 DELETE  FROM pip_column pc,
   (dummyt d  WITH seq = value(columnlistsize))
  SET pc.seq = 1
  PLAN (d)
   JOIN (pc
   WHERE (pc.pip_column_id=request->column_list[d.seq].pip_column_id))
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET bfoundcolumn = 1
 ENDIF
 IF (bfoundcolumn=1)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
