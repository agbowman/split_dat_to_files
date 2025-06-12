CREATE PROGRAM cps_get_organization:dba
 RECORD reply(
   1 organization_qual = i4
   1 organization[100]
     2 organization_id = f8
     2 org_name = c100
     2 org_name_key = c100
     2 federal_tax_id_nbr = c100
     2 org_status_cd = f8
     2 ft_entity_id = f8
     2 ft_entity_name = c32
     2 org_class_cd = f8
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
 EXECUTE cps_get_organization_sub parser(
  IF ((request->organization_id=0.0)) "0=0"
  ELSE "p.ORGANIZATION_ID=request->ORGANIZATION_ID "
  ENDIF
  )
END GO
