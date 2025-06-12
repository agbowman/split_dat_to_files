CREATE PROGRAM aps_get_verify_proxy:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 priv_qual[*]
       3 privilege_cdf = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  person_id = decode(app1.seq,app1.prsnl_id,app2.seq,app2.prsnl_id)
  FROM ap_prsnl_priv app1,
   ap_prsnl_priv app2,
   ap_prsnl_priv_r appr1,
   ap_prsnl_priv_r appr2,
   prsnl_group_reltn pgr,
   dummyt d1,
   dummyt d2,
   (dummyt d3  WITH seq = value(size(request->qual,5))),
   code_value cv
  PLAN (d3)
   JOIN (cv
   WHERE cv.code_set=21629
    AND (cv.cdf_meaning=request->qual[d3.seq].privilege_cdf)
    AND cv.active_ind=1)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (appr1
   WHERE (appr1.parent_entity_id=reqinfo->updt_id)
    AND appr1.parent_entity_name="PRSNL")
   JOIN (app1
   WHERE app1.privilege_id=appr1.privilege_id
    AND app1.privilege_cd=cv.code_value
    AND (app1.privilege_id != reqinfo->updt_id))
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (pgr
   WHERE (pgr.person_id=reqinfo->updt_id)
    AND pgr.active_ind=1
    AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (appr2
   WHERE pgr.prsnl_group_id=appr2.parent_entity_id
    AND appr2.parent_entity_name="PRSNL_GROUP")
   JOIN (app2
   WHERE appr2.privilege_id=app2.privilege_id
    AND app2.privilege_cd=cv.code_value
    AND (app2.privilege_id != reqinfo->updt_id))
   ))
  ORDER BY person_id, cv.code_value
  HEAD REPORT
   prsn_cnt = 0
  HEAD person_id
   priv_cnt = 0, prsn_cnt = (prsn_cnt+ 1)
   IF (mod(prsn_cnt,10)=1)
    stat = alterlist(reply->qual,(prsn_cnt+ 9))
   ENDIF
   reply->qual[prsn_cnt].person_id = person_id
  HEAD cv.code_value
   priv_cnt = (priv_cnt+ 1)
   IF (mod(priv_cnt,10)=1)
    stat = alterlist(reply->qual[prsn_cnt].priv_qual,(priv_cnt+ 9))
   ENDIF
   reply->qual[prsn_cnt].priv_qual[priv_cnt].privilege_cdf = cv.cdf_meaning
  FOOT  person_id
   stat = alterlist(reply->qual[prsn_cnt].priv_qual,priv_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,prsn_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FOR (x = 1 TO cnvtint(size(reply->qual,5)))
  CALL echo(build("person_id =",reply->qual[x].person_id))
  FOR (y = 1 TO cnvtint(size(reply->qual[x].priv_qual,5)))
    CALL echo(build("priv_cdf =",reply->qual[x].priv_qual[y].privilege_cdf))
  ENDFOR
 ENDFOR
#end_script
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE VALUE"
 ENDIF
END GO
