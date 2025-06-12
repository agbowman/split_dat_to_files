CREATE PROGRAM bhs_eks_find_med_on_list:dba
 PROMPT
  "List:" = "",
  "synnonym_id" = 0.0,
  "catalogCd" = 0.0,
  "Output to File/Printer/MINE" = "MINE",
  "call action:" = ""
  WITH list, synonymid, catalogcd,
  outdev, action
 DECLARE mf_remifentanil_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "REMIFENTANIL"))
 DECLARE mf_order_cat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mn_bfmc_ind = i2 WITH protect, noconstant(0)
 DECLARE log_message = vc WITH noconstant(" "), public
 DECLARE log_misc = vc WITH noconstant(" "), public
 DECLARE encntrid = f8 WITH noconstant(0.0), protect
 DECLARE list = vc WITH noconstant(" "), protect
 DECLARE founditem = i4 WITH noconstant(0)
 DECLARE sz = i4 WITH noconstant(0)
 DECLARE listvals = vc WITH noconstant(" "), protect
 DECLARE tempval = vc WITH noconstant(" "), protect
 SET retval = 0
 FREE RECORD temprequest
 RECORD temprequest(
   1 orderlist[*]
     2 orderid = f8
     2 narcoticorder = i2
     2 ingredientlist[*]
       3 synonymid = f8
       3 catalogcd = f8
 )
 SET log_message = concat(log_message,
  "this script will check the incoming admin meds to see exist on the Narcotics list tables",
  " if they do then it will execute another script and rule to check for the narcotics tasks. if the tasks",
  " Don't already exist they will be ordered.")
 SET log_message = concat(log_message,"-parse list types passed down")
 SET x = 0
 SET listvals = "ocs.list_key in ("
 SET opt_list_type = replace( $LIST,"'","")
 WHILE (x < 100
  AND x != 100)
   SET x = (x+ 1)
   SET tempval = piece(opt_list_type,"|",x,"1",0)
   IF (tempval="1"
    AND x=1)
    SET listvals = build(listvals,"'",trim(opt_list_type,3),"'")
   ELSEIF (tempval != "1")
    IF (x > 1)
     SET listvals = build(listvals,",")
    ENDIF
    SET listvals = build(listvals,"'",trim(tempval,3),"'")
   ELSE
    SET x = 100
   ENDIF
 ENDWHILE
 SET listvals = replace(listvals,"''","'")
 SET listvals = build(listvals,")")
 CALL echo(listvals)
 SET log_message = concat(log_message,"-List types passed down (in Parser:",listvals)
 IF (( $SYNONYMID > 0))
  SET log_message = concat(log_message,"SynonymId passed in:",build( $SYNONYMID))
  SET stat = alterlist(temprequest->orderlist,1)
  SET stat = alterlist(temprequest->orderlist[1].ingredientlist,1)
  SET temprequest->orderlist[1].ingredientlist[1].synonymid =  $SYNONYMID
  SET temprequest->orderlist[1].ingredientlist[1].catalogcd =  $CATALOGCD
 ELSEIF (validate(request->orderlist[1].synonymid))
  SET log_message = concat(log_message,"-order rule - parse and flatten Request->orderList")
  SET stat = alterlist(temprequest->orderlist,size(request->orderlist,5))
  SET newlistsize = 0
  SET log_message = concat(log_message," size(request->OrderList,5)",build(size(request->orderlist,5)
    ))
  FOR (x = 1 TO size(request->orderlist,5))
    SET temprequest->orderlist[x].orderid = request->orderlist[x].orderid
    SET log_message = concat(log_message," request->orderList[x].orderid",build(request->orderlist[x]
      .orderid))
    SET orglistsize = size(request->orderlist[x].subcomponentlist,5)
    SET log_message = concat(log_message," orgListSize:",build(orglistsize))
    IF (orglistsize >= 0)
     FOR (y = 1 TO orglistsize)
       SET stat = alterlist(temprequest->orderlist[x].ingredientlist,orglistsize)
       SET temprequest->orderlist[x].ingredientlist[y].catalogcd = request->orderlist[x].
       subcomponentlist[y].sccatalogcd
       SET temprequest->orderlist[x].ingredientlist[y].synonymid = request->orderlist[x].
       subcomponentlist[y].scsynonymid
       SET log_message = concat(log_message," request->OrderList[x].subcomponentlist[y].SCSYNONYMID:",
        build(request->orderlist[x].subcomponentlist[y].scsynonymid))
     ENDFOR
    ENDIF
  ENDFOR
 ELSEIF (validate(request->clin_detail_list[1].event_id))
  SET log_message = concat(log_message," sizeClinDetailList:",build(size(request->clin_detail_list,5)
    ))
  SET log_message = concat(log_message,
   "locate the synonym_ids from events and store them in tempRequest")
  SELECT
   o.order_id, oi.synonym_id
   FROM orders o,
    order_ingredient oi,
    (dummyt d  WITH seq = size(request->clin_detail_list,5))
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->clin_detail_list[d.seq].order_id))
    JOIN (oi
    WHERE ((o.template_order_id > 0
     AND oi.order_id=o.template_order_id
     AND oi.action_sequence=1) OR (o.template_order_id <= 0
     AND oi.order_id=o.order_id
     AND oi.action_sequence=1)) )
   ORDER BY o.order_id, oi.synonym_id
   HEAD REPORT
    x = 0
   HEAD o.order_id
    x = (x+ 1), stat = alterlist(temprequest->orderlist,x), y = 0
   HEAD oi.synonym_id
    y = (y+ 1), stat = alterlist(temprequest->orderlist[x].ingredientlist,y), temprequest->orderlist[
    x].orderid = o.order_id,
    temprequest->orderlist[x].ingredientlist[y].catalogcd = oi.catalog_cd, temprequest->orderlist[x].
    ingredientlist[y].synonymid = oi.synonym_id, log_message = concat(log_message,"  syn: ",build(
      temprequest->orderlist[x].ingredientlist[y].synonymid))
   WITH nocounter
  ;end select
  SET log_message = concat(log_message," curqual:",build(curqual))
  SET log_message = concat(log_message," request->clin->ordid:",build(request->clin_detail_list[1].
    order_id))
 ENDIF
 SET log_message = concat(log_message," size TempRequest:",build(size(temprequest->orderlist,5)))
 SET log_message = concat(log_message,build(" tempreqsynonid: ",build(temprequest->orderlist[1].
    ingredientlist[1].synonymid)))
 CALL echorecord(temprequest)
 SET log_message = concat(log_message," --locating catCd or SynId on list table")
 CALL echo(log_message)
 SELECT INTO  $OUTDEV
  d.seq, d1.seq
  FROM bhs_ordcatsyn_list ocs,
   (dummyt d  WITH seq = size(temprequest->orderlist,5)),
   (dummyt d1  WITH seq = 1),
   dummyt dout
  PLAN (d
   WHERE maxrec(d1,size(temprequest->orderlist[d.seq].ingredientlist,5)))
   JOIN (d1)
   JOIN (dout)
   JOIN (ocs
   WHERE parser(listvals)
    AND (((ocs.catalog_cd=temprequest->orderlist[d.seq].ingredientlist[d1.seq].catalogcd)) OR (ocs
   .catalog_cd=0))
    AND (((ocs.synonym_id=temprequest->orderlist[d.seq].ingredientlist[d1.seq].synonymid)) OR (ocs
   .synonym_id=0))
    AND ((ocs.synonym_id+ ocs.catalog_cd) > 0)
    AND ocs.active_ind=1)
  ORDER BY d.seq, d1.seq
  HEAD REPORT
   ordcnt = 1, tcurindex = 3
  HEAD d.seq
   stat = 0, orderadded = 0
  HEAD d1.seq
   stat = 0
  DETAIL
   log_message = concat(log_message,"--Inside select comparing values: ",build(ocs.synonym_id))
   IF (((ocs.catalog_cd+ ocs.synonym_id) > 0)
    AND orderadded=0)
    orderadded = 1, ordcnt = (ordcnt+ 1), founditem = 1,
    retval = 100, temprequest->orderlist[d.seq].narcoticorder = 1
   ENDIF
  WITH outerjoin = dout
 ;end select
 SET log_message = concat(log_message," curqual:",build(curqual))
 IF (( $ACTION="ADD"))
  IF (founditem=0)
   SET log_message = concat(log_message,"--No Rows Found")
   GO TO exit_program
  ELSE
   SET log_message = concat(log_message,
    "--Rows Found. executing script to call timer rules to place tasks")
   FOR (x = 1 TO size(temprequest->orderlist,5))
     IF ((temprequest->orderlist[x].narcoticorder=1))
      IF (findstring("NARCOTICORDERS",cnvtupper( $LIST)) > 0)
       SELECT INTO "nl:"
        FROM orders o
        WHERE (o.order_id=temprequest->orderlist[x].orderid)
        HEAD o.order_id
         mf_order_cat_cd = o.catalog_cd, encntrid = o.encntr_id
        WITH nocounter
       ;end select
       IF (mf_order_cat_cd=mf_remifentanil_cat_cd)
        SELECT INTO "nl:"
         FROM encounter e
         WHERE e.encntr_id=encntrid
         HEAD e.encntr_id
          IF (trim(uar_get_code_display(e.loc_facility_cd))="BFMC")
           mn_bfmc_ind = 1
          ENDIF
         WITH nocounter
        ;end select
        IF (mn_bfmc_ind=1)
         SET log_message = concat(log_message,
          " calling script to execute rule BHS_ASY_NARC_TASK_ORDER")
         EXECUTE bhs_syn_narctask_place_order temprequest->orderlist[x].orderid,
         "bhs_asy_narc_task_order"
        ELSE
         SET log_message = concat(log_message,"; for Remifentanil only execute for BFMC")
        ENDIF
       ELSE
        SET log_message = concat(log_message,
         " calling script to execute rule BHS_ASY_NARC_TASK_ORDER")
        EXECUTE bhs_syn_narctask_place_order temprequest->orderlist[x].orderid,
        "bhs_asy_narc_task_order"
       ENDIF
      ELSEIF (findstring("CONCENTRATED",cnvtupper( $LIST)) > 0)
       SET log_message = concat(log_message,
        " calling script to execute rule BHS_ASY_NARC_TASK_KCLORD")
       EXECUTE bhs_syn_narctask_place_order temprequest->orderlist[x].orderid,
       "bhs_asy_narc_task_kclord"
      ELSEIF (findstring("PATCH",cnvtupper( $LIST)) > 0)
       SET log_message = concat(log_message,
        " calling script to execute rule BHS_ASY_NARC_TASK_PCHORD")
       EXECUTE bhs_syn_narctask_place_order temprequest->orderlist[x].orderid,
       "bhs_asy_narc_task_pchord"
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_program
 CALL echo("Records")
 CALL echorecord(request)
 CALL echorecord(eksdata)
 CALL echo(log_message)
 CALL echo(log_misc)
END GO
