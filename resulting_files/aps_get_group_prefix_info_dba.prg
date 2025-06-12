CREATE PROGRAM aps_get_group_prefix_info:dba
 RECORD reply(
   1 acc_asgn_xref_qual[*]
     2 site_prefix_cd = f8
     2 accession_format_cd = f8
     2 accession_asgn_pool = f8
   1 group_qual[*]
     2 group_cd = f8
     2 group_name = vc
     2 group_desc = vc
     2 site_cd = f8
     2 site_disp = vc
     2 reset_yearly_ind = i2
     2 manual_assign_ind = i2
     2 active_ind = i2
     2 next_available_nbr = i4
     2 pg_updt_cnt = i4
     2 aap_updt_cnt = i4
     2 prefix_qual[*]
       3 prefix_cd = f8
       3 prefix_desc = c50
       3 prefix_name = c4
       3 case_type_cd = f8
       3 case_type_disp = c40
       3 order_catalog_cd = f8
       3 order_catalog_desc = vc
       3 task_default_cd = f8
       3 initiate_tasks_ind = i2
       3 ap_updt_cnt = i4
       3 active_ind = i2
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 pre_tag_qual[*]
         4 tag_group_cd = f8
         4 tag_type_flag = i2
         4 first_tag_disp = c7
         4 tag_separator = c1
         4 updt_cnt = i4
       3 interface_flag = i2
       3 tracking_service_resource_cd = f8
       3 tracking_service_resource_disp = c40
       3 imaging_interface_ind = i2
       3 imaging_service_resource_cd = f8
       3 imaging_service_resource_disp = c40
   1 orderable_qual[*]
     2 catalog_cd = f8
     2 description = vc
     2 mnemonic = vc
   1 task_default_qual[*]
     2 task_cd = f8
     2 task_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 DECLARE activity_subtype_code_set = i4 WITH protect, constant(5801)
 SET acc_frmt_cnt = 0
 SET acc_asgn_xref_cnt = 0
 SET acc_asgn_cnt = 0
 SET group_cnt = 0
 SET prefix_cnt = 0
 SET pre_tag_cnt = 0
 SET orderable_cnt = 0
 SET max_task_cnt = 0
 SET task_cnt = 0
 SET cnt = 0
 SET already_removed = 0
 SET add_default = 0
 DECLARE apspecimen_cd = f8 WITH protect, noconstant(0.0)
 DECLARE approcess_cd = f8 WITH protect, noconstant(0.0)
 SET _acc_assign_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(year(curdate),
      4,0,r)),"mmddyyyy"),0),2)
 SET stat = alterlist(reply->acc_asgn_xref_qual,1)
 SET stat = alterlist(reply->group_qual,1)
 SET stat = alterlist(reply->group_qual[1].prefix_qual,1)
 SET stat = alterlist(reply->group_qual[1].prefix_qual[1].pre_tag_qual,1)
 SET stat = alterlist(reply->orderable_qual,1)
 SET stat = alterlist(reply->task_default_qual,10)
 SET stat = uar_get_meaning_by_codeset(activity_subtype_code_set,"APSPECIMEN",1,apspecimen_cd)
 IF (apspecimen_cd=0.0)
  CALL subevent_add("UAR","F","5801","CANNOT GET APSPECIMEN CODE VALUE")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(activity_subtype_code_set,"APPROCESS",1,approcess_cd)
 IF (approcess_cd=0.0)
  CALL subevent_add("UAR","F","5801","CANNOT GET APPROCESS CODE VALUE")
 ENDIF
 SELECT INTO "nl:"
  aax.accession_format_cd
  FROM accession_assign_xref aax
  DETAIL
   acc_asgn_xref_cnt = (acc_asgn_xref_cnt+ 1), stat = alterlist(reply->acc_asgn_xref_qual,
    acc_asgn_xref_cnt), reply->acc_asgn_xref_qual[acc_asgn_xref_cnt].site_prefix_cd = aax
   .site_prefix_cd,
   reply->acc_asgn_xref_qual[acc_asgn_xref_cnt].accession_format_cd = aax.accession_format_cd, reply
   ->acc_asgn_xref_qual[acc_asgn_xref_cnt].accession_asgn_pool = aax.accession_assignment_pool_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->acc_asgn_xref_qual,acc_asgn_xref_cnt)
 SELECT INTO "nl:"
  pg.group_id, ap.prefix_id, prefix_exists = evaluate(nullind(ap.prefix_id),1,0,1),
  tag_group_exists = evaluate(nullind(tg.tag_group_id),1,0,1), accn_pool_id_exists = evaluate(nullind
   (aa.acc_assign_pool_id),1,0,1)
  FROM prefix_group pg,
   accession_assign_pool aap,
   accession_assignment aa,
   ap_prefix ap,
   order_catalog oc,
   ap_prefix_tag_group_r tg,
   ap_tag t
  PLAN (pg)
   JOIN (aap
   WHERE pg.group_id=aap.accession_assignment_pool_id)
   JOIN (aa
   WHERE aa.acc_assign_pool_id=outerjoin(pg.group_id)
    AND aa.acc_assign_date=outerjoin(cnvtdatetimeutc(_acc_assign_date,0)))
   JOIN (ap
   WHERE ap.group_id=outerjoin(pg.group_id))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(ap.order_catalog_cd))
   JOIN (tg
   WHERE tg.prefix_id=outerjoin(ap.prefix_id))
   JOIN (t
   WHERE t.tag_group_id=outerjoin(tg.tag_group_id)
    AND t.tag_sequence=outerjoin(1)
    AND t.active_ind=outerjoin(1))
  ORDER BY pg.group_id, ap.prefix_id
  HEAD REPORT
   group_cnt = 0
  HEAD pg.group_id
   IF (pg.group_id > 0.0)
    prefix_cnt = 0, group_cnt = (group_cnt+ 1), stat = alterlist(reply->group_qual,group_cnt),
    reply->group_qual[group_cnt].group_cd = pg.group_id, reply->group_qual[group_cnt].group_name = pg
    .group_name, reply->group_qual[group_cnt].group_desc = pg.group_desc,
    reply->group_qual[group_cnt].site_cd = pg.site_cd, reply->group_qual[group_cnt].reset_yearly_ind
     = pg.reset_yearly_ind, reply->group_qual[group_cnt].manual_assign_ind = pg.manual_assign_ind,
    reply->group_qual[group_cnt].active_ind = pg.active_ind, reply->group_qual[group_cnt].pg_updt_cnt
     = pg.updt_cnt
    IF (accn_pool_id_exists=1)
     reply->group_qual[group_cnt].next_available_nbr = aa.accession_seq_nbr
    ELSE
     reply->group_qual[group_cnt].next_available_nbr = aap.initial_value
    ENDIF
    reply->group_qual[group_cnt].aap_updt_cnt = aap.updt_cnt
   ENDIF
  HEAD ap.prefix_id
   IF (prefix_exists=1)
    prefix_cnt = (prefix_cnt+ 1), stat = alterlist(reply->group_qual[group_cnt].prefix_qual,
     prefix_cnt), reply->group_qual[group_cnt].prefix_qual[prefix_cnt].prefix_cd = ap.prefix_id,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].prefix_desc = ap.prefix_desc, reply->
    group_qual[group_cnt].prefix_qual[prefix_cnt].prefix_name = ap.prefix_name, reply->group_qual[
    group_cnt].prefix_qual[prefix_cnt].case_type_cd = ap.case_type_cd,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].order_catalog_cd = ap.order_catalog_cd,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].order_catalog_desc = oc.primary_mnemonic,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].initiate_tasks_ind = ap
    .initiate_protocol_ind,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].task_default_cd = ap.default_proc_catalog_cd,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].service_resource_cd = ap.service_resource_cd,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].interface_flag = ap.interface_flag,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].tracking_service_resource_cd = ap
    .tracking_service_resource_cd, reply->group_qual[group_cnt].prefix_qual[prefix_cnt].
    imaging_interface_ind = ap.imaging_interface_ind, reply->group_qual[group_cnt].prefix_qual[
    prefix_cnt].imaging_service_resource_cd = ap.imaging_service_resource_cd,
    reply->group_qual[group_cnt].prefix_qual[prefix_cnt].ap_updt_cnt = ap.updt_cnt, reply->
    group_qual[group_cnt].prefix_qual[prefix_cnt].active_ind = ap.active_ind, pre_tag_cnt = 0
   ENDIF
  DETAIL
   IF (prefix_cnt > 0)
    IF (tag_group_exists > 0)
     pre_tag_cnt = (pre_tag_cnt+ 1), stat = alterlist(reply->group_qual[group_cnt].prefix_qual[
      prefix_cnt].pre_tag_qual,pre_tag_cnt), reply->group_qual[group_cnt].prefix_qual[prefix_cnt].
     pre_tag_qual[pre_tag_cnt].tag_group_cd = tg.tag_group_id,
     reply->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt].tag_type_flag =
     tg.tag_type_flag, reply->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt]
     .tag_separator = tg.tag_separator, reply->group_qual[group_cnt].prefix_qual[prefix_cnt].
     pre_tag_qual[pre_tag_cnt].first_tag_disp = t.tag_disp,
     reply->group_qual[group_cnt].prefix_qual[prefix_cnt].pre_tag_qual[pre_tag_cnt].updt_cnt = tg
     .updt_cnt
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->group_qual,group_cnt)
 SELECT INTO "nl:"
  oc.catalog_cd, oc.primary_mnemonic, sd.description
  FROM order_catalog oc,
   service_directory sd
  PLAN (oc
   WHERE oc.activity_subtype_cd=apspecimen_cd
    AND 1=oc.active_ind)
   JOIN (sd
   WHERE oc.catalog_cd=sd.catalog_cd)
  DETAIL
   orderable_cnt = (orderable_cnt+ 1), stat = alterlist(reply->orderable_qual,orderable_cnt), reply->
   orderable_qual[orderable_cnt].catalog_cd = oc.catalog_cd,
   reply->orderable_qual[orderable_cnt].mnemonic = oc.primary_mnemonic, reply->orderable_qual[
   orderable_cnt].description = sd.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orderable_qual,orderable_cnt)
 IF (curqual=0)
  CALL subevent_add("SELECT","F","TABLE","ORDER_CATALOG")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, agi.parent_entity_id
  FROM code_value cv,
   ap_processing_grp_r agi
  PLAN (cv
   WHERE 1310=cv.code_set
    AND 1=cv.active_ind)
   JOIN (agi
   WHERE agi.parent_entity_id=cv.code_value)
  ORDER BY cv.code_value
  HEAD REPORT
   cnt = 0
  HEAD cv.code_value
   already_removed = 0
  DETAIL
   IF (already_removed=0
    AND (agi.begin_section=- (1)))
    already_removed = 1
   ENDIF
  FOOT  cv.code_value
   IF (already_removed=0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->task_default_qual,(cnt+ 9))
    ENDIF
    reply->task_default_qual[cnt].task_cd = cv.code_value, reply->task_default_qual[cnt].task_desc =
    cv.display
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->task_default_qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oc.catalog_cd, ptr.catalog_cd, ataa.task_assay_cd
  FROM order_catalog oc,
   profile_task_r ptr,
   ap_task_assay_addl ataa
  PLAN (oc
   WHERE oc.activity_subtype_cd=approcess_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (ataa
   WHERE ataa.task_assay_cd=ptr.task_assay_cd)
  HEAD REPORT
   cnt = size(reply->task_default_qual,5), inc = (10 - mod(cnt,10)), stat = alterlist(reply->
    task_default_qual,(cnt+ inc))
  DETAIL
   CASE (ataa.create_inventory_flag)
    OF 0:
     IF (ataa.task_type_flag=4)
      add_default = 1
     ENDIF
    OF 1:
     add_default = 1
    OF 2:
     IF (ataa.slide_origin_flag=4)
      add_default = 1
     ENDIF
    OF 3:
     add_default = 1
   ENDCASE
   IF (add_default=1)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->task_default_qual,(cnt+ 9))
    ENDIF
    reply->task_default_qual[cnt].task_cd = oc.catalog_cd, reply->task_default_qual[cnt].task_desc =
    trim(oc.description)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->task_default_qual,cnt)
  WITH nocounter
 ;end select
END GO
