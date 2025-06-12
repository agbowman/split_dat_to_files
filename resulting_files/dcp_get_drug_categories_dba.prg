CREATE PROGRAM dcp_get_drug_categories:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 ENDIF
 RECORD tempcategories(
   1 qual[*]
     2 category_id = f8
     2 category_name = vc
     2 child_id = f8
     2 child_name = vc
 )
 RECORD querylist(
   1 qual[*]
     2 category_id = f8
 )
 DECLARE loadcategoriesfromlist(null) = null WITH protect
 DECLARE loadsubcategoriesfromlist(null) = null WITH protect
 DECLARE loadgrandparents(null) = null WITH protect
 DECLARE loadcategoriesfromlist(null) = null WITH protect
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE itemcount = i4 WITH noconstant(0)
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE nlastidx = i4 WITH noconstant(0)
 DECLARE nqueryidx = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET itemcount = size(request->items,5)
 SET qualcnt = 0
 IF ((request->all_categories=1))
  CALL loadallcategories(null)
 ELSEIF ((request->all_categories=2))
  CALL loadsubcategoriesfromlist(null)
 ELSEIF ((request->level=0))
  CALL loadgrandparents(null)
 ELSE
  CALL loadcategoriesfromlist(null)
 ENDIF
 IF (qualcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD tempcategories
 FREE RECORD querylist
 SUBROUTINE loadsubcategoriesfromlist(null)
   SET qualcnt = 0
   SET nlastidx = 0
   SET nqueryidx = 0
   FOR (nqueryidx = 1 TO size(request->items,5))
    IF (mod(nqueryidx,5)=1)
     SET stat = alterlist(querylist->qual,(nqueryidx+ 4))
    ENDIF
    SET querylist->qual[nqueryidx].category_id = request->items[nqueryidx].category_id
   ENDFOR
   SET stat = alterlist(querylist->qual,nqueryidx)
   WHILE (nqueryidx > 0)
     CALL echo("Child Loop")
     SET stat = alterlist(tempcategories->qual,0)
     SELECT INTO "nl:"
      c.multum_category_id, c.category_name, xref.sub_category_id,
      c1.category_name
      FROM mltm_drug_categories c,
       mltm_category_sub_xref xref,
       mltm_drug_categories c1
      PLAN (c
       WHERE expand(ncnt,1,nqueryidx,c.multum_category_id,querylist->qual[ncnt].category_id))
       JOIN (xref
       WHERE outerjoin(c.multum_category_id)=xref.multum_category_id)
       JOIN (c1
       WHERE outerjoin(xref.sub_category_id)=c1.multum_category_id)
      ORDER BY c.multum_category_id, xref.sub_category_id
      HEAD REPORT
       qualcnt = 0
      DETAIL
       qualcnt = (qualcnt+ 1)
       IF (mod(qualcnt,5)=1)
        stat = alterlist(tempcategories->qual,(qualcnt+ 4))
       ENDIF
       tempcategories->qual[qualcnt].category_id = c.multum_category_id, tempcategories->qual[qualcnt
       ].category_name = c.category_name, tempcategories->qual[qualcnt].child_id = xref
       .sub_category_id,
       tempcategories->qual[qualcnt].child_name = c1.category_name
      FOOT REPORT
       stat = alterlist(tempcategories->qual,qualcnt)
      WITH nocounter
     ;end select
     SET nqueryidx = 0
     SET stat = alterlist(querylist->qual,0)
     FOR (i = 1 TO size(tempcategories->qual,5))
       SET nlastidx = (nlastidx+ 1)
       IF (mod(nlastidx,5)=1)
        SET stat = alterlist(reply->qual,(nlastidx+ 4))
       ENDIF
       SET reply->qual[nlastidx].category_id = tempcategories->qual[i].category_id
       SET reply->qual[nlastidx].category_name = tempcategories->qual[i].category_name
       SET reply->qual[nlastidx].child_id = tempcategories->qual[i].child_id
       SET reply->qual[nlastidx].child_name = tempcategories->qual[i].child_name
       IF ((tempcategories->qual[i].child_id != 0.0))
        SET nqueryidx = (nqueryidx+ 1)
        IF (mod(nqueryidx,5)=1)
         SET stat = alterlist(querylist->qual,(nqueryidx+ 4))
        ENDIF
        SET querylist->qual[nqueryidx].category_id = tempcategories->qual[i].child_id
       ENDIF
     ENDFOR
     SET stat = alterlist(querylist->qual,nqueryidx)
   ENDWHILE
   SET stat = alterlist(reply->qual,nlastidx)
 END ;Subroutine
 SUBROUTINE loadcategoriesfromlist(null)
   CALL loadsubcategoriesfromlist(null)
   SET stat = alterlist(reply->qual,((nlastidx+ 5) - mod(size(reply->qual,5),5)))
   SET nqueryidx = 0
   FOR (nqueryidx = 1 TO size(request->items,5))
    IF (mod(nqueryidx,5)=1)
     SET stat = alterlist(querylist->qual,(nqueryidx+ 4))
    ENDIF
    SET querylist->qual[nqueryidx].category_id = request->items[nqueryidx].category_id
   ENDFOR
   SET stat = alterlist(querylist->qual,nqueryidx)
   WHILE (nqueryidx > 0.0)
     CALL echo("Find Parent Loop")
     SET stat = alterlist(tempcategories->qual,0)
     SELECT INTO "nl:"
      c.multum_category_id, c.category_name, xref.multum_category_id,
      xref.sub_category_id, c1.category_name
      FROM mltm_drug_categories c,
       mltm_category_sub_xref xref,
       mltm_drug_categories c1
      PLAN (c
       WHERE expand(ncnt,1,nqueryidx,c.multum_category_id,querylist->qual[ncnt].category_id))
       JOIN (xref
       WHERE outerjoin(c.multum_category_id)=xref.sub_category_id)
       JOIN (c1
       WHERE xref.multum_category_id=c1.multum_category_id)
      ORDER BY c.multum_category_id, xref.multum_category_id
      HEAD REPORT
       qualcnt = 0
      DETAIL
       qualcnt = (qualcnt+ 1)
       IF (mod(qualcnt,5)=1)
        stat = alterlist(tempcategories->qual,(qualcnt+ 4))
       ENDIF
       tempcategories->qual[qualcnt].category_id = c1.multum_category_id, tempcategories->qual[
       qualcnt].category_name = c1.category_name, tempcategories->qual[qualcnt].child_id = xref
       .sub_category_id,
       tempcategories->qual[qualcnt].child_name = c.category_name
      FOOT REPORT
       stat = alterlist(tempcategories->qual,qualcnt)
      WITH nocounter
     ;end select
     CALL echo(build("qualCnt = ",qualcnt))
     SET nqueryidx = 0
     SET stat = alterlist(querylist->qual,0)
     FOR (i = 1 TO size(tempcategories->qual,5))
       SET nlastidx = (nlastidx+ 1)
       IF (mod(nlastidx,5)=1)
        SET stat = alterlist(reply->qual,(nlastidx+ 4))
       ENDIF
       SET reply->qual[nlastidx].category_id = tempcategories->qual[i].category_id
       SET reply->qual[nlastidx].category_name = tempcategories->qual[i].category_name
       SET reply->qual[nlastidx].child_id = tempcategories->qual[i].child_id
       SET reply->qual[nlastidx].child_name = tempcategories->qual[i].child_name
       IF ((tempcategories->qual[i].category_id != 0.0))
        SET nqueryidx = (nqueryidx+ 1)
        IF (mod(nqueryidx,5)=1)
         SET stat = alterlist(querylist->qual,(nqueryidx+ 4))
        ENDIF
        SET querylist->qual[nqueryidx].category_id = tempcategories->qual[i].category_id
       ENDIF
     ENDFOR
     SET stat = alterlist(querylist->qual,nqueryidx)
   ENDWHILE
   SET stat = alterlist(reply->qual,nlastidx)
 END ;Subroutine
 SUBROUTINE loadallcategories(null)
  SET qualcnt = 0
  SELECT INTO "nl:"
   c.multum_category_id, c.category_name, xref.sub_category_id,
   c1.category_name
   FROM mltm_drug_categories c,
    mltm_category_sub_xref xref,
    mltm_drug_categories c1
   PLAN (c)
    JOIN (xref
    WHERE outerjoin(c.multum_category_id)=xref.multum_category_id)
    JOIN (c1
    WHERE outerjoin(xref.sub_category_id)=c1.multum_category_id)
   ORDER BY c.multum_category_id, xref.sub_category_id
   DETAIL
    qualcnt = (qualcnt+ 1)
    IF (mod(qualcnt,5)=1)
     stat = alterlist(reply->qual,(qualcnt+ 4))
    ENDIF
    reply->qual[qualcnt].category_id = c.multum_category_id, reply->qual[qualcnt].category_name = c
    .category_name, reply->qual[qualcnt].child_id = xref.sub_category_id,
    reply->qual[qualcnt].child_name = c1.category_name
   FOOT REPORT
    stat = alterlist(reply->qual,qualcnt),
    CALL echo(build("qualcnt = ",qualcnt))
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadgrandparents(null)
  SET qualcnt = 0
  SELECT INTO "nl:"
   c.multum_category_id, c.category_name, xref.sub_category_id,
   c1.category_name
   FROM mltm_drug_categories c,
    mltm_category_sub_xref xref,
    mltm_drug_categories c1
   PLAN (c)
    JOIN (xref
    WHERE outerjoin(c.multum_category_id)=xref.sub_category_id)
    JOIN (c1
    WHERE outerjoin(xref.multum_category_id)=c1.multum_category_id)
   ORDER BY c.multum_category_id, xref.sub_category_id
   DETAIL
    IF (xref.sub_category_id=0.0
     AND c.multum_category_id != 0.0)
     qualcnt = (qualcnt+ 1)
     IF (mod(qualcnt,5)=1)
      stat = alterlist(reply->qual,(qualcnt+ 4))
     ENDIF
     reply->qual[qualcnt].category_id = c.multum_category_id, reply->qual[qualcnt].category_name = c
     .category_name, reply->qual[qualcnt].child_id = xref.sub_category_id,
     reply->qual[qualcnt].child_name = c1.category_name
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,qualcnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SET modify = nopredeclare
 SET last_mod = "000"
END GO
