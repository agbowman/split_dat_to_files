CREATE PROGRAM bhs_prax_format_str_param
 IF (validate(request)=0)
  FREE RECORD request
  RECORD request(
    1 param = vc
  ) WITH protect
 ENDIF
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 param = vc
  ) WITH protect
 ENDIF
 IF (textlen(request->param)=0)
  CALL echo("INVALID REQUEST PARAM...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE formatted_str = vc WITH protect, noconstant(trim(request->param,3))
 DECLARE crlf = vc WITH protect, constant(concat(char(13),char(10)))
 CALL echo(build("UNFORMATTED PARAMETER: ",formatted_str))
 IF (textlen(formatted_str))
  SET formatted_str = replace(formatted_str,"ltpercgt","%",0)
  SET formatted_str = replace(formatted_str,"ltampgt","&",0)
  SET formatted_str = replace(formatted_str,"ltsquotgt","'",0)
  SET formatted_str = replace(formatted_str,"ltscolgt",";",0)
  SET formatted_str = replace(formatted_str,"ltpipgt","|",0)
  SET formatted_str = replace(formatted_str,"ltless","<",0)
  SET formatted_str = replace(formatted_str,"ltgrtr",">",0)
  SET formatted_str = replace(formatted_str,"ltcrlf",crlf,0)
 ENDIF
 CALL echo(build("FORMATTED PARAMETER: ",formatted_str))
 SET reply->param = formatted_str
#exit_script
END GO
