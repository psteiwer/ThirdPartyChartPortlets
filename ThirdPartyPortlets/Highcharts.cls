Class ThirdPartyPortlets.Highcharts Extends %DeepSee.Component.Portlet.abstractPortlet
{

Method %DrawHTML()
{
    Set ..renderFlag = ..renderFlag + 1
	&html<<div id="#(..%EnclosingDivId())#/chartdiv" style="width:800px; height:600px;"></div>>
#;	&html<>
	&html<<script type='text/javascript' src="http://code.highcharts.com/highcharts.js"></script>>
	&html<<script type='text/javascript' src="http://code.highcharts.com/highcharts-more.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/highcharts-3d.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/modules/heatmap.js"></script>>
	&html<<script type='text/javascript' src="https://code.highcharts.com/modules/treemap.js"></script>>
	
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
	
	// Used for colors in TREEMAP
	var colors = ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1'];

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
	    drawChart(controller,this.id);
        html[html.length] = controller;
    }
    else {
        html[html.length] = 'No data source';
        document.getElementById(this.id+"/chartdiv").innerHTML = html.join('');
    }
    

	function sumArray(arr){
		var sum = 0;
		for (var i=0; i<arr.length; i++){
			sum += arr[i];
		}
		return sum;
	}
	
	function getChartType(chartNumber){
			if (chartNumber == 1){
				return "line";
			}
			if (chartNumber == 2){
				return "bar";
			}
			if (chartNumber == 3){
				return "spline";
			}
			if (chartNumber == 4){
				return "arearangeline";
			}
			if (chartNumber == 5){
				return "columnrange";
			}
			if (chartNumber == 6){
				return "scatter";
			}
			if (chartNumber == 7){
				return "regression";
			}
			if (chartNumber == 8){
				return "treemap";
			}			
	}	
	
	
function drawChart(resultSet,containingid) {
	// in order to eliminate the limit on chart size
	resultSet.maxChartSize = 0;
	
	// console.log(resultSet);
	// getLabel (index, axis) where axis=1 row, 2 col
	// use str.split("/") to parse into array
	// getDimSize(1) row, getDimSize(2) col

	// adjusts the opacity of Highcharts
	// document.getElementById("chartdiv").style.opacity = document.getElementById("opacity").value;

	var col_labels = [];
	// retrieve column labels, store into col_labels array - access length by .length
	for (var j = 0; j < resultSet.getDimSize(2); ++j){
//		console.log(resultSet.getLabel(j,2));
		col_labels[j] = resultSet.getLabel(j,2).split("/")[0];
	}
	//console.log("col_labels", col_labels);

	var row_labels = [];
	for (var i = 0; i < resultSet.getDimSize(1); ++i){
		row_labels[i] = resultSet.getLabel(i,1).toString().split("/")[0];
	}
	//console.log("row_labels", row_labels);

	// obtain the type of Highcharts graph desired
//	var hcType = document.getElementById('highchartsType').value;
	var hcType = getChartType(document.getElementById(containingid+"/settings/chartType").value);

	// for now, CROSSJOIN can only be used as TREEMAP
	if (hcType == "treemap"){
		// case that the query is a CROSSJOIN AND TREEMAP
//		if (!crossjoin){
//			alert("Enter a CROSSJOIN query for TREEMAP.");
//			document.getElementById("text").value = "SELECT NON EMPTY [Measures].[%COUNT] ON 0,NON EMPTY HEAD(NONEMPTYCROSSJOIN([DateOfSale].[Actual].[YearSold].Members,NONEMPTYCROSSJOIN([DateOfSale].[Actual].[MonthSold].Members,[DateOfSale].[Actual].[DaySold].Members)),2000,SAMPLE) ON 1 FROM [HOLEFOODS]";
//			initializePage();
//			return ;
//		} else {
			// call method to construct the TREEMAP

			// chartData now holds TREE for TREEMAP
			var chartData = buildTreemap(col_labels, row_labels, resultSet);

			// dataLabels and levelIsConstnat and levels needed for proper labels to show up
			Highcharts.chart(containingid+"/chartdiv", {
		    series: [{
		        type: 'treemap',
		        layoutAlgorithm: 'squarified',
		        allowDrillToNode: true,
		        animationLimit: 1000,
		        dataLabels: {    enabled: false    },
		        levelIsConstant: false,
		        levels: [{   level: 1,
			            dataLabels: {  enabled: true  },
			            borderWidth: 3      }],		       
		        data: chartData    // need new
		        }],
		    	subtitle: {     text: hcSubtitle    },
		    	title: {    text: hcTitle    }
			});
			return ;
//		}
	}	
	
//	for(var i=0; i<resultSet.data.cells.length;i++){
//		console.log(i, resultSet.data.cells[i]);
//	}

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
	// col_labels contains the names for the series, row_labels were the categories going onto the axis
	// create data_series array to format the data for Highcharts
	var data_series = [];
	for (var i = 0; i < chartData.length; i++){
		var new_data = {};
		new_data.name = col_labels[i];
		new_data.data = chartData[i];

		data_series.push(new_data);
	}

	// determine which Highcharts type to display, and zoom type
	var zoomType = document.getElementById(containingid+"/settings/zoomType").value;

	var hcTitle = document.getElementById(containingid+"/settings/titlehc").value;
	var hcSubtitle = document.getElementById(containingid+"/settings/subtitle").value;
	
	var hcXaxis = document.getElementById(containingid+"/settings/xaxis").value;
	var hcYaxis = document.getElementById(containingid+"/settings/yaxis").value;


	// if hcType == "arearangeline," sort the data for min, max, avg
	if (hcType=="arearangeline"){
		// of the three arrays, need to figure out which is min, max, avg
		// find the sum of each of the arrays to sort

		// We need to contruct two arrays:
		// Range: [min, max], and Data: [avg]
		
		// console.log("Length of data_series", Object.keys(data_series).length);
		if (Object.keys(data_series).length == 3){
			var hcType = "line";

			// find the sum of each of the three arrays
			var sum0 = sumArray(data_series[0].data);
			var sum1 = sumArray(data_series[1].data);
			var sum2 = sumArray(data_series[2].data);
			var sum_array = [sum0, sum1, sum2];

			// create an object for easy pairing sum:array
			var temp_sum_arr = {};
			temp_sum_arr[sum0] = [data_series[0].data, data_series[0].name];
			temp_sum_arr[sum1] = [data_series[1].data, data_series[1].name];
			temp_sum_arr[sum2] = [data_series[2].data, data_series[2].name];

			var min = Math.min(...sum_array);
			var max = Math.max(...sum_array);

			// range array contains [[min,max], [min,max],...]
			var range = [];
			for (var i=0; i<data_series[0].data.length; i++){
				range.push( [ temp_sum_arr[min][0][i], temp_sum_arr[max][0][i] ] );
			}

			// console.log("range", range, range[0], range[1]);

			delete temp_sum_arr[min];
			delete temp_sum_arr[max];

			// now, temp_sum_arr contains only the data value
			// fetch the data value array by calling on the first key
			// // need row_labels?
			// var values = temp_sum_arr[Object.keys(temp_sum_arr)[0]][0];
			// var name_values = temp_sum_arr[Object.keys(temp_sum_arr)[0]][1];

			var values = [];
			for (var i=0; i<data_series[0].data.length; i++){
				values.push( [  temp_sum_arr[Object.keys(temp_sum_arr)[0]][0][i] ] );
			}
			var values_name = temp_sum_arr[Object.keys(temp_sum_arr)[0]][1];

			var new_data_series = [];
			var data_obj = { name: values_name,
							data: values,
							zIndex: 1,
							marker: {
					            fillColor: 'white',
					            lineWidth: 2,
					            lineColor: Highcharts.getOptions().colors[0]  }
							};
			new_data_series.push(data_obj);
			
			var range_obj = { name: 'Range',
							data: range,
							type: 'arearange',
							lineWidth: 0,
							linkedTo: ':previous',
							color: Highcharts.getOptions().colors[0],
							fillOpacity: 0.3,
							zIndex: 0,
							marker: {enabled: false}  };
			new_data_series.push(range_obj);
			data_series = new_data_series;
			

		} else {
			var new_data_series = [];
			data_series = new_data_series;			
			return ;
		}
		// replace data_series with new_data_series
	}


	var colrange_plotoptions = {};
	if (hcType == "columnrange"){
		if (Object.keys(data_series).length == 2){

			var new_data_series = [];

			// find sums of each data_series.data array to find min / max
			var sum0 = sumArray(data_series[0].data);
			var sum1 = sumArray(data_series[1].data);
			// create an object for easy pairing sum:array
			var temp_sum_arr = {};
			temp_sum_arr[sum0] = [data_series[0].data, data_series[0].name];
			temp_sum_arr[sum1] = [data_series[1].data, data_series[1].name];
			var sum_array = [sum0, sum1];

			var min = Math.min(...sum_array);
			var max = Math.max(...sum_array);

			// range array contains [[min,max], [min,max],...]
			var range = [];
			for (var i=0; i<data_series[0].data.length; i++){
				range.push( [ temp_sum_arr[min][0][i], temp_sum_arr[max][0][i] ] );
			}

			var range_obj = { name: temp_sum_arr[min][1] + ' / ' + temp_sum_arr[max][1],
							data: range

							};

			new_data_series.push(range_obj);

			colrange_plotoptions = {
							            dataLabels: {
							                enabled: true,
							                formatter: function () {
							                    return this.y ;    }
							            }
							        }
			data_series = new_data_series;
		}else{
			var new_data_series = [];
			data_series = new_data_series;			
			return ;
		}
	}

	// correction for hcType
	if (hcType == 'regression'){
		hcType = 'scatter';
		// console.log(data_series);

		// update data_series to include a regression line(s)
		var temp = data_series;
		data_series = [];
		for (var i=0; i<temp.length; i++){
			data_series.push(temp[i]);
			var new_data = {};
			new_data.type = 'line';
			new_data.data = findLineByLeastSquares(temp[i].data);
			new_data.name = temp[i].name + " Regression Line";

			new_data.marker = {enabled: false};
			data_series.push(new_data);
		}
	}
	// if hcType == "spline", we need to add labels
//	// hcPlotBands is a global variable
//	if (hcType == "spline"){
//		// fetch the value of the three boxes
//		var hcFrom = document.getElementById("from");
//		var hcTo = document.getElementById("to");
//		var hcText = document.getElementById("plotbandtext");
//
//		console.log("from, to, text", hcFrom, hcTo, hcText)
//
//		// check if there is an input in each and every one of the three boxes
//		if (hcFrom && hcFrom.value && hcTo && hcTo.value && hcText && hcText.value){
//			if (hcAlt){
//				var hcColor = 'rgba(248, 255, 178, 0.7)';
//				hcAlt = false;
//			} else {
//				var hcColor = 'rgba(68, 170, 213, 0.2)';
//				hcAlt = true;
//			}
//			var new_label = {
//								from: hcFrom.value,
//								to: hcTo.value,
//								color: hcColor,
//								label: {
//										text: hcText.value,
//										style: {color:'#606060'}
//										}
//							};
//			hcPlotBands.push(new_label);
//		} else {
//			alert("Error: Write labels for plot bands in all three boxes.");
//		}
//	}


	// FUNCTIONALITY FOR INVERTING AXIS
	// check invertInput to determine whether or not to invert the x-y axis
	var hcInvert = document.getElementById(containingid+"/settings/invert").value;
	if (hcInvert==0){
		hcInvert = false;
	} else {
		hcInvert = true;
	}
 
	// FUNCTIONALITY FOR STACKING
	// hcStack.checked == false if checkbox not checked, true if checked
	var hcStack = document.getElementById(containingid+"/settings/stack").value;
	if (hcStack == 1){
		hcStack= 'normal';
	}else{
		hcStack = '';
	}

	// FUNCTIONALITY FOR 3D
	var hc3d = document.getElementById(containingid+"/settings/3d").value;
	if (hc3d == 1){
		hc3d= { enabled: true, alpha: -10, beta: 15, depth: 50 };
	}else{
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
		text: hcTitle   },
	subtitle: {
		text: hcSubtitle	},
	xAxis: {
		title: {
			text: hcXaxis	},
		categories: row_labels,
		},
	yAxis: {
		title: {
			text: hcYaxis,
		},
		plotBands: hcPlotBands
	},
	legend: {
    },
	tooltip: {
            headerFormat: '<b>{series.name}</b><br>',
            pointFormat: '{point.category}: {point.y}'
    },
	plotOptions: {
			series:{ stacking: hcStack },
			columnrange: colrange_plotoptions
	},
	series: data_series	
	});
	
	//console.log(myChart);

	return ;
}
function buildTreemap(col_labels, row_labels, resultSet){
	// construct array to maintain all the DeepSee data
	var chartData = [];

	// fetch all the data points
	for (var j = 0;j < resultSet.getDimSize(2);++j) {
		for (var i = 0;i < resultSet.getDimSize(1);++i) {
			var chartDataPoint = resultSet.data.cells[(i)*resultSet.getDimSize(2)+j];
			var chartLabel = resultSet.getLabel(i,1).toString();
			var labels = chartLabel.split("/")
			// id is a i_j pairing, guaranteed to be unique for each data point

			// the name/parent/id must be STRING
			var cat_data = {
				// id: "id_" + i + "_" + j,
				name: String(labels[labels.length-1]),
				parent: String(labels[labels.length-2]),
				value: chartDataPoint,
				// label is not a property needed by Highcharts, but we can use it
				label:	chartLabel};
			chartData.push(cat_data);
			//console.log("cat_data", cat_data);
		}
	}
		
	// keep original length of chartData
	// even if we push to chartData, don't worry about the newly added elements
	// since they get added to the end
	var len_chartData = chartData.length;

	// array to keep track of whether "something" was added to chartData or not
	var added_elements = [];

	for (var y=0; y<len_chartData; y++){
		// fetch the y^th element of chartData; it is an object {}
		var current_node = chartData[y];
		var current_node_labels = current_node["label"].split("/");

		for (var x=0; x<current_node_labels.length-1; x++){

			// use indexOf to check if the node is in chartData; add if it is not
			if (x==0){
				// if x is the last index, then this needs no parent since it's the root
				var new_data = {
					name: String(current_node_labels[x]),
					id: String(current_node_labels[x])
					// ,value:0		
				};
			}else {
				var new_data = {
					name: String(current_node_labels[x]),
					id: String(current_node_labels[x]),
					parent: String(current_node_labels[x-1])
					// , value:0
				};
			}

			// if new_data not in added_elements: add to chartData  
			// console.log("new_data", new_data);

			var check_boolean = false;

			// currently, the below code is not working at all
			if (added_elements.length == 0)	{
				// console.log("EMPTY");
				// add in new_data if added_elements is empty
				chartData.push(new_data);
				added_elements.push(new_data);

			} else {
				for (var q=0; q<added_elements.length; q++){
					// console.log("check", added_elements[q], new_data);
					if(JSON.stringify(added_elements[q]) == JSON.stringify(new_data)){
						// console.log("new_data exists in added_elements");
						check_boolean = true;
						break;
					}
				}

				// if current new_data is not in added_elements, then add to chartData
				if (!check_boolean){
					// console.log("push", new_data);
					chartData.push(new_data);
					added_elements.push(new_data);
				}
			}
		}
	}

	// only add colors to the root nodes
	// iterate through chartData, add colors to nodes without any parents
	var start_index = chartData.length-added_elements.length;
	var count_num_root = 0;
	var root_node;
	// add colors
	for (var i=start_index; i<chartData.length ; i++){
		// console.log("color", i, colors[i%10]);

		// if the node doesn't have a parent, it's a root node.
		// Add a color
		if(!chartData[i].hasOwnProperty("parent")){
		    chartData[i].color = colors[(i)%colors.length];
		    count_num_root++;
		    root_node=chartData[i];
		}
	}

	// if there is only 1 root node, assign colors to the immediate child(s) of that node for prettier chart
	if(count_num_root == 1){
		// iterate through all the nodes, find children whose parent is the sole root node
		for (var i=0; i<chartData.length; i++){
			if(chartData[i].parent == root_node.id){
				chartData[i].color = colors[(i)%colors.length];
			}
		}
		delete root_node.color;
	}
	return chartData;
}

