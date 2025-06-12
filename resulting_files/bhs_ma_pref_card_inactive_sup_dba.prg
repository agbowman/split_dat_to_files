CREATE PROGRAM bhs_ma_pref_card_inactive_sup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_item_nbr = vc
     2 s_desc = vc
     2 s_object_id = vc
     2 s_item_id = vc
     2 s_pref_card_id = vc
     2 s_area = vc
     2 s_doc_type = vc
     2 s_provider = vc
     2 s_orderable = vc
     2 s_pc_updt_dt = vc
     2 s_pc_updt_id = vc
     2 s_pc_updt_task = vc
     2 s_pl_updt_dt = vc
     2 s_pl_updt_id = vc
     2 s_pl_updt_task = vc
     2 s_item_updt_dt = vc
     2 s_item_updt_id = vc
     2 s_item_updt_task = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM preference_card sc,
   pref_card_pick_list ccpl,
   item_master im,
   item_definition id,
   package_type pt,
   object_identifier_index oii,
   object_identifier_index oii2,
   prsnl p2
  PLAN (sc
   WHERE sc.active_ind=1)
   JOIN (ccpl
   WHERE ccpl.pref_card_id=sc.pref_card_id
    AND ccpl.active_ind=1)
   JOIN (im
   WHERE im.item_id=ccpl.item_id)
   JOIN (id
   WHERE id.item_id=im.item_id)
   JOIN (pt
   WHERE pt.item_id=id.item_id
    AND pt.base_package_type_ind=1)
   JOIN (oii
   WHERE oii.object_id=id.item_id
    AND oii.generic_object=0.00
    AND (oii.identifier_type_cd=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=11000
     AND cv.cdf_meaning="ITEM_NBR")))
   JOIN (oii2
   WHERE oii2.object_id=id.item_id
    AND oii2.generic_object=0.00
    AND oii2.active_ind=0
    AND (oii2.identifier_type_cd=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=11000
     AND cv.cdf_meaning="DESC")))
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(sc.prsnl_id)) )
  ORDER BY oii.object_id, oii.value, oii2.value,
   im.item_id, sc.pref_card_id, sc.surg_area_cd,
   sc.doc_type_cd, p2.name_full_formatted, sc.catalog_cd
  HEAD oii.object_id
   null
  HEAD oii.value
   null
  HEAD oii2.value
   null
  HEAD im.item_id
   null
  HEAD sc.pref_card_id
   null
  HEAD sc.surg_area_cd
   null
  HEAD sc.doc_type_cd
   null
  HEAD p2.name_full_formatted
   null
  HEAD sc.catalog_cd
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   s_item_nbr = trim(substring(1,30,trim(oii.value,3)),3),
   m_rec->qual[m_rec->l_cnt].s_desc = trim(oii2.value,3), m_rec->qual[m_rec->l_cnt].s_object_id =
   trim(cnvtstring(oii.object_id,20,0),3), m_rec->qual[m_rec->l_cnt].s_item_id = trim(cnvtstring(im
     .item_id,20,0),3),
   m_rec->qual[m_rec->l_cnt].s_pref_card_id = trim(cnvtstring(sc.pref_card_id,20,0),3), m_rec->qual[
   m_rec->l_cnt].s_area = trim(uar_get_code_display(sc.surg_area_cd),3), m_rec->qual[m_rec->l_cnt].
   s_doc_type = trim(uar_get_code_display(sc.doc_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_provider = trim(p2.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_orderable = trim(uar_get_code_display(sc.catalog_cd),3), m_rec->qual[m_rec->l_cnt].s_pc_updt_dt
    = trim(format(sc.updt_dt_tm,";;q"),3),
   m_rec->qual[m_rec->l_cnt].s_pc_updt_id = trim(cnvtstring(sc.updt_id,20,0),3), m_rec->qual[m_rec->
   l_cnt].s_pc_updt_task = trim(cnvtstring(sc.updt_task,20,0),3), m_rec->qual[m_rec->l_cnt].
   s_pl_updt_dt = trim(format(ccpl.updt_dt_tm,";;q"),3),
   m_rec->qual[m_rec->l_cnt].s_pl_updt_id = trim(cnvtstring(ccpl.updt_id,20,0),3), m_rec->qual[m_rec
   ->l_cnt].s_pl_updt_task = trim(cnvtstring(ccpl.updt_task,20,0),3), m_rec->qual[m_rec->l_cnt].
   s_item_updt_dt = trim(format(id.updt_dt_tm,";;q"),3),
   m_rec->qual[m_rec->l_cnt].s_item_updt_id = trim(cnvtstring(id.updt_id,20,0),3), m_rec->qual[m_rec
   ->l_cnt].s_item_updt_task = trim(cnvtstring(id.updt_task,20,0),3)
  WITH nocounter, maxcol = 20000, format,
   separator = " ", memsort
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   item_number = trim(substring(1,100,m_rec->qual[d.seq].s_item_nbr)), description = trim(substring(1,
     100,m_rec->qual[d.seq].s_desc)), object_id = trim(substring(1,100,m_rec->qual[d.seq].s_object_id
     )),
   item_id = trim(substring(1,100,m_rec->qual[d.seq].s_item_id)), pref_card_id = trim(substring(1,100,
     m_rec->qual[d.seq].s_pref_card_id)), area = trim(substring(1,100,m_rec->qual[d.seq].s_area)),
   doc_type = trim(substring(1,100,m_rec->qual[d.seq].s_doc_type)), provider = trim(substring(1,100,
     m_rec->qual[d.seq].s_provider)), orderable = trim(substring(1,100,m_rec->qual[d.seq].s_orderable
     )),
   pref_card_updt_dt_tm = trim(substring(1,100,m_rec->qual[d.seq].s_pc_updt_dt)), pref_card_updt_id
    = trim(substring(1,100,m_rec->qual[d.seq].s_pc_updt_id)), pref_card_updt_task = trim(substring(1,
     100,m_rec->qual[d.seq].s_pc_updt_task)),
   pick_list_updt_dt_tm = trim(substring(1,100,m_rec->qual[d.seq].s_pl_updt_dt)), pick_list_updt_id
    = trim(substring(1,100,m_rec->qual[d.seq].s_pl_updt_id)), pick_list_updt_task = trim(substring(1,
     100,m_rec->qual[d.seq].s_pl_updt_task)),
   item_updt_dt_tm = trim(substring(1,100,m_rec->qual[d.seq].s_item_updt_dt)), item_updt_id = trim(
    substring(1,100,m_rec->qual[d.seq].s_item_updt_id)), item_updt_task = trim(substring(1,100,m_rec
     ->qual[d.seq].s_item_updt_task))
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No data qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08, maxcol = 1000
  ;end select
 ENDIF
#exit_script
END GO
