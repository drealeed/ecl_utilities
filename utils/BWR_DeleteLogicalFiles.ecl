import utils, lib_thorlib;

fileMatchPattern:='drea::firewalllogs::*'; //no tilde
fileAgeInDays :=0; //only delete matching files older than this many days
runInTestMode:=true; //does not perform actual deletion; just lists files that would be deleted

//when running on hthor, call it this way
resnothor :=utils.FN_DeleteLogicalFiles(fileMatchPattern,fileAgeInDays,runInTestMode);

//when running on thor, call it this way; bug in current HPCC build that causes a dali fault on a thor slave when run,
//even when NOTHOR is specified
resthor:=utils.FN_CreateWorkunit('import utils;utils.FN_DeleteLogicalFiles(\'' 
				+ filematchPattern + '\',' 
				+ fileAgeInDays + ','
				+  if (runIntestMode, 'TRUE','FALSE')
				+ ');','hthor');

cluster:=thorlib.cluster();


output(if (cluster='thor',resthor), named('run_on_thor'));
output(if (cluster='hthor',resnothor),named('run_on_hthor'));
