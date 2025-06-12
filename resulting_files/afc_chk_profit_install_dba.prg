CREATE PROGRAM afc_chk_profit_install:dba
 RECORD reply(
   1 profit_installed = i2
 )
 SELECT INTO "nl:"
  FROM billing_entity b
  WHERE b.billing_entity_id > 0
   AND ((b.active_ind+ 0)=1)
  DETAIL
   reply->profit_installed = 1
  WITH nocounter
 ;end select
 CALL echo(build("reply->profit_installed = ",reply->profit_installed))
END GO
