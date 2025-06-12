CREATE PROGRAM cclocdmerge:dba
 PAINT
 FREE RECORD ocd_list
 RECORD ocd_list(
   1 qual[*]
     2 ocd_num = i4
 )
 SET addmore = "Y"
 SET mergecnt = 0
 CALL video(r)
 CALL box(1,1,23,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM cclocdmerge")
 CALL text(2,50,concat("MiniDic: ",trim(minidic)))
 CALL clear(3,2,78)
 CALL text(03,05,"Program to Create Batch Export File From Existing OCDs")
 CALL video(n)
 SET t_file = cnvtlower(concat("ocdobj",ocdnumstring,".txt"))
 SET batchfile = concat("ocddir:",t_file)
 SET stat = findfile(batchfile)
 IF (stat=1)
  SET mline = concat("An ",trim(t_file)," file already exists.")
  CALL text(8,5,mline)
  CALL text(9,5,"You can Append to this file or Delete it and create a new one.")
  CALL text(10,5,"Enter A to APPEND to the existing file")
  CALL text(11,5,"Enter D to DELETE ALL VERSIONS of the file: ")
  CALL accept(11,48,"P;CU","A"
   WHERE curaccept IN ("A", "D"))
  IF (curaccept="D")
   SET rstat = 1
   WHILE (rstat=1)
     SET rstat = remove(batchfile)
   ENDWHILE
  ENDIF
 ENDIF
 CALL clear(8,2,78)
 CALL clear(9,2,78)
 CALL clear(10,2,78)
 CALL clear(11,2,78)
 WHILE (addmore="Y")
   CALL text(8,05,"Enter the numbers of the OCDs you want to merge into one baseline OCD")
   CALL text(10,05,"                   OCD Number")
   CALL accept(10,35,"N(6)",0)
   SET mergecnt = (mergecnt+ 1)
   IF (mod(mergecnt,10)=1)
    SET stat = alterlist(ocd_list->qual,(mergecnt+ 9))
   ENDIF
   SET ocd_list->qual[mergecnt].ocd_num = curaccept
   SET displayline = (mod(mergecnt,10)+ 12)
   CALL clear(displayline,5,20)
   CALL clear((displayline+ 1),5,20)
   CALL text(displayline,10,cnvtstring(ocd_list->qual[mergecnt].ocd_num))
   CALL text(11,05,"Enter Another OCD Number? Y/N")
   CALL accept(11,35,"P;CU","Y")
   SET addmore = curaccept
 ENDWHILE
 SET stat = alterlist(ocd_list->qual,mergecnt)
 DECLARE ocdmergestring = c6
 DECLARE mergedictionary = c30
 FOR (mcnt = 1 TO mergecnt)
   SET ocdmergestring = fillstring(6," ")
   SET mergedictionary = fillstring(30," ")
   SET mergenum = ocd_list->qual[mcnt].ocd_num
   SET ocdmergestring = format(mergenum,"######;rp0")
   SET mergeminidic = cnvtlower(concat("dicocd",ocdmergestring,".dat"))
   IF (cursys="AIX")
    SET logical mergedir value(concat(trim(logical("cer_ocd")),"/",ocdmergestring))
   ELSE
    SET cerocd = logical("cer_ocd")
    SET len = findstring("]",cerocd)
    SET line = concat(substring(1,(len - 1),cerocd),ocdmergestring,"]")
    SET logical mergedir line
   ENDIF
   FREE DEFINE dicocd
   FREE SET mergedictionary
   SET mergedictionary = concat("mergedir:",mergeminidic)
   SET stat = findfile(mergedictionary)
   IF (stat=1)
    DEFINE dicocd value(mergedictionary)
    SELECT INTO value(batchfile)
     obj = concat(trim(dpocd.object_name),".",trim(dpocd.object))
     FROM dprotectocd dpocd
     WITH noheading, append
    ;end select
   ENDIF
 ENDFOR
 FREE DEFINE dicocd
END GO
