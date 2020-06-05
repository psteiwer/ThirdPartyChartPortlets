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
	&html<<script type='text/javascript' src="http://code.highcharts.com/highcharts.js"></script>>
	&html<<script type='text/javascript' src="http://code.highcharts.com/highcharts-more.js"></script>>
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

ClientMethod getChartType(chartType) [ Language = javascript ]
{
	if (chartType == "LineChart") {
		return "line";
	} else if (chartType == "BarChart") {
		return "bar";
	} else if (chartType == "SplineChart") {
		return "spline";
	} else if (chartType == "AreaRangeLineChart") {
		return "arearangeline";
	} else if (chartType == "ColumnRangeChart") {
		return "columnrange";
	} else if (chartType == "ScatterChart") {
		return "scatter";
	} else if (chartType == "RegressionChart") {
		return "regression";
	} else if (chartType == "TreeMapChart") {
		return "treemap";
	}
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

ClientMethod drawChart(resultSet, containingid) [ Language = javascript ]
{
	// in order to eliminate the limit on chart size
	resultSet.maxChartSize = 0;
	
	// getLabel (index, axis) where axis=1 row, 2 col
	// use str.split("/") to parse into array
	// getDimSize(1) row, getDimSize(2) col

	// adjusts the opacity of Highcharts
	// document.getElementById("chartdiv").style.opacity = document.getElementById("opacity").value;

	var collables = [];
	// retrieve column labels, store into collables array - access length by .length
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		collables[j] = resultSet.getLabel(j,2).split("/")[0];
	}

	var rowlabels = [];
	for (var i = 0; i < resultSet.getDimSize(1); ++i) {
		rowlabels[i] = resultSet.getLabel(i,1).toString().split("/")[0];
	}

	var hcType = this.getChartType(document.getElementById(containingid+"/settings/chartType").value);
	
	// initialize the variable to hold onto all the DeepSee data which is in a 2D array
	var chartData = [];
	// fetch all the data points
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		var cat_data = [];
		for (var i = 0; i < resultSet.getDimSize(1); ++i) {
			var chartDataPoint = resultSet.data.cells[(i)*resultSet.getDimSize(2)+j];
			if(chartDataPoint == ""){
				chartDataPoint = 0;
			}
			cat_data.push(chartDataPoint);
		}
		chartData.push(cat_data);
	}

	// prepare the data to feed into Highcharts template
	// collables contains the names for the series, rowlabels were the categories going onto the axis
	// create data_series array to format the data for Highcharts
	var data_series = [];
	for (var i = 0; i < chartData.length; i++) {
		var new_data = {};
		new_data.name = collables[i];
		new_data.data = chartData[i];

		data_series.push(new_data);
	}

	// determine which Highcharts type to display, and zoom type
	var zoomType = document.getElementById(containingid+"/settings/zoomType").value;

	var hcTitle = document.getElementById(containingid+"/settings/titlehc").value;
	var hcSubtitle = document.getElementById(containingid+"/settings/subtitle").value;
	
	var hcXaxis = document.getElementById(containingid+"/settings/xaxis").value;
	var hcYaxis = document.getElementById(containingid+"/settings/yaxis").value;

	
	var colrange_plotoptions = {};
	
	
	// FUNCTIONALITY FOR INVERTING AXIS
	// check invertInput to determine whether or not to invert the x-y axis
	var hcInvert = document.getElementById(containingid+"/settings/invert").value;
	if (hcInvert==0) {
		hcInvert = false;
	} else {
		hcInvert = true;
	}
 
	// FUNCTIONALITY FOR STACKING
	// hcStack.checked == false if checkbox not checked, true if checked
	var hcStack = document.getElementById(containingid+"/settings/stack").value;
	if (hcStack == 1) {
		hcStack = 'normal';
	} else {
		hcStack = '';
	}

	// FUNCTIONALITY FOR 3D
	var hc3d = document.getElementById(containingid+"/settings/3d").value;
	if (hc3d == 1) {
		hc3d = { enabled: true, alpha: -10, beta: 15, depth: 50 };
	} else {
		hc3d = {};
	}

	var myChart = Highcharts.chart(containingid+"/chartdiv", {
		chart: {
			type: hcType,
			options3d: hc3d,
			zoomType: zoomType,
			inverted: hcInvert
		},
		title: {
			text: hcTitle
		},
		subtitle: {
			text: hcSubtitle
		},
		xAxis: {
			title: {
				text: hcXaxis
			},
			categories: rowlabels,
		},
		yAxis: {
			title: {
				text: hcYaxis,
			},
			plotBands: this.hcPlotBands
		},
		legend: {
		},
		tooltip: {
			headerFormat: '<b>{series.name}</b><br>',
			pointFormat: '{point.category}: {point.y}'
		},
		plotOptions: {
			series:{
				stacking: hcStack
			},
			columnrange: colrange_plotoptions
		},
		series: data_series
	});

	return;
}

ClassMethod %OnGetPortletSettings(Output pInfo As %List, ByRef pSettings) As %Status
{
  Kill pInfo
  
  Set tChartTypes="DRILL^Line:LineChart,Bar:BarChart, Spline with Plot Bands:SplineChart, Area Range and Line:AreaRangeLineChart, Column Range:ColumnRangeChart, Scatter Plot:ScatterChart, Scatter with Regression Line:RegressionChart, Tree Map:TreeMapChart"
  Set tCustomChartTypes=##class(ThirdPartyChartPortlets.Highcharts.Highcharts).GetCustomChartTypes()
  Set pInfo($I(pInfo)) = $LB("chartType","LineChart",tChartTypes_tCustomChartTypes,"Chart Type","List of Chart Types")
 
  set pInfo($I(pInfo)) = $LB("invert","0","%Boolean","Invert Axis","Invert the x-y axis")
  set pInfo($I(pInfo)) = $LB("3d","0","%Boolean","3D","Display in 3D")
  set pInfo($I(pInfo)) = $LB("stack","0","%Boolean","Stack","Stack the data")
  
  set pInfo($I(pInfo)) = $LB("zoomType","","ENUM^None:noZoom, X:x, Y:y, X-Y:xy","Zoom","Select the type of zoom")
  
  set pInfo($I(pInfo)) = $LB("titlehc","","%String","Title","Insert title here")
  set pInfo($I(pInfo)) = $LB("subtitle","","%String","Subtitle","Insert subtitle here")
  set pInfo($I(pInfo)) = $LB("xaxis","","%String","X-Axis","Label the x-axis")
  set pInfo($I(pInfo)) = $LB("yaxis","","%String","Y-Axis","Label the y-axis")
     
  Quit pInfo
}

ClassMethod GetCustomChartTypes() As %String
{
	Set tRes=""

	Set tSQL="SELECT * FROM %Dictionary.CompiledClass WHERE parent='ThirdPartyChartPortlets.Highcharts.Highcharts'"
	Set tSQLRS=##class(%SQL.Statement).%ExecDirect(,tSQL)
	While tSQLRS.%Next() {
		Set tClass=tSQLRS.%Get("ID")
		Set tChartType=$parameter(tClass,"ChartType")
		// Need to get a real chart index here
		Set tRes=tRes_","_tChartType_":1000"
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
