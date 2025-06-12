CREATE PROGRAM ec_profiler_m51:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IO DATA FLAG"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM code_value_group cvg,
    code_value cv
   PLAN (cvg
    WHERE cvg.code_set=71
     AND cvg.parent_code_value=dipencclass)
    JOIN (cv
    WHERE cv.code_value=cvg.child_code_value
     AND cv.code_set=71)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(ipenctypes->qual,(cnt+ 9))
    ENDIF
    ipenctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
   FOOT REPORT
    stat = alterlist(ipenctypes->qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM encntr_loc_hist elh,
     ce_intake_output_result io,
     clinical_event ce
    PLAN (ce
     WHERE ce.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
      stop_dt_tm)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (io
     WHERE io.event_id=ce.event_id
      AND ((io.person_id+ 0)=ce.person_id)
      AND ((io.encntr_id+ 0)=ce.encntr_id)
      AND io.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND io.io_end_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
      stop_dt_tm))
     JOIN (elh
     WHERE elh.encntr_id=io.encntr_id
      AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
      AND expand(idx,1,size(ipenctypes->qual,5),elh.encntr_type_cd,ipenctypes->qual[idx].
      encntr_type_cd)
      AND elh.active_ind=1
      AND io.io_end_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    ORDER BY elh.loc_facility_cd, io.io_result_id
    HEAD REPORT
     facilitycnt = 0
    HEAD elh.loc_facility_cd
     facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
      reply->facilities,facilitycnt),
     reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, positioncnt = (reply->
     facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].position_cnt =
     positioncnt,
     stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt), reply->facilities[
     facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[facilitycnt].positions[
     positioncnt].capability_in_use_ind = 1,
     resultcnt = 0
    HEAD io.io_result_id
     resultcnt = (resultcnt+ 1)
    FOOT  elh.loc_facility_cd
     detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
     facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt
      ].positions[1].details,detailcnt),
     reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
     facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
       resultcnt))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
