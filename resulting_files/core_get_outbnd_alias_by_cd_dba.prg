CREATE PROGRAM core_get_outbnd_alias_by_cd:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 outbnd_alias_list[*]
     2 alias = vc
     2 alias_type_meaning = c12
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
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE outnd_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cvo_ind = nullind(cvo.alias), cvo.alias, cvo.alias_type_meaning,
  cvo.contributor_source_cd
  FROM code_value_outbound cvo
  PLAN (cvo
   WHERE (cvo.code_value=request->code_value))
  HEAD REPORT
   outnd_cnt = 0
  DETAIL
   outnd_cnt = (outnd_cnt+ 1)
   IF (mod(outnd_cnt,10)=1)
    stat = alterlist(reply->outbnd_alias_list,(outnd_cnt+ 9))
   ENDIF
   IF (cvo.alias=" "
    AND cvo_ind=0)
    reply->outbnd_alias_list[outnd_cnt].alias = "<sp>"
   ELSE
    reply->outbnd_alias_list[outnd_cnt].alias = cvo.alias
   ENDIF
   reply->outbnd_alias_list[outnd_cnt].alias_type_meaning = cvo.alias_type_meaning, reply->
   outbnd_alias_list[outnd_cnt].contributor_source_cd = cvo.contributor_source_cd
  FOOT REPORT
   stat = alterlist(reply->outbnd_alias_list,outnd_cnt)
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
 SET script_version = "000 02/24/03 JF8275"
END GO
