CREATE PROGRAM afc_pv_research_acct:dba
 SET reply->status_data.status = "F"
 SET v_count = 0
 SELECT INTO "nl:"
  r.research_account_id, r.name
  FROM research_account r
  WHERE active_ind=1
  ORDER BY r.name, r.research_account_id
  DETAIL
   v_count = (v_count+ 1), stat = alterlist(reply->datacoll,v_count), reply->datacoll[v_count].
   description = r.name,
   reply->datacoll[v_count].currcv = cnvtstring(r.research_account_id)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 FOR (i = 1 TO v_count)
  CALL echo(build("name: ",reply->datacoll[i].description))
  CALL echo(build("research_acccount_id: ",reply->datacoll[i].currcv))
 ENDFOR
END GO
