CREATE PROGRAM bbd_get_auto_dir_donations:dba
 RECORD reply(
   1 qual[*]
     2 name = vc
     2 number = c200
     2 abo_cd = f8
     2 abo_disp = c40
     2 rh_cd = f8
     2 rh_disp = c40
     2 donated_dt_tm = dq8
     2 donated_proc_cd = f8
     2 donated_proc_disp = c40
     2 product_id = f8
     2 outcome = vc
     2 product_nbr = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE i18nhandle = i2 WITH protect, noconstant(0)
 DECLARE h = i2 WITH protect, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD status(
   1 success = vc
   1 unsuccessful = vc
 )
 SET status->success = uar_i18ngetmessage(i18nhandle,"success","Success")
 SET status->unsuccessful = uar_i18ngetmessage(i18nhandle,"unsuccessful","Unsuccessful")
 SET reply->status_data.status = "F"
 SET count = 0
 SET failed = "F"
 DECLARE auto_mean = c12 WITH protect, constant("AUTO")
 DECLARE directed_mean = c12 WITH protect, constant("DIRECTED")
 DECLARE success_mean = c12 WITH protect, constant("SUCCESS")
 DECLARE temp_procedure = c12 WITH protect, noconstant("")
 DECLARE ddonorid_cv = f8 WITH protect, noconstant(0.0)
 SET code_value = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_get_patient_recip"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 4 and DonorID"
  GO TO exit_script
 ENDIF
 SET ddonorid_cv = code_value
 SELECT INTO "nl:"
  FROM encntr_person_reltn e,
   bbd_donor_contact b,
   person p,
   person_alias pa,
   person_aborh pr,
   bbd_donation_results br,
   bbd_don_product_r bd,
   product pd
  PLAN (e
   WHERE (e.related_person_id=request->person_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (b
   WHERE b.encntr_id=e.encntr_id
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=b.person_id
    AND p.active_ind=1)
   JOIN (br
   WHERE br.person_id=p.person_id
    AND br.active_ind=1
    AND br.contact_id=b.contact_id
    AND br.drawn_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->end_dt_tm
    ))
   JOIN (bd
   WHERE bd.person_id=outerjoin(br.person_id)
    AND bd.donation_results_id=outerjoin(br.donation_result_id)
    AND bd.active_ind=outerjoin(1))
   JOIN (pd
   WHERE pd.product_id=outerjoin(bd.product_id))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(ddonorid_cv))
   JOIN (pr
   WHERE pr.person_id=outerjoin(p.person_id)
    AND pr.active_ind=outerjoin(1))
  DETAIL
   temp_procedure = uar_get_code_meaning(br.procedure_cd)
   IF (temp_procedure IN (auto_mean, directed_mean))
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].name = p
    .name_full_formatted,
    reply->qual[count].number = pa.alias, reply->qual[count].abo_cd = pr.abo_cd, reply->qual[count].
    rh_cd = pr.rh_cd,
    reply->qual[count].donated_dt_tm = br.drawn_dt_tm, reply->qual[count].donated_proc_cd = br
    .procedure_cd, reply->qual[count].product_nbr = pd.product_nbr,
    reply->qual[count].product_id = pd.product_id
    IF (uar_get_code_meaning(br.outcome_cd)=success_mean)
     reply->qual[count].outcome = status->success
    ELSE
     reply->qual[count].outcome = status->unsuccessful
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD status
END GO
