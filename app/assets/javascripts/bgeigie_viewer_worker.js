// ==============================================
// bGeigie Log Viewer - Web Worker
// ==============================================
// Nick Dolezal/Safecast, 2015-2017
// This code is released into the public domain.
// ==============================================

self.onmessage = function(e) {
  if (e.data.op == 'PARSE_LOG_TO_VEC') {
    self.ParseLogFileToVectors(
      e.data.log,
      e.data.logbuffer,
      e.data.userData,
      e.data.is_more_fields,
      e.data.logId,
      e.data.worker_id
    );
  } // if
  else if (e.data.op == 'PREFILTER_VECS') {
    self.PrefilterVecs(
      e.data.mxs,
      e.data.mys,
      e.data.minzs,
      e.data.cpms,
      e.data.times,
      e.data.alts,
      e.data.degs,
      e.data.oldmxs,
      e.data.oldmys,
      e.data.oldzs,
      e.data.olddres,
      e.data.logId,
      e.data.userData,
      e.data.isMobile,
      e.data.worker_id
    );
  } else if (e.data.op == 'ORDER_BY_QUADKEY_ASC') {
    self.SortByQuadKey(
      e.data.mxs,
      e.data.mys,
      e.data.minzs,
      e.data.cpms,
      e.data.times,
      e.data.alts,
      e.data.degs,
      e.data.logids,
      e.data.litcpms,
      e.data.litcp5s,
      e.data.valids,
      e.data.noproc,
      e.data.userData,
      e.data.isMobile,
      e.data.worker_id
    );
  } else {
    var txt = '[' + e.data.worker_id + '] onmesssage: [ERR] Invalid op: ' + e.data.op + '.';
    self.postMessage({ op: 'DEBUG_MSG', txt: txt, worker_id: e.data.worker_id });
  } // if
};

self.SortByQuadKey = function(
  bmxs,
  bmys,
  bminzs,
  bcpms,
  btimes,
  balts,
  bdegs,
  blogids,
  blitcpms,
  blitcp5s,
  bvalids,
  noproc,
  userData,
  isMobile,
  worker_id
) {
  var mxs = new Uint32Array(bmxs);
  var mys = new Uint32Array(bmys);
  var minzs = new Int8Array(bminzs);
  var cpms = new Float32Array(bcpms);
  var times = new Uint32Array(btimes);
  var alts = new Int16Array(balts);
  var degs = new Int8Array(bdegs);
  var logids = new Int32Array(blogids);
  var litcpms = new Float32Array(blitcpms);
  var litcp5s = new Float32Array(blitcp5s);
  var valids = new Uint8Array(bvalids);

  var n = cpms.length;

  if (n < 5000000 || (isMobile && n < 50000)) {
    // don't blow up due to RAM use
    var d0 = new Date();
    var qks = new Array(n);
    var x, y, z;

    for (var i = 0; i < n; i++) {
      var s = '';
      var digit; // 48="0"
      var mask;

      z = minzs[i] >>> 0;
      x = mxs[i] >>> (29 - z);
      y = mys[i] >>> (29 - z);

      for (var j = z; j > 0; j--) {
        digit = 48;
        mask = 1 << (j - 1);

        if ((x & mask) != 0) digit++;
        if ((y & mask) != 0) digit += 2;

        s += String.fromCharCode(digit);
      } // for

      qks[i] = [s, i];
    } // for

    var d1 = new Date();

    qks.sort(function(a, b) {
      return a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0;
    });

    var d2 = new Date();

    // try to survive the high RAM use of sort...

    for (var i = 0; i < n; i++) qks[i][0] = null;

    var idxs = new Uint32Array(n);

    for (var i = 0; i < n; i++) idxs[i] = qks[i][1];

    qks = null;

    var buf = new ArrayBuffer(n * 4);
    var buf_s08 = new Int8Array(buf);
    var buf_u08 = new Uint8Array(buf);
    var buf_s16 = new Int16Array(buf);
    var buf_u32 = new Uint32Array(buf);
    var buf_s32 = new Int32Array(buf);
    var buf_f32 = new Float32Array(buf);

    vindex_u32(minzs, idxs, buf_s08, n);
    vcopy_s08(minzs, 0, buf_s08, 0, n);

    vindex_u32(cpms, idxs, buf_f32, n);
    vcopy_f32(cpms, 0, buf_f32, 0, n);

    vindex_u32(alts, idxs, buf_s16, n);
    vcopy_s16(alts, 0, buf_s16, 0, n);

    vindex_u32(degs, idxs, buf_s08, n);
    vcopy_s08(degs, 0, buf_s08, 0, n);

    vindex_u32(logids, idxs, buf_s32, n);
    vcopy_s32(logids, 0, buf_s32, 0, n);

    vindex_u32(times, idxs, buf_u32, n);
    vcopy_u32(times, 0, buf_u32, 0, n);

    vindex_u32(mxs, idxs, buf_u32, n);
    vcopy_u32(mxs, 0, buf_u32, 0, n);

    vindex_u32(mys, idxs, buf_u32, n);
    vcopy_u32(mys, 0, buf_u32, 0, n);

    if (litcpms != null && litcpms.length == cpms.length) {
      vindex_u32(litcpms, idxs, buf_f32, n);
      vcopy_f32(litcpms, 0, buf_f32, 0, n);
      vindex_u32(litcp5s, idxs, buf_f32, n);
      vcopy_f32(litcp5s, 0, buf_f32, 0, n);
      vindex_u32(valids, idxs, buf_u08, n);
      vcopy_u08(valids, 0, buf_u08, 0, n);
    } // if

    idxs = null;
    buf_f32 = null;
    buf_s32 = null;
    buf_u32 = null;
    buf_s16 = null;
    buf_s08 = null;
    buf_u08 = null;
    buf = null;

    var ms_idx = d1.getTime() - d0.getTime();
    var ms_sort = d2.getTime() - d1.getTime();
    var ms_apply = d2.getTime() - d2.getTime();

    var txt =
      '[' + worker_id + '] SortByQuadkey: { idx:' + ms_idx + ' ms, sort:' + ms_sort + ' ms, apply:' + ms_apply + ' }';
    self.postMessage({ op: 'DEBUG_MSG', txt: txt, worker_id: worker_id });
  } // if

  self.postMessage(
    {
      op: 'ORDER_BY_QUADKEY_ASC',
      userData: userData,
      worker_id: worker_id,
      mxs: mxs.buffer,
      mys: mys.buffer,
      minzs: minzs.buffer,
      times: times.buffer,
      cpms: cpms.buffer,
      alts: alts.buffer,
      degs: degs.buffer,
      logids: logids.buffer,
      litcpms: litcpms.buffer,
      litcp5s: litcp5s.buffer,
      valids: valids.buffer,
    },
    [
      mxs.buffer,
      mys.buffer,
      minzs.buffer,
      times.buffer,
      cpms.buffer,
      alts.buffer,
      degs.buffer,
      logids.buffer,
      litcpms.buffer,
      litcp5s.buffer,
      valids.buffer,
    ]
  );
};

