CREATE PROGRAM bhs_gvw_pat_active_orders:dba
 DECLARE mf_cs6000_pharm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224")
  )
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
    1 format = i4
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_order_id = f8
     2 s_order_name = vc
     2 s_order_status = vc
     2 s_order_dt = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=request->person_id)
   AND o.active_ind=1
   AND o.order_status_cd IN (mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd, mf_cs6004_future_cd)
   AND o.catalog_type_cd != mf_cs6000_pharm_cd
  ORDER BY o.orig_order_dt_tm DESC, o.order_mnemonic
  HEAD REPORT
   m_rec->l_cnt = 0
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].s_order_dt = trim(format(o.orig_order_dt_tm,"MMM/DD/YYYY HH:mm;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_order_name = trim(o.order_mnemonic,3), m_rec->qual[m_rec->l_cnt].
   s_order_status = trim(uar_get_code_display(o.order_status_cd),3)
  WITH nocounter
 ;end select
 SET reply->text = "<html> <body> "
 IF ((m_rec->l_cnt > 0))
  SET reply->text = concat(reply->text,
   " <table border=1 cellspacing=0 cellpadding=0 width=100%> <tr> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Order </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Status </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Order Date/Time </span></b></p></td> ")
  SET reply->text = concat(reply->text," </tr> ")
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET reply->text = concat(reply->text," <tr> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_name,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_status,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_dt,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," </tr> ")
  ENDFOR
  SET reply->text = concat(reply->text," </table> ")
 ELSE
  SET reply->text = concat(reply->text,"<p>"," No Outstanding/Future Orders Found ","</p>")
 ENDIF
 SET reply->text = concat(reply->text,"</body></html>")
 SET reply->format = 1
 CALL echorecord(reply)
#exit_script
END GO
