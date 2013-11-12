import $,lib_stringlib,lib_thorlib;
export FN_CreateWorkunit(STRING ecl,STRING cluster='thor') := FUNCTION
//endpoint := 'http://10.173.147.1:8010/WsWorkunits?ver_=1.44';
endpoint :='http://' + Stringlib.StringFindReplace(thorlib.daliServers(),'7070','8010') + '/WsWorkunits?ver_=1.27';
layout_wucreate_in := {
		 INTEGER AddDrilldownFields {XPATH('AddDrilldownFields')} := 0;
		STRING QueryText {XPATH('QueryText'), MAXLENGTH(1024)} := ecl;
};
layout_wucreate_out := {
   STRING wuid {XPATH('Wuid'), MAXLENGTH(20)};
   STRING owner {XPATH('Owner'), MAXLENGTH(20)};
	 };
wucreateResult := SOAPCALL(
   endpoint,
   'WUCreateAndUpdate',
   layout_wucreate_in,
   layout_wucreate_out,
   LITERAL,
   XPATH('WUUpdateResponse/Workunit')
);


layout_WUSubmit_in := {
   STRING Wuid {XPATH('Wuid'), MAXLENGTH(20)} := wucreateResult.wuid;
   STRING Cluster {XPATH('Cluster'), MAXLENGTH(24)} := cluster;
   STRING Queue {XPATH('Queue'), MAXLENGTH(24)} := 'eclserver_queue';
   INTEGER MaxRunTime {XPATH('MaxRunTime')} := 0;
   INTEGER BlockTillFinishTimer {XPATH('BlockTillFinishTimer')} := 0;
   INTEGER SyntaxCheck {XPATH('SyntaxCheck')} := 0;
   STRING previous {MAXLENGTH(20)} := wucreateResult.wuid;
};
layout_WUSubmit_out := {
   STRING wuid {XPATH('Wuid'), MAXLENGTH(20)};
};
wuSubmitResult := SOAPCALL(
   endpoint,
   'WUSubmit',
   layout_WUSubmit_in,
   layout_WUSubmit_out,
   LITERAL,
   XPATH('WUSubmitResponse/Workunit')
);
layout_WUWait_in := {
   STRING Wuid {XPATH('Wuid'), MAXLENGTH(20)} := wucreateResult.wuid;
   INTEGER WaitComplete {XPATH('Wait')} := 30000;
   INTEGER ReturnOnWait {XPATH('ReturnOnWait')} := 0;
   STRING previous {MAXLENGTH(20)} := wuSubmitResult.wuid;
};
layout_WUWait_out := {
   STRING wuid {XPATH('Wuid'), MAXLENGTH(20)};
   STRING stateid {XPATH('StateID'), MAXLENGTH(10)};
};
wuWaitResult := SOAPCALL(
   endpoint,
	'WUWaitComplete',
   layout_WUWait_in,
   layout_WUWait_out,
   LITERAL,
   XPATH('WUWaitResponse')
);
layout_WUInfo_in := {
   STRING Wuid {XPATH('Wuid'), MAXLENGTH(20)} := wucreateResult.wuid;
   STRING previous {MAXLENGTH(20)} := wuWaitResult.wuid;
};
layout_WUInfo_out := {
   STRING wuid {XPATH('Wuid'), MAXLENGTH(20)};
   STRING stateid {XPATH('StateID'), MAXLENGTH(10)};
   STRING state {XPATH('State'), MAXLENGTH(10)};
};
wuInfoResult := SOAPCALL(
   endpoint,
   'WUInfo',
   layout_WUInfo_in,
   layout_WUInfo_out,
   LITERAL,
   XPATH('WUInfoResponse/Workunit')
);
return wuInfoResult;
END;