// note that both a string (log) and arraybuffer (logbuffer) must be accepted as input for now
// until the TextDeccoder is part of the offical W3C spec.  The function will polyfill, but
// probably not very efficiently.
//
self.ParseLogFileToVectors = function(log, logbuffer, userData, isMoreFields, logId, worker_id) {
  self.postMessage({ op: 'MSG_START_PARSING', userData: userData });

  if (log == null && logbuffer != null) log = self.GetStringForArrayBuffer(logbuffer);

  var dest = new Array();
  var isMobile = userData[2];

  var tile_u08 = new Uint8Array(65536);
  var prefilter_n = 0;
  var min_z = 0;
  var i, j, lines, data;

  var destminzs = null;
  var destcpms = null;
  var destalts = null;
  var destdegs = null;
  var destlogids = null;
  var desttimes = null;
  var destmxs = null;
  var destmys = null;
  var idx = 0;

  // 2017-05-29 ND: Add optional additional columns for human logfile review
  var destlitcpms = null;
  var destlitcp5s = null;
  var destvalids = null;

  var s_header,
    s_id,
    s_time,
    s_cpm,
    s_cp5s,
    s_totc,
    s_rnStatus,
    s_latitude,
    s_northsouthindicator,
    s_longitude,
    s_eastwestindicator,
    s_altitude,
    s_gpsStatus,
    s_dop,
    s_quality,
    s_checksum;
  var blat, blon, bcpm, spatialMatch, comp_cpm, bcpm5s, blitcpm, blitcp5s;

  var x_min = 9000.0; // extent
  var y_min = 9000.0;
  var x_max = -9000.0;
  var y_max = -9000.0;

  var x, s, y, w, px, py;
  w = parseFloat(256 << 21);

  lines = log.split('\n');
  log = null;

  destcpms = new Float32Array(lines.length);
  destalts = new Int16Array(lines.length);
  destdegs = new Int8Array(lines.length);
  desttimes = new Uint32Array(lines.length);
  destmxs = new Uint32Array(lines.length);
  destmys = new Uint32Array(lines.length);
  destminzs = new Int8Array(lines.length);
  // 2017-05-29 ND: Add optional additional columns for human logfile review
  if (isMoreFields) {
    destlitcpms = new Float32Array(lines.length);
    destlitcp5s = new Float32Array(lines.length);
    destvalids = new Uint8Array(lines.length);
  } // if

  var last_lat = -9000.0;
  var last_lon = -9000.0;
  var last_i = -1;
  var high_n = 0;
  var high_thr = 100.0; // 330.0

  // summary stats
  var ss = {
    n: 0,
    dist_meters: 0.0,
    time_ss: 0.0,
    sum_usvh: 0.0,
    mean_usvh: 0.0,
    de_usv: 0.0,
    min_usvh: 9000.0,
    max_usvh: -9000.0,
    min_alt_meters: 9000.0,
    max_alt_meters: -9000.0,
    min_kph: 9000.0,
    max_kph: -9000.0,
    logId: logId,
  };

  for (i = 0; i < lines.length; i++) {
    data = lines[i] != null && lines[i].length > 0 ? lines[i].split(',') : null;

    if (data != null && data.length > 13) {
      // && data[0] != "$BMRDD" && data[0] != "$BGRDD" && data[0] != "$BNRDD")
      // hack for bug in bgeigie firmware where no \n is appened to the header/initial line
      if (data[0] != null && data[0].length > 0 && data.length == 16 && data[0].substring(0, 1) == '#') {
        for (j = 0; j < 15; j++) {
          data[j] = data[j + 1];
        } // for
      } // if

      // NB: example of random bad line in logfile, cause unknown
      // $BMRDD,100,20SI-P- T23:47:04Z,65,5,147602,A,0.00,2,220912,N,,V,,**68

      // NB: example of power-on and bad data during init
      // # Version,1.4.7
      // $BMRDD,153,2015-02-25T20:52:06Z,40,4,40,V,,,,,,V,,0*60
      // $BMRDD,153,2015-02-25T20:52:37Z,44,1,62,A,3545.2449,N,13941.6144,E,108.9,A,3.55,1*6F

      // # format=1.3.4nano
      // $BNRDD,2001, 2015-12-01T06:16:27Z, 30,  6,     30, V, 3539.3681, N, 13942.2259, E, -11.10, A,   6, 140*49

      // # format=1.3.5nano
      // $BNRDD,2720, 2017-03-20T17:44:42Z,3477,296,239624, A, 3813.7904, N, 10845.0602, W, 1896.50,V,   0, 9999*4C

      // # format=1.0.0nano
      // $BNRDD, 200, 2012-08-14T09:33:35Z, 64,  7,     91, A, 5123.2925, N,  3006.6467, E, 120.40, A, 150,  3*44

      // # firmware=1.3.9jp
      // $BMRDD,107,2013-03-11T08:28:59Z,8,8,8,V,3738.2746,N,14057.3248,E,20.5,A,0.80,2*43

      // # firmware=1.3.9
      // $BMRDD, 100, 2012-09-23T02:17:31Z, 70, 11, 156730, A, 3544.7495, N, 13955.0880, E,  15.0,  A, 0.82, 2*69
      //    0     1             2            3   4     5    6      7      8       9     10    11   12   13    14

      // NB: "quality" is inconsistent between logs and is not fully documented, perhaps due to differences in GPS chipsets or firmwares
      // NB: format / firmware is not consistently reported
      // NB: "dop" (HDOP) is inconsistent between logs and varies by orders of magnitudes

      // ---  ---     -----------------------
      // Col  Def     Desc
      // ---  ---     -----------------------
      //  0   [ ]     header
      //  1   [ ]     id
      //  2   [x]     time
      //  3   [\]     cpm
      //  4   [/]     cp5s
      //  5   [ ]     totc
      //  6   [o]     rnStatus                     'A' ok, 'V' invalid.
      //  7   [\]     latitude
      //  8   [/]     northsouthindicator
      //  9   [\]     longitude
      // 10   [/]     eastwestindicator
      // 11   [x]     altitude
      // 12   [o]     gpsStatus                    'A' ok, 'V' invalid.
      // 13   [ ]     dop
      // 14   [ ]     quality                      0 = invalid, 1 = GPS Fix, 2 = DGPS Fix.
      //      [ ]     *                            separator between quality and checksum
      //      [o]     checksum                     not including first $ and last *

      // s_header              = data[0];                // non-default
      // s_id                  = data[1];                // non-default
      s_time = data[2];
      s_cpm = data[3];
      s_cp5s = data[4];
      // s_totc                = data[5];                // non-default
      s_rnStatus = data[6]; // non-default
      s_latitude = data[7];
      s_northsouthindicator = data[8];
      s_longitude = data[9];
      s_eastwestindicator = data[10];
      s_altitude = data[11];
      s_gpsStatus = data[12]; // non-default
      // s_dop                 = data[13];                 // non-default

      if (destvalids != null && data[14].indexOf('*') > -1 && data[14].length > 1) {
        // s_quality         = data[14].split("*")[0];   // non-default
        s_checksum = data[14].split('*')[1]; // non-default
      } // if

      if (s_latitude != null && s_latitude.length > 0 && s_longitude != null && s_longitude.length > 0) {
        blat = parseFloat(s_latitude);
        blon = parseFloat(s_longitude);
        blitcpm = parseFloat(s_cpm);
        bcpm = blitcpm;
        blitcp5s = parseFloat(s_cp5s);

        high_n = bcpm > high_thr ? 0 : high_n + 1; // samples since last high range measurement

        if (s_cp5s != null && s_cp5s.length > 0) {
          // was: 750.0
          bcpm5s = blitcp5s * 12.0; // CPS for 5s -> CPM

          if (bcpm5s > 0.0 && ((bcpm > high_thr && bcpm5s > bcpm * 0.1 && bcpm5s < bcpm * 10.0) || high_n < 13)) {
            bcpm = bcpm5s / (1.0 - bcpm5s * 0.0000018833); // replace if at a high CPM and seems valid with deadtime correction
          } // if
        } // if
        else {
          bcpm5s = -9000.0; // indicate nodata
        } // else

        blat = Math.abs(blat) * 0.01;
        blon = Math.abs(blon) * 0.01;
        blat = (blat - parseInt(blat)) * 0.01666666666666666666666666666667 * 100.0 + parseInt(blat);
        blon = (blon - parseInt(blon)) * 0.01666666666666666666666666666667 * 100.0 + parseInt(blon);

        if (s_northsouthindicator.toUpperCase() == 'S') blat *= -1.0;
        if (s_eastwestindicator.toUpperCase() == 'W') blon *= -1.0;

        if (blat > -85.05112878 && blat < 85.05112878 && blon >= -180.0 && blon <= 180.0) {
          if (blat != 0.0 && blon != 0.0) {
            if (blat > y_max) y_max = blat;
            if (blat < y_min) y_min = blat;
            if (blon > x_max) x_max = blon;
            if (blon < x_min) x_min = blon;
          } // if

          var unixMS = s_time == null ? 0.0 : Date.parse(s_time);
          desttimes[idx] = unixMS == null ? 0.0 : parseInt(unixMS * 0.001);
          destcpms[idx] = bcpm;
          destalts[idx] = parseInt(s_altitude);

          x = (blon + 180.0) * 0.00277777777777777777777777777778;
          s = Math.sin(blat * 0.01745329251994329576923690768489);
          y = 0.5 - Math.log((1.0 + s) / (1.0 - s)) * 0.07957747154594766788444188168626;

          destmxs[idx] = x * w + 0.5;
          destmys[idx] = y * w + 0.5;

          if (destlitcpms != null) {
            destlitcpms[idx] = blitcpm;
            destlitcp5s[idx] = blitcp5s;
            destvalids[idx] =
              ((s_rnStatus == 'A' ? 1 : 0) << 2) |
              ((s_gpsStatus == 'A' ? 1 : 0) << 1) |
              (IsValidChecksum(lines[i], s_checksum) ? 1 : 0);
          } // if

          tile_u08[((destmys[idx] >>> 21) << 8) + (destmxs[idx] >>> 21)] = 255;

          if (idx > 0)
            destdegs[idx - 1] = parseInt(
              self.GetHeading_EPSG4326(last_lat, last_lon, blat, blon) * 0.35277777777777777777777777777778
            );

          // *** summary stats ****

          var dist = PointDistanceMeters_EPSG4326(last_lat, last_lon, blat, blon);
          var alt = destalts[idx];
          var kph = dist * 0.072;
          ss.n++;

          if (!isNaN(bcpm) && !isNaN(bcpm5s)) {
            ss.sum_usvh += bcpm;
            ss.de_usv += (bcpm5s != -9000.0 ? bcpm5s : bcpm) * 0.000039682539683; // -> uSv/h, for 5 seconds

            if (bcpm > ss.max_usvh) ss.max_usvh = bcpm;
            if (bcpm < ss.min_usvh) ss.min_usvh = bcpm;
            if (alt > ss.max_alt_meters) ss.max_alt_meters = alt;
            if (alt < ss.min_alt_meters) ss.min_alt_meters = alt;
          } // if

          if (kph < 1225.0) {
            // speed of sound in air -- sanity limit
            if (kph > ss.max_kph) ss.max_kph = kph;
            if (kph < ss.min_kph) ss.min_kph = kph;
            ss.dist_meters += dist;
          } // if

          last_lat = blat;
          last_lon = blon;

          idx++;
        } // if
      } // if
    } // if
  } // for

  data = null;

  // summary stats
  if (ss.n > 0) {
    ss.time_ss = ss.n * 5.0;
    ss.sum_usvh *= 0.0029940119760479;
    ss.mean_usvh = ss.sum_usvh / ss.n;
    ss.min_usvh *= 0.0029940119760479;
    ss.max_usvh *= 0.0029940119760479;

    self.postMessage({ op: 'SUMMARY_STATS', summary_stats: ss, worker_id: worker_id });
  } // if

  for (i = 0; i < idx; i++) destminzs[i] = -1;

  var unassigned_n = 0;

  if (idx > 0) {
    self.postMessage({ op: 'TILE_CALLBACK', userData: userData, worker_id: worker_id, buffer: tile_u08.buffer }, [
      tile_u08.buffer,
    ]);

    self.AssignScaleVisibilityToVecs(
      destmxs,
      destmys,
      destminzs,
      destcpms,
      destlitcpms,
      destlitcp5s,
      destvalids,
      idx,
      worker_id
    );

    unassigned_n = vscount_s08(destminzs, -1, idx);
  } // if

  var ex = [x_min, y_min, x_max, y_max];

  if (lines.length != idx && unassigned_n == 0) {
    destmxs = vtrunc_u32(destmxs, idx);
    destmys = vtrunc_u32(destmys, idx);
    desttimes = vtrunc_u32(desttimes, idx);
    destcpms = vtrunc_f32(destcpms, idx);
    destalts = vtrunc_s16(destalts, idx);
    destdegs = vtrunc_s08(destdegs, idx);

    // 2017-05-29 ND: Add optional additional columns for human logfile review
    if (isMoreFields) {
      destlitcpms = vtrunc_f32(destlitcpms, idx);
      destlitcp5s = vtrunc_f32(destlitcp5s, idx);
      destvalids = vtrunc_u08(destvalids, idx);
    } // if

    destminzs = vtrunc_s08(destminzs, idx);
  } // if
  else if (lines.length != idx && unassigned_n > 0) {
    var nn = idx - unassigned_n;
    destmxs = vcmprs_u32(destmxs, -1, destminzs, nn, idx);
    destmys = vcmprs_u32(destmys, -1, destminzs, nn, idx);
    desttimes = vcmprs_u32(desttimes, -1, destminzs, nn, idx);
    destcpms = vcmprs_f32(destcpms, -1, destminzs, nn, idx);
    destalts = vcmprs_s16(destalts, -1, destminzs, nn, idx);
    destdegs = vcmprs_s08(destdegs, -1, destminzs, nn, idx);

    // 2017-05-29 ND: Add optional additional columns for human logfile review
    if (isMoreFields) {
      destlitcpms = vcmprs_f32(destlitcpms, -1, destminzs, nn, idx);
      destlitcp5s = vcmprs_f32(destlitcp5s, -1, destminzs, nn, idx);
      destvalids = vcmprs_u08(destvalids, -1, destminzs, nn, idx);
    } // if

    destminzs = vcmprs_s08(destminzs, -1, destminzs, nn, idx);

    // var txt = "Log->Vec: Found "+unassigned_n+" unassigned rows.  Initial rows: "+idx+".  Final rows: "+destmxs.length+".";
    // self.postMessage( {op:"DEBUG_MSG", txt:txt, worker_id:worker_id } );
  } // else if

  lines = null;

  if (!isMoreFields) {
    destlitcpms = new Float32Array(1);
    destlitcp5s = new Float32Array(1);
    destvalids = new Uint8Array(1);
  } // if

  self.postMessage(
    {
      op: 'PARSE_LOG_TO_VEC',
      ex: ex,
      userData: userData,
      worker_id: worker_id,
      mxs: destmxs.buffer,
      mys: destmys.buffer,
      minzs: destminzs.buffer,
      times: desttimes.buffer,
      cpms: destcpms.buffer,
      alts: destalts.buffer,
      degs: destdegs.buffer,
      litcpms: destlitcpms.buffer,
      litcp5s: destlitcp5s.buffer,
      valids: destvalids.buffer,
    },
    [
      destmxs.buffer,
      destmys.buffer,
      destminzs.buffer,
      desttimes.buffer,
      destcpms.buffer,
      destalts.buffer,
      destdegs.buffer,
      destlitcpms.buffer,
      destlitcp5s.buffer,
      destvalids.buffer,
    ]
  );
};

