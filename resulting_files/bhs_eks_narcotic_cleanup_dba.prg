CREATE PROGRAM bhs_eks_narcotic_cleanup:dba
 DECLARE log_message = vc WITH noconstant(" ")
 SET orderid = 0
 SET morethenonemed = 0
 FOR (y = 1 TO size(request->clin_detail_list,5))
   IF (y=1)
    SET orderid = request->clin_detail_list[1].order_id
   ELSE
    IF ((orderid != request->clin_detail_list[y].order_id))
     SET morethenonemed = 1
     SET y = size(request->clin_detail_list,5)
    ENDIF
   ENDIF
 ENDFOR
 RECORD remove(
   1 qual[*]
     2 orderid = f8
 )
 SET log_message = concat(log_message," | Matching orderables")
 CALL echo(log_message)
 SELECT
  oc.catalog_cd
  FROM order_catalog oc,
   (dummyt d  WITH seq = size(request->clin_detail_list,5))
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=request->clin_detail_list[d.seq].catalog_cd)
    AND  NOT (cnvtupper(oc.primary_mnemonic) IN ("PCA*", "MORPHINE*", "FENTANYL*"))
    AND  NOT (cnvtupper(oc.primary_mnemonic) IN ("HYDROMORPHONE*")))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(remove->qual,cnt), remove->qual[cnt].orderid = request->
   clin_detail_list[d.seq].event_id
  WITH nocounter
 ;end select
 CALL echorecord(remove)
 CALL echorecord(request)
 IF (curqual > 0)
  SET log_message = concat(log_message," | BAD orderables found, removing them")
  CALL echo(log_message)
  FOR (x = 1 TO size(remove->qual,5))
   SET y = 1
   WHILE (y=1)
     SET pos = 0
     SET locnum = 0
     SET pos = locateval(locnum,1,size(request->clin_detail_list,5),remove->qual[x].orderid,request->
      clin_detail_list[locnum].event_id)
     IF (pos > 0)
      SET stat = alterlist(request->clin_detail_list,(size(request->clin_detail_list,5) - 1),(pos - 1
       ))
     ELSE
      SET y = 0
     ENDIF
   ENDWHILE
  ENDFOR
 ELSE
  SET log_message = concat(log_message," | no BAD orderables found")
 ENDIF
#exit_program
 IF (size(request->clin_detail_list,5) > 0)
  SET eksdata->tqual[1].qual[1].order_id = request->clin_detail_list[1].order_id
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
 SET log_message = concat(log_message," OrderID:",build(eksdata->tqual[1].qual[1].order_id))
 CALL echo(log_message)
 CALL echorecord(request)
END GO
