$(function () {
    var a = [{"featureType": "water", "stylers": [{"saturation": -100}, {"lightness": -30}]},
        {"stylers": [{"saturation": -100}, {"lightness": 50}]},
        {"elementType": "labels.icon", "stylers": [{"invert_lightness": true}, {"gamma": 9.99}, {"lightness": 79}]}];

    gry = new google.maps.StyledMapType(a, {name: "Map (Gray)"});

    var map_options =
        {
            zoom: 9,
            maxZoom: 21,
            center: new google.maps.LatLng(37.316113, 140.515516),
            scrollwheel: true,
            zoomControl: true,
            panControl: false,
            scaleControl: true,
            mapTypeControl: true,
            streetViewControl: true,
            navigationControl: true,
            overviewMapControl: false,
            navigationControlOptions: {style: google.maps.NavigationControlStyle.DEFAULT},
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                mapTypeIds: [google.maps.MapTypeId.ROADMAP,
                    google.maps.MapTypeId.SATELLITE,
                    google.maps.MapTypeId.HYBRID,
                    google.maps.MapTypeId.TERRAIN,
                    "gray"]
            },
            mapTypeId: "gray"
        };

    var $map = $('#map_canvas');
    map = new google.maps.Map($map[0], map_options);
    map.mapTypes.set("gray", gry);

    var binds =
        {
            elementIds: {
                bv_transferBar: "bv_transferBar"
            },
            cssClasses: {
                bv_hline: "bv_hline",
                bv_FuturaFont: "bv_FuturaFont",
                bv_transferBarHidden: "bv_transferBarHidden",
                bv_transferBarVisible: "bv_transferBarVisible"
            },
            urls: {
                world_155a_z0: "world_155a_z0.png",
                bv_worker_min: $map.data('bv-worker-min')
            }
        };

    bvm = new BVM(map, binds);
    bvm.SetNewCustomMarkerOptions(16, 16, 1, 1, 0, true);    // default: 10, 10, 0.75, 0.75, 0, false
    bvm.SetOpenInfowindowOnHover(true);   // default: false
    bvm.GetLogFileDirectFromUrlAsync($map.data('url'), $map.data('id'));
});

