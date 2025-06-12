CREATE PROGRAM dm_stat_resend:dba
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 SET modify maxvarlen 10000000
 FREE RECORD rest_reply
 RECORD rest_reply(
   1 responsecode = vc
   1 responsebody = vc
 )
 SET stat = initrec(rest_reply)
 FREE RECORD frecstruct
 RECORD frecstruct(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET stat = initrec(frecstruct)
 DECLARE pos = i4 WITH protect
 DECLARE actual = i4 WITH protect
 DECLARE uri = vc WITH protect
 DECLARE huri_put = i4 WITH protect
 DECLARE hreq_put = i4 WITH protect
 DECLARE hbuf_put = i4 WITH protect
 DECLARE hbuf_get = i4 WITH protect
 DECLARE hresp_put = i4 WITH protect
 DECLARE hresp_code = i4 WITH protect
 DECLARE hresp_props_put = i4 WITH protect
 DECLARE hprops_put = i4 WITH protect
 DECLARE pos_put = i4 WITH protect
 DECLARE buf = c8192 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE _output = vc WITH protect
 DECLARE _errstatus = i4 WITH protect
 DECLARE dclcmd = vc
 DECLARE status = i4
 DECLARE zipfile = vc WITH protect, noconstant(build("cctstmp",rand(0),".gz"))
 DECLARE ccts_send_timeout = i4 WITH protect, noconstant(180)
 DECLARE clientmnemonic = vc WITH protect, constant(logical("CLIENT_MNEMONIC"))
 DECLARE hostname = vc WITH protect, constant(logical("CCTS_SERVER"))
 DECLARE hostport = vc WITH protect, constant(logical("CCTS_PORT"))
 DECLARE serverstring = vc WITH protect, constant(build(hostname,":",hostport,"/upload"))
 DECLARE timestampstring = vc WITH protect, constant(trim(replace(datetimezoneformat(cnvtdatetime(
      cnvtdatetime(curdate,curtime3)),datetimezonebyname(curtimezone),"yyyy-MM-dd HH:mm:ss",
     curtimezonedef)," ","T",1)))
 DECLARE snapshot_type = vc WITH protect, noconstant("")
 DECLARE stat_snap_dt_tm = vc WITH protect, noconstant("")
 DECLARE cctsinit(dummyvar=vc) = null
 DECLARE cctssend(filename=vc,batchsize=i4,batchindex=i4) = null
 DECLARE dsendstart = dq8 WITH protect
 DECLARE dsendend = dq8 WITH protect
 DECLARE diffsendseconds = f8 WITH protect
 SUBROUTINE cctsinit(dummyvar)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DM_STAT_RESEND"
    AND di.info_name="CCTS_SEND_TIMEOUT"
   DETAIL
    ccts_send_timeout = di.info_number
   WITH nocounter
  ;end select
  IF (validate(srvuri_def,999)=999)
   CALL echo("Declaring srvuri_def")
   DECLARE srvuri_def = i2 WITH persist
   SET srvuri_def = 1
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81203))
    DECLARE uar_srv_geturistring(p1=h(value),p2=vc(ref)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIString",
    persist
    DECLARE uar_srv_geturiparts(p1=vc(ref)) = h WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIParts",
    persist
    DECLARE uar_srv_createwebrequest(p1=h(value)) = h WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_CreateWebRequest",
    persist
    DECLARE uar_srv_setwebrequestprops(p1=h(value),p2=h(value)) = i4 WITH image_axp = "srvuri",
    image_aix = "libsrvuri.a(libsrvuri.o)", uar = "SRV_SetWebRequestProps",
    persist
    DECLARE uar_srv_getwebresponse(p1=h(value),p2=h(value)) = h WITH image_axp = "srvuri", image_aix
     = "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponse",
    persist
    DECLARE uar_srv_getwebresponseprops(p1=h(value)) = h WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponseProps",
    persist
    DECLARE uar_srv_resetwebrequest(p1=h(value)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_ResetWebRequest",
    persist
    DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(value),p5=i4(
      value),
     p6=i4(value)) = h WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar =
    "SRV_CreateMemoryBuffer",
    persist
    DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = h WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreateFileBuffer",
    persist
    DECLARE uar_srv_writebuffer(p1=h(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_WriteBuffer",
    persist
    DECLARE uar_srv_readbuffer(p1=h(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
    "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_ReadBuffer",
    persist
    DECLARE uar_srv_setbufferpos(p1=h(value),p2=i4(value),p3=h(value),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetBufferPos",
    persist
    DECLARE uar_srv_getbufferpos(p1=h(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix
     = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetBufferPos",
    persist
    DECLARE uar_srv_getmemorybuffer(p1=h(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
    image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBuffer",
    persist
    DECLARE uar_srv_getmemorybuffersize(p1=h(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBufferSize",
    persist
    DECLARE uar_srv_getfilebuffername(p1=h(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
    "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferName",
    persist
    DECLARE uar_srv_getfilebuffersize(p1=h(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferSize",
    persist
    DECLARE uar_srv_createproplist() = h WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
    persist
    DECLARE uar_srv_getpropstring(p1=h(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropString",
    persist
    DECLARE uar_srv_getpropint(p1=h(value),p2=vc(ref),p3=h(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropInt",
    persist
    DECLARE uar_srv_getprophandle(p1=h(value),p2=vc(ref),p3=h(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropHandle",
    persist
    DECLARE uar_srv_setpropstring(p1=h(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
    persist
    DECLARE uar_srv_setpropint(p1=h(value),p2=vc(ref),p3=h(value)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
    persist
    DECLARE uar_srv_setprophandle(p1=h(value),p2=vc(ref),p3=h(value),p4=i4(value)) = i4 WITH
    image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
    persist
    DECLARE uar_srv_removeprop(p1=h(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_RemoveProp",
    persist
    DECLARE uar_srv_firstprop(p1=h(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_FirstProp",
    persist
    DECLARE uar_srv_nextprop(p1=h(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_NextProp",
    persist
    DECLARE uar_srv_getpropcount(p1=h(value),p2=h(ref)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropCount",
    persist
    DECLARE uar_srv_clearproplist(p1=h(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_ClearPropList",
    persist
    DECLARE uar_srv_geterror() = h WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetError",
    persist
    DECLARE uar_srv_geterrorspecific() = h WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetErrorSpecific",
    persist
    DECLARE uar_srv_closehandle(p1=h(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle",
    persist
    DECLARE uar_srv_allocate(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_Allocate",
    persist
    DECLARE uar_srv_free(p1=i4(value)) = null WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_Free",
    persist
   ELSE
    DECLARE uar_srv_geturistring(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvuri", image_aix
     = "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIString",
    persist
    DECLARE uar_srv_geturiparts(p1=vc(ref)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIParts",
    persist
    DECLARE uar_srv_createwebrequest(p1=i4(value)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_CreateWebRequest",
    persist
    DECLARE uar_srv_setwebrequestprops(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "srvuri",
    image_aix = "libsrvuri.a(libsrvuri.o)", uar = "SRV_SetWebRequestProps",
    persist
    DECLARE uar_srv_getwebresponse(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "srvuri",
    image_aix = "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponse",
    persist
    DECLARE uar_srv_getwebresponseprops(p1=i4(value)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponseProps",
    persist
    DECLARE uar_srv_resetwebrequest(p1=i4(value)) = i4 WITH image_axp = "srvuri", image_aix =
    "libsrvuri.a(libsrvuri.o)", uar = "SRV_ResetWebRequest",
    persist
    DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(value),p5=i4(
      value),
     p6=i4(value)) = i4 WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar =
    "SRV_CreateMemoryBuffer",
    persist
    DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreateFileBuffer",
    persist
    DECLARE uar_srv_writebuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_WriteBuffer",
    persist
    DECLARE uar_srv_readbuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_ReadBuffer",
    persist
    DECLARE uar_srv_setbufferpos(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(ref)) = i4 WITH
    image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetBufferPos",
    persist
    DECLARE uar_srv_getbufferpos(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix
     = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetBufferPos",
    persist
    DECLARE uar_srv_getmemorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
    image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBuffer",
    persist
    DECLARE uar_srv_getmemorybuffersize(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBufferSize",
    persist
    DECLARE uar_srv_getfilebuffername(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
    "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferName",
    persist
    DECLARE uar_srv_getfilebuffersize(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferSize",
    persist
    DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
    persist
    DECLARE uar_srv_getpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i4 WITH image_axp
     = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropString",
    persist
    DECLARE uar_srv_getpropint(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropInt",
    persist
    DECLARE uar_srv_getprophandle(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropHandle",
    persist
    DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
    persist
    DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
    persist
    DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
    image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
    persist
    DECLARE uar_srv_removeprop(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_RemoveProp",
    persist
    DECLARE uar_srv_firstprop(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_FirstProp",
    persist
    DECLARE uar_srv_nextprop(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
    image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_NextProp",
    persist
    DECLARE uar_srv_getpropcount(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix
     = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropCount",
    persist
    DECLARE uar_srv_clearproplist(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_ClearPropList",
    persist
    DECLARE uar_srv_geterror() = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetError",
    persist
    DECLARE uar_srv_geterrorspecific() = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetErrorSpecific",
    persist
    DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle",
    persist
    DECLARE uar_srv_allocate(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_Allocate",
    persist
    DECLARE uar_srv_free(p1=i4(value)) = null WITH image_axp = "srvcore", image_aix =
    "libsrvcore.a(libsrvcore.o)", uar = "SRV_Free",
    persist
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE cctssend(filename,batchsize,batchindex)
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 80904))
    SET snapshot_type = ""
    SET stat_snap_dt_tm = ""
    SET uridebug = ""
    IF (clientmnemonic != ""
     AND hostname != ""
     AND hostport != "")
     IF (findfile(filename)=1)
      FREE DEFINE rtl2
      DEFINE rtl2 filename
      SELECT INTO "nl:"
       a.line
       FROM rtl2t a
       DETAIL
        IF (((snapshot_type="") OR (stat_snap_dt_tm="")) )
         startpos = findstring("<Snapshot_Type>",a.line)
         IF (startpos > 0)
          startpos = (startpos+ 15), endpos = findstring("</Snapshot_Type>",a.line), snapshot_type =
          substring(startpos,(endpos - startpos),a.line),
          startpos = findstring(".",snapshot_type,1,1)
          IF (startpos > 0)
           snapshot_type = substring(1,(startpos - 1),snapshot_type)
          ENDIF
          startpos = findstring("SOLCAP||",snapshot_type,1,1)
          IF (startpos > 0)
           snapshot_type = substring(1,6,snapshot_type)
          ENDIF
          startpos = findstring("-",snapshot_type,1,1)
          IF (startpos > 0)
           IF (isnumeric(substring((startpos+ 1),(size(snapshot_type,3) - startpos),snapshot_type))
            > 0)
            snapshot_type = substring(1,(startpos - 1),snapshot_type)
           ENDIF
          ENDIF
          snapshot_type = replace(snapshot_type," ",""), snapshot_type = replace(snapshot_type,"-",
           "_")
         ENDIF
         startpos = findstring("<Stat_Snap_Dt_Tm>",a.line)
         IF (startpos > 0)
          IF (startpos > 0)
           startpos = (startpos+ 17), endpos = findstring("</Stat_Snap_Dt_Tm>",a.line),
           stat_snap_dt_tm = substring(startpos,(endpos - startpos),a.line)
          ENDIF
         ENDIF
        ENDIF
       WITH nocounter, maxrec = 10
      ;end select
      SET dclcmd = concat("gzip < ",filename," > ",zipfile)
      CALL dcl(dclcmd,size(dclcmd),status)
      IF (status != 0)
       SET frecstruct->file_name = zipfile
       SET frecstruct->file_buf = "rb"
       SET status = cclio("OPEN",frecstruct)
       IF (status > 0
        AND (frecstruct->file_desc != 0))
        SET frecstruct->file_dir = 2
        SET status = cclio("SEEK",frecstruct)
        IF (status=0)
         SET filelen = cclio("TELL",frecstruct)
         SET status = memrealloc(_output,1,build("C",filelen))
         IF (status > 0)
          SET frecstruct->file_dir = 0
          SET status = cclio("SEEK",frecstruct)
          SET frecstruct->file_buf = _output
          SET _output = " "
          IF (status=0)
           SET stat = cclio("READ",frecstruct)
           SET status = cclio("CLOSE",frecstruct)
           IF (status != 0)
            SET uri = build(serverstring,"?timestamp=",timestampstring,"&namespace=DM_STATS",
             "&resource=",
             snapshot_type,"&client=",clientmnemonic,"&target=",reqdata->domain,
             "&target=",curnode,"&target=",stat_snap_dt_tm,"&format=XML",
             "&keyname=batchsize","&keyname=batchindex","&keyvalue=",batchsize,"&keyvalue=",
             batchindex,"&compressed=true")
            SET huri_put = uar_srv_geturiparts(value(uri))
            SET hreq_put = uar_srv_createwebrequest(huri_put)
            SET hprops_put = uar_srv_createproplist()
            SET hbuf_put = uar_srv_creatememorybuffer(3,0,0,0,0,
             0)
            SET stat = uar_srv_setbufferpos(hbuf_put,0,0,pos_put)
            SET stat = uar_srv_writebuffer(hbuf_put,frecstruct->file_buf,size(frecstruct->file_buf),
             actual)
            SET stat = uar_srv_setpropstring(hprops_put,"method","post")
            SET stat = uar_srv_setpropstring(hprops_put,"contenttype","application/octet-stream")
            SET stat = uar_srv_setpropint(hprops_put,"timeout",ccts_send_timeout)
            SET stat = uar_srv_setprophandle(hprops_put,"reqBuffer",hbuf_put,1)
            SET stat = uar_srv_setwebrequestprops(hreq_put,hprops_put)
            SET dsendstart = cnvtdatetime(curdate,curtime3)
            SET hbuf_get = uar_srv_creatememorybuffer(3,0,0,0,0,
             0)
            SET hresp_put = uar_srv_getwebresponse(hreq_put,hbuf_get)
            SET dsendend = cnvtdatetime(curdate,curtime3)
            SET diffsendseconds = datetimediff(dsendend,dsendstart,5)
            IF (hresp_put=0)
             IF (diffsendseconds < 10
              AND diffsendseconds < ccts_send_timeout)
              SET rest_reply->responsecode = "998"
              SET rest_reply->responsebody = "Non-Timeout Send Error Occurred"
              SET _errstatus = 1
             ELSE
              SET rest_reply->responsecode = "999"
              SET rest_reply->responsebody = "Timeout Error Occurred during send. "
              SET _errstatus = 1
             ENDIF
            ELSE
             SET hresp_props_put = uar_srv_getwebresponseprops(hresp_put)
             SET stat = uar_srv_getprophandle(hresp_props_put,"statusCode",hresp_code)
             SET stat = uar_srv_getmemorybuffersize(hbuf_get,0)
             SET stat = uar_srv_setbufferpos(hbuf_get,0,0,pos)
             SET stat = uar_srv_readbuffer(hbuf_get,buf,8192,actual)
             SET rest_reply->responsecode = build(hresp_code)
             SET rest_reply->responsebody = build(buf)
             IF (hresp_code=200)
              SET _errstatus = 0
             ELSE
              SET _errstatus = 2
             ENDIF
            ENDIF
            SET stat = uar_srv_resetwebrequest(hreq_put)
            SET stat = uar_srv_closehandle(huri_put)
            SET stat = uar_srv_closehandle(hreq_put)
            SET stat = uar_srv_closehandle(hprops_put)
            SET stat = uar_srv_closehandle(hbuf_put)
            SET stat = uar_srv_closehandle(hbuf_get)
            SET stat = uar_srv_closehandle(hresp_props_put)
            SET stat = uar_srv_closehandle(hresp_put)
            SET stat = uar_srv_closehandle(hresp_code)
            SET frecstruct->file_buf = " "
           ELSE
            SET _errstatus = 60
           ENDIF
          ELSE
           SET _errstatus = 40
          ENDIF
         ELSE
          SET _errstatus = 30
         ENDIF
        ELSE
         SET _errstatus = 20
        ENDIF
       ELSE
        SET _errstatus = 10
       ENDIF
       SET dclcmd = concat("rm ",zipfile)
       CALL dcl(dclcmd,size(dclcmd),status)
      ELSE
       SET _errstatus = 1
      ENDIF
     ELSE
      SET _errstatus = 55
     ENDIF
    ELSE
     SET _errstatus = 50
     CALL echo(
      "Logicals CCTS_SERVER, CCTS_PORT, and CLIENT_MNEMONIC must be defined to utilize CCTSSEND")
    ENDIF
   ELSE
    SET _errstatus = 4
    CALL echo("CCTS Send functionality requires CCL 8.9.4 or greater")
   ENDIF
 END ;Subroutine
 FREE RECORD xmlfiles
 RECORD xmlfiles(
   1 qual[*]
     2 file_name = vc
     2 retry_count = i4
     2 ccts_retry_count = i4
     2 resend_retry_id = f8
     2 batch_size = i4
     2 batch_index = i4
 )
 DECLARE updatexmlfile(resend_retry_id=f8,msa_increment=i2,ccts_increment=i2) = null
 DECLARE successxmlfile(resend_retry_id=f8,msa_resend_cnt=i4,ccts_resend_cnt=i4) = null
 DECLARE executemsaclient(cnt=i4) = null
 DECLARE checkmsastatus(cnt=i4) = null
 DECLARE checkcctsstatus(cnt=i4) = null
 DECLARE retrievexmlfiles(targetserver=vc) = null
 DECLARE sendxmlfiles(targetserver=vc) = null
 DECLARE linecnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE mystat = i4 WITH noconstant(0)
 DECLARE msa_status = i2 WITH noconstant(0)
 DECLARE msa_status2 = i2 WITH noconstant(0)
 DECLARE msa_status3 = i2 WITH noconstant(0)
 DECLARE status_tmp = c300
 DECLARE err_msg = vc
 DECLARE dclcmd = vc
 DECLARE status = i4
 DECLARE error_msg = vc
 DECLARE filecnt = i4 WITH noconstant(0)
 DECLARE whereclause = vc WITH noconstant("")
 DECLARE resend_cnt = i4 WITH protect, noconstant(45)
 DECLARE ccts_server = vc WITH protect, noconstant("CCTS_SERVER")
 DECLARE msa_server = vc WITH protect, noconstant("MSA_SERVER")
 DECLARE dir_name = vc WITH protect, noconstant("CCLUSERDIR")
 DECLARE resend_node = vc WITH protect, noconstant(trim(cnvtupper(curnode)))
 DECLARE debug_msg_ind = i2
 DECLARE logfile = vc WITH constant(build2("DM_STAT_RESEND",curnode,"_",day(curdate),".txt"))
 DECLARE randtag = i4 WITH constant(rand(0))
 CALL getdebugrow("x")
 CALL log_msg("BeginSession",logfile)
 SET mystat = alterlist(xmlfiles->qual,10)
 CALL checkserverlogicals("x")
 IF (logical("MSA_SERVER") != null)
  CALL log_msg("Sending MSA Data",logfile)
  CALL retrievexmlfiles(msa_server)
  IF (size(xmlfiles->qual,5) > 0)
   CALL sendxmlfiles(msa_server)
  ELSE
   CALL echo("")
   CALL echo("****************************")
   CALL echo("*   No MSA files to send   *")
   CALL echo("****************************")
   CALL echo("")
  ENDIF
  CALL log_msg("MSA Sends Complete",logfile)
 ENDIF
#end_msa
 SET stat = initrec(xmlfiles)
 SET stat = alterlist(xmlfiles->qual,10)
 IF (logical("CCTS_SERVER") != null)
  IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 80904))
   CALL log_msg("Sending CCTS data",logfile)
   CALL cctsinit("X")
   CALL retrievexmlfiles(ccts_server)
   IF (size(xmlfiles->qual,5) > 0)
    CALL sendxmlfiles(ccts_server)
   ELSE
    CALL echo("")
    CALL echo("*****************************")
    CALL echo("*   No CCTS files to send   *")
    CALL echo("*****************************")
    CALL echo("")
   ENDIF
   CALL log_msg("CCTS Sends Complete",logfile)
  ELSE
   CALL echo("CCTS Send functionality requires CCL 8.9.4 or greater")
  ENDIF
 ENDIF
#end_ccts
 CALL purgeresendtable("x")
 GO TO exit_program
 SUBROUTINE checkserverlogicals(z)
   IF (logical("MSA_SERVER")=null
    AND logical("CCTS_SERVER")=null)
    CALL echo("ERROR: Either MSA_SERVER or CCTS_SERVER logical must be defined")
    SET msa_status = 1
   ENDIF
   IF (logical("CLIENT_MNEMONIC")=null)
    CALL echo("ERROR: CLIENT_MNEMONIC logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (msa_status=1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievexmlfiles(targetserver)
   IF (targetserver=ccts_server)
    SET whereclause = build2("drr.ccts_resend_retry_cnt >= -1 and drr.ccts_resend_retry_cnt < ",trim(
      cnvtstring(resend_cnt,2))," and drr.file_name LIKE'*",trim(resend_node),"*'")
   ELSEIF (targetserver=msa_server)
    SET whereclause = build2("drr.resend_retry_cnt >= -1 and drr.resend_retry_cnt < ",trim(cnvtstring
      (resend_cnt,2))," and drr.file_name LIKE'*",trim(resend_node),"*'")
   ENDIF
   CALL log_msg(build2("WhereClause: ",whereclause),logfile)
   SELECT INTO "nl:"
    FROM dm_stat_resend_retry drr
    WHERE parser(whereclause)
    HEAD REPORT
     linecnt = 0
    DETAIL
     IF (substring((findstring("_",drr.file_name)+ 1),((findstring("_",drr.file_name,(findstring("_",
        drr.file_name)+ 1)) - findstring("_",drr.file_name)) - 1),drr.file_name)=resend_node)
      IF (linecnt=size(xmlfiles->qual,5))
       mystat = alterlist(xmlfiles->qual,(linecnt+ 10))
      ENDIF
      linecnt = (linecnt+ 1), xmlfiles->qual[linecnt].file_name = cnvtlower(drr.file_name), xmlfiles
      ->qual[linecnt].retry_count = drr.resend_retry_cnt,
      xmlfiles->qual[linecnt].ccts_retry_count = drr.ccts_resend_retry_cnt, xmlfiles->qual[linecnt].
      resend_retry_id = drr.dm_stat_resend_retry_id, xmlfiles->qual[linecnt].batch_size = drr
      .batch_size_nbr,
      xmlfiles->qual[linecnt].batch_index = drr.batch_index_nbr
     ENDIF
    FOOT REPORT
     mystat = alterlist(xmlfiles->qual,linecnt)
    WITH nocounter, nullreport
   ;end select
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmexit)
   ENDIF
 END ;Subroutine
 SUBROUTINE sendxmlfiles(targetserver)
  CALL log_msg(build2("Sending XML Files. File Cnt: ",size(xmlfiles->qual,5)),logfile)
  FOR (cnt = 1 TO size(xmlfiles->qual,5))
    IF (findfile(xmlfiles->qual[cnt].file_name)=1)
     CALL log_msg(build2("Sending XML File: ",xmlfiles->qual[cnt].file_name),logfile)
     SET filecnt = (filecnt+ 1)
     IF (targetserver=msa_server)
      SET status_tmp = replace(build("msa_",rand(0),".tmp")," ","")
      CALL echo(build2("Generating Tmp file name: ",status_tmp))
      CALL log_msg("Calling MSA",logfile)
      CALL executemsaclient(cnt)
      CALL checkmsastatus(cnt)
     ELSEIF (targetserver=ccts_server)
      CALL log_msg("Calling CCTS",logfile)
      CALL cctssend(xmlfiles->qual[cnt].file_name,xmlfiles->qual[cnt].batch_size,xmlfiles->qual[cnt].
       batch_index)
      CALL checkcctsstatus(cnt)
     ENDIF
    ELSE
     CALL echo(build2("ERROR: ",xmlfiles->qual[cnt].file_name," file not found"))
     UPDATE  FROM dm_stat_resend_retry drr
      SET drr.resend_retry_cnt = 55, drr.ccts_resend_retry_cnt = 55, drr.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       drr.updt_id = reqinfo->updt_id, drr.updt_task = reqinfo->updt_task, drr.updt_applctx = reqinfo
       ->updt_applctx,
       drr.updt_cnt = (drr.updt_cnt+ 1)
      WHERE (drr.dm_stat_resend_retry_id=xmlfiles->qual[cnt].resend_retry_id)
      WITH nocounter
     ;end update
     IF (error(error_msg,0) != 0)
      CALL esmerror(error_msg,esmexit)
     ENDIF
     COMMIT
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE executemsaclient(cnt)
   IF (cursys="AIX")
    SET dclcmd = build2("$cer_exe/msaclient -file $",dir_name,"/",xmlfiles->qual[cnt].file_name,
     " | grep 'Status' > ",
     status_tmp)
   ELSE
    SET dclcmd = build2("pipe mcr cer_exe:msaclient -file ",dir_name,":",xmlfiles->qual[cnt].
     file_name," | search sys$input Status/out = ",
     status_tmp)
   ENDIF
   CALL log_msg(build2("MSA DCLCMD: ",dclcmd),logfile)
   CALL dcl(dclcmd,size(dclcmd),status)
   IF (status=0)
    SET err_msg = "ERROR: msaclient call failed.  Skipping remaining MSA executions"
    CALL esmerror(err_msg,esmreturn)
    GO TO end_msa
   ENDIF
 END ;Subroutine
 SUBROUTINE checkmsastatus(cnt)
   IF (findfile(status_tmp)=1)
    FREE DEFINE rtl2
    DEFINE rtl2 status_tmp
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      CALL echo(build2("Status Line: ",trim(a.line)))
      IF (findstring("<Code>0</Code>",trim(a.line)) > 0)
       CALL echo(build2(xmlfiles->qual[cnt].file_name," was sent successfully to MSA at ",format(
         curtime2,"##:##:##"))), msa_status = 1
      ELSE
       msa_status2 = 1
      ENDIF
     WITH nocounter, maxrec = 1
    ;end select
   ELSE
    SET msa_status3 = 1
   ENDIF
   IF (((msa_status2=1) OR (((msa_status3=1) OR (curqual=0)) )) )
    CALL echo(build2(xmlfiles->qual[cnt].file_name," was not sent successfully to MSA"))
    CALL updatexmlfile(xmlfiles->qual[cnt].resend_retry_id,1,0)
    CALL echo(build2(xmlfiles->qual[cnt].file_name," was updated in the resend table"))
    IF (((xmlfiles->qual[cnt].retry_count+ 1)=resend_cnt))
     CALL esmerror(build2("ERROR: ",trim(xmlfiles->qual[cnt].file_name)," reached the threshold of ",
       trim(cnvtstring(resend_cnt,2))," MSA retries."),esmreturn)
    ENDIF
   ENDIF
   IF (msa_status=1)
    CALL successxmlfile(xmlfiles->qual[cnt].resend_retry_id,100,- (99))
    CALL echo(build2(xmlfiles->qual[cnt].file_name," MSA_STATUS has been updated in the resend table"
      ))
   ENDIF
 END ;Subroutine
 SUBROUTINE checkcctsstatus(cnt)
   IF ((rest_reply->responsecode="200"))
    CALL echo(build2(xmlfiles->qual[cnt].file_name," was sent successfully to CCTS at ",format(
       curtime2,"##:##:##")))
    CALL successxmlfile(xmlfiles->qual[cnt].resend_retry_id,- (99),100)
    CALL echo(build2(xmlfiles->qual[cnt].file_name,
      " CCTS_RESEND_RETRY_CNT has been updated in the resend table"))
   ELSE
    CALL echo(build2(xmlfiles->qual[cnt].file_name," was not sent successfully to CCTS"))
    CALL echo(build2("Error_Status: ",_errstatus))
    CALL echo(build2("Error_Code: ",rest_reply->responsecode," - ",rest_reply->responsebody))
    CALL echo(build2("URI_String: ",uri))
    CALL log_msg(build2("Error_Status: ",_errstatus),logfile)
    CALL log_msg(build2("Error_Code: ",rest_reply->responsecode," - ",rest_reply->responsebody),
     logfile)
    CALL log_msg(build2("URI_String: ",uri),logfile)
    CALL updatexmlfile(xmlfiles->qual[cnt].resend_retry_id,0,1)
    CALL echo(build2(xmlfiles->qual[cnt].file_name," was updated in the resend table"))
    IF (((xmlfiles->qual[cnt].retry_count+ 1)=resend_cnt))
     CALL esmerror(build2("ERROR: ",trim(xmlfiles->qual[cnt].file_name)," reached the threshold of ",
       trim(cnvtstring(resend_cnt,2))," CCTS retries."),esmreturn)
    ENDIF
    IF (value(rest_reply->responsecode)="999")
     CALL log_msg("Aborting CCTS Sends due to an unresponsive CCTS Host",logfile)
     GO TO end_ccts
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updatexmlfile(resend_retry_id,msa_increment,ccts_increment)
   UPDATE  FROM dm_stat_resend_retry drr
    SET drr.resend_retry_cnt = (drr.resend_retry_cnt+ msa_increment), drr.ccts_resend_retry_cnt = (
     drr.ccts_resend_retry_cnt+ ccts_increment), drr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     drr.updt_id = reqinfo->updt_id, drr.updt_task = reqinfo->updt_task, drr.updt_applctx = reqinfo->
     updt_applctx,
     drr.updt_cnt = (drr.updt_cnt+ 1)
    WHERE drr.dm_stat_resend_retry_id=resend_retry_id
    WITH nocounter
   ;end update
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmexit)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE successxmlfile(resend_retry_id,msa_resend_cnt,ccts_resend_cnt)
   UPDATE  FROM dm_stat_resend_retry drr
    SET drr.resend_retry_cnt = evaluate(msa_resend_cnt,- (99),drr.resend_retry_cnt,msa_resend_cnt),
     drr.ccts_resend_retry_cnt = evaluate(ccts_resend_cnt,- (99),drr.ccts_resend_retry_cnt,
      ccts_resend_cnt), drr.resend_retry_dt_tm = cnvtdatetime(curdate,curtime3),
     drr.updt_dt_tm = cnvtdatetime(curdate,curtime3), drr.updt_id = reqinfo->updt_id, drr.updt_task
      = reqinfo->updt_task,
     drr.updt_applctx = reqinfo->updt_applctx, drr.updt_cnt = (drr.updt_cnt+ 1)
    WHERE drr.dm_stat_resend_retry_id=resend_retry_id
    WITH nocounter
   ;end update
   IF (error(error_msg,0) != 0)
    CALL esmerror(error_msg,esmexit)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE purgeresendtable(z)
  DELETE  FROM dm_stat_resend_retry drr
   WHERE (drr.resend_retry_dt_tm < (sysdate - 90))
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE getdebugrow(x)
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE info_domain="DM_STAT_RESEND"
    AND info_name="DEBUG_IND"
   DETAIL
    debug_msg_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_domain = "DM_STAT_RESEND", info_name = "DEBUG_IND", info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
   SET debug_msg_ind = 0
   CALL log_msg("Creating DM_INFO row",logfile)
  ENDIF
 END ;Subroutine
 SUBROUTINE log_msg(logmsg,sbr_dlogfile)
   IF (debug_msg_ind=1)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 120, not_done = 1,
      dm_eproc_length = textlen(logmsg)
     DETAIL
      IF (logmsg="BeginSession")
       dummyvar = build2("Script Begins:",randtag), row + 1, dummyvar,
       row + 1, curdate"mm/dd/yyyy;;d", " ",
       curtime3"hh:mm:ss;3;m"
      ELSEIF (logmsg="EndSession")
       dummyvar = build2("Script Ends:",randtag), row + 1, dummyvar,
       row + 1, curdate"mm/dd/yyyy;;d", " ",
       curtime3"hh:mm:ss;3;m"
      ELSE
       dm_txt = build2(randtag," : ",substring(beg_pos,end_pos,logmsg))
       WHILE (not_done=1)
         row + 1, col 0, dm_txt,
         row + 1, curdate"mm/dd/yyyy;;d", " ",
         curtime3"hh:mm:ss;3;m"
         IF (end_pos > dm_eproc_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 120), dm_txt = substring(beg_pos,120,logmsg)
         ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
   ENDIF
 END ;Subroutine
#exit_program
 FREE RECORD filestosend
 CALL log_msg("EndSession",logfile)
END GO
