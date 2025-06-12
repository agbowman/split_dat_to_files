CREATE PROGRAM dcp_add_input_mask:dba
 RECORD fldrec(
   1 qual[*]
     2 oe_field_id = f8
 )
 SET count = 0
 SELECT INTO "nl:"
  oef.oe_field_id
  FROM order_entry_fields oef
  WHERE oef.field_type_flag=2
  HEAD REPORT
   stat = alterlist(fldrec->qual[count],5)
  DETAIL
   count = (count+ 1)
   IF (count > size(fldrec->qual,5))
    stat = alterlist(fldrec->qual,(count+ 10))
   ENDIF
   fldrec->qual[count].oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 CALL echo(build("count: ",count))
 FOR (x = 1 TO count)
   UPDATE  FROM oe_format_fields off
    SET off.input_mask = "4"
    WHERE (off.oe_field_id=fldrec->qual[x].oe_field_id)
   ;end update
 ENDFOR
 SET readme_data->status = "S"
 IF (count > 0)
  SET readme_data->message = build("PVReadMe 1119: Update Successfull.")
  EXECUTE dm_readme_status
  COMMIT
 ELSE
  SET readme_data->message = build("PVReadMe 1119: No update Needed.")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
 COMMIT
END GO
