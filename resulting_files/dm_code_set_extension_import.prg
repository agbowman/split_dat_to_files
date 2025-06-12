CREATE PROGRAM dm_code_set_extension_import
 SET trace = callecho
 RECORD dmrequest(
   1 field_name = c32
   1 code_set = f8
   1 field_seq = i4
   1 field_type = i2
   1 field_len = i4
   1 field_prompt = c50
   1 field_default = c50
   1 field_help = c100
 )
 IF ((requestin->list_0[1].code_set=" "))
  CALL echo("This row is an empty set")
  GO TO ext_prg
 ENDIF
 SET dmrequest->field_name = requestin->list_0[1].field_name
 SET dmrequest->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET dmrequest->field_seq = cnvtint(requestin->list_0[1].field_seq)
 SET dmrequest->field_type = cnvtint(requestin->list_0[1].field_type)
 SET dmrequest->field_len = cnvtint(requestin->list_0[1].field_len)
 SET dmrequest->field_prompt = requestin->list_0[1].field_prompt
 SET dmrequest->field_default = requestin->list_0[1].field_default
 SET dmrequest->field_help = requestin->list_0[1].field_help
 EXECUTE dm_code_set_extension
 COMMIT
#ext_prg
END GO
