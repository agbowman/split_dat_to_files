CREATE PROGRAM cps_get_hp_bnft_set_alias
 RECORD reply(
   1 hp_bnft_set_alias_qual = i4
   1 hp_bnft_set_alias[100]
     2 bnft_set_alias_id = f8
     2 hp_bnft_set_id = f8
     2 bnft_set_description = vc
     2 alias = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cps_get_hp_bnft_set_alias_sub parser(
  IF ((request->bnft_set_alias_id=0.0)) "0=0"
  ELSE "p.BNFT_SET_ALIAS_id=request->BNFT_SET_ALIAS_id"
  ENDIF
  ), parser(
  IF ((request->hp_bnft_set_id=0.0)) "0=0"
  ELSE "p.HP_BNFT_SET_id=request->HP_BNFT_SET_id"
  ENDIF
  )
END GO
