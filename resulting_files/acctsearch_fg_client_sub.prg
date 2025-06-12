CREATE PROGRAM acctsearch_fg_client_sub
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=18733
   AND c.cdf_meaning="OWNER"
  DETAIL
   be_owner_code = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=18936
   AND c.cdf_meaning="OWNER"
  DETAIL
   client_owner_code = c.code_value
  WITH nocounter
 ;end select
 SELECT
  IF ((request->billing_entity_id=- (1))
   AND (request->organization_id=- (1)))
   FROM account a,
    acct_org_reltn aor,
    organization o
   PLAN (a
    WHERE  $1
     AND  $2
     AND (a.acct_type_cd=request->acct_type_cd))
    JOIN (aor
    WHERE a.acct_id=aor.acct_id
     AND aor.role_type_cd=client_owner_code)
    JOIN (o
    WHERE aor.organization_id=o.organization_id)
  ELSEIF ((request->organization_id=- (1)))
   FROM account a,
    be_at_reltn bar,
    organization o,
    acct_org_reltn aor
   PLAN (bar
    WHERE (bar.billing_entity_id=request->billing_entity_id)
     AND bar.active_ind=1
     AND bar.access_cd=be_owner_code)
    JOIN (a
    WHERE bar.acct_templ_id=a.acct_templ_id
     AND  $1
     AND  $2
     AND (a.acct_type_cd=request->acct_type_cd))
    JOIN (aor
    WHERE aor.acct_id=a.acct_id
     AND aor.role_type_cd=client_owner_code)
    JOIN (o
    WHERE aor.organization_id=o.organization_id)
  ELSEIF ((request->billing_entity_id=- (1)))
   FROM account a,
    organization o,
    acct_org_reltn aor
   PLAN (o
    WHERE (o.organization_id=request->organization_id))
    JOIN (aor
    WHERE o.organization_id=aor.organization_id
     AND aor.role_type_cd=client_owner_code)
    JOIN (a
    WHERE aor.acct_id=a.acct_id
     AND  $1
     AND  $2
     AND (a.acct_type_cd=request->acct_type_cd))
  ELSE
   FROM account a,
    be_at_reltn bar,
    organization o,
    acct_org_reltn aor
   PLAN (bar
    WHERE (bar.billing_entity_id=request->billing_entity_id)
     AND bar.active_ind=1
     AND bar.access_cd=be_owner_code)
    JOIN (a
    WHERE bar.acct_templ_id=a.acct_templ_id
     AND  $1
     AND  $2
     AND (a.acct_type_cd=reqeuest->acct_type_cd))
    JOIN (aor
    WHERE (aor.organization_id=request->organization_id)
     AND aor.acct_id=a.acct_id
     AND aor.role_type_cd=client_owner_code)
    JOIN (o
    WHERE aor.organization_id=o.organization_id)
  ENDIF
  INTO "nl:"
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].acct_id = a.acct_id, reply->qual[count].org_name = o.org_name, reply->qual[
   count].tax_id = o.federal_tax_id_nbr,
   reply->qual[count].ext_acct_id_txt = a.ext_acct_id_txt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
  SET reply->count = count
 ELSE
  SET reply->status_data.status = "S"
  SET reply->count = count
 ENDIF
END GO
