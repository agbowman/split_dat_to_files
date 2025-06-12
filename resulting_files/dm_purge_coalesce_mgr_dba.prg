CREATE PROGRAM dm_purge_coalesce_mgr:dba
 DECLARE sbr_toggletemplateindicator(sbr_templatenbr=i4) = i2
 DECLARE sbr_settemplateind(sbr_templatenbr=i4,sbr_coalesceind=i2) = i2
 DECLARE sbr_setstatusmsg(sbr_statusmsg=vc) = null
 DECLARE sbr_setallcoalescing(sbr_coalesceind=i2) = null
 DECLARE numperpage = i4 WITH protect, constant(10)
 DECLARE currentpage = i4 WITH protect, noconstant(1)
 DECLARE numpages = i4 WITH protect, noconstant(0)
 DECLARE currow = i4 WITH protect, noconstant(0)
 DECLARE loop = i4 WITH protect, noconstant(0)
 DECLARE displaystring = vc WITH protect, noconstant("")
 DECLARE startidx = i4 WITH protect, noconstant(0)
 DECLARE endidx = i4 WITH protect, noconstant(0)
 DECLARE lval_idx = i4 WITH protect, noconstant(0)
 DECLARE trimmedinput = c1 WITH protect, noconstant("")
 DECLARE statusmsg = vc WITH protect, noconstant("")
 DECLARE showstatusmsgind = i2 WITH protect, noconstant(0)
 FREE RECORD purgetemplates
 RECORD purgetemplates(
   1 templatecnt = i4
   1 list_0[*]
     2 templatenbr = i4
     2 templatename = vc
     2 hascoalescerowind = i2
     2 coalesceenabledind = i2
 )
 SELECT INTO "nl:"
  allcapsname = cnvtupper(dpt.name), dpt.name, dpt.template_nbr,
  di.info_number
  FROM dm_purge_template dpt,
   dm_info di
  PLAN (dpt
   WHERE (dpt.schema_dt_tm=
   (SELECT
    max(dpt2.schema_dt_tm)
    FROM dm_purge_template dpt2
    WHERE dpt2.template_nbr=dpt.template_nbr))
    AND dpt.active_ind=1)
   JOIN (di
   WHERE cnvtint(di.info_long_id)=outerjoin(dpt.template_nbr)
    AND di.info_domain=outerjoin("DM PURGE COALESCE"))
  ORDER BY allcapsname
  DETAIL
   purgetemplates->templatecnt = (purgetemplates->templatecnt+ 1)
   IF (mod(purgetemplates->templatecnt,10)=1)
    stat = alterlist(purgetemplates->list_0,(purgetemplates->templatecnt+ 9))
   ENDIF
   purgetemplates->list_0[purgetemplates->templatecnt].templatenbr = dpt.template_nbr, purgetemplates
   ->list_0[purgetemplates->templatecnt].templatename = trim(dpt.name,3)
   IF (nullind(di.info_number)=1)
    purgetemplates->list_0[purgetemplates->templatecnt].hascoalescerowind = 0, purgetemplates->
    list_0[purgetemplates->templatecnt].coalesceenabledind = 1
   ELSE
    purgetemplates->list_0[purgetemplates->templatecnt].hascoalescerowind = 1, purgetemplates->
    list_0[purgetemplates->templatecnt].coalesceenabledind = di.info_number
   ENDIF
  FOOT REPORT
   stat = alterlist(purgetemplates->list_0,purgetemplates->templatecnt)
  WITH nocounter
 ;end select
 IF ((purgetemplates->templatecnt=0))
  CALL echo("No active purge templates exist in this domain.  Exiting.")
  GO TO exit_script
 ENDIF
 SET numpages = ceil((cnvtreal(purgetemplates->templatecnt)/ cnvtreal(numperpage)))
