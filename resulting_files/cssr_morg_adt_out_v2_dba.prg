CREATE PROGRAM cssr_morg_adt_out_v2:dba
 DECLARE tmp_str = vc WITH protect
 DECLARE oenlogdir = vc WITH noconstant("CCLUSERDIR:"), protect
 IF ( NOT (validate(hl7message)))
  IF ( NOT (validate(oenlogdir)))
   SET oenlogdir = "CCLUSERDIR:fsi/logs"
  ENDIF
  DECLARE hl7message = vc WITH noconstant("NoMessage")
  DECLARE nonhl7message = vc
  DECLARE hl7field = vc
  DECLARE currentpos = i4
  DECLARE currentsegment = vc
  DECLARE previoussegment = vc
  DECLARE errmess = vc
  DECLARE errcde = i4
  DECLARE firstseg = vc
  DECLARE hl7sep = vc
  DECLARE hl7sep2 = vc
  DECLARE hl7sep3 = vc
  DECLARE eos = vc WITH constant(char(13))
  DECLARE som = vc WITH constant(char(11))
  DECLARE eom = vc WITH constant(char(28))
  DECLARE trace_level_com = i4
  DECLARE oenlogfile = vc
  DECLARE memostartcurtime3 = i4 WITH noconstant(curtime3)
  SET csvsep = "|"
  SET csveltid = 0
  SET trace_level_com = 4
  DECLARE mor_log_level = i1
  IF (validate(oen_proc->trait_list))
   SET mor_log_level = 0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(oen_proc->trait_list,5)))
    WHERE (oen_proc->trait_list[d.seq].name="TRACE_LEVEL")
    DETAIL
     mor_log_level = cnvtint(oen_proc->trait_list[d.seq].value)
    WITH nocounter
   ;end select
   SET oenlogfile = build(oenlogdir,"/",oen_proc->proc_name,"_oen.log")
  ELSE
   SET mor_log_level = 5
   SET oenlogfile = build(oenlogdir,"/",curuser,"_dvd.log")
   CALL resetmorlogs(0)
  ENDIF
 ENDIF
 IF (hl7message="OEN_IGNORE")
  RETURN(0)
 ELSEIF (hl7message="NoMessage")
  IF (validate(oen_request->org_msg))
   CALL sethl7message(oen_request->org_msg)
  ELSEIF (reflect(parameter(1,0)) != " ")
   SET themsgfile = readmsgfile( $1)
   CALL sethl7message(themsgfile)
  ELSEIF (validate(testmessage))
   CALL sethl7message(testmessage)
  ENDIF
  CALL writeoenlogprompt("Initialization to Original Message")
  CALL writehl7message(0)
 ENDIF
 DECLARE writeoenlog(text=vc) = i1
 SUBROUTINE writeoenlog(text)
  IF (mor_log_level < trace_level_com)
   RETURN(0)
  ENDIF
  SELECT INTO value(oenlogfile)
   text
   WITH append
  ;end select
 END ;Subroutine
 DECLARE forceoenlog(text=vc) = i1
 SUBROUTINE forceoenlog(text)
   SELECT INTO value(oenlogfile)
    text
    WITH append
   ;end select
 END ;Subroutine
 DECLARE writeoenlogprompt(text=vc) = i1
 SUBROUTINE writeoenlogprompt(text)
   IF (mor_log_level < trace_level_com)
    RETURN(0)
   ENDIF
   CALL writeoenlog("")
   CALL writeoenlog(concat(format(cnvtdatetime(curdate,curtime2),"DD/MM/YYYY HH:MM:SS;;D")," - ",trim
     (cnvtstring((curtime3 - memostartcurtime3))),"/100 s"," - ",
     curprog," >>> ",text))
 END ;Subroutine
 DECLARE forceoenlogprompt(text=vc) = i1
 SUBROUTINE forceoenlogprompt(text)
   SET memo_mor_log_level = mor_log_level
   SET mor_log_level = 2
   CALL writeoenlogprompt(text)
   SET mor_log_level = memo_mor_log_level
 END ;Subroutine
 DECLARE resetmorlogs(anything) = i1
 SUBROUTINE resetmorlogs(anything)
   SELECT INTO value(oenlogfile)
    " "
   ;end select
 END ;Subroutine
 DECLARE writehl7message(anything) = i1
 SUBROUTINE writehl7message(anything)
   IF (mor_log_level < trace_level_com)
    RETURN(0)
   ENDIF
   DECLARE p1 = i4 WITH protect, noconstant(1)
   DECLARE p2 = i4 WITH protect
   DECLARE linetolog = vc WITH protect
   WHILE (p1 < size(hl7message))
     SET p2 = findstring(eos,build(hl7message,eos),p1)
     SET linetolog = substring(p1,(p2 - p1),hl7message)
     CALL writeoenlog(trim(linetolog))
     SET p1 = (p2+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE readmsgfile(msgfilepath=vc) = vc
 SUBROUTINE readmsgfile(msgfilepath)
   SET logical msgfile msgfilepath
   FREE DEFINE rtl3
   DEFINE rtl3 "Msgfile"  WITH nomodify
   DECLARE varmsg = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    theline = line
    FROM rtl3t
    DETAIL
     varmsg = concat(varmsg,trim(theline),eos)
    WITH nocounter
   ;end select
   FREE DEFINE rtl3
   RETURN(trim(varmsg))
 END ;Subroutine
 DECLARE sethl7message(msg=vc) = i1
 SUBROUTINE sethl7message(msg)
   IF (substring(1,3,msg)="MSH")
    SET hl7message = trim(msg)
   ELSE
    SET hl7message = "NonHL7Message"
    SET nonhl7message = msg
    RETURN(1)
   ENDIF
   SET hl7message = replace(hl7message,build(char(13),char(10)),eos,0)
   SET hl7message = replace(hl7message,char(10),eos,0)
   SET hl7message = replace(hl7message,som,"",0)
   SET hl7message = replace(hl7message,eom,"",0)
   SET hl7sep = substring(4,1,hl7message)
   SET hl7sep2 = substring(5,1,hl7message)
   SET hl7sep3 = substring(6,1,hl7message)
   SET errmess = ""
   SET errcde = 0
   SET firstseg = "MSH"
   CALL firstsegment(0)
   RETURN(1)
 END ;Subroutine
 DECLARE returnhl7message(anything) = i1
 SUBROUTINE returnhl7message(anything)
   IF (validate(oen_reply->out_msg))
    SET oen_reply->out_msg = build(trim(hl7message),char(0))
   ENDIF
   CALL writeoenlogprompt("Returned Message")
   CALL writehl7message(0)
 END ;Subroutine
 DECLARE ignorehl7message(logtext=vc) = i1
 SUBROUTINE ignorehl7message(logtext)
   DECLARE msh9 = vc WITH protect
   DECLARE logt = vc WITH protect
   CALL writeoenlog("")
   IF (logtext="")
    SET msh9 = gethl7field("MSH",9)
    SET logt = concat("Message ",msh9," Ignored")
   ELSE
    SET logt = logtext
   ENDIF
   CALL writeoenlogprompt(logt)
   SET hl7message = build("OEN_IGNORE",char(0))
   IF (validate(oen_reply->out_msg))
    SET oen_reply->out_msg = hl7message
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE sethprimmessage(msg=vc) = i1
 SUBROUTINE sethprimmessage(msg)
   CALL sethl7message(msg)
   SET hl7sep = substring(2,1,hl7message)
   SET hl7sep2 = substring(3,1,hl7message)
   SET hl7sep3 = substring(4,1,hl7message)
   SET firstseg = "H"
   RETURN(1)
 END ;Subroutine
 DECLARE firstsegment(anything) = vc
 SUBROUTINE firstsegment(anything)
   SET currentpos = 1
   SET previoussegment = ""
   SET p = findstring(hl7sep,hl7message)
   SET currentsegment = substring(currentpos,(p - currentpos),hl7message)
   RETURN(currentsegment)
 END ;Subroutine
 DECLARE nextsegment(anything) = vc
 SUBROUTINE nextsegment(anything)
   DECLARE p = i4 WITH protect
   DECLARE p1 = i4 WITH protect
   SET previoussegment = currentsegment
   SET p = findstring(eos,hl7message,currentpos)
   IF (p=0)
    SET currentsegment = ""
    SET currentpos = (size(hl7message)+ 2)
   ELSE
    SET p1 = findstring(hl7sep,hl7message,p)
    SET currentsegment = substring((p+ 1),((p1 - p) - 1),hl7message)
    SET currentpos = (p+ 1)
   ENDIF
   RETURN(currentsegment)
 END ;Subroutine
 DECLARE findnextsegment(segname=vc) = vc
 SUBROUTINE findnextsegment(segname)
   CALL nextsegment(0)
   WHILE (currentsegment != ""
    AND currentsegment != segname)
     CALL nextsegment(0)
   ENDWHILE
   RETURN(currentsegment)
 END ;Subroutine
 DECLARE findfirstsegment(segname=vc) = vc
 SUBROUTINE findfirstsegment(segname)
  CALL firstsegment(0)
  IF (currentsegment=segname)
   RETURN(segname)
  ELSE
   RETURN(findnextsegment(segname))
  ENDIF
 END ;Subroutine
 DECLARE existssegment(segname=vc) = i1
 SUBROUTINE existssegment(segname)
   RETURN(findstring(build(eos,segname,hl7sep),build(eos,hl7message)))
 END ;Subroutine
 DECLARE getsegment(segname=vc) = vc
 SUBROUTINE getsegment(segname)
   DECLARE theseg = vc WITH protect
   SET theseg = ""
   IF (segname != ""
    AND currentsegment != segname)
    CALL findnextsegment(segname)
   ENDIF
   IF (currentsegment != "")
    SET memocurrentpos = currentpos
    SET memocurrentsegment = currentsegment
    CALL nextsegment(0)
    SET theseg = substring(memocurrentpos,((currentpos - memocurrentpos) - 1),hl7message)
    SET currentpos = memocurrentpos
    SET currentsegment = memocurrentsegment
   ENDIF
   RETURN(theseg)
 END ;Subroutine
 DECLARE getsegmentuntil(segname=vc,n=i4) = vc
 SUBROUTINE getsegmentuntil(segname,n)
   DECLARE theseg = vc WITH protect
   DECLARE i = i4 WITH protect
   DECLARE p = i4 WITH protect
   SET theseg = getsegment(segname)
   SET p = 1
   SET s = size(theseg)
   FOR (i = 1 TO n)
    SET p = findstring(hl7sep,theseg,(p+ 1))
    IF (p=0)
     SET p = s
    ENDIF
   ENDFOR
   RETURN(substring(1,p,theseg))
 END ;Subroutine
 DECLARE getsegmentfrom(segname=vc,n=i4) = vc
 SUBROUTINE getsegmentfrom(segname,n)
   DECLARE theseg = vc WITH protect
   DECLARE i = i4 WITH protect
   DECLARE p = i4 WITH protect
   SET theseg = getsegment(segname)
   SET p = 1
   SET s = size(theseg)
   FOR (i = 1 TO (n+ 1))
    SET p = findstring(hl7sep,theseg,(p+ 1))
    IF (p=0)
     SET p = s
    ENDIF
   ENDFOR
   RETURN(substring(p,s,theseg))
 END ;Subroutine
 DECLARE deletesegment(segname=vc) = vc
 SUBROUTINE deletesegment(segname)
   DECLARE delseg = vc WITH protect
   DECLARE firstbit = vc WITH protect
   DECLARE lastbit = vc WITH protect
   DECLARE p = i4 WITH protect
   SET delseg = ""
   IF (segname != ""
    AND currentsegment != segname)
    CALL findnextsegment(segname)
   ENDIF
   IF (currentsegment != "")
    SET firstbit = substring(1,(currentpos - 2),hl7message)
    SET memocurrentpos = currentpos
    CALL nextsegment(0)
    IF (currentpos > size(hl7message))
     SET lastbit = " "
    ELSE
     SET lastbit = substring((currentpos - 1),size(hl7message),hl7message)
    ENDIF
    SET delseg = substring(memocurrentpos,((currentpos - memocurrentpos) - 1),hl7message)
    CALL writeoenlogprompt(concat("Delete ",segname," Segment"))
    CALL writeoenlog(concat(" => ",delseg))
    SET hl7message = build(firstbit,lastbit)
    SET currentpos = memocurrentpos
    SET p = findstring(hl7sep,hl7message,currentpos)
    SET currentsegment = substring(currentpos,(p - currentpos),hl7message)
   ENDIF
   RETURN(delseg)
 END ;Subroutine
 DECLARE deletesegments(segname=vc) = i4
 SUBROUTINE deletesegments(segname)
   DECLARE dseg = vc WITH protect
   DECLARE delcnt = i4 WITH protect
   CALL firstsegment(0)
   SET delcnt = 0
   SET dseg = deletesegment(segname)
   WHILE (dseg != "")
    SET delcnt = (delcnt+ 1)
    SET dseg = deletesegment(segname)
   ENDWHILE
   CALL firstsegment(0)
   RETURN(delcnt)
 END ;Subroutine
 DECLARE deletezsegments(anything) = i4
 SUBROUTINE deletezsegments(anything)
   DECLARE dseg = vc WITH protect
   DECLARE delcnt = i4 WITH protect
   CALL firstsegment(0)
   SET delcnt = 0
   WHILE (currentsegment != "")
     IF (substring(1,1,currentsegment)="Z")
      SET delcnt = (delcnt+ 1)
      SET dseg = deletesegment(currentsegment)
     ELSE
      CALL nextsegment(0)
     ENDIF
   ENDWHILE
   CALL firstsegment(0)
   RETURN(delcnt)
 END ;Subroutine
 DECLARE insertsegment(segment=vc) = vc
 SUBROUTINE insertsegment(segment)
   DECLARE firstbit = vc WITH protect
   DECLARE lastbit = vc WITH protect
   DECLARE p = i4 WITH protect
   SET firstbit = substring(1,(currentpos - 1),hl7message)
   SET lastbit = substring(currentpos,size(hl7message),hl7message)
   IF (substring((currentpos - 1),1,firstbit)=eos)
    SET hl7message = build(firstbit,segment,eos,lastbit)
   ELSE
    SET hl7message = build(firstbit,eos,segment,lastbit)
   ENDIF
   SET p = findstring(hl7sep,segment)
   SET currentsegment = substring(1,p,segment)
   CALL writeoenlogprompt(concat("Insert ",currentsegment," Segment"))
   CALL writeoenlog(concat(" => ",segment))
   RETURN(currentsegment)
 END ;Subroutine
 DECLARE movecurrentsegment(targetpos=i4) = i1
 SUBROUTINE movecurrentsegment(targetpos)
   DECLARE segmenttomove = vc WITH protect
   DECLARE memocpos = i4 WITH protect
   DECLARE lseg = i4 WITH protect
   IF (targetpos > 0
    AND targetpos < size(hl7message)
    AND currentpos != targetpos
    AND currentsegment != "")
    SET memocpos = currentpos
    SET segmenttomove = deletesegment(currentsegment)
    SET lseg = size(segmenttomove)
    IF (targetpos < memocpos)
     SET currentpos = targetpos
    ELSE
     SET currentpos = ((targetpos - lseg) - 1)
    ENDIF
    CALL insertsegment(segmenttomove)
    IF (targetpos < memocpos)
     SET currentpos = ((memocpos+ lseg) - 1)
    ELSE
     SET currentpos = memocpos
    ENDIF
    CALL nextsegment(0)
    RETURN(1)
   ELSEIF (currentpos=targetpos)
    CALL nextsegment(0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE getelt(str=vc,sep=vc,num=i4) = vc
 SUBROUTINE getelt(str,sep,num)
   DECLARE str2 = vc WITH protect
   DECLARE p1 = i4 WITH protect
   DECLARE p2 = i4 WITH protect
   DECLARE i = i4 WITH protect
   SET str2 = build(sep,trim(str),sep)
   SET p1 = 0
   FOR (i = 1 TO num)
    SET p1 = findstring(sep,str2,(p1+ 1))
    IF (p1=0)
     RETURN(trim(" "))
    ENDIF
   ENDFOR
   SET p2 = findstring(sep,str2,(p1+ 1))
   IF (p2=0)
    SET p2 = textlen(str2)
   ENDIF
   RETURN(substring((p1+ 1),((p2 - p1) - 1),str2))
 END ;Subroutine
 DECLARE setelt(str=vc,sep=vc,num=i4,value=vc) = vc
 SUBROUTINE setelt(str,sep,num,value)
   IF (num < 1)
    RETURN(str)
   ENDIF
   DECLARE sss = vc WITH protect
   DECLARE p1 = i4 WITH protect
   DECLARE p2 = i4 WITH protect
   DECLARE i = i4 WITH protect
   DECLARE sz1 = i4 WITH protect
   SET sss = " "
   SET p1 = 0
   SET p2 = 0
   SET sz1 = size(str)
   FOR (i = 1 TO (num - 1))
     SET p1 = findstring(sep,str,(p2+ 1))
     IF (p1=0)
      SET sss = build(sss,sep)
      SET p1 = (sz1+ size(sss))
     ENDIF
     SET p2 = p1
   ENDFOR
   IF (value="")
    SET value = " "
   ENDIF
   IF (sss=" ")
    SET p2 = findstring(sep,str,(p1+ 1))
    IF (p2=0)
     SET p2 = (sz1+ 1)
    ENDIF
    RETURN(build(substring(1,p1,str),value,substring(p2,((sz1 - p1)+ 1),str)))
   ELSE
    RETURN(build(str,sss,value))
   ENDIF
 END ;Subroutine
 DECLARE countelt(str=vc,sep=vc) = i4
 SUBROUTINE countelt(str,sep)
   DECLARE i = i4 WITH protect
   DECLARE sz = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   SET sz = size(str)
   SET cnt = 1
   FOR (i = 1 TO sz)
     IF (substring(i,1,str)=sep)
      SET cnt = (cnt+ 1)
     ENDIF
   ENDFOR
   RETURN(cnt)
 END ;Subroutine
 DECLARE gethl7field2(segname=vc,fieldnum=i4,occurrence=i4) = vc
 SUBROUTINE gethl7field2(segname,fieldnum,occurrence)
   DECLARE res = vc WITH protect
   DECLARE p1 = i4 WITH protect
   DECLARE peos = i4 WITH protect
   IF (segname=firstseg)
    SET fieldnum = (fieldnum - 1)
    SET p1 = 1
   ELSE
    SET p1 = findstring(build(eos,segname,hl7sep),hl7message,(currentpos - 1))
   ENDIF
   SET errmess = ""
   IF (p1=0)
    SET errcde = 1
    SET errmess = build("segment ",segname," not found",char(0))
    RETURN(trim(" "))
   ELSE
    SET errcde = 0
    SET errmess = ""
    SET p1 = ((p1+ textlen(segname))+ 2)
   ENDIF
   SET peos = findstring(eos,hl7message,(p1+ 1))
   IF (((peos=0) OR (peos > size(hl7message))) )
    SET peos = (size(hl7message)+ 1)
   ENDIF
   SET res = getelt(substring(p1,(peos - p1),hl7message),hl7sep,fieldnum)
   IF (occurrence < 1)
    RETURN(res)
   ELSE
    RETURN(getelt(res,hl7sep3,occurrence))
   ENDIF
 END ;Subroutine
 DECLARE gethl7field(segname=vc,fieldnum=i4) = vc
 SUBROUTINE gethl7field(segname,fieldnum)
   DECLARE res = vc WITH protect
   SET res = gethl7field2(segname,fieldnum,0)
   IF (errcde=1
    AND currentpos > 1)
    SET memopos = currentpos
    SET currentpos = 1
    SET res = gethl7field2(segname,fieldnum,0)
    SET currentpos = memopos
   ENDIF
   RETURN(res)
 END ;Subroutine
 DECLARE gethl7rfield(segname=vc,fieldnum=i4,occurence=i4) = vc
 SUBROUTINE gethl7rfield(segname,fieldnum,occurence)
   DECLARE res = vc WITH protect
   SET res = gethl7field2(segname,fieldnum,occurence)
   IF (errcde=1
    AND currentpos > 1)
    SET memopos = currentpos
    SET currentpos = 1
    SET res = gethl7field2(segname,fieldnum,occurence)
    SET currentpos = memopos
   ENDIF
   RETURN(res)
 END ;Subroutine
 DECLARE sethl7field2(segname=vc,fieldnum=i4,occurrence=i4,value=vc) = i1
 SUBROUTINE sethl7field2(segname,fieldnum,occurrence,value)
   DECLARE toadd = vc WITH protect
   DECLARE fstbt = vc WITH protect
   DECLARE lstbt = vc WITH protect
   DECLARE newval = vc WITH protect
   DECLARE p1 = i4 WITH protect
   DECLARE peos = i4 WITH protect
   DECLARE pnext = i4 WITH protect
   DECLARE add_to_end = i1 WITH protect
   DECLARE i = i4 WITH protect
   IF (segname=firstseg)
    SET fieldnum = (fieldnum - 1)
    SET p1 = 1
   ELSE
    SET p1 = findstring(build(eos,segname,hl7sep),hl7message,(currentpos - 1))
   ENDIF
   SET toadd = " "
   IF (p1=0)
    RETURN(0)
   ENDIF
   SET peos = findstring(eos,hl7message,(p1+ 1))
   IF (((peos=0) OR (peos > size(hl7message))) )
    SET peos = (size(hl7message)+ 1)
   ENDIF
   SET add_to_end = 0
   FOR (i = 1 TO fieldnum)
    IF (add_to_end)
     SET toadd = build(hl7sep,toadd)
    ELSE
     SET p1 = findstring(hl7sep,hl7message,(p1+ 1))
    ENDIF
    IF (((p1 > peos) OR (p1=0)) )
     SET p1 = (peos - 1)
     SET add_to_end = 1
     SET toadd = build(hl7sep,toadd)
    ENDIF
   ENDFOR
   IF (p1 < peos)
    SET pnext = findstring(hl7sep,hl7message,(p1+ 1))
    IF (((pnext=0) OR (pnext > peos)) )
     SET pnext = peos
    ENDIF
   ELSE
    SET pnext = peos
   ENDIF
   SET fstbt = substring(1,p1,hl7message)
   IF (value="")
    SET value = " "
   ENDIF
   IF (occurrence=0)
    SET newval = value
   ELSE
    SET newval = substring((p1+ 1),((pnext - p1) - 1),hl7message)
    SET newval = setelt(newval,hl7sep3,occurrence,value)
   ENDIF
   SET lstbt = substring(pnext,size(hl7message),hl7message)
   SET hl7message = build(fstbt,toadd,newval,lstbt)
   CALL writeoenlogprompt(concat("Set HL7 Field ",segname,":",trim(cnvtstring(fieldnum))," [",
     trim(cnvtstring(occurrence)),"]"))
   CALL writeoenlog(concat(" Value => ",value))
   RETURN(1)
 END ;Subroutine
 DECLARE sethl7field(segname=vc,fieldnum=i4,value=vc) = i1
 SUBROUTINE sethl7field(segname,fieldnum,value)
   DECLARE res = i1 WITH protect
   SET res = sethl7field2(segname,fieldnum,0,value)
   IF (res=0)
    SET memopos = currentpos
    SET currentpos = 1
    SET res = sethl7field2(segname,fieldnum,0,value)
    SET currentpos = memopos
   ENDIF
   RETURN(res)
 END ;Subroutine
 DECLARE sethl7rfield(segname=vc,fieldnum=i4,occurrence=i4,value=vc) = i1
 SUBROUTINE sethl7rfield(segname,fieldnum,occurrence,value)
   DECLARE res = i1 WITH protect
   SET res = sethl7field2(segname,fieldnum,occurrence,value)
   IF (res=0)
    SET memopos = currentpos
    SET currentpos = 1
    SET res = sethl7field2(segname,fieldnum,occurrence,value)
    SET currentpos = memopos
   ENDIF
   RETURN(res)
 END ;Subroutine
 DECLARE sethl7fields(segname=vc,fieldnum=i4,value=vc) = i1
 SUBROUTINE sethl7fields(segname,fieldnum,value)
   CALL findfirstsegment(segname)
   WHILE (currentsegment=segname)
    CALL sethl7field(segname,fieldnum,value)
    CALL findnextsegment(segname)
   ENDWHILE
   CALL firstsegment(0)
   RETURN(1)
 END ;Subroutine
 DECLARE gethl7subfield(segname=vc,fieldnum=i4,subfieldnum=i4) = vc
 SUBROUTINE gethl7subfield(segname,fieldnum,subfieldnum)
   DECLARE wholefield = vc WITH protect
   SET wholefield = gethl7rfield(segname,fieldnum,1)
   IF (subfieldnum=0)
    RETURN(wholefield)
   ELSE
    RETURN(getelt(wholefield,hl7sep2,subfieldnum))
   ENDIF
 END ;Subroutine
 DECLARE gethl7rsubfield(segname=vc,fieldnum=i4,subfieldnum=i4,occurrence=i4) = vc
 SUBROUTINE gethl7rsubfield(segname,fieldnum,subfieldnum,occurrence)
   DECLARE wholefield = vc WITH protect
   SET wholefield = gethl7rfield(segname,fieldnum,occurrence)
   IF (subfieldnum=0)
    RETURN(wholefield)
   ELSE
    RETURN(getelt(wholefield,hl7sep2,subfieldnum))
   ENDIF
 END ;Subroutine
 DECLARE counthl7rfieldocc(segname=vc,fieldnum=i4) = i4
 SUBROUTINE counthl7rfieldocc(segname,fieldnum)
   DECLARE p = i4 WITH protect
   DECLARE occ = i4 WITH protect
   DECLARE wholefield = vc WITH protect
   SET wholefield = gethl7field(segname,fieldnum)
   SET p = 0
   SET occ = evaluate(wholefield,"",0,1)
   WHILE (1)
    SET p = findstring(hl7sep3,wholefield,(p+ 1))
    IF (p=0)
     RETURN(occ)
    ELSE
     SET occ = (occ+ 1)
    ENDIF
   ENDWHILE
 END ;Subroutine
 DECLARE findhl7rfieldocc(segname=vc,fieldnum=i4,subfieldnum=i4,findthis=vc) = i4
 SUBROUTINE findhl7rfieldocc(segname,fieldnum,subfieldnum,findthis)
   DECLARE i = i4 WITH protect
   DECLARE lastocc = i4 WITH protect
   SET lastocc = counthl7rfieldocc(segname,fieldnum)
   FOR (i = 1 TO lastocc)
     IF (gethl7rsubfield(segname,fieldnum,subfieldnum,i)=findthis)
      RETURN(i)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 DECLARE gethl7rsubfieldwhere(segname=vc,fieldnum=i4,subfieldnum=i4,subfieldfindnum=i4,findthis=vc)
  = vc
 SUBROUTINE gethl7rsubfieldwhere(segname,fieldnum,subfieldnum,subfieldfindnum,findthis)
   DECLARE i = i4 WITH protect
   SET i = findhl7rfieldocc(segname,fieldnum,subfieldfindnum,findthis)
   RETURN(evaluate(i,0,"",gethl7rsubfield(segname,fieldnum,subfieldnum,i)))
 END ;Subroutine
 DECLARE gethl7rfieldwhere(segname=vc,fieldnum=i4,subfieldfindnum=i4,findthis=vc) = vc
 SUBROUTINE gethl7rfieldwhere(segname,fieldnum,subfieldfindnum,findthis)
   DECLARE i = i4 WITH protect
   SET i = findhl7rfieldocc(segname,fieldnum,subfieldfindnum,findthis)
   RETURN(evaluate(i,0,"",gethl7rfield(segname,fieldnum,i)))
 END ;Subroutine
 DECLARE sethl7subfield(segname=vc,fieldnum=i4,subfieldnum=i4,value=vc) = vc
 SUBROUTINE sethl7subfield(segname,fieldnum,subfieldnum,value)
  DECLARE wholefield = vc WITH protect
  IF (subfieldnum=0)
   RETURN(sethl7field(segname,fieldnum,value))
  ELSE
   SET wholefield = gethl7field(segname,fieldnum)
   SET wholefield = setelt(wholefield,hl7sep2,subfieldnum,value)
   RETURN(sethl7field(segname,fieldnum,wholefield))
  ENDIF
 END ;Subroutine
 DECLARE sethl7rsubfield(segname=vc,fieldnum=i4,subfieldnum=i4,occurrence=i4,value=vc) = vc
 SUBROUTINE sethl7rsubfield(segname,fieldnum,subfieldnum,occurrence,value)
   DECLARE wholefield = vc WITH protect
   IF (occurrence < 1)
    SET occurrence = 1
   ENDIF
   IF (subfieldnum=0)
    RETURN(sethl7rfield(segname,fieldnum,occurrence,value))
   ELSE
    SET wholefield = gethl7rfield(segname,fieldnum,occurrence)
    SET wholefield = setelt(wholefield,hl7sep2,subfieldnum,value)
    RETURN(sethl7rfield(segname,fieldnum,occurrence,wholefield))
   ENDIF
 END ;Subroutine
 DECLARE sethl7subfields(segname=vc,fieldnum=i4,subfieldnum=i4,value=vc) = i1
 SUBROUTINE sethl7subfields(segname,fieldnum,subfieldnum,value)
   CALL findfirstsegment(segname)
   WHILE (currentsegment=segname)
    CALL sethl7subfield(segname,fieldnum,subfieldnum,value)
    CALL findnextsegment(segname)
   ENDWHILE
   CALL firstsegment(0)
   RETURN(1)
 END ;Subroutine
 DECLARE csvtohl7(sep=vc) = i1
 SUBROUTINE csvtohl7(sep)
   DECLARE csv = vc WITH protect
   DECLARE jst = vc WITH protect
   DECLARE elt = vc WITH protect
   DECLARE nbelt = i4 WITH protect
   DECLARE j = i4 WITH protect
   SET csv = build(trim(oen_request->org_msg),char(0))
   SET j = 1
   SET nbelt = countelt(csv,sep)
   WHILE (1)
     SET jst = cnvtstring(j)
     IF (findstring(build("-",jst,"-"),hl7message)=0
      AND j > nbelt)
      RETURN((j - 1))
     ENDIF
     SET hl7message = replace(hl7message,build("-",jst,"-"),"",0)
     SET hl7message = replace(hl7message,build("#",jst,"#"),getelt(csv,sep,j),0)
     SET j = (j+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE renumobxs(anything) = i1
 SUBROUTINE renumobxs(anything)
   DECLARE obxcnt = i4 WITH protect
   SET obxcnt = 1
   CALL firstsegment(0)
   WHILE (currentsegment != "")
    IF (currentsegment="OBX")
     CALL sethl7field("OBX",1,cnvtstring(obxcnt))
     SET obxcnt = (obxcnt+ 1)
    ELSEIF (((currentsegment="OBR") OR (currentsegment="SPM")) )
     SET obxcnt = 1
    ENDIF
    CALL nextsegment(0)
   ENDWHILE
   CALL firstsegment(0)
 END ;Subroutine
 DECLARE changecd2display(tag) = i1
 SUBROUTINE changecd2display(tag)
   DECLARE p1 = i4 WITH protect
   DECLARE p2 = i4 WITH protect
   DECLARE cvs = vc WITH protect
   DECLARE cset = vc WITH protect
   DECLARE tag1 = vc WITH protect
   DECLARE tag2 = vc WITH protect
   SET tag1 = tag
   SET tag2 = evaluate(tag,"CV"," ",tag)
   SET p1 = 1
   WHILE (p1 > 0)
     SET p1 = findstring("CD:",hl7message,(p1+ 1))
     IF (p1=0)
      RETURN(0)
     ENDIF
     SET p2 = (p1+ 3)
     WHILE (isnumeric(substring(p2,1,hl7message)))
       SET p2 = (p2+ 1)
     ENDWHILE
     SET cvs = substring((p1+ 3),((p2 - p1) - 3),hl7message)
     IF (tag="CV")
      SELECT
       FROM code_value cv
       WHERE cv.code_value=cnvtreal(cvs)
       DETAIL
        cset = cnvtstring(cv.code_set)
       WITH nocounter
      ;end select
      SET tag1 = build("CS:",cset,"-CV:",cvs,"-")
     ENDIF
     SET hl7message = build(substring(1,(p1 - 1),hl7message),tag1,uar_get_code_display(cnvtreal(cvs)),
      tag2,substring(p2,size(hl7message),hl7message))
   ENDWHILE
 END ;Subroutine
 DECLARE getnextcsvelt(anything) = vc
 SUBROUTINE getnextcsvelt(anything)
  SET csveltid = (csveltid+ 1)
  RETURN(getelt(nonhl7message,csvsep,csveltid))
 END ;Subroutine
 SET tmp_str = getsegment("MSH")
 EXECUTE oencpm_msglog build2("*** Working on MSH: ",tmp_str,char(0))
 DECLARE msh_seg = vc
 SET msh_seg = findfirstsegment("MSH")
 CALL sethl7field("MSH",21,"PH_SS-NoAck^SS Sender^2.16.840.1.114222.4.10.3^ISO")
 DECLARE trans_type = vc
 DECLARE orig_trans = vc
 SET trans_type = gethl7field("MSH",9)
 SET orig_trans = trans_type
 IF (((trans_type="*A01*") OR (((trans_type="*A04*") OR (trans_type="*A08*")) )) )
  SET trans_type = concat(trim(trans_type),"^ADT_A01")
 ELSEIF (trans_type="*A03*")
  SET trans_type = concat(trim(trans_type),"^ADT_A03")
 ENDIF
 CALL sethl7field("MSH",9,trans_type)
 CALL sethl7field("MSH",11,"P")
 DECLARE evn_seg = vc
 SET evn_seg = findfirstsegment("EVN")
 DECLARE msh_4 = vc
 SET msh_4 = gethl7field("MSH",4)
 CALL sethl7field("EVN",7,msh_4)
 DECLARE pid_seg = vc
 SET pid_seg = findfirstsegment("PID")
 DECLARE pv1_seg = vc
 SET pv1_seg = findfirstsegment("PV1")
 DECLARE pv1_19 = vc
 SET pv1_19 = gethl7field("PID",18)
 CALL sethl7field("PV1",19,pv1_19)
 CALL returnhl7message(0)
 EXECUTE oencpm_msglog build2("*** EXIT HS_SYN_SUR_OUT ***",char(0))
END GO
