Class ThirdPartyChartPortlets.Highcharts.Highcharts Extends %DeepSee.Component.Portlet.abstractPortlet
{

Method %DrawHTML()
{
    Set ..renderFlag = ..renderFlag + 1
	&html<<div id="#(..%EnclosingDivId())#/chartdiv" style="width:800px; height:600px;"></div>>
	
	Do ..DrawSRCs()
	
	Do ..DrawSettings()
}

Method DrawSRCs()
{
	&html<<script type='text/javascript' src="https://code.highcharts.com/highcharts.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/highcharts-more.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/highcharts-3d.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/modules/heatmap.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/modules/treemap.js"></script>>
}

Method DrawSettings()
{
	&html<<input id="#(..%EnclosingDivId())#/settings/chartType" type='hidden' value='#(..settings("chartType"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/invert" type='hidden' value='#(..settings("invert"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/3d" type='hidden' value='#(..settings("3d"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/stack" type='hidden' value='#(..settings("stack"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/yAxisType" type='hidden' value='#(..settings("yAxisType"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/titlehc" type='hidden' value='#(..settings("titlehc"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/subtitle" type='hidden' value='#(..settings("subtitle"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/xaxis" type='hidden' value='#(..settings("xaxis"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/yaxis" type='hidden' value='#(..settings("yaxis"))#'>  </input>>
	&html<<input id="#(..%EnclosingDivId())#/settings/zoomType" type='hidden' value='#(..settings("zoomType"))#'>  </input>>
}

ClientMethod renderContents() [ Language = javascript ]
{
	var html = [];

	// global variables used for plotbands
	// hcAlt is to alternate the colors of the plotbands
	var hcPlotBands = [];
	var hcAlt = false;
	
    var crossjoin = false;
	
    // do we have a data controller?
    var controller = this.getController();
    if (null == controller) {
        // try to connect to dataController
        this.connectToController();
        controller = this.getController();
    }
    if (controller) {
	    this.dispatchDrawChart(controller,this.id);
        html[html.length] = controller;
    }
    else {
        html[html.length] = 'No data source';
        document.getElementById(this.id+"/chartdiv").innerHTML = html.join('');
    }
}

ClientMethod sumArray(arr) [ Language = javascript ]
{
	var sum = 0;
	for (var i=0; i<arr.length; i++) {
		sum += arr[i];
	}
	
	return sum;
}

Method GetChartType(chartType) As %String [ ZenMethod ]
{
	Quit $Parameter("ThirdPartyChartPortlets.Highcharts."_chartType,"ChartType")
}

ClientMethod dispatchDrawChart(resultSet, containingid) [ Language = javascript ]
{
	var chartType=document.getElementById(containingid+"/settings/chartType").value;
	
	// Dynamically call drawChart for selected chart type.
	var drawFunction=new Function("return ThirdPartyChartPortlets_Highcharts_"+chartType+"_drawChart");
	drawFunction=drawFunction.call();
	drawFunction.call(this,resultSet,containingid);
	
	return;
}

ClassMethod %OnGetPortletSettings(Output pInfo As %List, ByRef pSettings) As %Status
{
  Kill pInfo
  
  Set tChartTypes=##class(ThirdPartyChartPortlets.Highcharts.Highcharts).GetCustomChartTypes()
  Set pInfo($I(pInfo)) = $LB("chartType","LineChart",tChartTypes,"Chart Type","List of Chart Types")
 
  set pInfo($I(pInfo)) = $LB("invert","0","%Boolean","Invert Axis","Invert the x-y axis")
  set pInfo($I(pInfo)) = $LB("3d","0","%Boolean","3D","Display in 3D")
  set pInfo($I(pInfo)) = $LB("stack","0","%Boolean","Stack","Stack the data")

  set pInfo($I(pInfo)) = $LB("yAxisType","linear","ENUM^Linear:linear, Logarithmic:logarithmic","Y Axis Type","Y Axis scale type")
  set pInfo($I(pInfo)) = $LB("zoomType","","ENUM^None:noZoom, X:x, Y:y, X-Y:xy","Zoom","Select the type of zoom")
  
  set pInfo($I(pInfo)) = $LB("titlehc","","%String","Title","Insert title here")
  set pInfo($I(pInfo)) = $LB("subtitle","","%String","Subtitle","Insert subtitle here")
  set pInfo($I(pInfo)) = $LB("xaxis","","%String","X-Axis","Label the x-axis")
  set pInfo($I(pInfo)) = $LB("yaxis","","%String","Y-Axis","Label the y-axis")
     
  Quit pInfo
}

ClassMethod GetCustomChartTypes() As %String
{
	Set tRes="DRILL^"

	Set tSQL="SELECT * FROM %Dictionary.CompiledClass WHERE Super='ThirdPartyChartPortlets.Highcharts.Base'"
	Set tSQLRS=##class(%SQL.Statement).%ExecDirect(,tSQL)
	While tSQLRS.%Next() {
		Set tClass=tSQLRS.%Get("ID")
		Set tDisplayName=$parameter(tClass,"DisplayName")
		// Need to get a real chart index here
		If (tDisplayName'="") {
			Set tRes=tRes_$select(tRes'="DRILL^":",",1:"")_tDisplayName_":"_$piece(tClass,".",*)
		}
	}

	Quit tRes
}

/// Notification that a filter has changed.
/// Subclass can implement this, if they wish.<br/>
/// <var>refresh</var> inidicates if the display should be refreshed.<br/>
/// <var>widget</var> is the containing widget object.<br/>
ClientMethod onApplyFilters(refresh, widget) [ Language = javascript ]
{
	this.renderContents();
}

/// Notification from the containing widget that the page is loaded or the widget is resized.
/// Subclass can implement this, if they wish.
ClientMethod adjustContentSize(load, width, height) [ Language = javascript ]
{
	console.log("getelement 6");
	var div=document.getElementById(this.id+"/chartdiv")
	div.style.width=width.toString()+"px"
	div.style.height=height.toString()+"px"
	if (div.dataset.highchartsChart) {
		Highcharts.charts[div.dataset.highchartsChart].reflow()
	}
}

}
