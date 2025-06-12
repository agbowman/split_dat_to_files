CREATE PROGRAM bhs_eks_med_safety
 DECLARE sbr_log(ms_log_str=vc) = null
 CALL sbr_log(build2("Begin Log:",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),"order id:", $1))
 SET orderid = cnvtreal( $1)
 IF (orderid=0)
  SET orderid = cnvtreal( $2)
  IF (orderid=0)
   SET retval = 0
   CALL sbr_log(build2("Exiting Script:",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),"->Exiting script"
     ))
   GO TO exit_script
  ENDIF
 ENDIF
 SET creat_cd = uar_get_code_by("DISPLAY",72,"Creatinine-Blood")
 SET creat_size = 0
 SET retval = 0
 FREE RECORD creatlist
 RECORD creatlist(
   1 qual[*]
     2 result = vc
     2 clinid = f8
     2 event_end_dt_tm = cv
     2 admin_end_dt_tm = cv
 )
 CALL echo(orderid)
 CALL echo(creat_cd)
 SELECT INTO "nl:"
  FROM orders o,
   clinical_event ce,
   ce_med_result cem,
   clinical_event ce2
  PLAN (o
   WHERE ((o.order_id=orderid) OR (o.template_order_id=orderid)) )
   JOIN (ce
   WHERE ce.order_id=o.order_id)
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
   JOIN (ce2
   WHERE ce.person_id=ce2.person_id
    AND ce2.event_cd=creat_cd
    AND ce2.clinsig_updt_dt_tm >= cem.admin_end_dt_tm
    AND ce2.valid_until_dt_tm > sysdate)
  ORDER BY cem.admin_end_dt_tm DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(creatlist->qual,cnt), creatlist->qual[cnt].admin_end_dt_tm =
   format(cem.admin_end_dt_tm,"MM/DD/YY HH:MM ;;D"),
   creatlist->qual[cnt].clinid = ce2.clinical_event_id, creatlist->qual[cnt].event_end_dt_tm = format
   (ce2.event_end_dt_tm,"MM/DD/YY HH:MM ;;D"), creatlist->qual[cnt].result = ce2.result_val
  FOOT REPORT
   creat_size = cnt
  WITH nocounter
 ;end select
 CALL echo(build("creat_size is",creat_size))
 IF (creat_size > 1)
  FOR (x = 1 TO creat_size)
    IF (((cnvtreal(creatlist->qual[x].result) - cnvtreal(creatlist->qual[creat_size].result)) > 1.0))
     SET retval = 100
     SET x = (creat_size+ 1)
    ELSE
     SET retval = 0
    ENDIF
  ENDFOR
  CALL echo(build("The retval is:",retval))
 ELSE
  SET retval = 0
 ENDIF
 CALL echo(build("The retval is:",retval))
 CALL echorecord(creatlist)
 CALL sbr_log(build2("End Log:",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),"order id:", $1,"retval:",
   retval))
 SUBROUTINE sbr_log(ms_log_str)
   SELECT INTO "bhscust:medsafetylog.dat"
    DETAIL
     col 0, row + 1, ms_log_str
    WITH nocounter, append
   ;end select
 END ;Subroutine
#exit_script
END GO
