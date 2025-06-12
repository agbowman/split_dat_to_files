CREATE PROGRAM afc_pv_interface_file:dba
 SET reply->status_data.status = "F"
 SET v_count = 0
 SELECT INTO "nl:"
  i.description, i.interface_file_id
  FROM interface_file i
  WHERE i.active_ind=1
  ORDER BY i.description, i.interface_file_id
  DETAIL
   v_count = (v_count+ 1), stat = alterlist(reply->datacoll,v_count), reply->datacoll[v_count].
   description = i.description,
   reply->datacoll[v_count].currcv = cnvtstring(i.interface_file_id)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 FOR (i = 1 TO v_count)
  CALL echo(build("description: ",reply->datacoll[i].description))
  CALL echo(build("research_acccount_id: ",reply->datacoll[i].currcv))
 ENDFOR
END GO
