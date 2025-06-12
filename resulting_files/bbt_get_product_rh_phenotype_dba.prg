CREATE PROGRAM bbt_get_product_rh_phenotype:dba
 RECORD reply(
   1 product_rh_phenotype_id = f8
   1 rh_phenotype_id = f8
   1 updt_cnt = i4
   1 fisher_race_disp = vc
   1 fr_nomenclature_id = f8
   1 wiener_disp = vc
   1 w_nomenclature_id = f8
   1 antigenlist[*]
     2 special_testing_id = f8
     2 special_testing_cd = f8
     2 special_testing_disp = c40
     2 updt_cnt = i4
     2 spcl_tst_rsl_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET type_cnt = 0
 SET qual_cnt = 0
 SET st_cnt = 0
 SET select_ok_ind = 0
 SET stat = alterlist(reply->antigenlist,10)
 SELECT INTO "nl:"
  prp.product_id, prp.product_rh_phenotype_id, prp.rh_phenotype_id,
  prp.updt_cnt, brp.fr_nomenclature_id, brp.w_nomenclature_id,
  brp.rh_phenotype_id, table_ind = decode(st.seq,"ST",n.seq,"NM","XX"), n.nomenclature_id,
  n.short_string"##########", st.special_testing_id, st.special_testing_cd,
  st.updt_cnt, str.updt_cnt
  FROM product_rh_phenotype prp,
   bb_rh_phenotype brp,
   (dummyt d  WITH seq = 1),
   nomenclature n,
   special_testing st,
   special_testing_result str
  PLAN (prp
   WHERE prp.active_ind=1
    AND (prp.product_id=request->product_id))
   JOIN (brp
   WHERE brp.rh_phenotype_id=prp.rh_phenotype_id
    AND brp.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (((n
   WHERE ((n.nomenclature_id=brp.fr_nomenclature_id) OR (n.nomenclature_id=brp.w_nomenclature_id)) )
   ) ORJOIN ((st
   WHERE st.product_rh_phenotype_id=prp.product_rh_phenotype_id
    AND st.active_ind=1)
   JOIN (str
   WHERE str.special_testing_id=st.special_testing_id
    AND str.active_ind=1)
   ))
  ORDER BY prp.product_rh_phenotype_id, table_ind
  HEAD REPORT
   select_ok_ind = 0, qual_cnt = 0, st_cnt = 0
  HEAD prp.product_rh_phenotype_id
   qual_cnt += 1, reply->product_rh_phenotype_id = prp.product_rh_phenotype_id, reply->
   rh_phenotype_id = prp.rh_phenotype_id,
   reply->updt_cnt = prp.updt_cnt
  DETAIL
   IF (table_ind="NM")
    IF (brp.fr_nomenclature_id=n.nomenclature_id)
     reply->fisher_race_disp = n.short_string, reply->fr_nomenclature_id = brp.fr_nomenclature_id
    ELSEIF (brp.w_nomenclature_id=n.nomenclature_id)
     reply->wiener_disp = n.short_string, reply->w_nomenclature_id = brp.w_nomenclature_id
    ENDIF
   ELSEIF (table_ind="ST")
    st_cnt += 1
    IF (mod(st_cnt,10)=1
     AND st_cnt != 1)
     stat = alterlist(reply->antigenlist,(st_cnt+ 9))
    ENDIF
    reply->antigenlist[st_cnt].special_testing_id = st.special_testing_id, reply->antigenlist[st_cnt]
    .special_testing_cd = st.special_testing_cd, reply->antigenlist[st_cnt].updt_cnt = st.updt_cnt,
    reply->antigenlist[st_cnt].spcl_tst_rsl_updt_cnt = str.updt_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->antigenlist,st_cnt), select_ok_ind = 1
  WITH nullreport, nocounter
 ;end select
 IF (select_ok_ind=1)
  IF (qual_cnt=0)
   CALL load_process_status("Z","select product_rh_phenotype",concat(
     "ZERO - no active product_rh_phenotype rows for product_id=",cnvtstring(request->product_id,32,2
      )))
  ELSEIF (qual_cnt=1)
   CALL load_process_status("S","select product_rh_phenotype","SUCCESS")
  ELSE
   CALL load_process_status("F","select product_rh_phenotype",
    "Multiple active product_rh_phenotype rows.  Cannot retrieve product rh_phenotype")
  ENDIF
 ELSE
  CALL load_process_status("F","select product_rh_phenotype","Select failed.  CCL Error.")
 ENDIF
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_product_rh_phenotype"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
END GO
