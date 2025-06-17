Class ThirdPartyChartPortlets.Mapbox Extends %DeepSee.Component.Portlet.abstractPortlet
{

Method %DrawHTML()
{
    Set ..renderFlag = ..renderFlag + 1
	&html<<div id="#(..%EnclosingDivId())#/chartdiv" style="width:800px; height:600px;"></div>>
	
	Do ..DrawSRCs()
}

Method DrawSRCs()
{
	&html<<script type='text/javascript' src="https://api.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.js"></script>>
    &html<<link href="https://api.mapbox.com/mapbox-gl-js/v1.9.1/mapbox-gl.css" rel="stylesheet" />>
}

ClientMethod renderContents() [ Language = javascript ]
{
	var html = [];
	
    // do we have a data controller?
    var controller = this.getController();
    if (null == controller) {
        // try to connect to dataController
        this.connectToController();
        controller = this.getController();
    }
    if (controller) {
        try {
	        this.drawChart(controller,this.id);
            html[html.length] = controller;
        } catch (error) {
            //html[html.length] = "";
        }
    }
    else {
        html[html.length] = 'No data source';
        document.getElementById(this.id+"/chartdiv").innerHTML = html.join('');
    }
}

ClientMethod drawChart(resultSet, containingid) [ Language = javascript ]
{
    mapboxgl.accessToken = this.getAPIKey();
    var map = new mapboxgl.Map({
        container: containingid+"/chartdiv",
        style: 'mapbox://styles/mapbox/light-v10',
        center: [-99.9, 41.5],
        zoom: 1
    });
    
    // Perform initial loop to get maxValue
    var maxValue = 0;
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		for (var i = 0; i < resultSet.getDimSize(1); ++i) {
            var value=resultSet.data.cells[(i)*resultSet.getDimSize(2)+j];
            if (value>maxValue) {
                maxValue=value;
            }
		}
	}

    var valueLabel = resultSet.getLabel(i,0).toString().split("/")[0];

    // Populate data and color array
    var colors = [];
    colors.push("match");
    colors.push(["get", "iso_3166_1"]);
	var data = [];
	for (var j = 0; j < resultSet.getDimSize(2); ++j) {
		for (var i = 0; i < resultSet.getDimSize(1); ++i) {
            var label=resultSet.getLabel(i,1).toString().split("/")[0];
            var value=resultSet.data.cells[(i)*resultSet.getDimSize(2)+j];
            var color = 'rgba(' + 0 + ', ' + ((value / maxValue) * 255) + ', ' + 0 + ', 1)';
            if (value>maxValue) {
                maxValue=value;
            }
            data.push({'iso_3166_1': label, valueLabel: value});
            colors.push(label);
            colors.push(color);
		}
	}

    // Add default color
    colors.push('rgba(0,0,0,0)');
    
    map.on('load', function() {
        map.addSource('boundaries_admin_0', {
            type: 'vector',
            url: 'mapbox://mapbox.boundaries-adm0-v3'
        });
    
        // Add layer from the vector tile source with data-driven style
        map.addLayer({
            'id': 'boundaries_admin_0-join',
            'type': 'fill',
            'source': 'boundaries_admin_0',
            'source-layer': 'boundaries_admin_0',
            'paint': {
                'fill-color': colors
            }
        },'waterway-label');
    });
}

Method getAPIKey() As %String [ ZenMethod ]
{
    Quit ##class(ThirdPartyChartPortlets.Mapbox).APIKey()
}

ClassMethod APIKey() As %String
{
    Quit $G(^ThirdPartyChartPortlets.APIKey("Mapbox"))
}

ClassMethod SetAPIKey(pKey As %String = "") As %Status
{
    Set ^ThirdPartyChartPortlets.APIKey("Mapbox")=pKey

    Quit $$$OK
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
}

}
