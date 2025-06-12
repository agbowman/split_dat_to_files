CREATE PROGRAM bed_get_contributor_systems:dba
 FREE SET reply
 RECORD reply(
   1 contributor_systems[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 contributor_source
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 alias_config_params_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(reply->contributor_systems,50)
 SELECT INTO "NL:"
  FROM contributor_system cs,
   code_value cv1,
   code_value cv2
  PLAN (cs
   WHERE cs.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=cs.contributor_system_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=cs.contributor_source_cd
    AND cv2.active_ind=1)
  DETAIL
   tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
   IF (alterlist_tcnt > 50)
    stat = alterlist(reply->contributor_systems,(tcnt+ 50)), alterlist_tcnt = 1
   ENDIF
   reply->contributor_systems[tcnt].code_value = cv1.code_value, reply->contributor_systems[tcnt].
   display = cv1.display, reply->contributor_systems[tcnt].mean = cv1.cdf_meaning,
   reply->contributor_systems[tcnt].contributor_source.code_value = cv2.code_value, reply->
   contributor_systems[tcnt].contributor_source.display = cv2.display, reply->contributor_systems[
   tcnt].contributor_source.mean = cv2.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->contributor_systems,tcnt)
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    br_contr_cs_r b
   PLAN (d)
    JOIN (b
    WHERE (b.contributor_system_cd=reply->contributor_systems[d.seq].code_value))
   DETAIL
    reply->contributor_systems[d.seq].alias_config_params_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
