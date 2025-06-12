CREATE PROGRAM dcp_get_cki_drug_categories:dba
 SET modify = predeclare
 RECORD reply(
   1 target_category = f8
   1 qual[*]
     2 dnum = vc
     2 category_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD category_request(
   1 all_categories = i2
   1 level = i2
   1 items[*]
     2 category_id = f8
 )
 RECORD category_reply(
   1 qual[*]
     2 category_id = f8
     2 category_name = vc
     2 child_id = f8
     2 child_name = vc
     2 level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE loadcategories(null) = null WITH protect
 DECLARE loadcategoriesfromtarget(null) = null WITH protect
 DECLARE loadmmdcs(null) = null WITH protect
 DECLARE loaddrugidsformmdc(null) = null WITH protect
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE nqualcnt = i4 WITH noconstant(0)
 DECLARE startidx = i4 WITH noconstant(0)
 DECLARE endidx = i4 WITH noconstant(0)
 DECLARE itemidx = i4 WITH noconstant(0)
 DECLARE status = i4 WITH noconstant(0)
 DECLARE cm = c1 WITH constant("m")
 DECLARE cckidnum = c8 WITH constant("MUL.ORD!")
 DECLARE cckimmdc = c9 WITH constant("MUL.MMDC!")
 DECLARE ncount = i4 WITH noconstant(0)
 IF ((request->target_category > 0.0))
  CALL loadcategoriesfromtarget(null)
 ELSE
  CALL loadmmdcs(null)
  CALL loadcategories(null)
 ENDIF
 FREE RECORD mmdc
 FREE RECORD category_request
 FREE RECORD category_reply
 SUBROUTINE loadcategoriesfromtarget(null)
   SET reply->status_data.status = "F"
   SET category_request->all_categories = 2
   SET category_request->level = 1
   SET status = alterlist(category_request->items,1)
   SET category_request->items[1].category_id = request->target_category
   EXECUTE dcp_get_drug_categories  WITH replace("REQUEST","CATEGORY_REQUEST"), replace("REPLY",
    "CATEGORY_REPLY")
   IF ((category_reply->status_data.status="F"))
    RETURN
   ELSEIF ((category_reply->status_data.status="Z"))
    SET reply->status_data.status = "Z"
    RETURN
   ENDIF
   SELECT DISTINCT INTO "nl:"
    xref.multum_category_id, xref.drug_identifier, mmdc.main_multum_drug_code
    FROM mltm_category_drug_xref xref,
     mltm_ndc_main_drug_code mmdc
    PLAN (xref
     WHERE expand(ncount,1,size(category_reply->qual,5),xref.multum_category_id,category_reply->qual[
      ncount].category_id))
     JOIN (mmdc
     WHERE outerjoin(xref.drug_identifier)=mmdc.drug_identifier)
    ORDER BY xref.multum_category_id, xref.drug_identifier
    HEAD REPORT
     nqualcnt = 0, reply->target_category = request->target_category
    HEAD xref.drug_identifier
     IF (xref.drug_identifier != "")
      nqualcnt = (nqualcnt+ 1)
      IF (mod(nqualcnt,10)=1)
       status = alterlist(reply->qual,(nqualcnt+ 9))
      ENDIF
      reply->qual[nqualcnt].category_id = xref.multum_category_id, reply->qual[nqualcnt].dnum =
      concat(cckidnum,xref.drug_identifier)
     ENDIF
    DETAIL
     IF (mmdc.main_multum_drug_code > 0)
      nqualcnt = (nqualcnt+ 1)
      IF (mod(nqualcnt,10)=1)
       status = alterlist(reply->qual,(nqualcnt+ 9))
      ENDIF
      reply->qual[nqualcnt].category_id = xref.multum_category_id, reply->qual[nqualcnt].dnum =
      concat(cckimmdc,cnvtstring(mmdc.main_multum_drug_code))
     ENDIF
    FOOT REPORT
     status = alterlist(reply->qual,nqualcnt)
    WITH nocounter
   ;end select
   IF (nqualcnt=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE loadcategories(null)
   SET reply->status_data.status = "F"
   DECLARE ireqcnt = i4 WITH protect, noconstant(size(request->items,5))
   DECLARE dreqdnumidx = i4 WITH protect, noconstant(0)
   DECLARE ireqit = i4 WITH protect, noconstant(0)
   DECLARE curmmdc = vc WITH protect, noconstant("")
   DECLARE icount = i4 WITH protect, constant(size(request->items,5))
   IF (ireqcnt > 0)
    SELECT INTO "nl:"
     FROM mltm_category_drug_xref xref
     PLAN (xref
      WHERE expand(itemidx,1,size(request->items,5),xref.drug_identifier,request->items[itemidx].dnum
       ))
     ORDER BY xref.drug_identifier, xref.multum_category_id
     HEAD REPORT
      nqualcnt = 0
     HEAD xref.drug_identifier
      curmmdc = "", dreqdnumidx = locateval(ireqit,1,ireqcnt,xref.drug_identifier,request->items[
       ireqit].dnum)
      IF (dreqdnumidx > 0)
       curmmdc = request->items[dreqdnumidx].mmdc
      ENDIF
     HEAD xref.multum_category_id
      nqualcnt = (nqualcnt+ 1)
      IF (nqualcnt > size(reply->qual,5))
       status = alterlist(reply->qual,(nqualcnt+ 5))
      ENDIF
      reply->qual[nqualcnt].category_id = xref.multum_category_id
      IF (curmmdc != "")
       reply->qual[nqualcnt].dnum = curmmdc
      ELSE
       reply->qual[nqualcnt].dnum = xref.drug_identifier
      ENDIF
      IF (curmmdc != "")
       FOR (immdccount = 1 TO icount)
         IF ((request->items[immdccount].mmdc != curmmdc)
          AND (request->items[immdccount].dnum=xref.drug_identifier))
          nqualcnt = (nqualcnt+ 1)
          IF (nqualcnt > size(reply->qual,5))
           status = alterlist(reply->qual,(nqualcnt+ 5))
          ENDIF
          reply->qual[nqualcnt].category_id = xref.multum_category_id, reply->qual[nqualcnt].dnum =
          request->items[immdccount].mmdc
         ENDIF
       ENDFOR
      ENDIF
     FOOT REPORT
      status = alterlist(reply->qual,nqualcnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (nqualcnt=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE loadmmdcs(null)
   DECLARE itemcount = i4 WITH private, constant(size(request->items,5))
   DECLARE mmdccount = i4 WITH private, noconstant(0)
   RECORD mmdc(
     1 items[*]
       2 mmdc = i4
       2 item_idx = i2
   )
   IF (itemcount > 0)
    FOR (mcount = 1 TO itemcount)
      IF (cm=substring(1,1,request->items[mcount].dnum))
       SET mmdccount = (mmdccount+ 1)
       SET status = alterlist(mmdc->items,mmdccount)
       SET mmdc->items[mmdccount].mmdc = cnvtint(substring(2,size(request->items[mcount].dnum,1),
         request->items[mcount].dnum))
       SET mmdc->items[mmdccount].item_idx = mcount
      ENDIF
    ENDFOR
    IF (size(mmdc->items,5) > 0)
     CALL loaddrugidsformmdc(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddrugidsformmdc(null)
   DECLARE mmdcidx = i4 WITH protect, noconstant(0)
   DECLARE reqidx = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET reply->status_data.status = "F"
   SELECT INTO "nl:"
    mmdc.drug_identifier
    FROM mltm_ndc_main_drug_code mmdc
    PLAN (mmdc
     WHERE expand(mmdcidx,1,size(mmdc->items,5),mmdc.main_multum_drug_code,mmdc->items[mmdcidx].mmdc)
     )
    ORDER BY mmdc.main_multum_drug_code
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), reqidx = locateval(x,1,size(mmdc->items,5),mmdc.main_multum_drug_code,mmdc->
      items[x].mmdc), request->items[mmdc->items[reqidx].item_idx].dnum = mmdc.drug_identifier,
     request->items[mmdc->items[reqidx].item_idx].mmdc = concat("m",cnvtstring(mmdc
       .main_multum_drug_code))
    WITH nocounter
   ;end select
   IF (cnt=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SET last_mod = "003"
 SET modify = nopredeclare
END GO
