CREATE PROGRAM dcp_get_alias_pool_cd:dba
 RECORD reply(
   1 qual[*]
     2 alias_pool_cd = f8
     2 suffix = vc
     2 unique_id = vc
     2 visitalias = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="CCOW")
  DETAIL
   IF ((((request->suffix="")) OR ((request->suffix=di.info_char))) )
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].alias_pool_cd = di.info_number, reply->qual[count].suffix = di.info_char,
    reply->qual[count].unique_id = di.info_name,
    reply->qual[count].visitalias = di.info_long_id
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "Z"
 SET stat = alterlist(reply->qual,count)
END GO
