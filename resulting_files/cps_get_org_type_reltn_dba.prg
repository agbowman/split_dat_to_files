CREATE PROGRAM cps_get_org_type_reltn:dba
 RECORD reply(
   1 org_type_reltn_qual = i4
   1 org_type_reltn[100]
     2 organization_id = f8
     2 org_type_cd = f8
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
 EXECUTE cps_get_org_type_reltn_sub parser(
  IF ((request->organization_id=0.0)) "0 = 0"
  ELSE "p.organization_id = request->organization_id"
  ENDIF
  )
END GO
