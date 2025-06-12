CREATE PROGRAM bed_get_icd_sources:dba
 FREE SET reply
 RECORD reply(
   1 sources[*]
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SET rep_cnt = 0
 SELECT INTO "nl:"
  FROM nomenclature_load_ns ns,
   code_value cs
  PLAN (ns
   WHERE ns.source_vocabulary_mean="ICD9"
    AND ns.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ns.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ns.primary_vterm_ind IN (0, null)
    AND ns.active_ind=1)
   JOIN (cs
   WHERE cs.cdf_meaning=ns.contributor_system_mean
    AND cs.code_set=89
    AND cs.active_ind=1)
  ORDER BY cs.code_value
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->sources,(rep_cnt+ 10))
  HEAD cs.code_value
   cnt = (cnt+ 1), rep_cnt = (rep_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->sources,(rep_cnt+ 10)), cnt = 1
   ENDIF
   reply->sources[rep_cnt].display = cs.display
  FOOT REPORT
   stat = alterlist(reply->sources,rep_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  cnvtupper(v.source_name)
  FROM br_vocabulary v
  ORDER BY cnvtupper(v.source_name)
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->sources,(rep_cnt+ 10))
  HEAD v.source_name
   cnt = (cnt+ 1), rep_cnt = (rep_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->sources,(rep_cnt+ 10)), cnt = 1
   ENDIF
   reply->sources[rep_cnt].display = v.source_name
  FOOT REPORT
   stat = alterlist(reply->sources,rep_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
