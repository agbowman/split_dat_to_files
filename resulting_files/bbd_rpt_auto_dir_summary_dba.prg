CREATE PROGRAM bbd_rpt_auto_dir_summary:dba
 RECORD reply(
   1 qual[*]
     2 nbr_of_units = f8
     2 product_type = c40
     2 abo_cd = f8
     2 abo_disp = vc
     2 rh_cd = f8
     2 rh_disp = vc
     2 state = c40
   1 donations[*]
     2 nbr_of_units = f8
     2 product_cd = f8
     2 product_disp = c40
     2 outcome = c40
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
   1 in_inventory = vc
   1 finaldisposition = vc
   1 quarantined = vc
   1 dispensed = vc
   1 tested = vc
   1 drawn = vc
 )
 SET status->success = uar_i18ngetmessage(i18nhandle,"success","Success")
 SET status->unsuccessful = uar_i18ngetmessage(i18nhandle,"unsuccessful","Unsuccessful")
 SET status->in_inventory = uar_i18ngetmessage(i18nhandle,"in_inventory","In Inventory")
 SET status->finaldisposition = uar_i18ngetmessage(i18nhandle,"finaldisposition","Final Disposition")
 SET status->quarantined = uar_i18ngetmessage(i18nhandle,"quarantined","Quarantined")
 SET status->dispensed = uar_i18ngetmessage(i18nhandle,"dispensed","Dispensed")
 SET status->tested = uar_i18ngetmessage(i18nhandle,"tested","Tested")
 SET status->drawn = uar_i18ngetmessage(i18nhandle,"drawn","Drawn")
 RECORD struct(
   1 qual[*]
     2 product_id = f8
     2 product_cd = f8
     2 abo_cd = f8
     2 rh_cd = f8
     2 event = c40
 )
 RECORD donation_struct(
   1 qual[*]
     2 procedure_cd = f8
     2 outcome = c40
 )
 SET reply->status_data.status = "F"
 SET request_qual_count = size(request->qual,5)
 SET struct_counter = 0
 SET qual_count = 0
 SET count = 0
 SET event_display = fillstring(20," ")
 SET state1 = fillstring(20," ")
 SET state2 = fillstring(20," ")
 SET don_struct_counter = 0
 SET nbr_don_struct = 0
 SET don_counter = 0
 SET reply_don_counter = 0
 SET failed = "F"
 DECLARE auto_mean = c12 WITH protect, constant("AUTO")
 DECLARE directed_mean = c12 WITH protect, constant("DIRECTED")
 DECLARE success_mean = c12 WITH protect, constant("SUCCESS")
 DECLARE temp_procedure = c12 WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM auto_directed a,
   product p,
   blood_product bp,
   product_event pe,
   product_event pe2,
   (dummyt d1  WITH seq = value(request_qual_count))
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1)
   JOIN (pe
   WHERE pe.product_event_id=a.product_event_id
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->end_dt_tm
    )
    AND pe.active_ind=1)
   JOIN (p
   WHERE p.product_id=a.product_id
    AND p.active_ind=1)
   JOIN (bp
   WHERE bp.product_id=a.product_id
    AND bp.active_ind=1)
   JOIN (d1)
   JOIN (pe2
   WHERE pe2.product_id=a.product_id
    AND pe2.active_ind=1
    AND (pe2.event_type_cd=request->qual[d1.seq].event_type_cd))
  ORDER BY p.product_id, p.product_cd, bp.cur_abo_cd,
   bp.cur_rh_cd, pe2.event_type_cd
  HEAD p.product_id
   struct_counter = (struct_counter+ 1), stat = alterlist(struct->qual,struct_counter), state1 =
   fillstring(20," "),
   state2 = fillstring(20," ")
  DETAIL
   IF (((uar_get_code_meaning(pe2.event_type_cd)="7") OR (((uar_get_code_meaning(pe2.event_type_cd)=
   "5") OR (uar_get_code_meaning(pe2.event_type_cd)="14")) )) )
    IF (((state1 < " ") OR ((state1=status->finaldisposition))) )
     state1 = status->finaldisposition
    ELSEIF (state1 > " "
     AND (state1 != status->finaldisposition))
     IF (((state2=" ") OR ((state2=status->finaldisposition))) )
      state2 = status->finaldisposition
     ENDIF
    ENDIF
   ELSEIF (((uar_get_code_meaning(pe2.event_type_cd)="3") OR (((uar_get_code_meaning(pe2
    .event_type_cd)="1") OR (((uar_get_code_meaning(pe2.event_type_cd)="10") OR (((
   uar_get_code_meaning(pe2.event_type_cd)="11") OR (((uar_get_code_meaning(pe2.event_type_cd)="9")
    OR (((uar_get_code_meaning(pe2.event_type_cd)="13") OR (uar_get_code_meaning(pe2.event_type_cd)=
   "12")) )) )) )) )) )) )
    IF (((state1=" ") OR ((state1=status->in_inventory))) )
     state1 = status->in_inventory
    ELSEIF (state1 > " "
     AND (state1 != status->in_inventory))
     IF (((state2=" ") OR ((state2=status->in_inventory))) )
      state2 = status->in_inventory
     ENDIF
    ENDIF
   ELSEIF (uar_get_code_meaning(pe2.event_type_cd)="2")
    IF (((state1=" ") OR ((state1=status->quarantined))) )
     state1 = status->quarantined
    ELSEIF (state1 > " "
     AND (state1=status->quarantined))
     IF (((state2=" ") OR ((state2=status->quarantined))) )
      state2 = status->quarantined
     ENDIF
    ENDIF
   ELSEIF (uar_get_code_meaning(pe2.event_type_cd)="4")
    IF (((state1=" ") OR ((state1=status->dispensed))) )
     state1 = status->dispensed
    ELSEIF (state1 > " "
     AND (state1 != status->dispensed))
     IF (((state2=" ") OR ((state2=status->dispensed))) )
      state2 = status->dispensed
     ENDIF
    ENDIF
   ELSEIF (uar_get_code_meaning(pe2.event_type_cd)="21")
    IF (((state1=" ") OR ((state1=status->tested))) )
     state1 = status->tested
    ELSEIF (state1 > " "
     AND (state1 != status->tested))
     IF (((state2=" ") OR ((state2=status->tested))) )
      state2 = status->tested
     ENDIF
    ENDIF
   ELSE
    IF (((state1=" ") OR ((state1=status->drawn))) )
     state1 = status->drawn
    ELSEIF (state1 > " "
     AND (state1 != status->drawn))
     IF (((state2=" ") OR ((state2=status->drawn))) )
      state2 = status->drawn
     ENDIF
    ENDIF
   ENDIF
   IF ((((state1=status->quarantined)
    AND (state2=status->finaldisposition)) OR ((state2=status->quarantined)
    AND (state1=status->finaldisposition))) )
    event_display = status->finaldisposition
   ELSEIF ((((state1=status->quarantined)
    AND (state2=status->dispensed)) OR ((state2=status->quarantined)
    AND (state2=status->dispensed))) )
    event_display = status->dispensed
   ELSE
    event_display = state1
   ENDIF
   struct->qual[struct_counter].product_cd = p.product_cd, struct->qual[struct_counter].product_id =
   p.product_id, struct->qual[struct_counter].abo_cd = bp.cur_abo_cd,
   struct->qual[struct_counter].rh_cd = bp.cur_rh_cd, struct->qual[struct_counter].event =
   event_display
  WITH nocounter, check
 ;end select
 SET nbr_struct = size(struct->qual,5)
 IF (nbr_struct=0)
  GO TO donation_script
 ENDIF
 SELECT INTO "nl:"
  product_cd = struct->qual[d1.seq].product_cd, abo_cd = struct->qual[d1.seq].abo_cd, rh_cd = struct
  ->qual[d1.seq].rh_cd,
  event = struct->qual[d1.seq].event
  FROM (dummyt d1  WITH seq = value(nbr_struct))
  ORDER BY struct->qual[d1.seq].product_cd, struct->qual[d1.seq].abo_cd, struct->qual[d1.seq].rh_cd,
   struct->qual[d1.seq].event
  DETAIL
   count = (count+ 1)
  FOOT  product_cd
   IF (count > 0)
    qual_count = (qual_count+ 1), stat = alterlist(reply->qual,qual_count), reply->qual[qual_count].
    nbr_of_units = count,
    reply->qual[qual_count].product_type = uar_get_code_display(struct->qual[d1.seq].product_cd),
    reply->qual[qual_count].abo_cd = struct->qual[d1.seq].abo_cd, reply->qual[qual_count].rh_cd =
    struct->qual[d1.seq].rh_cd,
    reply->qual[qual_count].state = struct->qual[d1.seq].event, count = 0, state1 = fillstring(20," "
     ),
    state2 = fillstring(20," ")
   ENDIF
  FOOT  abo_cd
   IF (count > 0)
    qual_count = (qual_count+ 1), stat = alterlist(reply->qual,qual_count), reply->qual[qual_count].
    nbr_of_units = count,
    reply->qual[qual_count].product_type = uar_get_code_display(struct->qual[d1.seq].product_cd),
    reply->qual[qual_count].abo_cd = struct->qual[d1.seq].abo_cd, reply->qual[qual_count].rh_cd =
    struct->qual[d1.seq].rh_cd,
    reply->qual[qual_count].state = struct->qual[d1.seq].event, count = 0, state1 = fillstring(20," "
     ),
    state2 = fillstring(20," ")
   ENDIF
  FOOT  rh_cd
   IF (count > 0)
    qual_count = (qual_count+ 1), stat = alterlist(reply->qual,qual_count), reply->qual[qual_count].
    nbr_of_units = count,
    reply->qual[qual_count].product_type = uar_get_code_display(struct->qual[d1.seq].product_cd),
    reply->qual[qual_count].abo_cd = struct->qual[d1.seq].abo_cd, reply->qual[qual_count].rh_cd =
    struct->qual[d1.seq].rh_cd,
    reply->qual[qual_count].state = struct->qual[d1.seq].event, count = 0, state1 = fillstring(20," "
     ),
    state2 = fillstring(20," ")
   ENDIF
  FOOT  event
   IF (count > 0)
    qual_count = (qual_count+ 1), stat = alterlist(reply->qual,qual_count), reply->qual[qual_count].
    nbr_of_units = count,
    reply->qual[qual_count].product_type = uar_get_code_display(struct->qual[d1.seq].product_cd),
    reply->qual[qual_count].abo_cd = struct->qual[d1.seq].abo_cd, reply->qual[qual_count].rh_cd =
    struct->qual[d1.seq].rh_cd,
    reply->qual[qual_count].state = struct->qual[d1.seq].event, count = 0, state1 = fillstring(20," "
     ),
    state2 = fillstring(20," ")
   ENDIF
  WITH nocounter
 ;end select
