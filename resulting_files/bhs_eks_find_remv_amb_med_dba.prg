CREATE PROGRAM bhs_eks_find_remv_amb_med:dba
 DECLARE log_message = vc WITH noconstant(" "), public
 DECLARE log_misc1 = vc WITH noconstant(" "), public
 DECLARE ambulatorymedflag = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",16449,
   "AMBULATORYMEDFLAG")), protect
 SET retval = 0
 CALL echo("find order detail records")
 CALL echorecord(request)
 CALL echorecord(request)
 SET log_message = concat(log_message,"for loop to find order detail ","totalCount: ",build(size(
    request->orderlist,5)))
 FOR (x = 1 TO size(request->orderlist,5))
  SELECT
   c.code_value
   FROM code_value c,
    (dummyt d  WITH seq = size(request->orderlist[x].detaillist,5))
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=request->orderlist[x].detaillist[d.seq].oefieldid))
   DETAIL
    IF (c.code_value=ambulatorymedflag)
     log_message = concat(log_message,"- Ambulatory Med Flag Found:",build(request->orderlist[x].
       detaillist[d.seq].oefieldvalue)), log_misc1 = trim(build(request->orderlist[x].detaillist[d
       .seq].oefieldvalue),3), x = size(request->orderlist,5)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET log_message = concat(log_message,"- count:",build(x)," No Detail Found ")
  ENDIF
 ENDFOR
 IF (textlen(log_misc1) > 0)
  SET retval = 100
 ENDIF
#exit_program
 SET log_message = concat(log_message,"- log_misc1: ",log_misc1)
 CALL echo(log_message)
 CALL echo(log_misc1)
END GO
