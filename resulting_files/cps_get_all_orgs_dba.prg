CREATE PROGRAM cps_get_all_orgs:dba
 RECORD reply(
   1 organization_qual = i4
   1 organization[*]
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
 SET count = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM organization o
  PLAN (o
   WHERE o.active_ind=1)
  DETAIL
   count = (count+ 1)
   IF (mod(count,100)=1)
    stat = alterlist(reply->organization,(count+ 100))
   ENDIF
   reply->organization[count].organization_id = o.organization_id, reply->organization[count].
   org_name = o.org_name, reply->organization[count].org_name_key = o.org_name_key,
   reply->organization[count].federal_tax_id_nbr = o.federal_tax_id_nbr, reply->organization[count].
   org_status_cd = o.org_status_cd, reply->organization[count].ft_entity_id = o.ft_entity_id,
   reply->organization[count].ft_entity_name = o.ft_entity_name, reply->organization[count].
   org_class_cd = o.org_class_cd, reply->organization[count].beg_effective_dt_tm = o
   .beg_effective_dt_tm,
   reply->organization[count].end_effective_dt_tm = o.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->organization,count)
 SET reply->organization_qual = count
 CALL echo(build("reply->organization_qual=",reply->organization_qual))
END GO
