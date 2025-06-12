CREATE PROGRAM bb_get_edn_info:dba
 RECORD reply(
   1 edn_list[*]
     2 bb_edn_admin_id = f8
     2 order_nbr_ident = c12
     2 dispatch_nbr_txt = c12
     2 admin_dt_tm = dq8
     2 source_org_id = f8
     2 destination_loc_cd = f8
     2 protocol_nbr = i2
     2 edn_complete_ind = i2
     2 long_blob_id = f8
     2 access_ind = i2
     2 product_list[*]
       3 bb_edn_product_id = f8
       3 edn_product_nbr_ident = c20
       3 product_type_txt = c20
       3 abo_cd = f8
       3 abo_disp = c40
       3 rh_cd = f8
       3 rh_disp = c40
       3 donation_dt_tm = dq8
       3 expiration_dt_tm = dq8
       3 volume_cnt = i4
       3 clinical_use_ind = i2
       3 delivery_type_cd = f8
       3 delivery_type_disp = c40
       3 delivery_type_mean = c12
       3 product_comment_txt = c30
       3 product_id = f8
       3 product_complete_ind = i2
       3 antigen_list[*]
         4 bb_edn_spcl_testing_id = f8
         4 spcl_testing_cd = f8
         4 spcl_testing_disp = c40
         4 confirmed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE getedndetails(listitem=i4) = i2
 DECLARE getcodevalues(null) = i2
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 DECLARE sscript_name = vc WITH protect, constant("BB_GET_EDN_INFO")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE dcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM bb_edn_admin bea,
   location lo
  PLAN (bea
   WHERE (bea.order_nbr_ident=request->order_nbr)
    AND bea.edn_complete_ind=0)
   JOIN (lo
   WHERE lo.location_cd=bea.destination_loc_cd)
  ORDER BY bea.bb_edn_admin_id
  HEAD REPORT
   count = 0
  HEAD bea.bb_edn_admin_id
   count = (count+ 1)
   IF (count > size(reply->edn_list,5))
    lstat = alterlist(reply->edn_list,(count+ 5))
   ENDIF
  DETAIL
   reply->edn_list[count].bb_edn_admin_id = bea.bb_edn_admin_id, reply->edn_list[count].
   order_nbr_ident = bea.order_nbr_ident, reply->edn_list[count].dispatch_nbr_txt = bea
   .dispatch_nbr_txt,
   reply->edn_list[count].admin_dt_tm = bea.admin_dt_tm, reply->edn_list[count].source_org_id = bea
   .source_org_id, reply->edn_list[count].destination_loc_cd = bea.destination_loc_cd,
   reply->edn_list[count].protocol_nbr = bea.protocol_nbr, reply->edn_list[count].edn_complete_ind =
   bea.edn_complete_ind, reply->edn_list[count].long_blob_id = bea.long_blob_id
   FOR (idx = 1 TO size(request->ownerarealist,5))
     IF ((bea.destination_loc_cd=request->ownerarealist[idx].location_cd))
      reply->edn_list[count].access_ind = 1, idx = size(request->ownerarealist,5)
     ENDIF
   ENDFOR
  FOOT REPORT
   lstat = alterlist(reply->edn_list,count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select Admin Order Number",errmsg)
 ENDIF
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 FOR (lcnt = 1 TO size(reply->edn_list,5))
   IF ((reply->edn_list[lcnt].access_ind=1))
    CALL getedndetails(lcnt)
   ENDIF
 ENDFOR
 SUBROUTINE getedndetails(litem)
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bb_edn_product bep,
     bb_edn_spcl_testing best
    PLAN (bep
     WHERE (bep.bb_edn_admin_id=reply->edn_list[litem].bb_edn_admin_id)
      AND bep.product_complete_ind=0)
     JOIN (best
     WHERE best.bb_edn_product_id=outerjoin(bep.bb_edn_product_id))
    ORDER BY bep.bb_edn_product_id, best.bb_edn_spcl_testing_id
    HEAD REPORT
     lprodcnt = 0, lagcnt = 0
    HEAD bep.bb_edn_product_id
     lprodcnt = (lprodcnt+ 1)
     IF (lprodcnt > size(reply->edn_list[litem].product_list,5))
      lstat = alterlist(reply->edn_list[litem].product_list,(lprodcnt+ 9))
     ENDIF
     reply->edn_list[litem].product_list[lprodcnt].bb_edn_product_id = bep.bb_edn_product_id, reply->
     edn_list[litem].product_list[lprodcnt].edn_product_nbr_ident = bep.edn_product_nbr_ident, reply
     ->edn_list[litem].product_list[lprodcnt].product_type_txt = bep.product_type_txt,
     reply->edn_list[litem].product_list[lprodcnt].abo_cd = bep.abo_cd, reply->edn_list[litem].
     product_list[lprodcnt].rh_cd = bep.rh_cd, reply->edn_list[litem].product_list[lprodcnt].
     donation_dt_tm = bep.donation_dt_tm,
     reply->edn_list[litem].product_list[lprodcnt].expiration_dt_tm = bep.expiration_dt_tm, reply->
     edn_list[litem].product_list[lprodcnt].volume_cnt = bep.volume_cnt, reply->edn_list[litem].
     product_list[lprodcnt].clinical_use_ind = bep.clinical_use_ind,
     reply->edn_list[litem].product_list[lprodcnt].delivery_type_cd = bep.delivery_type_cd, reply->
     edn_list[litem].product_list[lprodcnt].product_comment_txt = bep.product_comment_txt, reply->
     edn_list[litem].product_list[lprodcnt].product_id = bep.product_id,
     reply->edn_list[litem].product_list[lprodcnt].product_complete_ind = bep.product_complete_ind,
     lagcnt = 0
    HEAD best.bb_edn_spcl_testing_id
     IF (best.bb_edn_spcl_testing_id > 0.0)
      lagcnt = (lagcnt+ 1)
      IF (lagcnt > size(reply->edn_list[litem].product_list[lprodcnt].antigen_list,5))
       lstat = alterlist(reply->edn_list[litem].product_list[lprodcnt].antigen_list,(lagcnt+ 4))
      ENDIF
      reply->edn_list[litem].product_list[lprodcnt].antigen_list[lagcnt].bb_edn_spcl_testing_id =
      best.bb_edn_spcl_testing_id, reply->edn_list[litem].product_list[lprodcnt].antigen_list[lagcnt]
      .spcl_testing_cd = best.spcl_testing_cd, reply->edn_list[litem].product_list[lprodcnt].
      antigen_list[lagcnt].confirmed_ind = best.confirmed_ind
     ENDIF
    DETAIL
     row + 0
    FOOT  best.bb_edn_spcl_testing_id
     row + 0
    FOOT  bep.bb_edn_product_id
     lstat = alterlist(reply->edn_list[litem].product_list[lprodcnt].antigen_list,lagcnt)
    FOOT REPORT
     lstat = alterlist(reply->edn_list[litem].product_list,lprodcnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select EDN Prod/Ag Info",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcodevalues(null)
   DECLARE lcodeset = i4 WITH protect, constant(120)
   DECLARE scdfmeaning = c12 WITH protect, constant("NOCOMP")
   DECLARE lcodecnt = i4 WITH protect, noconstant(1)
   SET lstat = uar_get_meaning_by_codeset(lcodeset,nullterm(scdfmeaning),lcodecnt,dcodevalue)
   IF (dcodevalue=0.0)
    SET uar_error = concat("Failed to retrieve compression type code with meaning of ",trim(
      snocompression),".")
    CALL errorhandler("F","uar_get_code_by",uar_error)
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
 IF (size(reply->edn_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
