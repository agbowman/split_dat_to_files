CREATE PROGRAM bed_ens_ado_categories:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 category_id = f8
    1 category_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 IF ((request->category_name > " "))
  SET ind = 0
  SELECT INTO "nl:"
   FROM br_ado_category c
   PLAN (c
    WHERE c.category_name_key=cnvtupper(request->category_name))
   DETAIL
    ind = (ind+ 1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET c_id = 0.0
   SELECT INTO "nl:"
    temp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     c_id = cnvtreal(temp)
    WITH nocounter
   ;end select
   SET ierrcode = 0
   INSERT  FROM br_ado_category c
    SET c.br_ado_category_id = c_id, c.category_name = request->category_name, c.category_name_key =
     cnvtupper(request->category_name),
     c.updt_cnt = 0, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
    PLAN (c)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error on Inserting Order List Category:",trim(request->category_name),".")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   SET reply->category_id = c_id
   SET reply->category_name = request->category_name
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
