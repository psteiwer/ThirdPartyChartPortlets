Class ThirdPartyChartPortlets.Highcharts.AreaRangeLineChart Extends ThirdPartyChartPortlets.Highcharts.Highcharts
{

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


    // if hcType == "arearangeline," sort the data for min, max, avg
	// of the three arrays, need to figure out which is min, max, avg
	// find the sum of each of the arrays to sort
    // We need to contruct two arrays:
    // Range: [min, max], and Data: [avg]
    
    if (Object.keys(data_series).length == 3) {
        var hcType = "line";

        // find the sum of each of the three arrays
        var sum0 = this.sumArray(data_series[0].data);
        var sum1 = this.sumArray(data_series[1].data);
        var sum2 = this.sumArray(data_series[2].data);
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
        for (var i=0; i<data_series[0].data.length; i++) {
            range.push( [ temp_sum_arr[min][0][i], temp_sum_arr[max][0][i] ] );
        }

        // console.log("range", range, range[0], range[1]);

        delete temp_sum_arr[min];
        delete temp_sum_arr[max];

        // now, temp_sum_arr contains only the data value
        // fetch the data value array by calling on the first key
        // // need rowlabels?
        // var values = temp_sum_arr[Object.keys(temp_sum_arr)[0]][0];
        // var name_values = temp_sum_arr[Object.keys(temp_sum_arr)[0]][1];

        var values = [];
        for (var i=0; i<data_series[0].data.length; i++) {
            values.push( [  temp_sum_arr[Object.keys(temp_sum_arr)[0]][0][i] ] );
        }
        var values_name = temp_sum_arr[Object.keys(temp_sum_arr)[0]][1];

        var new_data_series = [];
        var data_obj = {
            name: values_name,
            data: values,
            zIndex: 1,
            marker: {
                fillColor: 'white',
                lineWidth: 2,
                lineColor: Highcharts.getOptions().colors[0]
            }
        };
        new_data_series.push(data_obj);
        
        var range_obj = {
            name: 'Range',
            data: range,
            type: 'arearange',
            lineWidth: 0,
            linkedTo: ':previous',
            color: Highcharts.getOptions().colors[0],
            fillOpacity: 0.3,
            zIndex: 0,
            marker: {
                enabled: false
            }
        };
        new_data_series.push(range_obj);
        data_series = new_data_series;
    } else {
        var new_data_series = [];
        data_series = new_data_series;
    }
    // replace data_series with new_data_series

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

}
