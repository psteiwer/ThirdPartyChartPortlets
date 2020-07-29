Class ThirdPartyChartPortlets.Highcharts.RegressionChart Extends ThirdPartyChartPortlets.Highcharts.Base
{

Parameter DisplayName = "Regression";

Parameter ChartType = "regression";

ClientMethod drawChart(resultSet, containingid) [ Language = javascript ]
{
	// in order to eliminate the limit on chart size
	resultSet.maxChartSize = 0;
	
	// getLabel (index, axis) where axis=1 row, 2 col
	// use str.split("/") to parse into array
	// getDimSize(1) row, getDimSize(2) col

	// adjusts the opacity of Highcharts
	// document.getElementById("chartdiv").style.opacity = document.getElementById("opacity").value;

	var collabels = [];
	// retrieve column labels, store into collabels array - access length by .length
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		collabels[j] = resultSet.getLabel(j,2).split("/")[0];
	}

	var rowlabels = [];
	for (var i = 0; i < resultSet.getDimSize(1); ++i) {
		rowlabels[i] = resultSet.getLabel(i,1).toString().split("/")[0];
	}

	var hcType = this.GetChartType(document.getElementById(containingid+"/settings/chartType").value);
	
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
	// collabels contains the names for the series, rowlabels were the categories going onto the axis
	// create data_series array to format the data for Highcharts
	var data_series = [];
	for (var i = 0; i < chartData.length; i++) {
		var new_data = {};
		new_data.name = collabels[i];
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

    hcType = 'scatter';
    
    // update data_series to include a regression line(s)
    var temp = data_series;
    data_series = [];
    for (var i=0; i<temp.length; i++) {
        data_series.push(temp[i]);
        var new_data = {};
        new_data.type = 'line';
        new_data.data = ThirdPartyChartPortlets_Highcharts_RegressionChart_findLineByLeastSquares(temp[i].data);
        new_data.name = temp[i].name + " Regression Line";

        new_data.marker = {enabled: false};
        data_series.push(new_data);
    }
	
	
	// FUNCTIONALITY FOR INVERTING AXIS
	// check invertInput to determine whether or not to invert the x-y axis
	var hcInvert = document.getElementById(containingid+"/settings/invert").value;
	if (hcInvert==0) {
		hcInvert = false;
	} else {
		hcInvert = true;
	}

	// FUNCTIONALITY FOR LOGARITHMIC Y AXIS
	var hcYAxisType = document.getElementById(containingid+"/settings/yAxisType").value;
 
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
			type: hcYAxisType,
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

ClientMethod findLineByLeastSquares(valuesy) [ Language = javascript ]
{
	var sum_x = 0;
	var sum_y = 0;
	var sum_xy = 0;
	var sum_xx = 0;
	var count = 0;
	
	var x = 0;
	var y = 0;
	var values_length = valuesy.length;

	var values_x = [];
	
	for (var v = 0; v < values_length; v++) {
		values_x.push(v);
	}
	
	/*
	 * Calculate the sum for each of the parts necessary.
	 */
	for (var v = 0; v < values_length; v++) {
		x = values_x[v];
		y = valuesy[v];
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
	var result_valuesy = [];
	
	for (var v = 0; v < values_length; v++) {
		x = values_x[v];
		y = x * m + b;
		result_values_x.push(x);
		result_valuesy.push(y);
	}
	return result_valuesy;
}

}
