CREATE PROGRAM bb_upd_edn_import:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE checkforedn(sadminordernbr=c12) = i2
 DECLARE addedn(llistindex=i4) = i2
 DECLARE getlongdataseq(null) = f8
 DECLARE getpathnetseq(null) = f8
 DECLARE getcodevalues(null) = i2
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 DECLARE sscript_name = vc WITH protect, constant("BB_UPD_EDN_IMPORT")
 DECLARE nnot_found = i2 WITH protect, constant(0)
 DECLARE dcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE llistsize = i4 WITH protect, noconstant(0)
 DECLARE llistidx = i4 WITH protect, noconstant(0)
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 SET llistsize = size(request->edn_list,5)
 IF (llistsize > 0)
  FOR (llistidx = 1 TO llistsize)
    IF (checkforedn(request->edn_list[llistidx].admin_order_nbr)=nnot_found)
     CALL addedn(llistidx)
    ELSE
     CALL errorhandler("F","Order Nbr Already Exists",errmsg)
    ENDIF
  ENDFOR
 ELSE
  GO TO exit_script
 ENDIF
 SUBROUTINE checkforedn(sadminordernbr)
   SELECT INTO "nl:"
    FROM bb_edn_admin bea
    WHERE bea.order_nbr_ident=sadminordernbr
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select Admin Order Number",errmsg)
   ENDIF
   IF (curqual > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE addedn(lidx)
   DECLARE ldispatchsize = i4 WITH protect, noconstant(0)
   DECLARE lagsize = i4 WITH protect, noconstant(0)
   DECLARE lidx2 = i4 WITH protect, noconstant(0)
   DECLARE lidx3 = i4 WITH protect, noconstant(0)
   DECLARE lbloblength = i4 WITH protect, noconstant(0)
   DECLARE new_long_blob_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_bb_edn_admin_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_bb_edn_product_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_bb_edn_sp_test_id = f8 WITH protect, noconstant(0.0)
   SET lstat = getcodevalues(null)
   IF (lstat=0)
    GO TO exit_script
   ENDIF
   SET new_long_blob_id = getlongdataseq(null)
   SET new_bb_edn_admin_id = getpathnetseq(null)
   SET lbloblength = size(cnvtstring(request->edn_list[lidx].file_object),1)
   INSERT  FROM long_blob lb
    SET lb.active_ind = 1, lb.blob_length = lbloblength, lb.compression_cd = dcodevalue,
     lb.long_blob = request->edn_list[lidx].file_object, lb.long_blob_id = new_long_blob_id, lb
     .parent_entity_id = new_bb_edn_admin_id,
     lb.parent_entity_name = "BB_EDN_ADMINISTRATION", lb.updt_applctx = reqinfo->updt_applctx, lb
     .updt_cnt = 0,
     lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id, lb.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Insert LONG_BLOB",errmsg)
   ENDIF
   INSERT  FROM bb_edn_admin bea
    SET bea.bb_edn_admin_id = new_bb_edn_admin_id, bea.order_nbr_ident = request->edn_list[lidx].
     admin_order_nbr, bea.dispatch_nbr_txt = request->edn_list[lidx].admin_dispatch_nbr,
     bea.admin_dt_tm = cnvtdatetime(request->edn_list[lidx].administration_dt_tm), bea.source_org_id
      = request->edn_list[lidx].source_org_id, bea.destination_loc_cd = request->edn_list[lidx].
     destination_loc_cd,
     bea.protocol_nbr = 1, bea.edn_complete_ind = 0, bea.long_blob_id = new_long_blob_id,
     bea.updt_applctx = reqinfo->updt_applctx, bea.updt_dt_tm = cnvtdatetime(curdate,curtime3), bea
     .updt_id = reqinfo->updt_id,
     bea.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Insert BB_EDN_ADMIN",errmsg)
   ENDIF
   SET ldispatchsize = size(request->edn_list[lidx].dispatchlist,5)
   IF (ldispatchsize > 0)
    FOR (lidx2 = 1 TO ldispatchsize)
      SET new_bb_edn_product_id = 0.0
      SET new_bb_edn_product_id = getpathnetseq(null)
      IF ((request->edn_list[lidx].dispatchlist[lidx2].expiration_time_ind=0))
       SET request->edn_list[lidx].dispatchlist[lidx2].expiry_dt_tm = cnvtdatetime(cnvtdate(request->
         edn_list[lidx].dispatchlist[lidx2].expiry_dt_tm),235900)
      ENDIF
      INSERT  FROM bb_edn_product bep
       SET bep.bb_edn_product_id = new_bb_edn_product_id, bep.bb_edn_admin_id = new_bb_edn_admin_id,
        bep.edn_product_nbr_ident = trim(substring(1,13,request->edn_list[lidx].dispatchlist[lidx2].
          prod_nbr)),
        bep.product_type_txt = request->edn_list[lidx].dispatchlist[lidx2].prod_type, bep.abo_cd =
        request->edn_list[lidx].dispatchlist[lidx2].abo_cd, bep.rh_cd = request->edn_list[lidx].
        dispatchlist[lidx2].rh_cd,
        bep.donation_dt_tm = cnvtdatetime(request->edn_list[lidx].dispatchlist[lidx2].date_bled_dt_tm
         ), bep.expiration_dt_tm = cnvtdatetime(request->edn_list[lidx].dispatchlist[lidx2].
         expiry_dt_tm), bep.volume_cnt = request->edn_list[lidx].dispatchlist[lidx2].volume,
        bep.product_comment_txt = request->edn_list[lidx].dispatchlist[lidx2].comment, bep
        .delivery_type_cd = request->edn_list[lidx].dispatchlist[lidx2].delivery_type_cd, bep
        .clinical_use_ind = request->edn_list[lidx].dispatchlist[lidx2].clinical_use_ind,
        bep.product_id = 0.0, bep.product_complete_ind = 0, bep.updt_applctx = reqinfo->updt_applctx,
        bep.updt_dt_tm = cnvtdatetime(curdate,curtime3), bep.updt_id = reqinfo->updt_id, bep
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Insert BB_EDN_PRODUCT",errmsg)
      ENDIF
      SET lagsize = size(request->edn_list[lidx].dispatchlist[lidx2].antigenlist,5)
      IF (lagsize > 0)
       FOR (lidx3 = 1 TO lagsize)
         SET new_bb_edn_sp_test_id = 0.0
         SET new_bb_edn_sp_test_id = getpathnetseq(null)
         INSERT  FROM bb_edn_spcl_testing best
          SET best.bb_edn_spcl_testing_id = new_bb_edn_sp_test_id, best.bb_edn_product_id =
           new_bb_edn_product_id, best.spcl_testing_cd = request->edn_list[lidx].dispatchlist[lidx2].
           antigenlist[lidx3].antigen_cd,
           best.confirmed_ind = request->edn_list[lidx].dispatchlist[lidx2].antigenlist[lidx3].
           confirmed_ind, best.updt_applctx = reqinfo->updt_applctx, best.updt_dt_tm = cnvtdatetime(
            curdate,curtime3),
           best.updt_id = reqinfo->updt_id, best.updt_task = reqinfo->updt_task
          WITH nocounter
         ;end insert
         SET error_check = error(errmsg,0)
         IF (error_check != 0)
          CALL errorhandler("F","Insert BB_EDN_SPCL_TESTING",errmsg)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE getlongdataseq(null)
   SET new_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_id = seqn
    WITH format, nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select Dual LongDataSeq",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO exit_script
   ELSE
    RETURN(new_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE getpathnetseq(null)
   SET new_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_id = seqn
    WITH format, nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select Dual PathNetSeq",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO exit_script
   ELSE
    RETURN(new_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodevalues(null)
   DECLARE lcodeset = i4 WITH protect, constant(120)
   DECLARE scdfmeaning = c12 WITH protect, constant("NOCOMP")
   DECLARE lcodecnt = i4 WITH protect, noconstant(1)
   SET lstat = uar_get_meaning_by_codeset(lcodeset,nullterm(scdfmeaning),lcodecnt,dcodevalue)
   IF (dcodevalue=0.0)
    SET errmsg = concat("Failed to retrieve compression type code with meaning of ",trim(scdfmeaning),
     ".")
    CALL errorhandler("F","uar_get_code_by",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET lstat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
