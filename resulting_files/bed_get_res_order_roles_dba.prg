CREATE PROGRAM bed_get_res_order_roles:dba
 FREE SET reply
 RECORD reply(
   1 ord_roles[*]
     2 ord_role_id = f8
     2 mnemonic = vc
     2 group_id = f8
     2 seq_nbr = i4
     2 selected_ind = i2
     2 mul_ord_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_order_role sor,
   sch_list_role slr
  PLAN (sor
   WHERE (sor.location_cd=request->dept_code_value)
    AND sor.active_ind=1)
   JOIN (slr
   WHERE slr.list_role_id=sor.list_role_id
    AND slr.active_ind=1)
  ORDER BY sor.list_role_id, sor.catalog_cd, sor.seq_nbr
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->ord_roles,10)
  HEAD sor.list_role_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->ord_roles,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->ord_roles[tot_cnt].ord_role_id = slr.list_role_id, reply->ord_roles[tot_cnt].mnemonic = slr
   .mnemonic, reply->ord_roles[tot_cnt].seq_nbr = sor.seq_nbr,
   ord_cnt = 0
  HEAD sor.catalog_cd
   IF ((sor.catalog_cd=request->catalog_code_value))
    reply->ord_roles[tot_cnt].selected_ind = 1, reply->ord_roles[tot_cnt].seq_nbr = sor.seq_nbr
   ENDIF
   IF (ord_cnt > 0)
    reply->ord_roles[tot_cnt].mul_ord_ind = 1
   ENDIF
   ord_cnt = (ord_cnt+ 1)
  FOOT REPORT
   stat = alterlist(reply->ord_roles,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    br_name_value bnv,
    dummyt d2
   PLAN (d)
    JOIN (bnv
    WHERE bnv.br_nv_key1="SCHRESGROUPROLE")
    JOIN (d2
    WHERE (cnvtint(trim(bnv.br_name))=reply->ord_roles[d.seq].ord_role_id))
   ORDER BY d.seq
   HEAD d.seq
    reply->ord_roles[d.seq].group_id = cnvtint(trim(bnv.br_value))
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
