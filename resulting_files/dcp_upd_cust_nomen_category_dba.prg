CREATE PROGRAM dcp_upd_cust_nomen_category:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET cnt = size(request->nomenclatures,5)
 DELETE  FROM dcp_nomencategorydef
  WHERE (category_id=request->category_id)
  WITH counter
 ;end delete
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
   INSERT  FROM dcp_nomencategorydef d
    SET d.categorydef_id = seq(carenet_seq,nextval), d.category_id = request->category_id, d.sequence
      = x,
     d.nomenclature_id = request->nomenclatures[x].nomenclature_id, d.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), d.updt_id = reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 1
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_NomenCategorydef table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("status: ",reply->status_data.status))
END GO
