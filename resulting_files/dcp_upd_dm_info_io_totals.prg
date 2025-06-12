CREATE PROGRAM dcp_upd_dm_info_io_totals
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 RECORD reply(
   1 row_created_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_info dmi
  WHERE dmi.info_domain="INET"
   AND dmi.info_name="IO_TOTALS"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->row_created_ind = 0
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success - Row found in table"
 ELSEIF (curqual=0)
  INSERT  FROM dm_info dmi
   SET dmi.info_date = cnvtdatetime(curdate,curtime3), dmi.info_domain = "INET", dmi.info_name =
    "IO_TOTALS",
    dmi.updt_task = reqinfo->updt_task, dmi.updt_applctx = reqinfo->updt_applctx, dmi.updt_cnt = 1,
    dmi.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET reply->row_created_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.operationname = concat("Insert - ",errmsg)
  ELSEIF (curqual=0)
   SET reply->row_created_ind = 0
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
  ELSE
   SET reply->row_created_ind = 1
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus.operationname = "Success - Row found in table"
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
