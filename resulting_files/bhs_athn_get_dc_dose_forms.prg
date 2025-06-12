CREATE PROGRAM bhs_athn_get_dc_dose_forms
 RECORD t_record(
   1 item_cnt = i4
   1 item_qual[*]
     2 item_id = f8
     2 value = vc
     2 qual_ind = i2
 )
 RECORD out_rec(
   1 meds[*]
     2 med = vc
 )
 DECLARE description_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"DESCRIPTION"))
 DECLARE organization_id = f8
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   organization_id = e.organization_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   med_identifier mi,
   item_definition id
  PLAN (ocs
   WHERE (ocs.catalog_cd= $3)
    AND ocs.active_ind=1)
   JOIN (mi
   WHERE mi.item_id=ocs.item_id
    AND mi.med_identifier_type_cd=description_cd
    AND mi.active_ind=1
    AND mi.med_product_id=0)
   JOIN (id
   WHERE id.item_id=mi.item_id
    AND id.active_ind=1)
  ORDER BY mi.value
  HEAD mi.value
   t_record->item_cnt += 1
   IF (mod(t_record->item_cnt,100)=1)
    stat = alterlist(t_record->item_qual,(t_record->item_cnt+ 99))
   ENDIF
   i_cnt = t_record->item_cnt, t_record->item_qual[i_cnt].item_id = mi.item_id, t_record->item_qual[
   i_cnt].value = mi.value,
   t_record->item_qual[i_cnt].qual_ind = 1
  FOOT REPORT
   stat = alterlist(t_record->item_qual,t_record->item_cnt)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->item_cnt),
   item_org_reltn ior
  PLAN (d)
   JOIN (ior
   WHERE (ior.item_id=t_record->item_qual[d.seq].item_id))
  ORDER BY ior.item_id
  HEAD ior.item_id
   t_record->item_qual[d.seq].qual_ind = 0
  DETAIL
   IF (ior.org_id=organization_id)
    t_record->item_qual[d.seq].qual_ind = 1
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->item_cnt)
  PLAN (d
   WHERE (t_record->item_qual[d.seq].qual_ind=1))
  HEAD REPORT
   m_cnt = 0
  DETAIL
   m_cnt += 1, stat = alterlist(out_rec->meds,m_cnt), out_rec->meds[m_cnt].med = t_record->item_qual[
   d.seq].value
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
 CALL echorecord(out_rec)
END GO
