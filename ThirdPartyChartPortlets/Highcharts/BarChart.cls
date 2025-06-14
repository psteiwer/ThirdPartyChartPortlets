Class ThirdPartyChartPortlets.Highcharts.BarChart Extends ThirdPartyChartPortlets.Highcharts.Base
{

Parameter DisplayName = "Bar";

Parameter ChartType = "bar";

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
			cat_data.push({
				y: chartDataPoint,
				originalCell: { row: i, col: j }
			});
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

	var selectedPoint = null;

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
			series: {
				stacking: hcStack,
				point: {
					events: {
						click: function () {
							// Apply style to the selected bar
							if (selectedPoint) {
								selectedPoint.update({
									borderWidth: 0,
									borderColor: null
								}, false);
							}
							this.update({
								borderWidth: 3,
								borderColor: '#000000'
							}, false);
							selectedPoint = this;
							this.series.chart.redraw();

							var row = this.originalCell.row;
							var col = this.originalCell.col;

							var filter = resultSet.getFilterForCells(row+1, col+1);
							var widget=zenPage.getComponentById(containingid.split("/")[0]);
							widget.currFilterSpec=filter;
						}
					}
				}
			},
			columnrange: colrange_plotoptions
		},
		series: data_series
	});

	return;
}

}
