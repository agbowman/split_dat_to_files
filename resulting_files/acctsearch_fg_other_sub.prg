CREATE PROGRAM acctsearch_fg_other_sub
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=18733
   AND c.cdf_meaning="OWNER"
  DETAIL
   owner_code = c.code_value
  WITH nocounter
 ;end select
 SELECT
  IF ((request->billing_entity_id=- (1)))
   FROM account a
   WHERE (a.acct_type_cd=request->acct_type_cd)
    AND  $1
    AND  $2
  ELSE
   FROM account a,
    be_at_reltn bar
   PLAN (bar
    WHERE (bar.billing_entity_id=request->billing_entity_id)
     AND bar.active_ind=1
     AND bar.access_cd=owner_code)
    JOIN (a
    WHERE bar.acct_templ_id=a.acct_templ_id
     AND  $1
     AND  $2)
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
   reply->qual[count].acct_id = a.acct_id, reply->qual[count].acct_desc = a.acct_desc, reply->qual[
   count].ext_acct_id_txt = a.ext_acct_id_txt
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
