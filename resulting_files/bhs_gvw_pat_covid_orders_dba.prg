CREATE PROGRAM bhs_gvw_pat_covid_orders:dba
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224")
  )
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100")
  )
 DECLARE mf_cs6004_discontinued_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3101"))
 DECLARE mf_cs200_covid192019novelcoronavirus_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"COVID192019NOVELCORONAVIRUS"))
 DECLARE mf_cs200_covid192019novelcoronavirusrna_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"COVID192019NOVELCORONAVIRUSRNA"))
 DECLARE mf_cs200_covid192019novelcoronavirusrtpcr_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"COVID192019NOVELCORONAVIRUSRTPCR"))
 DECLARE mf_cs200_covid19iggantibody_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COVID19IGGANTIBODY"))
 DECLARE mf_cs200_covid19novelcoronavirusrapidpcr_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"COVID19NOVELCORONAVIRUSRAPIDPCR"))
 DECLARE mf_cs200_covid19novelcoronavirusrnapcr_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"COVID19NOVELCORONAVIRUSRNAPCR"))
 DECLARE mf_cs200_covid19sarscov2antibody_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"COVID19SARSCOV2ANTIBODY"))
 DECLARE mf_cs200_covidpuiedonly_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COVIDPUIEDONLY"))
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
     2 l_ce_cnt = i4
     2 ce_qual[*]
       3 f_event_id = f8
       3 s_event_cd = vc
       3 s_result = vc
       3 s_result_dt = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o,
   clinical_event ce,
   order_catalog oc
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.active_ind=1
    AND o.order_status_cd IN (mf_cs6004_ordered_cd, mf_cs6004_inprocess_cd, mf_cs6004_future_cd,
   mf_cs6004_completed_cd, mf_cs6004_discontinued_cd)
    AND o.template_order_flag IN (0, 1))
   JOIN (ce
   WHERE (ce.order_id= Outerjoin(o.order_id))
    AND (ce.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ce.view_level= Outerjoin(1)) )
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.active_ind=1
    AND cnvtupper(oc.primary_mnemonic)="*COVID*19*")
  ORDER BY o.orig_order_dt_tm DESC, o.order_id, ce.event_cd
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].s_order_dt = trim(format(o.orig_order_dt_tm,"MMM/DD/YYYY HH:mm;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_order_name = trim(o.order_mnemonic,3), m_rec->qual[m_rec->l_cnt].
   s_order_status = trim(uar_get_code_display(o.order_status_cd),3)
  HEAD ce.event_cd
   IF (size(trim(ce.result_val,3)) > 0)
    m_rec->qual[m_rec->l_cnt].l_ce_cnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].ce_qual,m_rec
     ->qual[m_rec->l_cnt].l_ce_cnt), m_rec->qual[m_rec->l_cnt].ce_qual[m_rec->qual[m_rec->l_cnt].
    l_ce_cnt].f_event_id = ce.event_id,
    m_rec->qual[m_rec->l_cnt].ce_qual[m_rec->qual[m_rec->l_cnt].l_ce_cnt].s_event_cd = trim(
     uar_get_code_display(ce.event_cd),3), m_rec->qual[m_rec->l_cnt].ce_qual[m_rec->qual[m_rec->l_cnt
    ].l_ce_cnt].s_result = trim(ce.result_val,3), m_rec->qual[m_rec->l_cnt].ce_qual[m_rec->qual[m_rec
    ->l_cnt].l_ce_cnt].s_result_dt = trim(format(ce.performed_dt_tm,"MMM/DD/YYYY HH:mm;;q"),3)
   ENDIF
  WITH nocounter
 ;end select
 SET reply->text = "<html> <body> "
 IF ((m_rec->l_cnt > 0))
  SET reply->text = concat(reply->text,
   " <table border=1 cellspacing=0 cellpadding=0 width=100%> <tr> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Order </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Status </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Order Date/Time </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Result </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Result Date/Time </span></b></p></td> ")
  SET reply->text = concat(reply->text," </tr> ")
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET reply->text = concat(reply->text," <tr> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_name,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_status,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_order_dt,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td> ")
    FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ce_cnt)
      SET reply->text = concat(reply->text," <p><span> ",m_rec->qual[ml_idx1].ce_qual[ml_idx2].
       s_result," </span></p><br> ")
    ENDFOR
    SET reply->text = concat(reply->text," </td> ")
    SET reply->text = concat(reply->text," <td> ")
    FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ce_cnt)
      SET reply->text = concat(reply->text," <p><span> ",m_rec->qual[ml_idx1].ce_qual[ml_idx2].
       s_result_dt," </span></p><br> ")
    ENDFOR
    SET reply->text = concat(reply->text," </td> ")
    SET reply->text = concat(reply->text," </tr> ")
  ENDFOR
  SET reply->text = concat(reply->text," </table> ")
 ELSE
  SET reply->text = concat(reply->text,"<p>"," No COVID Testing Information Available ","</p>")
 ENDIF
 SET reply->text = concat(reply->text,"</body></html>")
 SET reply->format = 1
 CALL echorecord(reply)
#exit_script
END GO
