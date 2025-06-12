CREATE PROGRAM cpmcachemanager_add_node:dba
 CALL echo("cpmcachemanager_add_node")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nodeexists = i2 WITH noconstant(0)
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value_node cvn
  WHERE trim(cnvtlower(cvn.node_name))=trim(cnvtlower(request->node_name),3)
  DETAIL
   nodeexists = 1
  WITH nocounter
 ;end select
 IF (nodeexists=0)
  INSERT  FROM code_value_node cvn
   SET cvn.code_value_node_id = seq(reference_seq,nextval), cvn.node_name = trim(cnvtlower(request->
      node_name),3), cvn.updt_id = 0,
    cvn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvn.updt_task = 0, updt_applctx = 0,
    updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET reply->status_data.status = "S"
   COMMIT
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
