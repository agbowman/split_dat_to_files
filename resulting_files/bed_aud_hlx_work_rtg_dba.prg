CREATE PROGRAM bed_aud_hlx_work_rtg:dba
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
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 dept_display_name = vc
     2 resource_route_lvl = i2
     2 r_cnt = i4
     2 rlist[*]
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 sequence = i4
       3 primary_ind = i2
       3 instr_bench_status = vc
 )
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
 DECLARE genlab_code = f8 WITH protect, noconstant(0.0)
 DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
 DECLARE ci_code = f8 WITH protect, noconstant(0.0)
 DECLARE ptl_code = f8 WITH protect, noconstant(0.0)
 DECLARE i18n_handle = i4 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE nprimary_name = i2 WITH protect, constant(1)
 DECLARE ninstrument = i2 WITH protect, constant(2)
 DECLARE nsequence = i2 WITH protect, constant(3)
 DECLARE ndefault = i2 WITH protect, constant(4)
 DECLARE ndept_disp_name = i2 WITH protect, constant(5)
 DECLARE nactivity_type = i2 WITH protect, constant(6)
 DECLARE nsub_act_type = i2 WITH protect, constant(7)
 DECLARE ncatalog_cd = i2 WITH protect, constant(8)
 DECLARE nserv_res_cd = i2 WITH protect, constant(9)
 DECLARE ninstrument_status = i2 WITH protect, constant(10)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(6000,"GENERAL LAB",1,genlab_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 SET stat = uar_get_meaning_by_codeset(106,"CI",1,ci_code)
 SET stat = uar_get_meaning_by_codeset(106,"PTL",1,ptl_code)
 SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=genlab_code
     AND oc.activity_type_cd IN (hlx_code, ci_code, ptl_code)
     AND oc.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o,
   code_value cv1,
   code_value cv2,
   orc_resource_list r
  PLAN (o
   WHERE o.catalog_type_cd=genlab_code
    AND o.activity_type_cd IN (hlx_code, ci_code, ptl_code)
    AND o.active_ind=1
    AND o.orderable_type_flag != 6
    AND o.orderable_type_flag != 2
    AND o.bill_only_ind IN (0, null))
   JOIN (cv1
   WHERE cv1.code_value=o.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_subtype_cd)
   JOIN (r
   WHERE r.catalog_cd=outerjoin(o.catalog_cd))
  ORDER BY cv1.display_key, cnvtupper(o.primary_mnemonic), o.catalog_cd,
   r.sequence
  HEAD REPORT
   o_cnt = 0, r_cnt = 0
  HEAD o.catalog_cd
   r_cnt = 0, o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt,
   stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[
   o_cnt].primary_mnemonic = o.primary_mnemonic,
   temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp =
   cv1.display, temp->olist[o_cnt].dept_display_name = o.dept_display_name
   IF (o.activity_subtype_cd > 0)
    temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd, temp->olist[o_cnt].
    activity_subtype_disp = cv2.display
   ENDIF
   temp->olist[o_cnt].resource_route_lvl = o.resource_route_lvl
  DETAIL
   IF (o.resource_route_lvl != 2)
    r_cnt = (r_cnt+ 1), temp->olist[o_cnt].r_cnt = r_cnt, stat = alterlist(temp->olist[o_cnt].rlist,
     r_cnt),
    temp->olist[o_cnt].rlist[r_cnt].service_resource_cd = r.service_resource_cd, temp->olist[o_cnt].
    rlist[r_cnt].sequence = r.sequence
    IF (r.primary_ind=1)
     temp->olist[o_cnt].rlist[r_cnt].primary_ind = 1
    ENDIF
    IF (r.active_ind=0)
     temp->olist[o_cnt].rlist[r_cnt].instr_bench_status = uar_i18ngetmessage(i18n_handle,
      "Inactive Relation","Inactive Relation")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[nprimary_name].header_text = uar_i18ngetmessage(i18n_handle,"Primary Name",
  "Primary Name")
 SET reply->collist[nprimary_name].data_type = 1
 SET reply->collist[nprimary_name].hide_ind = 0
 SET reply->collist[ninstrument].header_text = uar_i18ngetmessage(i18n_handle,"Instrument/Bench",
  "Instrument/Bench")
 SET reply->collist[ninstrument].data_type = 1
 SET reply->collist[ninstrument].hide_ind = 0
 SET reply->collist[nsequence].header_text = uar_i18ngetmessage(i18n_handle,"Sequence","Sequence")
 SET reply->collist[nsequence].data_type = 1
 SET reply->collist[nsequence].hide_ind = 0
 SET reply->collist[ndefault].header_text = uar_i18ngetmessage(i18n_handle,"Default","Default")
 SET reply->collist[ndefault].data_type = 1
 SET reply->collist[ndefault].hide_ind = 0
 SET reply->collist[ndept_disp_name].header_text = uar_i18ngetmessage(i18n_handle,"Dept Disp Name",
  "Dept Disp Name")
 SET reply->collist[ndept_disp_name].data_type = 1
 SET reply->collist[ndept_disp_name].hide_ind = 0
 SET reply->collist[nactivity_type].header_text = uar_i18ngetmessage(i18n_handle,"Activity Type",
  "Activity Type")
 SET reply->collist[nactivity_type].data_type = 1
 SET reply->collist[nactivity_type].hide_ind = 0
 SET reply->collist[nsub_act_type].header_text = uar_i18ngetmessage(i18n_handle,"Subactivity Type",
  "Subactivity Type")
 SET reply->collist[nsub_act_type].data_type = 1
 SET reply->collist[nsub_act_type].hide_ind = 0
 SET reply->collist[ncatalog_cd].header_text = "catalog_cd"
 SET reply->collist[ncatalog_cd].data_type = 2
 SET reply->collist[ncatalog_cd].hide_ind = 1
 SET reply->collist[nserv_res_cd].header_text = "service_resource_cd"
 SET reply->collist[nserv_res_cd].data_type = 2
 SET reply->collist[nserv_res_cd].hide_ind = 1
 SET reply->collist[ninstrument_status].header_text = uar_i18ngetmessage(i18n_handle,
  "Instrument/Bench Status","Instrument/Bench Status")
 SET reply->collist[ninstrument_status].data_type = 1
 SET reply->collist[ninstrument_status].hide_ind = 0
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO temp->o_cnt)
   IF ((temp->olist[x].r_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = temp->olist[x].r_cnt),
      code_value cv
     PLAN (d
      WHERE (temp->olist[x].rlist[d.seq].service_resource_cd > 0))
      JOIN (cv
      WHERE (cv.code_value=temp->olist[x].rlist[d.seq].service_resource_cd))
     ORDER BY d.seq
     HEAD d.seq
      temp->olist[x].rlist[d.seq].service_resource_disp = trim(cv.display)
      IF ((temp->olist[x].rlist[d.seq].instr_bench_status=" "))
       IF (cv.active_ind=0)
        temp->olist[x].rlist[d.seq].instr_bench_status = "Inactive"
       ELSE
        temp->olist[x].rlist[d.seq].instr_bench_status = "Active"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (x = 1 TO temp->o_cnt)
   IF ((temp->olist[x].r_cnt=0))
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
    SET reply->rowlist[row_nbr].celllist[nactivity_type].string_value = temp->olist[x].
    activity_type_disp
    SET reply->rowlist[row_nbr].celllist[nprimary_name].string_value = temp->olist[x].
    primary_mnemonic
    SET reply->rowlist[row_nbr].celllist[ndept_disp_name].string_value = temp->olist[x].
    dept_display_name
    SET reply->rowlist[row_nbr].celllist[nsub_act_type].string_value = temp->olist[x].
    activity_subtype_disp
    SET reply->rowlist[row_nbr].celllist[ncatalog_cd].double_value = temp->olist[x].catalog_cd
    IF ((temp->olist[x].resource_route_lvl=2))
     SET reply->rowlist[row_nbr].celllist[ninstrument].string_value = "Assay Level"
    ENDIF
   ELSE
    FOR (y = 1 TO temp->olist[x].r_cnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
      SET reply->rowlist[row_nbr].celllist[nactivity_type].string_value = temp->olist[x].
      activity_type_disp
      SET reply->rowlist[row_nbr].celllist[nprimary_name].string_value = temp->olist[x].
      primary_mnemonic
      SET reply->rowlist[row_nbr].celllist[ndept_disp_name].string_value = temp->olist[x].
      dept_display_name
      SET reply->rowlist[row_nbr].celllist[nsub_act_type].string_value = temp->olist[x].
      activity_subtype_disp
      SET reply->rowlist[row_nbr].celllist[ncatalog_cd].double_value = temp->olist[x].catalog_cd
      SET reply->rowlist[row_nbr].celllist[ninstrument].string_value = temp->olist[x].rlist[y].
      service_resource_disp
      SET reply->rowlist[row_nbr].celllist[nsequence].string_value = cnvtstring(temp->olist[x].rlist[
       y].sequence)
      IF ((temp->olist[x].rlist[y].primary_ind=1))
       SET reply->rowlist[row_nbr].celllist[ndefault].string_value = "X"
      ELSE
       SET reply->rowlist[row_nbr].celllist[ndefault].string_value = " "
      ENDIF
      SET reply->rowlist[row_nbr].celllist[nserv_res_cd].double_value = temp->olist[x].rlist[y].
      service_resource_cd
      SET reply->rowlist[row_nbr].celllist[ninstrument_status].string_value = temp->olist[x].rlist[y]
      .instr_bench_status
      IF ((reply->rowlist[row_nbr].celllist[ninstrument].string_value=" "))
       SET reply->rowlist[row_nbr].celllist[nsequence].string_value = " "
       SET reply->rowlist[row_nbr].celllist[ninstrument_status].string_value = " "
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("hlx_work_rtg_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
