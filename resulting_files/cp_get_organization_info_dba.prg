CREATE PROGRAM cp_get_organization_info:dba
 RECORD reply(
   1 org_name = vc
   1 address_line1 = vc
   1 address_line2 = vc
   1 address_line3 = vc
   1 address_line4 = vc
   1 city = vc
   1 state = vc
   1 state_cd = f8
   1 zipcode = vc
   1 client_number = vc
   1 client_contact = vc
   1 country = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE client_cd = f8 WITH constant(uar_get_code_by("MEANING",334,"CLIENT")), protect
 DECLARE bus_addr_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"BUSINESS")), protect
 SELECT INTO "nl:"
  o.org_name, oa.alias, a.*
  FROM organization o,
   organization_alias oa,
   address a
  PLAN (o
   WHERE (o.organization_id=request->organization_id))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(o.organization_id)
    AND a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.address_type_cd=outerjoin(bus_addr_cd)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (oa
   WHERE oa.organization_id=outerjoin(o.organization_id)
    AND oa.org_alias_type_cd=outerjoin(client_cd)
    AND oa.active_ind=outerjoin(1))
  ORDER BY a.address_type_seq
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count=1)
    reply->org_name = o.org_name, reply->address_line1 = a.street_addr, reply->address_line2 = a
    .street_addr2,
    reply->address_line3 = a.street_addr3, reply->address_line4 = a.street_addr4, reply->city = a
    .city
    IF (a.state_cd > 0)
     reply->state = uar_get_code_display(a.state_cd)
    ELSE
     reply->state = a.state
    ENDIF
    reply->state_cd = a.state_cd, reply->zipcode = a.zipcode, reply->client_number = cnvtalias(oa
     .alias,oa.alias_pool_cd),
    reply->client_contact = a.contact_name
    IF (a.country_cd > 0)
     reply->country = uar_get_code_display(a.country_cd)
    ELSE
     reply->country = a.country
    ENDIF
   ENDIF
  FOOT REPORT
   donothing = 0
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
