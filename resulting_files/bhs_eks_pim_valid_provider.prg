CREATE PROGRAM bhs_eks_pim_valid_provider
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM bhs_pim_provider bpr
  PLAN (bpr
   WHERE (bpr.prsnl_id=request->orderlist[event_repeat_index].physician)
    AND bpr.active_ind=1)
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 IF ((retval=- (1)))
  SET retval = 0
 ENDIF
END GO
