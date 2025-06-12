CREATE PROGRAM aps_omf_grid_column_name:dba
 RECORD request(
   1 codeset = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->codeset = 24990
 SET pid = 868
 EXECUTE plm_insert_grid_column
 SET reqinfo->commit_ind = 1
 SET reply->status = "S"
END GO
