CREATE PROGRAM dcp_upd_nomen_categories:dba
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
 SET now = cnvtdatetime(curdate,curtime3)
 SET cnt = size(request->categories,5)
 FOR (x = 1 TO cnt)
   IF ((request->categories[x].category_id=0))
    INSERT  FROM dcp_nomencategory dnc
     SET dnc.category_id = seq(carenet_seq,nextval), dnc.category_type_cd = request->category_type_cd,
      dnc.sequence = x,
      dnc.category_name = request->categories[x].category_name, dnc.custom_category_ind = request->
      categories[x].custom_category_ind, dnc.source_vocabulary_cd = request->categories[x].
      source_vocabulary_cd,
      dnc.principle_type_cd = request->categories[x].principle_type_cd, dnc.default_ind = request->
      categories[x].default_ind, dnc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dnc.updt_id = reqinfo->updt_id, dnc.updt_task = reqinfo->updt_task, dnc.updt_applctx = reqinfo
      ->updt_applctx,
      dnc.updt_cnt = 0
     WITH counter
    ;end insert
   ELSE
    UPDATE  FROM dcp_nomencategory dnc
     SET dnc.category_type_cd = request->category_type_cd, dnc.sequence = x, dnc.category_name =
      request->categories[x].category_name,
      dnc.custom_category_ind = request->categories[x].custom_category_ind, dnc.source_vocabulary_cd
       = request->categories[x].source_vocabulary_cd, dnc.principle_type_cd = request->categories[x].
      principle_type_cd,
      dnc.default_ind = request->categories[x].default_ind, dnc.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), dnc.updt_id = reqinfo->updt_id,
      dnc.updt_task = reqinfo->updt_task, dnc.updt_applctx = reqinfo->updt_applctx, dnc.updt_cnt = (
      dnc.updt_cnt+ 1)
     WHERE (dnc.category_id=request->categories[x].category_id)
      AND (dnc.category_type_cd=request->category_type_cd)
     WITH counter
    ;end update
   ENDIF
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_NomenCategory table"
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