self.AssignScaleVisibilityToVecs = function(mxs, mys, minzs, cpms, litcpms, litcp5s, valids, n, worker_id) {
  var cpm,
    z,
    zdest,
    i,
    j,
    zdest_n = 0,
    match,
    z_diff,
    mx,
    my,
    p,
    did_replace;

  var dest_cs = new Float32Array(n);
  var dest_xs = new Uint32Array(n);
  var dest_ys = new Uint32Array(n);
  var dest_is = new Uint32Array(n);
  // 2017-05-29 ND: Add optional additional columns for human logfile review
  /*
    var dest_ds = litcpms != null ? new Float32Array(n) : null;
    var dest_5s = litcp5s != null ? new Float32Array(n) : null;
    var dest_vs = valids  != null ? new Uint8Array(n)   : null;
    */

  did_replace = true;
  p = 0;

  while (did_replace) {
    did_replace = false;

    for (z = 0; z <= 21; z++) {
      z_diff = (21 - z) >>> 0;
      if (z > 0) z_diff = (z_diff + 1) >>> 0;
      if (z > 1) z_diff = (z_diff + 1) >>> 0;

      for (i = 0; i < n; i++) {
        if (minzs[i] == -1) {
          match = false;
          cpm = cpms[i]; // * mag;
          mx = mxs[i] >>> z_diff;
          my = mys[i] >>> z_diff;

          for (j = 0; j < zdest_n; j++) {
            if (mx == dest_xs[j] >>> z_diff && my == dest_ys[j] >>> z_diff) {
              if (cpm > dest_cs[j]) {
                // significantly higher value -- replace original point in-place to show maxima.
                dest_xs[j] = mxs[i];
                dest_ys[j] = mys[i];
                dest_cs[j] = cpms[i];

                // 2017-05-29 ND: Add optional additional columns for human logfile review
                /*
                                if (dest_ds != null)
                                {
                                    dest_ds[j] = litcpms[i];
                                    dest_5s[j] = litcp5s[i];
                                    dest_vs[j] = valids[i];
                                }//if
                                */

                minzs[dest_is[j]] = -1; // unassign original point

                minzs[i] = z;
                dest_is[j] = i;
                did_replace = true;
              } // if

              match = true;
              break;
            } // if (spatial match)
          } // for j

          if (!match) {
            dest_xs[zdest_n] = mxs[i];
            dest_ys[zdest_n] = mys[i];
            dest_cs[zdest_n] = cpms[i];

            /*
                        if (dest_ds != null)
                        {
                            dest_ds[zdest_n] = litcpms[i];
                            dest_5s[zdest_n] = litcp5s[i];
                            dest_vs[zdest_n] = valids[i];
                        }//if
                        */

            dest_is[zdest_n] = i;
            zdest_n++;
            minzs[i] = z;
          } // if
        } // if (unassigned)
      } // for i
    } // for z

    p++;
  } // while (did_replace)

  if (p > 2) {
    var txt = '[' + worker_id + '] AssignScaleVis: Passes: ' + p + '.';
    self.postMessage({ op: 'DEBUG_MSG', txt: txt, worker_id: worker_id });
  } // if

  dest_ys = null;
  dest_xs = null;
  dest_cs = null;
  /*
    dest_ds = null;
    dest_5s = null;
    dest_vs = null;
    */
}; // AssignScaleVisibilityToVecs

