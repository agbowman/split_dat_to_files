CREATE PROGRAM ams_infuse_billing_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Date" = "CURDATE",
  "Select Nurse Unit" = value(*)
  WITH outdev, date, nunit
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE powerchart_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART")), protect
 DECLARE nonscheduled_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6025,"NONSCHEDULED")),
 protect
 DECLARE iv_var = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV")), protect
 DECLARE begin_var = f8 WITH constant(uar_get_code_by("MEANING",180,"BEGIN")), protect
 DECLARE pending_var = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING")), protect
 DECLARE infusebill_var = f8 WITH constant(uar_get_code_by("MEANING",6026,"INFUSEBILL")), protect
 DECLARE modified_var = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE altered_var = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE unauth_var = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE auth_var = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE emergencyroomquick_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,
   "EMERGENCYROOMQUICK")), protect
 DECLARE emergencyroom_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCYROOM")),
 protect
 DECLARE emergencyfasttrack_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,
   "EMERGENCYFASTTRACK")), protect
 DECLARE opu_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATIONATUMC")), protect
 DECLARE edu_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"UMCEMERGENCYDEPT")), protect
 DECLARE eru_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"UMCEMERGENCYROOMQUICKREG")),
 protect
 DECLARE finnbr_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE extendedobservationfromsds_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,
   "EXTENDEDOBSERVATIONFROMSDS")), protect
 DECLARE observationatsz_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATIONATSZ")),
 protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE indx = i4
 DECLARE nurse_count = i4 WITH noconstant(0), protect
 DECLARE patient_count = i4 WITH noconstant(0), protect
 DECLARE infusion_count = i4 WITH noconstant(0), protect
 DECLARE complete_count = i4 WITH noconstant(0), protect
 DECLARE ilcnt = i2 WITH protect, noconstant(1)
 DECLARE tot_patient_count = i4 WITH noconstant(0), protect
 DECLARE tot_infusion_count = i4 WITH noconstant(0), protect
 DECLARE tot_complete_count = i4 WITH noconstant(0), protect
 DECLARE p_count = i4 WITH noconstant(0), protect
 DECLARE i_count = i4 WITH noconstant(0), protect
 DECLARE c_count = i4 WITH noconstant(0), protect
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(3,0)))), public
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE clocation = c1 WITH protect, constant(substring(1,1,reflect(parameter(3,0))))
 DECLARE ilocation_cnt = i2 WITH protect, noconstant(cnvtint(substring(2,3,reflect(parameter(3,0)))))
 DECLARE slocation_select_parameters = vc WITH protect, noconstant(" ")
 DECLARE slocation_parser_string = vc WITH protect, noconstant("e.loc_nurse_unit_cd in (")
 DECLARE dlocation_cd = f8 WITH protect, noconstant(0.0)
 CASE (clocation)
  OF "C":
   SET slocation_parser_string = "e.loc_nurse_unit_cd>0.0"
   SET slocation_select_parameters = "All Locations"
  OF "F":
   SET slocation_parser_string = build(trim(slocation_parser_string,3),parameter(3,1),")")
   SET dlocation_cd = parameter(3,1)
   SET slocation_select_parameters = trim(uar_get_code_description(dlocation_cd),3)
  OF "L":
   SET slocation_parser_string = build(trim(slocation_parser_string,3),parameter(3,ilcnt))
   SET dlocation_cd = parameter(3,1)
   SET slocation_select_parameters = trim(uar_get_code_description(dlocation_cd),3)
   FOR (ilcnt = 2 TO ilocation_cnt)
     SET dlocation_cd = parameter(3,ilcnt)
     SET slocation_parser_string = build(trim(slocation_parser_string,3),",",parameter(3,ilcnt))
     SET slocation_select_parameters = concat(trim(slocation_select_parameters,3),", ",trim(
       uar_get_code_description(dlocation_cd),3))
   ENDFOR
   SET slocation_parser_string = build(trim(slocation_parser_string,3),")")
 ENDCASE
 FREE RECORD infusion_rpt
 RECORD infusion_rpt(
   1 rpt[*]
     2 nurse_unit = vc
     2 qual[*]
       3 encntr_type = vc
       3 patient_name = vc
       3 fin = vc
       3 room_bed = vc
       3 admit_dt = vc
       3 disch_dt = vc
       3 infusion_no = vc
       3 start_no = vc
       3 stop_no = vc
       3 complete = vc
 )
 FREE RECORD orders
 RECORD orders(
   1 qual[*]
     2 encntr_id = f8
     2 order_id = f8
     2 start_cnt = i4
     2 end_cnt = i4
     2 dateofevent = dq8
     2 nurs_unit = vc
     2 room_cd = vc
     2 bed_cd = vc
 )
 SELECT
  FROM task_activity ta,
   clinical_event ce,
   ce_med_result cmr,
   orders o
  PLAN (ta
   WHERE ta.task_type_cd=infusebill_var
    AND ta.task_status_cd=pending_var
    AND ta.task_class_cd=nonscheduled_var
    AND ta.active_ind=1)
   JOIN (ce
   WHERE ce.order_id=ta.order_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.contributor_system_cd=powerchart_var
    AND ce.result_status_cd IN (auth_var, unauth_var, altered_var, modified_var)
    AND ce.catalog_cd != 0
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE),0) AND cnvtdatetime(cnvtdate( $DATE),
    235959)
    AND ce.event_start_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE),0) AND cnvtdatetime(cnvtdate(
      $DATE),235959))
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND cmr.iv_event_cd=begin_var)
   JOIN (o
   WHERE o.order_id=ta.order_id
    AND o.med_order_type_cd=iv_var)
  ORDER BY ta.order_id
  HEAD REPORT
   cnt = 0
  HEAD ta.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(orders->qual,(cnt+ 9))
   ENDIF
   orders->qual[cnt].order_id = ta.order_id, orders->qual[cnt].dateofevent = cnvtdatetime(ce
    .event_end_dt_tm), orders->qual[cnt].encntr_id = ce.encntr_id,
   orders->qual[cnt].nurs_unit = uar_get_code_display(ta.location_cd), orders->qual[cnt].room_cd =
   uar_get_code_display(ta.loc_room_cd), orders->qual[cnt].bed_cd = uar_get_code_display(ta
    .loc_room_cd)
  HEAD ce.event_id
   orders->qual[cnt].start_cnt = (orders->qual[cnt].start_cnt+ 1)
  FOOT REPORT
   stat = alterlist(orders->qual,cnt)
  WITH nocounter
 ;end select
 SELECT
  FROM task_activity ta,
   ce_event_order_link ceol,
   clinical_event ce,
   ce_med_result cmr,
   orders o
  PLAN (ta
   WHERE ta.task_type_cd=infusebill_var
    AND ta.task_status_cd=pending_var
    AND ta.task_class_cd=nonscheduled_var
    AND ta.active_ind=1)
   JOIN (ceol
   WHERE ta.order_id=ceol.parent_order_ident
    AND ceol.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE),0) AND cnvtdatetime(cnvtdate(
      $DATE),235959)
    AND ceol.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ce
   WHERE ceol.event_id=ce.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.result_status_cd IN (auth_var, unauth_var, altered_var, modified_var)
    AND ce.catalog_cd != 0
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE),0) AND cnvtdatetime(cnvtdate( $DATE),
    235959)
    AND ce.event_start_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE),0) AND cnvtdatetime(cnvtdate(
      $DATE),235959))
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (o
   WHERE o.order_id=ta.order_id
    AND o.med_order_type_cd != iv_var)
  ORDER BY ta.order_id, ce.parent_event_id
  HEAD REPORT
   cnt = size(orders->qual,5), c_count = (10 - mod(cnt,10)), stat = alterlist(orders->qual,(c_count+
    cnt))
  HEAD ta.order_id
   stat_val = locateval(count,1,size(orders->qual,5),ta.order_id,orders->qual[count].order_id)
   IF (stat_val=0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(orders->qual[cnt],(cnt+ 9))
    ENDIF
    orders->qual[cnt].order_id = ta.order_id, orders->qual[cnt].dateofevent = ce.event_end_dt_tm,
    orders->qual[cnt].encntr_id = ta.encntr_id,
    orders->qual[cnt].nurs_unit = uar_get_code_display(ta.location_cd), orders->qual[cnt].room_cd =
    uar_get_code_display(ta.loc_room_cd), orders->qual[cnt].bed_cd = uar_get_code_display(ta
     .loc_room_cd)
   ENDIF
  HEAD ce.event_id
   IF (stat_val > 0)
    orders->qual[stat_val].start_cnt = (orders->qual[stat_val].start_cnt+ 1)
   ELSE
    orders->qual[cnt].start_cnt = (orders->qual[cnt].start_cnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(orders->qual,cnt)
  WITH format
 ;end select
 SELECT INTO "nl:"
  FROM infusion_billing_event ie,
   encntr_loc_hist elh
  WHERE ie.order_id != 0
   AND ie.infusion_start_dt_tm >= cnvtdatetime(cnvtdate( $DATE),0)
   AND ie.infusion_start_dt_tm <= cnvtdatetime(cnvtdate( $DATE),235959)
   AND elh.encntr_id=ie.encntr_id
   AND ie.infusion_start_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
  ORDER BY ie.order_id
  HEAD REPORT
   cnt = size(orders->qual,5), c_count = (10 - mod(cnt,10)), stat = alterlist(orders->qual,(c_count+
    cnt))
  HEAD ie.order_id
   stat_val = locateval(count,1,size(orders->qual,5),ie.order_id,orders->qual[count].order_id)
   IF (stat_val=0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(orders->qual[cnt],(cnt+ 9))
    ENDIF
    CALL echo(build2("COUNTInside:",cnt)), orders->qual[cnt].order_id = ie.order_id, orders->qual[cnt
    ].dateofevent = ie.infusion_start_dt_tm,
    orders->qual[cnt].encntr_id = ie.encntr_id, orders->qual[cnt].nurs_unit = uar_get_code_display(
     elh.loc_nurse_unit_cd), orders->qual[cnt].room_cd = uar_get_code_display(elh.loc_room_cd),
    orders->qual[cnt].bed_cd = uar_get_code_display(elh.loc_bed_cd)
   ENDIF
  DETAIL
   IF (stat_val > 0)
    orders->qual[stat_val].end_cnt = (orders->qual[stat_val].end_cnt+ 1)
   ELSE
    orders->qual[cnt].start_cnt = (orders->qual[cnt].start_cnt+ 1), orders->qual[cnt].end_cnt = (
    orders->qual[cnt].end_cnt+ 1)
   ENDIF
   CALL echo(build2("StartCNT1:",orders->qual[cnt].start_cnt)),
   CALL echo(build2("StartCNT20:",cnt))
  FOOT REPORT
   stat = alterlist(orders->qual,cnt)
  WITH format
 ;end select
 SET count = 0
 SELECT
  qual_order_id = orders->qual[d1.seq].order_id, e_loc_nurse_unit_disp = uar_get_code_display(elh
   .loc_nurse_unit_cd), e_loc_room_disp = uar_get_code_display(elh.loc_room_cd),
  e_loc_bed_disp = uar_get_code_display(elh.loc_bed_cd), e_encntr_type_disp = uar_get_code_display(
   elh.encntr_type_cd)
  FROM orders o,
   encounter e,
   encntr_loc_hist elh,
   encntr_alias ea,
   person p,
   (dummyt d1  WITH seq = value(size(orders->qual,5)))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=orders->qual[d1.seq].order_id))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.encntr_type_cd IN (extendedobservationfromsds_var, observationatsz_var, eru_var,
   emergencyfasttrack_var, emergencyroom_var,
   emergencyroomquick_var, opu_var, edu_var)
    AND parser(slocation_parser_string)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(orders->qual[d1.seq].dateofevent)
    AND elh.end_effective_dt_tm >= cnvtdatetime(orders->qual[d1.seq].dateofevent))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_var)
   JOIN (p
   WHERE e.person_id=p.person_id)
  ORDER BY e_loc_nurse_unit_disp, ea.alias
  HEAD e_loc_nurse_unit_disp
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(infusion_rpt->rpt,(count+ 9))
   ENDIF
   infusion_rpt->rpt[count].nurse_unit = e_loc_nurse_unit_disp, nurse_count = 0, patient_count = 0,
   infusion_count = 0, complete_count = 0
  HEAD ea.alias
   patient_count = (patient_count+ 1), nurse_count = (nurse_count+ 1)
   IF (mod(nurse_count,10)=1)
    stat = alterlist(infusion_rpt->rpt[count].qual,(nurse_count+ 9))
   ENDIF
   i_count = 0, c_count = 0, p_count = 0,
   infusion_rpt->rpt[count].qual[nurse_count].patient_name = trim(p.name_full_formatted),
   infusion_rpt->rpt[count].qual[nurse_count].fin = trim(ea.alias), infusion_rpt->rpt[count].qual[
   nurse_count].encntr_type = e_encntr_type_disp,
   infusion_rpt->rpt[count].qual[nurse_count].admit_dt = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;Q"),
   infusion_rpt->rpt[count].qual[nurse_count].disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM;;Q"),
   infusion_rpt->rpt[count].qual[nurse_count].room_bed = trim(concat(trim(e_loc_room_disp),"/",
     e_loc_bed_disp))
  DETAIL
   stat = locateval(cnt,1,size(orders->qual,5),o.order_id,orders->qual[cnt].order_id)
   IF (stat > 0)
    infusion_count = (infusion_count+ orders->qual[stat].start_cnt), i_count = (i_count+ orders->
    qual[stat].start_cnt), p_count = (p_count+ orders->qual[stat].start_cnt),
    c_count = (c_count+ orders->qual[stat].end_cnt), complete_count = (complete_count+ orders->qual[
    stat].end_cnt)
   ENDIF
  FOOT  ea.alias
   infusion_rpt->rpt[count].qual[nurse_count].infusion_no = cnvtstring(i_count), infusion_rpt->rpt[
   count].qual[nurse_count].start_no = cnvtstring(p_count), infusion_rpt->rpt[count].qual[nurse_count
   ].stop_no = cnvtstring(c_count),
   infusion_rpt->rpt[count].qual[nurse_count].complete = cnvtstring(((c_count * 100)/ p_count))
  FOOT  e_loc_nurse_unit_disp
   stat = alterlist(infusion_rpt->rpt[count].qual,nurse_count), count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(infusion_rpt->rpt,count)
   ENDIF
   stat = alterlist(infusion_rpt->rpt[count].qual,2),
   CALL echo(patient_count), infusion_rpt->rpt[count].qual[1].room_bed = concat(
    "Total # Patients had Infusion: ",trim(cnvtstring(patient_count))),
   CALL echo(infusion_rpt->rpt[count].qual[1].room_bed), infusion_rpt->rpt[count].qual[1].
   patient_name = concat("Total # Infusions : ",cnvtstring(infusion_count)), infusion_rpt->rpt[count]
   .qual[1].encntr_type = concat("Total # complete :",cnvtstring(complete_count)),
   infusion_rpt->rpt[count].qual[1].fin = concat("% complete : ",cnvtstring(cnvtreal(((
      complete_count * 100)/ infusion_count)))), infusion_rpt->rpt[count].qual[1].complete = "----",
   infusion_rpt->rpt[count].qual[1].stop_no = "----",
   infusion_rpt->rpt[count].qual[1].start_no = "----", infusion_rpt->rpt[count].qual[1].infusion_no
    = "----", infusion_rpt->rpt[count].qual[1].disch_dt = "----",
   infusion_rpt->rpt[count].qual[1].admit_dt = "----", tot_patient_count = (tot_patient_count+
   patient_count), tot_infusion_count = (tot_infusion_count+ infusion_count),
   tot_complete_count = (tot_complete_count+ complete_count)
  FOOT REPORT
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(infusion_rpt->rpt,count)
   ENDIF
   stat = alterlist(infusion_rpt->rpt[count].qual,1), infusion_rpt->rpt[count].nurse_unit = concat(
    "Total # Patients : ",cnvtstring(tot_patient_count)), infusion_rpt->rpt[count].qual[1].
   patient_name = concat("Total # Infusions : ",cnvtstring(tot_infusion_count)),
   infusion_rpt->rpt[count].qual[1].encntr_type = concat("Total # complete :",cnvtstring(
     tot_complete_count)), infusion_rpt->rpt[count].qual[1].fin = concat("% complete : ",cnvtstring(
     cnvtreal(((tot_complete_count * 100)/ tot_infusion_count)))), stat = alterlist(infusion_rpt->rpt,
    count)
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO  $OUTDEV
  encntr_type = substring(1,30,infusion_rpt->rpt[d1.seq].qual[d2.seq].encntr_type), patient_name =
  substring(1,30,infusion_rpt->rpt[d1.seq].qual[d2.seq].patient_name), fin = substring(1,30,
   infusion_rpt->rpt[d1.seq].qual[d2.seq].fin),
  nurse_unit = substring(1,30,infusion_rpt->rpt[d1.seq].nurse_unit), room_bed = trim(substring(1,40,
    infusion_rpt->rpt[d1.seq].qual[d2.seq].room_bed)), admit_dt = infusion_rpt->rpt[d1.seq].qual[d2
  .seq].admit_dt,
  disch_dt = infusion_rpt->rpt[d1.seq].qual[d2.seq].disch_dt, infusion_no = infusion_rpt->rpt[d1.seq]
  .qual[d2.seq].infusion_no, start_no = infusion_rpt->rpt[d1.seq].qual[d2.seq].start_no,
  stop_no = infusion_rpt->rpt[d1.seq].qual[d2.seq].stop_no, complete_as_perc = infusion_rpt->rpt[d1
  .seq].qual[d2.seq].complete
  FROM (dummyt d1  WITH seq = value(size(infusion_rpt->rpt,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(infusion_rpt->rpt[d1.seq].qual,5)))
   JOIN (d2)
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET last_mode = "001 KK032244 20/03/2015 Initial Release"
END GO
