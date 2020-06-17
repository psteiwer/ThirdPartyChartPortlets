Class ThirdPartyChartPortlets.Highcharts.TreeMapChart Extends ThirdPartyChartPortlets.Highcharts.Base
{

Parameter DisplayName = "Tree Map";

Parameter ChartType = "treemap";

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

	var hcTitle = document.getElementById(containingid+"/settings/titlehc").value;
	var hcSubtitle = document.getElementById(containingid+"/settings/subtitle").value;
	var hcType = this.GetChartType(document.getElementById(containingid+"/settings/chartType").value);

    // case that the query is a CROSSJOIN AND TREEMAP
    // call method to construct the TREEMAP

    // chartData now holds TREE for TREEMAP
    var chartData = ThirdPartyChartPortlets_Highcharts_TreeMapChart_buildTreemap(collables, rowlabels, resultSet);

    // dataLabels and levelIsConstnat and levels needed for proper labels to show up
    Highcharts.chart(containingid+"/chartdiv", {
        series: [{
            type: 'treemap',
            layoutAlgorithm: 'squarified',
            allowDrillToNode: true,
            animationLimit: 1000,
            dataLabels: {
                enabled: false
            },
            levelIsConstant: false,
            levels: [{
                level: 1,
                dataLabels: {
                    enabled: true
                },
                borderWidth: 3
            }],
            turboThreshold: 0,
            data: chartData    // need new
        }],
        subtitle: {
            text: hcSubtitle
        },
        title: {
            text: hcTitle
        }
    });
    return;
}

ClientMethod buildTreemap(collabels, rowlabels, resultSet) [ Language = javascript ]
{
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
				label: chartLabel
			};
			chartData.push(cat_data);
		}
	}
		
	// keep original length of chartData
	// even if we push to chartData, don't worry about the newly added elements
	// since they get added to the end
	var len_chartData = chartData.length;

	// array to keep track of whether "something" was added to chartData or not
	var added_elements = [];

	for (var y=0; y<len_chartData; y++) {
		// fetch the y^th element of chartData; it is an object {}
		var current_node = chartData[y];
		var current_node_labels = current_node["label"].split("/");

		for (var x=0; x<current_node_labels.length-1; x++) {
			// use indexOf to check if the node is in chartData; add if it is not
			if (x==0) {
				// if x is the last index, then this needs no parent since it's the root
				var new_data = {
					name: String(current_node_labels[x]),
					id: String(current_node_labels[x])
					// ,value:0		
				};
			} else {
				var new_data = {
					name: String(current_node_labels[x]),
					id: String(current_node_labels[x]),
					parent: String(current_node_labels[x-1])
					// , value:0
				};
			}

			// if new_data not in added_elements: add to chartData  
			
			var check_boolean = false;

			// currently, the below code is not working at all
			if (added_elements.length == 0)	{
				// add in new_data if added_elements is empty
				chartData.push(new_data);
				added_elements.push(new_data);
			} else {
				for (var q=0; q<added_elements.length; q++) {
					if (JSON.stringify(added_elements[q]) == JSON.stringify(new_data)) {
						check_boolean = true;
						break;
					}
				}

				// if current new_data is not in added_elements, then add to chartData
				if (!check_boolean) {
					chartData.push(new_data);
					added_elements.push(new_data);
				}
			}
		}
	}

    colors = ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1'];
	// only add colors to the root nodes
	// iterate through chartData, add colors to nodes without any parents
	var start_index = chartData.length-added_elements.length;
	var count_num_root = 0;
	var root_node;
	// add colors
	for (var i=start_index; i<chartData.length ; i++) {
		// if the node doesn't have a parent, it's a root node.
		// Add a color
		if (!chartData[i].hasOwnProperty("parent")) {
		    chartData[i].color = colors[(i)%colors.length];
		    count_num_root++;
		    root_node = chartData[i];
		}
	}

	// if there is only 1 root node, assign colors to the immediate child(s) of that node for prettier chart
	if (count_num_root == 1) {
		// iterate through all the nodes, find children whose parent is the sole root node
		for (var i=0; i<chartData.length; i++) {
			if (chartData[i].parent == root_node.id) {
				chartData[i].color = colors[(i)%colors.length];
			}
		}
		delete root_node.color;
	}
	return chartData;
}

}
