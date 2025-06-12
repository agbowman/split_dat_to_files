CREATE PROGRAM afc_get_spec_coll:dba
 SET afc_get_spec_coll_vrsn = "162220.005"
 IF (validate(reply->action_type,"XXX")="XXX")
  RECORD reply(
    1 action_type = c3
    1 charge_event_qual = i2
    1 charge_event[*]
      2 ext_master_event_id = f8
      2 ext_master_event_cont_cd = f8
      2 ext_master_reference_id = f8
      2 ext_master_reference_cont_cd = f8
      2 ext_parent_event_id = f8
      2 ext_parent_event_cont_cd = f8
      2 ext_parent_reference_id = f8
      2 ext_parent_reference_cont_cd = f8
      2 ext_item_event_id = f8
      2 ext_item_event_cont_cd = f8
      2 ext_item_reference_id = f8
      2 ext_item_reference_cont_cd = f8
      2 person_id = f8
      2 person_name = vc
      2 accession = vc
      2 encntr_id = f8
      2 order_mnemonic = c20
      2 mnemonic = c20
      2 charge_event_act_qual = i2
      2 charge_event_act[*]
        3 charge_event_id = f8
        3 cea_type_cd = f8
        3 cea_prsnl_id = f8
        3 cea_prsnl_type_cd = f8
        3 service_resource_cd = f8
        3 service_dt_tm = dq8
        3 charge_type_cd = f8
        3 quantity = i4
  )
 ENDIF
 DECLARE ce_collected = f8
 DECLARE ce_collection = f8
 DECLARE ce_specimen = f8
 DECLARE ce_coll_act = f8
 DECLARE ce_coll_type = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13029
 SET cdf_meaning = "COLLECTED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_collected)
 SET code_set = 13028
 SET cdf_meaning = "COLLECTION"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_collection)
 SET code_set = 13016
 SET cdf_meaning = "SPECIMEN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_specimen)
 SET code_set = 13016
 SET cdf_meaning = "COLL ACT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_coll_act)
 SET code_set = 13016
 SET cdf_meaning = "COLL TYPE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_coll_type)
 SET count1 = 0
 SET lastspecid = 0
 RECORD specs(
   1 spec_qual = i4
   1 specs[*]
     2 specimen_id = f8
     2 specimen_type_cd = f8
     2 drawn_dt_tm = dq8
     2 collection_method_cd = f8
     2 order_id = f8
     2 order_mnemonic = c25
     2 orig_order_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c20
     2 accession = c18
     2 current_location_cd = f8
     2 order_status_cd = f8
     2 collected_flag = i2
     2 charge_event_id = f8
     2 ce_ordered_flag = i2
     2 ce_collected_flag = i2
     2 ce_completed_flag = i2
     2 drawn_id = f8
 )
 SET count1 = 0
 SET lastspecid = 0
 SET lastdrawndttm = cnvtdatetime(curdate,curtime)
 SET lastspectype = 0
 SET lastcollect = 0
 SET lastencntr = 0
 SET duplicate = 0
 SELECT INTO "nl:"
  s.specimen_id, s.specimen_type_cd, s.collection_method_cd,
  s.drawn_dt_tm, o.order_id, o.person_id,
  o.order_mnemonic, o.orig_order_dt_tm, o.activity_type_cd,
  o.order_status_cd, cv.display
  FROM v500_specimen s,
   container c,
   order_container_r ocr,
   orders o,
   code_value cv
  PLAN (s
   WHERE s.drawn_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (c
   WHERE c.specimen_id=s.specimen_id)
   JOIN (ocr
   WHERE ocr.container_id=c.container_id)
   JOIN (o
   WHERE o.order_id=ocr.order_id)
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
  DETAIL
   IF (lastspecid != s.specimen_id)
    IF (lastdrawndttm=cnvtdatetime(s.drawn_dt_tm)
     AND lastspectype=s.specimen_type_cd
     AND lastcollect=c.collection_method_cd
     AND lastencntr=o.encntr_id)
     duplicate = 1
    ELSE
     duplicate = 0
    ENDIF
    lastspecid = s.specimen_id, lastdrawndttm = cnvtdatetime(s.drawn_dt_tm), lastspectype = s
    .specimen_type_cd,
    lastcollect = c.collection_method_cd, lastencntr = o.encntr_id, count1 = (count1+ 1),
    stat = alterlist(specs->specs,count1), specs->specs[count1].specimen_id = s.specimen_id, specs->
    specs[count1].specimen_type_cd = s.specimen_type_cd,
    specs->specs[count1].drawn_dt_tm = s.drawn_dt_tm, specs->specs[count1].collection_method_cd = c
    .collection_method_cd, specs->specs[count1].order_id = o.order_id,
    specs->specs[count1].order_mnemonic = o.order_mnemonic, specs->specs[count1].orig_order_dt_tm = o
    .orig_order_dt_tm, specs->specs[count1].person_id = o.person_id,
    specs->specs[count1].encntr_id = o.encntr_id, specs->specs[count1].activity_type_cd = o
    .activity_type_cd, specs->specs[count1].activity_type_disp = cv.display,
    specs->specs[count1].order_status_cd = o.order_status_cd, specs->specs[count1].
    current_location_cd = c.current_location_cd, specs->specs[count1].collected_flag = 1
    IF (duplicate=1)
     specs->specs[count1].ce_collected_flag = 1
    ELSE
     specs->specs[count1].ce_collected_flag = 0
    ENDIF
    specs->specs[count1].drawn_id = c.drawn_id
   ENDIF
  WITH nocounter
 ;end select
 SET specs->spec_qual = count1
 CALL echo(build("AFC_GET_SPEC_COLL: Specimens Read: ",specs->spec_qual))
 SELECT INTO "nl:"
  cea.charge_event_act_id
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   charge_event c,
   charge_event_act cea
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1))
   JOIN (c
   WHERE (c.ext_m_event_id=specs->specs[d1.seq].specimen_id)
    AND c.ext_m_event_cont_cd=ce_coll_act
    AND (c.ext_i_event_id=specs->specs[d1.seq].specimen_id)
    AND c.ext_i_event_cont_cd=ce_coll_act
    AND (c.ext_i_reference_id=specs->specs[d1.seq].collection_method_cd)
    AND c.ext_i_reference_cont_cd=ce_coll_type
    AND (c.encntr_id=specs->specs[d1.seq].encntr_id))
   JOIN (cea
   WHERE cea.charge_event_id=c.charge_event_id
    AND cea.cea_type_cd=ce_collected
    AND cea.service_dt_tm=cnvtdatetime(specs->specs[d1.seq].drawn_dt_tm))
  DETAIL
   IF (cea.charge_event_act_id != 0)
    specs->specs[d1.seq].ce_collected_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("AFC_GET_SPEC_COLL: Retrieving Accession Numbers...")
 SELECT INTO "nl:"
  a.accession
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   accession_order_r r,
   accession a
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1)
    AND (specs->specs[d1.seq].ce_collected_flag=0))
   JOIN (r
   WHERE (r.order_id=specs->specs[d1.seq].order_id))
   JOIN (a
   WHERE a.accession_id=r.accession_id)
  DETAIL
   specs->specs[d1.seq].accession = a.accession
  WITH nocounter
 ;end select
 CALL echo("AFC_GET_SPEC_COLL: Retrieving Person Names...")
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   person p
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1)
    AND (specs->specs[d1.seq].ce_collected_flag=0))
   JOIN (p
   WHERE (p.person_id=specs->specs[d1.seq].person_id))
  DETAIL
   specs->specs[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET count1 = 0
 CALL echo("AFC_GET_SPEC_COLL: spec_qual = ",0)
 CALL echo(specs->spec_qual)
 IF ((specs->spec_qual=0))
  GO TO endprog
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(specs->spec_qual))
  PLAN (d1
   WHERE (specs->specs[d1.seq].ce_collected_flag=0))
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->charge_event,count1), reply->charge_event[count1].
   ext_master_event_id = specs->specs[d1.seq].specimen_id,
   reply->charge_event[count1].ext_master_event_cont_cd = ce_coll_act, reply->charge_event[count1].
   ext_master_reference_id = specs->specs[d1.seq].specimen_type_cd, reply->charge_event[count1].
   ext_master_reference_cont_cd = ce_specimen,
   reply->charge_event[count1].ext_parent_event_id = specs->specs[d1.seq].specimen_id, reply->
   charge_event[count1].ext_parent_event_cont_cd = ce_coll_act, reply->charge_event[count1].
   ext_parent_reference_id = specs->specs[d1.seq].specimen_type_cd,
   reply->charge_event[count1].ext_parent_reference_cont_cd = ce_specimen, reply->charge_event[count1
   ].ext_item_event_id = specs->specs[d1.seq].specimen_id, reply->charge_event[count1].
   ext_item_event_cont_cd = ce_coll_act,
   reply->charge_event[count1].ext_item_reference_id = specs->specs[d1.seq].collection_method_cd,
   reply->charge_event[count1].ext_item_reference_cont_cd = ce_coll_type, reply->charge_event[count1]
   .person_id = specs->specs[d1.seq].person_id,
   reply->charge_event[count1].person_name = specs->specs[d1.seq].person_name, reply->charge_event[
   count1].encntr_id = specs->specs[d1.seq].encntr_id, reply->charge_event[count1].accession = specs
   ->specs[d1.seq].accession,
   reply->charge_event[count1].order_mnemonic = specs->specs[d1.seq].order_mnemonic, stat = alterlist
   (reply->charge_event[count1].charge_event_act,1), reply->charge_event[count1].charge_event_act[1].
   service_dt_tm = specs->specs[d1.seq].drawn_dt_tm,
   reply->charge_event[count1].charge_event_act[1].quantity = 1, reply->charge_event[count1].
   charge_event_act[1].charge_type_cd = ce_collection, reply->charge_event[count1].charge_event_act[1
   ].cea_type_cd = ce_collected,
   reply->charge_event[count1].charge_event_act[1].service_resource_cd = specs->specs[d1.seq].
   current_location_cd, reply->charge_event[count1].charge_event_act[1].cea_prsnl_id = specs->specs[
   d1.seq].drawn_id, reply->charge_event[count1].charge_event_act_qual = 1
  WITH nocounter
 ;end select
#endprog
 SET reply->charge_event_qual = count1
 FREE SET specs
END GO
