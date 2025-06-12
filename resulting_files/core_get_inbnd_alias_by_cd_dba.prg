CREATE PROGRAM core_get_inbnd_alias_by_cd:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 inbnd_alias_list[*]
     2 alias = vc
     2 alias_type_meaning = c12
     2 contributor_source_cd = f8
     2 contributor_source_disp = c40
     2 primary_ind = i2
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
 DECLARE inbnd_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cva_ind = nullind(cva.alias), cva.alias, cva.alias_type_meaning,
  cva.contributor_source_cd, cva.primary_ind
  FROM code_value_alias cva
  PLAN (cva
   WHERE (cva.code_value=request->code_value))
  HEAD REPORT
   inbnd_cnt = 0
  DETAIL
   inbnd_cnt = (inbnd_cnt+ 1)
   IF (mod(inbnd_cnt,10)=1)
    stat = alterlist(reply->inbnd_alias_list,(inbnd_cnt+ 9))
   ENDIF
   IF (cva.alias=" "
    AND cva_ind=0)
    reply->inbnd_alias_list[inbnd_cnt].alias = "<sp>"
   ELSE
    reply->inbnd_alias_list[inbnd_cnt].alias = cva.alias
   ENDIF
   reply->inbnd_alias_list[inbnd_cnt].alias_type_meaning = cva.alias_type_meaning, reply->
   inbnd_alias_list[inbnd_cnt].contributor_source_cd = cva.contributor_source_cd, reply->
   inbnd_alias_list[inbnd_cnt].primary_ind = cva.primary_ind
  FOOT REPORT
   stat = alterlist(reply->inbnd_alias_list,inbnd_cnt)
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
