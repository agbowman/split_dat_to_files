CREATE PROGRAM bed_get_icd_syns_to_updt:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 nomenclature_id = f8
     2 term = vc
     2 code = vc
     2 source = vc
     2 cross_mapping_ind = i2
     2 contributor_system
       3 code_value = f8
       3 meaning = vc
       3 display = vc
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
 DECLARE nparse = vc
 DECLARE nsparse = vc
 SET nparse = "n.source_vocabulary_cd = icd_code and n.active_ind+0 = 1"
 SET nsparse = "ns.cmti = n.cmti"
 IF ((request->load_flag=1))
  SET nparse = concat(nparse," and n.beg_effective_dt_tm+0 <= cnvtdatetime(curdate,curtime3) ",
   " and n.end_effective_dt_tm+0 > cnvtdatetime(curdate,curtime3)")
  SET nsparse = concat(nsparse," and ns.end_effective_dt_tm+0 < n.end_effective_dt_tm ")
 ELSEIF ((request->load_flag=2))
  SET nparse = concat(nparse," and n.end_effective_dt_tm+0 <= cnvtdatetime(curdate,curtime3)")
  SET nsparse = concat(nsparse," and ns.end_effective_dt_tm+0 > n.end_effective_dt_tm ",
   " and ns.end_effective_dt_tm+0 > cnvtdatetime(curdate,curtime3)")
 ENDIF
 SELECT INTO "nl:"
  FROM nomenclature n,
   nomenclature_load_ns ns,
   code_value cs
  PLAN (n
   WHERE parser(nparse))
   JOIN (ns
   WHERE parser(nsparse))
   JOIN (cs
   WHERE cs.code_value=n.contributor_system_cd
    AND cs.active_ind=1)
  ORDER BY n.nomenclature_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->synonyms,100)
  HEAD n.nomenclature_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->synonyms,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->synonyms[tcnt].nomenclature_id = n.nomenclature_id, reply->synonyms[tcnt].code = n
   .source_identifier, reply->synonyms[tcnt].source = cs.display,
   reply->synonyms[tcnt].term = n.source_string, reply->synonyms[tcnt].contributor_system.code_value
    = cs.code_value, reply->synonyms[tcnt].contributor_system.display = cs.display,
   reply->synonyms[tcnt].contributor_system.meaning = cs.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->synonyms,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
