CREATE PROGRAM cv_save_order_category:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE errmsg = vc WITH protect
 DECLARE dupfound = i2 WITH protect, noconstant(0)
 DECLARE adddetailcnt = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE lastcatalogcd = f8 WITH protect, noconstant(0.0)
 FREE RECORD addcategory
 RECORD addcategory(
   1 objarray[*]
     2 cv_order_category_id = f8
     2 category_name = c40
     2 category_limit = i4
     2 collation_seq = i4
     2 section_enum = i4
 )
 FREE RECORD addcategorydetail
 RECORD addcategorydetail(
   1 objarray[*]
     2 cv_order_category_r_id = f8
     2 cv_order_category_id = f8
     2 catalog_cd = f8
     2 detail_txt = vc
 )
 FREE RECORD uptcategory
 RECORD uptcategory(
   1 objarray[*]
     2 cv_order_category_id = f8
     2 category_name = c40
     2 category_limit = i4
     2 collation_seq = i4
     2 section_enum = i4
     2 updt_cnt = i4
 )
 FREE RECORD uptcategorydetail
 RECORD uptcategorydetail(
   1 objarray[*]
     2 cv_order_category_r_id = f8
     2 cv_order_category_id = f8
     2 catalog_cd = f8
     2 detail_txt = vc
     2 updt_cnt = i4
 )
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD addreply
 RECORD addreply(
   1 insert_ids[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD adddetailreply
 RECORD adddetailreply(
   1 insert_ids[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_order_category coc
  WHERE coc.cv_order_category_id=0.0
  WITH nocounter, forupdatewait(coc)
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL cv_log_stat(cv_error,"Failed to LOCK cv_order_category","F","CV_ORDER_CATEGORY_R",errmsg)
  GO TO exit_script
 ENDIF
 DECLARE ndeletesize = i4 WITH constant(size(request->deletecategory,5)), protect
 IF (ndeletesize > 0)
  DELETE  FROM cv_order_category_r c,
    (dummyt d1  WITH seq = value(ndeletesize))
   SET c.seq = 1
   PLAN (d1)
    JOIN (c
    WHERE (c.cv_order_category_id=request->deletecategory[d1.seq].cv_order_category_id))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   CALL cv_log_stat(cv_error,"DELETE","F","CV_ORDER_CATEGORY_R",errmsg)
   GO TO exit_script
  ENDIF
  DELETE  FROM cv_order_category c,
    (dummyt d1  WITH seq = value(ndeletesize))
   SET c.seq = 1
   PLAN (d1)
    JOIN (c
    WHERE (c.cv_order_category_id=request->deletecategory[d1.seq].cv_order_category_id))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   CALL cv_log_stat(cv_error,"DELETE","F","CV_ORDER_CATEGORY",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE ndeletedetailsize = i4 WITH constant(size(request->deletecategorydetail,5)), protect
 IF (ndeletedetailsize > 0)
  DELETE  FROM cv_order_category_r c,
    (dummyt d1  WITH seq = value(ndeletedetailsize))
   SET c.seq = 1
   PLAN (d1)
    JOIN (c
    WHERE (c.cv_order_category_r_id=request->deletecategorydetail[d1.seq].cv_order_category_r_id))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   CALL cv_log_stat(cv_error,"DELETE","F","CV_ORDER_CATEGORY_R",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE nupdatesize = i4 WITH constant(size(request->updatecategory,5)), protect
 IF (nupdatesize > 0)
  SET stat = alterlist(uptcategory->objarray,nupdatesize)
  FOR (i = 1 TO nupdatesize)
    SET uptcategory->objarray[i].cv_order_category_id = request->updatecategory[i].
    cv_order_category_id
    SET uptcategory->objarray[i].category_name = request->updatecategory[i].category_name
    SET uptcategory->objarray[i].category_limit = request->updatecategory[i].category_limit
    SET uptcategory->objarray[i].collation_seq = request->updatecategory[i].collation_seq
    SET uptcategory->objarray[i].section_enum = request->updatecategory[i].section_enum
    SET uptcategory->objarray[i].updt_cnt = request->updatecategory[i].updt_cnt
  ENDFOR
  IF (size(uptcategory->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"Updating CV_ORDER_CATEGORY...")
   EXECUTE cv_da_upt_cv_order_category  WITH replace("REQUEST",uptcategory), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_upt_cv_order_category","")
    CALL echorecord(uptcategory)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"Nothing to update into cv_order_category")
  ENDIF
 ENDIF
 DECLARE nupdatedetailsize = i4 WITH constant(size(request->updatecategorydetail,5)), protect
 IF (nupdatedetailsize > 0)
  SET stat = alterlist(uptcategorydetail->objarray,nupdatedetailsize)
  FOR (i = 1 TO nupdatedetailsize)
    SET uptcategorydetail->objarray[i].cv_order_category_r_id = request->updatecategorydetail[i].
    cv_order_category_r_id
    SET uptcategorydetail->objarray[i].cv_order_category_id = request->updatecategorydetail[i].
    cv_order_category_id
    SET uptcategorydetail->objarray[i].catalog_cd = request->updatecategorydetail[i].catalog_cd
    SET uptcategorydetail->objarray[i].detail_txt = request->updatecategorydetail[i].detail_txt
    SET uptcategorydetail->objarray[i].updt_cnt = request->updatecategorydetail[i].updt_cnt
  ENDFOR
  IF (size(uptcategorydetail->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"Updating detail CV_ORDER_CATEGORY_R...")
   EXECUTE cv_da_upt_cv_order_category_r  WITH replace("REQUEST",uptcategorydetail), replace("REPLY",
    reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_upt_cv_order_category_r","")
    CALL echorecord(uptcategorydetail)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"No detail to update into cv_order_category_r")
  ENDIF
 ENDIF
 DECLARE naddsize = i4 WITH constant(size(request->addcategory,5)), protect
 IF (naddsize > 0)
  SET stat = alterlist(addcategory->objarray,naddsize)
  FOR (i = 1 TO naddsize)
    SET addcategory->objarray[i].category_name = request->addcategory[i].category_name
    SET addcategory->objarray[i].category_limit = request->addcategory[i].category_limit
    SET addcategory->objarray[i].collation_seq = request->addcategory[i].collation_seq
    SET addcategory->objarray[i].section_enum = request->addcategory[i].section_enum
    SET adddetailcnt += size(request->addcategory[i].addcategorydetail,5)
  ENDFOR
  SET stat = alterlist(addcategorydetail->objarray,adddetailcnt)
  IF (size(addcategory->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"Inserting into CV_ORDER_CATEGORY...")
   EXECUTE cv_da_add_cv_order_category  WITH replace("REQUEST",addcategory), replace("REPLY",addreply
    )
   IF ((addreply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",addreply->status_data.status,"cv_da_add_cv_order_category","")
    CALL echorecord(addcategory)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"Nothing to insert into cv_order_category")
  ENDIF
  SET adddetailcnt = 0
  FOR (i = 1 TO naddsize)
    FOR (j = 1 TO size(request->addcategory[i].addcategorydetail,5))
      SET adddetailcnt += 1
      SET addcategorydetail->objarray[adddetailcnt].cv_order_category_id = addreply->insert_ids[i].id
      SET addcategorydetail->objarray[adddetailcnt].catalog_cd = request->addcategory[i].
      addcategorydetail[j].catalog_cd
      SET addcategorydetail->objarray[adddetailcnt].detail_txt = request->addcategory[i].
      addcategorydetail[j].detail_txt
    ENDFOR
  ENDFOR
  IF (size(addcategorydetail->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"Adding into CV_ORDER_CATEGORY_R...")
   EXECUTE cv_da_add_cv_order_category_r  WITH replace("REQUEST",addcategorydetail), replace("REPLY",
    adddetailreply)
   IF ((adddetailreply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",adddetailreply->status_data.status,
     "CV_DA_ADD_CV_ORDER_CATEGORY_R","")
    CALL echorecord(addcategorydetail)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 DECLARE nadddetailsize = i4 WITH constant(size(request->addcategorydetail,5)), protect
 IF (nadddetailsize > 0)
  SET stat = alterlist(addcategorydetail->objarray,nadddetailsize)
  FOR (i = 1 TO nadddetailsize)
    SET addcategorydetail->objarray[i].cv_order_category_id = request->addcategorydetail[i].
    cv_order_category_id
    SET addcategorydetail->objarray[i].catalog_cd = request->addcategorydetail[i].catalog_cd
    SET addcategorydetail->objarray[i].detail_txt = request->addcategorydetail[i].detail_txt
  ENDFOR
  IF (size(addcategorydetail->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"Adding detail into CV_ORDER_CATEGORY_R...")
   EXECUTE cv_da_add_cv_order_category_r  WITH replace("REQUEST",addcategorydetail), replace("REPLY",
    adddetailreply)
   IF ((adddetailreply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",adddetailreply->status_data.status,
     "CV_DA_ADD_CV_ORDER_CATEGORY_R","")
    CALL echorecord(addcategorydetail)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"No detail to add into cv_order_category_r")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM cv_order_category co,
   cv_order_category_r cor
  PLAN (co
   WHERE co.cv_order_category_id != 0)
   JOIN (cor
   WHERE cor.cv_order_category_id=co.cv_order_category_id)
  ORDER BY co.section_enum, cor.catalog_cd
  HEAD co.section_enum
   lastcatalogcd = 0.0
  DETAIL
   IF (cor.catalog_cd=lastcatalogcd)
    dupfound = 1
   ENDIF
   lastcatalogcd = cor.catalog_cd
  FOOT REPORT
   lastcatalogcd = 0.0
  WITH nocounter
 ;end select
 IF (1=dupfound)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_SAVE_ORDER_CATEGORY FAILED!")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 003 06/13/2008 AR012547")
END GO
