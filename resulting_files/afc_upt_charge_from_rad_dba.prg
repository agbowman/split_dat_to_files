CREATE PROGRAM afc_upt_charge_from_rad:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 CALL echo(build("Reply status is: ",reply->status_data.status))
 FREE DEFINE tmp_chrg_tab
 SELECT INTO TABLE tmp_chrg_tab
  c.verify_phys_id, c.perf_phys_id, c.order_id,
  c.process_flg, rp.report_prsnl_id, p.person_id
  FROM charge c,
   order_radiology o,
   rad_report r,
   rad_report_prsnl rp,
   prsnl p
  PLAN (c
   WHERE c.process_flg=0
    AND c.order_id > 0)
   JOIN (o
   WHERE o.order_id=c.order_id
    AND o.parent_order_id != 0)
   JOIN (r
   WHERE r.order_id=o.parent_order_id)
   JOIN (rp
   WHERE rp.rad_report_id=r.rad_report_id
    AND rp.prsnl_relation_flag=2)
   JOIN (p
   WHERE p.person_id=rp.report_prsnl_id)
  WITH counter, forupdate(c)
 ;end select
 UPDATE  FROM charge c,
   tmp_chrg_tab t
  SET c.verify_phys_id = t.person_id, c.perf_phys_id = t.person_id, c.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.updt_cnt = (c.updt_cnt+ 1)
  PLAN (t)
   JOIN (c
   WHERE c.order_id=t.order_id
    AND c.process_flg=0)
  WITH counter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 CALL echo(build("Reply status is: ",reply->status_data.status))
 SET clean = remove("ccluserdir:tmp_chrg_tab.dat;*")
END GO
