CREATE PROGRAM dm_hl7_doc_import
 SET element_number = cnvtint(requestin->list_0[1].element_number)
 SET field_size = cnvtint(requestin->list_0[1].field_size)
 UPDATE  FROM dm_hl7_doc dhd
  SET dhd.table_name = cnvtupper(requestin->list_0[1].table_name), dhd.column_name = cnvtupper(
    requestin->list_0[1].column_name), dhd.field_format = requestin->list_0[1].field_format,
   dhd.element_number = element_number, dhd.data_type = requestin->list_0[1].data_type, dhd
   .field_size = field_size,
   dhd.required = requestin->list_0[1].required, dhd.repeating = requestin->list_0[1].repeating, dhd
   .field_comment = requestin->list_0[1].field_comment,
   dhd.hl7_table = requestin->list_0[1].hl7_table, dhd.qualifier = requestin->list_0[1].qualifier
  WHERE dhd.segment=trim(requestin->list_0[1].segment)
   AND dhd.field=cnvtint(requestin->list_0[1].field)
   AND dhd.field_component=cnvtint(requestin->list_0[1].field_component)
   AND dhd.field_subcomponent=cnvtint(requestin->list_0[1].field_subcomponent)
   AND dhd.sequence=cnvtint(requestin->list_0[1].seq)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_hl7_doc dhd
   SET dhd.table_name = cnvtupper(requestin->list_0[1].table_name), dhd.column_name = cnvtupper(
     requestin->list_0[1].column_name), dhd.field_format = requestin->list_0[1].field_format,
    dhd.element_number = element_number, dhd.data_type = requestin->list_0[1].data_type, dhd
    .field_size = field_size,
    dhd.required = requestin->list_0[1].required, dhd.repeating = requestin->list_0[1].repeating, dhd
    .field_comment = requestin->list_0[1].field_comment,
    dhd.hl7_table = requestin->list_0[1].hl7_table, dhd.qualifier = requestin->list_0[1].qualifier,
    dhd.segment = requestin->list_0[1].segment,
    dhd.field = cnvtint(requestin->list_0[1].field), dhd.field_component = cnvtint(requestin->list_0[
     1].field_component), dhd.field_subcomponent = cnvtint(requestin->list_0[1].field_subcomponent),
    dhd.sequence = cnvtint(requestin->list_0[1].seq)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
#ext_prg
END GO
