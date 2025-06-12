CREATE PROGRAM bhs_gvw_pend_studies:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD prsn_orders
 RECORD prsn_orders(
   1 n_cnt = i4
   1 list[*]
     2 s_order_name = vc
 ) WITH protect
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE mf_radiology_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE mf_laboratory_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY")
  )
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE n_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=request->person[1].person_id)
   AND (o.encntr_id=request->visit[1].encntr_id)
   AND o.active_ind=1
   AND o.order_status_cd IN (mf_ordered_cd, mf_inprocess_cd, mf_pending_cd)
   AND o.catalog_type_cd IN (mf_radiology_cd, mf_laboratory_cd)
  ORDER BY uar_get_code_display(o.catalog_cd), o.orig_order_dt_tm DESC
  HEAD REPORT
   prsn_orders->n_cnt = 0
  HEAD o.catalog_cd
   prsn_orders->n_cnt += 1, stat = alterlist(prsn_orders->list,prsn_orders->n_cnt)
   IF (cnvtupper(trim(o.order_mnemonic)) != cnvtupper(trim(o.ordered_as_mnemonic))
    AND size(trim(o.ordered_as_mnemonic)) != 0)
    prsn_orders->list[prsn_orders->n_cnt].s_order_name = concat(trim(o.order_mnemonic)," (",trim(o
      .ordered_as_mnemonic),")")
   ELSE
    prsn_orders->list[prsn_orders->n_cnt].s_order_name = o.order_mnemonic
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(prsn_orders)
 SET s_text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18"
 IF ((prsn_orders->n_cnt > 0))
  FOR (n_idx = 1 TO prsn_orders->n_cnt)
    SET s_text = concat(s_text," ",prsn_orders->list[n_idx].s_order_name," \par ")
  ENDFOR
 ELSE
  SET s_text = concat(s_text," No incomplete studies found \par ")
 ENDIF
 SET s_text = concat(s_text,"}")
 SET reply->text = s_text
END GO
