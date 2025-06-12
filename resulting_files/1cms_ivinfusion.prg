CREATE PROGRAM 1cms_ivinfusion
 SELECT INTO "NL:"
  o.order_mnemonic
  FROM orders o
  WHERE o.order_id=link_orderid
  HEAD REPORT
   log_misc1 = trim(o.order_mnemonic)
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual=0)
  SET retval = 0
 ELSE
  SET retval = 100
 ENDIF
END GO
