// NOTICE!! DO NOT USE ANY OF THIS JAVASCRIPT
// IT'S ALL JUST JUNK FOR OUR DOCS!
// ++++++++++++++++++++++++++++++++++++++++++

/**
 * Safecast Map
 * Copyright (c) 2012 Safecast
 * App and visualizations by Anthony DeVincenzi, MIT Media Lab (thinkwithdesign.com)
 * Google Fusion logic adapted from Kalin KOZHUHAROV <kalin@thinrope.net>
 */

$(document).ready(function() {

	app = {
		
		init: function()
		{
			$('.info-pane').css('height',55);
			$('.info-pane .reading').hide();
			$('.info-pane .samples').hide();
			$('.info-pane .cpm').hide();
			$('.info-pane .date-range').hide();
			
			this.render();
		},
		
		render: function()
		{
			//Replace parameters from URL
			this.setFromUrl();

			//Loads JS instantiated UI controls
			this.loadControllers();

			//Build base map
			this.initMap();
			this.toggleTheme();

			//Build layer maps
			this.initCensusMap();
			this.initSafecastFusionMap();
			this.displayElements();
			
			//Default state
			if(mobileVisible)
				this.showMobileCollection();

			if(staticVisible)
				this.showStaticSensors();

			if(censusVisible)
				this.showCensusData();
				
			//Add extras
		},
		
		getUrlVars: function()
		{
		    var vars = [], hash;
		    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
		    for(var i = 0; i < hashes.length; i++)
		    {
		        hash = hashes[i].split('=');
		        vars.push(hash[0]);
		        vars[hash[0]] = hash[1];
		    }
		    return vars;
		},
		
		setFromUrl: function()
		{			
			/*
			stv: self.settingsVisible,
			cv: censusVisible,
			mv: mobileVisible,
			sv: staticVisible,
			dt: darkTheme,
			lt: lightTheme, 
			st: standardTheme, 
			cc: censusColor,
			mz: map_zoom,
			mc: map.getCenter().toUrlValue(),
			*/
						
			if(app.getUrlVars()["stv"])
				settingsVisible = app.getUrlVars()["stv"];
			
			if(app.getUrlVars()["cv"])
				censusVisible = app.getUrlVars()["cv"];
				
			if(app.getUrlVars()["cc"])
				censusColor = app.getUrlVars()["cc"];
			
			if(app.getUrlVars()["mv"])
				mobileVisible = app.getUrlVars()["mv"];
				
			if(app.getUrlVars()["sv"])
				staticVisible = app.getUrlVars()["sv"];
			
			if(app.getUrlVars()["dt"])
				darkTheme = app.getUrlVars()["dt"];
			
			if(app.getUrlVars()["lt"])		
				lightTheme = app.getUrlVars()["lt"];
			
			if(app.getUrlVars()["st"])
				standardTheme = app.getUrlVars()["st"];
			
			if(app.getUrlVars()["cs"])
				censusColor = app.getUrlVars()["cs"];
			
			if(app.getUrlVars()["mz"])
				map_zoom = parseInt(app.getUrlVars()["mz"]); 
				
			if(app.getUrlVars()["lat"])
				lat = parseFloat(app.getUrlVars()["lat"]);	
				
			if(app.getUrlVars()["lng"])
				lng = parseFloat(app.getUrlVars()["lng"]);
				
			},
				
		
		displayElements: function()
		{	
			$('#loading-window').delay(loadDelay).fadeOut(800, function() {
			    $('#logo').fadeIn(2000);
				if(settingsVisible)
					app.showSettings();
			});
		},
		
		loadControllers: function()
		{
			// Color Picker(s)
			$("#color-picker").miniColors({
					change: function(hex, rgb) 
					{ 
						censusColor = hex;
						app.initCensusMap();
					}
			});
			$("#color-picker").miniColors('disabled',true);
			$("#color-picker").miniColors('value',censusColor);	
		},
		
		/////////////////////////
		// BASE MAP
		/////////////////////////
		
		initMap: function()
		{
			var self = this;
			geocoder = new google.maps.Geocoder();
			map = new google.maps.Map(
				document.getElementById('map-view'),
				{ center: new google.maps.LatLng(lat, lng),
					zoom: map_zoom,
					minZoom: 5,		
					maxZoom: map_max_zoom,
					infoBoxClearance: new google.maps.Size(15, 15),
					zoomControl: false,
					panControl: false,
					scaleControl: false,
					scaleControlOptions: { position: google.maps.ControlPosition.TOP_CENTER },
					mapTypeControl: false,
					streetViewControl: false,
					mapTypeId: google.maps.MapTypeId.ROADMAP
				});
								
			app.updateMapStyle();
			app.addCircle()
			

			//Set Listeners
			google.maps.event.addListener(map, 'zoom_changed', function() {
				app.updateZoomLevels(map.getZoom());
			});
			
			google.maps.event.addListener(map, 'dragend', function() {
				lat = map.getCenter().lat(),
				lng = map.getCenter().lng(),
				app.generateURL();
			});
			
			google.maps.event.addListener(map, 'click', function() {
				app.hideMapOverlay();
			});
			
			map_zoom = map.getZoom();
						
		},
		
		updateZoomLevels: function(zoom)
		{
			map_zoom = zoom;
			app.initSafecastFusionMap();
			app.updateMapStyle();
			app.generateURL();
		},
		
		updateMapStyle: function(theme)
		{
			if(map_zoom < 10)
				var _visibility = "simplified"
			else
				var _visibility = "on" 
			
			if(lightTheme == true)
			{
				var style = [
				  {
				    stylers: [
					      { saturation: -100 },
					      { visibility: _visibility },
					      { lightness: 8 },
					      { gamma: 1.31 }
					    ]
				  }
				];
			} else if (darkTheme == true)
			{
				var style = [
				  {
				    stylers: [
					      { saturation: -100 },
					      { visibility: _visibility },
					      { lightness: 45 },
					      { invert_lightness: true },
					      { gamma: 0.88 }
						]
				  }
				];	
			} else if (standardTheme == true)
			{
				var style = [
				  {
				    stylers: []
				  }
				];	
			}
			var styledMapType = new google.maps.StyledMapType(style, { map: map, name: 'Styled Map' });
			map.mapTypes.set('map-style', styledMapType);
			map.setMapTypeId('map-style');
		},
		
		updateDataPointInfo: function(e)
		{
			currMarker = e;
					
			if (e)
			{	
				$('.info-pane').css('opacity',1);
				$('.info-pane').css('height',320);
				$('.info-pane .reading').fadeIn('fast');
				$('.info-pane .samples').fadeIn('fast');
				$('.info-pane .cpm').fadeIn('fast');;
				$('.info-pane .date-range').fadeIn('fast');
							
				var DRE = parseFloat(e.row.DRE.value);
				
				app.hideMapOverlay();
				
				var mapOptions = {
					closeBoxURL: '',
		            disableAutoPan: false,
					infoBoxClearance: new google.maps.Size(15, 15),
		           	zIndex: 999,
		            isHidden: false,
		            pane: 'floatPane',
		            enableEventPropagation: false
		        };
				
				var samples = e.row.points.value;
				var dre = e.row.DRE.value;
				var cpm = e.row.cpm_avg.value;
				var time_from = e.row.timestamp_min.value;
				var time_to = e.row.timestamp_max.value;
				
				$('.info-pane .samples').html(samples + ' samples');
				$('.info-pane .reading').html('<p>&#956;Sv/h</p><h1>'+Number(dre).toFixed(3)+'</h1>')
				$('.info-pane .cpm').html('<p>cpm</br>average</p><h1>'+Number(cpm).toFixed(3)+'</h1>');
				$('.info-pane .date-range').html(time_from + 'to </br>'+ time_to);

				app.generateURL();				
			}
			
			$('.info-pane').delay(5000).fadeTo('slow',.5);
			
			return true;
		},
		
		hideMapOverlay: function()
		{
			if(ib != null)
			{
				ib.close();
			}
		},
		
		addMarkers: function()
		{
			//To use with Safecast data API
			var markers = [];
	       
			var markerClusterer = new MarkerClusterer(map, markers, {
	          minimumClusterSize: 5,
				batchSize: 500,
	        });
		},
		
		addCircle: function()
		{		
			//Daiichi Circle
			var NPS = new google.maps.LatLng(37.425252, 141.033247);
			var area_30km = new google.maps.Circle( { map: map, center: NPS, fillColor: '#ff0000', fillOpacity: 0.05, strokeColor: '#ff0000', strokeOpacity: 0.5, strokeWeight: 2, radius: 30000, clickable:false});
			var area_30km = new google.maps.Circle( { map: map, center: NPS, fillColor: '#ffffff', fillOpacity: 0.05, strokeColor: '#ffffff', strokeOpacity: 0.5, strokeWeight: 2, radius: 30000, clickable:true, editable:true});
			
		},
		
		centerMap: function()
		{
			var addr = $('#search').val();
						
			if(addr == ''){
				addr = baseLocation;
			}

			app.goToPlace(addr, 0);
			return true;
		},

		goToPlace: function(place, zoom)
		{
			geocoder.geocode( {'address': place, 'region': "jp"}, function (results, status)
				{
					if (status == google.maps.GeocoderStatus.OK)
					{
						if (zoom >0)
						{
							map.setCenter(results[0].geometry.location);
							map.setZoom(zoom);
						}
						else
						{
							map.fitBounds(results[0].geometry.viewport);
						}
					 }
					else
						{ alert ("Cannot find " + addr + "! Status: " + status); }
				});
			app.generateURL();
			return true;
		},	
		
		/* 
			Layers from Google Fusion Maps 
		*/
		
		/////////////////////////
		// Safecast
		/////////////////////////
		
		initSafecastFusionMap: function()
		{
			//Clear all existing layers
			for (var layer in layers)
			{
				if (layers[layer])
				{
					layers[layer].setMap(null);
					layers[layer] = null;
				}
			}
							
			// Pull zoom key from tbl_data (based on map.getZoom())
			// Zoom less than 14 use square KML blocks, 14+ use exact dots	
						
			if(map_zoom < 14)
			{	
				if (map_zoom <= 6)
				{
					zoom_key = tbl_data[8];
				}		
				else if (map_zoom <= 8)
				{
					zoom_key = tbl_data[10];
				}
				else if (map_zoom <= 10)
				{
					zoom_key = tbl_data[15];
				}
				else if (map_zoom == 9)
				{
					zoom_key = tbl_data[10];
				}
				else if (map_zoom <= 15)
				{
					zoom_key = tbl_data[18];
				}
				else if (map_zoom > 15)
				{
					zoom_key = tbl_data[7];
				}
				
				layers['squares'] = new google.maps.FusionTablesLayer({ query: {select: 'grid', from: zoom_key, where: ''} });
				layers['squares'].setOptions({ suppressInfoWindows : true});
				listeners['squares'] = google.maps.event.addListener(layers['squares'], 'click', function(e) {app.updateDataPointInfo(e)});
				if(mobileVisible)
					layers['squares'].setMap(map)
					
			} else
			{
				layers['dots'] = new google.maps.FusionTablesLayer({ query: {select: 'lat_lon', from: zoom_key, where: ''}});
				layers['dots'].setOptions({ suppressInfoWindows : true, markerOptions:{enabled:false}});
				listeners['dots'] = google.maps.event.addListener(layers['dots'], 'click', function(e) {app.updateDataPointInfo(e)});
				if(mobileVisible)
					layers['dots'].setMap(map);	
			}			
		},
		
		/////////////////////////
		// CENSUS LAYER
		/////////////////////////
	
		initCensusMap: function()
		{
			if(census){census.setMap(null)};
			
			census = new google.maps.FusionTablesLayer({ query: {select: 'geometry', from: '2113296', where: ''}, styles: [{
				polygonOptions: {
			      fillColor: censusColor,
			      fillOpacity: 0.0,
			      strokeColor: "#ffffff",
				  strokeWeight: 0,
				  strokeOpacity: 0.01,
			    }
			  }]});
			
			if(censusVisible)
				app.showCensusData();
		},
		
		showCensusData: function()
		{
			censusVisible = true;
			census.setMap(map);				
			$('#toggle-census').addClass('active');
			$("#color-picker").miniColors('disabled',false);
			
			//#hack
			if(mobileVisible)
				app.showMobileCollection();
			
			app.generateURL();		
		},
		
		hideCensusData: function()
		{	
			censusVisible = false;
			census.setMap(null);
			$('#toggle-census').removeClass('active');
			$("#color-picker").miniColors('disabled',true);
			app.generateURL();
		},
		
		/////////////////////////
		// MOBILE LAYER
		/////////////////////////
		
		showMobileCollection: function()
		{
			$('#toggle-safecastdata').addClass('active');
			mobileVisible = true;
			app.initSafecastFusionMap();
			app.generateURL();
		},
		
		hideMobileCollection: function()
		{
			if(map_zoom < map_max_zoom)
			{
				layers['squares'].setMap(null);
			} else
			{
				layers['dots'].setMap(null);
			}
			$('#toggle-safecastdata').removeClass('active');
			mobileVisible = false;	
			app.generateURL();
		},
		
		/////////////////////////
		// STATIC LAYER
		/////////////////////////
		
		showStaticSensors: function()
		{
			$('#toggle-staticdata').addClass('active');
			staticVisible = true;
			app.generateURL();
		},
		
		hideStaticSensors: function()
		{
			$('#toggle-staticdata').removeClass('active');
			staticVisible = false;
			app.generateURL();
		},
		
		/* 
			End Google Fusion Maps 
		*/
		
		/////////////////////////
		// UI SETTINGS
		/////////////////////////
		
		toggleTheme: function(theme)
		{	
			if(theme == undefined)
			{
				if(darkTheme)
					theme = 'dark';
				else if(lightTheme)
					theme = 'light';
				else if (standardTheme)
					theme = 'standard'
				else
					theme = 'dark'
			}
						
			if(theme == 'dark')
			{
				darkTheme = true;
				lightTheme = false;
				standardTheme = false;
				$('#toggle-light').removeClass('light-on');
				$('#toggle-light').addClass('light-off');
				$('#toggle-dark').removeClass('dark-off');
				$('#toggle-dark').addClass('dark-on');
				$('#toggle-standard').removeClass('standard-on');
				$('#toggle-standard').addClass('standard-off');

			} else if (theme == 'light')
			{
				darkTheme = false;
				lightTheme = true;
				standardTheme = false;
				$('#toggle-light').removeClass('light-off');
				$('#toggle-light').addClass('light-on');
				$('#toggle-dark').removeClass('dark-on');
				$('#toggle-dark').addClass('dark-off');
				$('#toggle-standard').removeClass('standard-on');
				$('#toggle-standard').addClass('standard-off');
				
			} else if (theme == 'standard')
			{
				darkTheme = false;
				lightTheme = false;
				standardTheme = true;
				$('#toggle-light').removeClass('light-on');
				$('#toggle-light').addClass('light-off');
				$('#toggle-dark').removeClass('dark-on');
				$('#toggle-dark').addClass('dark-off');
				$('#toggle-standard').removeClass('standard-off');
				$('#toggle-standard').addClass('standard-on');
			}
			app.generateURL();
			app.updateMapStyle();
		},
		
		showSettings: function()
		{
			settingsVisible = true
			$('#map-container').animate({left:220},{queue:false, duration:500, easing:'easeOutQuint'});
			$('#settings-toggle').animate({left:250},{queue:false, duration:500, easing:'easeOutQuint'});
			$('#zoom-buttons').animate({left:300},{queue:false, duration:500, easing:'easeOutQuint'});
			app.generateURL();
		},
		
		hideSettings: function()
		{
			settingsVisible = false
			$('#map-container').animate({left:-15},{queue:false, duration:500, easing:'easeOutQuint'});
			$('#settings-toggle').animate({left:15},{queue:false, duration:500, easing:'easeOutQuint'});
			$('#zoom-buttons').animate({left:65},{queue:false, duration:500, easing:'easeOutQuint'});
			app.generateURL();
		},
		
		generateURL: function()
		{
			var self = this;
			
			var params = {
				stv:settingsVisible,
				cv: censusVisible,
				mv: mobileVisible,
				sv: staticVisible,
				dt: darkTheme,
				lt: lightTheme, 
				st: standardTheme, 
				cc: censusColor,
				mz: map_zoom,
				lat: lat,
				lng: lng,
			};
				
			var myURL = "/";
			myURL += '?';
			for (var key in params)
			{
				if (params[key])
				{
					myURL += '&' + key + '=' + params[key];
				}
			}
			
			window.location = '#';
			window.location += myURL;
			
			return false;
		},
		
		/* Social */
		
		twitterButtonClicked: function() {
			var tweet = {};
			tweet.url = 'url';
			tweet.text = 'Check out the Safecast map: ' + window.location;
			tweet.via = "safecastdotorg";

			var url = 'https://twitter.com/share?' + $.param(tweet);

			window.open(url, 'Tweet this post', 'width=650,height=251,toolbar=0,scrollbars=0,status=0,resizable=0,location=0,menuBar=0');
		},

		facebookButtonClicked: function() {
			var url = 'http://www.facebook.com/sharer.php?u='
			url += encodeURIComponent(window.location);
			url += '&t=Check out the Safecast map';
			window.open('' + url, 'Share it on Facebook', 'width=650,height=251,toolbar=0,scrollbars=0,status=0,resizable=0,location=0,menuBar=0');
		}
		
	};
	
	/////////////////////////
	// Init the App 
	///////////////////////
	
	app.init();

	/////////////////////////
	// Click Interactions 
	///////////////////////
	
	$('#settings-toggle').click(function() {
		
		if(settingsVisible == true)
		{			
			app.hideSettings();
		}
		else
		{
			app.showSettings();
		}	
	});
	
	$('#zoom-out').click(function() {
		map.setZoom(map_zoom-1);
	});
	
	$('#zoom-in').click(function() {
		map.setZoom(map_zoom+1);
	});
	
	$('#toggle-census').click(function() {
		if(censusVisible == true)
		{			
			app.hideCensusData();
		}
		else
		{
			app.showCensusData();
		}
	});
	
	$('#toggle-safecastdata').click(function() {
		if(mobileVisible == true)
		{			
			app.hideMobileCollection();
		}
		else
		{
			app.showMobileCollection();
		}
	});
	
	$('#toggle-staticdata').click(function() {
		if(staticVisible == true)
		{			
			app.hideStaticSensors();
		}
		else
		{
			app.showStaticSensors();
		}
	});
	
	$('#toggle-dark').click(function() {
		app.toggleTheme('dark');
	});
	
	$('#toggle-light').click(function() {
		app.toggleTheme('light');
	});
	
	$('#toggle-standard').click(function() {
		app.toggleTheme('standard');
	});
	
	$('#search').keydown(function(event) {
	  if (event.keyCode == '13') {
	    app.centerMap();
	   }
	});
	
	$('.btn-facebook').click(function() {
		app.facebookButtonClicked();
	});
	
	$('.btn-twitter').click(function() {
		app.twitterButtonClicked();
	});
	
	
	
	/* Roll Over Events */
	
	$('#toggle-safecastdata').mouseover(function() {
		var options = {
			animation: true,
            placement: 'right',
			title: 'Toggle mobile data',
			content: 'Display the #### of readings gathered from the Safecast community'
        };
		$('#toggle-safecastdata').popover(options);
	});
	
	$('.info-hit-area').mouseover(function() {
		$('.info-pane').fadeTo('fast',1);
	});
	
	$('.info-hit-area').mouseout(function() {
		$('.info-pane').delay(5000).fadeTo('slow',.5);
	});

	
});

$(window).resize(function() {
	//Do nothing
});