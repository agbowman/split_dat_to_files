CREATE PROGRAM cv_chk_build_wfm:dba
 DECLARE e_msg_activity_subtype_invalid = i4 WITH public, constant(1)
 DECLARE e_msg_event_cd_unavail = i4 WITH public, constant(2)
 DECLARE e_msg_event_cd_excess = i4 WITH public, constant(3)
 DECLARE e_msg_task_assay_unavail = i4 WITH public, constant(4)
 DECLARE e_msg_task_assay_invalid = i4 WITH public, constant(5)
 DECLARE e_msg_event_set_invalid = i4 WITH public, constant(6)
 DECLARE e_msg_event_class_invalid = i4 WITH public, constant(7)
 DECLARE e_msg_dta_activity_type_invalid = i4 WITH public, constant(8)
 DECLARE e_msg_dta_def_result_type_invalid = i4 WITH public, constant(9)
 DECLARE e_msg_csr_step_type_invalid = i4 WITH public, constant(10)
 DECLARE e_msg_csr_step_doc_type_invalid = i4 WITH public, constant(11)
 DECLARE e_msg_csr_step_sched_invalid = i4 WITH public, constant(12)
 DECLARE e_msg_step_signed_unavail = i4 WITH public, constant(13)
 DECLARE e_msg_step_technologist_doc_id_duplicate = i4 WITH public, constant(14)
 DECLARE e_msg_step_multiple_technologist_no_doc_id = i4 WITH public, constant(15)
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
 DECLARE block_size = i4 WITH protect, constant(40)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nstop = i4 WITH protect, noconstant(0)
 DECLARE ordr_cnt = i4 WITH protect
 DECLARE ordr_idx = i4 WITH protect
 DECLARE ordr_pad = i4 WITH protect
 DECLARE error_cnt = i4 WITH protect
 DECLARE msg_str2 = vc WITH protect
 DECLARE msg_param = vc WITH protect
 DECLARE c_catalog_type_cardiovascul = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,
   "CARDIOVASCUL"))
 DECLARE c_dta_type_cardiovascul = f8 WITH protect, constant(uar_get_code_by("MEANING",106,
   "CARDIOVASCUL"))
 DECLARE c_dta_result_type_11 = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"11"))
 DECLARE c_eventset_status_active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE c_def_event_class_proc = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PROCEDURE")
  )
 DECLARE c_def_step_status_signed = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "SIGNED"))
 DECLARE c_def_step_type_technologist = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "TECHNOLOGIST"))
 DECLARE electrophysiology_docid_str = vc WITH public, noconstant(uar_get_code_display(
   uar_get_code_by("MEANING",4002763,"ELECTROPHYS")))
 DECLARE hemo_docid_str = vc WITH public, noconstant(uar_get_code_display(uar_get_code_by("MEANING",
    4002763,"HEMO")))
 DECLARE stress_ecg_docid_str = vc WITH public, noconstant(uar_get_code_display(uar_get_code_by(
    "MEANING",4002763,"STRESSECG")))
 DECLARE msg_str = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE s_code1_disp = vc WITH protect, noconstant(fillstring(25," "))
 DECLARE s_code2_disp = vc WITH protect, noconstant(fillstring(25," "))
 DECLARE s_i18nkey = vc WITH protect, noconstant(fillstring(10," "))
 DECLARE l_size = i4 WITH protect, noconstant(0)
 SET i18nh = 0
 SET i18nretval = uar_i18nlocalizationinit(i18nh,curprog,"",curcclrev)
 IF (validate(reply)=0)
  RECORD reply(
    1 order_catalog[*]
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 event_cd = f8
      2 event_disp = vc
      2 cv_step[*]
        3 task_assay_cd = f8
        3 task_assay_mnemonic = vc
        3 idx = i4
      2 msgs[*]
        3 msg_idx = i4
    1 cv_step[*]
      2 task_assay_cd = f8
      2 task_assay_mnemonic = vc
      2 msgs[*]
        3 msg_idx = i4
    1 msg[*]
      2 msg_nbr = i4
      2 code1_cd = f8
      2 code1_disp = vc
      2 code2_cd = f8
      2 code2_disp = vc
      2 msg_str = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "NL:"
  dta.task_assay_cd
  FROM cv_step_ref csr,
   discrete_task_assay dta
  PLAN (csr
   WHERE csr.task_assay_cd > 0.0)
   JOIN (dta
   WHERE (dta.task_assay_cd= Outerjoin(csr.task_assay_cd)) )
  HEAD REPORT
   l_count = 0, stat = alterlist(reply->cv_step,10)
  DETAIL
   l_count += 1
   IF (mod(l_count,10)=1
    AND l_count != 1)
    stat = alterlist(reply->cv_step,(l_count+ 9))
   ENDIF
   reply->cv_step[l_count].task_assay_cd = dta.task_assay_cd, reply->cv_step[l_count].
   task_assay_mnemonic = nullterm(trim(dta.mnemonic))
   IF ( NOT (dta.activity_type_cd=c_dta_type_cardiovascul))
    CALL cv_add_error(e_msg_dta_activity_type_invalid,l_count,0.0)
   ENDIF
   IF ( NOT (dta.default_result_type_cd=c_dta_result_type_11))
    CALL cv_add_error(e_msg_dta_def_result_type_invalid,l_count,0.0)
   ENDIF
   IF (csr.step_type_cd <= 0)
    CALL cv_add_error(e_msg_csr_step_type_invalid,l_count,0.0)
   ENDIF
   IF (csr.doc_type_cd <= 0
    AND csr.step_type_cd != c_def_step_type_technologist)
    CALL cv_add_error(e_msg_csr_step_doc_type_invalid,l_count,0.0)
   ENDIF
   IF (csr.schedule_ind=1
    AND csr.activity_subtype_cd < 0)
    CALL cv_add_error(e_msg_csr_step_sched_invalid,l_count,0.0)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->cv_step,l_count)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  oc_catalog_disp = uar_get_code_display(oc.catalog_cd), cver_event_disp = uar_get_code_display(cver
   .event_cd), ptr_task_assay_mnemonic = uar_get_code_display(ptr.task_assay_cd)
  FROM order_catalog oc,
   code_value_event_r cver,
   v500_event_code vec,
   profile_task_r ptr,
   cv_step_ref csr
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd=c_catalog_type_cardiovascul)
   JOIN (cver
   WHERE (cver.parent_cd= Outerjoin(oc.catalog_cd))
    AND (cver.flex1_cd= Outerjoin(0.0)) )
   JOIN (vec
   WHERE (vec.event_cd= Outerjoin(cver.event_cd)) )
   JOIN (ptr
   WHERE (ptr.catalog_cd= Outerjoin(oc.catalog_cd))
    AND (ptr.active_ind= Outerjoin(1)) )
   JOIN (csr
   WHERE (csr.task_assay_cd= Outerjoin(ptr.task_assay_cd)) )
  ORDER BY oc.catalog_cd, cver.event_cd, ptr.task_assay_cd
  HEAD oc.catalog_cd
   ordr_cnt += 1, l_count = 0, l_technologiststepcnt = 0
   IF (ordr_cnt > ordr_pad)
    ordr_pad += block_size, stat = alterlist(reply->order_catalog,ordr_pad)
   ENDIF
   reply->order_catalog[ordr_cnt].catalog_cd = oc.catalog_cd, reply->order_catalog[ordr_cnt].
   catalog_disp = nullterm(trim(oc_catalog_disp))
   IF (oc.activity_subtype_cd < 0.0)
    CALL cv_add_error(e_msg_activity_subtype_invalid,ordr_cnt,0.0)
   ENDIF
   evnt_cnt = 0, ptr_cnt = 0, b_found = 0
  HEAD cver.event_cd
   l_epcnt = 0, l_hemocnt = 0, l_stressecgcnt = 0,
   l_blankdocidcnt = 0
   IF (cver.event_cd != 0.0)
    evnt_cnt += 1
    IF (evnt_cnt=1)
     reply->order_catalog[ordr_cnt].event_cd = cver.event_cd, reply->order_catalog[ordr_cnt].
     event_disp = nullterm(trim(cver_event_disp))
    ENDIF
    IF (vec.def_event_class_cd != c_def_event_class_proc)
     CALL cv_add_error(e_msg_event_class_invalid,ordr_cnt,0.0)
    ENDIF
   ENDIF
   stat = alterlist(reply->order_catalog[ordr_cnt].cv_step,10)
  HEAD ptr.task_assay_cd
   IF (ptr.task_assay_cd != 0.0
    AND evnt_cnt <= 1)
    ptr_cnt += 1
    IF (mod(ptr_cnt,10)=1
     AND ptr_cnt != 1)
     stat = alterlist(reply->order_catalog[ordr_cnt].cv_step,(ptr_cnt+ 9))
    ENDIF
    reply->order_catalog[ordr_cnt].cv_step[ptr_cnt].task_assay_cd = ptr.task_assay_cd, reply->
    order_catalog[ordr_cnt].cv_step[ptr_cnt].task_assay_mnemonic = nullterm(trim(
      ptr_task_assay_mnemonic)), l_idx = 0,
    l_idx = locateval(l_idx,1,size(reply->cv_step,5),ptr.task_assay_cd,reply->cv_step[l_idx].
     task_assay_cd)
    IF (l_idx=0)
     CALL cv_add_error(e_msg_task_assay_invalid,ordr_cnt,ptr.task_assay_cd)
    ELSE
     reply->order_catalog[ordr_cnt].cv_step[ptr_cnt].idx = l_idx
     IF (csr.proc_status_cd=c_def_step_status_signed)
      b_found = 1
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (csr.step_type_cd=c_def_step_type_technologist)
    l_technologiststepcnt += 1
    IF (l_technologiststepcnt > 0
     AND csr.doc_id_str=electrophysiology_docid_str)
     l_epcnt += 1
    ELSEIF (l_technologiststepcnt > 0
     AND csr.doc_id_str=hemo_docid_str)
     l_hemocnt += 1
    ELSEIF (l_technologiststepcnt > 0
     AND csr.doc_id_str=null)
     l_blankdocidcnt += 1
    ELSEIF (l_technologiststepcnt > 0
     AND csr.doc_id_str=stress_ecg_docid_str)
     l_stressecgcnt += 1
    ENDIF
   ENDIF
  FOOT  oc.catalog_cd
   IF (evnt_cnt < 1)
    CALL cv_add_error(e_msg_event_cd_unavail,ordr_cnt,0.0)
   ENDIF
   IF (evnt_cnt > 1)
    CALL cv_add_error(e_msg_event_cd_excess,ordr_cnt,0.0)
   ENDIF
   IF (ptr_cnt < 1)
    CALL cv_add_error(e_msg_task_assay_unavail,ordr_cnt,0.0)
   ELSEIF (b_found != 1)
    CALL cv_add_error(e_msg_step_signed_unavail,ordr_cnt,0.0)
   ENDIF
   IF (l_technologiststepcnt > 1)
    IF (l_hemocnt=1
     AND l_blankdocidcnt=1)
     CALL cv_add_error(e_msg_step_technologist_doc_id_duplicate,ordr_cnt,0.0)
    ENDIF
   ENDIF
   IF (((l_epcnt > 1) OR (((l_hemocnt > 1) OR (l_stressecgcnt > 1)) )) )
    CALL cv_add_error(e_msg_step_technologist_doc_id_duplicate,ordr_cnt,0.0)
   ENDIF
   IF (l_blankdocidcnt > 1)
    CALL cv_add_error(e_msg_step_multiple_technologist_no_doc_id,ordr_cnt,0.0)
   ENDIF
   stat = alterlist(reply->order_catalog[ordr_cnt].cv_step,ptr_cnt)
  FOOT REPORT
   stat = alterlist(reply->order_catalog,ordr_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM v500_event_set_explode vese,
   (dummyt d  WITH seq = value((ordr_pad/ block_size)))
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
   JOIN (vese
   WHERE expand(ordr_idx,nstart,minval(((nstart+ block_size) - 1),ordr_cnt),vese.event_cd,reply->
    order_catalog[ordr_idx].event_cd))
  DETAIL
   nstop = minval((block_size * d.seq),ordr_cnt), l_idx = 0, l_idx = locateval(l_idx,(1+ ((d.seq - 1)
     * block_size)),nstop,vese.event_cd,reply->order_catalog[l_idx].event_cd)
   WHILE (l_idx > 0)
    IF (((vese.event_set_cd <= 0.0) OR (vese.event_set_status_cd != c_eventset_status_active)) )
     CALL cv_add_error(e_msg_event_set_invalid,l_idx,0.0)
    ENDIF
    ,l_idx = locateval(l_idx,(l_idx+ 1),nstop,vese.event_cd,reply->order_catalog[l_idx].event_cd)
   ENDWHILE
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SUBROUTINE (cv_add_error(msg_nbr=i4,code1_idx=i4,code2_cd=f8) =null)
   IF (validate(reply) != 0)
    SET l_errcnt = (size(reply->msg,5)+ 1)
    SET stat = alterlist(reply->msg,l_errcnt)
    SET msg_str = fillstring(150," ")
    SET reply->msg[l_errcnt].msg_nbr = msg_nbr
    SET reply->msg[l_errcnt].msg_str = msg_str
    SET s_i18nkey = concat(trim(cnvtstring(l_errcnt)),"-",trim(cnvtstring(msg_nbr)))
    IF (msg_nbr=e_msg_activity_subtype_invalid)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has no Activity SubType")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_event_cd_unavail)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has no associated Event Code")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_task_assay_unavail)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has no associated DTA")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_task_assay_invalid)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET s_code2_disp = nullterm(trim(uar_get_code_display(code2_cd)))
     SET msg_str = build2("DTA Associated to Order has no Reference Step: ",s_code2_disp)
     SET reply->msg[l_errcnt].code2_cd = code2_cd
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_event_class_invalid)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Event Code Associated to Order has invalid Event Class")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_dta_activity_type_invalid)
     SET s_code1_disp = reply->cv_step[code1_idx].task_assay_mnemonic
     SET reply->msg[l_errcnt].code1_cd = reply->cv_step[code1_idx].task_assay_cd
     SET msg_str = build2("DTA Associated to Order has invalid ActivityType")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->cv_step[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->cv_step[code1_idx].msgs,l_size)
     SET reply->cv_step[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_dta_def_result_type_invalid)
     SET s_code1_disp = reply->cv_step[code1_idx].task_assay_mnemonic
     SET reply->msg[l_errcnt].code1_cd = reply->cv_step[code1_idx].task_assay_cd
     SET msg_str = build2("DTA Associated to Order has invalid Default ResultType")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->cv_step[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->cv_step[code1_idx].msgs,l_size)
     SET reply->cv_step[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_csr_step_type_invalid)
     SET s_code1_disp = reply->cv_step[code1_idx].task_assay_mnemonic
     SET reply->msg[l_errcnt].code1_cd = reply->cv_step[code1_idx].task_assay_cd
     SET msg_str = build2("Refence Step has Invalid Step Type")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->cv_step[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->cv_step[code1_idx].msgs,l_size)
     SET reply->cv_step[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_csr_step_doc_type_invalid)
     SET s_code1_disp = reply->cv_step[code1_idx].task_assay_mnemonic
     SET reply->msg[l_errcnt].code1_cd = reply->cv_step[code1_idx].task_assay_cd
     SET msg_str = build2("Reference Step has Invalid DocType")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->cv_step[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->cv_step[code1_idx].msgs,l_size)
     SET reply->cv_step[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_csr_step_sched_invalid)
     SET s_code1_disp = reply->cv_step[code1_idx].task_assay_mnemonic
     SET reply->msg[l_errcnt].code1_cd = reply->cv_step[code1_idx].task_assay_cd
     SET msg_str = build2("Schedulable Reference Step has no Modality")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,"sch_step_inv",msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->cv_step[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->cv_step[code1_idx].msgs,l_size)
     SET reply->cv_step[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_step_signed_unavail)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has no Reference Step with Procedure Status of Signed")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_step_technologist_doc_id_duplicate)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has multiple Technologist steps with same Document Id")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ELSEIF (msg_nbr=e_msg_step_multiple_technologist_no_doc_id)
     SET s_code1_disp = reply->order_catalog[code1_idx].catalog_disp
     SET reply->msg[l_errcnt].code1_cd = reply->order_catalog[code1_idx].catalog_cd
     SET msg_str = build2("Order has multiple Technologist steps with blank Document Id")
     IF (i18nretval=0)
      SET reply->msg[l_errcnt].msg_str = uar_i18ngetmessage(i18nh,s_i18nkey,msg_str)
     ELSE
      SET reply->msg[l_errcnt].msg_str = msg_str
     ENDIF
     SET l_size = (size(reply->order_catalog[code1_idx].msgs,5)+ 1)
     SET stat = alterlist(reply->order_catalog[code1_idx].msgs,l_size)
     SET reply->order_catalog[code1_idx].msgs[l_size].msg_idx = l_errcnt
    ENDIF
   ENDIF
 END ;Subroutine
 CALL echorecord(reply)
END GO
