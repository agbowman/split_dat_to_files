CREATE PROGRAM drc_calc_get_unit_exprsns:dba
 RECORD reply(
   1 unitlist[*]
     2 ue_id = f8
     2 ue_cki = vc
     2 ue_disp = vc
     2 ue_code_value = f8
     2 ue_numerator_id_list[*]
       3 ue_branch_unit_id = f8
     2 ue_denominator_id_list[*]
       3 ue_branch_unit_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 SET counter = 0
 SET numercntr = 0
 SET denomcntr = 0
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SELECT INTO "nl:"
  e.unit_exprsn_cki, e.drc_unit_exprsn_id, r.drc_unit_exprsn_id,
  r.relation_numerator_ind, r.drc_unit_id, code = uar_get_code_by_cki(e.unit_exprsn_cki)
  FROM drc_unit_exprsn e,
   drc_unit_exprsn_reltn r
  PLAN (e)
   JOIN (r
   WHERE e.drc_unit_exprsn_id=r.drc_unit_exprsn_id)
  ORDER BY e.unit_exprsn_cki, r.relation_numerator_ind
  HEAD e.unit_exprsn_cki
   counter = (counter+ 1)
   IF (counter > size(reply->unitlist,5))
    stat = alterlist(reply->unitlist,(counter+ 10))
   ENDIF
   reply->unitlist[counter].ue_cki = e.unit_exprsn_cki, reply->unitlist[counter].ue_id = e
   .drc_unit_exprsn_id, reply->unitlist[counter].ue_disp = uar_get_code_display(code),
   reply->unitlist[counter].ue_code_value = code, denomcntr = 0, numercntr = 0
  DETAIL
   IF (r.relation_numerator_ind=0)
    denomcntr = (denomcntr+ 1), stat = alterlist(reply->unitlist[counter].ue_denominator_id_list,
     denomcntr), reply->unitlist[counter].ue_denominator_id_list[denomcntr].ue_branch_unit_id = r
    .drc_unit_id
   ENDIF
   IF (r.relation_numerator_ind=1)
    numercntr = (numercntr+ 1), stat = alterlist(reply->unitlist[counter].ue_numerator_id_list,
     numercntr), reply->unitlist[counter].ue_numerator_id_list[numercntr].ue_branch_unit_id = r
    .drc_unit_id
   ENDIF
  FOOT  e.unit_exprsn_cki
   stat = alterlist(reply->unitlist,counter)
  WITH nocounter
 ;end select
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,errcnt)
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
 ENDWHILE
 IF (curqual=0
  AND (errors->err_cnt > 1))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDERS"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
