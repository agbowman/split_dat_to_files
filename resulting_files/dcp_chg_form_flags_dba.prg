CREATE PROGRAM dcp_chg_form_flags:dba
 RECORD temp(
   1 qual[*]
     2 dcp_forms_ref_id = f8
 )
 SET count = 0
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  WHERE dfr.enforce_required_ind=1
   AND dfr.flags=0
  DETAIL
   count = (count+ 1)
   IF (count > size(temp->qual,5))
    stat = alterlist(temp->qual,(count+ 5))
   ENDIF
   temp->qual[count].dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->qual,count)
 FOR (x = 1 TO count)
   UPDATE  FROM dcp_forms_ref dfr
    SET dfr.flags = 1
    WHERE (dfr.dcp_forms_ref_id=temp->qual[x].dcp_forms_ref_id)
    WITH nocounter
   ;end update
   SET readme_data->message = build("Row ",x," of ",count," updated.")
   EXECUTE dm_readme_status
   COMMIT
 ENDFOR
 SET readme_data->status = "S"
 IF (count <= 0)
  SET readme_data->message = build("PVReadMe 1101: No rows qualify for updt.")
 ELSE
  SET readme_data->message = build("PVReadMe 1101: Updt to ",count," rows in dcp_forms_ref.")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
