CREATE PROGRAM bhs_eks_chk_cur_evoke_cnt:dba
 SET retval = 0
 CALL echo(build("eks_common->event_repeat_index = ",eks_common->event_repeat_index))
 CALL echo(build("eks_common->event_repeat_count = ",eks_common->event_repeat_count))
 IF ((eks_common->event_repeat_index=eks_common->event_repeat_count))
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO
