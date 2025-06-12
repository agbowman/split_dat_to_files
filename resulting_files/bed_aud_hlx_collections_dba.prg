CREATE PROGRAM bed_aud_hlx_collections:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
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
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 primary_mnem = vc
     2 catalog_cd = f8
     2 resource_route_lvl = i2
     2 accn_class = vc
     2 spec_type = vc
     2 def_coll_method = vc
     2 srvres = vc
     2 srvres_cd = f8
     2 age_from_min = i4
     2 age_from = vc
     2 age_to_min = i4
     2 age_to = vc
     2 min_vol = vc
     2 min_vol_units = vc
     2 spec_cont = vc
     2 coll_class = vc
     2 spec_handling = vc
     2 extra_label = vc
     2 activity_type = vc
     2 activity_subtype = vc
     2 instr_bench_status = vc
     2 specimen_type_cd = f8
     2 aliquot_seq = i4
     2 aliquots[*]
       3 min_vol = vc
       3 spec_cntnr_disp = vc
       3 coll_class_disp = vc
       3 spec_hndl_disp = vc
       3 netting = vc
 ) WITH protect
 IF ( NOT (validate(i18nhandle)))
  IF (validate(i18nuar_def,999)=999)
   CALL echo("Declaring i18nuar_def")
   DECLARE i18nuar_def = i2 WITH persist
   SET i18nuar_def = 1
   DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
   DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
   DECLARE uar_i18nbuildmessage() = vc WITH persist
   DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
   c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
   "uar_i18nGetHijriDate",
   persist
   DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
    stitle=vc(ref),
    sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
   "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
   persist
   DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
   "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
   persist
  ENDIF
  DECLARE i18nhandle = i4 WITH protect, noconstant(0)
  CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
  DECLARE sminutes = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"MINUTES","Minutes"))
  DECLARE shours = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"HOURS","Hours"))
  DECLARE sdays = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
  DECLARE sweeks = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"WEEKS","Weeks"))
  DECLARE smonths = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"MONTHS","Months"))
  DECLARE syears = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"YEARS","Years"))
  DECLARE sactive = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ACTIVE","Active"))
  DECLARE sinactive = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"INACTIVE","Inactive"))
  DECLARE sall = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ALL","ALL"))
  DECLARE syes = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"YES","Yes"))
  DECLARE sno = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"NO","No"))
  DECLARE sinactive_reltn = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"INACTIVE_RELTN",
    "Inactive Relation"))
  DECLARE sinvalid = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"INVALID","Invalid"))
  DECLARE sprimary_name = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"PRIMARY_NAME",
    "Millennium Name (Primary Synonym)"))
  DECLARE sacc_class = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ACC_CLASS",
    "Accession Class"))
  DECLARE sspec_type = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"SPEC_TYPE",
    "Specimen Type"))
  DECLARE scoll_method = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"COLL_METHOD",
    "Collection Method"))
  DECLARE sinstrument = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"INSTRUMENT",
    "Instrument/Bench"))
  DECLARE sage_from = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"AGE_FROM","Age From"))
  DECLARE sage_to = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"AGE_TO","Age To"))
  DECLARE smin_vol = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"MIN_VOL",
    "Minimum Volume"))
  DECLARE scontainer = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"CONTAINER",
    "Container"))
  DECLARE scoll_class = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"COLL_CLASS",
    "Collection Class"))
  DECLARE sspec_handle = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"SPEC_HANDLE",
    "Special Handling"))
  DECLARE sextra_label = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"EXTRA_LABEL",
    "Extra Label"))
  DECLARE sactivity_type = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ACTIVITY_TYPE",
    "Activity Type"))
  DECLARE ssub_act_type = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"SUB_ACT_TYPE",
    "Subactivity Type"))
  DECLARE sinstrument_status = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,
    "INSTRUMENT_STATUS","Instrument/Bench Status"))
  DECLARE saliq_min_vol = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ALIQ_MIN_VOL",
    "Aliquot Min Vol"))
  DECLARE saliq_container = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ALIQ_CONTAINER",
    "Aliquot Container"))
  DECLARE saliq_coll_class = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,
    "ALIQ_COLL_CLASS","Aliquot Coll Class"))
  DECLARE saliq_spec_handle = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,
    "ALIQ_SPEC_HANDLE","Aliquot Spec Handling"))
  DECLARE saliq_netting = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ALIQ_NETTING",
    "Aliquot Netting"))
 ENDIF
 DECLARE populatecelllist(lrowlistndx=i4,ltempqualndx=i4) = null WITH protect
 DECLARE fmttimedisp(ltime=i4,stimetype=vc) = vc WITH protect
 DECLARE nprimary_name = i2 WITH protect, constant(1)
 DECLARE nacc_class = i2 WITH protect, constant(2)
 DECLARE nspec_type = i2 WITH protect, constant(3)
 DECLARE ncoll_method = i2 WITH protect, constant(4)
 DECLARE ninstrument = i2 WITH protect, constant(5)
 DECLARE nage_from = i2 WITH protect, constant(6)
 DECLARE nage_to = i2 WITH protect, constant(7)
 DECLARE nmin_vol = i2 WITH protect, constant(8)
 DECLARE ncontainer = i2 WITH protect, constant(9)
 DECLARE ncoll_class = i2 WITH protect, constant(10)
 DECLARE nspec_handle = i2 WITH protect, constant(11)
 DECLARE nextra_label = i2 WITH protect, constant(12)
 DECLARE nactivity_type = i2 WITH protect, constant(13)
 DECLARE nsub_act_type = i2 WITH protect, constant(14)
 DECLARE ninstrument_status = i2 WITH protect, constant(15)
 DECLARE naliq_min_vol = i2 WITH protect, constant(16)
 DECLARE naliq_container = i2 WITH protect, constant(17)
 DECLARE naliq_coll_class = i2 WITH protect, constant(18)
 DECLARE naliq_spec_handle = i2 WITH protect, constant(19)
 DECLARE naliq_netting = i2 WITH protect, constant(20)
 DECLARE ncatalog_cd = i2 WITH protect, constant(21)
 DECLARE dcatalog_type_lab = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE dact_type_hlx = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLX"))
 DECLARE dact_type_cyg = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"CYG"))
 DECLARE dact_subtype_mdx = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"HLX_MDX"))
 DECLARE dact_subtype_specimen = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,
   "HLX_SPECIMEN"))
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv8,
   code_value cv9,
   (dummyt d  WITH seq = 1),
   procedure_specimen_type pst,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   collection_info_qualifiers ciq,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7
  PLAN (oc
   WHERE oc.catalog_type_cd=dcatalog_type_lab
    AND oc.activity_type_cd IN (dact_type_hlx, dact_type_cyg)
    AND oc.active_ind=1
    AND oc.orderable_type_flag != 2
    AND oc.bill_only_ind IN (0, null)
    AND oc.activity_subtype_cd IN (0, null, dact_subtype_mdx, dact_subtype_specimen))
   JOIN (cv8
   WHERE cv8.code_value=oc.activity_type_cd)
   JOIN (cv9
   WHERE cv9.code_value=oc.activity_subtype_cd)
   JOIN (d)
   JOIN (pst
   WHERE pst.catalog_cd=oc.catalog_cd)
   JOIN (cv1
   WHERE cv1.code_value=pst.accession_class_cd)
   JOIN (cv2
   WHERE cv2.code_value=pst.specimen_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=pst.default_collection_method_cd)
   JOIN (ciq
   WHERE ciq.catalog_cd=pst.catalog_cd
    AND ciq.specimen_type_cd=pst.specimen_type_cd)
   JOIN (cv4
   WHERE cv4.code_value=ciq.service_resource_cd)
   JOIN (cv5
   WHERE cv5.code_value=ciq.spec_cntnr_cd)
   JOIN (cv6
   WHERE cv6.code_value=ciq.coll_class_cd)
   JOIN (cv7
   WHERE cv7.code_value=ciq.spec_hndl_cd)
  ORDER BY cnvtupper(oc.primary_mnemonic), cv2.display, ciq.sequence
  DETAIL
   cnt = (cnt+ 1), temp->cnt = cnt
   IF (cnt > size(temp->qual,5))
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].primary_mnem = oc.primary_mnemonic, temp->qual[cnt].catalog_cd = oc.catalog_cd,
   temp->qual[cnt].resource_route_lvl = oc.resource_route_lvl,
   temp->qual[cnt].activity_type = cv8.display, temp->qual[cnt].activity_subtype = cv9.display
   IF (pst.catalog_cd > 0)
    temp->qual[cnt].accn_class = cv1.display, temp->qual[cnt].spec_type = cv2.display, temp->qual[cnt
    ].def_coll_method = cv3.display
   ENDIF
   IF (ciq.catalog_cd > 0)
    IF (ciq.service_resource_cd=0)
     temp->qual[cnt].srvres = sall
    ELSE
     temp->qual[cnt].srvres = cv4.display, temp->qual[cnt].srvres_cd = ciq.service_resource_cd
     IF (cv4.active_ind=0)
      temp->qual[cnt].instr_bench_status = sinactive
     ELSE
      temp->qual[cnt].instr_bench_status = sactive
     ENDIF
    ENDIF
    temp->qual[cnt].age_to_min = ciq.age_to_minutes, temp->qual[cnt].age_from_min = ciq
    .age_from_minutes
    IF (ciq.age_from_minutes < 60)
     temp->qual[cnt].age_from = fmttimedisp(ciq.age_from_minutes,sminutes)
    ELSEIF (ciq.age_from_minutes >= 60
     AND ciq.age_from_minutes < 1440)
     temp->qual[cnt].age_from = fmttimedisp((ciq.age_from_minutes/ 60),shours)
    ELSEIF (ciq.age_from_minutes >= 1440
     AND ciq.age_from_minutes < 10080)
     temp->qual[cnt].age_from = fmttimedisp((ciq.age_from_minutes/ 1440),sdays)
    ELSEIF (ciq.age_from_minutes >= 10080
     AND ciq.age_from_minutes < 43200)
     temp->qual[cnt].age_from = fmttimedisp((ciq.age_from_minutes/ 10080),sweeks)
    ELSEIF (ciq.age_from_minutes >= 43200
     AND ciq.age_from_minutes < 525600)
     temp->qual[cnt].age_from = fmttimedisp((ciq.age_from_minutes/ 43200),smonths)
    ELSEIF (ciq.age_from_minutes >= 525600)
     temp->qual[cnt].age_from = fmttimedisp((ciq.age_from_minutes/ 525600),syears)
    ELSE
     temp->qual[cnt].age_from = " "
    ENDIF
    IF (ciq.age_to_minutes < 60)
     temp->qual[cnt].age_to = fmttimedisp(ciq.age_to_minutes,sminutes)
    ELSEIF (ciq.age_to_minutes >= 60
     AND ciq.age_to_minutes < 1440)
     temp->qual[cnt].age_to = fmttimedisp((ciq.age_to_minutes/ 60),shours)
    ELSEIF (ciq.age_to_minutes >= 1440
     AND ciq.age_to_minutes < 10080)
     temp->qual[cnt].age_to = fmttimedisp((ciq.age_to_minutes/ 1440),sdays)
    ELSEIF (ciq.age_to_minutes >= 10080
     AND ciq.age_to_minutes < 43200)
     temp->qual[cnt].age_to = fmttimedisp((ciq.age_to_minutes/ 10080),sweeks)
    ELSEIF (ciq.age_to_minutes >= 43200
     AND ciq.age_to_minutes < 525600)
     temp->qual[cnt].age_to = fmttimedisp((ciq.age_to_minutes/ 43200),smonths)
    ELSEIF (ciq.age_to_minutes >= 525600)
     temp->qual[cnt].age_to = fmttimedisp((ciq.age_to_minutes/ 525600),syears)
    ELSE
     temp->qual[cnt].age_to = " "
    ENDIF
    temp->qual[cnt].min_vol = format(ciq.min_vol,"#####.##"), temp->qual[cnt].spec_cont = cv5.display,
    temp->qual[cnt].coll_class = cv6.display,
    temp->qual[cnt].spec_handling = cv7.display
    IF (ciq.additional_labels > 0)
     temp->qual[cnt].extra_label = cnvtstring(ciq.additional_labels)
    ELSE
     temp->qual[cnt].extra_label = " "
    ENDIF
    IF (ciq.aliquot_ind=1)
     temp->qual[cnt].specimen_type_cd = ciq.specimen_type_cd, temp->qual[cnt].aliquot_seq = ciq
     .aliquot_seq
    ELSE
     temp->qual[cnt].specimen_type_cd = 0, temp->qual[cnt].aliquot_seq = 0
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (cnt > 0)
  SET stat = alterlist(temp->qual,cnt)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = cnt),
    aliquot_info_qualifiers aiq
   PLAN (d)
    JOIN (aiq
    WHERE (aiq.catalog_cd=temp->qual[d.seq].catalog_cd)
     AND (aiq.specimen_type_cd=temp->qual[d.seq].specimen_type_cd)
     AND (aiq.coll_info_seq=temp->qual[d.seq].aliquot_seq))
   ORDER BY d.seq
   HEAD d.seq
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(temp->qual[d.seq].aliquots,acnt)
    IF (aiq.min_vol > 0)
     temp->qual[d.seq].aliquots[acnt].min_vol = format(aiq.min_vol,"#####.##")
    ELSE
     temp->qual[d.seq].aliquots[acnt].min_vol = " "
    ENDIF
    IF (aiq.spec_cntnr_cd > 0)
     temp->qual[d.seq].aliquots[acnt].spec_cntnr_disp = uar_get_code_display(aiq.spec_cntnr_cd)
    ELSE
     temp->qual[d.seq].aliquots[acnt].spec_cntnr_disp = " "
    ENDIF
    IF (aiq.coll_class_cd > 0)
     temp->qual[d.seq].aliquots[acnt].coll_class_disp = uar_get_code_display(aiq.coll_class_cd)
    ELSE
     temp->qual[d.seq].aliquots[acnt].coll_class_disp = " "
    ENDIF
    IF (aiq.spec_hndl_cd > 0)
     temp->qual[d.seq].aliquots[acnt].spec_hndl_disp = uar_get_code_display(aiq.spec_hndl_cd)
    ELSE
     temp->qual[d.seq].aliquots[acnt].spec_hndl_disp = " "
    ENDIF
    IF (aiq.net_ind=1)
     temp->qual[d.seq].aliquots[acnt].netting = syes
    ELSE
     temp->qual[d.seq].aliquots[acnt].netting = sno
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,21)
 SET reply->collist[nprimary_name].header_text = sprimary_name
 SET reply->collist[nprimary_name].data_type = 1
 SET reply->collist[nprimary_name].hide_ind = 0
 SET reply->collist[nacc_class].header_text = sacc_class
 SET reply->collist[nacc_class].data_type = 1
 SET reply->collist[nacc_class].hide_ind = 0
 SET reply->collist[nspec_type].header_text = sspec_type
 SET reply->collist[nspec_type].data_type = 1
 SET reply->collist[nspec_type].hide_ind = 0
 SET reply->collist[ncoll_method].header_text = scoll_method
 SET reply->collist[ncoll_method].data_type = 1
 SET reply->collist[ncoll_method].hide_ind = 0
 SET reply->collist[ninstrument].header_text = sinstrument
 SET reply->collist[ninstrument].data_type = 1
 SET reply->collist[ninstrument].hide_ind = 0
 SET reply->collist[nage_from].header_text = sage_from
 SET reply->collist[nage_from].data_type = 1
 SET reply->collist[nage_from].hide_ind = 0
 SET reply->collist[nage_to].header_text = sage_to
 SET reply->collist[nage_to].data_type = 1
 SET reply->collist[nage_to].hide_ind = 0
 SET reply->collist[nmin_vol].header_text = smin_vol
 SET reply->collist[nmin_vol].data_type = 1
 SET reply->collist[nmin_vol].hide_ind = 0
 SET reply->collist[ncontainer].header_text = scontainer
 SET reply->collist[ncontainer].data_type = 1
 SET reply->collist[ncontainer].hide_ind = 0
 SET reply->collist[ncoll_class].header_text = scoll_class
 SET reply->collist[ncoll_class].data_type = 1
 SET reply->collist[ncoll_class].hide_ind = 0
 SET reply->collist[nspec_handle].header_text = sspec_handle
 SET reply->collist[nspec_handle].data_type = 1
 SET reply->collist[nspec_handle].hide_ind = 0
 SET reply->collist[nextra_label].header_text = sextra_label
 SET reply->collist[nextra_label].data_type = 1
 SET reply->collist[nextra_label].hide_ind = 0
 SET reply->collist[nactivity_type].header_text = sactivity_type
 SET reply->collist[nactivity_type].data_type = 1
 SET reply->collist[nactivity_type].hide_ind = 0
 SET reply->collist[nsub_act_type].header_text = ssub_act_type
 SET reply->collist[nsub_act_type].data_type = 1
 SET reply->collist[nsub_act_type].hide_ind = 0
 SET reply->collist[ninstrument_status].header_text = sinstrument_status
 SET reply->collist[ninstrument_status].data_type = 1
 SET reply->collist[ninstrument_status].hide_ind = 0
 SET reply->collist[naliq_min_vol].header_text = saliq_min_vol
 SET reply->collist[naliq_min_vol].data_type = 1
 SET reply->collist[naliq_min_vol].hide_ind = 0
 SET reply->collist[naliq_container].header_text = saliq_container
 SET reply->collist[naliq_container].data_type = 1
 SET reply->collist[naliq_container].hide_ind = 0
 SET reply->collist[naliq_coll_class].header_text = saliq_coll_class
 SET reply->collist[naliq_coll_class].data_type = 1
 SET reply->collist[naliq_coll_class].hide_ind = 0
 SET reply->collist[naliq_spec_handle].header_text = saliq_spec_handle
 SET reply->collist[naliq_spec_handle].data_type = 1
 SET reply->collist[naliq_spec_handle].hide_ind = 0
 SET reply->collist[naliq_netting].header_text = saliq_netting
 SET reply->collist[naliq_netting].data_type = 1
 SET reply->collist[naliq_netting].hide_ind = 0
 SET reply->collist[ncatalog_cd].header_text = "catalog_cd"
 SET reply->collist[ncatalog_cd].data_type = 2
 SET reply->collist[ncatalog_cd].hide_ind = 1
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   orc_resource_list orl
  PLAN (d
   WHERE (temp->qual[d.seq].srvres_cd > 0)
    AND (temp->qual[d.seq].resource_route_lvl < 2))
   JOIN (orl
   WHERE (orl.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND (orl.service_resource_cd=temp->qual[d.seq].srvres_cd))
  DETAIL
   IF ((orl.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND (orl.service_resource_cd=temp->qual[d.seq].srvres_cd))
    IF (orl.active_ind=0)
     temp->qual[d.seq].instr_bench_status = sinactive_reltn
    ENDIF
   ELSE
    temp->qual[d.seq].instr_bench_status = sinvalid
   ENDIF
  WITH outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   profile_task_r ptr,
   assay_resource_list arl
  PLAN (d
   WHERE (temp->qual[d.seq].srvres_cd > 0)
    AND (temp->qual[d.seq].resource_route_lvl=2))
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (arl
   WHERE arl.task_assay_cd=ptr.task_assay_cd
    AND (arl.service_resource_cd=temp->qual[d.seq].srvres_cd))
  DETAIL
   IF (arl.task_assay_cd > 0
    AND (arl.service_resource_cd=temp->qual[d.seq].srvres_cd))
    IF (arl.active_ind=0)
     temp->qual[d.seq].instr_bench_status = sinactive_reltn
    ENDIF
   ELSE
    temp->qual[d.seq].instr_bench_status = sinvalid
   ENDIF
  WITH outerjoin = d
 ;end select
 SET row_nbr = 0
 SET stat = alterlist(reply->rowlist,cnt)
 FOR (x = 1 TO cnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,21)
   CALL populatecelllist(row_nbr,x)
   SET aliquotcnt = size(temp->qual[x].aliquots,5)
   FOR (a = 1 TO aliquotcnt)
     SET reply->rowlist[row_nbr].celllist[naliq_min_vol].string_value = temp->qual[x].aliquots[a].
     min_vol
     SET reply->rowlist[row_nbr].celllist[naliq_container].string_value = temp->qual[x].aliquots[a].
     spec_cntnr_disp
     SET reply->rowlist[row_nbr].celllist[naliq_coll_class].string_value = temp->qual[x].aliquots[a].
     coll_class_disp
     SET reply->rowlist[row_nbr].celllist[naliq_spec_handle].string_value = temp->qual[x].aliquots[a]
     .spec_hndl_disp
     SET reply->rowlist[row_nbr].celllist[naliq_netting].string_value = temp->qual[x].aliquots[a].
     netting
     IF (a < aliquotcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,(size(reply->rowlist,5)+ 1))
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,21)
      CALL populatecelllist(row_nbr,x)
     ENDIF
   ENDFOR
 ENDFOR
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 5000)
   SET reply->high_volume_flag = 2
  ELSEIF (row_nbr > 3000)
   SET reply->high_volume_flag = 1
  ENDIF
  IF ((reply->high_volume_flag IN (1, 2)))
   SET reply->output_filename = build("hlx_collections_audit.csv")
   SET stat = alterlist(reply->rowlist,0)
  ENDIF
 ENDIF
 SUBROUTINE populatecelllist(lrowlistndx,ltempqualndx)
   SET reply->rowlist[lrowlistndx].celllist[nactivity_type].string_value = temp->qual[ltempqualndx].
   activity_type
   SET reply->rowlist[lrowlistndx].celllist[nprimary_name].string_value = temp->qual[ltempqualndx].
   primary_mnem
   SET reply->rowlist[lrowlistndx].celllist[nacc_class].string_value = temp->qual[ltempqualndx].
   accn_class
   SET reply->rowlist[lrowlistndx].celllist[nspec_type].string_value = temp->qual[ltempqualndx].
   spec_type
   SET reply->rowlist[lrowlistndx].celllist[ncoll_method].string_value = temp->qual[ltempqualndx].
   def_coll_method
   SET reply->rowlist[lrowlistndx].celllist[ninstrument].string_value = temp->qual[ltempqualndx].
   srvres
   SET reply->rowlist[lrowlistndx].celllist[nage_from].string_value = temp->qual[ltempqualndx].
   age_from
   SET reply->rowlist[lrowlistndx].celllist[nage_to].string_value = temp->qual[ltempqualndx].age_to
   SET reply->rowlist[lrowlistndx].celllist[nmin_vol].string_value = temp->qual[ltempqualndx].min_vol
   SET reply->rowlist[lrowlistndx].celllist[ncontainer].string_value = temp->qual[ltempqualndx].
   spec_cont
   SET reply->rowlist[lrowlistndx].celllist[ncoll_class].string_value = temp->qual[ltempqualndx].
   coll_class
   SET reply->rowlist[lrowlistndx].celllist[nspec_handle].string_value = temp->qual[ltempqualndx].
   spec_handling
   SET reply->rowlist[lrowlistndx].celllist[nextra_label].string_value = temp->qual[ltempqualndx].
   extra_label
   SET reply->rowlist[lrowlistndx].celllist[nsub_act_type].string_value = temp->qual[ltempqualndx].
   activity_subtype
   SET reply->rowlist[lrowlistndx].celllist[ninstrument_status].string_value = temp->qual[
   ltempqualndx].instr_bench_status
   SET reply->rowlist[lrowlistndx].celllist[ncatalog_cd].double_value = temp->qual[ltempqualndx].
   catalog_cd
 END ;Subroutine
 SUBROUTINE fmttimedisp(ltime,stimetype)
   RETURN(uar_i18nbuildmessage(i18nhandle,"FORMAT_TIME_DISPLAY","%1 %2","is",ltime,
    nullterm(stimetype)))
 END ;Subroutine
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
