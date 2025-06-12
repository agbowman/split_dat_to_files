CREATE PROGRAM cdi_get_dm_info
 RECORD reply(
   1 options_qual[*]
     2 info_name = vc
     2 info_number = f8
     2 info_char = vc
     2 info_date = dq8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt_options = i2 WITH public, noconstant(0)
 DECLARE info_domain = vc WITH public, constant("IMAGING DOCUMENT")
 DECLARE g_alloc_num = i2 WITH public, constant(10)
 DECLARE pend_signs_ind_info_name = vc WITH public, constant("HIM_PENDING_SIGNS_IND")
 DECLARE dm_info_qual = i2 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->options_qual,g_alloc_num)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=info_domain
  HEAD REPORT
   cnt_options = 0
  DETAIL
   cnt_options += 1
   IF (cnt_options > size(reply->options_qual,5))
    stat = alterlist(reply->options_qual,(cnt_options+ g_alloc_num))
   ENDIF
   reply->options_qual[cnt_options].info_name = di.info_name, reply->options_qual[cnt_options].
   info_char = di.info_char, reply->options_qual[cnt_options].info_date = di.info_date,
   reply->options_qual[cnt_options].info_number = di.info_number, reply->options_qual[cnt_options].
   updt_cnt = di.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_info_qual = 0
 ELSE
  SET dm_info_qual = 1
 ENDIF
 SET cnt_options += 1
 SET stat = alterlist(reply->options_qual,cnt_options)
 IF (validate(him_r_system_params_inc)=0)
  DECLARE him_r_system_params_inc = i2 WITH public, noconstant(1)
  DECLARE multifacility_ind = i2 WITH protect, noconstant(0)
  DECLARE tracking_orders_ind = i2 WITH protect, noconstant(0)
  DECLARE pending_signs_ind = i2 WITH protect, noconstant(0)
  DECLARE visit_aging_ind = i2 WITH protect, noconstant(0)
  DECLARE doc_aging_ind = i2 WITH protect, noconstant(0)
  DECLARE phys_hold_ind = i2 WITH protect, noconstant(0)
  DECLARE visit_hold_ind = i2 WITH protect, noconstant(0)
  DECLARE days_to_delinq = i4 WITH protect, noconstant(0)
  DECLARE days_to_suspend = i4 WITH protect, noconstant(0)
  DECLARE loading_letters = i2 WITH protect, noconstant(0)
  DECLARE loading_powervision = i2 WITH protect, noconstant(0)
  DECLARE order_delinq_hours = i2 WITH protect, noconstant(0)
  DECLARE order_susp_hours = i2 WITH protect, noconstant(0)
  DECLARE days_to_qualify_order = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM him_system_params hp
   WHERE hp.him_system_params_id > 0
    AND hp.active_ind=1
   DETAIL
    multifacility_ind = hp.facility_logic_ind, tracking_orders_ind = hp.order_tracking_ind,
    pending_signs_ind = hp.pending_signs_ind,
    visit_aging_ind = hp.visitaging_ind, doc_aging_ind = hp.docaging_ind, phys_hold_ind = hp
    .docaging_phys_hold_ind,
    visit_hold_ind = hp.docaging_visit_hold_ind, days_to_suspend = hp.days_to_suspend, days_to_delinq
     = hp.days_to_delinquent,
    loading_letters = hp.loading_letters_ind, loading_powervision = hp.loading_powervision_ind,
    order_delinq_hours = (hp.order_delinquent_days * 24),
    order_susp_hours = (hp.order_suspension_days * 24), days_to_qualify_order = validate(hp
     .days_to_qualify_order,0)
   WITH nocounter
  ;end select
  DECLARE him_multifacility_ind = i2 WITH public, constant(multifacility_ind)
  DECLARE him_tracking_orders_ind = i2 WITH public, constant(tracking_orders_ind)
  DECLARE him_pending_signs_ind = i2 WITH public, constant(pending_signs_ind)
  DECLARE him_visit_aging_ind = i2 WITH public, constant(visit_aging_ind)
  DECLARE him_doc_aging_ind = i2 WITH public, constant(doc_aging_ind)
  DECLARE him_phys_hold_ind = i2 WITH public, constant(phys_hold_ind)
  DECLARE him_visit_hold_ind = i2 WITH public, constant(visit_hold_ind)
  DECLARE him_days_to_suspend = i4 WITH public, constant(days_to_suspend)
  DECLARE him_days_to_delinq = i4 WITH public, constant(days_to_delinq)
  DECLARE him_loading_letters_ind = i2 WITH public, constant(loading_letters)
  DECLARE him_loading_pv_ind = i2 WITH public, constant(loading_powervision)
  DECLARE him_order_delinq_hrs = i2 WITH public, constant(order_delinq_hours)
  DECLARE him_order_susp_hrs = i2 WITH public, constant(order_susp_hours)
  DECLARE him_days_to_qualify_order = i4 WITH public, constant(days_to_qualify_order)
 ENDIF
 SET reply->options_qual[cnt_options].info_name = pend_signs_ind_info_name
 SET reply->options_qual[cnt_options].info_number = him_pending_signs_ind
 SET reply->options_qual[cnt_options].updt_cnt = 0
 IF (dm_info_qual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_dm_info"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to get dm_info option rows."
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
