CREATE PROGRAM cps_get_nomenstring:dba
 RECORD reply(
   1 s_cnt = i4
   1 s_qual[10]
     2 nomenclature_id = f8
     2 principle_type_cd = f8
     2 principle_type_disp = c40
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 source_string = vc
     2 source_identifier = vc
     2 string_identifier = c18
     2 string_status_cd = f8
     2 term_id = f8
     2 language_cd = f8
     2 language_disp = c40
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_mean = c40
     2 nom_ver_grp_id = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 short_string = vc
     2 mnemonic = c25
     2 concept_identifier = vc
     2 concept_name = vc
     2 concept_source_cd = f8
     2 concept_source_disp = vc
     2 concept_source_mean = vc
     2 string_source_cd = f8
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = vc
     2 primary_vterm_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 EXECUTE cps_get_nomenstring_sub parser(
  IF ((request->nomenclature_id > 0)) "n.nomenclature_id = request->nomenclature_id"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF ((request->principle_type_cd > 0)) "n.principle_type_cd = request->principle_type_cd"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF ((request->source_vocabulary_cd > 0)) "n.source_vocabulary_cd = request->source_vocabulary_cd"
  ELSE "0=0"
  ENDIF
  ),
 parser(
  IF ((request->source_string > "")) "n.source_string = patstring(request->source_string)"
  ELSE "0=0"
  ENDIF
  )
END GO
