CREATE PROGRAM ccl_uar_rtf_tester
 PROMPT
  "Enter output device= " = "MINE",
  "Enter RTF mode(0,1)= " = 0,
  "Enter UAR_RTFx (1,2,3)= " = 0,
  "Enter RTF file= " = ""
  WITH outdev, rtfparam, rtfmode,
  rtffile
 DECLARE sline = vc WITH constant(fillstring(100,"-"))
 DECLARE inbuffer = vc
 DECLARE inbuffer2 = vc
 DECLARE inbuflen = i4
 DECLARE outbufsize = i4 WITH constant(32768)
 DECLARE outbuffer = c32768 WITH noconstant("")
 DECLARE outbuflen = i4
 SET outbuflen = outbufsize
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH constant( $RTFPARAM)
 DECLARE srtffile = vc WITH constant(cnvtlower( $RTFFILE))
 DECLARE filehandle = i4 WITH noconstant(0), private
 DECLARE filesize = i4
 DECLARE uar_fopen(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fopen",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fopen", image_win = "msvcrt.dll", uar_win = "fopen"
 DECLARE uar_fread(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fread", image_aix = "libc.a(shr.o)",
 uar_aix = "fread", image_win = "msvcrt.dll", uar_win = "fread"
 DECLARE uar_fwrite(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fwrite", image_aix = "libc.a(shr.o)",
 uar_aix = "fwrite", image_win = "msvcrt.dll", uar_win = "fwrite"
 DECLARE uar_fseek(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp
  = "decc$fseek", image_aix = "libc.a(shr.o)",
 uar_aix = "fseek", image_win = "msvcrt.dll", uar_win = "fseek"
 DECLARE uar_ftell(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$ftell", image_aix
  = "libc.a(shr.o)",
 uar_aix = "ftell", image_win = "msvcrt.dll", uar_win = "ftell"
 DECLARE uar_fclose(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fclose",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fclose", image_win = "msvcrt.dll", uar_win = "fclose"
 SET filehandle = uar_fopen(nullterm(srtffile),"r")
 IF (filehandle != 0)
  DECLARE nmore = i4 WITH private
  DECLARE vcmore = vc WITH private, notrim
  SET _stat = uar_fseek(filehandle,0,2)
  CALL echo(build("  uar_fseek status : ",_stat))
  SET filesize = (uar_ftell(filehandle)+ 512)
  CALL echo(build("  file size: ",filesize))
  DECLARE _xmldoc = vc
  CALL echo(build("C",filesize))
  SET _stat = memrealloc(_xmldoc,1,build("C",filesize))
  SET _stat = uar_fseek(filehandle,0,0)
  SET filesize = uar_fread(_xmldoc,1,filesize,filehandle)
  SET inbuffer = substring(1,filesize,_xmldoc)
  SET _stat = uar_fclose(filehandle)
 ELSE
  CALL echo(build("Error opening file= ",srtffile))
  GO TO exit_script2
 ENDIF
 CALL echo("RTF to parse..")
 CALL echo(inbuffer)
 SET inbuflen = size(inbuffer)
 IF (( $RTFMODE=2))
  CALL echo("invoke uar_rtf2..")
  CALL echo(uar_rtf2(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
    bflag))
 ELSEIF (( $RTFMODE=3))
  CALL echo("invoke uar_rtf3..")
  CALL echo(uar_rtf3(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen))
 ENDIF
 CALL echo("uar_rtf output...")
 CALL echo(trim(outbuffer))
 CALL echo(build("retbuflen= ",retbuflen))
 CALL echo(sline)
#exit_script2
END GO
