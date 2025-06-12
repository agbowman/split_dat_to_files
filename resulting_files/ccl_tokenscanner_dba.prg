CREATE PROGRAM ccl_tokenscanner:dba
 IF (validate(request->source," ")=" ")
  RECORD request(
    1 source = gvc
    1 ignorewhitespace = i2
  )
  RECORD reply(
    1 token[*]
      2 value = vc
      2 isliteral = i4
      2 iscomment = i4
  )
 ENDIF
 DECLARE dummyvar = vc WITH constant(trim(" ")), protect
 DECLARE _null_ = c1 WITH constant(char(0)), protect
 DECLARE _literalind = i4 WITH noconstant(false), protect
 DECLARE _commentind = i4 WITH noconstant(false), protect
 DECLARE _tokenindex = i4 WITH noconstant(0), protect
 DECLARE _tokenvalue = vc WITH noconstant(trim(" ")), notrim, protect
 DECLARE _scansource = vc WITH noconstant(trim(" ")), protect
 DECLARE _scanindex = i4 WITH noconstant(0), protect
 DECLARE _stat = i4 WITH noconstant(0), protect
 SET _scansource = request->source
 CALL scan(dummyvar)
 CALL echorecord(reply)
 SUBROUTINE (scan(dummyvar=vc) =null WITH protect)
   DECLARE scansourcelength = i4 WITH noconstant(textlen(_scansource)), private
   DECLARE char = c1 WITH noconstant(""), private
   DECLARE literaldelimiter = c1 WITH noconstant(trim(" ")), private
   DECLARE commentdelimiter = vc WITH noconstant(trim(" ")), private
   DECLARE parameterind = i4 WITH noconstant(false), private
   DECLARE parametertextind = i4 WITH noconstant(false), private
   DECLARE parametertextlen = i4 WITH noconstant(0), private
   SET stat = alterlist(reply->token,10)
   FOR (_scanindex = 1 TO scansourcelength)
    SET char = notrim(substring(_scanindex,1,_scansource))
    IF (char != "'"
     AND char != "^"
     AND char != '"'
     AND char != "~"
     AND char != "/"
     AND char != char(10)
     AND ((_literalind) OR (_commentind))
     AND parametertextind != true)
     SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
    ELSE
     CASE (char)
      OF "'":
      OF "^":
      OF '"':
      OF "~":
       IF (_commentind)
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       ELSE
        IF (((_literalind) OR (parameterind)) )
         SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
         IF (char=literaldelimiter)
          CALL flushtoken(dummyvar)
          SET _literalind = false
         ENDIF
        ELSE
         CALL flushtoken(dummyvar)
         SET _literalind = true
         SET literaldelimiter = char
         SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
        ENDIF
       ENDIF
      OF ";":
       IF (parameterind != true)
        CALL flushtoken(dummyvar)
        SET _commentind = true
        SET commentdelimiter = char
       ENDIF
       SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
      OF "/":
       IF (((_literalind) OR (parameterind)) )
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       ELSE
        IF (_commentind)
         SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
         IF (peekpreviousprevious(dummyvar) != "/"
          AND peekprevious(dummyvar)="*"
          AND commentdelimiter="/*")
          CALL flushtoken(dummyvar)
          SET _commentind = false
         ENDIF
        ELSE
         IF (peeknext(dummyvar)="*")
          CALL flushtoken(dummyvar)
         ENDIF
         SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
        ENDIF
       ENDIF
      OF "*":
       SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       IF (parameterind=false)
        IF (peekprevious(dummyvar)="/")
         SET _commentind = true
         SET commentdelimiter = _tokenvalue
        ENDIF
       ENDIF
      OF char(10):
       IF (((_literalind) OR (parameterind)) )
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       ELSE
        IF (_commentind=false
         AND _tokenvalue != char(13))
         CALL flushtoken(dummyvar)
        ENDIF
        IF (validate(request->ignorewhitespace,0)=0)
         SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
        ENDIF
        IF (_commentind)
         IF (commentdelimiter=";")
          CALL flushtoken(dummyvar)
          SET _commentind = false
         ENDIF
        ELSE
         CALL flushtoken(dummyvar)
        ENDIF
       ENDIF
      OF "-":
       IF (parametertextind=false)
        CALL flushtoken(dummyvar)
       ENDIF
       SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       IF (peeknext(dummyvar) != ">")
        IF (parametertextind=false)
         CALL flushtoken(dummyvar)
        ENDIF
       ENDIF
      OF ">":
       IF (_tokenvalue="-")
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
        IF (parametertextind=false)
         CALL flushtoken(dummyvar)
        ENDIF
       ELSE
        IF (parametertextind=false)
         CALL flushtoken(dummyvar)
        ENDIF
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
        IF (parametertextind=false)
         CALL flushtoken(dummyvar)
        ENDIF
       ENDIF
      OF " ":
      OF "(":
      OF ")":
      OF ",":
      OF "[":
      OF "]":
      OF "{":
      OF "}":
      OF "+":
      OF "=":
      OF "<":
      OF ":":
      OF ".":
      OF "!":
      OF "%":
      OF "$":
      OF "&":
      OF "|":
      OF "@":
      OF char(9):
      OF char(13):
       IF (char="@")
        IF (parameterind)
         IF (parametertextind=true
          AND parametertextlen=textlen(_tokenvalue))
          SET parameterind = false
          SET parametertextind = false
         ENDIF
        ELSE
         SET parameterind = true
         SET parametertextlen = 0
        ENDIF
       ENDIF
       IF (parametertextind=false)
        IF (parameterind=true
         AND char=":")
         SET parametertextlen = cnvtint(_tokenvalue)
        ENDIF
        CALL flushtoken(dummyvar)
        SET _literalind = false
       ENDIF
       IF (((validate(request->ignorewhitespace,0)=0) OR (validate(request->ignorewhitespace,0)=1
        AND ichar(char) > ichar(" "))) )
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       ENDIF
       IF (char != char(13))
        IF (parametertextind=false)
         CALL flushtoken(dummyvar)
        ENDIF
       ENDIF
       IF (parameterind)
        IF (char=":")
         SET parametertextind = true
         SET _literalind = true
        ENDIF
       ENDIF
      ELSE
       IF (((validate(request->ignorewhitespace,0)=0) OR (validate(request->ignorewhitespace,0)=1
        AND ichar(char) > ichar(" "))) )
        SET _tokenvalue = notrim(concat(notrim(_tokenvalue),notrim(char)))
       ENDIF
     ENDCASE
    ENDIF
   ENDFOR
   CALL flushtoken(dummyvar)
   SET _stat = alterlist(reply->token,_tokenindex)
 END ;Subroutine
 SUBROUTINE (flushtoken(dummyvar=vc) =null WITH protect)
   IF (_tokenvalue != _null_
    AND textlen(_tokenvalue) > 0)
    SET _tokenindex += 1
    IF (_tokenindex > size(reply->token,5))
     SET _stat = alterlist(reply->token,(_tokenindex+ 9))
    ENDIF
    SET reply->token[_tokenindex].value = notrim(_tokenvalue)
    SET reply->token[_tokenindex].isliteral = _literalind
    SET reply->token[_tokenindex].iscomment = _commentind
    SET _tokenvalue = trim(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE (peeknext(dummyvar=vc) =c1 WITH protect)
   RETURN(substring((_scanindex+ 1),1,_scansource))
 END ;Subroutine
 SUBROUTINE (peekprevious(dummyvar=vc) =c1 WITH protect)
   RETURN(substring((_scanindex - 1),1,_scansource))
 END ;Subroutine
 SUBROUTINE (peekpreviousprevious(dummyvar=vc) =c1 WITH protect)
   RETURN(substring((_scanindex - 2),1,_scansource))
 END ;Subroutine
END GO
