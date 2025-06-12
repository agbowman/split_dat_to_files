CREATE PROGRAM cps_get_org_bnft_set_r
 RECORD reply(
   1 org_bnft_set_r_qual = i4
   1 org_bnft_set_r[100]
     2 org_bnft_set_id = f8
     2 organization_id = f8
     2 hp_bnft_set_id = f8
     2 description = c200
     2 coverage_status_cd = f8
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
 EXECUTE cps_get_org_bnft_set_r_sub parser(
  IF ((request->org_bnft_set_id=0.0)) "0=0"
  ELSE "p.ORG_BNFT_SET_ID=request->ORG_BNFT_SET_ID"
  ENDIF
  ), parser(
  IF ((request->organization_id=0.0)) "0=0"
  ELSE "p.ORGANIZATION_id =request->ORGANIZATION_id "
  ENDIF
  ), parser(
  IF ((request->hp_bnft_set_id=0.0)) "0=0"
  ELSE "p.HP_BNFT_SET_Id =request->HP_BNFT_SET_Id "
  ENDIF
  )
END GO
