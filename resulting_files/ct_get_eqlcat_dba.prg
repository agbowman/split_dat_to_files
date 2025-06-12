CREATE PROGRAM ct_get_eqlcat:dba
 RECORD reply(
   1 qual[*]
     2 eql_cat = vc
     2 eql_cat_cd = f8
     2 labels[*]
       3 eql_id = f8
       3 eql_label = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 SET countcd = 0
 SET countlabel = 0
 SET countcd = 0
 SELECT INTO "nl:"
  eql.elig_quest_library_id, cv.code_value_id
  FROM elig_quest_library eql,
   code_value cv,
   dummyt d
  PLAN (cv
   WHERE cv.code_set=19469
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (eql
   WHERE eql.eql_cat_cd=cv.code_value)
  ORDER BY cv.display, eql.eql_label
  HEAD cv.display
   countcd += 1, stat = alterlist(reply->qual,countcd), reply->qual[countcd].eql_cat = cv.display,
   reply->qual[countcd].eql_cat_cd = cv.code_value,
   CALL echo(build("EQL_Cat:",reply->qual[countcd].eql_cat)),
   CALL echo(build("EQL_CAt_Cd:",reply->qual[countcd].eql_cat_cd)),
   countlabel = 0
  DETAIL
   IF (eql.seq > 0
    AND (eql.logical_domain_id=domain_reply->logical_domain_id))
    countlabel += 1, stat = alterlist(reply->qual[countcd].labels,countlabel), reply->qual[countcd].
    labels[countlabel].eql_id = eql.elig_quest_library_id,
    reply->qual[countcd].labels[countlabel].eql_label = eql.eql_label,
    CALL echo(build("EQL_Label:",eql.eql_label))
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
