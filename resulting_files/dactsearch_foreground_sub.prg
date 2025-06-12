CREATE PROGRAM dactsearch_foreground_sub
 SELECT
  IF ((request->billing_entity_id=- (1)))
   FROM deposit_acct da,
    organization o
   PLAN (da
    WHERE  $2
     AND  $3
     AND  $4
     AND  $5
     AND  $6
     AND  $7)
    JOIN (o
    WHERE da.organization_id=o.organization_id)
  ELSE
   FROM be_depacct_reltn bdr,
    deposit_acct da,
    organization o
   PLAN (bdr
    WHERE  $1
     AND bdr.active_ind=1)
    JOIN (da
    WHERE bdr.deposit_acct_id=da.deposit_acct_id
     AND  $2
     AND  $3
     AND  $4
     AND  $5
     AND  $6
     AND  $7)
    JOIN (o
    WHERE da.organization_id=o.organization_id)
  ENDIF
  INTO "nl:"
  da.deposit_acct_id
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].deposit_acct_id = da.deposit_acct_id, reply->qual[count].deposit_acct_desc = da
   .deposit_acct_desc, reply->qual[count].org_name = o.org_name,
   reply->qual[count].ext_acct_id_txt = da.ext_acct_id_txt
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
