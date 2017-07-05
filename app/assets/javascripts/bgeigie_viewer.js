// ==============================================
// bGeigie Log Viewer
// ==============================================
// Nick Dolezal/Safecast, 2015 - 2017
// This code is released into the public domain.
// ==============================================

// 2017-07-05 ND: - Add log review alert messages and check for log file status.
// 2017-06-29 ND: - Add additional log stats per Sean, reformat log stats table.
// 2017-06-28 ND: - Add log stats table to infowindow.
// 2017-06-05 ND: - Add additional columns for single log review on api.safecast.org only.
// 2017-04-25 ND: - Fix for autozoom when running in smaller area on page.
//                - Smarter handling of partial databind params.
//                - Manually allow enabling infowindow on hover.
// 2016-11-22 ND: - Make various static/class functions private, comment out dead code.
// 2015-04-05 ND: - Test fix for remaining known no-draw panning issue
// 2015-03-30 ND: - Fix for various no-draw panning issues.
// 2015-03-21 ND: - Support for retrieving all logids in string or limited number.
// 2015-03-20 ND: - Major changes to core rendering logic; quadkey clustering and per-tile rendering.
// 2015-02-17 ND: - Added direct log download function - BVM.GetLogFileDirectFromUrlAsync(url, logId);
//                - Removed legacy query form refs.
//                - Made "zoom to marker extent" the default behavior.
//                - Added setter for above: BVM.SetZoomToLogExtent(bool);

// =================================
// Requirements (Files):
// =================================
// 1. bgeigie_viewer_min.js             (this file)
// 2. bgeigie_viewer_worker_min.js      (*not* optional!)



// =================================
// Use
// =================================
//
// 1. Prerequisites
// -------------------------------
// var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);         // or whatever.
//
// 2. Instantiate
// -------------------------------
// var bvm = new BVM(map, null);
//
// 3. Add a log by URL directly
// -------------------------------
// bvm.GetLogFileDirectFromUrlAsync("https://safecast-production.s3.amazonaws.com/uploads/bgeigie_import/source/12070/100-1111.LOG", 12070);
//
// 3. Add a log by ID
// -------------------------------
// bvm.AddLogsByQueryFromString("12070");
//


// =================================
// Optional - Data Transfer UI
// =================================
//
// To display a UI showing download progress to the user, a div with a specific ID is required.
// This div is used to inject HTML, as Google Maps does with "map_canvas" above.
// External CSS styles and an image are also required.
//
// 1. HTML Div
// -------------------------------
// <div id="bv_transferBar" class="bv_transferBarHidden"></div>
//
// 2. World Map PNG (256x256)
// -------------------------------
// By default, "world_155a_z0.png" should be in the same path.
//
// 3. CSS Styles (many)
// -------------------------------
// Required styles are as follows.
//
// #bv_transferBar { position:absolute;top:0;bottom:0;left:0;right:0;margin:auto;padding:10px 0px 20px 20px;border:0px;background-color:rgba(255, 255, 255, 0.75);font-size:80%; }
// .bv_transferBarVisible { visibility:visible;z-index:8;width:276px;height:286px;overflow:visible; }
// .bv_transferBarHidden { visibility:hidden;z-index:-9000;width:0px;height:0px;overflow:hidden; }
// .bv_FuturaFont { font-size:100%;font-family:Futura,Futura-Medium,'Futura Medium','Futura ND Medium','Futura Std Medium','Futura Md BT','Century Gothic','Segoe UI',Helvetica,Arial,sans-serif; }
// .bv_hline { overflow:hidden;text-align:center; }
// .bv_hline:before, .bv_hline:after { background-color:#000;content:"";display:inline-block;height:1px;position:relative;vertical-align:middle;width:50%; }
// .bv_hline:before { right:0.5em;margin-left:-50%; }
// .bv_hline:after { left:0.5em;margin-right:-50%; }
//
// Note the font can be anything, but should be about that size.
// That font class is also used for marker info windows.









// bGeigie Log Viewer - Main
// Contains all useful instances of other objects and UI event handling.
// Messy and too broad but hey.

// NOTE: In most cases, null should be passed for "dataBinds".
//       Only override this if you want to set custom styles or image/worker filepaths.

