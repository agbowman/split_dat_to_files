CREATE PROGRAM cps_add_proxies:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET proxy_id = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET proxy_cnt = size(request->qual,5)
 SET proxy_type_cd = 0.0
 SET proxy_sub_type_cd = 0.0
 FOR (x = 1 TO proxy_cnt)
  SELECT INTO "nl:"
   pr.proxy_person_id, pr.group_proxy_id, pr.proxy_type_cd,
   pr.active_ind
   FROM proxy pr
   WHERE (pr.proxy_person_id=request->qual[x].proxy_person_id)
    AND (pr.person_id=request->qual[x].person_id)
    AND (pr.group_proxy_id=request->qual[x].group_proxy_id)
    AND (pr.msg_category_id=request->qual[x].proxy_type_cd)
    AND (pr.msg_item_grp_id=request->qual[x].proxy_sub_type_cd)
    AND datetimediff(pr.end_effective_dt_tm,cnvtdatetime(request->qual[x].beg_effective_dt_tm)) > 0
    AND (pr.take_proxy_status_flag=request->qual[x].take_proxy_status_flag)
    AND pr.active_ind=1
  ;end select
  IF (curqual > 0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "You already have a proxy for this person, type and time period please revise!"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
 FOR (x = 1 TO proxy_cnt)
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     proxy_id = cnvtint(j)
    WITH format, nocounter
   ;end select
   IF (proxy_id=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "3 - unable to sequence number"
    GO TO exit_script
   ENDIF
   INSERT  FROM proxy p
    SET p.proxy_id = proxy_id, p.msg_category_id = request->qual[x].proxy_type_cd, p.msg_item_grp_id
      = request->qual[x].proxy_sub_type_cd,
     p.person_id = request->qual[x].person_id, p.proxy_person_id = request->qual[x].proxy_person_id,
     p.active_ind = 1,
     p.beg_effective_dt_tm = cnvtdatetime(request->qual[x].beg_effective_dt_tm), p
     .end_effective_dt_tm = cnvtdatetime(request->qual[x].end_effective_dt_tm), p
     .take_proxy_status_flag = request->qual[x].take_proxy_status_flag,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.group_proxy_id = request->qual[x].
     group_proxy_id
    WITH counter
   ;end insert
   IF (curqual < 1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "proxy table"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "4 - unableto insert into table"
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
END GO
