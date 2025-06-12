CREATE PROGRAM dcp_add_nomen_category:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE category_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   category_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (category_id=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_NomenCategory table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "3-unable"
  GO TO exit_script
 ENDIF
 INSERT  FROM dcp_nomencategory dnc
  SET dnc.category_id = category_id, dnc.category_type_cd = request->category_type_cd, dnc.sequence
    = request->sequence,
   dnc.category_name = request->category_name, dnc.custom_category_ind = request->custom_category_ind,
   dnc.source_vocabulary_cd = request->source_vocabulary_cd,
   dnc.principle_type_cd = request->principle_type_cd, dnc.default_ind = request->default_ind, dnc
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dnc.updt_id = reqinfo->updt_id, dnc.updt_task = reqinfo->updt_task, dnc.updt_applctx = reqinfo->
   updt_applctx,
   dnc.updt_cnt = 0
  WITH counter
 ;end insert
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
END GO
