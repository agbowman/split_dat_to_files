CREATE PROGRAM ayb_rx_rtform_rule:dba
 RECORD orders(
   1 orderlist[*]
     2 route_cd = f8
     2 route_disp = vc
     2 form_cd = f8
     2 form_disp = vc
 )
 DECLARE msg = vc WITH protect
 DECLARE ordercnt = i2 WITH protect, noconstant(0)
 DECLARE detailcnt = i2 WITH protect, noconstant(0)
 DECLARE oidx = i2 WITH protect, noconstant(0)
 DECLARE detidx = i2 WITH protect, noconstant(0)
 DECLARE resp_txt_cnt = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE routefound = i2 WITH protect, noconstant(0)
 DECLARE formfound = i2 WITH protect, noconstant(0)
 DECLARE orderable = vc WITH protect
 DECLARE msgfound = i2 WITH protect, noconstant(0)
 DECLARE errormsg = vc WITH protect
 DECLARE save_oidx = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE requestindex = i2 WITH protect, noconstant(0)
 DECLARE miscindex = i2 WITH protect, noconstant(0)
 DECLARE lastrequestindex = i2 WITH protect, noconstant(0)
 DECLARE dupfound = i2 WITH protect, noconstant(0)
 DECLARE multiingred = i2 WITH protect, noconstant(0)
 DECLARE ingredcnt = i2
 DECLARE ingredidx = i2
 DECLARE ingredorderable = vc WITH protect
 SET retval = 0
 SET msg = fillstring(100," ")
 SET x = validate(eksrequest)
 IF (x=0)
  SET retval = 10
  SET msg = "Request does not exist, no compatibility checking can be done."
  GO TO exit_program
 ENDIF
 IF (eksrequest != 3072006)
  SET retval = 10
  SET msg = "Request does not equal 3072006, no compatibility checking can be done."
  GO TO exit_program
 ENDIF
 CALL echo(build("link_template is ",link_template))
 IF (link_template > 0)
  IF ((eksdata->tqual[3].qual[link_template].data[1].misc != "<SPINDEX>"))
   SET retval = 1
   GO TO exit_program
  ENDIF
  IF (link_template > curindex)
   SET retval = 10
   SET msg = concat("This template has been linked to another template after this one. ",
    "Please link to a template that comes before.")
   GO TO exit_program
  ENDIF
 ENDIF
 SET ordercnt = size(request->orderlist,5)
 CALL echo(build("OrderCnt is ",ordercnt))
 IF (ordercnt=0)
  SET retval = 10
  SET msg = "There are no orders found in the request."
  GO TO exit_program
 ENDIF
 SET stat = alterlist(orders->orderlist,value(ordercnt))
 SET resp_txt_cnt = 0
 SET lastrequestindex = 0
 SET oidx = 1
 SET miscindex = 1
 IF (link_template > 0)
  SET ordercnt = (size(eksdata->tqual[3].qual[link_template].data,5) - 1)
  CALL echo(build("OrderCnt from link_template is ",ordercnt))
 ENDIF
 WHILE (oidx <= ordercnt)
   SET msgfound = 0
   SET routefound = 0
   SET formfound = 0
   SET dupfound = 0
   IF (link_template > 0)
    SET miscindex = (miscindex+ 1)
    CALL echo(build("miscIndex : ",miscindex))
    SET dupfound = 1
    WHILE (dupfound=1)
      IF ((miscindex <= (eksdata->tqual[3].qual[link_template].cnt+ 1)))
       SET stringfound = findstring(":",eksdata->tqual[3].qual[link_template].data[miscindex].misc)
       IF (stringfound=0)
        SET requestindex = cnvtint(cnvtalphanum(eksdata->tqual[3].qual[link_template].data[miscindex]
          .misc))
       ELSE
        SET requestindex = cnvtint(cnvtalphanum(substring(1,(stringfound - 1),eksdata->tqual[3].qual[
           link_template].data[miscindex].misc)))
       ENDIF
       IF (lastrequestindex=0)
        SET lastrequestindex = requestindex
        SET dupfound = 0
       ELSE
        IF (requestindex=lastrequestindex)
         SET miscindex = (miscindex+ 1)
        ELSE
         SET dupfound = 0
        ENDIF
        SET lastrequestindex = requestindex
       ENDIF
      ELSE
       GO TO exit_program
      ENDIF
    ENDWHILE
   ELSE
    SET requestindex = oidx
   ENDIF
   SET ingredcnt = size(request->orderlist[requestindex].ingredientlist,5)
   IF (ingredcnt > 1)
    SET multiingred = 1
    FOR (ingredidx = 1 TO ingredcnt)
      SET ingredorderable = uar_get_code_display(request->orderlist[requestindex].ingredientlist[
       ingredidx].catalogcd)
      CALL echo(build("Ingred",ingredorderable))
      IF (ingredidx=1)
       SET orderable = concat("		",ingredorderable)
      ELSE
       SET orderable = concat(orderable,"@NEWLINE		",ingredorderable)
      ENDIF
    ENDFOR
   ELSE
    SET multiingred = 0
   ENDIF
   CALL echo(build("requestIndex is ",requestindex))
   SET detailcnt = size(request->orderlist[requestindex].detaillist,5)
   FOR (detidx = 1 TO detailcnt)
     IF ((request->orderlist[requestindex].detaillist[detidx].oefieldmeaning="RXROUTE"))
      IF ((request->orderlist[requestindex].detaillist[detidx].oefieldvalue > 0))
       SET orders->orderlist[oidx].route_cd = request->orderlist[requestindex].detaillist[detidx].
       oefieldvalue
       SET orders->orderlist[oidx].route_disp = uar_get_code_display(orders->orderlist[oidx].route_cd
        )
       SET routefound = 1
      ENDIF
     ENDIF
     IF ((request->orderlist[requestindex].detaillist[detidx].oefieldmeaning="DRUGFORM"))
      SET orders->orderlist[oidx].form_cd = request->orderlist[requestindex].detaillist[detidx].
      oefieldvalue
      SET orders->orderlist[oidx].form_disp = uar_get_code_display(orders->orderlist[oidx].form_cd)
      SET formfound = 1
     ENDIF
     IF (routefound=1
      AND formfound=1)
      SET detidx = detailcnt
     ENDIF
   ENDFOR
   IF (multiingred=0)
    SET orderable = uar_get_code_display(request->orderlist[requestindex].catalog_code)
   ENDIF
   IF ((orders->orderlist[oidx].route_cd > 0)
    AND (orders->orderlist[oidx].form_cd > 0))
    SELECT INTO "NL:"
     FROM route_form_r r
     WHERE (r.form_cd=orders->orderlist[oidx].form_cd)
      AND (r.route_cd=orders->orderlist[oidx].route_cd)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET msgfound = 1
     IF (multiingred=1)
      SET errormsg = concat("The multi-ingredient order that contains the drugs: @NEWLINE",build(
        orderable),"@NEWLINE","Has a route of ",orders->orderlist[oidx].route_disp,
       " and a dosage form of ",orders->orderlist[oidx].form_disp,", which are not compatible.")
     ELSE
      SET errormsg = concat("The order for ",build(orderable)," drug ","contains ",orders->orderlist[
       oidx].route_disp,
       " route and ",orders->orderlist[oidx].form_disp," dosage form, which are not compatible.")
     ENDIF
    ENDIF
   ELSEIF ((orders->orderlist[oidx].route_cd > 0)
    AND (orders->orderlist[oidx].form_cd=0))
    SET msgfound = 1
    IF (multiingred=1)
     SET msgfound = 0
    ELSE
     SET errormsg = concat("The order for ",build(orderable),
      " drug does not have a dosage form  - cannot perform Route/Form ","Compatibility check.")
    ENDIF
   ELSEIF ((orders->orderlist[oidx].route_cd=0)
    AND (orders->orderlist[oidx].form_cd > 0))
    SET msgfound = 1
    IF (multiingred=1)
     SET errormsg = concat("The multi-ingredient order that contains the drugs: @NEWLINE",build(
       orderable),"@NEWLINE","Does not have a route - cannot perform Route/Form Compatibility check."
      )
    ELSE
     SET errormsg = concat("The order for ",build(orderable),
      " drug does not have a route - cannot perform Route/Form Compatibility check.")
    ENDIF
   ELSEIF ((orders->orderlist[oidx].route_cd=0)
    AND (orders->orderlist[oidx].form_cd=0))
    SET msgfound = 1
    IF (multiingred=1)
     SET errormsg = concat("The multi-ingredient order that contains the drugs: @NEWLINE",build(
       orderable),"@NEWLINE",
      "Does not have a route or a dosage form - cannot perform Route/Form Compatibility check.")
    ELSE
     SET errormsg = concat("The order for ",build(orderable),
      " drug does not have a route or a dosage form - cannot perform Route/Form Compatibility check."
      )
    ENDIF
   ENDIF
   IF (msgfound=1)
    SET save_oidx = 0
    SET retval = 100
    SET idx_str = concat(trim(cnvtstring(requestindex)),"|")
    IF (resp_txt_cnt=0)
     SET resp_txt_cnt = (resp_txt_cnt+ 1)
     SET stat = alterlist(eksdata->tqual[3].qual[curindex].data,resp_txt_cnt)
     SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = "<SPINDEX>"
    ENDIF
    SET resp_txt_cnt = (resp_txt_cnt+ 1)
    SET stat = alterlist(eksdata->tqual[3].qual[curindex].data,resp_txt_cnt)
    IF (oidx != save_oidx)
     SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = idx_str
     SET save_oidx = oidx
    ENDIF
    SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = concat(eksdata->tqual[3].qual[
     curindex].data[resp_txt_cnt].misc,errormsg)
   ENDIF
   SET requestindex = (requestindex+ 1)
   SET oidx = (oidx+ 1)
 ENDWHILE
#exit_program
 IF (retval=1)
  SET retval = 0
  SET msg = "There are no orders from linked template to check."
 ELSEIF (retval=10)
  SET retval = 0
 ELSEIF (retval=100)
  SET msg = "The Route and Dosage Form check was not successful."
 ELSE
  SET retval = 0
  SET msg = "Route and Dosage Form are compatible."
 ENDIF
 SET eksdata->tqual[3].qual[curindex].logging = msg
 SET eksdata->tqual[3].qual[curindex].cnt = resp_txt_cnt
 SET eksdata->tqual[3].qual[curindex].person_id = request->person_id
 SET eksdata->tqual[3].qual[curindex].encntr_id = request->encntr_id
 CALL echo(build("retval:",retval))
 CALL echo(build("resp_txt_cnt:",resp_txt_cnt))
 FOR (x = 1 TO resp_txt_cnt)
   CALL echo(build("text:",eksdata->tqual[3].qual[curindex].data[x].misc))
 ENDFOR
END GO