self.oldtile = null;
self.oldtile_last_n = 0;

self.PrefilterVecs = function(
  bmxs,
  bmys,
  bminzs,
  bcpms,
  btimes,
  balts,
  bdegs,
  boldmxs,
  boldmys,
  boldzs,
  bolddres,
  logId,
  userData,
  isMobile,
  worker_id
) {
  var i, j, ed, exists, dist;
  var shouldAdd_c = 0;

  var olddres = null;
  var oldmxs = null;
  var oldmys = null;
  var oldzs = null;

  var mxs = new Uint32Array(bmxs);
  var mys = new Uint32Array(bmys);
  var minzs = new Int8Array(bminzs);
  var times = new Uint32Array(btimes);
  var cpms = new Float32Array(bcpms);
  var alts = new Int16Array(balts);
  var degs = new Int8Array(bdegs);

  var n = mxs.length;

  var shouldAdds = new Uint8Array(n);

  var old_n = 0;

  olddres = new Uint16Array(bolddres);
  oldmxs = new Uint32Array(boldmxs);
  oldmys = new Uint32Array(boldmys);
  oldzs = new Int8Array(boldzs);
  old_n = olddres.length;

  var new_min_x = 256 << 21;
  var new_min_y = 256 << 21;
  var new_max_x = 0;
  var new_max_y = 0;

  var old_min_x = 256 << 21;
  var old_min_y = 256 << 21;
  var old_max_x = 0;
  var old_max_y = 0;

  var bitmap_fails = null;

  var isInExtent = true;

  if (old_n > 0) {
    var zxy = LatLonToXYZ_EPSG3857(0.0, 0.0, 21);
    var zx = zxy[0];
    var zy = zxy[1];
    var x, y, lat, lon;

    for (i = 0; i < old_n; i++) {
      if (oldzs[i] == 0) {
        x = oldmxs[i];
        y = oldmys[i];

        if (x != zx && y != zy) {
          if (y < old_min_y) old_min_y = y;
          else if (y > old_max_y) old_max_y = y;

          if (x < old_min_x) old_min_x = x;
          else if (x > old_max_x) old_max_x = x;
        } // if
      } // if
    } // for

    for (i = 0; i < mxs.length; i++) {
      x = mxs[i];
      y = mys[i];

      if (x != zx && y != zy) {
        if (y < new_min_y) new_min_y = y;
        else if (y > new_max_y) new_max_y = y;

        if (x < new_min_x) new_min_x = x;
        else if (x > new_max_x) new_max_x = x;
      } // if
    } // for

    isInExtent = !(new_max_x < old_min_x || new_min_x > old_max_x || new_max_y < old_min_y || new_min_y > old_max_y);
  } // if
  else {
    isInExtent = false;
  } // else

  if (isInExtent) {
    if (mxs.length * olddres.length > 50000) {
      var bitmap_n = 0;
      var x, y;
      var w = isMobile ? 256 >>> 0 : 8192 >>> 0;
      var h = w;
      var zsr = isMobile ? (21 - 0) >>> 0 : (21 - 5) >>> 0;
      var zsl = isMobile ? 0 >>> 0 : 0 >>> 0;
      var src_z_max = isMobile ? 1 : 6;
      var idx, bitidx;
      var px_u08 = new Uint8Array(1);

      bitmap_fails = new Uint8Array(mxs.length);

      if (self.oldtile == null) {
        var malloc_size = (w * h) >>> 3;
        self.oldtile = new Uint8Array(malloc_size);
      } // if

      for (i = self.oldtile_last_n; i < olddres.length; i++) {
        if (oldzs[i] < src_z_max) {
          idx = ((oldmys[i] >>> zsr) << zsl) * w + ((oldmxs[i] >>> zsr) << zsl);

          bitidx = idx % 8 >>> 0;
          idx >>>= 3;

          self.oldtile[idx] |= (1 << bitidx) | 0; // set bit
        }
      } // for

      self.oldtile_last_n = olddres.length;

      for (
        y = (h >>> 1) - 2;
        y <= (h >>> 1) + 2;
        y++ // clear (0,0) area
      ) {
        for (x = (w >>> 1) - 2; x <= (w >>> 1) + 2; x++) {
          idx = y * w + x;
          idx >>>= 3;
          self.oldtile[idx] = 0;
        } // for
      } // for

      for (i = 0; i < mxs.length; i++) {
        idx = ((mys[i] >>> zsr) << zsl) * w + ((mxs[i] >>> zsr) << zsl);
        bitidx = idx % 8 >>> 0;
        idx >>>= 3;

        if (self.oldtile[idx] & ((1 << bitidx) | 0)) {
          bitmap_fails[i] = 1;
          bitmap_n++;
        } // if
      } // for

      isInExtent = bitmap_n > 0;
    } // if
  } // if

  if (isInExtent) {
    var mx, my, z_diff;
    var no_bitmap = bitmap_fails == null;
    old_min_x >>>= 0;
    old_min_y >>>= 0;
    old_max_x >>>= 0;
    old_max_y >>>= 0;

    var z_filter_start = 21;
    var stride = 1;

    var this_z, cpm;

    for (var z_filter = z_filter_start; z_filter >= 0; z_filter--) {
      z_diff = (21 - z_filter) >>> 0;
      if (z_filter > 0) z_diff = (z_diff + 1) >>> 0;
      if (z_filter > 1) z_diff = (z_diff + 1) >>> 0;

      if (z_filter == z_filter_start) {
        for (i = 0; i < old_n; i++) {
          oldmxs[i] >>>= 2;
          oldmys[i] >>>= 2;
        } // for
      } // if
      else if (z_filter > 1) {
        for (i = 0; i < old_n; i++) {
          if (oldzs[i] <= z_filter) {
            oldmxs[i] >>>= 1;
            oldmys[i] >>>= 1;
          } // if
        } // for
      } // else if

      for (i = 0; i < n; i++) {
        if (minzs[i] == z_filter) {
          exists = false;
          this_z = minzs[i];

          if (no_bitmap || bitmap_fails[i] == 1) {
            // this_z >= z_filter
            mx = mxs[i];
            my = mys[i];

            if (!(mx < old_min_x || mx > old_max_x || my < old_min_y || my > old_max_y)) {
              mx >>>= z_diff;
              my >>>= z_diff;
              cpm = parseInt(cpms[i] * 0.018724571);

              for (j = 0; j < old_n; j += stride) {
                if (z_filter == oldzs[j] && mx == oldmxs[j] && my == oldmys[j] && cpm < olddres[j]) {
                  exists = true;
                  break;
                } // if
              } // for
            } // if
          } // if

          if (!exists) {
            shouldAdds[i] = 1;
            shouldAdd_c++;
          } // if
        } // if minz = z_filter
      } // for i
    } // for z_filter
  } // if
  else {
    if (bitmap_fails == null) {
      shouldAdd_c = mxs.length;
    } // if
    else {
      for (i = 0; i < n; i++) {
        var z = isMobile ? 0 : 5;

        if (bitmap_fails[i] == 0 || minzs[i] > z) {
          shouldAdds[i] = 1;
          shouldAdd_c++;
        } // if
      } // for
    } // else
  } // else

  if (bitmap_fails != null) bitmap_fails = null;

  olddres = null;
  oldzs = null;
  oldmxs = null;
  oldmys = null;
  bolddres = null;
  boldzs = null;

  var logids = null;

  if (shouldAdd_c > 0) {
    if (mxs.length != shouldAdd_c) {
      mxs = vcmprs_u32(mxs, 0, shouldAdds, shouldAdd_c, mxs.length);
      mys = vcmprs_u32(mys, 0, shouldAdds, shouldAdd_c, mys.length);
      minzs = vcmprs_s08(minzs, 0, shouldAdds, shouldAdd_c, minzs.length);
      alts = vcmprs_s16(alts, 0, shouldAdds, shouldAdd_c, alts.length);
      degs = vcmprs_s08(degs, 0, shouldAdds, shouldAdd_c, degs.length);
      times = vcmprs_u32(times, 0, shouldAdds, shouldAdd_c, times.length);
      cpms = vcmprs_f32(cpms, 0, shouldAdds, shouldAdd_c, cpms.length);
    } // if

    logids = new Int32Array(shouldAdd_c);
    for (i = 0; i < shouldAdd_c; i++) logids[i] = logId;
  } // if
  else {
    mxs = new Uint32Array(1);
    mys = new Uint32Array(1);
    minzs = new Int8Array(1);
    alts = new Int16Array(1);
    degs = new Int8Array(1);
    times = new Uint32Array(1);
    cpms = new Float32Array(1);
    logids = new Int32Array(1);
  } // else

  self.postMessage(
    {
      op: 'DATA_FOR_PARSED_LOG',
      logId: logId,
      userData: userData,
      shouldAdd_c: shouldAdd_c,
      worker_id: worker_id,
      minzs: minzs.buffer,
      cpms: cpms.buffer,
      alts: alts.buffer,
      degs: degs.buffer,
      logids: logids.buffer,
      times: times.buffer,
      mxs: mxs.buffer,
      mys: mys.buffer,
    },
    [minzs.buffer, cpms.buffer, alts.buffer, degs.buffer, logids.buffer, times.buffer, mxs.buffer, mys.buffer]
  );
};

