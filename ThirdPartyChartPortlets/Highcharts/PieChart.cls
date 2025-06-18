Class ThirdPartyChartPortlets.Highcharts.PieChart Extends ThirdPartyChartPortlets.Highcharts.Base
{

Parameter DisplayName = "Pie";

Parameter ChartType = "pie";

ClientMethod drawChart(resultSet, containingid) [ Language = javascript ]
{
	resultSet.maxChartSize = 0;

	var collabels = [];
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		collabels[j] = resultSet.getLabel(j, 2).split("/")[0];
	}

	var rowlabels = [];
	for (var i = 0; i < resultSet.getDimSize(1); ++i) {
		rowlabels[i] = resultSet.getLabel(i, 1).split("/")[0];
	}

	var hcTitle = document.getElementById(containingid+"/settings/titlehc").value;
	var hcSubtitle = document.getElementById(containingid+"/settings/subtitle").value;

	var data = [];

	for (var i = 0; i < resultSet.getDimSize(1); i++) {
		for (var j = 0; j < resultSet.getDimSize(2); j++) {
			var label = rowlabels[i];
			var value = resultSet.data.cells[(i) * resultSet.getDimSize(2) + j];
			if (value === "") value = 0;

			data.push({
				name: label,
				y: value,
				originalCell: { row: i, col: j }
			});
		}
	}

	Highcharts.chart(containingid + "/chartdiv", {
		chart: {
			type: 'pie'
		},
		title: {
			text: hcTitle
		},
		subtitle: {
			text: hcSubtitle
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
		},
		accessibility: {
			point: {
				valueSuffix: '%'
			}
		},
		plotOptions: {
			pie: {
				allowPointSelect: true,
				cursor: 'pointer',
				dataLabels: {
					enabled: true,
					format: '<b>{point.name}</b>: {point.percentage:.1f} %'
				},
				point: {
					events: {
						click: function () {
							var row = this.originalCell.row;
							var col = this.originalCell.col;
							var filter = resultSet.getFilterForCells(row + 1, col + 1);
							var widget = zenPage.getComponentById(containingid.split("/")[0]);
							widget.currFilterSpec = filter;
						}
					}
				}
			}
		},
		series: [{
			name: 'Share',
			colorByPoint: true,
			data: data
		}]
	});
}

}