#donation_script
 SELECT INTO "nl:"
  FROM encntr_person_reltn e,
   bbd_donor_contact b,
   bbd_donation_results br
  PLAN (e
   WHERE (e.related_person_id=request->person_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (b
   WHERE b.encntr_id=e.encntr_id
    AND b.active_ind=1)
   JOIN (br
   WHERE br.person_id=b.person_id
    AND br.encntr_id=b.encntr_id
    AND br.active_ind=1
    AND br.drawn_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->end_dt_tm
    ))
  ORDER BY br.procedure_cd
  DETAIL
   temp_procedure = uar_get_code_meaning(br.procedure_cd)
   IF (temp_procedure IN (auto_mean, directed_mean))
    don_struct_counter = (don_struct_counter+ 1), stat = alterlist(donation_struct->qual,
     don_struct_counter), donation_struct->qual[don_struct_counter].procedure_cd = br.procedure_cd
    IF (uar_get_code_meaning(br.outcome_cd)=success_mean)
     donation_struct->qual[don_struct_counter].outcome = status->success
    ELSE
     donation_struct->qual[don_struct_counter].outcome = status->unsuccessful
    ENDIF
   ENDIF
  WITH nocounter, check
 ;end select
 SET nbr_don_struct = size(donation_struct->qual,5)
 IF (nbr_don_struct=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  product_cd = donation_struct->qual[d3.seq].procedure_cd, outcome = donation_struct->qual[d3.seq].
  outcome
  FROM (dummyt d3  WITH seq = value(nbr_don_struct))
  ORDER BY product_cd, outcome
  HEAD product_cd
   row + 0
  HEAD outcome
   row + 0
  DETAIL
   don_counter = (don_counter+ 1)
  FOOT  product_cd
   IF (don_counter > 0)
    reply_don_counter = (reply_don_counter+ 1), stat = alterlist(reply->donations,reply_don_counter),
    reply->donations[reply_don_counter].nbr_of_units = don_counter,
    reply->donations[reply_don_counter].product_cd = donation_struct->qual[d3.seq].procedure_cd,
    reply->donations[reply_don_counter].outcome = donation_struct->qual[d3.seq].outcome, don_counter
     = 0
   ENDIF
  FOOT  outcome
   IF (don_counter > 0)
    reply_don_counter = (reply_don_counter+ 1), stat = alterlist(reply->donations,reply_don_counter),
    reply->donations[reply_don_counter].nbr_of_units = don_counter,
    reply->donations[reply_don_counter].product_cd = donation_struct->qual[d3.seq].procedure_cd,
    reply->donations[reply_don_counter].outcome = donation_struct->qual[d3.seq].outcome, don_counter
     = 0
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
 FREE RECORD struct
 FREE RECORD donation_struct
 FREE RECORD status
END GO
