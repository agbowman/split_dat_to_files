CREATE PROGRAM bed_aud_sch_order_roles
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET stat = alterlist(reply->collist,17)
 SET reply->collist[1].header_text = "Appointment Type Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Ambulatory Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Orderable"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Catalog_cd"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Order Role"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Order Role Flexing"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resources Available"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Slot Name(from Slot Types tab)"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Patient Pre Arrival"
 SET reply->collist[10].data_type = 3
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Resource Setup"
 SET reply->collist[11].data_type = 3
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Procedure Duration (minutes)"
 SET reply->collist[12].data_type = 3
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Resource Cleanup"
 SET reply->collist[13].data_type = 3
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Patient Recovery"
 SET reply->collist[14].data_type = 3
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Resource Offset Time"
 SET reply->collist[15].data_type = 3
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Person Prep (Name)"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Post Appointment Instructions (Name)"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET cnt = 0
 SELECT INTO "NL:"
  s.appt_type_cd, sa.description, s.catalog_cd,
  o.primary_mnemonic, so.location_cd, cv1.description,
  sor.list_role_id, sl.resource_cd, cv2.description,
  cv2.display, sod.arrival_units, sod.setup_units,
  sod.duration_units, sod.cleanup_units, sod.recovery_units,
  sod.offset_beg_units, sod1.arrival_units, sod1.setup_units,
  sod1.duration_units, sod1.cleanup_units, sod1.recovery_units,
  sod1.offset_beg_units, ste1.mnemonic, st.text_type_meaning,
  sst.mnemonic, sor.sch_flex_id, slr.description,
  slr.list_role_id, sf.description
  FROM sch_order_appt s,
   sch_appt_type sa,
   order_catalog o,
   sch_order_loc so,
   code_value cv1,
   sch_order_role sor,
   sch_list_res sl,
   sch_list_role slr,
   sch_flex_string sf,
   sch_list_slot sls,
   sch_slot_type sst,
   code_value cv2,
   dummyt d1,
   sch_order_duration sod,
   dummyt d3,
   sch_order_duration sod1,
   sch_text_link st,
   sch_sub_list ss,
   sch_template ste1
  PLAN (s
   WHERE s.active_ind=1
    AND s.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (sa
   WHERE sa.appt_type_cd=s.appt_type_cd
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (o
   WHERE o.catalog_cd=s.catalog_cd
    AND o.active_ind=1)
   JOIN (so
   WHERE s.catalog_cd=so.catalog_cd
    AND so.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cv1
   WHERE cv1.code_set=220
    AND so.location_cd=cv1.code_value)
   JOIN (sor
   WHERE sor.catalog_cd=s.catalog_cd
    AND sor.location_cd=so.location_cd
    AND sor.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sor.active_ind=1)
   JOIN (sl
   WHERE sl.list_role_id=sor.list_role_id
    AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sl.active_ind=1)
   JOIN (slr
   WHERE slr.list_role_id=sl.list_role_id)
   JOIN (sf
   WHERE sor.sch_flex_id=sf.sch_flex_id)
   JOIN (sls
   WHERE sls.list_role_id=sor.list_role_id
    AND sls.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sls.active_ind=1
    AND sls.resource_cd=sl.resource_cd)
   JOIN (sst
   WHERE sst.slot_type_id=sls.slot_type_id)
   JOIN (cv2
   WHERE cv2.code_value=sl.resource_cd
    AND cv2.code_set=14231)
   JOIN (d1)
   JOIN (sod
   WHERE sod.catalog_cd=sor.catalog_cd
    AND sod.location_cd=0
    AND sod.seq_nbr=sor.seq_nbr
    AND sod.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sod.active_ind=1)
   JOIN (d3)
   JOIN (sod1
   WHERE sod1.catalog_cd=sor.catalog_cd
    AND sod1.seq_nbr=sor.seq_nbr
    AND sod1.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sod1.active_ind=1)
   JOIN (st
   WHERE st.parent2_id=so.location_cd
    AND st.parent_id=s.catalog_cd
    AND st.text_type_meaning IN ("PREAPPT", "POSTAPPT")
    AND st.active_ind=1)
   JOIN (ss
   WHERE ss.parent_table="SCH_TEXT_LINK"
    AND ss.parent_id=st.text_link_id
    AND ss.active_ind=1)
   JOIN (ste1
   WHERE ss.template_id=ste1.template_id)
  ORDER BY sa.description
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,100)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->rowlist,(100+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,17), reply->rowlist[cnt].celllist[1].string_value =
   sa.description, reply->rowlist[cnt].celllist[2].string_value = cv1.description,
   reply->rowlist[cnt].celllist[3].double_value = so.location_cd, reply->rowlist[cnt].celllist[4].
   string_value = o.primary_mnemonic, reply->rowlist[cnt].celllist[5].double_value = o.catalog_cd,
   reply->rowlist[cnt].celllist[6].string_value = slr.description, reply->rowlist[cnt].celllist[7].
   string_value = sf.description, reply->rowlist[cnt].celllist[8].string_value = cv2.description,
   reply->rowlist[cnt].celllist[9].string_value = sst.mnemonic
   CASE (sod.offset_type_meaning)
    OF "INHERIT":
     reply->rowlist[cnt].celllist[10].nbr_value = sod1.arrival_units
    ELSE
     reply->rowlist[cnt].celllist[10].nbr_value = sod.arrival_units
   ENDCASE
   reply->rowlist[cnt].celllist[11].nbr_value = sod.setup_units
   CASE (sod.offset_type_meaning)
    OF "INHERIT":
     reply->rowlist[cnt].celllist[12].nbr_value = sod1.duration_units
    ELSE
     reply->rowlist[cnt].celllist[12].nbr_value = sod.duration_units
   ENDCASE
   reply->rowlist[cnt].celllist[12].nbr_value = sod.duration_units, reply->rowlist[cnt].celllist[13].
   nbr_value = sod.cleanup_units, reply->rowlist[cnt].celllist[14].nbr_value = sod.recovery_units,
   reply->rowlist[cnt].celllist[15].nbr_value = sod.offset_beg_units
   CASE (st.text_type_meaning)
    OF "PREAPPT":
     reply->rowlist[cnt].celllist[16].string_value = ste1.mnemonic
    OF "POSTAPPT":
     reply->rowlist[cnt].celllist[17].string_value = ste1.mnemonic
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, separator = " ", format,
   outerjoin = d1, outerjoin = d3
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (cnt > 15000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->collist,0)
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (cnt > 10000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->collist,0)
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("esm_appt_type_order_role.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
