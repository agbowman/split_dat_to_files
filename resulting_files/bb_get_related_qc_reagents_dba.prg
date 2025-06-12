CREATE PROGRAM bb_get_related_qc_reagents:dba
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
 RECORD reply(
   1 related_reagent_list[*]
     2 qc_reagent_cd = f8
     2 qc_reagent_disp = c40
     2 qc_reagent_id = f8
     2 qc_reagent_name = c40
     2 qc_reagent_name_key = c40
     2 active_ind = i2
     2 updt_cnt = i4
     2 related_reagent_detail_list[*]
       3 related_reagent_detail_id = f8
       3 enhancement_cd = f8
       3 enhancement_disp = c40
       3 control_cd = f8
       3 control_disp = c40
       3 phase_cd = f8
       3 phase_disp = c40
       3 active_ind = i2
       3 updt_cnt = i4
       3 expected_result_list[*]
         4 expected_result_id = f8
         4 result_id = f8
         4 result_string = c40
         4 active_ind = i2
         4 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getqcrelatedreagents(no_param=i2(value)) = i2 WITH private
 DECLARE getqcreagentdetails(no_param=i2(value)) = i2 WITH private
 DECLARE getqcexpectedresults(no_param=i2(value)) = i2 WITH private
 DECLARE nstatus = i2 WITH noconstant(0), protect
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nno_matches = i2 WITH protect, constant(2)
#begin_script
 SET reply->status_data.status = "F"
 SET nstatus = getqcrelatedreagents(0)
 IF (nstatus=nno_matches)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","BB_QC_RELATED_REAGENT","No related reagents found.")
  GO TO exit_script
 ELSEIF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_RELATED_REAGENT","Query for related reagents failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getqcreagentdetails(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_RELATED_REAGENT_DETAIL",
   "Query for related reagent details failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getqcexpectedresults(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_EXPECTED_RESULT_R","Query for expected results failed.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE getqcrelatedreagents(no_param)
   DECLARE lrelatedcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM bb_qc_rel_reagent rr
    PLAN (rr
     WHERE rr.related_reagent_id > 0)
    DETAIL
     lrelatedcnt = (lrelatedcnt+ 1)
     IF (lrelatedcnt > size(reply->related_reagent_list,5))
      nstatus = alterlist(reply->related_reagent_list,(lrelatedcnt+ 10))
     ENDIF
     reply->related_reagent_list[lrelatedcnt].qc_reagent_cd = rr.reagent_cd, reply->
     related_reagent_list[lrelatedcnt].qc_reagent_id = rr.related_reagent_id, reply->
     related_reagent_list[lrelatedcnt].qc_reagent_name = rr.related_reagent_name,
     reply->related_reagent_list[lrelatedcnt].qc_reagent_name_key = rr.related_reagent_name_key,
     reply->related_reagent_list[lrelatedcnt].active_ind = rr.active_ind, reply->
     related_reagent_list[lrelatedcnt].updt_cnt = rr.updt_cnt
    FOOT REPORT
     nstatus = alterlist(reply->related_reagent_list,lrelatedcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->related_reagent_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE getqcreagentdetails(no_param)
   DECLARE ldetailcnt = i4 WITH noconstant(0), protect
   DECLARE lreagentcnt = i4 WITH noconstant(0), protect
   SET lreagentcnt = size(reply->related_reagent_list,5)
   IF (lreagentcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(lreagentcnt)),
      bb_qc_rel_reagent_detail rrd
     PLAN (d1)
      JOIN (rrd
      WHERE (rrd.related_reagent_id=reply->related_reagent_list[d1.seq].qc_reagent_id)
       AND rrd.prev_related_reagent_detail_id=rrd.related_reagent_detail_id
       AND rrd.active_ind=1)
     ORDER BY rrd.related_reagent_id
     HEAD rrd.related_reagent_id
      ldetailcnt = 0
     DETAIL
      ldetailcnt = (ldetailcnt+ 1)
      IF (ldetailcnt > size(reply->related_reagent_list[d1.seq].related_reagent_detail_list,5))
       nstatus = alterlist(reply->related_reagent_list[d1.seq].related_reagent_detail_list,(
        ldetailcnt+ 10))
      ENDIF
      reply->related_reagent_list[d1.seq].related_reagent_detail_list[ldetailcnt].
      related_reagent_detail_id = rrd.related_reagent_detail_id, reply->related_reagent_list[d1.seq].
      related_reagent_detail_list[ldetailcnt].enhancement_cd = rrd.enhancement_cd, reply->
      related_reagent_list[d1.seq].related_reagent_detail_list[ldetailcnt].control_cd = rrd
      .control_cd,
      reply->related_reagent_list[d1.seq].related_reagent_detail_list[ldetailcnt].phase_cd = rrd
      .phase_cd, reply->related_reagent_list[d1.seq].related_reagent_detail_list[ldetailcnt].
      active_ind = rrd.active_ind, reply->related_reagent_list[d1.seq].related_reagent_detail_list[
      ldetailcnt].updt_cnt = rrd.updt_cnt
     FOOT  rrd.related_reagent_id
      nstatus = alterlist(reply->related_reagent_list[d1.seq].related_reagent_detail_list,ldetailcnt)
     WITH nocounter
    ;end select
   ENDIF
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE getqcexpectedresults(no_param)
   DECLARE lexpectedcnt = i4 WITH noconstant(0), protect
   DECLARE lreagentcnt = i4 WITH noconstant(0), protect
   DECLARE ldetailcnt = i4 WITH noconstant(0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE j = i4 WITH noconstant(0), protect
   SET lreagentcnt = size(reply->related_reagent_list,5)
   IF (lreagentcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(lreagentcnt)),
      (dummyt d2  WITH seq = 1),
      bb_qc_expected_result_r er,
      nomenclature n
     PLAN (d1
      WHERE maxrec(d2,size(reply->related_reagent_list[d1.seq].related_reagent_detail_list,5)))
      JOIN (d2)
      JOIN (er
      WHERE (er.related_reagent_detail_id=reply->related_reagent_list[d1.seq].
      related_reagent_detail_list[d2.seq].related_reagent_detail_id)
       AND er.expected_result_id=er.prev_expected_result_id
       AND er.active_ind=1)
      JOIN (n
      WHERE n.nomenclature_id=er.nomenclature_id
       AND n.nomenclature_id > 0)
     ORDER BY d1.seq, d2.seq
     HEAD d1.seq
      row + 0
     HEAD d2.seq
      lexpectedcnt = 0
     DETAIL
      lexpectedcnt = (lexpectedcnt+ 1)
      IF (lexpectedcnt > size(reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq]
       .expected_result_list,5))
       nstatus = alterlist(reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
        expected_result_list,(lexpectedcnt+ 10))
      ENDIF
      reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].expected_result_list[
      lexpectedcnt].expected_result_id = er.expected_result_id, reply->related_reagent_list[d1.seq].
      related_reagent_detail_list[d2.seq].expected_result_list[lexpectedcnt].result_id = n
      .nomenclature_id, reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
      expected_result_list[lexpectedcnt].result_string = n.short_string,
      reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].expected_result_list[
      lexpectedcnt].active_ind = er.active_ind, reply->related_reagent_list[d1.seq].
      related_reagent_detail_list[d2.seq].expected_result_list[lexpectedcnt].updt_cnt = er.updt_cnt
     FOOT  d2.seq
      nstatus = alterlist(reply->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
       expected_result_list,lexpectedcnt)
     FOOT  d1.seq
      row + 0
     WITH nocounter
    ;end select
   ENDIF
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
END GO
