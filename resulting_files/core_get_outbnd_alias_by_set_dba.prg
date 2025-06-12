CREATE PROGRAM core_get_outbnd_alias_by_set:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 alias_list[*]
     2 alias = vc
     2 alias_type_meaning = c12
     2 code_value = f8
     2 code_value_disp = c40
     2 cdf_meaning = c12
     2 active_ind = i2
     2 contributor_source_cd = f8
     2 contributor_source_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD alias_req
 RECORD alias_req(
   1 code_set = i4
   1 alias_type_ind = i4
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SET alias_req->code_set = request->code_set
 SET alias_req->alias_type_ind = 2
 EXECUTE kia_alias_cleanup  WITH replace("REQUEST","ALIAS_REQ"), replace("REPLY","ALIAS_REP")
 SELECT INTO "nl:"
  cvo_ind = nullind(cvo.alias), cvo.alias, cvo.alias_type_meaning,
  cvo.code_set, cvo.code_value, cvo.contributor_source_cd,
  cv.display
  FROM code_value_outbound cvo,
   code_value cv
  PLAN (cv
   WHERE (cv.code_set=request->code_set))
   JOIN (cvo
   WHERE cvo.code_value=cv.code_value)
  HEAD REPORT
   a_cnt = 0
  DETAIL
   a_cnt = (a_cnt+ 1)
   IF (mod(a_cnt,10)=1)
    stat = alterlist(reply->alias_list,(a_cnt+ 9))
   ENDIF
   IF (cvo.alias=" "
    AND cvo_ind=0)
    reply->alias_list[a_cnt].alias = "<sp>"
   ELSE
    reply->alias_list[a_cnt].alias = cvo.alias
   ENDIF
   reply->alias_list[a_cnt].alias_type_meaning = cvo.alias_type_meaning, reply->alias_list[a_cnt].
   code_value = cvo.code_value, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
   reply->alias_list[a_cnt].active_ind = cv.active_ind, reply->alias_list[a_cnt].code_value_disp = cv
   .display, reply->alias_list[a_cnt].contributor_source_cd = cvo.contributor_source_cd
  FOOT REPORT
   stat = alterlist(reply->alias_list,a_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "004 05/05/2008 KV011080"
END GO