var BVM = (function()
{
    function BVM(map, dataBinds)
    {
        this.mapRef   = map;
        this.isMobile = _IsPlatformMobile();
        this.xfm      = null; // data transfer manager
        this.mks      = null; // marker manager
        this.wwm      = null; // web worker manager
        
        this.did_add_gmaps_listeners = false;  // todo: move to MKS
        this.zoom_to_log_extent      = true;   // whether or not to zoom to the extent of the log(s) after processing.
        
        this.Init_DataBindDefaults();

        if (dataBinds != null)
        {
            for (var key in dataBinds)
            {
                this.dataBinds[key] = dataBinds[key];
            }//for
        }//if
        
        this.Init();
    }
    
    
    
    // =======================================================================================================
    //                                      Mandatory Initialization
    // =======================================================================================================

    BVM.prototype.Init = function()
    {
        this.Init_XFM();
        this.Init_MKS();
        this.Init_WWM();
    };
    
    BVM.prototype.Init_DataBindDefaults = function()
    {
        var binds =
        {
            elementIds:
            {
                bv_transferBar:"bv_transferBar"
            },
            cssClasses:
            {
                             bv_hline:"bv_hline",
                        bv_FuturaFont:"bv_FuturaFont",
                 bv_transferBarHidden:"bv_transferBarHidden", 
                bv_transferBarVisible:"bv_transferBarVisible"
            },
            urls:
            {
                world_155a_z0:"world_155a_z0.png",
                bv_worker_min:"bgeigie_viewer_worker_min.js"
            }
        };
        
        this.dataBinds = binds;
    };
    
    BVM.prototype.AddGmapsListener_Idle = function()
    {
        var fxRefresh = function() 
        {
            this.mks.RemoveMarkersFromMapForCurrentVisibleExtent();
            this.mks.AddMarkersToMapForCurrentVisibleExtent();
        }.bind(this);
        
        google.maps.event.addListener(this.mapRef, "idle", fxRefresh); // 2015-04-03 ND: idle isn't getting the bounds changed when panning north suddenly(?)
    };
    
    BVM.prototype.AddGmapsListener_OnStreetViewExit = function()
    {
        var pan = this.mapRef.getStreetView();

        var fxRefreshIfDone = function() 
        { 
            if (!pan.getVisible()) // restore the markers to the map extent instead of street view
            {
                this.mks.RemoveMarkersFromMapForCurrentVisibleExtent();
                this.mks.AddMarkersToMapForCurrentVisibleExtent();
            }//if
            else // seems to have issues with large data sets, see if this helps(?)
            {
                this.mks.RemoveAllMarkersFromMap();
                var pos = pan.getPosition();
                var lat = pos.lat();
                var lon = pos.lng();
                var x0  = lon - 0.005; // ~0.5km
                var y0  = lat - 0.005;
                var x1  = lon + 0.005;
                var y1  = lat + 0.005;
                var  z  = 21;
                var last_ex = [ 0, 0, 0, 0, 0, 0, 0 ];
                    
                this.mks.RemoveAllMarkersFromMap();
                this.mks.AddMarkersToMapForExtentTimer(x0, y0, x1, y1, -9000.0, -9000.0, z, last_ex, 0, 500, 0, null, null);
            }//else
        }.bind(this);

        google.maps.event.addListener(pan, "visible_changed", fxRefreshIfDone);
    };
    
    BVM.prototype.AddGmapsListener_OnStreetViewPositionChanged = function()
    {
        var pan = this.mapRef.getStreetView();
        
        var fxRefreshStreetView = function()
        {
            if (pan.getVisible())
            {
                var pos = pan.getPosition();
                var lat = pos.lat();
                var lon = pos.lng();
                var x0  = lon - 0.005; // ~0.5km
                var y0  = lat - 0.005;
                var x1  = lon + 0.005;
                var y1  = lat + 0.005;
                var  z  = 21;
                var last_ex = [ 0, 0, 0, 0, 0, 0, 0 ];
                    
                this.mks.RemoveAllMarkersFromMap();
                this.mks.AddMarkersToMapForExtentTimer(x0, y0, x1, y1, -9000.0, -9000.0, z, last_ex, 0, 500, 0, null, null);
            }//if
        }.bind(this);
        
        google.maps.event.addListener(pan, "position_changed", fxRefreshStreetView);
    };
    
    BVM.prototype.AddGmapsListeners_IfNeeded = function()
    {
        if (!this.did_add_gmaps_listeners)
        {
            this.AddGmapsListener_Idle();
            this.AddGmapsListener_OnStreetViewExit();
            this.AddGmapsListener_OnStreetViewPositionChanged();
            
            this.did_add_gmaps_listeners = true;
        }//if
    };

    BVM.prototype.Init_XFM = function()
    {
        var xfmcbs = function(userData) { this.TransferBar_SetHidden(false); }.bind(this);

        var xfmcbe = function(userData)
        {
            this.xfm.ChangeMode(XFM.ModeCPU);
            
            var sortcb = function()
            {
                this.wwm.TerminateWorkers();
                
                if (this.zoom_to_log_extent) this.mks.ApplyMapVisibleExtentForMarkers();

                this.mks.AddMarkersToMapForCurrentVisibleExtent();
            
                this.AddGmapsListeners_IfNeeded();

                setTimeout(function() { this.TransferBar_SetHidden(true); this.xfm.ChangeMode(XFM.ModeXF); }.bind(this), 2500);
            }.bind(this);
            
            var n = this.mks.cpms == null ? 0 : this.mks.cpms.length;
            
            if (n > 0 && (n < 5000000 || (this.isMobile && n < 10000)))
            {
                this.wwm.SetFxReportDoneSortByQuadKey(sortcb);
            
                this.mks.SortByQuadKey(); // 2015-03-13 ND: test QuadKey sort for performance
            }//if
            else
            {
                sortcb(); // bypass if likely to blow up due to RAM.
            }//else
        }.bind(this);

        var el_bar = document.getElementById(this.dataBinds.elementIds.bv_transferBar);

        this.xfm = new XFM(xfmcbs, xfmcbe, null, "Data Transfer", this.dataBinds.cssClasses.bv_hline, el_bar, this.dataBinds.cssClasses.bv_FuturaFont, this.isMobile, this.dataBinds.urls.world_155a_z0);
    };

    BVM.prototype.Init_MKS = function()
    {
        var fxGetWorkerForDispatch = function() { return this.wwm.GetWorkerForDispatch(); }.bind(this);
        var fxClearAllLogIds = function() { this.xfm.ClearAllLogIds(); }.bind(this);
        var fxReportResultsSuccessForLogId = function(logId) { this.xfm.ReportResultsSuccessForLogId(logId); }.bind(this);
    
        this.mks = new MKS(this.mapRef, ICO.IconStyleMd, window.devicePixelRatio > 1.5, this.isMobile, this.dataBinds.cssClasses.bv_FuturaFont, fxGetWorkerForDispatch, fxClearAllLogIds, fxReportResultsSuccessForLogId);
    };

    BVM.prototype.Init_WWM = function()
    {
        var cb_rsuc = function(logId) { this.xfm.ReportResultsSuccessForLogId(logId); }.bind(this);
        var cb_rspr = function(logId) { this.xfm.ReportStartParsingForLogId(logId); }.bind(this);
        var cb_rdpr = function(logId) { this.xfm.ReportDoneParsingForLogId(logId); }.bind(this);
        var cb_uimg = function(image) { this.xfm.UpdateGlobalImage(image); }.bind(this);
        var cb_rdaz = function(logId) { this.xfm.ReportDoneAssignZForLogId(logId); }.bind(this);
        var cb_gdpv = function(mxs, mys, minzs, cpms, alts, degs, times, litcpms, litcp5s, valids, logId, userData) { this.mks.GetDataAndDispatchPrefilterVec(mxs, mys, minzs, cpms, alts, degs, times, litcpms, litcp5s, valids, logId, userData); }.bind(this);
        //var cb_adat = function(lats, lons, minzs, cpms, alts, degs, logids, times, lutidxs, mxs, mys) { this.mks.AddData(lats, lons, minzs, cpms, alts, degs, logids, times, lutidxs, mxs, mys); }.bind(this);
        var cb_adat = function(minzs, cpms, alts, degs, logids, times, mxs, mys, litcpms, litcp5s, valids) { this.mks.AddData(minzs, cpms, alts, degs, logids, times, mxs, mys, litcpms, litcp5s, valids); }.bind(this);
        var cb_upex = function(x0, y0, x1, y1) { this.mks.UpdateMarkerExtent(x0, y0, x1, y1); }.bind(this);
        var cb_ismf = function() { return this.mks.logids == null; }.bind(this);
        var cb_cpss = function(s) { this.mks.CopySummaryStats(s); }.bind(this);

        this.wwm = new WWM(this.isMobile, 0, cb_rsuc, cb_rspr, cb_rdpr, cb_uimg, cb_rdaz, cb_gdpv, cb_adat, cb_upex, cb_ismf, cb_cpss, this.dataBinds.urls.bv_worker_min);
    };


    // =======================================================================================================
    //                            Event handlers - abstracted download methods
    // =======================================================================================================

    BVM.prototype.GetJSONAsyncByQuery_AllPages = function(base_url, xfType, pageIdx, pageLimit, extra_params)
    {
        var title = "API Query, Page " + pageIdx;

        var cb = function(response, userData)
        {
            var success = response != null && response.length > 0;

            if (success)
            {
                var obj = JSON.parse(response);
                var   j = 0;
        
                for (var i=0; i<obj.length; i++)
                {
                    if (obj[i] != null && obj[i].measurements_count != 0)
                    {
                        var logId = obj[i].id;
                        var responseType = window.TextDecoder != null ? "arraybuffer" : null;
                        var wcb = function(response, userData) { this.wwm.DispatchLogParseToVec(response, logId, userData); }.bind(this);
                        this.xfm.AddTask(obj[i].source.url, responseType, wcb, [obj[i].id], "bGeigie Log", XF.TypeLog, obj[i].id);
                        j++;
                    }//if
                    else
                    {
                        console.log("BVM.GetJSONAsyncByQuery_AllPages: Log ID=%d had 0 measurements, skipping.", obj[i].id);
                    }//else
                }//for
            
                success = j > 0 && userData[2] < userData[3];
            
                // now, get the next page of results.
                if (success)
                {
                    this.GetJSONAsyncByQuery_AllPages(userData[0], userData[1], userData[2] + 1, userData[3], userData[4]);
                }//if
            }//if
        
            if (!success)
            {
                var synth_url = userData[0] + (userData[2] > 1 ? "&page=" + userData[2] : "") + (userData[4] != null ? userData[4] : "");
                this.xfm.ReportResultsErrorForURL(synth_url);
            }//if
        }.bind(this);
    
        var page_url = base_url + (pageIdx > 1 ? "&page=" + pageIdx : "") + (extra_params != null ? extra_params : "");
        
        this.xfm.AddTask(page_url, null, cb, [base_url, xfType, pageIdx, pageLimit, extra_params], title, xfType, 0);
    };


    BVM.prototype.GetJSONAsync = function(url)
    {
        var cb = function(response, userData)
        {
            var success = response != null && response.length > 0;
        
            if (success)
            {
                var obj = JSON.parse(response);
                
                if (obj != null && obj.source != null && obj.source.url != null && obj.source.url.length > 0)
                {
                    var logId = obj.id;
                    var responseType = window.TextDecoder != null ? "arraybuffer" : null;
                    this.xfm.AddTask(obj.source.url, responseType, function(response, userData) { this.wwm.DispatchLogParseToVec(response, logId, userData); }.bind(this), [obj.id], "bGeigie Log", XF.TypeLog, obj.id);
                }//if
                else
                {
                    success = false;
                }//else
            }//if
        
            if (!success)
            {
                this.xfm.ReportResultsErrorForURL(url);
            }//if
        }.bind(this);

        this.xfm.AddTask(url, null, cb, null, "API Query - Log", XF.TypeLogQueryByLog, 0);
    };
    
    
    BVM.prototype.GetLogFileDirectFromUrlAsync = function(url, logId, cb)
    {
        var responseType = window.TextDecoder != null ? "arraybuffer" : null;
        this.xfm.AddTask(url, responseType, function(response, userData) { if (userData.length > 0 && userData[1] != null) { userData[1](); userData = [userData[0]]; } this.wwm.DispatchLogParseToVec(response, logId, userData); }.bind(this), [logId, cb], "bGeigie Log", XF.TypeLog, logId);
    };


    // =======================================================================================================
    //                            Event handlers - abstracted query methods
    // =======================================================================================================

    BVM.prototype.AddLogsByQueryFromString = function(txt, extra_params, page_limit)
    {
        if (txt == null || txt.length == 0)
        {
            var url = "https://api.safecast.org/bgeigie_imports.json?order=created_at+desc";
            this.GetJSONAsyncByQuery_AllPages(url, XF.TypeLogQueryByUser, 1, page_limit, extra_params);
        }//if
        
        if (txt != null && txt.length > 0 && txt.substring(0,1) == "c" && txt.indexOf("cosmic") == 0)
        {
            page_limit = 250;
            var url = "https://api.safecast.org/bgeigie_imports.json?subtype=Cosmic";
            this.GetJSONAsyncByQuery_AllPages(url, XF.TypeLogQueryByUser, 1, page_limit, extra_params);
        }//if
    
        if (txt != null && txt.length > 0 && txt.substring(0,1) == "u")
        {
            page_limit = 250;
            var url = _ParseUserInput_UserID(txt);
            this.GetJSONAsyncByQuery_AllPages(url, XF.TypeLogQueryByUser, 1, page_limit, extra_params);
        }//if
    
        if (txt != null && txt.length > 0 && txt.substring(0,1) == "q")
        {
            page_limit = 250;
            var url = _ParseUserInput_QueryText(txt);
            this.GetJSONAsyncByQuery_AllPages(url, XF.TypeLogQueryByText, 1, page_limit, extra_params);
        }//if
    
        var ids = _ParseUserInputIDs(txt);
    
        for (var i=0; i<ids.length; i++)
        {
            var url = "https://api.safecast.org/bgeigie_imports/" + ids[i] + ".json";
            this.GetJSONAsync(url);
        }//for
    };

    BVM.prototype.AddLogsFromQueryTextWithOptions = function(query, queryTypeId, extraParams, pageLimit)
    {
        if (queryTypeId == 1 && query != null && query.length > 0)
        {
            query = "u" + query;
        }
        else if (queryTypeId == 2 && query != null && query.length > 0)
        {
            query = "q" + query;
        }
    
        this.AddLogsByQueryFromString(query, extraParams, pageLimit);
    };
    
    
    
    // =======================================================================================================
    //                                      Event handlers - UI
    // =======================================================================================================
    
    BVM.prototype.RemoveAllMarkersFromMapAndPurgeData = function()
    {
        this.mks.RemoveAllMarkersFromMapAndPurgeData();
    };

    BVM.prototype.TransferBar_SetHidden = function(isHidden)
    {
        _ChangeVisibilityForElementByIdByReplacingClass(this.dataBinds.elementIds.bv_transferBar, this.dataBinds.cssClasses.bv_transferBarHidden, this.dataBinds.cssClasses.bv_transferBarVisible, isHidden);
    };
    
    BVM.prototype.SetParallelism = function(p)
    {
        this.wwm.SetParallelism(p);
        this.xfm.SetParallelism(p);
    };
    
    BVM.prototype.SetZoomToLogExtent = function(shouldZoom)
    {
        this.zoom_to_log_extent = shouldZoom;
    };

    BVM.prototype.SetOpenInfowindowOnHover = function(shouldOpen)
    {
        this.mks.hover_iw = shouldOpen;
    };
    
    BVM.prototype.SetNewCustomMarkerOptions = function(width, height, alpha_fill, alpha_stroke, shadow_radius, hasBearingTick)
    {
        this.mks.SetNewCustomMarkerOptions(width, height, alpha_fill, alpha_stroke, shadow_radius, hasBearingTick);
    };
    
    BVM.prototype.SetNewMarkerType = function(iconTypeId)
    {
        this.mks.SetNewMarkerType(iconTypeId);
    };

    BVM.prototype.GetLogIdsEncoded = function()
    {
        return this.xfm.GetLogIdsEncoded();
    };
    
    BVM.prototype.GetAllLogIdsEncoded = function()
    {
        return this.xfm.GetAllLogIdsEncoded();
    };
    
    BVM.prototype.GetLogCount = function()
    {
        return this.xfm == null || this.xfm.logIds == null ? 0 : this.xfm.logIds.length;
    };


    // =======================================================================================================
    //                                      Static/Class Methods
    // =======================================================================================================
    
    // returns value of querystring parameter "name"
    var _GetParam = function(name) 
    {
        name        = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS  = "[\\?&]" + name + "=([^&#]*)";
        var regex   = new RegExp(regexS);
        var results = regex.exec(window.location.href);
    
        return results == null ? "" : results[1];
    };


    // http://stackoverflow.com/questions/11381673/detecting-a-mobile-browser
    // returns true if useragent is detected as being a mobile platform, or "mobile=1" is set in querystring.
    var _IsPlatformMobile = function()
    {
        var check   = false;
        var ovr_str = _GetParam("mobile");
    
        if (ovr_str != null && ovr_str.length > 0)
        {
            check = parseInt(ovr_str) == 1;
        }//if
        else
        {
            (function(a,b){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte|android|ipad|playbook|silk\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
    
            if (!check) check = navigator.userAgent.match(/iPad/i);
            if (!check) check = navigator.userAgent.match(/Android/i);
            if (!check) check = window.navigator.userAgent.indexOf("iPad") > 0;
            if (!check) check = window.navigator.userAgent.indexOf("Android") > 0;
        }//else
    
        return check;
    };
    
    var _ChangeVisibilityForElementByIdByReplacingClass = function(elementid, classHidden, classVisible, isHidden)
    {
        var el = document.getElementById(elementid);
        if       (el != null &&  isHidden && el.className == classVisible) el.className = classHidden;
        else if  (el != null && !isHidden && el.className == classHidden)  el.className = classVisible;
    };
    
    var _ParseUserInput_QueryText = function(txt)
    {
        var q   = txt.length > 1 ? txt.substring(1, txt.length) : null;
        var url = q != null ? "https://api.safecast.org/bgeigie_imports.json?q=" + q + "&order=created_at+desc" : null;
    
        return url;
    };

    var _ParseUserInput_UserID = function(txt)
    {
        var user_id = txt.length > 1 ? txt.substring(1, txt.length) : null;
        var url = user_id != null ? "https://api.safecast.org/bgeigie_imports.json?by_user_id=" + user_id + "&order=created_at+desc" : null;
    
        return url;
    };

    var _ParseUserInputIDs = function(txt)
    {
        var dest = new Array();
    
        if (txt != null && txt.length > 0)
        {
            var txt_ids = txt.split(",");
    
            for (var i=0; i<txt_ids.length; i++)
            {
                var x = parseInt(txt_ids[i]);
        
                if (x != null && x > 0)
                {
                    dest.push(x);
                }//if
            }//for
        }//if
    
        return dest;
    };
    

    return BVM;
})();









// WWM: Web worker manager.
//      Manages one or more web workers with coded handling for specific messages.
var WWM = (function()
{
    function WWM(isMobile, parallelism, fxReportResultsSuccessForLogId, fxReportStartParsingForLogId, fxReportDoneParsingForLogId, fxUpdateGlobalImage, fxReportDoneAssignZForLogId, fxGetDataAndDispatchPrefilter, fxAddData, fxUpdateMarkerExtent, fxGetIsMoreFields, fxCopySummaryStats, workerSrcUrl)
    {
        this.n       = parallelism > 0 ? parallelism : navigator.hardwareConcurrency != null ? navigator.hardwareConcurrency : isMobile ? 2 : 4;
        this.workers = new Array(this.n);
        this.isBusy  = new Uint8Array(this.n);
        this.index   = 0;

        this.fxReportResultsSuccessForLogId = fxReportResultsSuccessForLogId;   // xfm
        this.fxReportStartParsingForLogId   = fxReportStartParsingForLogId;     // xfm
        this.fxReportDoneParsingForLogId    = fxReportDoneParsingForLogId;      // xfm
        this.fxUpdateGlobalImage            = fxUpdateGlobalImage;              // xfm
        this.fxReportDoneAssignZForLogId    = fxReportDoneAssignZForLogId;      // xfm
        this.fxReportDoneSortByQuadKey      = null;
        this.fxGetDataAndDispatchPrefilter  = fxGetDataAndDispatchPrefilter;    // mks
        this.fxAddData                      = fxAddData;                        // mks
        this.fxUpdateMarkerExtent           = fxUpdateMarkerExtent;             // mks
        this.fxGetIsMoreFields              = fxGetIsMoreFields;
        this.fxCopySummaryStats             = fxCopySummaryStats;
        
        this.workerSrcUrl                   = workerSrcUrl;
        
        this.summary_stats                  = new Array(); // 2015-03-31 ND: *** TEMP *** move elsewhere later.
        
        for (var i=0; i<this.n; i++)
        {
            this.workers[i] = null;
        }//for
    }//WWM
    
    WWM.prototype.SetFxReportDoneSortByQuadKey = function(cb)
    {
        this.fxReportDoneSortByQuadKey = cb;
    };
    
    WWM.prototype.SetParallelism = function(n)
    {
        var s  = _sve(this.isBusy, 0, Math.min(this.n, this.workers.length));
        this.n = n;
    
        if (s == 0)
        {
            this.TerminateWorkers();
        }//if
    };
    
    WWM.prototype.DispatchLogParseToVec = function(log, logId, userData)
    {
        var worker = this.GetWorkerForDispatch();
        var bufs   = null;
        var args   = { op:"PARSE_LOG_TO_VEC", log:log, logId:logId, userData:userData, is_more_fields:this.fxGetIsMoreFields(), deci:0, worker_id:worker[1] };
       
        if (typeof log != "string") // Preferably, the log is downloaded as an arraybuffer.  Arraybuffers are the only things
        {                           // that can be sent to a web worker without a slow-ass copy.  But this is only done for
            args.log = null;        // platforms that support the new experimental affaybuffer->text decode.  (currently Chrome, Firefox)
            args.logbuffer = log;
            bufs = [ log ];
        }//if
    
        worker[0].postMessage(args, bufs);
    
        log      = null;
        userData = null;
    };
    
    WWM.prototype.GetWorkerForDispatch = function()
    {
        var idx   = -1;
        var max_i = Math.min(this.n, this.workers.length);
    
        for (var i=0; i<max_i; i++)
        {
            if (this.isBusy[i] == 0)
            {
                idx = i;
            }//if
        }//for
    
        if (idx == -1)
        {
            this.index = this.index < max_i - 1 ? this.index + 1 : 0;
            idx        = this.index;
        }//if
    
        this.isBusy[idx] = 1;
    
        if (this.workers[idx] == null)
        {
            var worker = new Worker(this.workerSrcUrl);
            this.AddWorkerCallback(worker);
            this.workers[idx] = worker;
        }//if

        return [this.workers[idx], idx];
    };
    
    WWM.prototype.ReportWorkerIsDone = function(idx)
    {
        if (idx != null && idx > 0 && idx < this.isBusy.length)
        {
            this.isBusy[idx] = 0;
        }//if
    };
    
    WWM.prototype.TerminateWorkers = function()
    {
        if (this.workers == null) return;
    
        for (var i=0; i<this.workers.length; i++)
        {
            this.isBusy[i] = 1;
            
            if (this.workers[i] != null)
            {
                this.workers[i].terminate();
            }//if
        }//for
        
        this.isBusy  = new Uint8Array(this.n);
        this.workers = new Array(this.n);
        this.index   = 0;
        
        for (var i=0; i<this.n; i++)
        {
            this.workers[i] = null;
        }//for
    };
    
    WWM.prototype.AddWorkerCallback = function(worker)
    {
        worker.onerror = function(e)
        {
            var errline = e != null && e.lineno   != null ? e.lineno   : "<NULL>";
            var errfile = e != null && e.filename != null ? e.filename : "<NULL>";
            var errmsg  = e != null && e.message  != null ? e.message  : "<NULL>";
            console.log("WMM: ERROR from worker: Line " + errline + " in " + errfile + ": " + errmsg);
        }.bind(this);
    
        worker.onmessage = function(e)
        {
            if (e == null || e.data == null || e.data.op == null)
            {
                console.log("WWM: Message from worker: unknown.");
            }//if
            else if (e.data.op == "PARSE_LOG_TO_VEC")
            {
                var minzs   = new Int8Array(e.data.minzs);
                var cpms    = new Float32Array(e.data.cpms);
                var alts    = new Int16Array(e.data.alts);
                var degs    = new Int8Array(e.data.degs);
                var times   = new Uint32Array(e.data.times);
                var mxs     = new Uint32Array(e.data.mxs);
                var mys     = new Uint32Array(e.data.mys);
                var litcpms = new Float32Array(e.data.litcpms);
                var litcp5s = new Float32Array(e.data.litcp5s);
                var valids  = new Uint8Array(e.data.valids);
                var logId   = e.data.userData[0];
                var ex      = e.data.ex;
                
                this.fxReportDoneAssignZForLogId(logId);
                
                this.fxUpdateMarkerExtent(e.data.ex[0], e.data.ex[1], e.data.ex[2], e.data.ex[3]);
                
                this.ReportWorkerIsDone(e.data.worker_id);
                
                this.fxGetDataAndDispatchPrefilter(mxs, mys, minzs, cpms, alts, degs, times, litcpms, litcp5s, valids, logId, e.data.userData);
            }//else if
            else if (e.data.op == "MSG_START_PARSING")
            {
                this.fxReportStartParsingForLogId(e.data.userData[0]);
            }//else if
            else if (e.data.op == "TILE_CALLBACK")
            {
                this.fxReportDoneParsingForLogId(e.data.userData[0]);
                var tile_u08 = new Uint8Array(e.data.buffer);
                this.fxUpdateGlobalImage(tile_u08);
            }//else if
            else if (e.data.op == "DATA_FOR_PARSED_LOG")
            {
                var minzs   = new Int8Array(e.data.minzs);
                var cpms    = new Float32Array(e.data.cpms);
                var alts    = new Int16Array(e.data.alts);
                var degs    = new Int8Array(e.data.degs);
                var logids  = new Int32Array(e.data.logids);
                var times   = new Uint32Array(e.data.times);
                var mxs     = new Uint32Array(e.data.mxs);
                var mys     = new Uint32Array(e.data.mys);
            
                if (e.data.shouldAdd_c > 0)
                {
                    this.fxAddData(minzs, cpms, alts, degs, logids, times, mxs, mys);
                }//if

                this.ReportWorkerIsDone(e.data.worker_id);
            
                this.fxReportResultsSuccessForLogId(e.data.logId);
            }//else if
            else if (e.data.op == "ORDER_BY_QUADKEY_ASC")
            {
                var minzs   = new Int8Array(e.data.minzs);
                var cpms    = new Float32Array(e.data.cpms);
                var alts    = new Int16Array(e.data.alts);
                var degs    = new Int8Array(e.data.degs);
                var logids  = new Int32Array(e.data.logids);
                var times   = new Uint32Array(e.data.times);
                var mxs     = new Uint32Array(e.data.mxs);
                var mys     = new Uint32Array(e.data.mys);
                var litcpms = new Float32Array(e.data.litcpms);
                var litcp5s = new Float32Array(e.data.litcp5s);
                var valids  = new Uint8Array(e.data.valids);

                var is_single_log = true;
                var last_id = logids.length > 0 ? logids[0] : -1;

                for (var i=0; i<logids.length; i++)
                {
                    if (logids[i] != last_id)
                    {
                        is_single_log = false;
                        break;
                    }//if

                    last_id = logids[i];
                }//for

                if (!is_single_log)
                {
                    litcpms = null;
                    litcp5s = null;
                    valids  = null;
                }//if
                
                this.fxAddData(minzs, cpms, alts, degs, logids, times, mxs, mys, litcpms, litcp5s, valids);
                
                this.ReportWorkerIsDone(e.data.worker_id);
                
                this.fxReportDoneSortByQuadKey();
            }//else if
            else if (e.data.op == "SUMMARY_STATS")
            {
                this.summary_stats.push(e.data.summary_stats);
                this.fxCopySummaryStats(e.data.summary_stats);
                
                // 2015-03-31 ND: summary stats should be maintained somewhere else, this is temporary
                
                // get aggregate stats
                var ss = { n:0, dist_meters:0.0, time_ss:0.0, sum_usvh:0.0, mean_usvh:0.0, de_usv:0.0, min_usvh:9000.0, max_usvh:-9000.0, min_kph:9000.0, max_kph:-9000.0, min_alt_meters:9000.0, max_alt_meters:-9000.0 };
                
                for (var i=0; i<this.summary_stats.length; i++)
                {
                    var s = this.summary_stats[i];
                    
                    ss.n           += s.n;
                    ss.dist_meters += s.dist_meters;
                    ss.time_ss     += s.time_ss;
                    ss.sum_usvh    += s.sum_usvh;
                    ss.de_usv      += s.de_usv;

                    if (s.min_usvh < ss.min_usvh) ss.min_usvh = s.min_usvh;
                    if (s.max_usvh > ss.max_usvh) ss.max_usvh = s.max_usvh;

                    if (s.min_kph < ss.min_kph) ss.min_kph = s.min_kph;
                    if (s.max_kph > ss.max_kph) ss.max_kph = s.max_kph;
                    
                    if (s.min_alt_meters < ss.min_alt_meters) ss.min_alt_meters = s.min_alt_meters;
                    if (s.max_alt_meters > ss.max_alt_meters) ss.max_alt_meters = s.max_alt_meters;
                }//for
                
                ss.mean_usvh = ss.sum_usvh / ss.n;
                
                console.log("WWM: Aggregate [%d] summary stats: { n:%d, dist_km:%s, time_hh:%s, mean_usvh:%s, de_usv:%s, min_usvh:%s, max_usvh:%s, min_kph:%s, max_kph:%s, min_alt_meters:%s, max_alt_meters:%s };",
                            this.summary_stats.length,
                            ss.n,
                            (ss.dist_meters / 1000.0).toFixed(2),
                            (ss.time_ss / 3600.0).toFixed(2),
                            ss.mean_usvh.toFixed(2),
                            ss.de_usv.toFixed(2),
                            ss.min_usvh.toFixed(2),
                            ss.max_usvh.toFixed(2),
                            ss.min_kph.toFixed(0),
                            ss.max_kph.toFixed(0),
                            ss.min_alt_meters.toFixed(0),
                            ss.max_alt_meters.toFixed(0));
            }//else if
            else if ("DEBUG_MSG")
            {
                console.log("WWM: Worker: %s", e.data.txt);
            }//else if
            else
            {
                console.log("WWM: Message from worker: unknown. op:[%s]", e.data.op);
            }
        }.bind(this);
    };
    
    var _sve = function(s,o,n) { var e=0;for(var i=o;i<o+n;i++)e+=s[i];return e; };
    //var _vfill = function(x,d,n) { for(var i=0;i<n;i++)d[i]=x; }; // unused
    
    return WWM;
})();





// XF: Data transfer task.
//     Represents an instance of an object controlled by XFM, used for querying the API or downloading data.
var XF = (function()
{
    function XF(xfId, tagId, ordinal, url, fxCallback, userData, xfTitle, xfType, responseType, XFM_progress)
    {
        this.xfId         = xfId;
        this.ordinal      = ordinal;
        this.url          = url;
        this.bytes        = 0;
        this.bytes_max    = 0;
        this.fxCallback   = fxCallback;
        this.userData     = userData;
        this.xfTitle      = xfTitle + (xfType == XF.TypeLog ? " " + tagId : "");
        this.xfType       = xfType;
        this.done         = false;
        this.error        = false;
        this.callbackDone = false;
        this.tagId        = tagId;
        this.responseType = responseType;  //"arraybuffer", "blob", "document", "json", and "text"
        this.time_started = new Date();
        this.time_done    = null;
        this.XFM_progress = XFM_progress;
        this.statusText   = "Connecting";
        this._last_pct    = 0.0;
        this.isStarted    = false;
        this.isStartParsing = false;
        this.isDoneParsing = false;
        this.isDoneAssignZ = false;
    }//XF

    XF.prototype.SetSuccess = function()
    {
        this.callbackDone = true;
        this.time_done    = new Date();
        this.XFM_progress(this);
    };

    // 0 unsent, 1 open, 2 connected, 3 transfer, 4 done
    XF.prototype.HttpEventReadyStateChange = function(response, readyState, status)
    {
        var old_bytes = this.bytes;
        var rlen      = response == null ? 0 : this.responseType == "arraybuffer" ? response.byteLength : response.length;
    
        if (rlen > this.bytes) this.bytes = rlen;
    
        if (readyState === 4 && status == 200)
        {
            this.done       = true;
            this.statusText = "Done";
            
            this.XFM_progress(this);
            
            this.fxCallback(response, this.userData);
    
            this.fxCallback = null;
            this.userData   = null;
                
            if (this.xfType != XF.TypeLog)
            {
                this.SetSuccess();
            }//if
        }//if
        else if (readyState === 4 && status != 200)
        {
            this.statusText = "Error";
            this.done       = true;
            this.error      = true;
            this.fxCallback = null;
            this.userData   = null;
            this.time_done  = new Date();
            this.XFM_progress(this);
        }//else if
        else if (old_bytes != this.bytes)
        {
            var pct = parseFloat(this.bytes) / parseFloat(this.bytes_max);
            
            if (pct > this._last_pct * 1.01)
            {
                this.XFM_progress(this);
            }//if
            
            this._last_pct = pct;
        }//else if
    };
    
    XF.prototype.HttpEventProgress = function(evt)
    {
        if (evt.lengthComputable && this.bytes_max == 0)
        {
            this.bytes_max  = evt.total;
            this.statusText = "Downloading";
        }//if
        
        if (evt.loaded > this.bytes)
        {
            this.bytes = evt.loaded;
            
            var pct = parseFloat(this.bytes) / parseFloat(this.bytes_max);
            
            if (pct > this._last_pct * 1.01)
            {
                this.XFM_progress(this);
            }//if
            
            this._last_pct = pct;
        }//if
    };
    
    XF.prototype.HttpEventError = function(evt, eventName) // "error", "abort"
    {
        this.statusText = eventName == "error" ? "Error" : "Aborted";
        this.done       = true;
        this.error      = true;
        this.fxCallback = null;
        this.userData   = null;
        this.time_done  = new Date();
        this.XFM_progress(this);
    };
    
    XF.prototype.HttpGet = function()
    {
        this.isStarted = true;
    
        var req = new XMLHttpRequest();
        
        req.open("GET", this.url, true);
        
        if (this.responseType != null)
        {
            req.responseType = this.responseType;
        }//if
        
        var pCB = function(evt) { this.HttpEventProgress(evt);       }.bind(this);
        var eCB = function(evt) { this.HttpEventError(evt, "error"); }.bind(this);
        var aCB = function(evt) { this.HttpEventError(evt, "abort"); }.bind(this);
        
        req.addEventListener("progress", pCB, false);
        req.addEventListener("error",    eCB, false);
        req.addEventListener("abort",    aCB, false);
        
        req.onreadystatechange = function()
        {
            this.HttpEventReadyStateChange(req.response, req.readyState, req.status);
        }.bind(this);
                
        req.send(null);
        
        this.XFM_progress(this);
    };
    
    XF.prototype.GetProgressBytesText = function()
    {
        var bx = XF.GetKbOrMbWithLabelFor2xBytes(this.bytes, this.bytes_max);
        
        return "" + bx[0] + " / " + bx[1] + " " + bx[2]
    };
    
    XF.prototype.GetProgressPercentText = function()
    {
        return (this.GetProgressNormalized() * 100.0).toFixed(0) + "%";
    };
    
    XF.prototype.GetProgressNormalized = function()
    {
        return this.bytes_max > 0 ? parseFloat(this.bytes) / parseFloat(this.bytes_max) : 0.0;
    };
    
    XF.prototype.GetElapsedSinceDoneSS = function()
    {
        return this.time_done != null ? this.time_done.getTime() - this.time_started.getTime() : 0;
    };
    
    XF.prototype.GetElapsedTimeSS = function()
    {
        var d1 = new Date();
        return this.time_started.getTime() - d1.getTime();
    };
    
    XF.GetKbOrMbWithLabelFor2xBytes = function(x, y)
    {
        var fx, fy, txt;
        
        if (x >= 1048576 || y >= 1048576)
        {
            fx  = parseFloat(x) * 0.00000095367431640625;
            fy  = parseFloat(y) * 0.00000095367431640625;
            txt = "MB";
        }//if
        else
        {
            fx  = parseFloat(x) * 0.0009765625;
            fy  = parseFloat(y) * 0.0009765625;
            txt = "KB";
        }//else
        
        return [fx.toFixed(2), fy.toFixed(2), txt];
    };
    
    XF.TypeLog            = 0;  // download of full log text from a specific URL
    XF.TypeLogQueryByUser = 1;  // API query for log URLs, by a user ID
    XF.TypeLogQueryByLog  = 2;  // API query for log URL,  by a log ID
    XF.TypeLogQueryByText = 3;  // API query for log URLs, by text

    return XF;
})();



// XFM: Data transfer manager.
//      Injects HTML into divElement to show progress UI to user.
//      Currently has external HTML and CSS dependencies.
//      Spawns instances of XF that represent data transfer tasks.

// Note: This is designed to inject HTML for a UI panel into "divElement".
//       This uses several externally defined styles and an image.
//       To disable this, just pass null for "divElement."

var XFM = (function()
{
    function XFM(fxCallbackStart, fxCallbackEnd, userData, title, titleClass, divElement, tableClass, isMobile, world_png_url)
    {
        this.fxCallbackStart = fxCallbackStart;
        this.fxCallbackEnd   = fxCallbackEnd;
        this.userData        = userData;
    
        this.tasks   = new Array();
        this.xfmId   = "xfm" + parseInt((Math.random() * 65535) + 1);
        this.title   = title;        
        this.tiClass = titleClass;
        this.tbClass = tableClass;
        this.div     = divElement;
        this.hTbl    = null;
        this.bTbl    = null;
        this.cvx     = null;
        this.xf_div  = null;
        this.cpu_div = null;
        this.xf_n    = 0;
        this.mode    = XFM.ModeXF;
        this.logIds  = new Array();
        this.queue   = new Array();
        this.noUI    = this.div == null;
        this.para    = navigator.hardwareConcurrency != null ? navigator.hardwareConcurrency + 4 : isMobile ? 6 : 8; // todo: replace global function
        
        this.world_png_url = world_png_url;
        
        if (!this.noUI)
        {
            this.NewHeaderTableElement();
            this.NewBodyElements();
        }//if
    }//XFM
    
    XFM.prototype.ChangeMode = function(newMode)
    {
        if (this.mode == XFM.ModeXF && newMode == XFM.ModeCPU)
        {
            if (!this.noUI)
            {
                this.xf_div.style.visibility  = "hidden";
                this.cpu_div.style.visibility = "visible";
            }//if
            this.mode = newMode;
        }//if
        else if (this.mode == XFM.ModeCPU && newMode == XFM.ModeXF)
        {
            if (!this.noUI)
            {
                this.cpu_div.style.visibility = "hidden";
                this.xf_div.style.visibility  = "visible";
            }//if
            this.mode = newMode;
        }//else if
    };
    
    XFM.prototype.GetXFByTagIdAndType = function(tagId, xfType)
    {
        var xf = null;
        
        for (var i=0; i<this.tasks.length; i++)
        {
            if (this.tasks[i].tagId == tagId && this.tasks[i].xfType == xfType)
            {
                xf = this.tasks[i];
                break;
            }//if
        }//for
        
        return xf;
    };
    
    XFM.prototype.SetParallelism = function(n)
    {
        this.para = n + 4;
    };
    
    XFM.prototype.ProcessNextInQueue = function()
    {
        if (this.queue.length > 0)
        {
            var xf = this.queue.pop();
            xf.HttpGet();
        }//if
    };
    
    XFM.prototype.GetActiveTaskCount = function()
    {
        var active_n = 0;
        
        for (var i=0; i<this.tasks.length; i++)
        {
            if (this.tasks[i].isStarted && (!this.tasks[i].callbackDone && !this.tasks[i].isError)) active_n++;
        }//for
        
        return active_n;
    };
    
    XFM.prototype.StartTask = function(xf)
    {
        var n = this.GetActiveTaskCount();
        
        if (n <= this.para || xf.xfType != XF.TypeLog)
        {
            xf.HttpGet();
        }//if
        else
        {
            this.queue.push(xf);
        }//else
    };
    
    XFM.prototype.AddTask = function(url, responseType, fxCallback, userData, xfTitle, xfType, tagId)
    {
        if (xfType == XF.TypeLog)
        {
            for (var i=0; i<this.logIds.length; i++)
            {
                if (this.logIds[i] == tagId)
                {
                    console.log("XFM: logId=%d already on map, request denied.", tagId);
                    return;
                }//if
            }//for
        }//if
    
        var cb = function(xf)
        {
            this.XFCallback(xf);
        }.bind(this);
        
        var xf = new XF(this.xfmId + "_" + this.xf_n, tagId, this.xf_n + 1, url, fxCallback, userData, xfTitle, xfType, responseType, cb);
        
        this.tasks.push(xf);
        
        this.xf_n = this.xf_n + 1;
        
        this.fxCallbackStart(this.userData);
        
        requestAnimationFrame(function() {
            this.DataBindRow(xf);
        }.bind(this));
        
        this.StartTask(xf);
    };
    
    XFM.prototype.GetLogIdsEncoded = function(limit)
    {
        var s = "";
        if (limit == null) limit = 25;
        
        var max_i = limit >= 0 && this.logIds.length > limit ? limit : this.logIds.length;
        
        for (var i=0; i<max_i; i++)
        {
            if (this.logIds[i] > 0)
            {
                s += "" + this.logIds[i] + (i < this.logIds.length - 1 ? "," : "");
            }//if
        }//for
        
        //return s == "" ? s : encodeURIComponent(s); // if the googs doesn't urlencode commas, why bother?
        
        return s;
    };
    
    XFM.prototype.GetAllLogIdsEncoded = function()
    {
        return this.GetLogIdsEncoded(-1);
    };
    
    XFM.prototype.GetLogIds = function()
    {
        return this.logIds;
    };
    
    XFM.prototype.ClearAllLogIds = function()
    {
        if (this.logIds.length > 0) this.ClearGlobalImage();
        
        this.logIds = new Array();
    };
    
    XFM.prototype.ClearGlobalImage = function()
    {
        var ctx = this.cvx.getContext("2d");
        ctx.clearRect(0, 0, this.cvx.width, this.cvx.height);
    };
    
    XFM.prototype.UpdateGlobalImage = function(tile_u08)
    {
        if (this.noUI) return;
        
        var ctx = this.cvx.getContext("2d");
        var x, y_w;

        for (var y=0; y<256; y++)
        {
            y_w = y * 256;
        
            for (x=0; x<256; x++)
            {
                if (tile_u08[y_w + x] > 0)
                {
                    ctx.beginPath();
                        var grd = ctx.createRadialGradient(x, y, 1, x, y, 7);
                        
                        grd.addColorStop(0, "rgba(0,0,255,1.0)");
                        grd.addColorStop(1, "rgba(0,0,255,0.0)");        

                        ctx.arc(x, y, 7, 0, 2 * Math.PI);
                        ctx.fillStyle = grd;
                    ctx.fill();
                }//if
            }//for x
        }//for y
    };

    // info only status
    XFM.prototype.ReportDoneParsingForLogId = function(logId)
    {
        var xf = this.GetXFByTagIdAndType(logId, XF.TypeLog);
        xf.isDoneParsing = true;
        this.DataBindRow(xf);
    };
    
    // info only status
    XFM.prototype.ReportDoneAssignZForLogId = function(logId)
    {
        var xf = this.GetXFByTagIdAndType(logId, XF.TypeLog);
        xf.isDoneAssignZ = true;
        this.DataBindRow(xf);
    };
    
    // info only status
    XFM.prototype.ReportStartParsingForLogId = function(logId)
    {
        var xf = this.GetXFByTagIdAndType(logId, XF.TypeLog);
        xf.isStartParsing = true;
        this.DataBindRow(xf);
    };
    
    
    XFM.prototype.ReportResultsSuccessForLogId = function(logId)
    {
        var matchIdx = -1;
    
        for (var i=0; i<this.tasks.length; i++)
        {
            if (this.tasks[i].xfType == XF.TypeLog && !this.tasks[i].callbackDone && this.tasks[i].done && !this.tasks[i].error && this.tasks[i].tagId == logId)
            {
                this.tasks[i].SetSuccess();
                matchIdx = i;
                break;
            }//if
        }//for
        
        if (matchIdx > -1)
        {
            this.ProcessNextInQueue();
        }//if
    };
    
    XFM.prototype.ReportResultsErrorForURL = function(url)
    {
        console.log("XFM: error reported for url: %s", url);
        
        var matchIdx = -1;
        var isTypeLog = false;
        
        for (var i=0; i<this.tasks.length; i++)
        {
            if (this.tasks[i].done && !this.tasks[i].error && this.tasks[i].url == url)
            {
                this.tasks[i].error      = true;
                this.tasks[i].statusText = "Error";
                
                isTypeLog = this.tasks[i].xfType == XF.TypeLog;
                matchIdx  = i;
                
                break;
            }//if
        }//for
        
        if (matchIdx > -1) this.XFCallback(this.tasks[matchIdx]);
    };
    
    XFM.prototype.UpdateLogIdsFromXF = function(xf)
    {
        if (xf != null && xf.callbackDone && !xf.error && xf.xfType == XF.TypeLog && xf.tagId != 0)
        {
            var alreadyExists = false;
                
            for (var i=0; i<this.logIds.length; i++)
            {
                if (this.logIds[i] == xf.tagId)
                {
                    alreadyExists = true;
                    break;
                }//if
            }//for
            
            if (!alreadyExists)
            {
                this.logIds.push(xf.tagId);
            }//if
        }//if
    };
    
    // invoked by task when progress / done / error
    XFM.prototype.XFCallback = function(xf)
    {
        var allDone = true;
        
        if (xf != null)
        {
            this.DataBindRow(xf);
            this.UpdateLogIdsFromXF(xf);
            
            if (xf.xfType == XF.TypeLog && xf.error)
            {
                this.ProcessNextInQueue();
            }//if
        }//if
        
        for (var i=0; i<this.tasks.length; i++)
        {
            if (!this.tasks[i].callbackDone && !this.tasks[i].error)
            {
                allDone = false;
            }//if
        }//for
        
        if (allDone)
        {
            this.fxCallbackEnd(this.userData);
        }//if
    };
    
    //array.splice( index, 1 );
    
    XFM.prototype.RemoveAllRows = function()
    {
        for (var i=0; i<this.bTbl.rows.length; i++)
        {
            this.bTbl.deleteRow(-1);
        }//for
    };
    
    XFM.prototype.DataBindRow = function(xf)
    {
        if (xf == null || this.noUI) return;
        
        var idx = -1;
        
        for (var i=0; i<this.bTbl.rows.length; i++)
        {
            if (this.bTbl.rows[i].id == xf.xfId)
            {
                idx = i;
                break;
            }//if
        }//for
        
        if (idx == -1 && xf.GetElapsedSinceDoneSS() < 3.0)
        {
            var row = this.bTbl.insertRow(0); // new at top
            row.id = xf.xfId;
            
            var td0 = row.insertCell(-1);
            td0.innerHTML = xf.ordinal + ".";
            td0.style.textAlign = "right";
            td0.style.width = "30px";
            
            var td1 = row.insertCell(-1);
            td1.innerHTML = xf.xfTitle;
            
            var td2 = row.insertCell(-1);
            td2.style.textAlign = "right";
            td2.innerHTML = _FormatXFCell(xf);
        }//if
        else if (xf.GetElapsedSinceDoneSS() < 3.0)
        {
            this.bTbl.rows[idx].cells[2].innerHTML = _FormatXFCell(xf);
        }//else
        else if (idx != -1 && xf.GetElapsedSinceDoneSS() >= 3.0)
        {
            this.bTbl.deleteRow(idx);
        }//else
    };
    
    XFM.prototype.NewHeaderTableElement = function()
    {
        this.hTbl               = document.createElement("table");
        this.hTbl.style.cssText = "width:256px;border:0px;padding:0px 0px 10px 0px;border-spacing:0px;"
        this.hTbl.className     = this.tbClass;
                
        var div           = document.createElement("div");
        div.className     = this.tiClass;
        div.style.cssText = "font-size:120%;left:0;right:0;"
        div.innerHTML     = this.title;
        
        var row  = this.hTbl.insertRow(0);
        var cell = row.insertCell(0);
        cell.style.textAlign = "center";
        cell.appendChild(div);
        
        this.div.appendChild(this.hTbl);
    };
    
    XFM.prototype.NewBodyElements = function()
    {
        var cdiv = document.createElement("div");
        cdiv.style.cssText = "position:relative;width:276px;height:256px;";
        
        var div0 = document.createElement("div");
        div0.style.cssText = "position:absolute;top:0;left:0;width:256px;height:256px;background:url('" 
                           + this.world_png_url 
                           + "') no-repeat;opacity:0.4;-webkit-filter:blur(2px);-moz-filter:blur(2px);-o-filter:blur(2px);-ms-filter:blur(2px);filter:blur(2px);";

        this.xf_div = document.createElement("div");
        this.xf_div.style.cssText = "position:absolute;top:0;left:0;width:276px;height:256px;overflow-x:hidden;overflow-y:auto;";
        
        this.cpu_div = document.createElement("div");
        this.cpu_div.style.cssText = "position:absolute;top:0;left:0;width:256px;height:256px;display:table;visibility:hidden;";
        
        this.cvx        = document.createElement("canvas");
        this.cvx.width  = 256;
        this.cvx.height = 256;
                
        this.bTbl               = document.createElement("table");
        this.bTbl.style.cssText = "width:256px;border:0px;padding:0px;border-spacing:0px;"
        this.bTbl.className     = this.tbClass;
        
        cdiv.appendChild(div0);
        cdiv.appendChild(this.xf_div);
        cdiv.appendChild(this.cpu_div);
        
        div0.appendChild(this.cvx);
        this.xf_div.appendChild(this.bTbl);
        
        var wait_text = "- Please Wait -";
        var proc_text = "Finalizing Data";

        this.cpu_div.innerHTML = "<div style='display:table-cell;vertical-align:middle;text-align:center;'><span style='font-size:140%'>"
                               + wait_text
                               + "</span><br/><span style='font-size:60%'>"
                               + proc_text
                               + "</span></div>";
        this.cpu_div.className = this.tbClass;
        
        this.div.appendChild(cdiv);
    };
    
    var _FormatXFCell = function(xf)
    {
        var queued_text     = "Queued";
        var merging_text    = "Merging";
        var processing_text = "Processing";
        var parsing_text    = "Parsing";
        var wait_text       = "[WAIT]";
    
        return    xf.error          ? xf.statusText 
               : !xf.isStarted      ? queued_text 
               :  xf.callbackDone   ? "100%" 
               :  xf.isDoneAssignZ  ? merging_text 
               :  xf.isDoneParsing  ? processing_text 
               :  xf.isStartParsing ? parsing_text 
               :  xf.done && xf.xfType == XF.TypeLog ? wait_text 
               :  xf.GetProgressPercentText();
    };
    
    XFM.ModeXF  = 0; // displays download list
    XFM.ModeCPU = 1; // displays "adding markers/please wait"

    return XFM;
})();






// LUT: contains color lookup table and returns RGB colors for a numeric value.
var LUT = (function()
{
    function LUT(min, max)
    {
        this.min = min;
        this.max = max;
        this.r = new Uint8Array([1,8,9,10,12,14,16,16,18,18,19,20,21,22,22,24,24,25,25,25,26,26,26,26,25,26,27,26,25,26,26,24,24,25,24,21,21,21,17,16,9,7,0,7,15,23,28,32,34,38,40,43,45,
                                 46,50,51,54,55,56,56,56,58,59,59,59,59,59,59,59,59,57,56,56,56,54,51,48,45,43,39,37,33,29,23,10,0,29,39,60,67,84,90,97,105,110,120,124,133,137,143,148,
                                 153,161,163,171,173,178,181,185,191,194,200,202,208,210,214,217,220,225,226,233,235,240,242,245,249,251,254,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255]);
        this.g = new Uint8Array([1,7,7,8,10,11,12,12,13,13,13,13,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,14,14,14,14,13,13,12,11,11,10,9,5,4,0,9,19,30,36,43,46,56,59,65,70,74,
                                 82,85,94,96,103,107,112,118,121,130,132,140,144,150,156,160,167,170,181,184,191,195,200,208,213,221,224,233,237,243,250,255,252,251,242,240,235,231,226,
                                 221,219,212,210,204,202,197,192,187,182,180,172,170,163,160,156,151,148,137,134,128,124,117,112,107,100,97,87,83,71,64,56,44,38,5,0,0,0,0,0,0,0,0,0,0,0,
                                 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,25,36,42,53,57,68,73,81,85,89,96,98,106,109,119,123,128,133,136,144,146,153,156,162,
                                 166,170,180,183,191,193,200,204,208,214,217,224,226,234,239,247,251,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]);
        this.b = new Uint8Array([1,10,12,15,19,23,29,31,38,39,43,48,54,59,61,70,72,79,83,89,94,99,109,112,122,125,135,140,145,153,158,169,173,186,191,199,206,212,223,228,239,244,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                 255,255,255,255,255,255,255,255,254,247,242,234,227,221,211,207,196,192,183,179,174,166,161,154,151,140,136,128,123,119,113,111,102,100,94,88,81,75,72,65,
                                 63,55,52,47,42,38,32,29,18,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,10,20,23,31,36,41,47,51,62,65,74,
                                 78,84,90,94,102,105,115,118,128,133,138,145,148,157,159,168,172,179,186,191,198,202,211,215,222,226,232,238,242,253]);
        this.n = this.r.length;
        this.rdiff = 1.0 / (this.max - this.min);
        this.nsb1  = parseFloat(this.n - 1.0);
    }//LUT
    
        //itovh8=function(s){var d="";for(var i=0;i<256;i++) d+=(s[i]<16?"0":"")+s[i].toString(16);return d;}
        //function bv_vhtoi8(d,s) { for (var i=0; i<d.length; i++) d[i] = parseInt("0x" + s.substring(i<<1, (i<<1) + 2)); }
    
    LUT.prototype.GetRgbForIdx = function(i)
    {
        return [this.r[i], this.g[i], this.b[i]];
    };
    
    LUT.prototype.GetIdxForValue = function(x, rsn)
    {
        x = (x - this.min) * this.rdiff;
        if (x > 1.0) x = 1.0; else if (x < 0.0) x = 0.0;
        x = Math.log(x * 9.0 + 1.0) * 0.43429448190325176;
        x = Math.log(x * 9.0 + 1.0) * 0.43429448190325176;
        x = Math.log(x * 9.0 + 1.0) * 0.43429448190325176;
        x = Math.log(x * 9.0 + 1.0) * 0.43429448190325176;
        
        var i = parseInt(x * this.nsb1);
        return rsn > 0 ? (i >> rsn) << rsn : i;
    };
    
    LUT.prototype.GetRgbForValue = function(x, rsn)
    {
        var i = this.GetIdxForValue(x, rsn);
        return [this.r[i], this.g[i], this.b[i]];
    };
    
    return LUT;
})();






// ICO: Renders marker icon to ivar "this.url" as base64 png.
//      Can be retained in cache as rendering pngs is slow.
//      This is completely ignorant of retina displays.
var ICO = (function()
{
    function ICO(width, height, deg, showBearingTick, lutidx, red, green, blue, alpha_fill, alpha_stroke, shadow_radius)
    {
        this.width  = width;
        this.height = height;
        this.deg    = deg;
        this.btick  = showBearingTick;
        this.lutidx = lutidx;
        this.red    = red;
        this.green  = green;
        this.blue   = blue;
        this.alpha0 = alpha_fill;
        this.alpha1 = alpha_stroke;
        this.shd_r  = shadow_radius;
        this.url    = null;
        
        this.Render();
    }//ICO
    
    ICO.prototype.Render = function()
    {
        var c     = document.createElement("canvas");
        
        var w_add = (this.shd_r - (this.width  >> 1)) * 2;
        var h_add = (this.shd_r - (this.height >> 1)) * 2;
        var w_px  = this.width  + Math.max(0, w_add);
        var h_px  = this.height + Math.max(0, h_add);
        
        c.width  = w_px;
        c.height = h_px;
        
        var ctx  = c.getContext("2d");
        var r    = ((this.width < this.height ? this.width : this.height) >> 1) - 1;

        var ox   = w_px  >> 1;
        var oy   = h_px >> 1;
        
        if (r <= 0) r = 1;

        if (this.alpha0 > 0.0)
        {
            ctx.beginPath();
                ctx.arc(ox, oy, r, 0, 2 * Math.PI);
                ctx.fillStyle = "rgba(" + this.red + ", " + this.green + ", " + this.blue + ", " + this.alpha0 + ")";
                if (this.shd_r > 0)
                {
                    ctx.shadowBlur  = this.shd_r;
                    ctx.shadowColor = "rgba(" + this.red + ", " + this.green + ", " + this.blue + ", 1.0)";
                }//if
            ctx.fill();
        }//if
        else if (this.shd_r > 0)
        {
            ctx.beginPath();
                var grd = ctx.createRadialGradient(ox, oy, 1, ox, oy, this.shd_r);
                grd.addColorStop(0, "rgba(" + this.red + ", " + this.green + ", " + this.blue + ", 0.25)");
                grd.addColorStop(1, "rgba(" + this.red + ", " + this.green + ", " + this.blue + ", 0.0)");        
                ctx.arc(ox, oy, this.shd_r, 0, 2 * Math.PI);
                ctx.fillStyle = grd;
            ctx.fill();
        }//else if
    
        if (this.alpha1 > 0.0 && this.width > 3)
        {
            ctx.beginPath();
                ctx.arc(ox, oy, r, 0, 2 * Math.PI);
                ctx.strokeStyle = "rgba(0, 0, 0, " + this.alpha1 + ")";
                ctx.lineWidth   = 0.5;
            ctx.stroke();
        }//if

        if (this.deg > 0 && this.width > 5 && this.btick)
        {
            var length = parseFloat(r);
            var length_factor = 1.0;
            var degrees = parseFloat(this.deg);
    
            // not sure why deg - 90 is needed...
            degrees = (degrees - 90.0) * 0.01745329251994329576923690768489; // ->rad

            var dx = Math.cos(degrees) * length * length_factor;
            var dy = Math.sin(degrees) * length * length_factor;
    
            var x = ox + dx;
            var y = oy + dy;
        
            x = Math.round(x);
            y = Math.round(y);
        
            ctx.beginPath();
                ctx.strokeStyle = "rgba(0, 0, 0, " + Math.max(this.alpha0, this.alpha1) + ")";
                ctx.lineWidth   = 1.0;
                ctx.moveTo(ox, oy);
                ctx.lineTo(x, y);
            ctx.stroke();
        }//if
    
        this.url = c.toDataURL("image/png");
    };
    
    ICO.GetIconOptionsForIconStyle = function(iconStyle)
    {
        var p;
        
        switch (iconStyle)
        {
            case ICO.IconStyleSm:
                p = [ 7, 7, 0.75, 0.75, 0.0, false];
                break;
            case ICO.IconStyleMdB:
                p = [ 10, 10, 0.75, 0.75, 0.0, true];
                break;
            case ICO.IconStyleLgB:
                p = [ 16, 16, 0.75, 0.75, 0.0, true];
                break;
            case ICO.IconStyleLg:
                p = [ 16, 16, 0.75, 0.75, 0.0, false];
                break;
            case ICO.IconStyleMd:
                p = [ 10, 10, 0.75, 0.75, 0.0, false];
                break;
            default:
                p = [ 10, 10, 0.75, 0.75, 0.0, true];
                break;
        }//switch
        
        return { width:p[0], height:p[1], fill_alpha:p[2], stroke_alpha:p[3], shadow_radius:p[4], show_bearing_tick:p[5] };
    };
    
    ICO.IconStyleSm     = 0;
    ICO.IconStyleMdB    = 1;
    ICO.IconStyleMd     = 2;
    ICO.IconStyleLgB    = 3;
    ICO.IconStyleLg     = 4;
    ICO.IconStyleCustom = 5;
    
    return ICO;
})();




// MKS: Marker manager
var MKS = (function()
{
    function MKS(mapRef, iconType, isRetina, isMobile, fontCssClass, fxGetWorkerForDispatch, fxClearAllLogIds, fxReportResultsSuccessForLogId)
    {
        // Typed arrays, these hold the parsed log data.
        this.minzs   = null;    // minimum zoom level to show this point at
        this.cpms    = null;    // CPM value of point
        this.alts    = null;    // Altitude of point, in meters.
        this.degs    = null;    // Bearing of next point, degrees * 0.35.  -1 indicates no bearing.
        this.logids  = null;    // Original LogIDs of points.
        this.times   = null;    // Datetime of marker, seconds since 1970-01-01.
        this.onmaps  = null;    // 1=is a marker currently on map.  0=not on map.
        this.mxs     = null;    // X coordinate.  EPSG:3857 pixel X/Y @ zoom level 21.
        this.mys     = null;    // Y coordinate.  EPSG:3857 pixel X/Y @ zoom level 21.
        this.litcpms = null;    // Literal CPM values from the logfile; note that "cpms" is rather autoselected cpm/cp5s. (OPTIONAL)
        this.litcp5s = null;    // Literal CP5S values from the logfile; note that "cpms" is rather autoselected cpm/cp5s. (OPTIONAL)
        this.valids  = null;    // Bitmask of radiation, GPS, and checksum validity. (OPTIONAL)
        
        this.isMobile = isMobile; // Disables some caching and renders less markers per pass.
        
        this.fontCssClass = fontCssClass;
        
        this.isSPARTAAAAAAA = false;  // Gives up on high-quality processing when merging datasets,
                                      // which becomes exponentially slower with probelm set size.
        
        this.mkType   = iconType;       // Predefined marker templates.
        this.isRetina = isRetina;       // Enables @2x marker icon resolution.
        this.width    = 10;             // Marker icon width, in non-retina pixels
        this.height   = 10;             // Marker icon height, in non-retina pixels
        this.alpha0   = 0.75;           // Marker icon fill alpha, [0.0 - 1.0]
        this.alpha1   = 0.75;           // Maker icon stroke alpha, [0.0 - 1.0]
        this.shd_r    = 0.0;            // Marker icon shadow radius, pixels.
        this.btick    = true;           // Marker icon: enables drawing bearing tick.
        this.icons    = new Array();
        
        this.lut      = new LUT(0.03 * 350.0, 65.535 * 350.0); // The LUT gets the RGB values for a value.

        this.mapref   = mapRef;
        this.inforef  = null;
        this.last_ex  = new Float64Array(7);    // last "add markers" extent
        this.last_rm_ex = new Float64Array(7);  // last "remove markers" extent
        
        // Note: Extent vec values are: x0, y0, x1, y1, ex0, ex1, z
        // 
        // For lat/lon (EPSG:4326) these are aka:
        //  x0: min_lon
        //  y0: min_lat
        //  x1: max_lon
        //  y1: max_lat
        // ex0: *if* the extent spans the 180th meridian, this contains the second extent's min_lon
        // ex1: *if* the extent spans the 180th meridian, this contains the second extent's max_lon
        //   z: zoom level
        //
        // (For EPSG:3857, these are later translated to pixel x/y coordinates at zoom level 21.)
        //
        // If no 180th meridian span is present, this is indicated with:
        //      EPSG:4326: -9000.0
        //      EPSG:3857:  0xFFFFFFFF (aka UINT32_MAX in C)
        
        this.markers = new Array(); // Markers currently on map.
        this.rmpool  = new Array(); // Recycle pool for a limited number of removed markers, to reduce object creation/destruction overhead.
        this.m_n     = 512;         // Number of elements in m_ids, m_midxs.
        this.m_ids   = new Int32Array(this.m_n);  // Currently same as m_idxs
        this.m_idxs  = new Uint32Array(this.m_n); // Correlates with markers in this.markers.  Index into this.mxs, this.cpms etc of data values.
                                                  // Scanning a typed array is faster than enumerating the marker objects.
        this.mk_ex   = new Float64Array([9000.0, 9000.0, -9000.0, -9000.0]); // x0, y0, x1, y1 - EPSG:4326 only.

        this.hover_iw = false;

        this.summary_stats = new Array();
        
        // callbacks to other stuff outside scope
        this.fxGetWorkerForDispatch = fxGetWorkerForDispatch;
        this.fxClearAllLogIds = fxClearAllLogIds;
        this.fxReportResultsSuccessForLogId = fxReportResultsSuccessForLogId;

        this.ApplyMarkerType(); // must fire on init
    }//MKS

    MKS.prototype.CopySummaryStats = function(s)
    {
        this.summary_stats.push(s);
    };

    MKS.prototype.GetSummaryStatsForLogId = function(log_id)
    {
        var d = null;

        for (var i=0; i<this.summary_stats.length; i++)
        {
            if (this.summary_stats[i].logId == log_id)
            {
                d = this.summary_stats[i];
                break;
            }//if
        }//for

        return d;
    };
    
    MKS.prototype.SetNewCustomMarkerOptions = function(width, height, alpha_fill, alpha_stroke, shadow_radius, hasBearingTick)
    {
        if (this.icons.length > 0) this.icons = new Array();
        
        this.RemoveAllMarkersFromMap();
        
        this.mkType = ICO.IconStyleCustom;
        this.width  = width;
        this.height = height;
        this.alpha0 = alpha_fill;
        this.alpha1 = alpha_stroke;
        this.shd_r  = shadow_radius;
        this.btick  = hasBearingTick;
        
        if (this.mxs != null)
        {
            this.AddMarkersToMapForCurrentVisibleExtent();
        }//if
    };
    
    MKS.prototype.SetNewMarkerType = function(markerType)
    {
        if (markerType != this.mkType)
        {
            if (this.icons.length > 0) this.icons = new Array();
            this.mkType = markerType;
            this.RemoveAllMarkersFromMap();
            this.ApplyMarkerType();
            this.AddMarkersToMapForCurrentVisibleExtent();
        }//if
    };
    
    MKS.prototype.ApplyMarkerType = function()
    {
        var p = ICO.GetIconOptionsForIconStyle(this.mkType);
        
        this.width  = p.width;
        this.height = p.height;
        this.alpha0 = p.fill_alpha;
        this.alpha1 = p.stroke_alpha;
        this.shd_r  = p.shadow_radius;
        this.btick  = p.show_bearing_tick;
    };
    
    MKS.prototype.UpdateMarkerExtent = function(x0, y0, x1, y1)
    {
        this.mk_ex[0] = Math.min(this.mk_ex[0], x0);
        this.mk_ex[1] = Math.min(this.mk_ex[1], y0);
        this.mk_ex[2] = Math.max(this.mk_ex[2], x1);
        this.mk_ex[3] = Math.max(this.mk_ex[3], y1);
    };
    
    MKS.prototype.IsMarkerExtentValid = function()
    {
        return this.mk_ex[0] >= -180.0 && this.mk_ex[0] <= 180.0 && this.mk_ex[1] >= -90.0 && this.mk_ex[1] <= 90.0
            && this.mk_ex[2] >= -180.0 && this.mk_ex[2] <= 180.0 && this.mk_ex[3] >= -90.0 && this.mk_ex[3] <= 90.0;
    };
    
    MKS.prototype.ApplyMapVisibleExtentForMarkers = function()    
    {
        if (!this.IsMarkerExtentValid())
        {
            console.log("MKS.ApplyMapVisibleExtentForMarkers: Invalid marker extent: (%1.8f, %1.8f) - (%1.8f, %1.8f)", this.mk_ex[0], this.mk_ex[1], this.mk_ex[2], this.mk_ex[3]);
            return;
        }//if
        
        var r = _GetRegionForExtentAndClientView_EPSG4326(this.mk_ex[0], this.mk_ex[1], this.mk_ex[2], this.mk_ex[3], this.mapref);
        this.mapref.panTo(r[0]);
        this.mapref.setZoom(r[1]);

        if (this.logids.length > 0 && this.litcpms != null)
        {
            // only show this prompt for api.safecast.org if the logfile hasn't been approved yet
            // theoretically this should also check the user for moderator status
            // it would be better if the status was checked from the same API call to get the log file URL

            var div_done = document.getElementById("done");

            if (div_done != null && div_done.className.indexOf("bar-warning") >= 0)
            {
                var ss = this.GetSummaryStatsForLogId(this.logids[0]);
                _ShowAnomalyAlertIfNeeded(ss);
            }//if
        }//if
    };
    
    MKS.prototype.ReallocMarkerIndexBuffersIfNeeded = function(new_n)
    {
        if (new_n > this.m_n)
        {
            var src_n   = this.m_n;
            var dest_n  = src_n + new_n;
            var newids  = new Int32Array(dest_n);
            var newidxs = new Uint32Array(dest_n);
            _vcopy_s32(newids,  0, this.m_ids,  0, src_n);
            _vcopy_u32(newidxs, 0, this.m_idxs, 0, src_n);
            this.m_ids  = newids;
            this.m_idxs = newidxs;
            this.m_n    = dest_n;
        }//if
    };

    MKS.prototype.PurgeData = function()
    {
        this.minzs   = null;
        this.cpms    = null;
        this.alts    = null;
        this.degs    = null;
        this.logids  = null;
        this.times   = null;
        this.lutidxs = null;
        this.onmaps  = null;
        this.mxs     = null;
        this.mys     = null;
        this.litcpms = null;
        this.litcp5s = null;
        this.valids  = null;
        this.rmpool  = new Array();
        this.mk_ex   = new Float64Array([9000.0, 9000.0, -9000.0, -9000.0]);
        this.fxClearAllLogIds();
    };

    MKS.prototype.RemoveAllMarkersFromMapAndPurgeData = function()
    {
        this.RemoveAllMarkersFromMap();
        this.PurgeData();
    };

    MKS.prototype.RemoveAllMarkersFromMap = function()
    {
        var idx;
        
        for (var i=0; i<this.markers.length; i++)
        {
            google.maps.event.clearInstanceListeners(this.markers[i]);
            this.markers[i].setMap(null);
            idx = this.m_idxs[i];
            this.onmaps[idx] = 0;
        }//for
        
        this.markers = new Array();
        this.last_ex = new Float64Array(7);
    };
    
    MKS.prototype.GetCurrentVisibleExtent = function()
    {
        var b   = this.mapref.getBounds();
        var y0  = b.getSouthWest().lat();
        var x0  = b.getSouthWest().lng();
        var y1  = b.getNorthEast().lat();
        var x1  = b.getNorthEast().lng();
        var z   = this.mapref.getZoom();
        var ex0 = -9000.0;
        var ex1 = -9000.0;
        
        if (x0 > x1) // 180th meridian handling -- need to split into second extent
        {            // but, y-coordinates stay the same, so only need two more x-coordinates.
            ex1 = x1;
            x1  =  180.0;
            ex0 = -180.0;
        }//if
        
        return [x0, y0, x1, y1, ex0, ex1, z];
    };
    
    MKS.prototype.RemoveMarkersFromMapForCurrentVisibleExtent = function()
    {
        if (this.markers.length < 1 || this.cpms == null) return;        
        
        var e = this.GetCurrentVisibleExtent();
        
        this.RemoveMarkersFromMapForExtent(e[0], e[1], e[2], e[3], e[4], e[5], e[6]);
        
        for (var i=0; i<7; i++)
        {
            this.last_rm_ex[i] = e[i];
        }//for
    };
    
    MKS.prototype.RecycleMarker = function(marker)
    {
        google.maps.event.clearInstanceListeners(marker);
        marker.setMap(null);
    
        // 2017-05-17 ND: desktop max 10k increase, uses ~45MB RAM per 10k
        if (this.rmpool.length < (this.isMobile ? 1000 : 10000))
        {
            marker.setIcon(null);
            this.rmpool.push(marker);
        }//if
    };
    
    MKS.prototype.RemoveMarkersFromMapForExtent = function(x0, y0, x1, y1, ex0, ex1, z)
    {
        var new_markers = new Array();
        var lat, lon, idx;
        var m_idx = 0;
        var x,y,m;
        
        var mex = this.GetMercExtentForLatLonExtent(this.last_rm_ex);
        var cex = this.GetMercExtentForLatLonExtent([x0, y0, x1, y1, ex0, ex1, z]);
        x0  = cex[0];
        y0  = cex[1];
        x1  = cex[2];
        y1  = cex[3];
        ex0 = cex[4];
        ex1 = cex[5];
        var nx0  = mex[0];
        var ny0  = mex[1];
        var nx1  = mex[2];
        var ny1  = mex[3];
        var nex0 = mex[4];
        var nex1 = mex[5];
        var nz   = mex[6];
        
        for (var i=0; i<this.markers.length; i++)
        {
            idx = this.m_idxs[i];
            m   = this.minzs[idx];
            x   = this.mxs[idx];
            y   = this.mys[idx];

            if ((   m > z 
                ||  y < y0 
                ||  y > y1 
                || (x < x0 && (ex0 == 0xFFFFFFFF || x < ex0))
                || (x > x1 && (ex1 == 0xFFFFFFFF || x > ex1)) ) // 2016-06-18 ND: test 180th fix
                //|| (x < x0 || (ex0 != 0xFFFFFFFF && x < ex0))
                //|| (x > x1 || (ex1 != 0xFFFFFFFF && x > ex1)) )
               )
            {
                this.RecycleMarker(this.markers[i]);
                this.markers[i]  = null;
                this.onmaps[idx] = 0;
            }//if
            else
            {
                new_markers.push(this.markers[i]);
                
                if (m_idx >= this.m_n) { this.ReallocMarkerIndexBuffersIfNeeded(m_idx + 16384); }
                
                this.m_ids[m_idx]  = idx; // this will be replaced with unique autoincrement ID
                this.m_idxs[m_idx] = idx;
                m_idx++;
            }//else
        }//for
        
        this.markers = new_markers;
    };

    
    MKS.prototype.AddMarkersToMapForCurrentVisibleExtent = function()
    {
        var e = this.GetCurrentVisibleExtent();
        
        // 2015-04-05 ND: Add check for valid marker extent (paranoia)
        var inMkEx = !this.IsMarkerExtentValid() || this.IsIntersectingExtents(e, this.mk_ex);
        
        if (inMkEx
            || (e[4] != -9000.0 && this.IsIntersectingExtents([e[4], e[1], e[5], e[3]], this.mk_ex))) // handle 180th meridian spans
        {
            this.AddMarkersToMapForExtentTimer(e[0], e[1], e[2], e[3], e[4], e[5], e[6], this.last_ex, 0, this.isMobile ? 500 : 2000, 0, null, null); // 2000
        }//if
        else
        {
            // 2015-04-05 ND: Reset last rendered marker extent when outside of marker extent entirely
            _vfill(0, this.last_ex, 0, this.last_ex.length);
        }//else
    };
    

    // reprojects extent from EPSG:4326 to EPSG:3857, pixel x/y @ zoom level 21
    MKS.prototype.GetMercExtentForLatLonExtent = function(ex)
    {
        var mex = new Uint32Array(7);
        mex[0] = _LonToX_z21(ex[0]);
        mex[1] = _LatToY_z21(_ClampLatToMercPlane(ex[3]));
        mex[2] = _LonToX_z21(ex[2]);
        mex[3] = _LatToY_z21(_ClampLatToMercPlane(ex[1]));
        mex[4] = ex[4] == -9000.0 ? 0xFFFFFFFF : _LonToX_z21(ex[4]);
        mex[5] = ex[5] == -9000.0 ? 0xFFFFFFFF : _LonToX_z21(ex[5]);
        mex[6] = ex[6];
        return mex;
    };
    
    MKS.prototype.IsIntersectingExtents = function(ex0, ex1)
    {
        return !(ex0[2] < ex1[0] || ex0[0] > ex1[2] || ex0[3] < ex1[1] || ex0[1] > ex1[3])
    };
    
    MKS.prototype.IsExtentEqual = function(ex0, ex1)
    {
        var isEqual = true;
        for (var i=0; i<ex0.length; i++)
        {
            if (ex0[i] != ex1[i])
            {
                isEqual = false;
                break;
            }//if
        }//for
        return isEqual;
    };

    // This rather messy function controls adding the markers, with a timed delay.
    // This is necessary as large numbers of markers would otherwise generate a "script on page has stopped responding" message.
    MKS.prototype.AddMarkersToMapForExtentTimer = function(x0, y0, x1, y1, ex0, ex1, z, last_ex, idx, limit, old_mn, arCs, csr)
    {
        if (this.cpms == null) return;
        var isFirstRun = arCs == null;
                
        if (isFirstRun)
        {
            var d0 = new Date();
            arCs   = this.GetCandidatesForAddMarkers(x0, y0, x1, y1, ex0, ex1, z, last_ex, limit);
            var ms = Date.now() - d0.getTime();
            
            if (ms >= 200) console.log("GetCandidates: %d ms for n=%d", ms, arCs[1]);
            
            old_mn = this.markers.length;
            csr    = null;

            if (idx != -1)
            {
                requestAnimationFrame(function() {
                    this.AddMarkersToMapForExtentTimer(x0, y0, x1, y1, ex0, ex1, z, last_ex, idx, limit, old_mn, arCs, csr); // this.last-ex -> last_ex: 2015-03-30 ND: attempt to fix no-draw issue
                }.bind(this));
            }//else if
        }//if
        else
        {
            var still_vis = this.IsExtentEqual([x0, y0, x1, y1, ex0, ex1, z], this.GetCurrentVisibleExtent()) || z == 21; // z=21 is hack for street view, need to fix this...
            
            if (!still_vis) 
            {
                _vfill(0, this.last_ex, 0, this.last_ex.length); // 2015-03-30 ND: attempt to fix no-draw issue on panning after abort
                return;                                             // 2015-04-05 ND: this may be unnecessary.  todo: remove and test.
            }//if
        
            requestAnimationFrame(function() {
                var d0 = new Date();
                idx = this.AddMarkersToMapForExtentLimited(x0, y0, x1, y1, ex0, ex1, z, idx, limit, old_mn, arCs, csr);
                var ms = Date.now() - d0.getTime();
                if (ms >= 200) console.log("AddCandidates: %d ms. (idx=%d/%d)%s", ms, idx, arCs != null && arCs[1] != null ? arCs[1] : 0, idx == -1 ? "[End]" : "");
                if (idx != -1) this.AddMarkersToMapForExtentTimer(x0, y0, x1, y1, ex0, ex1, z, last_ex, idx, limit, old_mn, arCs, csr);
            }.bind(this));
        }//else
    };

    
    MKS.prototype.GetCandidatesForAddMarkers = function(x0, y0, x1, y1, ex0, ex1, z, last_ex, limit)
    {
        if (this.cpms == null) return [null, -1];
        
        var old_mn = this.markers.length;
        var m_idx  = old_mn;
        var mex    = this.GetMercExtentForLatLonExtent(last_ex); // reproject extents from EPSG:4326 -> EPSG:3857
        var cex    = this.GetMercExtentForLatLonExtent([x0, y0, x1, y1, ex0, ex1, z]);
        x0  = cex[0];
        y0  = cex[1];
        x1  = cex[2];
        y1  = cex[3];
        ex0 = cex[4];
        ex1 = cex[5];
        var nx0  = mex[0];
        var ny0  = mex[1];
        var nx1  = mex[2];
        var ny1  = mex[3];
        var nex0 = mex[4];
        var nex1 = mex[5];
        var nz   = mex[6];
        
        var x, y, v, m, i;

        var chunk_n = 32768;

        var cs = new Uint32Array(chunk_n);
        var cs_n = 0;
    
        for (i=0; i<this.cpms.length; i++)
        {
            // 2017-05-17 ND: remove ()|0 asm.js-style int32_t hack (mixing int32_t / uint32_t anyway...)
            x = this.mxs[i];
            y = this.mys[i];
            v = this.onmaps[i];
            m = this.minzs[i];

            if (    v == 0  &&  m <= z 
                &&  y >= y0 &&  y <= y1
                && (   (x >= x0  && x <= x1)
                    || (x >= ex0 && x <= ex1))
                && (    z != nz  // z > nz // m > nz
                    ||  y < ny0 
                    ||  y > ny1 
                    || (x < nx0 || (nex0 != 0xFFFFFFFF && x < nex0))
                    || (x > nx1 || (nex1 != 0xFFFFFFFF && x > nex1)))) // 2015-03-30 ND: were (x < nx0 && (nex0 == 0xFFFFFFFF || x < nex0)), fix for 180th meridian extent testing
            {
                cs[cs_n++] = i;
                
                if (cs_n >= cs.length - 1)
                {
                    var _cs = new Uint32Array(cs.length + chunk_n);
                    _vcopy_u32(_cs, 0, cs, 0, cs.length);
                    cs = _cs;
                    chunk_n *= 2;
                }//if
            }//if
        }//for
        
        // z_diff is to convert from zoom level 21 to whatever is actually being rendered,
        // which is easily accomplished by a right-shift.
        
        // However, spacing markers every 1 pixel is slow and useless, so to control
        // density it further right shifts by up to 2 if possible, resulting in a target
        // density of every 4 pixels.
        
        var z_diff = (21 - z) >>> 0;
        if (z > 0) z_diff = (z_diff + 1) >>> 0;
        if (z > 1) z_diff = (z_diff + 1) >>> 0;
        
        var mmx = null, mmy = null, mmc = null, ccx = null, ccy = null, ccc = null;
        
        // This speeds things up by 2x (no gather-scatter), but at the cost of RAM...
        // approx 12MB heap for 300k candidates and 100k on map, in addition to other
        // mallocs during this time.
        
        var mem_use = 0;
        
        this.SortCandidatesIdxOnlyByQuadKey(cs, cs_n, z); // test in-place quadkey sort
        
        if (this.isMobile) // find memory use if on mobile platform
        {
            mem_use =  ((256 << (21>>>z_diff)) < 65536 ? 2 : 4);        // x/y vec element size
            mem_use += (mem_use * 2 * cs_n) + (mem_use * 2 * old_mn);   // x/y vecs total size
            mem_use += 2 * cs_n + 2 * old_mn;                           // cpm vecs total size
            mem_use =  mem_use / 1024 / 1024;                           // bytes -> MB
        }//if
        
        if (!this.isMobile || mem_use <= 8) // only make caches if not mobile or if less than 8 MB of RAM would be used.
        {
            mmx = (256 << (21>>>z_diff)) <= 65536 ? new Uint16Array(old_mn) : new Uint32Array(old_mn);
            mmy = (256 << (21>>>z_diff)) <= 65536 ? new Uint16Array(old_mn) : new Uint32Array(old_mn);            
            mmc = new Uint16Array(old_mn);
        
            for (i=0; i<old_mn; i++)
            {
                mmx[i] = this.mxs[this.m_idxs[i]] >>> z_diff;
                mmy[i] = this.mys[this.m_idxs[i]] >>> z_diff;
                mmc[i] = this.cpms[this.m_idxs[i]] * 0.18724571; // rescale to uint16_t range
            }//for

            ccx = (256 << (21>>>z_diff)) <= 65536 ? new Uint16Array(cs_n) : new Uint32Array(cs_n);
            ccy = (256 << (21>>>z_diff)) <= 65536 ? new Uint16Array(cs_n) : new Uint32Array(cs_n);            
            ccc = new Uint16Array(cs_n);
        
            for (i=0; i<cs_n; i++)
            {
                ccx[i] = this.mxs[cs[i]] >>> z_diff;
                ccy[i] = this.mys[cs[i]] >>> z_diff;
                ccc[i] = this.cpms[cs[i]] * 0.18724571; // rescale to uint16_t range
            }//for
        }//if
        
        //var add_buffer = new Uint32Array(limit);
        var add_buffer = new Uint32Array(4096); // need to malloc for worst case when doing tile chunking ... every 4px = 64x64 = 4096
        
        return [cs, cs_n, mmx, mmy, mmc, ccx, ccy, ccc, add_buffer];
    };
    
    MKS.prototype.AddMarkersToMapForExtentLimited = function(x0, y0, x1, y1, ex0, ex1, z, idx, limit, old_mn, arCs, csr)
    {
        if (arCs[2] == null) 
        {
            return this.AddMarkersToMapForExtentLimitedLowMem(x0,y0,x1,y1,ex0,ex1,z,idx,limit,old_mn,arCs,csr);
        }//if
        
        var z_diff = (21 - z) >>> 0;
        if (z > 0) z_diff = (z_diff + 1) >>> 0;
        if (z > 1) z_diff = (z_diff + 1) >>> 0; // only for tile xy calc
    
        var i, j, k, ridx, exists, mx, my, z_diff, cpm, csi;
        var c        = 0;
        
        var tx = -1;
        var ty = -1;
        var last_tx = -1;
        var last_ty = -1;

        // 2017-05-17 ND: remove check for -1 by pushing init value beyond upper bounds
        var next_tile_idx_initval = cs_n + 1;
        var next_tile_idx = next_tile_idx_initval;
        
        var cs   = arCs[0];
        var cs_n = arCs[1];
        var mmx  = arCs[2];
        var mmy  = arCs[3];
        var mmc  = arCs[4];    
        var ccx  = arCs[5];
        var ccy  = arCs[6];
        var ccc  = arCs[7];
        var adds = arCs[8];

        
        for (i=idx; i<cs_n; i++)
        {
            csi         = cs[i];
            exists      = false;
            
            if (this.onmaps[csi] == 0) // in case changed by another timer "process"
            {
                tx = (ccx[i] << z_diff) >>> (29 - z);
                ty = (ccy[i] << z_diff) >>> (29 - z);
            
                // 2017-05-10 ND: no need for last_tx != -1 conditional, since it would be set if c > 0
                if (c > 0 && (tx != last_tx || ty != last_ty)) break;
                    
                if (next_tile_idx == next_tile_idx_initval)
                {
                    for (j=i+1; j<cs_n; j++)
                    {
                        if (   (ccx[j] << z_diff) >>> (29 - z) != tx
                            || (ccy[j] << z_diff) >>> (29 - z) != ty)
                        {
                            next_tile_idx = j;
                            break;
                        }//if
                    }//for
                }//if
            
                cpm = ccc[i] >>> 1;
                mx  = ccx[i];
                my  = ccy[i];

                for (j=i+1; j<cs_n; j++)
                {
                    if (   mx == ccx[j]
                        && my == ccy[j])
                    {
                        if (cpm > ccc[j])  // replace mode
                        {
                            ridx = cs[j];
                               
                            for (k=0; k<c; k++) // find where old point was in add list
                            {
                                if (adds[k] == ridx)
                                {
                                    adds[k] = csi;
                                    break;
                                }//if
                            }//for
                        }//if
                    
                        exists = true;
                        break;
                    }//if
                    
                    // 2017-05-17 ND: remove check for -1 by pushing init value beyond upper bounds
                    if (j >= next_tile_idx) break;
                }//for
            
                if (!exists)
                {
                    cpm >>>= 2;
                    
                    for (j=0; j<old_mn; j++)
                    {
                        if (   mx == mmx[j]
                            && my == mmy[j]
                            && cpm < mmc[j])
                        {
                            exists = true;
                            break;
                        }//if
                    }//for
                    
                    if (!exists)
                    {
                        adds[c] = csi;
                        c++;
                    
                        if (c >= 4096) break;
                    }//if
                }//if
                
                last_tx = tx;
                last_ty = ty;
            }//if
        }//for
        

        this.AddMarkersToMapForIdxAddList(adds, c);

        if (i > idx + 1) i--; // decrement for next tile

        if (i >= cs_n - 2)
        {
            this.last_ex[0] = x0;
            this.last_ex[1] = y0;
            this.last_ex[2] = x1;
            this.last_ex[3] = y1;
            this.last_ex[4] = ex0;
            this.last_ex[5] = ex1;
            this.last_ex[6] = z;
        }//if
        
        return i >= cs_n - 2 ? -1 : i;
    };
    
    // 2x slower due to gather-scatter and types, but doesn't malloc temp buffers
    MKS.prototype.AddMarkersToMapForExtentLimitedLowMem = function(x0, y0, x1, y1, ex0, ex1, z, idx, limit, old_mn, arCs, csr)
    {
        var i, j, k, ridx, exists, mx, my, z_diff, cpm, csi;
        var c        = 0;
        var cs       = arCs[0];
        var cs_n     = arCs[1];
        var adds     = arCs[8];
        
        var tx = -1;
        var ty = -1;
        var last_tx = -1;
        var last_ty = -1;
        // 2017-05-17 ND: remove check for -1 by pushing init value beyond upper bounds
        var next_tile_idx_initval = cs_n + 1;
        var next_tile_idx = next_tile_idx_initval;
        
        var z_diff = (21 - z) >>> 0;
        if (z > 0) z_diff = (z_diff + 1) >>> 0;
        if (z > 1) z_diff = (z_diff + 1) >>> 0;
        
        for (i=idx; i<cs_n; i++)
        {
            csi         = cs[i];
            exists      = false;
            
            if (this.onmaps[csi] == 0) // in case changed by another timer "process"
            {
                tx = this.mxs[csi] >>> (21 - z + 8);
                ty = this.mys[csi] >>> (21 - z + 8);
            
                // 2017-05-10 ND: no need for last_tx != -1 conditional, since it would be set if c > 0
                if (c > 0 && (tx != last_tx || ty != last_ty)) break;

                if (next_tile_idx == next_tile_idx_initval)
                {
                    for (j=i+1; j<cs_n; j++)
                    {
                        if (   this.mxs[cs[j]] >>> (29 - z) != tx
                            || this.mys[cs[j]] >>> (29 - z) != ty)
                        {
                            next_tile_idx = j;
                            break;
                        }//if
                    }//for
                }//if
            
                cpm = this.cpms[csi] * 0.5;
                mx  = this.mxs[csi] >>> z_diff;
                my  = this.mys[csi] >>> z_diff;

                for (j=i+1; j<cs_n; j++)
                {
                    if (   mx == (this.mxs[cs[j]] >>> z_diff)
                        && my == (this.mys[cs[j]] >>> z_diff))
                    {
                        if (cpm > this.cpms[cs[j]])  // replace mode
                        {
                            ridx = cs[j];
                               
                            for (k=0; k<c; k++) // find where old point was in add list
                            {
                                if (adds[k] == ridx)
                                {
                                    adds[k] = csi;
                                    break;
                                }//if
                            }//for
                        }//if
                    
                        exists = true;
                        break;
                    }//if
                    
                    // 2017-05-17 ND: remove check for -1 by pushing init value beyond upper bounds
                    if (j >= next_tile_idx) break;
                }//for
            
                if (!exists)
                {
                    cpm *= 0.2;
                    
                    for (j=0; j<old_mn; j++)
                    {
                        if (   mx == (this.mxs[this.m_idxs[j]] >>> z_diff)
                            && my == (this.mys[this.m_idxs[j]] >>> z_diff)
                            && cpm < this.cpms[this.m_idxs[j]])
                        {
                            exists = true;
                            break;
                        }//if
                    }//for
                    
                    if (!exists)
                    {
                        adds[c] = csi;
                        c++;
                    
                        if (c >= 4096) break;
                    }//if
                }//if
                
                last_tx = tx;
                last_ty = ty;
            }//if
        }//for
        
        this.AddMarkersToMapForIdxAddList(adds, c);

        if (i > idx + 1) i--; // decrement for next tile

        if (i >= cs_n - 2)
        {
            this.last_ex[0] = x0;
            this.last_ex[1] = y0;
            this.last_ex[2] = x1;
            this.last_ex[3] = y1;
            this.last_ex[4] = ex0;
            this.last_ex[5] = ex1;
            this.last_ex[6] = z;
        }//if
        
        return i >= cs_n - 2 ? -1 : i;
    };
    
    
    MKS.prototype.AddMarkersToMapForIdxAddList = function(adds, n)
    {
        var i, csi, lat, lon, lutidx;
        var marker_n = this.markers.length;
        var m_idx    = marker_n;
        var rsn      = this.isMobile ? 2 : 2;
        var newmks   = new Array(n); // 2017-05-17 ND: add to map in 2nd step

        // 2017-05-17 ND: Add presort.
        // 2017-05-17 ND: The main performance limiting step for many markers is Gmaps' rendering.
        //                Ideally, this waits for an unknown period of time before firing a second
        //                timer in a batch operation to add the markers, and sorts them by z-index.
        //                Actually, the mechanics of this are unknown.  So an initial sort by
        //                what will become the z-index value is performed.
        //                In the worst case, adding a marker with a z-index below the marker tiles'
        //                max z-index could theoretically cause Gmaps to redraw the entire thing.
        //                And this could theoretically occur many times for a single tile.

        newmks.sort(function(a, b) {
            return this.cpms[a[0]] > this.cpms[b[0]] ?  1
                 : this.cpms[a[0]] < this.cpms[b[0]] ? -1
                 :                                      0;
        });
        
        for (i=0; i<n; i++)
        {
            csi = adds[i];
            
            this.onmaps[csi] = 1;
            lat    = _YtoLat_z21(this.mys[csi]);
            lon    = _XtoLon_z21(this.mxs[csi]);
            lutidx = this.lut.GetIdxForValue(this.cpms[csi], rsn);
                    
            //this.AddMarker(csi, lat, lon, this.degs[csi], lutidx);
            newmks[i] = this.GetNewMarker(csi, lat, lon, this.degs[csi], lutidx);
                    
            if (m_idx >= this.m_n) { this.ReallocMarkerIndexBuffersIfNeeded(marker_n + m_idx + 16384); }
            this.m_ids[m_idx]  = csi; // this wil be replaced by a unique autoincrement ID
            this.m_idxs[m_idx] = csi;
            
            m_idx++;
        }//for

        for (i=0; i<n; i++)
        {
            newmks[i].setMap(this.mapref);
        }//for
    };

    MKS.prototype.GetNewMarker = function(marker_id, lat, lon, deg, lutidx)
    {   
        var icon_url = this.GetIconCached(deg, lutidx);
        var w_add    = (this.shd_r - (this.width  >> 1)) * 2;
        var h_add    = (this.shd_r - (this.height >> 1)) * 2;
        var w_pt     = this.width  + Math.max(0, w_add);
        var h_pt     = this.height + Math.max(0, h_add);

        var size = new google.maps.Size(w_pt, h_pt);
        var anch = new google.maps.Point(w_pt >> 1, h_pt >> 1);
        var icon = { url:icon_url, size:size, anchor:anch };
                   
        if (this.isRetina) { icon.scaledSize = new google.maps.Size(w_pt, h_pt); }
        
        var yx     = new google.maps.LatLng(lat, lon);
        var marker = this.rmpool.length > 0 ? this.rmpool.pop() : new google.maps.Marker();
        
        marker.setPosition(yx);
        marker.setIcon(icon);
        marker.setZIndex(lutidx);
        marker.ext_id = marker_id;

        this.AttachInfoWindow(marker);
        this.markers.push(marker);

        return marker;
    };

    MKS.prototype.AddMarker = function(marker_id, lat, lon, deg, lutidx)
    {   
        var icon_url = this.GetIconCached(deg, lutidx);
        var w_add    = (this.shd_r - (this.width  >> 1)) * 2;
        var h_add    = (this.shd_r - (this.height >> 1)) * 2;
        var w_pt     = this.width  + Math.max(0, w_add);
        var h_pt     = this.height + Math.max(0, h_add);

        var size = new google.maps.Size(w_pt, h_pt);
        var anch = new google.maps.Point(w_pt >> 1, h_pt >> 1);
        var icon = { url:icon_url, size:size, anchor:anch };
                   
        if (this.isRetina) { icon.scaledSize = new google.maps.Size(w_pt, h_pt); }
        
        var yx     = new google.maps.LatLng(lat, lon);
        var marker = this.rmpool.length > 0 ? this.rmpool.pop() : new google.maps.Marker();
        
        marker.setPosition(yx);
        marker.setIcon(icon);
        marker.setZIndex(lutidx);
        marker.ext_id = marker_id;
        marker.setMap(this.mapref);
        
        this.AttachInfoWindow(marker);
        this.markers.push(marker);
    };

    MKS.prototype.GetIconCached = function(deg, lutidx)
    {
        var url  = null;       
        var w_px = this.isRetina ? this.width  << 1 : this.width;
        var h_px = this.isRetina ? this.height << 1 : this.height;
        var s_px = this.isRetina ? this.shd_r  << 1 : this.shd_r;
        deg      = parseInt(Math.round(parseFloat(_UnpackDegreeValue(deg))*0.03333333333333333)*30.0); // round to nearest 30 degree "tick"
        deg      = deg == 0 ? 360 : deg; // degrees=0 causes problems with rendering
        
        for (var i=0; i<this.icons.length; i++)
        {
            if (    this.icons[i].lutidx == lutidx 
                && (this.icons[i].deg    == deg || !this.btick)
                &&  this.icons[i].btick  == this.btick 
                &&  this.icons[i].width  == w_px
                &&  this.icons[i].height == h_px
                &&  this.icons[i].alpha0 == this.alpha0
                &&  this.icons[i].alpha1 == this.alpha1
                &&  this.icons[i].shd_r  == s_px)
            {
                url = this.icons[i].url;
                break;
            }//if
        }//for
        
        if (url == null)
        {
            var r = this.lut.r[lutidx];
            var g = this.lut.g[lutidx];
            var b = this.lut.b[lutidx];
            
            var ico = new ICO(w_px, h_px, deg, this.btick, lutidx, r, g, b, this.alpha0, this.alpha1, s_px);
            this.icons.push(ico);
            url = ico.url;
        }//if
        
        return url;
    };
    
    // someday, "id" will be a unique autoincrement ID, but for now it's the same as the index.
    MKS.prototype.GetIdxForMarkerId = function(marker_id)
    {
        return marker_id;
    };


    MKS.prototype.GetInfoWindowContentForId = function(marker_id)
    {
        var i = this.GetIdxForMarkerId(marker_id);
        
        if (this.cpms == null || i < 0 || i > this.cpms.length) return "";
        
        var unixMS = parseFloat(this.times[i]) * 1000.0;        
        var d     = new Date(unixMS);
        var sdate = d.toISOString().substring( 0, 10);
        var stime = d.toISOString().substring(11, 19);
        var sdeg  = this.degs[i] > 0 ? "" + parseInt(_UnpackDegreeValue(this.degs[i])) : "N/A";
        var sdre  = (this.cpms[i] * 0.0029940119760479).toFixed(2);
                 
        var litcpm  = this.litcpms != null ? this.litcpms[i] : null;
        var litcp5s = this.litcp5s != null ? this.litcp5s[i] : null;
        var is_valid_rad = null;
        var is_valid_gps = null;
        var is_valid_chk = null;

        if (this.valids != null)
        {
            is_valid_rad = _UnpackValids_RadValue(this.valids[i]);
            is_valid_gps = _UnpackValids_GpsValue(this.valids[i]);
            is_valid_chk = _UnpackValids_ChkValue(this.valids[i]);
        }//if

        var ss = this.GetSummaryStatsForLogId(this.logids[i]);

        return _GetInfoWindowHtmlForParams(sdre, this.cpms[i], this.alts[i], sdeg, sdate, stime, this.logids[i], litcpm, litcp5s, is_valid_rad, is_valid_gps, is_valid_chk, ss, this.fontCssClass);
    };
    
    MKS.prototype.AttachInfoWindow = function(marker)
    {
        if (this.hover_iw && !this.isMobile)
        {
            google.maps.event.addListener(marker, "mouseover", function() 
            {
                this.OpenRetainedInfoWindow(marker);
                google.maps.event.clearListeners(marker, "mouseout");
                google.maps.event.addListener(marker, "mouseout", function() { this.inforef.close(); }.bind(this));
            }.bind(this));
        
            google.maps.event.addListener(marker, "click", function() 
            {
                this.OpenRetainedInfoWindow(marker);
                google.maps.event.clearListeners(marker, "mouseout");
            }.bind(this));
        }//if
        else
        {
            google.maps.event.addListener(marker, "click", function() 
            {
                this.OpenRetainedInfoWindow(marker);
            }.bind(this));
        }//else
    };
    
    MKS.prototype.OpenRetainedInfoWindow = function(marker)
    {
        if (this.inforef == null) this.inforef = new google.maps.InfoWindow({size: new google.maps.Size(60, 40)});
        else this.inforef.close(); 
        this.inforef.setContent(this.GetInfoWindowContentForId(marker.ext_id));
        this.inforef.open(this.mapref, marker);
    };
    
    MKS.prototype.GetDataAndDispatchPrefilterVec = function(mxs, mys, minzs, cpms, alts, degs, times, litcpms, litcp5s, valids, logId, userData)
    {
        if (this.cpms != null && this.cpms.length > 300 * 300)
        {
            this.isSPARTAAAAAAA = true;
        }//if
        
        // if no data yet or the problem set size is too large, just add the data directly.
        if (this.cpms == null || this.cpms.length == 0 || this.isSPARTAAAAAAA || this.litcpms != null)
        {
            if (mxs != null && mxs.length > 0)
            {
                var logids = new Int32Array(mxs.length);
                _vfill(logId, logids, 0, logids.length);
                this.AddData(minzs, cpms, alts, degs, logids, times, mxs, mys, litcpms, litcp5s, valids);
            }//if
            
            this.fxReportResultsSuccessForLogId(logId);
            return;
        }//if

        // otherwise, make a copy of x/y/z/c values and ship it off to a web worker thread so
        // dupe points can be removed.

        var pack = this.GetDataCopyForPrefilter();        
        var ox = pack[0];
        var oy = pack[1];
        var oz = pack[2];
        var oc = pack[3];
        
        var worker = this.fxGetWorkerForDispatch();
        
        var noproc = this.litcpms != null;

        var params = { op:"PREFILTER_VECS", 
                       mxs:mxs.buffer, mys:mys.buffer, minzs:minzs.buffer, cpms:cpms.buffer, times:times.buffer, alts:alts.buffer, degs:degs.buffer,
                       oldmxs:ox.buffer, oldmys:oy.buffer, oldzs:oz.buffer, olddres:oc.buffer, 
                       logId:logId, userData:userData, isMobile:true, noproc:noproc, worker_id:worker[1] };

        var bufs   = [mxs.buffer, mys.buffer, minzs.buffer, cpms.buffer, times.buffer, alts.buffer, degs.buffer, ox.buffer, oy.buffer, oz.buffer, oc.buffer ];
        
        worker[0].postMessage(params, bufs);
    };
    
    MKS.prototype.GetDataCopyForPrefilter = function()
    {
        var dest_n    = this.cpms.length;
        var destmxs   = new Uint32Array(dest_n);
        var destmys   = new Uint32Array(dest_n);
        var destminzs = new Int8Array(dest_n);
        var destcpms  = new Uint16Array(dest_n);
        
        _vcopy_u32(destmxs,   0, this.mxs,   0, dest_n);
        _vcopy_u32(destmys,   0, this.mys,   0, dest_n);
        _vcopy_s08(destminzs, 0, this.minzs, 0, dest_n);
        _vsmul(this.cpms, 0.18724571, destcpms, dest_n); // rescale to uint16_t range

        return [destmxs, destmys, destminzs, destcpms];
    };

    
    MKS.prototype.AddData = function(newminzs, newcpms, newalts, newdegs, newlogids, newtimes, newmxs, newmys, newlitcpms, newlitcp5s, newvalids)
    {
        if (newcpms == null || newcpms.length < 2) return;

        // 2017-05-29 ND: Only add extended columns for a single log file (API use case).
        //                In the multiple log file use case, release them to free memory.
        if (this.logids == null && newlitcpms != null && this.litcpms == null)
        {
            this.litcpms = _vcombine_f32(this.litcpms, newlitcpms);
            this.litcp5s = _vcombine_f32(this.litcp5s, newlitcp5s);
            this.valids  = _vcombine_u08(this.valids,  newvalids);

            console.log("MKS.AddData: Adding extra fields.");
        }//if
        else if (this.litcpms != null)
        {
            this.litcpms = null;
            this.litcp5s = null;
            this.valids  = null;

            console.log("MKS.AddData: Purging extra fields.");
        }//else if

        this.minzs   = _vcombine_s08(this.minzs,  newminzs);
        this.cpms    = _vcombine_f32(this.cpms,   newcpms);
        this.alts    = _vcombine_s16(this.alts,   newalts);
        this.degs    = _vcombine_s08(this.degs,   newdegs);
        this.logids  = _vcombine_s32(this.logids, newlogids);
        this.times   = _vcombine_u32(this.times,  newtimes);
        this.mxs     = _vcombine_u32(this.mxs,    newmxs);
        this.mys     = _vcombine_u32(this.mys,    newmys);
        this.onmaps  = _vcombine_u08(this.onmaps, new Uint8Array(newcpms.length));
        
        console.log("MKS.AddData: Added %d items, new total = %d.", newcpms.length, this.cpms.length);
        
        newminzs   = null;
        newcpms    = null;
        newalts    = null;
        newdegs    = null;
        newlogids  = null;
        newtimes   = null;
        newmxs     = null;
        newmys     = null;
        newlitcpms = null;
        newlitcp5s = null;
        newvalids  = null;
    };
    
    
    MKS.prototype.SortCandidatesIdxOnlyByQuadKey = function(is, n, z)
    {
        var qks = new Array(n);
        z >>>= 0;
        
        var x,y,idx;
        
        for (var i=0; i<n; i++)
        {
            var s = "";
            var digit; // 48="0"
            var mask;
        
            idx = is[i];
        
            x = this.mxs[idx] >>> (29 - z);
            y = this.mys[idx] >>> (29 - z);
        
            for (var j=z; j>0; j--)
            {
                digit = 48;
                mask  = 1 << (j - 1);
            
                if ((x & mask) != 0) digit++;
                if ((y & mask) != 0) digit += 2;
            
                s += String.fromCharCode(digit);
            }//for

            qks[i] = [s, i, this.cpms[idx]];
        }//for
        
        qks.sort(function(a, b) {
            return a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : a[2] < b[2] ? -1 : b[2] < a[2] ? 1 : 0;
        });
        
        if (this.isMobile && n > 1000)
        {
            for (var i=0; i<n; i++) qks[i] = qks[i][1]; // try to free up some heap before temp buffer malloc on mobile
            
            var b32 = new Uint32Array(n);
                
            for (var i=0; i<n; i++) b32[i] =  is[qks[i]];
            for (var i=0; i<n; i++)  is[i] = b32[i];
            
            b32 = null;
        }//if
        else
        {
            var b32 = new Uint32Array(n);
                
            for (var i=0; i<n; i++) b32[i] =  is[qks[i][1]];
            for (var i=0; i<n; i++)  is[i] = b32[i];
            
            b32 = null;
        }//else        
    };
    
    
    MKS.prototype.SortByQuadKey = function()
    {
        var worker = this.fxGetWorkerForDispatch();

        var noproc = this.litcpms != null;

        if (!noproc)
        {
            this.litcpms = new Float32Array(1);
            this.litcp5s = new Float32Array(1);
            this.valids  = new Uint8Array(1);
        }//if
        
        var params = { op:"ORDER_BY_QUADKEY_ASC",  
                       userData:null, isMobile:this.isMobile, worker_id:worker[1], noproc:noproc,
                       mxs:this.mxs.buffer, mys:this.mys.buffer, minzs:this.minzs.buffer, cpms:this.cpms.buffer, times:this.times.buffer, alts:this.alts.buffer, degs:this.degs.buffer, logids:this.logids.buffer, litcpms:this.litcpms.buffer, litcp5s:this.litcp5s.buffer, valids:this.valids.buffer };

        var bufs   = [this.mxs.buffer, this.mys.buffer, this.minzs.buffer, this.cpms.buffer, this.times.buffer, this.alts.buffer, this.degs.buffer, this.logids.buffer, this.litcpms.buffer, this.litcp5s.buffer, this.valids.buffer ];
        
        worker[0].postMessage(params, bufs);
        
        this.mxs = null;
        this.mys = null;
        this.minzs = null;
        this.cpms = null;
        this.times = null;
        this.alts = null;
        this.degs = null;
        this.logids = null;
        this.onmaps = null;
        this.litcpms = null;
        this.litcp5s = null;
        this.valids = null;
    };

    var _ShowAnomalyAlertIfNeeded = function(summary_stats)
    {
        if (summary_stats == null)
        {
            return;
        }//if

        var d = "";

        if (summary_stats.max_usvh > 0.5)
        {
            d += "This log file contains a possible radiological anomaly. Max µSv/h: " + summary_stats.max_usvh.toFixed(2);
        }//if

        if (summary_stats.min_usvh <= 0.0)
        {
            d += (d.length > 0 ? "  " : "") + "This log file contains one or more measurements of 0.00 CPM/µSv/h.";
        }//if
        
        if (summary_stats.dist_meters <= 0.0)
        {
            d += (d.length > 0 ? "  " : "") + "This log file does not appear to contain movement.";
        }//if

        if (summary_stats.n <= 10)
        {
            d += (d.length > 0 ? "  " : "") + "This log file only contains " + summary_stats.n + " parseable lines.";
        }//if

        if (d.length > 0)
        {
            alert("Attention: " + d);
        }//if
    };
    
    var _GetInfoWindowHtmlForParams = function(dre, cpm, alt, deg, date, time, logId, litcpm, litcp5s, is_valid_rad, is_valid_gps, is_valid_chk, summary_stats, fontCssClass)
    {
        var d = "<table id='bv_iw_tbl_pt' style='border:0;border-collapse:collapse;' class='" + fontCssClass  + "'>";

        d += "<tr><td align=right>" + dre            + "</td><td>" + (litcpm == null ? "" : "") + "\u00B5" + "Sv/h" + "</td></tr>";
        d += "<tr><td align=right>" + cpm.toFixed(0) + "</td><td>" + (litcpm == null ? "" : "") + "CPM"             + "</td></tr>";

        if (litcpm != null)
        {
            d += "<tr><td align=right>" + litcpm.toFixed(0)  + "</td><td>"        + "Log CPM"     + "</td></tr>";
        }//if

        if (litcp5s != null)
        {
            d += "<tr><td align=right>" + litcp5s.toFixed(0) + "</td><td>"        + "Log CP5s"     + "</td></tr>";
        }//if

        d    += "<tr><td align=right>" + alt + "</td><td nowrap>" + "m alt"               + "</td></tr>"
              + "<tr><td align=right>" + deg + "</td><td nowrap>" + "\u00B0" + " heading" + "</td></tr>"
              + "<tr><td align=right nowrap>" + date + "<br/>" + time + "</td><td>UTC"    + "</td></tr>";

        if (is_valid_rad != null && !is_valid_rad)
        {
            d += "<tr><td align=right>" + (is_valid_rad ? "Valid" : "Invalid") + "</td><td nowrap>" + "Radiation" + "</td></tr>"
        }//if

        if (is_valid_gps != null && !is_valid_gps)
        {
            d += "<tr><td align=right>" + (is_valid_gps ? "Valid" : "Invalid") + "</td><td nowrap>" + "GPS" + "</td></tr>"
        }//if

        if (is_valid_chk != null && !is_valid_chk)
        {
            d += "<tr><td align=right>" + (is_valid_chk ? "Valid" : "Invalid") + "</td><td nowrap>" + "Checksum" + "</td></tr>"
        }//if

        var oc = "var bids = document.getElementById('bv_iw_div_ss');"
               + "var bitp = document.getElementById('bv_iw_tbl_pt');"
               + "if (bids != null && bitp != null)"
               + "{" 
               + "bids.style.display = bids.style.display == 'none' ? 'block' : 'none';"
               + "bitp.style.display = bitp.style.display == 'none' ? 'block' : 'none';"
               + "}";

        d    += "</table>";

        if (summary_stats != null)
        {
            var ss     = summary_stats;
            var de_str = ss.de_usv > 0.01 ? ss.de_usv.toFixed(2) : ss.de_usv.toFixed(4);
            var r0s = "<tr><td align=right>";
            var r1s = "<tr><td align=right style='padding-top:5px;'>";
            var c0s = "</td><td>";
            var c1s = "</td><td style='padding-top:5px;'>";
            var r0e = "</td></tr>";

            d += "<div id='bv_iw_div_ss' style='display:none; padding-top:10px;'>";
            d += "<table style='border:0;border-collapse:collapse;' class='" + fontCssClass  + "'>";
            d += "<tr><td align=center colspan=2 style='font-size:16px;'>" + "Log File Stats" + r0e;
            d += r1s + (ss.max_usvh*334.0).toFixed(0)     + c1s + "CPM, max"                  + r0e;
            d += r0s + (ss.mean_usvh*334.0).toFixed(0)    + c0s + "CPM, mean"                 + r0e;
            d += r0s + (ss.min_usvh*334.0).toFixed(0)     + c0s + "CPM, min"                  + r0e;
            d += r1s + ss.max_usvh.toFixed(2)             + c1s + "\u00B5" + "Sv/h, max"      + r0e;
            d += r0s + ss.mean_usvh.toFixed(2)            + c0s + "\u00B5" + "Sv/h, mean"     + r0e;
            d += r0s + ss.min_usvh.toFixed(2)             + c0s + "\u00B5" + "Sv/h, min"      + r0e;
            d += r1s + de_str                             + c1s + "\u00B5" + "Sv, total dose" + r0e;
            d += r1s + (ss.dist_meters/1000.0).toFixed(1) + c1s + "km, total"                 + r0e;
            d += r0s + ss.max_kph.toFixed(0)              + c0s + "kph, max"                  + r0e;
            d += r0s + ss.min_kph.toFixed(0)              + c0s + "kph, min"                  + r0e;
            d += r1s + ss.max_alt_meters.toFixed(0)       + c1s + "m, max alt."               + r0e;
            d += r0s + ss.min_alt_meters.toFixed(0)       + c0s + "m, min alt."               + r0e;
            d += r1s + (ss.time_ss/3600.0).toFixed(1)     + c1s + "hours"                     + r0e;
            d += r0s + ss.n                               + c0s + "lines"                     + r0e;
            d += "</table>";
            d += "</div>";
        }//if

        d    += "<div class=\""+fontCssClass+"\" style=\"cursor:pointer;position:absolute;top:0;left:0;font-size:70%;color:#9999FF;\" onclick=\"" + oc + "\">" 
              + Math.abs(logId)
              + "</div>";

        return d;
    };
    
    // based on the client's screen size and extent, find the center and zoom level
    // to pass to Google Maps to pan the view.
    var _GetRegionForExtentAndClientView_EPSG4326 = function(x0, y0, x1, y1, mapref)
    {
        var vwh = _GetClientViewSize();
        var mw  = mapref != null ? mapref.getDiv().clientWidth  : 0; // 2017-04-25 ND: bugfix for running in smaller div within window
        var mh  = mapref != null ? mapref.getDiv().clientHeight : 0;
        return _GetRegionForExtentAndScreenSize_EPSG4326(x0, y0, x1, y1, mw > 0 ? mw : vwh[0], mh > 0 ? mh : vwh[1]);
    };
    
    var _GetRegionForExtentAndScreenSize_EPSG4326 = function(x0, y0, x1, y1, vw, vh)
    {
        var yx0 = new google.maps.LatLng(y0+(y1-y0)*0.5, x0+(x1-x0)*0.5);
        var dz  = 3;
                
        for (var z = 20; z >= 0; z--)
        {
            var mxy0 = _LatLonToXYZ_EPSG3857(y1, x0, z);
            var mxy1 = _LatLonToXYZ_EPSG3857(y0, x1, z);
                    
            if (Math.abs(mxy1[0] - mxy0[0]) < vw && Math.abs(mxy1[1] - mxy0[1]) < vh)
            {
                dz = z;
                break;
            }//if
        }//for
    
        if (256 << dz < vw) dz++; // don't repeat world on x-axis
    
        return [yx0, dz];
    };
    
    var _GetClientViewSize = function()
    {
        var _w = window,
            _d = document,
            _e = _d.documentElement,
            _g = _d.getElementsByTagName("body")[0],
            vw = _w.innerWidth || _e.clientWidth || _g.clientWidth,
            vh = _w.innerHeight|| _e.clientHeight|| _g.clientHeight;
        
        return [vw, vh];
    };
    
    var _ClampLatToMercPlane = function(lat) { return lat > 85.05112878 ? 85.05112878 : lat < -85.05112878 ? -85.05112878 : lat; };
    
    var _LatLonToXYZ_EPSG3857 = function(lat, lon, z)
    {
        var x  = (lon + 180.0) * 0.002777778;
        var s  = Math.sin(lat * 0.0174532925199);
        var y  = 0.5 - Math.log((1.0 + s) / (1.0 - s)) * 0.0795774715459;
        var w  = 256 << z;
        var px = parseInt(x * w + 0.5);
        var py = parseInt(y * w + 0.5);
        return [px, py];
    };
    
    var _YtoLat_z21 = function(y)
    {
        return 90.0 - 360.0 * Math.atan(Math.exp(-(0.5 - y * 0.00000000186264514923095703125) * 6.283185307179586476925286766559)) * 0.318309886183790671538;
    };
    
    var _XtoLon_z21 = function(x)
    {
        return 360.0 * (x * 0.00000000186264514923095703125 - 0.5);
    };
    
    var _LatToY_z21 = function(lat)
    {
        var s = Math.sin(lat * 0.0174532925199);
        var y = 0.5 - Math.log((1.0 + s) / (1.0 - s)) * 0.0795774715459;
        return parseInt(y * 536870912.0 + 0.5);
    };
    
    var _LonToX_z21 = function(lon)
    {
        return parseInt((lon + 180.0) * 0.002777778 * 536870912.0 + 0.5);
    };
    
    // unused
    /*
    MKS.XYZtoLatLon_EPSG3857 = function (x, y, z)
    {
        var w = 256 << z;
        var r = 1.0  / w;
        x = x * r - 0.5;
        y = 0.5 - y * r;
        var lat = 90.0 - 360.0 * Math.atan(Math.exp(-y * 6.283185307179586476925286766559)) * 0.31830988618379067153776752674503;
        var lon = 360.0 * x;
        return [lat, lon];
    };
    */
    
    // unused
    /*
    MKS.MercXZtoMercXZ = function(x, src_z, dest_z)
    {
        return dest_z > src_z ? x << (dest_z - src_z) : x >>> (src_z - dest_z);
    };
    */
    
    // Bearing degrees are stored more compactly as an 8-bit signed integer, which loses precision, but
    // they're relatively non-essential and get rounded to 30 degree ticks for rendering markers anyway.
    var _UnpackDegreeValue = function(deg_s08)
    {
        return deg_s08 == -1 ? -1.0 : parseFloat(deg_s08) * 2.8346456692913385826771653543307;
    };

    var _UnpackValids_RadValue = function(valids_u08)
    {
        return (valids_u08 & 0x4) >>> 2;
    };

    var _UnpackValids_GpsValue = function(valids_u08)
    {
        return (valids_u08 & 0x2) >>> 1;
    };    

    var _UnpackValids_ChkValue = function(valids_u08)
    {
        return (valids_u08 & 0x1) >>> 0;
    };
    
    //MKS.vcombine_f64 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new Float64Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_f32 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new Float32Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_u32 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new  Uint32Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_s32 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new   Int32Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    //MKS.vcombine_u16 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new  Uint16Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_s16 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new   Int16Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_u08 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new   Uint8Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    var _vcombine_s08 = function(a,b) { if(a==null)return b;if(b==null)return a;var d=new    Int8Array(a.length+b.length);d.set(a);d.set(b,a.length);return d; }
    
    //MKS.vcopy_f64 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    //MKS.vcopy_f32 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    var _vcopy_u32 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    var _vcopy_s32 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    //MKS.vcopy_u16 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    //MKS.vcopy_s16 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    var _vcopy_u08 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    var _vcopy_s08 = function(d,od,s,os,n) { d.subarray(od,od+n).set(s.subarray(os,os+n)); };
    
    //MKS.vcopy_convert = function(d,od,s,os,n) { for(var i=od;i<od+n;i++)d[i]=s[os++]; };

    // id[x]s are used as indices into [s]rc and written to [d]est.
    //MKS.vindex_f32 = function(s,x,d,n) { var i,m=n-(n%4);for(i=0;i<m;i+=4){d[i]=s[parseInt(x[i])];d[i+1]=s[parseInt(x[i+1])];d[i+2]=s[parseInt(x[i+2])];d[i+3]=s[parseInt(x[i+3])];}for(i=m;i<m+n%4;i++)d[i]=s[parseInt(x[i])]; };
    //MKS.vindex_u32 = function(s,x,d,n) { var i,m=n-(n%4);for(i=0;i<m;i+=4){d[i]=s[x[i]];d[i+1]=s[x[i+1]];d[i+2]=s[x[i+2]];d[i+3]=s[x[i+3]];}for(i=m;i<m+n%4;i++)d[i]=s[x[i]]; };
    
    var _vsmul = function(s,x,d,n) { var i,m=n-(n%4);for(i=0;i<m;i+=4){d[i]=s[i]*x;d[i+1]=s[i+1]*x;d[i+2]=s[i+2]*x;d[i+3]=s[i+3]*x;}for(i=m;i<m+n%4;i++)d[i]=s[i]*x; };
    var _vfill = function(x,d,o,n) { var i,m=(o+n)-((o+n)%4);for(i=o;i<m;i+=4){d[i]=x;d[i+1]=x;d[i+2]=x;d[i+3]=x;}for(i=m;i<m+n%4;i++)d[i]=x; };

    return MKS;
})();