CREATE PROGRAM dcp_get_pip_orders_flt:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 order_list[*]
       3 encntr_id = f8
       3 order_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 notify_display_line = vc
       3 order_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 med_order_type_cd = f8
       3 need_rx_verify_ind = i2
       3 need_nurse_review_ind = i2
       3 need_doctor_cosign_ind = i2
       3 order_status_cd = f8
       3 iv_ind = i2
       3 constant_ind = i2
       3 order_comment_ind = i2
       3 comment_type_mask = i4
       3 order_comment_text = vc
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 detail_list[*]
         4 oe_field_id = f8
         4 oe_field_value = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_dt_tm_value = dq8
         4 oe_field_display_value = vc
       3 additive_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD temp
 RECORD temp(
   1 catalog_cnt = i4
   1 catalogs[*]
     2 catalog_cd = f8
   1 detail_cnt = i4
   1 details[*]
     2 oe_field_id = f8
   1 order_cnt = i4
   1 pat_orders[*]
     2 index = i4
     2 person_id = f8
   1 med_order_cnt = i4
   1 med_orders[*]
     2 order_id = f8
   1 orders[*]
     2 person_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 med_order_type_cd = f8
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 order_status_cd = f8
     2 notify_display_line = vc
     2 hna_order_mnemonic = vc
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 iv_ind = i2
     2 constant_ind = i2
     2 order_comment_ind = i2
     2 comment_type_mask = i4
     2 order_comment_text = vc
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 additive_cnt = i4
     2 detail_cnt = i4
     2 detail_list[*]
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_meaning = vc
       3 oe_field_meaning_id = f8
       3 oe_field_dt_tm_value = dq8
       3 oe_field_display_value = vc
   1 activities[*]
     2 activity_type_cd = f8
   1 catalogtype[*]
     2 catalog_type_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE script_version = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE ordlistcnt = i4 WITH protect, noconstant(size(request->order_list,5))
 DECLARE perlistcnt = i4 WITH protect, noconstant(size(request->person_list,5))
 IF (((ordlistcnt=0) OR (perlistcnt=0)) )
  CALL echo("Initialize subroutine failed")
  CALL fillsubeventstatus("dcp_get_pip_orders_flt","F","REQUEST",
   "Unable to get 'order_list' and 'person_list' count from the request.")
  SET failure_ind = 1
  GO TO failure
 ENDIF
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 IF (debugind=1)
  CALL echo("*******************************************************")
  CALL echo("Request")
  CALL echorecord(request)
  CALL echo("*******************************************************")
 ENDIF
 DECLARE initialize(null) = null
 DECLARE identifyorders(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE determineadditivecnt(null) = null
 DECLARE sortordersbypatient(null) = null
 DECLARE populatereply(null) = null
 CALL initialize(null)
 CALL identifyorders(null)
 IF ((temp->order_cnt > 0))
  CALL loadordercomments(null)
  CALL loadorderdetails(null)
  CALL determineadditivecnt(null)
 ENDIF
 CALL populatereply(null)
 SUBROUTINE initialize(null)
   IF (debugind=1)
    CALL echo("*Entering Initialize subroutine*")
   ENDIF
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE idy = i4 WITH protect, noconstant(- (1))
   DECLARE numy = i4 WITH protect, noconstant(0)
   DECLARE activity_cnt = i4 WITH protect, noconstant(0)
   DECLARE catalog_cnt = i4 WITH protect, noconstant(0)
   DECLARE numinit = i4 WITH protect, noconstant(0)
   DECLARE cattypecnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(temp->details,ordlistcnt)
   FOR (x = 1 TO ordlistcnt)
    IF ((request->order_list[x].oe_field_id > 0))
     SET temp->detail_cnt = (temp->detail_cnt+ 1)
     SET temp->details[temp->detail_cnt].oe_field_id = request->order_list[x].oe_field_id
    ENDIF
    IF ((request->order_list[x].catalog_cd > 0))
     SET catalog_cnt = (catalog_cnt+ 1)
     IF (mod(catalog_cnt,100)=1)
      SET stat = alterlist(temp->catalogs,(catalog_cnt+ 99))
     ENDIF
     SET temp->catalogs[catalog_cnt].catalog_cd = request->order_list[x].catalog_cd
    ELSE
     SET activity_cnt = (activity_cnt+ 1)
     IF (mod(activity_cnt,100)=1)
      SET stat = alterlist(temp->activities,(activity_cnt+ 99))
     ENDIF
     SET temp->activities[activity_cnt].activity_type_cd = request->order_list[x].activity_type_cd
    ENDIF
   ENDFOR
   SET stat = alterlist(temp->activities,activity_cnt)
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE expand(numinit,1,ordlistcnt,ocs.activity_type_cd,request->order_list[numinit].
     activity_type_cd)
    ORDER BY ocs.catalog_cd
    HEAD ocs.catalog_cd
     IF (size(temp->catalogtype,5) != 0)
      idy = locateval(numy,1,size(temp->catalogtype,5),ocs.catalog_type_cd,temp->catalogtype[numy].
       catalog_type_cd)
     ENDIF
     IF (idy <= 0
      AND ocs.catalog_type_cd > 0)
      cattypecnt = (cattypecnt+ 1)
      IF (mod(cattypecnt,100)=1)
       stat = alterlist(temp->catalogtype,(cattypecnt+ 99))
      ENDIF
      temp->catalogtype[cattypecnt].catalog_type_cd = ocs.catalog_type_cd
     ENDIF
     idx = locateval(numx,1,activity_cnt,ocs.activity_type_cd,temp->activities[numx].activity_type_cd
      )
     IF (idx > 0)
      catalog_cnt = (catalog_cnt+ 1)
      IF (mod(catalog_cnt,100)=1)
       stat = alterlist(temp->catalogs,(catalog_cnt+ 99))
      ENDIF
      temp->catalogs[catalog_cnt].catalog_cd = ocs.catalog_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->catalogs,catalog_cnt), stat = alterlist(temp->catalogtype,cattypecnt)
    WITH nocounter, expand = 1
   ;end select
   SET temp->catalog_cnt = catalog_cnt
   IF (debugind=1)
    CALL echo("*Leaving Initialize subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE identifyorders(null)
   IF (debugind=1)
    CALL echo("*Entering IdentifyOrders subroutine*")
   ENDIF
   DECLARE numident1 = i4 WITH protect, noconstant(0)
   DECLARE numident2 = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE catalogcnt = i4 WITH protect, noconstant(size(temp->catalogs,5))
   DECLARE catalogtypecnt = i4 WITH protect, noconstant(size(temp->catalogtype,5))
   IF (catalogcnt=0)
    CALL echo("IdentifyOrders subroutine failed")
    CALL fillsubeventstatus("dcp_get_pip_orders_flt","F","IdentifyOrders",
     "Unable to get 'catalog_cd' from temp->catalogs.")
    SET failure_ind = 1
    GO TO failure
   ENDIF
   DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
   DECLARE incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
   DECLARE inproc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
   DECLARE medstudent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
   DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
   DECLARE pendingrv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
   DECLARE pendingc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
   DECLARE unsched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
   SELECT INTO "nl:"
    FROM orders o
    WHERE expand(numident1,1,perlistcnt,o.person_id,request->person_list[numident1].person_id)
     AND o.order_status_cd IN (future_cd, incomplete_cd, inproc_cd, medstudent_cd, ordered_cd,
    pendingrv_cd, pendingc_cd, unsched_cd)
     AND expand(numident2,1,catalogtypecnt,o.catalog_type_cd,temp->catalogtype[numident2].
     catalog_type_cd)
     AND ((o.template_order_id+ 0)=0)
     AND ((o.orig_ord_as_flag < 1) OR (o.orig_ord_as_flag > 2))
    ORDER BY o.order_id
    HEAD REPORT
     ordercnt = 0, idx = 0, numx = 0
    HEAD o.order_id
     idx = locateval(numx,1,catalogcnt,o.catalog_cd,temp->catalogs[numx].catalog_cd)
     IF (idx > 0)
      IF (band(o.cs_flag,1) != 1
       AND band(o.cs_flag,3) != 3)
       ordercnt = (ordercnt+ 1)
       IF (mod(ordercnt,100)=1)
        stat = alterlist(temp->orders,(ordercnt+ 99))
       ENDIF
       temp->orders[ordercnt].person_id = o.person_id, temp->orders[ordercnt].encntr_id = o.encntr_id,
       temp->orders[ordercnt].order_id = o.order_id,
       temp->orders[ordercnt].catalog_cd = o.catalog_cd, temp->orders[ordercnt].catalog_type_cd = o
       .catalog_type_cd, temp->orders[ordercnt].activity_type_cd = o.activity_type_cd,
       temp->orders[ordercnt].med_order_type_cd = o.med_order_type_cd, temp->orders[ordercnt].
       need_rx_verify_ind = o.need_rx_verify_ind, temp->orders[ordercnt].need_nurse_review_ind = o
       .need_nurse_review_ind,
       temp->orders[ordercnt].need_doctor_cosign_ind = o.need_doctor_cosign_ind, temp->orders[
       ordercnt].order_status_cd = o.order_status_cd, temp->orders[ordercnt].updt_id = o.updt_id,
       temp->orders[ordercnt].updt_dt_tm = cnvtdatetime(o.updt_dt_tm), temp->orders[ordercnt].
       hna_order_mnemonic = o.hna_order_mnemonic, temp->orders[ordercnt].order_mnemonic = o
       .order_mnemonic,
       temp->orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic, temp->orders[ordercnt].
       iv_ind = o.iv_ind, temp->orders[ordercnt].constant_ind = o.constant_ind,
       temp->orders[ordercnt].order_comment_ind = o.order_comment_ind, temp->orders[ordercnt].
       comment_type_mask = o.comment_type_mask, temp->orders[ordercnt].notify_display_line =
       IF (trim(o.clinical_display_line) > " ") o.clinical_display_line
       ELSE o.order_detail_display_line
       ENDIF
       IF (o.med_order_type_cd > 0)
        temp->med_order_cnt = (temp->med_order_cnt+ 1)
        IF (mod(temp->med_order_cnt,50)=1)
         stat = alterlist(temp->med_orders,(temp->med_order_cnt+ 49))
        ENDIF
        temp->med_orders[temp->med_order_cnt].order_id = o.order_id
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->orders,ordercnt), temp->order_cnt = ordercnt
    WITH nocounter, orahint("index(o XIE99ORDERS)"), expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*Leaving IdentifyOrders subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   IF (debugind=1)
    CALL echo("*Entering LoadOrderComments subroutine*")
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE numordcmt = i4 WITH protect, noconstant(0)
   DECLARE order_comment_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT")
    )
   DECLARE order_comment_mask = i4 WITH protect, constant(1)
   DECLARE order_cnt = i4 WITH protect, noconstant(size(temp->orders,5))
   IF (order_cnt=0)
    CALL echo("LoadOrderComments subroutine failed")
    CALL fillsubeventstatus("dcp_get_pip_orders_flt","F","LoadOrderComments",
     "Unable to get 'order_id' from temp->orders.")
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SELECT INTO "nl:"
    FROM order_comment oc,
     long_text lt
    PLAN (oc
     WHERE expand(numordcmt,1,order_cnt,oc.order_id,temp->orders[numordcmt].order_id)
      AND oc.comment_type_cd=order_comment_cd
      AND (oc.action_sequence=
     (SELECT
      max(oc2.action_sequence)
      FROM order_comment oc2
      WHERE oc2.order_id=oc.order_id
       AND oc2.comment_type_cd=order_comment_cd)))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY oc.order_id
    HEAD REPORT
     idx = 0, num = 0
    DETAIL
     idx = locateval(num,1,temp->order_cnt,oc.order_id,temp->orders[num].order_id), temp->orders[idx]
     .order_comment_text = lt.long_text
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*Leaving LoadOrderComments subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorderdetails(null)
   IF (debugind=1)
    CALL echo("*Entering LoadOrderDetails subroutine*")
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE idy = i4 WITH protect, noconstant(0)
   DECLARE numy = i4 WITH protect, noconstant(0)
   DECLARE numorddet = i4 WITH protect, noconstant(0)
   DECLARE orderdetail_cnt = i4 WITH constant(size(temp->orders,5))
   IF (orderdetail_cnt=0)
    CALL echo("LoadOrderDetails subroutine failed")
    CALL fillsubeventstatus("dcp_get_pip_orders_flt","F","LoadOrderDetails",
     "Unable to get 'order_id' from temp->orders.")
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SELECT INTO "nl:"
    FROM order_detail od
    WHERE expand(numorddet,1,orderdetail_cnt,od.order_id,temp->orders[numorddet].order_id)
    ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC,
     od.detail_sequence
    HEAD REPORT
     idx = 0, numx = 0, idy = 0,
     numy = 0
    HEAD od.order_id
     increment_detail = 0, idx = locateval(numx,1,temp->order_cnt,od.order_id,temp->orders[numx].
      order_id)
    HEAD od.oe_field_id
     increment_action = 0, idy = locateval(numy,1,temp->detail_cnt,od.oe_field_id,temp->details[numy]
      .oe_field_id)
    HEAD od.action_sequence
     IF (idy > 0
      AND idx > 0)
      increment_action = (increment_action+ 1)
     ENDIF
    HEAD od.detail_sequence
     IF (idy > 0
      AND idx > 0)
      IF (increment_action=1)
       increment_detail = (increment_detail+ 1)
       IF (mod(increment_detail,10)=1)
        stat = alterlist(temp->orders[idx].detail_list,(increment_detail+ 9))
       ENDIF
       temp->orders[idx].detail_list[increment_detail].oe_field_id = od.oe_field_id, temp->orders[idx
       ].detail_list[increment_detail].oe_field_value = od.oe_field_value, temp->orders[idx].
       detail_list[increment_detail].oe_field_meaning = od.oe_field_meaning,
       temp->orders[idx].detail_list[increment_detail].oe_field_meaning_id = od.oe_field_meaning_id,
       temp->orders[idx].detail_list[increment_detail].oe_field_dt_tm_value = od.oe_field_dt_tm_value,
       temp->orders[idx].detail_list[increment_detail].oe_field_display_value = od
       .oe_field_display_value
      ENDIF
     ENDIF
    FOOT  od.order_id
     IF (increment_detail > 0)
      temp->orders[idx].detail_cnt = increment_detail, stat = alterlist(temp->orders[idx].detail_list,
       increment_detail)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*Leaving LoadOrderDetails subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE determineadditivecnt(null)
   IF (debugind=1)
    CALL echo("*Entering DetermineAdditiveCnt subroutine*")
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE numaddcnt = i4 WITH protect, noconstant(0)
   DECLARE additive_cnt = i4 WITH constant(size(temp->med_order_cnt,5))
   IF (additive_cnt=0)
    CALL echo("DetermineAdditiveCnt subroutine failed")
    CALL fillsubeventstatus("dcp_get_pip_orders_flt","F","DetermineAdditiveCnt",
     "Unable to get 'order_id' from temp->med_order_cnt.")
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SELECT INTO "nl:"
    FROM order_ingredient oi
    WHERE expand(numaddcnt,1,additive_cnt,oi.order_id,temp->med_orders[numaddcnt].order_id)
     AND oi.ingredient_type_flag IN (1, 3)
    ORDER BY oi.order_id, oi.action_sequence
    HEAD REPORT
     idx = 0, numx = 0
    HEAD oi.order_id
     idx = locateval(numx,1,temp->order_cnt,oi.order_id,temp->orders[numx].order_id)
    HEAD oi.action_sequence
     additivecnt = 0
    DETAIL
     additivecnt = (additivecnt+ 1)
    FOOT  oi.order_id
     temp->orders[idx].additive_cnt = additivecnt
    WITH nocounter, expand = 1
   ;end select
   IF (debugind=1)
    CALL echo("*Leaving DetermineAdditiveCnt subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE sortordersbypatient(null)
   IF (debugind=1)
    CALL echo("*Entering SortOrdersByPatient subroutine*")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET stat = alterlist(temp->pat_orders,temp->order_cnt)
   SET temp->pat_orders[1].index = 1
   SET temp->pat_orders[1].person_id = temp->orders[1].person_id
   FOR (i = 1 TO temp->order_cnt)
     FOR (j = (i+ 1) TO temp->order_cnt)
      IF ((temp->pat_orders[j].index=0))
       SET temp->pat_orders[j].index = j
       SET temp->pat_orders[j].person_id = temp->orders[temp->pat_orders[j].index].person_id
      ENDIF
      IF ((temp->orders[temp->pat_orders[j].index].person_id < temp->orders[temp->pat_orders[i].index
      ].person_id))
       SET index = temp->pat_orders[i].index
       SET temp->pat_orders[i].index = temp->pat_orders[j].index
       SET temp->pat_orders[j].index = index
       SET temp->pat_orders[i].person_id = temp->orders[temp->pat_orders[i].index].person_id
       SET temp->pat_orders[j].person_id = temp->orders[temp->pat_orders[j].index].person_id
      ENDIF
     ENDFOR
   ENDFOR
   IF (debugind=1)
    CALL echo("*Leaving SortOrdersByPatient subroutine*")
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   IF (debugind=1)
    CALL echo("*Entering PopulateReply subroutine*")
   ENDIF
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE z = i4 WITH protect, noconstant(0)
   DECLARE patcnt = i4 WITH protect, noconstant(0)
   DECLARE ordcnt = i4 WITH protect, noconstant(0)
   DECLARE patid = f8 WITH protect, noconstant(0.0)
   IF ((temp->order_cnt > 0))
    CALL sortordersbypatient(null)
   ENDIF
   SET stat = alterlist(reply->person_list,size(request->person_list,5))
   FOR (z = 1 TO temp->order_cnt)
     SET x = temp->pat_orders[z].index
     IF ((temp->orders[x].person_id != patid))
      IF (patcnt != 0
       AND ordcnt != 0)
       SET stat = alterlist(reply->person_list[patcnt].order_list,ordcnt)
      ENDIF
      SET patid = temp->orders[x].person_id
      SET patcnt = (patcnt+ 1)
      SET reply->person_list[patcnt].person_id = patid
      SET ordcnt = 0
     ENDIF
     SET ordcnt = (ordcnt+ 1)
     IF (mod(ordcnt,5)=1)
      SET stat = alterlist(reply->person_list[patcnt].order_list,(ordcnt+ 4))
     ENDIF
     SET reply->person_list[patcnt].order_list[ordcnt].order_id = temp->orders[x].order_id
     SET reply->person_list[patcnt].order_list[ordcnt].encntr_id = temp->orders[x].encntr_id
     SET reply->person_list[patcnt].order_list[ordcnt].catalog_cd = temp->orders[x].catalog_cd
     SET reply->person_list[patcnt].order_list[ordcnt].catalog_type_cd = temp->orders[x].
     catalog_type_cd
     SET reply->person_list[patcnt].order_list[ordcnt].activity_type_cd = temp->orders[x].
     activity_type_cd
     SET reply->person_list[patcnt].order_list[ordcnt].med_order_type_cd = temp->orders[x].
     med_order_type_cd
     SET reply->person_list[patcnt].order_list[ordcnt].need_rx_verify_ind = temp->orders[x].
     need_rx_verify_ind
     SET reply->person_list[patcnt].order_list[ordcnt].need_nurse_review_ind = temp->orders[x].
     need_nurse_review_ind
     SET reply->person_list[patcnt].order_list[ordcnt].need_doctor_cosign_ind = temp->orders[x].
     need_doctor_cosign_ind
     SET reply->person_list[patcnt].order_list[ordcnt].order_status_cd = temp->orders[x].
     order_status_cd
     SET reply->person_list[patcnt].order_list[ordcnt].notify_display_line = temp->orders[x].
     notify_display_line
     SET reply->person_list[patcnt].order_list[ordcnt].hna_order_mnemonic = temp->orders[x].
     hna_order_mnemonic
     SET reply->person_list[patcnt].order_list[ordcnt].order_mnemonic = temp->orders[x].
     order_mnemonic
     SET reply->person_list[patcnt].order_list[ordcnt].ordered_as_mnemonic = temp->orders[x].
     ordered_as_mnemonic
     SET reply->person_list[patcnt].order_list[ordcnt].iv_ind = temp->orders[x].iv_ind
     SET reply->person_list[patcnt].order_list[ordcnt].constant_ind = temp->orders[x].constant_ind
     SET reply->person_list[patcnt].order_list[ordcnt].order_comment_ind = temp->orders[x].
     order_comment_ind
     SET reply->person_list[patcnt].order_list[ordcnt].comment_type_mask = temp->orders[x].
     comment_type_mask
     SET reply->person_list[patcnt].order_list[ordcnt].order_comment_text = temp->orders[x].
     order_comment_text
     SET reply->person_list[patcnt].order_list[ordcnt].updt_dt_tm = temp->orders[x].updt_dt_tm
     SET reply->person_list[patcnt].order_list[ordcnt].updt_id = temp->orders[x].updt_id
     SET reply->person_list[patcnt].order_list[ordcnt].additive_cnt = temp->orders[x].additive_cnt
     SET stat = alterlist(reply->person_list[patcnt].order_list[ordcnt].detail_list,temp->orders[x].
      detail_cnt)
     FOR (y = 1 TO temp->orders[x].detail_cnt)
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_id = temp->orders[x]
       .detail_list[y].oe_field_id
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_value = temp->
       orders[x].detail_list[y].oe_field_value
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_meaning = temp->
       orders[x].detail_list[y].oe_field_meaning
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_meaning_id = temp->
       orders[x].detail_list[y].oe_field_meaning_id
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_dt_tm_value = temp->
       orders[x].detail_list[y].oe_field_dt_tm_value
       SET reply->person_list[patcnt].order_list[ordcnt].detail_list[y].oe_field_display_value = temp
       ->orders[x].detail_list[y].oe_field_display_value
     ENDFOR
   ENDFOR
   IF (patcnt > 0)
    SET stat = alterlist(reply->person_list[patcnt].order_list,ordcnt)
   ENDIF
   SET stat = alterlist(reply->person_list,patcnt)
   IF (debugind=1)
    CALL echo("*Leaving PopulateReply subroutine*")
   ENDIF
 END ;Subroutine
#failure
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","dcp_get_pip_orders_flt",serrormsg)
  SET reply->status_data.status = "F"
 ELSEIF (failure_ind=1)
  SET reply->status_data.status = "F"
 ELSEIF ((temp->order_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "005 10/29/2012"
 IF (debugind=1)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(build("Script Version: ",script_version))
 ELSE
  FREE RECORD temp
 ENDIF
 SET modify = nopredeclare
END GO
