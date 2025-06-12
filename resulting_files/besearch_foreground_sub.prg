CREATE PROGRAM besearch_foreground_sub
 SELECT
  IF ((request->org_name="NULL")
   AND (request->lname="NULL")
   AND (request->fname="NULL"))
   FROM organization o,
    billing_entity b
   PLAN (b
    WHERE  $1
     AND  $5
     AND  $6
     AND  $7)
    JOIN (o
    WHERE b.organization_id=o.organization_id)
   ORDER BY b.billing_entity_id
  ELSEIF ((request->org_name="NULL"))
   FROM be_prsnl_reltn bpr,
    organization o,
    prsnl pnl,
    billing_entity b
   PLAN (pnl
    WHERE  $3
     AND  $4
     AND pnl.active_ind=1)
    JOIN (bpr
    WHERE pnl.person_id=bpr.prsnl_id
     AND bpr.active_ind=1)
    JOIN (b
    WHERE bpr.billing_entity_id=b.billing_entity_id
     AND  $1
     AND  $5
     AND  $6
     AND  $7)
    JOIN (o
    WHERE b.organization_id=o.organization_id)
  ELSEIF ((request->lname="NULL")
   AND (request->fname="NULL"))
   FROM organization o,
    billing_entity b
   PLAN (o
    WHERE  $2)
    JOIN (b
    WHERE o.organization_id=b.organization_id
     AND  $1
     AND  $5
     AND  $6
     AND  $7)
  ELSE
   FROM organization o,
    billing_entity b,
    be_prsnl_reltn bpr,
    prsnl pnl
   PLAN (o
    WHERE  $2)
    JOIN (b
    WHERE o.organization_id=b.organization_id
     AND  $1
     AND  $5
     AND  $6
     AND  $7)
    JOIN (bpr
    WHERE b.billing_entity_id=bpr.billing_entity_id)
    JOIN (pnl
    WHERE bpr.prsnl_id=pnl.person_id
     AND  $3
     AND  $4)
  ENDIF
  INTO "nl:"
  b.billing_entity_id
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].billing_entity_id = b.billing_entity_id, reply->qual[count].be_name = b.be_name,
   reply->qual[count].org_name = o.org_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
  SET reply->count = count
  CALL echo(build("count: ",count))
 ELSE
  SET reply->status_data.status = "S"
  SET reply->count = count
  CALL echo(build("count: ",count))
 ENDIF
END GO
