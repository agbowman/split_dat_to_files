CREATE PROGRAM aps_case_spec_type_import
 RECORD request(
   1 case_type_meaning = c12
   1 specimen_meaning = c12
 )
 SET request->case_type_meaning = cnvtupper(requestin->list_0[1].case_type_meaning)
 SET request->specimen_meaning = cnvtupper(requestin->list_0[1].specimen_meaning)
 EXECUTE aps_insert_case_spec_type
END GO
