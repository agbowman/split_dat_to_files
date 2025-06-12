CREATE PROGRAM dpi_rdds_mc_audit_run
 PAINT
 SET accept = nopatcheck
#start_over
 CALL video(n)
 CALL clear(1,1)
 CALL box(2,1,5,80)
 CALL text(3,3,"RDDS Merge & Cutover Audit")
 CALL text(4,3,"Version: 2007-08-24")
 DECLARE command = vc WITH public, noconstant("")
 DECLARE soutput = vc WITH public, noconstant("")
 DECLARE stitle = vc WITH public, noconstant("")
 DECLARE sroot = vc WITH public, noconstant("")
 DECLARE stablefilter = vc WITH public, noconstant("")
 DECLARE ssource = vc WITH public, noconstant("")
 DECLARE scontext = vc WITH public, noconstant("")
 DECLARE sstatus = vc WITH public, noconstant("")
 DECLARE scutover = vc WITH public, noconstant("")
 DECLARE srowsperpage = vc WITH public, noconstant("")
 DECLARE sminrows = vc WITH public, noconstant("")
 DECLARE smaxrows = vc WITH public, noconstant("")
 DECLARE sgrablimit = vc WITH public, noconstant("")
 DECLARE ssummaryonly = vc WITH public, noconstant("")
 DECLARE sconfirm = vc WITH public, noconstant("")
 CALL text(6,3,"Output to File/Printer/MINE (default):")
 CALL accept(6,45,"P(20);CU"," ")
 SET soutput = trim(curaccept)
 IF (textlen(trim(soutput,3))=0)
  SET soutput = "MINE"
 ENDIF
 CALL text(7,3,"Title (default=RDDS Merge & Cutover Audit):")
 CALL accept(8,10,"P(95);CU"," ")
 SET stitle = trim(curaccept)
 IF (textlen(trim(stitle,3))=0)
  SET stitle = "RDDS Merge & Cutover Audit"
 ENDIF
 CALL text(9,3,"Root Path (default=/tmp):")
 CALL accept(9,45,"P(60);CU"," ")
 SET sroot = trim(curaccept)
 IF (textlen(trim(sroot,3))=0)
  SET sroot = "/tmp"
 ENDIF
 CALL text(10,3,"Temp Table ($R) Filter (default=*):")
 CALL accept(10,45,"P(60);CU"," ")
 SET stablefilter = trim(curaccept)
 DECLARE table_filter_len = i4 WITH protect, noconstant(textlen(trim(stablefilter,3)))
 IF (table_filter_len=0)
  SET stablefilter = "*$R"
 ELSE
  IF (substring((table_filter_len - 1),2,stablefilter) != "$R")
   SET stablefilter = concat(stablefilter,"$R")
  ENDIF
 ENDIF
 CALL text(11,3,"RDDS Src Env ID filter (default=*, type '0' for listing):")
 CALL accept(11,68,"P(25);CU"," ")
 SET ssource = trim(curaccept)
 IF (textlen(trim(ssource,3))=0)
  SET ssource = "*"
 ELSEIF (ssource="0")
  SET help =
  SELECT DISTINCT INTO "nl:"
   de.environment_id, de.environment_name
   FROM dm_info di,
    dm_env_reltn der,
    dm_environment de
   PLAN (di
    WHERE di.info_name="DM_ENV_ID"
     AND di.info_domain="DATA MANAGEMENT")
    JOIN (der
    WHERE der.child_env_id=di.info_number)
    JOIN (de
    WHERE der.parent_env_id=de.environment_id)
   ORDER BY de.environment_id
   WITH nocounter
  ;end select
  CALL clear(11,65)
  CALL accept(11,65,"P(25);FHC",0)
  SET ssource = trim(substring(1,(findstring(".",curaccept,1,0) - 1),curaccept),3)
  CALL clear(11,65)
  CALL text(11,65,ssource)
 ENDIF
 CALL text(12,3,"RDDS Context Name filter (default=*):")
 CALL accept(12,60,"P(30);CU"," ")
 SET scontext = trim(curaccept)
 IF (textlen(trim(scontext,3))=0)
  SET scontext = "*"
 ENDIF
 CALL text(13,3,"RDDS Status Flag filter (default=*):")
 CALL accept(13,60,"999999;CU"," ")
 SET sstatus = trim(curaccept)
 IF (textlen(trim(sstatus,3))=0)
  SET sstatus = "*"
 ENDIF
 CALL text(14,3,"Only get rows that are not yet cutover? (default=N):")
 CALL accept(14,60,"A;CU"," ")
 SET scutover = cnvtupper(trim(curaccept))
 IF (textlen(trim(scutover,3))=0)
  SET scutover = "N"
 ENDIF
 CALL text(15,3,"Number of rows per page (default=3000):")
 CALL accept(15,60,"999999;CU"," ")
 SET srowsperpage = trim(build(curaccept))
 IF (textlen(trim(srowsperpage,3))=0)
  SET srowsperpage = "3000"
 ENDIF
 CALL text(16,3,"Skip tables with num. of rows LESS than (default=1):")
 CALL accept(16,60,"9999999999;CU"," ")
 SET sminrows = trim(build(curaccept))
 IF (textlen(trim(sminrows,3))=0)
  SET sminrows = "1"
 ENDIF
 CALL text(17,3,"Skip tables with num. of rows GREATER than (default=0 (no limit)):")
 CALL accept(17,70,"9999999999;CU"," ")
 SET smaxrows = trim(build(curaccept))
 IF (textlen(trim(smaxrows,3))=0)
  SET smaxrows = "0"
 ENDIF
 CALL text(18,3,"Only get this many rows from each table (default=0 (no limit)):")
 CALL accept(18,70,"9999999999;CU"," ")
 SET sgrablimit = trim(build(curaccept))
 IF (textlen(trim(sgrablimit,3))=0)
  SET sgrablimit = "0"
 ENDIF
 CALL text(19,3,"Skip row info, output only table summary? (default=Y):")
 CALL accept(19,70,"A;CU"," ")
 SET ssummaryonly = cnvtupper(trim(curaccept))
 IF (textlen(trim(ssummaryonly,3))=0)
  SET ssummaryonly = "Y"
 ENDIF
 CALL text(20,3,"Start audit? (default=N (reset) / Y / Q):")
 CALL accept(20,45,"A;CU"," ")
 SET sconfirm = cnvtupper(trim(curaccept))
 IF (textlen(trim(sconfirm,3))=0)
  SET sconfirm = "N"
 ENDIF
 IF (sconfirm != "Y")
  IF (sconfirm="Q")
   GO TO exit_script
  ELSE
   GO TO start_over
  ENDIF
 ENDIF
 SET command = concat('dpi_rdds_mc_audit "',soutput,'", "',stitle,'", "',
  sroot,'", "',stablefilter,'", "',ssource,
  '", "',scontext,'", "',sstatus,'", "',
  scutover,'", "',srowsperpage,'", "',sminrows,
  '", "',smaxrows,'", "',sgrablimit,'", "',
  ssummaryonly,'", "Y" go')
 CALL text(22,1,"--------------------- EXECUTING COMMAND ---------------------")
 CALL text(23,3,command)
 CALL text(24,1,"-------------------------------------------------------------")
 EXECUTE dpi_rdds_mc_audit value(soutput), value(stitle), value(sroot),
 value(stablefilter), value(ssource), value(scontext),
 value(sstatus), value(scutover), value(srowsperpage),
 value(sminrows), value(smaxrows), value(sgrablimit),
 value(ssummaryonly), value("Y")
#exit_script
END GO
