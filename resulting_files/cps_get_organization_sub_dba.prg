CREATE PROGRAM cps_get_organization_sub:dba
 SET kount = 0
 SELECT INTO "nl:"
  p.*
  FROM organization p
  WHERE  $1
   AND active_ind=1
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->organization,(kount+ 100))
   ENDIF
   reply->organization[kount].organization_id = p.organization_id, reply->organization[kount].
   org_name = p.org_name, reply->organization[kount].org_name_key = p.org_name_key,
   reply->organization[kount].federal_tax_id_nbr = p.federal_tax_id_nbr, reply->organization[kount].
   org_status_cd = p.org_status_cd, reply->organization[kount].ft_entity_id = p.ft_entity_id,
   reply->organization[kount].ft_entity_name = p.ft_entity_name, reply->organization[kount].
   org_class_cd = p.org_class_cd, reply->organization[kount].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->organization[kount].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->organization,kount)
 SET reply->organization_qual = kount
END GO
