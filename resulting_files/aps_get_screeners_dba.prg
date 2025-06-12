CREATE PROGRAM aps_get_screeners:dba
 RECORD reply(
   1 screener_qual[*]
     2 role = c40
     2 role_cdf = c12
     2 prsnl_id = f8
     2 username = c50
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
 RECORD temp(
   1 qual[*]
     2 person_id = f8
     2 priv_qual[*]
       3 privilege_cdf = c12
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET y = 0
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
    stat = alterlist(temp->qual,(prsn_cnt+ 9))
   ENDIF
   temp->qual[prsn_cnt].person_id = person_id
  HEAD cv.code_value
   priv_cnt = (priv_cnt+ 1)
   IF (mod(priv_cnt,10)=1)
    stat = alterlist(temp->qual[prsn_cnt].priv_qual,(priv_cnt+ 9))
   ENDIF
   temp->qual[prsn_cnt].priv_qual[priv_cnt].privilege_cdf = cv.cdf_meaning
  FOOT  person_id
   stat = alterlist(temp->qual[prsn_cnt].priv_qual,priv_cnt)
  FOOT REPORT
   stat = alterlist(temp->qual,prsn_cnt)
  WITH nocounter
 ;end select
 CALL echo(build("curqual :",curqual))
 SET cnt = (value(size(temp->qual,5))+ 1)
 SET stat = alterlist(temp->qual,cnt)
 SET temp->qual[cnt].person_id = reqinfo->updt_id
 SELECT INTO "nl:"
  join_path = decode(pgr.seq,"N",pgr2.seq,"P"," "), c.display, p.name_full_formatted,
  pgr.prsnl_group_reltn_id, person_id = decode(pgr.seq,pgr.person_id,pgr2.seq,pgr2.person_id)
  FROM code_value c,
   prsnl_group pg,
   dummyt d2,
   prsnl_group_reltn pgr,
   prsnl p,
   cyto_screening_security css,
   cyto_screening_limits csl,
   dummyt d3,
   prsnl_group_reltn pgr2,
   prsnl p2,
   (dummyt d4  WITH seq = value(size(temp->qual,5)))
  PLAN (c
   WHERE 357=c.code_set
    AND c.cdf_meaning IN ("CYTOTECH", "PATHOLOGIST", "PATHRESIDENT")
    AND c.active_ind=1)
   JOIN (pg
   WHERE c.code_value=pg.prsnl_group_type_cd
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d4)
   JOIN (((d2
   WHERE 1=d2.seq)
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND (pgr.person_id=temp->qual[d4.seq].person_id)
    AND c.cdf_meaning IN ("CYTOTECH")
    AND 1=pgr.active_ind)
   JOIN (p
   WHERE pgr.person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (css
   WHERE pgr.person_id=css.prsnl_id
    AND 1=css.active_ind)
   JOIN (csl
   WHERE p.person_id=csl.prsnl_id
    AND 1=csl.active_ind)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (pgr2
   WHERE pg.prsnl_group_id=pgr2.prsnl_group_id
    AND (pgr2.person_id=temp->qual[d4.seq].person_id)
    AND c.cdf_meaning IN ("PATHOLOGIST", "PATHRESIDENT")
    AND 1=pgr2.active_ind)
   JOIN (p2
   WHERE pgr2.person_id=p2.person_id
    AND p2.active_ind=1
    AND p2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ))
  ORDER BY person_id, c.code_value
  HEAD REPORT
   cnt = 0
  HEAD person_id
   x = 0, priv_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->screener_qual,(cnt+ 9))
   ENDIF
   priv_cnt = cnvtint(size(temp->qual[d4.seq].priv_qual,5)), stat = alterlist(reply->screener_qual[
    cnt].priv_qual,priv_cnt)
   FOR (x = 1 TO priv_cnt)
    reply->screener_qual[cnt].priv_qual[x].privilege_cdf = temp->qual[d4.seq].priv_qual[x].
    privilege_cdf,
    CALL echo(build("privilege = ",reply->screener_qual[cnt].priv_qual[x].privilege_cdf))
   ENDFOR
  HEAD c.code_value
   IF (((((reply->screener_qual[cnt].role_cdf="PATHOLOGIST")) OR (c.cdf_meaning="PATHRESIDENT"
    AND (reply->screener_qual[cnt].role_cdf="CYTOTECH"))) =false))
    reply->screener_qual[cnt].role = c.display, reply->screener_qual[cnt].role_cdf = c.cdf_meaning
   ENDIF
   CASE (join_path)
    OF "N":
     reply->screener_qual[cnt].prsnl_id = p.person_id,reply->screener_qual[cnt].username = p
     .name_full_formatted,
     CALL echo("Cytotech")
    OF "P":
     reply->screener_qual[cnt].prsnl_id = p2.person_id,reply->screener_qual[cnt].username = p2
     .name_full_formatted,
     CALL echo("Pathologist or Pathology Resident")
   ENDCASE
   CALL echo(build("name = ",reply->screener_qual[cnt].username))
  FOOT  c.code_value
   x = 0
  FOOT  person_id
   x = 0
  FOOT REPORT
   stat = alterlist(reply->screener_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#troubleshooting
#end_script
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE VALUE"
 ENDIF
END GO