// method to find regression line given a set of data
// parameters are each an array of data
function findLineByLeastSquares(values_y) {
    var sum_x = 0;
    var sum_y = 0;
    var sum_xy = 0;
    var sum_xx = 0;
    var count = 0;

    var x = 0;
    var y = 0;
    var values_length = values_y.length;

    var values_x = [];

    for (var v = 0; v < values_length; v++) {
    	values_x.push(v);
    }

    /*
     * Calculate the sum for each of the parts necessary.
     */
    for (var v = 0; v < values_length; v++) {
        x = values_x[v];
        y = values_y[v];
        sum_x += x;
        sum_y += y;
        sum_xx += x*x;
        sum_xy += x*y;
        count++;
    }

    /*
     * Calculate m and b for the formular:
     * y = x * m + b
     */
    var m = (count*sum_xy - sum_x*sum_y) / (count*sum_xx - sum_x*sum_x);
    var b = (sum_y/count) - (m*sum_x)/count;

    /*
     * We will make the x and y result line now
     */
    var result_values_x = [];
    var result_values_y = [];

    for (var v = 0; v < values_length; v++) {
        x = values_x[v];
        y = x * m + b;
        result_values_x.push(x);
        result_values_y.push(y);
    }
    return result_values_y;
}
}

ClassMethod %OnGetPortletSettings(Output pInfo As %List, ByRef pSettings) As %Status
{
  Kill pInfo
  
  Set pInfo($I(pInfo)) = $LB("chartType","1",
 "DRILL^Line:1,Bar:2, Spline with Plot Bands:3, Area Range and Line:4, Column Range:5, Scatter Plot:6, Scatter with Regression Line:7, Tree Map:8",
 "Chart Type","List of Chart Types")
 
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
	var div=document.getElementById(this.id+"/chartdiv")
	div.style.width=width.toString()+"px"
	div.style.height=height.toString()+"px"
	if (div.dataset.highchartsChart) {
		Highcharts.charts[div.dataset.highchartsChart].reflow()
	}
}

}
