CREATE PROGRAM atsearch_foreground_sub
 SELECT
  IF ((request->billing_entity_id=- (1))
   AND (request->be_vrsn_nbr=- (1)))
   FROM acct_template at
   WHERE  $1
    AND  $4
    AND  $5
    AND  $6
    AND  $7
    AND  $8
    AND  $9
  ELSE
   FROM acct_template at,
    be_at_reltn bar
   PLAN (at
    WHERE  $1
     AND  $4
     AND  $5
     AND  $6
     AND  $7
     AND  $8
     AND  $9)
    JOIN (bar
    WHERE at.acct_templ_id=bar.acct_templ_id
     AND  $2
     AND  $3
     AND bar.active_ind=1)
  ENDIF
  INTO "nl:"
  status = uar_get_code_display(at.acct_type_cd)
  HEAD REPORT
   stat = alterlist(reply->at_qual,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->at_qual,(count+ 9))
   ENDIF
   reply->at_qual[count].acct_templ_id = at.acct_templ_id, reply->at_qual[count].acct_templ_name = at
   .acct_templ_name, reply->at_qual[count].acct_type_display = status
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->at_qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
  SET reply->count = count
 ELSE
  SET reply->status_data.status = "S"
  SET reply->count = count
 ENDIF
END GO
