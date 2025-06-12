CREATE PROGRAM bb_add_isbt_product_type:dba
 RECORD reply(
   1 product_type_list[*]
     2 ref_num = f8
     2 new_product_type_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD isbt(
   1 isbt_product_type_list[*]
     2 isbt_product_type_id = f8
 )
 RECORD attr(
   1 attr_info_list[*]
     2 attr_info_id = f8
 )
#script
 DECLARE failures = i2
 DECLARE ncnt = i4
 DECLARE icnt = i4
 DECLARE acnt = i4
 SET reply->status_data.status = "F"
 SET failures = 0
 SET stat = alterlist(reply->product_type_list,size(request->product_type_list,5))
 SET ncnt = size(request->product_type_list,5)
 SET next_pathnet_seq = 0.0
 DECLARE updateinactivatedisbtprodtypes(null) = null WITH protect
 FOR (index = 1 TO ncnt)
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->product_type_list[index].new_product_type_id = cnvtreal(seqn), reply->product_type_list[
     index].ref_num = request->product_type_list[index].ref_num
    WITH nocounter
   ;end select
 ENDFOR
 CALL updateinactivatedisbtprodtypes(null)
 INSERT  FROM bb_isbt_product_type bipt,
   (dummyt d1  WITH seq = value(size(request->product_type_list,5)))
  SET bipt.bb_isbt_product_type_id = reply->product_type_list[d1.seq].new_product_type_id, bipt
   .product_cd = request->product_type_list[d1.seq].product_cd, bipt.isbt_barcode = request->
   product_type_list[d1.seq].isbt_barcode,
   bipt.active_ind = 1, bipt.active_status_cd = reqdata->active_status_cd, bipt.active_status_dt_tm
    = cnvtdatetime(sysdate),
   bipt.active_status_prsnl_id = reqinfo->updt_id, bipt.updt_cnt = 0, bipt.updt_dt_tm = cnvtdatetime(
    sysdate),
   bipt.updt_id = reqinfo->updt_id, bipt.updt_task = reqinfo->updt_task, bipt.updt_applctx = reqinfo
   ->updt_applctx
  PLAN (d1)
   JOIN (bipt)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failures += 1
  GO TO exit_script
 ENDIF
 SUBROUTINE updateinactivatedisbtprodtypes(null)
  SELECT INTO "nl:"
   bipt.bb_isbt_product_type_id
   FROM (dummyt d1  WITH seq = value(size(request->product_type_list,5))),
    bb_isbt_product_type bipt,
    product_index pi
   PLAN (d1)
    JOIN (bipt
    WHERE (bipt.isbt_barcode=request->product_type_list[d1.seq].isbt_barcode)
     AND bipt.active_ind=1)
    JOIN (pi
    WHERE pi.active_ind=0
     AND bipt.product_cd=pi.product_cd)
   ORDER BY bipt.bb_isbt_product_type_id
   HEAD REPORT
    icnt = 0
   HEAD bipt.bb_isbt_product_type_id
    icnt += 1
    IF (mod(icnt,10)=1)
     stat = alterlist(isbt->isbt_product_type_list,(icnt+ 9))
    ENDIF
    isbt->isbt_product_type_list[icnt].isbt_product_type_id = bipt.bb_isbt_product_type_id
   FOOT  bipt.bb_isbt_product_type_id
    null
   FOOT REPORT
    stat = alterlist(isbt->isbt_product_type_list,icnt)
   WITH nocounter, forupdate(bipt)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM (dummyt d1  WITH seq = value(size(isbt->isbt_product_type_list,5))),
     bb_isbt_product_type bipt
    SET bipt.active_ind = 0, bipt.active_status_cd = reqdata->inactive_status_cd, bipt
     .active_status_dt_tm = cnvtdatetime(sysdate),
     bipt.active_status_prsnl_id = reqinfo->updt_id, bipt.updt_cnt = (bipt.updt_cnt+ 1), bipt
     .updt_dt_tm = cnvtdatetime(sysdate),
     bipt.updt_id = reqinfo->updt_id, bipt.updt_task = reqinfo->updt_task, bipt.updt_applctx =
     reqinfo->updt_applctx
    PLAN (d1)
     JOIN (bipt
     WHERE (bipt.bb_isbt_product_type_id=isbt->isbt_product_type_list[d1.seq].isbt_product_type_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failures += 1
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    bia.bb_isbt_add_info_id
    FROM (dummyt d1  WITH seq = value(size(isbt->isbt_product_type_list,5))),
     bb_isbt_add_info bia
    PLAN (d1)
     JOIN (bia
     WHERE (bia.bb_isbt_product_type_id=isbt->isbt_product_type_list[d1.seq].isbt_product_type_id)
      AND bia.active_ind=1)
    ORDER BY bia.bb_isbt_add_info_id
    HEAD REPORT
     acnt = 0
    HEAD bia.bb_isbt_add_info_id
     acnt += 1
     IF (mod(acnt,10)=1)
      stat = alterlist(attr->attr_info_list,(acnt+ 9))
     ENDIF
     attr->attr_info_list[acnt].attr_info_id = bia.bb_isbt_add_info_id
    FOOT  bia.bb_isbt_add_info_id
     null
    FOOT REPORT
     stat = alterlist(attr->attr_info_list,acnt)
    WITH nocounter, forupdate(bia)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM (dummyt d1  WITH seq = value(size(attr->attr_info_list,5))),
      bb_isbt_add_info bia
     SET bia.active_ind = 0, bia.active_status_cd = reqdata->inactive_status_cd, bia
      .active_status_dt_tm = cnvtdatetime(sysdate),
      bia.active_status_prsnl_id = reqinfo->updt_id, bia.updt_cnt = (bia.updt_cnt+ 1), bia.updt_dt_tm
       = cnvtdatetime(sysdate),
      bia.updt_id = reqinfo->updt_id, bia.updt_task = reqinfo->updt_task, bia.updt_applctx = reqinfo
      ->updt_applctx
     PLAN (d1)
      JOIN (bia
      WHERE (bia.bb_isbt_add_info_id=attr->attr_info_list[d1.seq].attr_info_id))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failures += 1
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
#exit_script
 IF (failures > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
