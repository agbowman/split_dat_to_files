CREATE PROGRAM dcp_add_proxy:dba
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
 DECLARE proxy_id = f8 WITH noconstant(0.0)
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE proxy_cnt = i4 WITH noconstant(0)
 SET proxy_cnt = size(request->qual,5)
 DECLARE proxy_type_cd = f8 WITH noconstant(0.0)
 IF ((request->proxy_meaning > " ")
  AND (request->person_id > 0))
  SET failed = "F"
 ELSE
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "1 - unable to insert into table"
  GO TO exit_script
 ENDIF
 SET code_set = 16189
 SET cdf_meaning = request->proxy_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET proxy_type_cd = code_value
 IF (proxy_type_cd=0.0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "2 - unable to insert into table"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO proxy_cnt)
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     proxy_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   IF (proxy_id=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "3 - unable to insert into table"
    GO TO exit_script
   ENDIF
   INSERT  FROM proxy p
    SET p.proxy_id = proxy_id, p.proxy_type_cd = proxy_type_cd, p.person_id = request->person_id,
     p.proxy_person_id = request->qual[x].proxy_person_id, p.active_ind = 1, p.beg_effective_dt_tm =
     cnvtdatetime(request->qual[x].beg_effective_dt_tm),
     p.end_effective_dt_tm = cnvtdatetime(request->qual[x].end_effective_dt_tm), p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "4 - unable to insert into table"
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
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
