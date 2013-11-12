import $,LIB_date,lib_stringlib,lib_fileservices, lib_thorlib;

export FN_DeleteLogicalFiles(STRING matchPattern='nothingfailsafe', INTEGER fileAgeInDays=0,boolean test=false) := FUNCTION

layout_with_superowner := {
   lib_fileservices.FsFilenameRecord;
   INTEGER superOwnerCount;
   INTEGER daysOld := -1;
	 STRING deleteString := '';
};

matchingRecs                := FileServices.LogicalFileList(matchPattern);
STRING currentDate := stringlib.getDateYYYYMMDD();

layout_with_superowner addSOCount(recordof(matchingrecs) L) := TRANSFORM
   SELF.superOwnerCount := COUNT(FileServices.LogicalFileSuperOwners('~' + L.name));
   STRING modDate := L.modified[1..4] + L.modified[6..7] + L.modified[9..10];
   SELF.daysOld := LIB_Date.DaysApart(modDate, currentDate);
	 SELF.deleteString :='FileServices.DeleteLogicalFile(\'~' + l.name + '\');';
   SELF := L;
END;

ds1 := PROJECT(matchingRecs, addSoCount(LEFT));
ds2:= ds1(fileAgeInDays=0 or daysOld>fileAgeInDays);

ds3 := ROLLUP(ds2,true,TRANSFORM(recordof(ds2),
SELF.deleteString:=left.deleteString + right.deleteString;
SELF:=LEFT;)
);

deleteWorkunit:=if (count(ds3) > 0, APPLY(ds3, FileServices.DeleteLogicalFile('~' + name)));

deleteAction:=if(test,output(ds3),
							deleteWorkunit
							);

return when(ds3,output(matchpattern));
END;