self.GetStringForArrayBuffer = function(src) {
  var dest = null;

  if (self.TextDecoder != null) {
    var dv = new DataView(src);
    var de = new self.TextDecoder('UTF-8');
    dest = de.decode(dv);
    de = null;
    dv = null;
  } // if
  else {
    self.postMessage({
      op: 'DEBUG_MSG',
      txt: 'WARNING: Attempting to decode arraybuffer without TextDecoder!',
      worker_id: 0,
    });

    var src_u08 = new Uint8Array(src);
    dest = '';

    for (var i = 0; i < src_u08.length; i++) {
      dest += src_u08[i].toString(16);
    } // for

    src_u08 = null;
  } // else

  return dest;
};

// ******** MISC NUMERICS SUPPORT FUNCTIONS ***********

// s:  src vec
// x:  scalar value in gate vec to *not* copy (eg NODATA)
// g:  gate vec
// nn: new vec size; total number of elements to copy (must know count of x a priori)
// sn: number of elements in src to read
function vcmprs_f32(s, x, g, nn, sn) {
  var d = new Float32Array(nn);
  var j = 0;
  for (var i = 0; i < sn; i++) if (g[i] != x) d[j++] = s[i];
  return d;
}
function vcmprs_u32(s, x, g, nn, sn) {
  var d = new Uint32Array(nn);
  var j = 0;
  for (var i = 0; i < sn; i++) if (g[i] != x) d[j++] = s[i];
  return d;
}
function vcmprs_s16(s, x, g, nn, sn) {
  var d = new Int16Array(nn);
  var j = 0;
  for (var i = 0; i < sn; i++) if (g[i] != x) d[j++] = s[i];
  return d;
}
function vcmprs_u08(s, x, g, nn, sn) {
  var d = new Uint8Array(nn);
  var j = 0;
  for (var i = 0; i < sn; i++) if (g[i] != x) d[j++] = s[i];
  return d;
}
function vcmprs_s08(s, x, g, nn, sn) {
  var d = new Int8Array(nn);
  var j = 0;
  for (var i = 0; i < sn; i++) if (g[i] != x) d[j++] = s[i];
  return d;
}

