CREATE PROGRAM bed_aud_dta_associations:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 dtas[*]
      2 assay_code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reply_sort(
   1 dtas[*]
     2 assay_id = f8
     2 assay_display = vc
     2 assay_description = vc
     2 event_id = f8
     2 template_id = f8
     2 locations[*]
       3 location_type = vc
       3 location_description = vc
       3 location_section = vc
 )
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Documented Location Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Documented Location Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Documented Location Section"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE locationcount = i4 WITH protect, noconstant(0)
 DECLARE rowcount = i4 WITH protect, noconstant(0)
 DECLARE currentrow = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->dtas,5)
 IF (req_cnt <= 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   discrete_task_assay dta
  PLAN (d)
   JOIN (dta
   WHERE (dta.task_assay_cd=request->dtas[d.seq].assay_code_value))
  ORDER BY d.seq, dta.mnemonic
  DETAIL
   stat = alterlist(reply_sort->dtas,d.seq), reply_sort->dtas[d.seq].assay_id = request->dtas[d.seq].
   assay_code_value, reply_sort->dtas[d.seq].assay_display = dta.mnemonic,
   reply_sort->dtas[d.seq].assay_description = dta.description, reply_sort->dtas[d.seq].event_id =
   dta.event_cd, reply_sort->dtas[d.seq].template_id = dta.label_template_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   doc_set_element_ref der,
   doc_set_section_ref_r dsrr,
   doc_set_ref dsr,
   doc_set_section_ref dssr
  PLAN (d)
   JOIN (der
   WHERE (der.task_assay_cd=reply_sort->dtas[d.seq].assay_id)
    AND der.active_ind=1
    AND der.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (dsrr
   WHERE dsrr.doc_set_section_ref_id=der.doc_set_section_ref_id
    AND dsrr.active_ind=1
    AND dsrr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND  NOT ( EXISTS (
   (SELECT
    dlt.doc_set_ref_id
    FROM dynamic_label_template dlt
    WHERE dlt.doc_set_ref_id=dsrr.doc_set_ref_id))))
   JOIN (dsr
   WHERE dsr.doc_set_ref_id=dsrr.doc_set_ref_id
    AND dsr.active_ind=1)
   JOIN (dssr
   WHERE dssr.doc_set_section_ref_id=dsrr.doc_set_section_ref_id
    AND dssr.active_ind=1)
  ORDER BY dsr.doc_set_name, dssr.doc_set_section_name
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "ACTIVITYVIEW", reply_sort->dtas[
   d.seq].locations[locationcount].location_description = dsr.doc_set_name, reply_sort->dtas[d.seq].
   locations[locationcount].location_section = dssr.doc_set_section_name
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   doc_set_element_ref dser,
   doc_set_section_ref_r dsrr,
   dynamic_label_template dlt,
   doc_set_ref dsr,
   doc_set_section_ref dssr
  PLAN (d)
   JOIN (dser
   WHERE (dser.task_assay_cd=reply_sort->dtas[d.seq].assay_id)
    AND dser.active_ind=1
    AND dser.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (dsrr
   WHERE dsrr.doc_set_section_ref_id=dser.doc_set_section_ref_id
    AND dsrr.active_ind=1
    AND dsrr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (dlt
   WHERE dlt.doc_set_ref_id=dsrr.doc_set_ref_id)
   JOIN (dsr
   WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id
    AND dsr.active_ind=1)
   JOIN (dssr
   WHERE dssr.doc_set_section_ref_id=dsrr.doc_set_section_ref_id
    AND dssr.active_ind=1)
  ORDER BY dsr.doc_set_name, dssr.doc_set_section_name
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "DYNAMICGRPLABEL", reply_sort->
   dtas[d.seq].locations[locationcount].location_description = dsr.doc_set_name, reply_sort->dtas[d
   .seq].locations[locationcount].location_section = dssr.doc_set_section_name
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   dynamic_label_template dlt,
   doc_set_ref dsr
  PLAN (d)
   JOIN (dlt
   WHERE (dlt.label_template_id=reply_sort->dtas[d.seq].template_id)
    AND dlt.label_template_id > 0)
   JOIN (dsr
   WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
  ORDER BY dsr.doc_set_name
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "DYNAMICGRPTEMP", reply_sort->
   dtas[d.seq].locations[locationcount].location_description = dsr.doc_set_name, reply_sort->dtas[d
   .seq].locations[locationcount].location_section = " "
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   v500_event_code vec,
   working_view_item wvi,
   working_view_section wvs,
   v500_event_set_code vesc,
   working_view wv
  PLAN (d)
   JOIN (vec
   WHERE (vec.event_cd=reply_sort->dtas[d.seq].event_id))
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(vec.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
   JOIN (vesc
   WHERE cnvtupper(vesc.event_set_name)=cnvtupper(wvs.event_set_name))
   JOIN (wv
   WHERE wv.working_view_id=wvs.working_view_id
    AND wv.active_ind=1)
  ORDER BY wv.display_name, vesc.event_set_cd_disp
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "IVIEW", reply_sort->dtas[d.seq].
   locations[locationcount].location_description = wv.display_name, reply_sort->dtas[d.seq].
   locations[locationcount].location_section = vesc.event_set_cd_disp
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   v500_event_code vec,
   v500_event_set_code vesc2,
   v500_event_set_canon vcan,
   v500_event_set_code vesc1,
   working_view_item wvi,
   working_view_section wvs,
   v500_event_set_code vesc3,
   working_view wv
  PLAN (d)
   JOIN (vec
   WHERE (vec.event_cd=reply_sort->dtas[d.seq].event_id))
   JOIN (vesc2
   WHERE cnvtupper(vesc2.event_set_name)=cnvtupper(vec.event_set_name))
   JOIN (vcan
   WHERE vcan.event_set_cd=vesc2.event_set_cd)
   JOIN (vesc1
   WHERE vesc1.event_set_cd=vcan.parent_event_set_cd
    AND vesc1.display_association_ind=1)
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(vesc1.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
   JOIN (vesc3
   WHERE cnvtupper(vesc3.event_set_name)=cnvtupper(wvs.event_set_name))
   JOIN (wv
   WHERE wv.working_view_id=wvs.working_view_id
    AND wv.active_ind=1)
  ORDER BY wv.display_name, vesc3.event_set_cd_disp
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "IVIEW", reply_sort->dtas[d.seq].
   locations[locationcount].location_description = wv.display_name, reply_sort->dtas[d.seq].
   locations[locationcount].location_section = vesc3.event_set_cd_disp
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 DECLARE medtasktypecd = f8 WITH constant(uar_get_code_by("MEANING",6026,"MED")), protect
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   task_discrete_r tdr,
   order_task ot
  PLAN (d)
   JOIN (tdr
   WHERE (tdr.task_assay_cd=reply_sort->dtas[d.seq].assay_id)
    AND tdr.active_ind=1)
   JOIN (ot
   WHERE ot.reference_task_id=tdr.reference_task_id
    AND ot.active_ind=1
    AND ot.task_type_cd=medtasktypecd)
  ORDER BY ot.task_description
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "MARCHARTINGELEMENT", reply_sort
   ->dtas[d.seq].locations[locationcount].location_description = ot.task_description, reply_sort->
   dtas[d.seq].locations[locationcount].location_section = " "
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   pathway_catalog p,
   pathway_comp pc,
   outcome_catalog o
  PLAN (d)
   JOIN (o
   WHERE (o.task_assay_cd=reply_sort->dtas[d.seq].assay_id))
   JOIN (pc
   WHERE pc.parent_entity_id=o.outcome_catalog_id)
   JOIN (p
   WHERE p.pathway_catalog_id=pc.pathway_catalog_id
    AND p.active_ind=1
    AND p.pathway_catalog_id > 0.0)
  ORDER BY d.seq, p.description
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "OUTCOMES/INTERVENTIONS",
   reply_sort->dtas[d.seq].locations[locationcount].location_description = p.description, reply_sort
   ->dtas[d.seq].locations[locationcount].location_section = " "
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply_sort->dtas,5))),
   dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (d)
   JOIN (dfr
   WHERE dfr.active_ind=1)
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.active_ind=1
    AND (nvp.merge_id=reply_sort->dtas[d.seq].assay_id))
  ORDER BY dfr.description, dsr.description
  HEAD d.seq
   locationcount = size(reply_sort->dtas[d.seq].locations,5)
  DETAIL
   locationcount = (locationcount+ 1), rowcount = (rowcount+ 1), stat = alterlist(reply_sort->dtas[d
    .seq].locations,locationcount),
   reply_sort->dtas[d.seq].locations[locationcount].location_type = "POWERFORM", reply_sort->dtas[d
   .seq].locations[locationcount].location_description = dfr.description, reply_sort->dtas[d.seq].
   locations[locationcount].location_section = dsr.description
  FOOT  d.seq
   locationcount = 0
  WITH nocounter
 ;end select
 SET dtaamount = value(size(reply_sort->dtas,5))
 IF (dtaamount > 0)
  SET stat = alterlist(reply->rowlist,rowcount)
  SET currentrow = 0
  FOR (x = 1 TO dtaamount)
   SET locationamount = value(size(reply_sort->dtas[x].locations,5))
   IF (locationamount > 0)
    FOR (y = 1 TO locationamount)
      SET currentrow = (currentrow+ 1)
      SET stat = alterlist(reply->rowlist[currentrow].celllist,5)
      SET reply->rowlist[currentrow].celllist[1].string_value = reply_sort->dtas[x].assay_display
      SET reply->rowlist[currentrow].celllist[2].string_value = reply_sort->dtas[x].assay_description
      SET reply->rowlist[currentrow].celllist[3].string_value = reply_sort->dtas[x].locations[y].
      location_type
      SET reply->rowlist[currentrow].celllist[4].string_value = reply_sort->dtas[x].locations[y].
      location_description
      SET reply->rowlist[currentrow].celllist[5].string_value = reply_sort->dtas[x].locations[y].
      location_section
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (rowcount > 30000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (rowcount > 20000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("dta_associations.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
