CREATE PROGRAM cclprotnode
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Object Type :" = "P",
  "Object Name :" = "",
  "Include Source Name :" = "N",
  "Sort by:" = "node",
  "Host Name (CURNODE):" = ""
  WITH outdev, objtype, objname,
  incsrc, sortby, hostlist
 FREE RECORD dicprotect_rec
 RECORD dicprotect_rec FROM dic,dicprotect,dicprotect
 FREE RECORD nodes
 RECORD nodes(
   1 qual[*]
     2 node = vc
 )
 FREE RECORD splitprot
 RECORD splitprot(
   1 qual[*]
     2 str = vc
 )
 FREE RECORD src
 RECORD src(
   1 qual[*]
     2 src = vc
 )
 FREE RECORD unsynced
 RECORD unsynced(
   1 qual[*]
     2 node = vc
     2 group = vc
     2 binary_cnt = vc
     2 app_minor_version = vc
     2 app_major_version = vc
     2 ccl_version = vc
     2 ccl_reg = vc
     2 app_ocdmajor = vc
     2 app_ocdminor = vc
     2 object_name = c30
     2 object_break = vc
     2 object = c1
     2 source_name = c80
     2 user_name = c12
     2 datestamp = vc
     2 timestamp = vc
     2 updt_id = vc
     2 updt_task = vc
     2 updt_applctx = vc
     2 prcname = vc
     2 groups[*]
       3 permit_info = i4
 )
 FREE RECORD cclprot
 RECORD cclprot(
   1 qual[*]
     2 node = vc
     2 group = vc
     2 binary_cnt = vc
     2 app_minor_version = vc
     2 app_major_version = vc
     2 ccl_version = vc
     2 ccl_reg = vc
     2 app_ocdmajor = vc
     2 app_ocdminor = vc
     2 object_name = c30
     2 object_break = vc
     2 object = c1
     2 source_name = c80
     2 user_name = c12
     2 datestamp = vc
     2 timestamp = vc
     2 updt_id = vc
     2 updt_task = vc
     2 updt_applctx = vc
     2 prcname = vc
     2 groups[*]
       3 permit_info = i4
 )
 FREE RECORD 3011002_request
 RECORD 3011002_request(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
 )
 FREE RECORD 3011001_reply
 RECORD 3011001_reply(
   1 info_line[*]
     2 new_line = vc
 )
 FREE RECORD crmerrorrec
 RECORD crmerrorrec(
   1 qual[*]
     2 node = vc
     2 message = vc
 )
 DECLARE file_dir = c9 WITH constant("cer_temp:"), protect
 DECLARE query_file = c16 WITH constant("cclprot_data.dat"), protect
 DECLARE cmds_file = c16 WITH constant("cclprot_temp.prg"), protect
 DECLARE qrycnt = i4 WITH noconstant(0), protect
 DECLARE gcnt = i4 WITH noconstant(0), protect
 DECLARE nodecnt = i4 WITH noconstant(0), protect
 DECLARE hostnames = vc WITH protect
 DECLARE foundidx = i4 WITH noconstant(0), protect
 DECLARE startidx = i4 WITH noconstant(1), protect
 DECLARE node = vc WITH protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE numtokens = i4 WITH noconstant(0), protect
 DECLARE nodecount = i4 WITH noconstant(0), protect
 DECLARE nodefailure = i4 WITH noconstant(0), protect
 DECLARE nodefailuremsg = vc WITH protect
 DECLARE _app = i4 WITH noconstant(0), protect
 DECLARE _happ = i4 WITH noconstant(0), protect
 DECLARE _eks_compile_source_task = i4 WITH noconstant(0), protect
 DECLARE _eks_compile_source_reqnum = i4 WITH noconstant(0), protect
 DECLARE _eks_get_source_task = i4 WITH noconstant(0), protect
 DECLARE _eks_get_source_reqnum = i4 WITH noconstant(0), protect
 DECLARE _eks_compile_source_htask = i4 WITH noconstant(0), protect
 DECLARE _eks_compile_source_hreq = i4 WITH noconstant(0), protect
 DECLARE _eks_get_source_htask = i4 WITH noconstant(0), protect
 DECLARE _eks_get_source_hreq = i4 WITH noconstant(0), protect
 DECLARE _hrep = i4 WITH noconstant(0), protect
 DECLARE _hstat = i4 WITH noconstant(0), protect
 DECLARE uar_crmnodeperform(p1=i4(value),p2=vc(ref)) = i2 WITH image_axp = "crmrtl", image_aix =
 "libcrm.a(libcrm.o)", uar = "CrmNodePerform",
 persist
 DECLARE last_group_global = i4 WITH noconstant(- (1))
 DECLARE last_node_global = vc WITH noconstant("")
 SET 3011002_request->source_dir = file_dir
 SET 3011002_request->source_filename = cmds_file
 IF (( $OBJNAME=""))
  RETURN(0)
 ENDIF
 IF (( $INCSRC != "Y"))
  DECLARE max_group = i2 WITH constant(3), protect
 ELSE
  DECLARE max_group = i2 WITH constant(10), protect
 ENDIF
 SET parametertype = substring(1,1,reflect(parameter(parameter2( $HOSTLIST),0)))
 IF (parametertype="L")
  WHILE (parametertype > " ")
    SET nodecount += 1
    SET parametertype = substring(1,1,reflect(parameter(parameter2( $HOSTLIST),nodecount)))
    IF (parametertype > " ")
     IF (mod(nodecount,5)=1)
      SET stat = alterlist(nodes->qual,(nodecount+ 4))
     ENDIF
     SET nodes->qual[nodecount].node = parameter(parameter2( $HOSTLIST),nodecount)
    ENDIF
  ENDWHILE
  SET nodecount -= 1
  SET stat = alterlist(nodes->qual,nodecount)
 ELSE
  SET stat = alterlist(nodes->qual,1)
  SET nodecount = 1
  SET nodes->qual[1].node =  $HOSTLIST
 ENDIF
 CALL echorecord(nodes)
 IF (nodecount=1
  AND (nodes->qual[1].node=trim(curnode)))
  SELECT INTO  $OUTDEV
   group = dp.group, dp.binary_cnt, dp.app_minor_version,
   dp.app_major_version, ccl_version = mod(dp.ccl_version,100), ccl_reg =
   IF (dp.ccl_version > 100) " Ureg"
   ELSE "  Reg"
   ENDIF
   ,
   app_ocdmajor =
   IF (dp.app_minor_version > 900000) mod(dp.app_minor_version,1000000)
   ELSE dp.app_minor_version
   ENDIF
   , app_ocdminor =
   IF (dp.app_minor_version > 900000) cnvtint((dp.app_minor_version/ 1000000.0))
   ELSE 0
   ENDIF
   , object_name = dp.object_name,
   object_break = concat(dp.object,dp.object_name), dp.object, dp.source_name,
   dp.user_name, dp.datestamp, dp.timestamp,
   updt_id =
   IF (mod(dp.ccl_version,100) >= 2) 0.0
   ELSE 0.0
   ENDIF
   , updt_task =
   IF (mod(dp.ccl_version,100) >= 2) validate(dp.updt_task,0)
   ELSE 0
   ENDIF
   , updt_applctx =
   IF (mod(dp.ccl_version,100) >= 2) validate(dp.updt_applctx,0)
   ELSE 0
   ENDIF
   ,
   prcname =
   IF (mod(dp.ccl_version,100) >= 2) validate(dp.prcname,"               ")
   ELSE "               "
   ENDIF
   FROM dprotect dp
   PLAN (dp
    WHERE (dp.object= $OBJTYPE)
     AND (dp.object_name= $OBJNAME))
   HEAD REPORT
    line = fillstring(130,"-"), last_group = 0, node = trim(curnode)
   HEAD PAGE
    "OBJECT", col 35, "GROUP",
    col 41, "TYPE", col 46,
    "OWNER", col 57, "SIZE",
    col 66, "APP_VER", col 78,
    "CCL_VER", col 86, "DATE    TIME",
    col 105, "(0 TO ", max_group"##",
    " PROTECTION)", row + 1, "Node: ",
    node, col 46, "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
    row + 1, line, row + 1
   HEAD object_break
    object_name, last_group = group, stat = initrec(src),
    srccnt = 0
   HEAD group
    IF (size(src->qual,5) != 0)
     pos = locateval(idx,1,size(src->qual,5),trim(dp.source_name),src->qual[idx].src)
     IF (negate(pos))
      srccnt += 1
      IF (mod(srccnt,10)=1)
       CALL alterlist(src->qual,(srccnt+ 9))
      ENDIF
      src->qual[srccnt].src = trim(dp.source_name)
     ENDIF
    ELSE
     srccnt += 1
     IF (mod(srccnt,10)=1)
      CALL alterlist(src->qual,(srccnt+ 9))
     ENDIF
     src->qual[srccnt].src = trim(dp.source_name)
    ENDIF
    IF (last_group != group)
     row + 1, "<Dup Warning>"
    ENDIF
    col 35, group"###", col 44,
    dp.object
    IF (dp.datestamp BETWEEN 69000 AND curdate)
     new_format = 1, col 46, dp.user_name,
     col 55, dp.binary_cnt"######", col 65,
     CALL print(build(dp.app_major_version,".",app_ocdmajor,".",app_ocdminor)), col 78, ccl_version
     "##",
     ccl_reg, col 86, dp.datestamp"DDMMMYY;;D",
     " ", dp.timestamp"HH:MM:SS;2;m"
    ELSE
     new_format = 0
    ENDIF
   DETAIL
    stat = moverec(dp.seq,dicprotect_rec), scol = 95
    FOR (gnum = 0 TO max_group)
     permit_info = dicprotect_rec->groups[(gnum+ 1)].permit_info,
     IF (permit_info != 0)
      IF (scol >= 125)
       row + 1, scol = 55
      ELSE
       scol += 8
      ENDIF
      col scol, gnum"##:"
      IF (permit_info=255)
       "ALL"
      ELSE
       IF (btest(permit_info,0)=1)
        "S"
       ENDIF
       IF (btest(permit_info,1)=1)
        "R"
       ENDIF
       IF (btest(permit_info,2)=1)
        "E"
       ENDIF
       IF (btest(permit_info,3)=1)
        "W"
       ENDIF
       IF (btest(permit_info,4)=1)
        "D"
       ENDIF
       IF (btest(permit_info,5)=1)
        "I"
       ENDIF
       IF (btest(permit_info,6)=1)
        "U"
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   FOOT  object_break
    IF (( $INCSRC="Y"))
     row + 1
     IF (new_format=1)
      col 0,
      CALL print(build("Source=",check(src->qual[1].src)))
     ELSE
      col 0,
      CALL print(build("Source=",substring(1,31,check(src->qual[1].src))))
     ENDIF
     col 80, "Srv="
     IF (cnvtupper(substring(1,3,prcname))="SRV")
      prcname
     ENDIF
     col 100,
     CALL print(build("App=",format(updt_id,"#########;l"),",",updt_task,",",
      updt_applctx))
     FOR (i = 2 TO srccnt)
       IF (i <= size(src->qual,5))
        row + 1
        IF (new_format=1)
         col 7,
         CALL print(check(src->qual[i].src))
        ELSE
         col 7,
         CALL print(substring(1,31,check(src->qual[i].src)))
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    CALL alterlist(src->qual,srccnt), row + 1
   WITH format, maxcol = 140, counter,
    outerjoin = dp
  ;end select
 ELSEIF (nodecount >= 1
  AND textlen(nullterm(nodes->qual[1].node)) > 0)
  CALL alterlist(3011002_request->line,100)
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "free record dicprotect_rec go"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  "record dicprotect_rec from dic, dicprotect, dicprotect go"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "free record frec go"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "record frec("
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "1 file_desc = w8"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "1 file_offset = i4"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "1 file_dir = i4"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "1 file_name = vc"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "1 file_buf = vc) go"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat('set frec->file_name = "',file_dir,query_file,
   '" go')
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'set frec->file_buf = "w" go'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'set stat = cclio("OPEN",frec) go'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'select into "nl:"'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "group = dp.group"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = ",ccl_version = mod(dp.ccl_version, 100)"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  ",ccl_reg = if(dp.ccl_version > 100) 'Ureg' else ' Reg' endif"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat(
   ",app_ocdmajor = if(dp.app_minor_version > 900000)"," mod(dp.app_minor_version, 1000000) else",
   " dp.app_minor_version endif")
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat(
   ",app_ocdminor = if(dp.app_minor_version > 900000)",
   " cnvtint(dp.app_minor_version/1000000.0) else"," 0 endif")
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = ",object_name = dp.object_name"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = ",object_break = concat(dp.object, dp.object_name)"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  ",updt_id = if(mod(dp.ccl_version, 100) >= 2) 0.0 else 0.0 endif"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat(
   ",updt_task = if(mod(dp.ccl_version, 100) >= 2)"," validate(dp.updt_task,0) else 0 endif")
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat(
   ",updt_applctx = if(mod(dp.ccl_version, 100) >= 2)"," validate(dp.updt_applctx, 0) else 0 endif")
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat(",prcname = if(mod(dp.ccl_version, 100) >= 2)",
   " validate(dp.prcname, 'none') else"," 'none' endif")
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "from dprotect dp"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat('plan dp where dp.object = "', $OBJTYPE,'"')
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = concat('and dp.object_name = "',cnvtupper( $OBJNAME),
   '"')
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "head object_break"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "null"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "head group"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "null"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "detail"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "stat = moverec(dp.seq, dicprotect_rec)"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'frec->file_buf = build(trim(curnode), "|", group)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.binary_cnt)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.app_minor_version)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.app_major_version)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", cnvtstring(ccl_version))'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'frec->file_buf = build(frec->file_buf, "|", ccl_reg)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", app_ocdmajor)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", app_ocdminor)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", trim(dp.object_name))'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", object_break)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.object)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", trim(dp.source_name))'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.user_name)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.datestamp)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", dp.timestamp)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'frec->file_buf = build(frec->file_buf, "|", updt_id)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", updt_task)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  'frec->file_buf = build(frec->file_buf, "|", updt_applctx)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'frec->file_buf = build(frec->file_buf, "|", prcname)'
  FOR (gcnt = 1 TO (max_group+ 1))
   SET qrycnt += 1
   SET 3011002_request->line[qrycnt].linedata = concat("frec->file_buf = build(frec->file_buf, '|', ",
    "dicprotect_rec->groups[",cnvtstring(gcnt),"].permit_info)")
  ENDFOR
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata =
  "frec->file_buf = build(frec->file_buf, char(13), char(10))"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'stat = cclio("WRITE",frec)'
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = "with nocounter go"
  SET qrycnt += 1
  SET 3011002_request->line[qrycnt].linedata = 'set stat = cclio("CLOSE",frec) go'
  CALL alterlist(3011002_request->line,qrycnt)
  SET 3011002_request->nbrlines = size(3011002_request->line,5)
  SET _app = 3010000
  SET _eks_compile_source_task = 3011004
  SET _eks_compile_source_reqnum = 3011003
  SET crmstatus = uar_crmbeginapp(_app,_happ)
  IF (crmstatus != 0)
   RETURN(0)
  ENDIF
  SET crmstatus = uar_crmbegintask(_happ,_eks_compile_source_task,_eks_compile_source_htask)
  IF (crmstatus != 0)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ENDIF
  SET _eks_get_source_task = 3011002
  SET _eks_get_source_reqnum = 3011001
  SET crmstatus = uar_crmbegintask(_happ,_eks_get_source_task,_eks_get_source_htask)
  IF (crmstatus != 0)
   CALL uar_crmendtask(_eks_compile_source_htask)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ENDIF
  SET stat = alterlist(crmerrorrec->qual,20)
  SET crmerrorcount = 0
  FOR (i = 1 TO size(nodes->qual,5))
    SET nodefailuremsg = ""
    SET crmstatus = uar_crmbeginreq(_eks_compile_source_htask,0,_eks_compile_source_reqnum,
     _eks_compile_source_hreq)
    IF (crmstatus != 0)
     CALL uar_crmendtask(_eks_compile_source_htask)
     CALL uar_crmendapp(_happ)
     RETURN(0)
    ENDIF
    SET _hrequest = uar_crmgetrequest(_eks_compile_source_hreq)
    IF (_hrequest)
     SET stat = uar_srvsetstring(_hrequest,"template_name",nullterm(piece(3011002_request->
        source_filename,".",1,"error")))
     SET stat = uar_srvsetstring(_hrequest,"source_location",concat(3011002_request->source_dir,
       3011002_request->source_filename))
     SET stat = uar_srvsetint(_hrequest,"nbrlines",3011002_request->nbrlines)
     FOR (j = 1 TO 3011002_request->nbrlines)
      SET _hlinerequest = uar_srvadditem(_hrequest,"line")
      SET stat = uar_srvsetstring(_hlinerequest,"lineData",nullterm(3011002_request->line[j].linedata
        ))
     ENDFOR
     SET crmstatus = uar_crmnodeperform(_eks_compile_source_hreq,nullterm(nodes->qual[i].node))
     CALL echo(build3(3,"uar_CrmNodePerform on ",nullterm(nodes->qual[i].node),", crmStatus: ",
       crmstatus))
     SET _hreply = uar_crmgetreply(_eks_compile_source_hreq)
     SET _hstat = uar_srvgetstruct(_hreply,"status_data")
     SET _status = uar_srvgetstringptr(_hstat,"status")
     CALL echo(build("Called process returned: ",_status))
     IF (((crmstatus != 0) OR (_status != "S")) )
      SET nodefailuremsg = build3(3,
       "Failed to return objects for host name. uar_CrmNodePerform error: Crm status= ",crmstatus)
     ENDIF
    ENDIF
    CALL uar_crmendreq(_eks_compile_source_hreq)
    SET crmstatus = uar_crmbeginreq(_eks_get_source_htask,0,_eks_get_source_reqnum,
     _eks_get_source_hreq)
    IF (crmstatus != 0)
     CALL uar_crmendreq(_eks_compile_source_hreq)
     CALL uar_crmendtask(_eks_compile_source_htask)
     CALL uar_crmendtask(_eks_get_source_htask)
     CALL uar_crmendapp(_happ)
     RETURN(0)
    ENDIF
    SET _hrequest = uar_crmgetrequest(_eks_get_source_hreq)
    IF (_hrequest)
     SET stat = uar_srvsetstring(_hrequest,"Module_Dir",file_dir)
     SET stat = uar_srvsetstring(_hrequest,"Module_Name",query_file)
     SET stat = uar_srvsetshort(_hrequest,"bAsBlob",0)
     SET crmstatus = uar_crmnodeperform(_eks_get_source_hreq,nullterm(nodes->qual[i].node))
     CALL echo(build("uar_CrmNodePerform on ",nullterm(nodes->qual[i].node),", crmStatus: ",crmstatus
       ))
     SET _hreply = uar_crmgetreply(_eks_get_source_hreq)
     SET _hstat = uar_srvgetstruct(_hreply,"status_data")
     SET _status = uar_srvgetstringptr(_hstat,"status")
     CALL echo(build("Called process returned: ",_status))
     IF (((crmstatus != 0) OR (_status != "S")) )
      SET nodefailuremsg = build3(3,
       "Failed to return objects for host name. uar_CrmNodePerform error: Crm status= ",crmstatus)
     ELSE
      SET stat = initrec(3011001_reply)
      SET numlines = uar_srvgetitemcount(_hreply,"info_line")
      CALL alterlist(3011001_reply->info_line,numlines)
      FOR (j = 1 TO numlines)
       SET this_line = uar_srvgetitem(_hreply,"info_line",(j - 1))
       SET 3011001_reply->info_line[j].new_line = uar_srvgetstringptr(this_line,"new_line")
      ENDFOR
     ENDIF
    ENDIF
    CALL uar_crmendreq(_eks_get_source_hreq)
    SET protcnt = size(cclprot->qual,5)
    IF (size(cclprot->qual,5) != 0)
     CALL alterlist(cclprot->qual,((protcnt+ 10) - mod(protcnt,10)))
    ENDIF
    FOR (j = 1 TO size(3011001_reply->info_line,5))
      SET protcnt += 1
      IF (mod(protcnt,10)=1)
       CALL alterlist(cclprot->qual,(protcnt+ 9))
      ENDIF
      SET numtokens = arraysplit(splitprot->qual[idx].str,idx,3011001_reply->info_line[j].new_line,
       "|")
      SET curalias curtoken splitprot->qual[tokcnt]
      SET curalias curobj cclprot->qual[protcnt]
      SET gcnt = 0
      CALL alterlist(cclprot->qual[protcnt].groups,(max_group+ 1))
      FOR (tokcnt = 1 TO size(splitprot->qual,5))
        CASE (tokcnt)
         OF 1:
          SET curobj->node = trim(curtoken->str)
         OF 2:
          SET curobj->group = curtoken->str
         OF 3:
          SET curobj->binary_cnt = curtoken->str
         OF 4:
          SET curobj->app_minor_version = curtoken->str
         OF 5:
          SET curobj->app_major_version = curtoken->str
         OF 6:
          SET curobj->ccl_version = curtoken->str
         OF 7:
          SET curobj->ccl_reg = curtoken->str
         OF 8:
          SET curobj->app_ocdmajor = curtoken->str
         OF 9:
          SET curobj->app_ocdminor = curtoken->str
         OF 10:
          SET curobj->object_name = curtoken->str
         OF 11:
          SET curobj->object_break = curtoken->str
         OF 12:
          SET curobj->object = curtoken->str
         OF 13:
          SET curobj->source_name = curtoken->str
         OF 14:
          SET curobj->user_name = curtoken->str
         OF 15:
          SET curobj->datestamp = curtoken->str
         OF 16:
          SET curobj->timestamp = curtoken->str
         OF 17:
          SET curobj->updt_id = curtoken->str
         OF 18:
          SET curobj->updt_task = curtoken->str
         OF 19:
          SET curobj->updt_applctx = curtoken->str
         OF 20:
          SET curobj->prcname = curtoken->str
         ELSE
          SET gcnt += 1
          SET curobj->groups[gcnt].permit_info = cnvtint(curtoken->str)
        ENDCASE
      ENDFOR
      SET curalias curtoken off
      SET curalias curobj off
    ENDFOR
    CALL alterlist(cclprot->qual,protcnt)
    CALL echo(nullterm(nodes->qual[i].node))
    CALL echorecord(cclprot)
    IF (nodefailuremsg != "")
     SET crmerrorcount += 1
     IF (mod(crmerrorcount,10)=1
      AND crmerrorcount > 20)
      SET stat = alterlist(crmerrorrec->qual,(crmerrorcount+ 9))
     ENDIF
     SET crmerrorrec->qual[crmerrorcount].node = nullterm(nodes->qual[i].node)
     SET crmerrorrec->qual[crmerrorcount].message = nodefailuremsg
    ENDIF
  ENDFOR
  SET stat = alterlist(crmerrorrec->qual,crmerrorcount)
  CALL uar_crmendtask(_eks_get_source_htask)
  CALL uar_crmendtask(_eks_compile_source_htask)
  CALL uar_crmendapp(_happ)
  IF (size(cclprot->qual,5)=0
   AND size(crmerrorrec->qual,5) > 0)
   SELECT INTO  $OUTDEV
    failednode = crmerrorrec->qual[d.seq].node, errormessage = crmerrorrec->qual[d.seq].message
    FROM (dummyt d  WITH seq = value(size(crmerrorrec->qual,5)))
    ORDER BY failednode
    HEAD REPORT
     line = fillstring(130,"-")
    HEAD failednode
     "OBJECT", col 35, "GROUP",
     col 41, "TYPE", col 46,
     "OWNER", col 57, "SIZE",
     col 66, "APP_VER", col 78,
     "CCL_VER", col 86, "DATE    TIME",
     col 105, "(0 TO ", max_group"##",
     " PROTECTION)", row + 1, "Node: ",
     failednode, col 46, "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
     row + 1, line, row + 1
    DETAIL
     errormessage, row + 2
    WITH format, counter
   ;end select
  ELSEIF (((( $SORTBY="node")) OR (size(nodes->qual,5)=1)) )
   SELECT INTO  $OUTDEV
    node = cclprot->qual[d.seq].node, object_break = cclprot->qual[d.seq].object_break, object_name
     = nullterm(cclprot->qual[d.seq].object_name),
    group = cnvtint(cclprot->qual[d.seq].group), datestamp = cnvtint(cclprot->qual[d.seq].datestamp),
    timestamp = cnvtint(cclprot->qual[d.seq].timestamp),
    ccl_version = cnvtint(cclprot->qual[d.seq].ccl_version), updt_id =
    IF (cnvtint(cclprot->qual[d.seq].ccl_version) >= 2) 0.0
    ELSE 0.0
    ENDIF
    FROM (dummyt d  WITH seq = value(size(cclprot->qual,5)))
    ORDER BY node, object_name, group
    HEAD REPORT
     line = fillstring(130,"-"), last_group = 0
    HEAD node
     "OBJECT", col 35, "GROUP",
     col 41, "TYPE", col 46,
     "OWNER", col 57, "SIZE",
     col 66, "APP_VER", col 78,
     "CCL_VER", col 86, "DATE    TIME",
     col 105, "(0 TO ", max_group"##",
     " PROTECTION)", row + 1, "Node: ",
     node, col 46, "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
     row + 1, line, row + 1
    HEAD object_name
     object_name, last_group = group, stat = initrec(src),
     srccnt = 0
    HEAD group
     IF (size(src->qual,5) != 0)
      pos = locateval(idx,1,size(src->qual,5),trim(cclprot->qual[d.seq].source_name),src->qual[idx].
       src)
      IF (pos=0)
       srccnt += 1
       IF (mod(srccnt,10)=1)
        CALL alterlist(src->qual,(srccnt+ 9))
       ENDIF
       src->qual[srccnt].src = trim(cclprot->qual[d.seq].source_name)
      ENDIF
     ELSE
      srccnt += 1
      IF (mod(srccnt,10)=1)
       CALL alterlist(src->qual,(srccnt+ 9))
      ENDIF
      src->qual[srccnt].src = trim(cclprot->qual[d.seq].source_name)
     ENDIF
     IF (last_group != group)
      row + 1, "<Dup Warning>"
     ENDIF
     col 35, group"###", col 44,
     cclprot->qual[d.seq].object
     IF (datestamp BETWEEN 69000 AND curdate)
      new_format = 1, col 46, cclprot->qual[d.seq].user_name,
      col 55, cclprot->qual[d.seq].binary_cnt"######", col 65,
      CALL print(build(cclprot->qual[d.seq].app_major_version,".",cclprot->qual[d.seq].app_ocdmajor,
       ".",cclprot->qual[d.seq].app_ocdminor)), col 78, ccl_version"##",
      cclprot->qual[d.seq].ccl_reg, col 86, datestamp"DDMMMYY;;D",
      " ", timestamp"HH:MM:SS;2;m"
     ELSE
      new_format = 0
     ENDIF
    DETAIL
     scol = 95
     FOR (gnum = 0 TO max_group)
      permit_info = cclprot->qual[d.seq].groups[(gnum+ 1)].permit_info,
      IF (permit_info != 0)
       IF (scol >= 125)
        row + 1, scol = 55
       ELSE
        scol += 8
       ENDIF
       col scol, gnum"##:"
       IF (permit_info=255)
        "ALL"
       ELSE
        IF (btest(permit_info,0)=1)
         "S"
        ENDIF
        IF (btest(permit_info,1)=1)
         "R"
        ENDIF
        IF (btest(permit_info,2)=1)
         "E"
        ENDIF
        IF (btest(permit_info,3)=1)
         "W"
        ENDIF
        IF (btest(permit_info,4)=1)
         "D"
        ENDIF
        IF (btest(permit_info,5)=1)
         "I"
        ENDIF
        IF (btest(permit_info,6)=1)
         "U"
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    FOOT  object_name
     IF (( $INCSRC="Y"))
      row + 1
      IF (new_format=1)
       col 0,
       CALL print(build("Source=",check(src->qual[1].src)))
      ELSE
       col 0,
       CALL print(build("Source=",substring(1,31,check(src->qual[1].src))))
      ENDIF
      col 80, "Srv="
      IF (cnvtupper(substring(1,3,cclprot->qual[d.seq].prcname))="SRV")
       cclprot->qual[d.seq].prcname
      ENDIF
      col 100,
      CALL print(build("App=",format(updt_id,"#########;l"),",",cclprot->qual[d.seq].updt_task,",",
       cclprot->qual[d.seq].updt_applctx))
      FOR (i = 2 TO srccnt)
        IF (i <= size(src->qual,5))
         row + 1
         IF (new_format=1)
          col 7,
          CALL print(check(src->qual[i].src))
         ELSE
          col 7,
          CALL print(substring(1,31,check(src->qual[i].src)))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     row + 1,
     CALL alterlist(src->qual,srccnt)
    FOOT  node
     row + 1
    FOOT REPORT
     FOR (errorindex = 1 TO size(crmerrorrec->qual,5))
       "OBJECT", col 35, "GROUP",
       col 41, "TYPE", col 46,
       "OWNER", col 57, "SIZE",
       col 66, "APP_VER", col 78,
       "CCL_VER", col 86, "DATE    TIME",
       col 105, "(0 TO ", max_group"##",
       " PROTECTION)", row + 1, "Node: ",
       crmerrorrec->qual[errorindex].node, col 46,
       "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
       row + 1, line, row + 1,
       CALL print(build(crmerrorrec->qual[errorindex].message)), row + 2
     ENDFOR
    WITH format, maxcol = 140, counter,
     outerjoin = dp
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    object_break = cclprot->qual[d.seq].object_break, object_name = nullterm(cclprot->qual[d.seq].
     object_name), node = cclprot->qual[d.seq].node,
    group = cnvtint(cclprot->qual[d.seq].group), datestamp = cnvtint(cclprot->qual[d.seq].datestamp),
    timestamp = cnvtint(cclprot->qual[d.seq].timestamp),
    ccl_version = cnvtint(cclprot->qual[d.seq].ccl_version), updt_id =
    IF (cnvtint(cclprot->qual[d.seq].ccl_version) >= 2) 0.0
    ELSE 0.0
    ENDIF
    FROM (dummyt d  WITH seq = value(size(cclprot->qual,5)))
    ORDER BY object_name, node, group
    HEAD REPORT
     line = fillstring(130,"-"), last_group = 0
    HEAD PAGE
     "OBJECT", col 29, "NODE",
     col 35, "GROUP", col 41,
     "TYPE", col 46, "OWNER",
     col 57, "SIZE", col 66,
     "APP_VER", col 78, "CCL_VER",
     col 86, "DATE    TIME", col 105,
     "(0 TO ", max_group"##", " PROTECTION)",
     row + 1, col 46, "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
     row + 1, line, row + 1
    HEAD object_name
     col 0, object_name, stat = initrec(src),
     srccnt = 0
    HEAD node
     col 28, node, last_group = - (1)
    HEAD group
     IF (size(src->qual,5) != 0)
      pos = locateval(idx,1,size(src->qual,5),trim(cclprot->qual[d.seq].source_name),src->qual[idx].
       src)
      IF (pos=0)
       srccnt += 1
       IF (mod(srccnt,10)=1)
        CALL alterlist(src->qual,(srccnt+ 9))
       ENDIF
       src->qual[srccnt].src = trim(cclprot->qual[d.seq].source_name)
      ENDIF
     ELSE
      srccnt += 1
      IF (mod(srccnt,10)=1)
       CALL alterlist(src->qual,(srccnt+ 9))
      ENDIF
      src->qual[srccnt].src = trim(cclprot->qual[d.seq].source_name)
     ENDIF
     col 36, group"###", col 44,
     cclprot->qual[d.seq].object
     IF (datestamp BETWEEN 69000 AND curdate)
      new_format = 1, col 46, cclprot->qual[d.seq].user_name,
      col 55, cclprot->qual[d.seq].binary_cnt"######", col 65,
      CALL print(build(cclprot->qual[d.seq].app_major_version,".",cclprot->qual[d.seq].app_ocdmajor,
       ".",cclprot->qual[d.seq].app_ocdminor)), col 78, ccl_version"##",
      cclprot->qual[d.seq].ccl_reg, col 86, datestamp"DDMMMYY;;D",
      " ", timestamp"HH:MM:SS;2;m"
     ELSE
      new_format = 0
     ENDIF
     scol = 95
     FOR (gnum = 0 TO max_group)
      permit_info = cclprot->qual[d.seq].groups[(gnum+ 1)].permit_info,
      IF (permit_info != 0)
       IF (scol >= 125)
        row + 1, scol = 55
       ELSE
        scol += 8
       ENDIF
       col scol, gnum"##:"
       IF (permit_info=255)
        "ALL"
       ELSE
        IF (btest(permit_info,0)=1)
         "S"
        ENDIF
        IF (btest(permit_info,1)=1)
         "R"
        ENDIF
        IF (btest(permit_info,2)=1)
         "E"
        ENDIF
        IF (btest(permit_info,3)=1)
         "W"
        ENDIF
        IF (btest(permit_info,4)=1)
         "D"
        ENDIF
        IF (btest(permit_info,5)=1)
         "I"
        ENDIF
        IF (btest(permit_info,6)=1)
         "U"
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
     IF ((last_group > - (1))
      AND last_group != group)
      col 0, "<Dup Warning>"
     ENDIF
     last_group = group, row + 1
    FOOT  object_name
     IF (( $INCSRC="Y"))
      IF (new_format=1)
       col 0,
       CALL print(build("Source=",check(src->qual[1].src)))
      ELSE
       col 0,
       CALL print(build("Source=",substring(1,31,check(src->qual[1].src))))
      ENDIF
      col 80, "Srv="
      IF (cnvtupper(substring(1,3,cclprot->qual[d.seq].prcname))="SRV")
       cclprot->qual[d.seq].prcname
      ENDIF
      col 100,
      CALL print(build("App=",format(updt_id,"#########;l"),",",cclprot->qual[d.seq].updt_task,",",
       cclprot->qual[d.seq].updt_applctx))
      FOR (i = 2 TO srccnt)
        IF (new_format=1)
         row + 1, col 7,
         CALL print(check(src->qual[i].src))
        ELSE
         row + 1, col 7,
         CALL print(substring(1,31,check(src->qual[i].src)))
        ENDIF
      ENDFOR
     ENDIF
     row + 1,
     CALL alterlist(src->qual,srccnt)
    FOOT REPORT
     FOR (errorindex = 1 TO size(crmerrorrec->qual,5))
       "OBJECT", col 35, "GROUP",
       col 41, "TYPE", col 46,
       "OWNER", col 57, "SIZE",
       col 66, "APP_VER", col 78,
       "CCL_VER", col 86, "DATE    TIME",
       col 105, "(0 TO ", max_group"##",
       " PROTECTION)", row + 1, "Node: ",
       crmerrorrec->qual[errorindex].node, col 46,
       "(E)xecute (S)elect (R)ead (W)rite (D)elete (I)nsert (U)pdate",
       row + 1, line, row + 1,
       CALL print(build(crmerrorrec->qual[errorindex].message)), row + 2
     ENDFOR
    WITH format, maxcol = 140, counter,
     outerjoin = dp
   ;end select
  ENDIF
 ENDIF
END GO
