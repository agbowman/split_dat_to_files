CREATE PROGRAM bhs_eks_one_order_alert:dba
 SET retval = 0
 SET stat = alterlist(eksdata->tqual[3].qual[1].data,2)
 IF (size(eksdata->tqual[3].qual[1].data,5) >= 2)
  SET retval = 100
 ENDIF
END GO