function vtrunc_f32(s, n) {
  var d = new Float32Array(n);
  d.set(s.subarray(0, n));
  return d;
}
function vtrunc_u32(s, n) {
  var d = new Uint32Array(n);
  d.set(s.subarray(0, n));
  return d;
}
function vtrunc_s16(s, n) {
  var d = new Int16Array(n);
  d.set(s.subarray(0, n));
  return d;
}
function vtrunc_u08(s, n) {
  var d = new Uint8Array(n);
  d.set(s.subarray(0, n));
  return d;
}
function vtrunc_s08(s, n) {
  var d = new Int8Array(n);
  d.set(s.subarray(0, n));
  return d;
}

function vscount_s08(s, x, n) {
  var c = 0;
  for (var i = 0; i < n; i++) if (s[i] == x) c++;
  return c;
}

function vindex_u32(s, x, d, n) {
  var i,
    m = n - (n % 4);
  for (i = 0; i < m; i += 4) {
    d[i] = s[x[i]];
    d[i + 1] = s[x[i + 1]];
    d[i + 2] = s[x[i + 2]];
    d[i + 3] = s[x[i + 3]];
  }
  for (i = m; i < m + (n % 4); i++) d[i] = s[x[i]];
}

function vcopy_f64(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_f32(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_u32(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_s32(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_u16(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_s16(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_u08(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}
function vcopy_s08(d, od, s, os, n) {
  d.subarray(od, od + n).set(s.subarray(os, os + n));
}

function LatLonToXYZ_EPSG3857(lat, lon, z) {
  var x = (lon + 180.0) * 0.00277777777777777777777777777778;
  var s = Math.sin(lat * 0.01745329251994329576923690768489);
  var y = 0.5 - Math.log((1.0 + s) / (1.0 - s)) * 0.07957747154594766788444188168626;
  var w = 256 << z;

  var px = parseInt(x * w + 0.5);
  var py = parseInt(y * w + 0.5);

  return [px, py];
}

function PointDistanceMeters_EPSG4326(lat0, lon0, lat1, lon1) {
  // not really, this is for a sphere, not an ellipsoid

  if (
    lat0 == 0.0 ||
    lon0 == 0.0 ||
    lat1 == 0.0 ||
    lon1 == 0.0 ||
    lat0 == -9000.0 ||
    lon0 == -9000.0 ||
    lat1 == -9000.0 ||
    lon1 == -9000.0
  )
    return 0.0; // sanity check input

  var r = 6371.0; // earth
  var p0 = lat0 * 0.01745329251994329576923690768489;
  var L0 = lon0 * 0.01745329251994329576923690768489;
  var p1 = lat1 * 0.01745329251994329576923690768489;
  var L1 = lon1 * 0.01745329251994329576923690768489;
  var dp = p1 - p0;
  var dL = L1 - L0;

  var a =
    Math.sin(dp * 0.5) * Math.sin(dp * 0.5) + Math.cos(p0) * Math.cos(p1) * Math.sin(dL * 0.5) * Math.sin(dL * 0.5);
  var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
  var d = r * c;

  d = d * 1000.0; // km --> m

  return d;
} // PointDistanceMeters_EPSG4326

function GetHeading_EPSG4326(lat0, lon0, lat1, lon1) {
  var dx = (lon1 - lon0) * 0.01745329251994329576923690768489;
  var r0 = lat0 * 0.01745329251994329576923690768489;
  var r1 = lat1 * 0.01745329251994329576923690768489;

  var y = Math.sin(dx) * Math.cos(r1);

  var x = Math.cos(r0) * Math.sin(r1) - Math.sin(r0) * Math.cos(r1) * Math.cos(dx);

  var t = Math.atan2(y, x);

  return (t * 57.295779513082320876798154814105 + 360.0) % 360;
}

// ****** DEBUG HELPER FUNCTIONS *******
function YtoLat_z21(y) {
  return (
    90.0 -
    360.0 *
      Math.atan(Math.exp(-(0.5 - y * 0.00000000186264514923095703125) * 6.283185307179586476925286766559)) *
      0.318309886183790671538
  );
}
function XtoLon_z21(x) {
  return 360.0 * (x * 0.00000000186264514923095703125 - 0.5);
}

function XYZtoLatLon_EPSG3857(x, y, z) {
  var w = 256 << z;
  var r = 1.0 / w;
  x = x * r - 0.5;
  y = 0.5 - y * r;
  var lat =
    90.0 - 360.0 * Math.atan(Math.exp(-y * 6.283185307179586476925286766559)) * 0.31830988618379067153776752674503;
  var lon = 360.0 * x;
  return [lat, lon];
}

// The checksum is a XOR of all the ASCII characters bytes between '$' and '*' (these excluded). Sample C code to compute the checksum is given.

/* Compute checksum of input array */
/*
char GPS_checksum(char *s, int N) 
{             
  int i = 0;  
  char chk = s[0];

  for (i=1 ; i < N ; i++)                                                                
    chk ^= s[i];

  return chk;
} 
*/

function GPS_checksum(s, n) {
  var chk = s.charCodeAt(0);

  for (var i = 1; i < n; i++) {
    chk ^= s.charCodeAt(i);
  } // for

  return chk;
} // GPS_checksum

// The checksum is then always encoded as a string of two ASCII characters giving the hexadecimal value of the checksum.

function IsValidChecksum(line, checksum) {
  var is_valid = false;

  if (line.indexOf('*') > -1) {
    var ss = line.substring(1, line.length);
    var chk = GPS_checksum(ss, ss.indexOf('*'));
    is_valid = parseInt('0x' + checksum) == chk;
  } // if

  return is_valid;
} // IsValidChecksum