#main_menu_begin
 SET message = nowindow
 SET message = window
 SET width = 132
 CALL clear(1,1)
 CALL video(n)
 CALL video(r)
 CALL box(1,1,24,130)
 CALL clear(2,2,128)
 CALL clear(3,2,128)
 CALL clear(4,2,128)
 CALL text(2,52,"DM Purge Coalesce Manager")
 CALL text(4,30,"A tool to manage the coalesce functionality of Millennium purge jobs")
 CALL video(n)
 IF (showstatusmsgind=1)
  CALL text(5,2,concat("STATUS: ",statusmsg))
  SET showstatusmsgind = 0
 ENDIF
 CALL text(5,117,concat("Page ",format(currentpage,"##")," / ",format(numpages,"##")))
 SET currow = 7
 SET startidx = (((currentpage - 1) * numperpage)+ 1)
 SET endidx = minval((currentpage * numperpage),purgetemplates->templatecnt)
 FOR (loop = startidx TO endidx)
   SET displaystring = concat(format(loop,"###"),". ",format(purgetemplates->list_0[loop].templatenbr,
     "#####")," ",evaluate(purgetemplates->list_0[loop].coalesceenabledind,1,"[E]","[D]"),
    " ",purgetemplates->list_0[loop].templatename)
   CALL text(currow,10,displaystring)
   SET currow = (currow+ 1)
 ENDFOR
 CALL text(7,98,"Key:")
 CALL text(8,100,"[E]: coalescing is enabled")
 CALL text(9,100,"[D]: coalescing is disabled")
 CALL text(18,7,"Enter choice:")
 CALL text(19,7,"Options:")
 CALL text(19,17,"(N)ext Page / (P)revious Page")
 CALL text(20,17,"(F)irst Page / (L)ast Page")
 CALL text(21,17,"(D)isable all coalescing / (E)nable all coalescing")
 CALL text(22,17,"(Q)uit")
 CALL text(23,17,"Or enter a purge template number to toggle coalescing for that purge template")
 CALL accept(18,21,"P(5);CU"," "
  WHERE ((trim(curaccept,3) IN ("N", "P", "F", "L", "D",
  "E", "Q")) OR (isnumeric(curaccept))) )
 SET trimmedinput = trim(curaccept,3)
 IF (isnumeric(curaccept)=1)
  IF (locateval(lval_idx,1,purgetemplates->templatecnt,cnvtint(curaccept),purgetemplates->list_0[
   lval_idx].templatenbr)=0)
   CALL sbr_setstatusmsg(concat(trim(curaccept,3)," is an invalid template number"))
  ELSE
   CALL sbr_toggletemplateindicator(cnvtint(curaccept))
  ENDIF
  GO TO main_menu_begin
 ELSEIF (trimmedinput="N")
  IF (currentpage >= numpages)
   CALL sbr_setstatusmsg("There are no more pages")
  ELSE
   SET currentpage = (currentpage+ 1)
  ENDIF
  GO TO main_menu_begin
 ELSEIF (trimmedinput="P")
  IF (currentpage=1)
   CALL sbr_setstatusmsg("There are no previous pages")
  ELSE
   SET currentpage = (currentpage - 1)
  ENDIF
  GO TO main_menu_begin
 ELSEIF (trimmedinput="F")
  SET currentpage = 1
  GO TO main_menu_begin
 ELSEIF (trimmedinput="L")
  SET currentpage = numpages
  GO TO main_menu_begin
 ELSEIF (trimmedinput="D")
  CALL sbr_setallcoalescing(0)
  GO TO main_menu_begin
 ELSEIF (trimmedinput="E")
  CALL sbr_setallcoalescing(1)
  GO TO main_menu_begin
 ELSEIF (trimmedinput="Q")
  CALL clear(1,1)
  GO TO exit_script
 ENDIF
 SUBROUTINE sbr_toggletemplateindicator(sbr_templatenbr)
   DECLARE sbr_curidx = i4 WITH protect, noconstant(0)
   DECLARE sbr_lvalidx = i4 WITH protect, noconstant(0)
   DECLARE sbr_floattemplatenbr = f8 WITH protect, noconstant(0.0)
   DECLARE sbr_errmsg = vc WITH protect, noconstant("")
   SET sbr_curidx = locateval(sbr_lvalidx,1,purgetemplates->templatecnt,sbr_templatenbr,
    purgetemplates->list_0[sbr_lvalidx].templatenbr)
   SET purgetemplates->list_0[sbr_curidx].coalesceenabledind = negate(purgetemplates->list_0[
    sbr_curidx].coalesceenabledind)
   IF ((purgetemplates->list_0[sbr_curidx].hascoalescerowind=1))
    SET stat = sbr_settemplateind(purgetemplates->list_0[sbr_curidx].templatenbr,purgetemplates->
     list_0[sbr_curidx].coalesceenabledind)
    IF (stat=0)
     RETURN(0)
    ELSEIF ((purgetemplates->list_0[sbr_curidx].coalesceenabledind=1))
     CALL sbr_setstatusmsg(concat("Coalescing enabled for template ",build(sbr_templatenbr)))
     RETURN(1)
    ELSE
     CALL sbr_setstatusmsg(concat("Coalescing disabled for template ",build(sbr_templatenbr)))
     RETURN(1)
    ENDIF
   ELSE
    SET sbr_floattemplatenbr = cnvtreal(purgetemplates->list_0[sbr_curidx].templatenbr)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM PURGE COALESCE"
      AND di.info_long_id=sbr_floattemplatenbr
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET stat = sbr_settemplateind(purgetemplates->list_0[sbr_curidx].templatenbr,purgetemplates->
      list_0[sbr_curidx].coalesceenabledind)
     IF (stat=0)
      RETURN(0)
     ELSEIF ((purgetemplates->list_0[sbr_curidx].coalesceenabledind=1))
      CALL sbr_setstatusmsg(concat("Coalescing enabled for template ",build(sbr_templatenbr)))
      RETURN(1)
     ELSE
      CALL sbr_setstatusmsg(concat("Coalescing disabled for template ",build(sbr_templatenbr)))
      RETURN(1)
     ENDIF
    ELSE
     INSERT  FROM dm_info di
      SET di.info_name = concat("Coalesce indicator for ",trim(cnvtstring(sbr_templatenbr),3)), di
       .info_domain = "DM PURGE COALESCE", di.info_long_id = sbr_floattemplatenbr,
       di.info_number = purgetemplates->list_0[sbr_curidx].coalesceenabledind, di.updt_applctx =
       reqinfo->updt_applctx, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(sbr_errmsg,0) > 0)
      ROLLBACK
      CALL sbr_setstatusmsg(concat("Failed to insert DM_INFO row: ",sbr_errmsg))
      RETURN(0)
     ELSE
      COMMIT
      IF ((purgetemplates->list_0[sbr_curidx].coalesceenabledind=1))
       CALL sbr_setstatusmsg(concat("Coalescing enabled for template ",build(sbr_templatenbr)))
       RETURN(1)
      ELSE
       CALL sbr_setstatusmsg(concat("Coalescing disabled for template ",build(sbr_templatenbr)))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_setallcoalescing(sbr_coalesceind)
   DECLARE sbr_loop = i4 WITH protect, noconstant(0)
   IF (sbr_coalesceind=0)
    CALL text(18,55,"WARNING: Continuing will disable coalescing for ALL purge templates!")
   ELSEIF (sbr_coalesceind=1)
    CALL text(18,55,"WARNING: Continuing will enable coalescing for ALL purge templates!")
   ENDIF
   CALL text(19,55,"Do you wish to continue? (Y/N)")
   CALL accept(19,86,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="N")
    RETURN(null)
   ENDIF
   FOR (sbr_loop = 1 TO purgetemplates->templatecnt)
     IF ((purgetemplates->list_0[sbr_loop].coalesceenabledind != sbr_coalesceind))
      SET stat = sbr_toggletemplateindicator(purgetemplates->list_0[sbr_loop].templatenbr)
      IF (stat=0)
       RETURN(null)
      ENDIF
     ENDIF
   ENDFOR
   IF (sbr_coalesceind=1)
    CALL sbr_setstatusmsg("Coalescing enabled for all purge templates")
    RETURN(null)
   ELSEIF (sbr_coalesceind=0)
    CALL sbr_setstatusmsg("Coalescing disabled for all purge templates")
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_settemplateind(sbr_templatenbr,sbr_coalesceind)
   DECLARE sbr_floattemplatenbr = f8 WITH protect, noconstant(0.0)
   DECLARE sbr_errmsg = vc WITH protect, noconstant("")
   SET sbr_floattemplatenbr = cnvtreal(sbr_templatenbr)
   UPDATE  FROM dm_info di
    SET di.info_number = sbr_coalesceind, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt
      = di.updt_cnt,
     di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->
     updt_applctx
    WHERE di.info_domain="DM PURGE COALESCE"
     AND di.info_long_id=sbr_floattemplatenbr
     AND di.info_number != sbr_coalesceind
    WITH nocounter
   ;end update
   IF (error(sbr_errmsg,0) > 0)
    ROLLBACK
    CALL sbr_setstatusmsg(concat("Failed to update DM_INFO row: ",sbr_errmsg))
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_setstatusmsg(sbr_statusmsg)
  SET statusmsg = sbr_statusmsg
  SET showstatusmsgind = 1
 END ;Subroutine
#exit_script
 FREE RECORD purgetemplates
END GO
